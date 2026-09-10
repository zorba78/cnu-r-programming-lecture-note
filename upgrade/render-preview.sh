#!/usr/bin/env bash
# 개편 원고(.qmd) 한 장을 렌더해 docs/preview/ 에 올린다.
#
#   bash upgrade/render-preview.sh 08-algorithms.qmd
#
# Quarto 전환이 아직 책 전체로 가지 않았으므로, 장 하나만 단독 렌더해
# GitHub Pages 에서 확인할 수 있게 하는 임시 경로다.
# 살아 있는 bookdown 사이트(docs/ 루트)는 건드리지 않는다.
#
# 그림·동영상은 docs/figures, docs/video 에 이미 있으므로 자체 포함(--embed-resources)
# 대신 상대경로만 ../ 로 고쳐 재사용한다 (3.5MB -> 약 1.3MB).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
qmd="${1:?사용법: bash upgrade/render-preview.sh <장.qmd>}"
base="$(basename "$qmd" .qmd)"

cd "$root"
[ -f "$qmd" ] || { echo "파일이 없다: $qmd" >&2; exit 1; }

echo "== 렌더: $qmd"
quarto render "$qmd"

mkdir -p docs/preview
rm -rf "docs/preview/${base}.html" "docs/preview/${base}_files"
mv "${base}.html" "docs/preview/${base}.html"
[ -d "${base}_files" ] && mv "${base}_files" "docs/preview/${base}_files"

# docs/preview/ 에서 한 단계 올라가야 docs/figures, docs/video 를 만난다
python - "$root/docs/preview/${base}.html" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
before = s
for a in ('figures/', 'video/', 'images/'):
    s = s.replace(f'src="{a}', f'src="../{a}').replace(f"src='{a}", f"src='../{a}")
io.open(p, 'w', encoding='utf-8', newline='\n').write(s)
print(f"   상대경로 수정: {'변경 있음' if s != before else '변경 없음'}")
PY

echo "== 완료: docs/preview/${base}.html"
echo "   로컬 확인:  python -m http.server 8899 --directory docs  ->  http://127.0.0.1:8899/preview/${base}.html"
echo "   배포 주소:  https://zorba78.github.io/cnu-r-programming-lecture-note/preview/${base}.html"
