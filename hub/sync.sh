#!/usr/bin/env bash
# 허브 페이지 소스를 배포 위치로 복사한다.
#
#   hub/*.html       원본 (손으로 편집하거나 hub/topic-page.R 이 생성하는 곳)
#   docs/hub/*.html  배포본 (GitHub Pages 가 서빙하는 곳)
#
#   index.html       주제 목록 (손으로 편집)
#   <장>.html        주제 상세 (Rscript hub/topic-page.R <장> 이 생성)
#
# docs/ 는 렌더 산출물 폴더라 Quarto 전환 시 비워질 수 있으므로 원본을 밖에 둔다.
# 같은 이유로 docs/legacy/ 도 렌더 후 다시 복사해 넣는다 (migrate-to-quarto 스킬 4단계).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$root/docs/hub"
for f in "$root"/hub/*.html; do
  cp "$f" "$root/docs/hub/"
  echo "hub/$(basename "$f") -> docs/hub/$(basename "$f")"
done
