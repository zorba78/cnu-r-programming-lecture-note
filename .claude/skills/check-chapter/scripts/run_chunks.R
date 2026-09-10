#!/usr/bin/env Rscript
# run_chunks.R — Rmd 파일의 R 코드 청크를 순차 실행해 오류·경고를 보고한다.
#
# 사용법:
#   Rscript run_chunks.R <file.Rmd> [--timeout=60] [--from=N] [--to=N] [--verbose]
# 종료 코드: 예상치 못한 ERROR 가 1개 이상이면 1, 아니면 0.
#
# 청크는 전역 환경에서 평가한다 (knitr 와 동일). 스크립트 자체 상태는 local() 안에
# 두어, 청크의 rm(list = ls()) 에 영향받지 않게 한다.

local({
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) < 1 || !file.exists(args[[1]])) {
    cat("사용법: Rscript run_chunks.R <file.Rmd> [--timeout=60] [--from=N] [--to=N] [--verbose]\n")
    quit(status = 2)
  }
  file <- args[[1]]
  opt <- function(name, default) {
    m <- grep(paste0("^--", name, "="), args, value = TRUE)
    if (length(m)) sub(paste0("^--", name, "="), "", m[[1]]) else default
  }
  timeout <- as.numeric(opt("timeout", "60"))
  from    <- as.integer(opt("from", "1"))
  to      <- as.integer(opt("to", "0"))
  verbose <- "--verbose" %in% args

  lines <- readLines(file, warn = FALSE, encoding = "UTF-8")

  # ---- 청크 경계 찾기 --------------------------------------------------------
  open_re <- "^\\s*```+\\s*\\{r([ ,][^`]*)?\\}\\s*$"
  fence_re <- "^\\s*```+\\s*$"
  opens <- grep(open_re, lines)
  fences <- grep(fence_re, lines)
  chunks <- list()
  for (s in opens) {
    e <- fences[fences > s]
    if (!length(e)) next
    e <- e[[1]]
    hdr <- sub("^\\s*```+\\s*\\{r", "", lines[[s]])
    hdr <- sub("\\}\\s*$", "", hdr)
    hdr <- sub("^[ ,]*", "", hdr)
    first <- trimws(strsplit(hdr, ",")[[1]][1])
    label <- if (!is.na(first) && nzchar(first) && !grepl("=", first)) first else ""
    chunks[[length(chunks) + 1]] <- list(
      idx = length(chunks) + 1, line = s, label = label, header = hdr,
      code = if (e - s > 1) lines[(s + 1):(e - 1)] else character()
    )
  }
  n <- length(chunks)
  if (to <= 0 || to > n) to <- n
  if (from < 1) from <- 1

  # ---- 실행 환경 -------------------------------------------------------------
  grDevices::pdf(NULL)                # 그래픽 출력 버림
  options(warn = 1, width = 80, device = function(...) grDevices::pdf(NULL))
  env <- globalenv()
  depr_re <- "deprecated|superseded|defunct|no longer|Please use|was renamed"

  cat(sprintf("== check-chapter: %s (청크 %d개, 실행 범위 %d-%d, timeout %ds)\n",
              file, n, from, to, timeout))
  cat(sprintf("%4s %6s %-28s %-15s %7s  %s\n", "#", "line", "label", "status", "time", "message"))

  res <- vector("list", n)
  for (i in seq_len(n)) {
    ch <- chunks[[i]]
    status <- "OK"; msg <- ""; elapsed <- 0; warns <- character()
    skip_reason <- NULL
    h <- ch$header
    if (i < from || i > to) skip_reason <- "범위 밖"
    else if (grepl("eval\\s*=\\s*F(ALSE)?\\b", h)) skip_reason <- "eval=FALSE"
    else if (grepl("eval\\s*=", h) && !grepl("eval\\s*=\\s*T(RUE)?\\b", h)) skip_reason <- "eval=<식>"
    else if (!length(ch$code) || all(!nzchar(trimws(ch$code)))) skip_reason <- "빈 청크"
    expect_error <- grepl("error\\s*=\\s*T(RUE)?\\b", h)

    if (!is.null(skip_reason)) {
      status <- "SKIP"; msg <- skip_reason
    } else {
      t0 <- proc.time()[["elapsed"]]
      err <- tryCatch({
        setTimeLimit(elapsed = timeout, transient = TRUE)
        withCallingHandlers(
          {
            out <- utils::capture.output(
              eval(parse(text = ch$code, keep.source = FALSE), envir = env)
            )
            if (verbose && length(out)) cat(paste0("    | ", out), sep = "\n")
          },
          warning = function(w) {
            warns <<- c(warns, conditionMessage(w))
            invokeRestart("muffleWarning")
          },
          message = function(m) invokeRestart("muffleMessage")
        )
        NULL
      }, error = function(e) e)
      setTimeLimit(elapsed = Inf)
      elapsed <- proc.time()[["elapsed"]] - t0
      if (!is.null(err)) {
        m1 <- gsub("\\s+", " ", conditionMessage(err))
        if (expect_error) { status <- "EXPECTED-ERROR"; msg <- m1 }
        else { status <- "ERROR"; msg <- m1 }
      } else if (expect_error) {
        status <- "NO-ERROR?"; msg <- "error=TRUE 청크인데 오류가 나지 않음 (본문 설명 확인)"
      }
      dw <- unique(warns[grepl(depr_re, warns, ignore.case = TRUE)])
      if (length(dw)) msg <- paste0(msg, if (nzchar(msg)) " | ", "DEPRECATION: ",
                                    paste(gsub("\\s+", " ", dw), collapse = " || "))
      else if (length(warns) && status == "OK") msg <- sprintf("(경고 %d건)", length(warns))
    }
    res[[i]] <- list(idx = i, line = ch$line, label = ch$label, status = status,
                     time = elapsed, msg = msg, code = ch$code)
    cat(sprintf("%4d %6d %-28s %-15s %6.1fs  %s\n", i, ch$line,
                substr(ch$label, 1, 28), status, elapsed, substr(msg, 1, 160)))
  }

  # ---- 요약 -------------------------------------------------------------------
  st <- vapply(res, `[[`, "", "status")
  tab <- table(factor(st, levels = c("OK", "ERROR", "EXPECTED-ERROR", "NO-ERROR?", "SKIP")))
  cat("\n== 요약: ", paste(sprintf("%s %d", names(tab), tab), collapse = " / "), "\n", sep = "")

  bad <- which(st %in% c("ERROR", "NO-ERROR?"))
  if (length(bad)) {
    cat("\n== 확인 필요 청크 상세\n")
    for (i in bad) {
      r <- res[[i]]
      cat(sprintf("\n[#%d line %d label '%s'] %s\n  %s\n", r$idx, r$line, r$label, r$status, r$msg))
      cat(paste0("  > ", head(r$code, 6)), sep = "\n")
      if (length(r$code) > 6) cat("  > ...\n")
    }
  }
  depr <- which(grepl("DEPRECATION:", vapply(res, `[[`, "", "msg")))
  if (length(depr)) {
    cat("\n== deprecation 경고가 난 청크: ",
        paste(sprintf("#%d(line %d)", depr, vapply(res[depr], `[[`, 0L, "line")), collapse = ", "),
        "\n", sep = "")
  }
  if (file.exists("Rplots.pdf")) unlink("Rplots.pdf")
  quit(status = if (any(st == "ERROR")) 1L else 0L)
})
