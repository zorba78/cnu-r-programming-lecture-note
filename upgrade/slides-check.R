#!/usr/bin/env Rscript
# slides-check.R — 렌더된 revealjs 덱을 헤드리스 크롬으로 열어 슬라이드마다 화면을 찍고 배치를 잰다.
#
#   Rscript upgrade/slides-check.R docs/preview/08-algorithms-slides.html <출력폴더> [all|3,7,12]
#
# 출력: <출력폴더>/sNN.png (1280×720 창), <출력폴더>/metrics.tsv
#   bottom  내용 하단(px, 슬라이드 좌표). 본문 슬라이드는 680 이하 — 꼬리말 선이 약 695px 이다.
#   right   내용 오른쪽 끝. 1280 을 넘으면 칸 밖으로 샌 것이다.
#   scroll  가로 스크롤이 생긴 코드·표의 개수. 0 이어야 한다(코드 줄이 칸보다 김).
#   minfont 가장 작은 글자(px). MathJax 위첨자는 원래 작으므로 small 열에서 걸러 본다.
# 필요: R 패키지 chromote, jsonlite / 크롬(google-chrome).
suppressMessages(library(chromote))
a <- commandArgs(TRUE)
if (length(a) < 2) stop("사용법: Rscript upgrade/slides-check.R <deck.html> <outdir> [all|1,2,5]")
html <- normalizePath(a[1]); out <- a[2]; which <- if (length(a) > 2) a[3] else "all"
dir.create(out, showWarnings = FALSE, recursive = TRUE)

b <- ChromoteSession$new(width = 1280, height = 720)
b$Emulation$setDeviceMetricsOverride(width = 1280, height = 720, deviceScaleFactor = 1, mobile = FALSE)
p <- b$Page$loadEventFired(wait_ = FALSE); b$Page$navigate(paste0("file://", html), wait_ = FALSE); b$wait_for(p)
ev <- function(js) b$Runtime$evaluate(js, returnByValue = TRUE, awaitPromise = TRUE)$result$value
Sys.sleep(2); invisible(ev("document.fonts.ready.then(()=>1)")); Sys.sleep(2)
invisible(ev("Reveal.configure({transition:'none', backgroundTransition:'none', controls:false}); 1"))
n <- ev("Reveal.getTotalSlides()")
idx <- if (which == "all") seq_len(n) else as.integer(strsplit(which, ",")[[1]])

metric_js <- "
(() => {
  const s = Reveal.getCurrentSlide(), sc = Reveal.getScale(), R = s.getBoundingClientRect();
  let maxb = 0, maxr = 0, small = [], minf = 999, scroll = 0;
  s.querySelectorAll('*').forEach(e => {
    if (e.closest('aside.notes') || e.closest('.slide-background')) return;
    const r = e.getBoundingClientRect(); if (!r.width || !r.height) return;
    const cs = getComputedStyle(e); if (cs.visibility === 'hidden' || cs.display === 'none') return;
    maxb = Math.max(maxb, r.bottom); maxr = Math.max(maxr, r.right);
    if (['PRE','TABLE'].includes(e.tagName) || e.classList.contains('sourceCode'))
      if (e.scrollWidth > e.clientWidth + 1) scroll++;
    const own = [...e.childNodes].some(c => c.nodeType === 3 && c.textContent.trim().length);
    if (own && !e.closest('mjx-container')) {
      const f = parseFloat(cs.fontSize); if (f < minf) minf = f;
      if (f < 18) small.push(Math.round(f*10)/10 + 'px ' + e.tagName.toLowerCase() +
        (typeof e.className === 'string' && e.className ? '.' + e.className.split(' ')[0] : '') +
        ' \"' + e.textContent.trim().slice(0, 18) + '\"');
    }
  });
  const kind = s.id === 'title-slide' ? 'title' : s.classList.contains('section-title') ? 'section' : 'content';
  const title = (s.querySelector('h1,h2') || {}).textContent || '';
  return JSON.stringify({kind: kind, title: title.trim().slice(0, 26),
    bottom: Math.round((maxb - R.top) / sc), right: Math.round((maxr - R.left) / sc),
    scroll: scroll, minfont: Math.round(minf * 10) / 10, small: [...new Set(small)].slice(0, 4)});
})()"

rows <- list()
for (i in idx) {
  invisible(ev(sprintf("(()=>{const s=Reveal.getSlides()[%d]; const x=Reveal.getIndices(s); Reveal.slide(x.h, x.v); while (Reveal.nextFragment()) {}; return 1})()", i - 1)))
  Sys.sleep(0.7)
  writeBin(jsonlite::base64_dec(b$Page$captureScreenshot(format = "png")$data), file.path(out, sprintf("s%02d.png", i)))
  m <- jsonlite::fromJSON(ev(metric_js))
  rows[[length(rows) + 1]] <- data.frame(n = i, kind = m$kind, title = m$title, bottom = m$bottom,
    right = m$right, scroll = m$scroll, minfont = m$minfont, small = paste(m$small, collapse = " | "))
}
d <- do.call(rbind, rows)
write.table(d, file.path(out, "metrics.tsv"), sep = "\t", row.names = FALSE, quote = FALSE)
bad <- d[(d$kind == "content" & d$bottom > 680) | d$right > 1281 | d$scroll > 0, ]
cat(sprintf("슬라이드 %d장 점검 — 문제 %d장\n", nrow(d), nrow(bad)))
if (nrow(bad)) print(bad[, c("n", "title", "bottom", "right", "scroll")], row.names = FALSE)
b$close()
