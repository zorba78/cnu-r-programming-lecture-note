# 8장 동기·용어 수정 (강사 지시 2026-11-19) 진행 상태

명세: `upgrade/plans/08-algorithms-motivation-rework-2026-11-19.md`. 워커는 동시에 2개까지.
강사 지시: 세션 한도에 걸리면 재개 가능 시간에 자동으로 이어가고, 끝나면 커밋과 푸시까지 한다.

재개할 때: `git status` 와 `git diff --stat` 으로 두 원고가 어디까지 고쳐졌는지 보고, 아래에서 체크되지 않은 첫 단계부터 이어간다. 워커가 중단됐으면 기록 파일(있다면)과 `grep` 결과로 남은 범위를 정해 같은 워커 종류로 다시 맡긴다.

- [x] 1. 슬라이드 `08-algorithms-slides.qmd` 수정 (워커 `lecture-slides-writer`). 완료 표시: 기록 `08-algorithms-slides-motivation-2026-11-19.md` 가 있고 렌더와 slides-check 문제 0.
- [x] 2. 노트 `08-algorithms.qmd` 수정 (워커 `lecture-note-writer`). 완료 표시: 기록 `08-algorithms-note-motivation-2026-11-19.md` 가 있고 렌더 오류 0.
- [x] 3. 오케스트레이터 대조: 두 파일의 낱말(손 추적, 바닥났, 무게, 걸음, 보폭 잔여 0), 공통 예 S(a, b) 의 수치, 5.6 W 행렬, 5.7 제목이 서로 같은지. 어긋나면 해당 워커에 수정 요청.
- [x] 4. 두 원고를 차례로 다시 렌더(`bash upgrade/render-preview.sh` 노트, 슬라이드 순), slides-check 재측정, 허브 주제 상세가 다시 만들어졌는지 확인, 루트의 렌더 부산물 삭제.
- [x] 5. CLAUDE.md 정정: 진행 상태 표 8장 행(장수, 이번 수정 요약), 174줄 "한 걸음 비교 그림", 264줄 "손 추적" → "손으로 풀어 보기", 277줄 "한 걸음" → "한 번의 반복", 279줄 "걸음 수 대 한 걸음의 비용" → "반복 횟수 대 반복 한 번의 비용". `upgrade/plans/08-algorithms-slides-rework-2026-10-22.md` 머리에 낱말이 바뀌었다는 한 줄.
- [x] 6. 커밋 두 개(본문·기록·CLAUDE.md / `docs/` 와 `hub/` 렌더본)와 `git push origin master`. 커밋 메시지는 한국어.
- [x] 7. 재개용 예약(CronCreate) 삭제, 강사에게 최종 보고.
