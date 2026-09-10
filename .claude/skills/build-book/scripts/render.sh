#!/usr/bin/env bash
# render.sh — bookdown 강의노트 렌더 (전체 또는 단일 장)
# 사용법: bash render.sh            # 전체 책 → docs/
#         bash render.sh 02-data-type.Rmd   # 해당 장만 미리보기 렌더
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT"
mkdir -p upgrade/logs
STAMP="$(date +%Y%m%d-%H%M%S)"

if [[ $# -ge 1 ]]; then
  CH="$1"
  [[ -f "$CH" ]] || { echo "파일 없음: $CH"; exit 2; }
  LOG="upgrade/logs/render-${STAMP}-${CH%.Rmd}.log"
  echo "단일 장 렌더: $CH  (로그: $LOG)"
  Rscript -e "bookdown::preview_chapter('$CH', output_format = 'bookdown::gitbook', quiet = FALSE)" > "$LOG" 2>&1
  STATUS=$?
else
  LOG="upgrade/logs/render-${STAMP}-full.log"
  echo "전체 책 렌더 → docs/  (로그: $LOG)"
  Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook', quiet = FALSE)" > "$LOG" 2>&1
  STATUS=$?
fi

echo "종료 코드: $STATUS"
echo "--- 오류/경고 추출 ---"
grep -nE "^Error|Quitting from lines|Execution halted|Warning in|is deprecated|was deprecated" "$LOG" | head -40 || true
echo "--- 로그 마지막 15줄 ---"
tail -n 15 "$LOG"
[[ -f Rplots.pdf ]] && rm -f Rplots.pdf
exit $STATUS
