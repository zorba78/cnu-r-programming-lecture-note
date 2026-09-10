#!/usr/bin/env Rscript
# rmd2qmd.R — bookdown Rmd 한 장을 Quarto qmd 로 기계 변환한다. 원본은 건드리지 않는다.
# 사용법: Rscript rmd2qmd.R <chapter.Rmd> [출력.qmd]
# 처리: block2 → callout, \@ref() → @..., 헤딩 {#id} → {#sec-id}, fig.cap 청크 레이블 → fig-*,
#       장 앞 YAML 제거, (PART) 헤딩 제거. 코드 청크 내부는 건드리지 않는다.
#       나머지는 수동 확인 (SKILL.md 참고).

args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("사용법: Rscript rmd2qmd.R <chapter.Rmd> [출력.qmd]")
inp <- args[[1]]
out <- if (length(args) > 1) args[[2]] else sub("\\.Rmd$", ".qmd", inp)
x <- readLines(inp, warn = FALSE, encoding = "UTF-8")

# 1. 파일 맨 앞 YAML 블록 제거
if (length(x) && grepl("^---\\s*$", x[1])) {
  end <- which(grepl("^---\\s*$", x))[2]
  if (!is.na(end)) x <- x[-(1:end)]
}

# 2. block2 → callout (펜스 상태를 추적하면서)
map <- c(rmdnote = "note", rmdtip = "tip", rmdimportant = "important",
         rmdcaution = "caution", rmdwarning = "warning")
i <- 1
while (i <= length(x)) {
  m <- regmatches(x[i], regexec("^\\s*```\\{block2,\\s*type\\s*=\\s*[\"']([a-z]+)[\"'].*\\}\\s*$", x[i]))[[1]]
  if (length(m) == 2 && m[2] %in% names(map)) {
    x[i] <- sprintf("::: {.callout-%s}", map[[m[2]]])
    j <- i + 1
    while (j <= length(x) && !grepl("^\\s*```\\s*$", x[j])) j <- j + 1
    if (j <= length(x)) x[j] <- ":::"
    i <- j
  }
  i <- i + 1
}

# 코드 펜스 내부 여부 (```{...} ... ``` 구간)
in_code <- logical(length(x)); open <- FALSE
for (k in seq_along(x)) {
  if (!open && grepl("^\\s*```+\\s*\\{", x[k])) { open <- TRUE; in_code[k] <- TRUE; next }
  if (open) { in_code[k] <- TRUE; if (grepl("^\\s*```+\\s*$", x[k])) open <- FALSE }
}
prose <- !in_code

# 3. (PART) 헤딩 제거
drop <- prose & grepl("^#\\s*\\(PART\\)", x)
x <- x[!drop]; prose <- prose[!drop]; in_code <- in_code[!drop]

# 4. fig.cap 이 있는 청크 레이블 → fig-<label>
fig_labels <- character()
for (k in which(in_code)) {
  if (grepl("^\\s*```\\{r\\s+[^,}=]+,.*fig\\.cap", x[k])) {
    lab <- trimws(sub("^\\s*```\\{r\\s+([^,}=]+),.*$", "\\1", x[k]))
    new <- paste0("fig-", gsub("[_.:]", "-", lab))
    x[k] <- sub(paste0("\\{r\\s+", lab, "(?=,)"), paste0("{r ", new), x[k], perl = TRUE)
    fig_labels[lab] <- new
  }
}

# 5. 상호참조 (본문만)
x[prose] <- gsub("\\\\@ref\\(fig:([A-Za-z0-9_.:-]+)\\)", "@fig-\\1", x[prose])
x[prose] <- gsub("\\\\@ref\\(tab:([A-Za-z0-9_.:-]+)\\)", "@tbl-\\1", x[prose])
x[prose] <- gsub("\\\\@ref\\(([A-Za-z0-9_-]+)\\)", "@sec-\\1", x[prose])
for (rep in 1:3)  # 레이블 안의 _ . : → - (최대 3회 반복 치환)
  x[prose] <- gsub("(@(fig|tbl|sec)-[A-Za-z0-9-]*)[_.:]", "\\1-", x[prose], perl = TRUE)

# 6. 헤딩 ID → sec- 접두, {-} → {.unnumbered} (본문 헤딩만)
h <- prose & grepl("^#{1,6}\\s", x)
x[h] <- gsub("\\{-\\}", "{.unnumbered}", x[h])
x[h] <- gsub("\\{-#(?!sec-)([A-Za-z0-9_-]+)\\}", "{#sec-\\1 .unnumbered}", x[h], perl = TRUE)
x[h] <- gsub("\\{#(?!sec-)([A-Za-z0-9_-]+)", "{#sec-\\1", x[h], perl = TRUE)

writeLines(x, out, useBytes = TRUE)
cat(sprintf("%s → %s (%d줄). fig 레이블 %d개 변경. 수동 확인 항목은 SKILL.md 참고.\n",
            inp, out, length(x), length(fig_labels)))
