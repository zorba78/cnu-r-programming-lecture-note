# 추상 표현 제거 (강사 지시 2026-10-19) 진행 상태

대상: 9·11·12·13·14장 노트와 슬라이드 (8장은 10-01~02 완료). 공통 지시: 8장 기록 두 개와 같은 방식, 건별 기록 `upgrade/plans/<파일>-wording-2026-10-19.md`.

- [x] 09-simulation.qmd (57건, 렌더 0)
- [ ] 09-simulation-slides.qmd: **중단**(2026-10-19, 세션 한도). 2절 편집 도중 멈춤. 노트의 "약속" → "명목 수준" 등 노트 기록과 맞춰야 함. 파일이 부분 수정 상태일 수 있으니 git diff 로 확인 후 재개.
- [x] 11-data-import-export.qmd (53건, 렌더 0)
- [ ] 11-data-import-export-slides.qmd: **중단**. 표지·2번 편집 시작 직후 멈춤. 노트의 identical() 사실 정정, AI 절 오류 유형, "채팅 창에서" 조건, 6.3 표 평가어와 맞출 것.
- [x] 12-data-handling.qmd (65건), 12-data-handling-slides.qmd (97건, 69장 문제 0)
- [x] 13-data-visualization.qmd (27건), 13-data-visualization-slides.qmd (52건, 68장 문제 0)
- [x] 14-basic-stat-analysis.qmd (32건)
- [~] 14-basic-stat-analysis-slides.qmd: 1차 41건 완료(69장 문제 0). 노트와 맞추는 2차(4.6 8장 X 사실 정정, 2.6 자유도 30 주장 삭제, 5.2 지수분포 약 9번, 5.5 Bonferroni 2.423 < Tukey 2.799)가 **중단**.
- [ ] 마무리: 오케스트레이터가 렌더·slides-check 재확인, 허브 주제 상세 재생성(`Rscript hub/topic-page.R <장>` ×5, `bash hub/sync.sh`), 저장소 루트의 렌더 부산물(`14-basic-stat-analysis.html`, `*_files/`, `*.rmarkdown`) 삭제.
- 재개 시 워커는 동시에 2개까지 (강사 지시 2026-10-19).
