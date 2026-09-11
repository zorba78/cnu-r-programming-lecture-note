#!/usr/bin/env Rscript
# 허브의 "주제 상세" 화면 생성기
#
#   Rscript hub/topic-page.R 08-algorithms        # → hub/08-algorithms.html
#
# 렌더된 슬라이드(docs/preview/<장>-slides.html)와 강의노트(docs/preview/<장>.html)를 읽어
# 절마다 슬라이드 번호 구간, 절 표지의 의도와 질문, 노트 발췌와 소절 목록을 뽑는다.
# 슬라이드를 넣고 빼면 번호 구간이 밀리므로 결과 HTML 을 손으로 고치지 않고 다시 생성한다.
# upgrade/render-preview.sh 가 렌더 뒤에 자동으로 부른다. 배포는 bash hub/sync.sh.
#
# 화면 구성은 허브 시안의 '주제 상세' 아트보드(upgrade/hub-design/Topic.dc.html)를 따른다.
suppressMessages(library(xml2))

# 주제 상세를 두는 장. anchor 는 hub/index.html 의 주제 행 id 다.
chapters <- list(
  "08-algorithms" = list(num = "08", part = "PART 1 · 프로그래밍 입문", anchor = "ch8", status = "개편 초안")
)

key <- commandArgs(TRUE)[1]
if (is.na(key) || is.null(chapters[[key]]))
  stop("사용법: Rscript hub/topic-page.R <장>   (등록된 장: ", paste(names(chapters), collapse = ", "), ")")
ch <- chapters[[key]]

self <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
root <- normalizePath(file.path(dirname(normalizePath(self)), ".."))
deck_file  <- file.path(root, "docs", "preview", paste0(key, "-slides.html"))
notes_file <- file.path(root, "docs", "preview", paste0(key, ".html"))
for (f in c(deck_file, notes_file))
  if (!file.exists(f)) stop("렌더본이 없다: ", f, "\n  먼저 bash upgrade/render-preview.sh 로 렌더한다.")
out_file <- file.path(root, "hub", paste0(key, ".html"))

# docs/hub/ 에서 본 상대 경로
deck_url  <- paste0("../preview/", key, "-slides.html")
notes_url <- paste0("../preview/", key, ".html")


# ---- 도우미 ------------------------------------------------------------------

squish <- function(s) { s[is.na(s)] <- ""; trimws(gsub("\\s+", " ", s)) }
txt <- function(node) if (inherits(node, "xml_missing")) "" else squish(xml_text(node))
esc <- function(s) {
  s <- gsub("&", "&amp;", s, fixed = TRUE); s <- gsub("<", "&lt;", s, fixed = TRUE)
  s <- gsub(">", "&gt;", s, fixed = TRUE); gsub("\"", "&quot;", s, fixed = TRUE)
}
drop_prefix <- function(s, p) if (nzchar(p) && startsWith(s, p)) squish(substring(s, nchar(p) + 1)) else s
cls_is <- function(cls) sprintf("contains(concat(' ', normalize-space(@class), ' '), ' %s ')", cls)
clip <- function(s, n) if (nchar(s) > n) paste0(substr(s, 1, n - 1), "…") else s

# 수식은 MathJax 없이 읽히도록 기호만 남긴다
tex_plain <- function(tex) {
  tex <- gsub("^\\\\\\(|\\\\\\)$", "", tex)
  tex <- gsub("\\\\(mathcal|mathrm|mathbf|text)\\{([^}]*)\\}", "\\2", tex)
  map <- c("\\times" = "×", "\\cdot" = "·", "\\le" = "≤", "\\ge" = "≥", "\\ldots" = "…",
           "\\dots" = "…", "\\infty" = "∞", "\\log" = "log", "\\approx" = "≈", "\\neq" = "≠")
  for (m in names(map)) tex <- gsub(m, map[[m]], tex, fixed = TRUE)
  squish(gsub("\\\\", "", tex))
}

# 문단을 허브용 인라인 HTML 로. 굵게·기울임·코드는 살리고, 노트 안 참조 링크는 노트로 잇는다.
inline <- function(node) {
  out <- character(0)
  for (k in xml_contents(node)) {
    type <- xml_type(k)
    if (type == "text") { out <- c(out, esc(xml_text(k))); next }
    if (type != "element") next
    nm <- xml_name(k); cls <- xml_attr(k, "class"); cls[is.na(cls)] <- ""
    if (nm == "span" && grepl("\\bmath\\b", cls)) {
      out <- c(out, "<i>", esc(tex_plain(xml_text(k))), "</i>")
    } else if (nm %in% c("strong", "b")) {
      out <- c(out, "<strong>", inline(k), "</strong>")
    } else if (nm %in% c("em", "i")) {
      out <- c(out, "<em>", inline(k), "</em>")
    } else if (nm == "code") {
      out <- c(out, "<code>", esc(xml_text(k)), "</code>")
    } else if (nm == "a") {
      href <- xml_attr(k, "href")
      if (!is.na(href) && startsWith(href, "#")) href <- paste0(notes_url, href)
      out <- c(out, sprintf("<a href=\"%s\">", esc(href)), inline(k), "</a>")
    } else {
      out <- c(out, inline(k))
    }
  }
  squish(paste(out, collapse = ""))
}


# ---- 슬라이드 ----------------------------------------------------------------

deck <- read_html(deck_file)
# Reveal.getSlides() 와 같은 순서: 안에 section 이 없는 section 이 슬라이드 한 장이다
leaves <- xml_find_all(deck, sprintf("//div[%s]//section[not(.//section)]", cls_is("slides")))
slides <- lapply(seq_along(leaves), function(i) {
  s <- leaves[[i]]; cls <- xml_attr(s, "class"); cls[is.na(cls)] <- ""
  h <- xml_find_first(s, ".//h1 | .//h2")
  secno <- txt(xml_find_first(h, sprintf(".//span[%s]", cls_is("secno"))))
  id <- xml_attr(s, "id")
  title <- if (identical(id, "title-slide")) "표지" else drop_prefix(txt(h), secno)
  is_predict <- grepl("\\bpredict\\b", cls)
  # 예측 슬라이드는 제목이 모두 '예측해 보자' 이므로 바로 아래의 질문 문단을 카드 제목으로 쓴다
  if (is_predict) { q <- txt(xml_find_first(s, "./p")); if (nzchar(q)) title <- clip(q, 60) }
  list(n = i, id = id, node = s, secno = secno, title = title,
       is_sec = grepl("\\bsection-title\\b", cls), is_predict = is_predict)
})

sec_at <- which(vapply(slides, function(s) s$is_sec, logical(1)))
if (!length(sec_at)) stop("절 표지 슬라이드(.section-title)가 없다: ", deck_file)
ends <- c(sec_at[-1] - 1, length(slides))
# 마지막 절 뒤에 절 번호 없는 슬라이드(정리 등)는 마무리로 뗀다. 예측 슬라이드는 절에 남긴다.
j <- ends[length(ends)]
while (j > sec_at[length(sec_at)] && !nzchar(slides[[j]]$secno) && !slides[[j]]$is_predict) j <- j - 1
closing <- if (j < ends[length(ends)]) (j + 1):ends[length(ends)] else integer(0)
ends[length(ends)] <- j
opening <- if (sec_at[1] > 1) seq_len(sec_at[1] - 1) else integer(0)

sec_meta <- function(s) {
  cols <- xml_find_all(s$node, sprintf(".//div[%s]", cls_is("column")))
  intent <- if (length(cols)) vapply(xml_find_all(cols[[1]], "./p"), inline, "") else character(0)
  q <- txt(xml_find_first(s$node, sprintf(".//div[%s]", cls_is("keypoint"))))
  list(intent = intent, question = sub("^이 절이 답하는 질문\\s*[—–-]\\s*", "", q))
}


# ---- 강의노트 ----------------------------------------------------------------

notes <- read_html(notes_file)
chap_title <- txt(xml_find_first(notes, sprintf("//h1[%s]", cls_is("title"))))
num_of <- function(h) txt(xml_find_first(h, sprintf(".//span[%s]", cls_is("header-section-number"))))
note_secs <- list()
for (s in xml_find_all(notes, sprintf("//section[%s][starts-with(@id, 'sec-')]", cls_is("level2")))) {
  h2 <- xml_find_first(s, "./h2"); num <- num_of(h2)
  if (!nzchar(num)) next                                   # 연습문제처럼 번호 없는 절
  subs <- lapply(xml_find_all(s, sprintf("./section[%s]", cls_is("level3"))), function(t) {
    h3 <- xml_find_first(t, "./h3"); n3 <- num_of(h3)
    list(id = xml_attr(t, "id"), num = n3, title = drop_prefix(txt(h3), n3))
  })
  # 발췌: 절 머리 문단 → 절 머리 콜아웃 본문 → 첫 소절의 문단. 160자를 넘을 때까지, 최대 세 문단.
  paras <- xml_find_all(s, "./p")
  if (!length(paras)) paras <- xml_find_all(s, sprintf("./div[%s]//div[%s]/p", cls_is("callout"), cls_is("callout-body-container")))
  if (!length(paras)) paras <- xml_find_all(s, sprintf("./section[%s][1]/p", cls_is("level3")))
  take <- 0; total <- 0
  for (p in paras) { take <- take + 1; total <- total + nchar(txt(p)); if (total >= 160 || take == 3) break }
  note_secs[[num]] <- list(id = xml_attr(s, "id"), num = num, title = drop_prefix(txt(h2), num),
                           subs = subs, excerpt = vapply(paras[seq_len(take)], inline, ""))
}

groups <- lapply(seq_along(sec_at), function(k) {
  first <- slides[[sec_at[k]]]
  list(k = k, num = first$secno, title = first$title, from = sec_at[k], to = ends[k],
       meta = sec_meta(first), note = note_secs[[first$secno]])
})


# ---- HTML --------------------------------------------------------------------

sno <- function(i) sprintf("S%02d", i)
rng <- function(a, b) if (a == b) sno(a) else paste0(sno(a), "–", sno(b))
slide_href <- function(s) paste0(deck_url, "#/", URLencode(s$id, reserved = TRUE))
hid <- function(k) if (k > 1) " hidden" else ""

card <- function(s) {
  cls <- paste(c("card", if (s$is_sec) "is-sec", if (s$is_predict) "is-predict"), collapse = " ")
  tag <- if (s$is_sec) "절 표지" else if (s$is_predict) "예측" else ""
  t <- if (nzchar(s$secno)) paste(s$secno, s$title) else s$title
  sprintf("<a class=\"%s\" href=\"%s\" target=\"deck\" data-id=\"%s\"><span class=\"card-n mono\"><span>%s</span><span class=\"card-tag\">%s</span></span><span class=\"card-t\">%s</span></a>",
          cls, esc(slide_href(s)), esc(s$id), sno(s$n), tag, esc(t))
}

strip <- function(g) {
  nav_prev <- if (g$k > 1) sprintf("<a href=\"#s%d\">&#9664; 이전 절</a>", g$k - 1) else "<span class=\"off\">&#9664; 이전 절</span>"
  nav_next <- if (g$k < length(groups)) sprintf("<a href=\"#s%d\">다음 절 &#9654;</a>", g$k + 1) else "<span class=\"off\">다음 절 &#9654;</span>"
  paste0(
    sprintf("<div class=\"strip\" data-panel=\"%d\"%s>\n", g$k, hid(g$k)),
    sprintf("  <div class=\"strip-head\"><span class=\"mono\">%s %s · %s · %d장</span><span class=\"mono strip-nav\">%s · %s</span></div>\n",
            esc(g$num), esc(g$title), rng(g$from, g$to), g$to - g$from + 1, nav_prev, nav_next),
    "  <div class=\"cards\">\n    ", paste(vapply(slides[g$from:g$to], card, ""), collapse = "\n    "), "\n  </div>\n</div>")
}

note_panel <- function(g) {
  n <- g$note; m <- g$meta
  body <- if (is.null(n)) "<p class=\"none\">이 절에 대응하는 강의노트 절을 찾지 못했다.</p>" else paste0(
    sprintf("<div class=\"n-head\"><div class=\"disp n-title\">%s %s</div><div class=\"mono n-anchor\">§ #%s</div></div>\n", esc(n$num), esc(n$title), esc(n$id)),
    "<div class=\"excerpt\">", paste0("<p>", n$excerpt, "</p>", collapse = ""), "</div>\n",
    if (length(n$subs)) paste0("<ul class=\"subs\">", paste(vapply(n$subs, function(t)
      sprintf("<li><a href=\"%s#%s\"><span class=\"mono\">%s</span><span>%s</span></a></li>", notes_url, esc(t$id), esc(t$num), esc(t$title)), ""),
      collapse = ""), "</ul>\n") else "",
    sprintf("<a class=\"more\" href=\"%s#%s\">강의노트에서 이어 읽기 <span aria-hidden=\"true\">&#8594;</span></a>\n", notes_url, esc(n$id)))
  intro <- paste0(
    "<div class=\"s-intro\">\n<div class=\"kicker mono\"><i class=\"sq sq-slide\"></i>이 절의 슬라이드</div>\n",
    paste0("<p>", m$intent, "</p>", collapse = ""),
    if (nzchar(m$question)) sprintf("\n<div class=\"question\"><span class=\"mono\">이 절이 답하는 질문</span>%s</div>", esc(m$question)) else "",
    "\n</div>")
  paste0(sprintf("<div class=\"note\" data-panel=\"%d\"%s>\n", g$k, hid(g$k)),
         "<div class=\"kicker mono\"><i class=\"sq sq-note\"></i>대응하는 강의노트</div>\n", body, intro, "\n</div>")
}

deck_rows <- vapply(groups, function(g) sprintf(
  "<a class=\"deckrow%s\" href=\"#s%d\" data-sec=\"%d\"%s><span class=\"mono dr-range\">%s</span><span class=\"dr-title\">%s %s</span><span class=\"mono dr-count\">%d장</span></a>",
  if (g$k == 1) " is-current" else "", g$k, g$k, if (g$k == 1) " aria-current=\"true\"" else "",
  rng(g$from, g$to), esc(g$num), esc(g$title), g$to - g$from + 1), "")
edge <- function(ix) if (length(ix)) paste0(rng(min(ix), max(ix)), " ", paste(vapply(slides[ix], function(s) s$title, ""), collapse = " · "))
deck_foot <- paste(esc(c(edge(opening), edge(closing))), collapse = "<br>")

first_sec <- slides[[groups[[1]]$from]]
today <- format(Sys.Date())

css <- r"---(
  :root {
    color-scheme: light;
    --bg:#FAF7F2; --ink:#241F1A; --prose:#5C554C; --muted:#6E665C;
    --faint:#8C8479; --line:#E4DCD0; --line-2:#D5CABB;
    --panel:#F3EEE5; --panel-line:#C9BCA9; --card-line:#DCD3C6; --sel:#EAE0D1;
    --note:#A64B32; --note-hover:#7E3624; --slide:#1F6F7A; --slide-hover:#155059;
  }
  * { box-sizing:border-box; }
  [hidden] { display:none !important; }
  html { -webkit-text-size-adjust:100%; }
  body {
    margin:0; background:var(--bg); color:var(--ink);
    font-family:'IBM Plex Sans KR','Apple SD Gothic Neo','Malgun Gothic',sans-serif;
    -webkit-font-smoothing:antialiased; text-wrap:pretty;
  }
  a { color:var(--note); text-decoration:none; }
  a:hover { color:var(--note-hover); }
  .mono { font-family:'IBM Plex Mono','SFMono-Regular',ui-monospace,'Malgun Gothic','Apple SD Gothic Neo',monospace; }
  .disp { font-family:'Hahmlet','Nanum Myeongjo','Apple SD Gothic Neo',serif; }
  .wrap { max-width:1440px; margin:0 auto; }
  :focus-visible { outline:2px solid var(--note); outline-offset:2px; }

  /* 경로 */
  .crumbs {
    display:flex; justify-content:space-between; align-items:center; gap:8px 16px; flex-wrap:wrap;
    padding:18px 72px; border-bottom:1px solid var(--line);
    font-size:12px; letter-spacing:0.1em; color:var(--muted);
  }
  .crumbs a { color:var(--muted); }
  .crumbs a:hover { color:var(--ink); }
  .crumbs .sep { color:#C0B5A5; margin:0 6px; }
  .crumbs .here { color:var(--ink); }

  /* 제목 줄 */
  .t-head {
    display:flex; justify-content:space-between; align-items:flex-end; gap:24px 48px; flex-wrap:wrap;
    padding:34px 72px 26px;
  }
  .t-name { display:flex; align-items:baseline; gap:20px; }
  .t-num { font-size:34px; color:var(--note); }
  .t-name h1 { margin:0; font-size:38px; font-weight:700; letter-spacing:-0.02em; }
  .t-meta { margin-top:8px; font-size:13.5px; color:var(--muted); }
  .t-act { display:flex; flex-direction:column; align-items:flex-end; gap:9px; }
  .t-btns { display:flex; align-items:center; gap:12px; flex-wrap:wrap; }
  .btn { display:inline-flex; align-items:center; gap:9px; padding:12px 20px; font-size:14px; font-weight:500; }
  .btn-slide { background:var(--slide); color:var(--bg); }
  .btn-slide:hover { background:var(--slide-hover); color:var(--bg); }
  .btn-line { border:1px solid var(--slide); color:var(--slide); padding:11px 18px; }
  .btn-line:hover { background:rgba(31,111,122,0.07); color:var(--slide-hover); }
  .btn-text { padding:12px 4px; color:var(--note); }
  .t-hint { font-size:12px; color:var(--muted); }

  /* 본문 두 칸 */
  .t-grid {
    display:grid; grid-template-columns:minmax(0,1fr) 460px; gap:48px;
    padding:6px 72px 48px; align-items:start;
  }
  .t-left { display:flex; flex-direction:column; gap:20px; min-width:0; }
  .stage {
    background:#FFFFFF; border:1px solid var(--card-line);
    box-shadow:0 1px 0 #EDE6DA, 0 12px 28px -18px rgba(36,31,26,0.35);
  }
  .stage-bar { height:5px; background:var(--slide); }
  .stage-view { position:relative; aspect-ratio:16 / 9; overflow:hidden; background:#FFFFFF; }
  .stage-view iframe { display:block; width:100%; height:100%; border:0; background:#FFFFFF; }
  /* 덱을 원래 크기(1280×720)로 그리고 칸 폭에 맞춰 줄인다. 좁은 iframe 에 그대로 넣으면
     reveal.js 가 폭 435px 아래에서 스크롤 보기로 바뀌어 카드를 눌러도 슬라이드가 넘어가지 않는다. */
  .js .stage-view iframe {
    position:absolute; top:0; left:0; width:1280px; height:720px;
    transform-origin:0 0; transform:scale(var(--deck-scale, 0.6));
  }
  .stage-foot {
    display:flex; justify-content:space-between; gap:6px 16px; flex-wrap:wrap;
    padding:10px 14px; border-top:1px solid var(--line); font-size:12px; color:var(--muted);
  }
  .strip { display:flex; flex-direction:column; gap:11px; }
  .strip-head {
    display:flex; justify-content:space-between; align-items:baseline; gap:6px 12px; flex-wrap:wrap;
    font-size:11px; letter-spacing:0.12em; color:var(--muted);
  }
  .strip-nav a { color:var(--muted); }
  .strip-nav a:hover { color:var(--ink); }
  .strip-nav .off { color:#C9BFB0; }
  .cards { display:grid; grid-template-columns:repeat(4, minmax(0,1fr)); gap:10px; }
  .card {
    display:flex; flex-direction:column; gap:5px; min-height:76px; padding:9px 11px;
    background:#FFFFFF; border:1px solid var(--card-line); color:var(--prose);
  }
  .card:hover { border-color:var(--slide); color:var(--ink); }
  .card-n { display:flex; justify-content:space-between; gap:6px; font-size:11px; color:var(--faint); }
  .card-tag { color:var(--slide); letter-spacing:0.06em; }
  .card-t {
    font-size:13px; line-height:1.45; overflow:hidden;
    display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical;
  }
  .card.is-sec { background:var(--panel); }
  .card.is-predict { border-left:3px solid var(--slide); padding-left:9px; }
  .card.is-current { border:2px solid var(--slide); padding:8px 10px; color:var(--ink); }

  /* 오른쪽 칸 */
  aside.t-side {
    display:flex; flex-direction:column; gap:22px; padding:26px;
    background:var(--panel); border:1px solid var(--line);
  }
  .note { display:flex; flex-direction:column; gap:16px; }
  .kicker { display:flex; align-items:center; gap:9px; font-size:11px; letter-spacing:0.16em; }
  .sq { display:block; width:9px; height:9px; flex-shrink:0; }
  .sq-note { background:var(--note); }
  .sq-slide { background:var(--slide); }
  .note > .kicker { color:var(--note); }
  .n-head { display:flex; flex-direction:column; gap:5px; }
  .n-title { font-size:21px; font-weight:700; }
  .n-anchor { font-size:11.5px; color:var(--faint); }
  .excerpt {
    display:flex; flex-direction:column; gap:11px; padding-left:14px; border-left:2px solid #D9BFB4;
    font-size:14px; line-height:1.8; color:#3A342C;
  }
  .excerpt p, .s-intro p { margin:0; }
  .excerpt code, .s-intro code {
    font-family:'IBM Plex Mono',ui-monospace,monospace; font-size:13px; background:var(--sel); padding:1px 5px;
  }
  .subs { list-style:none; margin:0; padding:0; display:flex; flex-direction:column; }
  .subs a { display:flex; gap:10px; align-items:baseline; padding:5px 0; font-size:13.5px; color:var(--prose); }
  .subs a:hover { color:var(--note); }
  .subs .mono { font-size:12px; color:var(--note); min-width:30px; }
  .more { display:inline-flex; align-items:center; gap:8px; font-size:13.5px; font-weight:500; }
  .none { margin:0; font-size:13.5px; color:var(--faint); }
  .s-intro {
    display:flex; flex-direction:column; gap:10px; border-top:1px solid var(--line-2); padding-top:18px;
    font-size:14px; line-height:1.75; color:#3A342C;
  }
  .s-intro .kicker { color:var(--slide); }
  .question {
    display:flex; flex-direction:column; gap:4px; padding:10px 12px;
    background:rgba(31,111,122,0.07); border-left:3px solid var(--slide);
    font-size:14px; line-height:1.6; color:var(--ink);
  }
  .question .mono { font-size:10.5px; letter-spacing:0.14em; color:var(--slide); }
  .decklist { display:flex; flex-direction:column; border-top:1px solid var(--line-2); padding-top:18px; }
  .decklist-h { font-size:11px; letter-spacing:0.16em; color:var(--muted); padding-bottom:6px; }
  .deckrow {
    display:grid; grid-template-columns:86px 1fr 40px; gap:12px; align-items:baseline;
    padding:9px 0; border-top:1px solid var(--line); color:var(--prose);
  }
  .decklist-h + .deckrow { border-top:none; }
  .deckrow:hover { color:var(--ink); }
  .dr-range { font-size:12px; color:var(--slide); }
  .dr-title { font-size:13.5px; }
  .dr-count { font-size:11.5px; color:var(--faint); text-align:right; }
  .deckrow.is-current { background:var(--sel); margin:0 -10px; padding:9px 10px; border-top-color:transparent; color:var(--ink); }
  .deckrow.is-current .dr-title { font-weight:600; }
  .deckrow.is-current + .deckrow { border-top-color:transparent; }
  .decklist-foot { padding-top:10px; font-size:11.5px; line-height:1.7; color:var(--faint); }

  /* 푸터 */
  footer {
    display:grid; grid-template-columns:1fr 1fr 240px; gap:48px;
    padding:32px 72px 52px; border-top:1px solid var(--ink);
  }
  .foot-col { display:flex; flex-direction:column; gap:7px; min-width:0; }
  .foot-col:last-child { text-align:right; }
  .foot-h { font-size:11px; letter-spacing:0.14em; color:var(--faint); }
  .foot-col a, .foot-col .v { font-size:14px; overflow-wrap:anywhere; }
  .foot-col .v { color:var(--prose); }

  /* 반응형 */
  @media (max-width:1100px) {
    .crumbs, .t-head, .t-grid, footer { padding-left:40px; padding-right:40px; }
    .t-grid { grid-template-columns:minmax(0,1fr); gap:32px; }
    .t-act { align-items:flex-start; }
    footer { grid-template-columns:1fr 1fr; }
    .foot-col:last-child { grid-column:1 / -1; text-align:left; }
  }
  @media (max-width:760px) {
    .crumbs, .t-head, .t-grid, footer { padding-left:16px; padding-right:16px; }
    .crumbs { padding-top:14px; padding-bottom:14px; }
    .t-head { padding-top:24px; }
    .t-name { gap:14px; }
    .t-num { font-size:26px; }
    .t-name h1 { font-size:30px; }
    .btn { padding:11px 14px; }
    .btn-line { padding:10px 13px; }
    .cards { grid-template-columns:repeat(2, minmax(0,1fr)); }
    aside.t-side { padding:20px 16px; }
    .deckrow { grid-template-columns:78px 1fr 34px; }
    footer { grid-template-columns:1fr; gap:22px; padding-bottom:40px; }
  }
)---"

js <- r"---(
(() => {
  const deck = document.getElementById('deck');
  const view = deck.parentElement;
  const fit = () => view.style.setProperty('--deck-scale', String(view.clientWidth / 1280));
  fit();
  if ('ResizeObserver' in window) new ResizeObserver(fit).observe(view); else window.addEventListener('resize', fit);
  const panels = [...document.querySelectorAll('[data-panel]')];
  const rows = [...document.querySelectorAll('.deckrow')];
  const cards = [...document.querySelectorAll('.card')];
  const byId = Object.fromEntries(cards.map(c => [c.dataset.id, c]));
  const secs = rows.map(r => r.dataset.sec);
  let cur = null;
  const mark = c => cards.forEach(x => x.classList.toggle('is-current', x === c));
  function show(k, move) {
    if (!secs.includes(k)) k = secs[0];
    cur = k;
    panels.forEach(p => { p.hidden = p.dataset.panel !== k; });
    rows.forEach(r => {
      const on = r.dataset.sec === k;
      r.classList.toggle('is-current', on);
      if (on) r.setAttribute('aria-current', 'true'); else r.removeAttribute('aria-current');
    });
    if (move) {
      const first = document.querySelector('.strip[data-panel="' + k + '"] .card');
      if (first) { deck.src = first.href; mark(first); }
    }
  }
  const fromHash = () => (location.hash.match(/^#s(\d+)$/) || [])[1];
  window.addEventListener('hashchange', () => show(fromHash(), true));
  document.addEventListener('click', e => { const c = e.target.closest('.card'); if (c) mark(c); });
  // 같은 출처(GitHub Pages)면 미리보기 안에서 넘긴 슬라이드를 카드와 절 목록이 따라간다.
  // file:// 로 열면 다른 출처로 취급되어 막히므로 조용히 건너뛴다.
  function follow() {
    try {
      const R = deck.contentWindow.Reveal;
      if (!R || R.__hubFollow) return;
      R.__hubFollow = true;
      const hook = () => R.on('slidechanged', e => {
        const c = byId[e.currentSlide.id];
        if (!c) return;
        mark(c);
        const k = c.closest('[data-panel]').dataset.panel;
        if (k !== cur) { show(k, false); history.replaceState(null, '', '#s' + k); }
      });
      R.isReady() ? hook() : R.on('ready', hook);
    } catch (err) { /* 다른 출처 */ }
  }
  deck.addEventListener('load', follow);
  follow();
  const k0 = fromHash();
  show(k0 || secs[0], Boolean(k0));
  if (!k0) mark(cards.find(c => !c.closest('[hidden]')));
})();
)---"

html <- paste0(
'<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>', esc(ch$num), ' ', esc(chap_title), ' — 강의 허브</title>
<meta name="description" content="', esc(ch$num), ' ', esc(chap_title), ' — 슬라이드와 대응하는 강의노트 절을 나란히 보는 주제 상세 화면.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Hahmlet:wght@400;500;700&amp;family=IBM+Plex+Mono:wght@400;500&amp;family=IBM+Plex+Sans+KR:wght@300;400;500;600;700&amp;display=swap">
<!-- 이 파일은 hub/topic-page.R 이 만든다. 손으로 고치지 말고 다시 생성한다. -->
<script>document.documentElement.classList.add("js");</script>
<style>', css, '</style>
</head>
<body>
<div class="wrap">

  <div class="crumbs">
    <div class="mono"><a href="index.html">강의 허브</a><span class="sep">/</span><a href="index.html#', ch$anchor, '">', esc(ch$part), '</a><span class="sep">/</span><span class="here">', esc(ch$num), ' ', esc(chap_title), '</span></div>
    <div class="mono">충남대학교 정보통계학과</div>
  </div>

  <header class="t-head">
    <div class="t-name">
      <span class="mono t-num">', esc(ch$num), '</span>
      <div>
        <h1 class="disp">', esc(chap_title), '</h1>
        <div class="t-meta">슬라이드 ', length(slides), '장 · 강의노트 ', length(note_secs), '개 절 · ', esc(ch$status), '</div>
      </div>
    </div>
    <div class="t-act">
      <div class="t-btns">
        <a class="btn btn-slide" href="', deck_url, '">슬라이드 열기 <span aria-hidden="true">&#8594;</span></a>
        <a class="btn btn-line" href="', deck_url, '?print-pdf" target="_blank" rel="noopener">PDF로 저장</a>
        <a class="btn btn-text" href="', notes_url, '">강의노트에서 보기 <span aria-hidden="true">&#8594;</span></a>
      </div>
      <div class="t-hint">PDF로 저장: 인쇄용 화면이 열리면 Ctrl+P (맥은 ⌘P) → 대상을 ‘PDF로 저장’으로</div>
    </div>
  </header>

  <div class="t-grid">
    <div class="t-left">
      <div class="stage">
        <div class="stage-bar"></div>
        <div class="stage-view"><iframe id="deck" name="deck" src="', esc(slide_href(first_sec)), '" title="슬라이드 미리보기" allow="fullscreen"></iframe></div>
        <div class="stage-foot"><span>미리보기 — 화면을 한 번 누른 뒤 ← → 키로 넘긴다</span><span>아래 카드를 누르면 그 슬라이드로 간다</span></div>
      </div>
', paste(vapply(groups, strip, ""), collapse = "\n"), '
    </div>

    <aside class="t-side">
', paste(vapply(groups, note_panel, ""), collapse = "\n"), '
      <nav class="decklist" aria-label="이 덱의 절">
        <div class="mono decklist-h">이 덱의 절</div>
', paste0("        ", deck_rows, collapse = "\n"), '
        <div class="mono decklist-foot">', deck_foot, '</div>
      </nav>
    </aside>
  </div>

  <footer>
    <div class="foot-col">
      <span class="mono foot-h">강의 허브</span>
      <a href="index.html">개편 교과 구성 전체 보기</a>
    </div>
    <div class="foot-col">
      <span class="mono foot-h">만든 방법</span>
      <span class="v">hub/topic-page.R 이 슬라이드·강의노트 렌더본에서 생성</span>
    </div>
    <div class="foot-col">
      <span class="mono foot-h">마지막 갱신</span>
      <span class="mono v">', today, '</span>
    </div>
  </footer>

</div>
<script>', js, '</script>
</body>
</html>
')

con <- file(out_file, open = "w", encoding = "UTF-8")
writeLines(html, con)
close(con)

cat(sprintf("%s: 슬라이드 %d장 · 절 %d개 · 노트 절 %d개 (대응 %d)\n",
            sub(paste0(root, "/"), "", out_file, fixed = TRUE), length(slides), length(groups), length(note_secs),
            sum(vapply(groups, function(g) !is.null(g$note), logical(1)))))
for (g in groups) cat(sprintf("  %s %-24s %s  노트 %s\n", g$num, g$title, rng(g$from, g$to), if (is.null(g$note)) "없음" else paste0("#", g$note$id)))
if (length(opening) || length(closing)) cat("  절 밖:", c(edge(opening), edge(closing)), sep = "\n    ")
