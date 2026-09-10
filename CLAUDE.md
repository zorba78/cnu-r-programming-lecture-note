# CLAUDE.md — 충남대 정보통계학과 R 프로그래밍 강의노트

## 프로젝트 개요

- 충남대학교 정보통계학과 **"통계프로그래밍언어"** (Part 1) 및 **"통계패키지활용"** (Part 2) 강의노트. 2020년부터 매년 강의에 사용.
- 저자: 구본초 (한국한의학연구원, GitHub `zorba78`). 배포: https://zorba78.github.io/cnu-r-programming-lecture-note/
- **bookdown (gitbook)** 기반, 본문은 한국어. 렌더 결과는 `docs/`에 생성되어 GitHub Pages로 배포됨.
- **2026-09 현재 목표: 대규모 업그레이드.** agent AI / LLM 시대에 맞게 내용·교수법·평가를 전면 개편한다. 원칙은 아래 "업그레이드 프로젝트" 참고.

## 저장소 구조

| 파일 | 내용 | 줄 수 |
|---|---|---|
| `index.Rmd` | 책 메타데이터, 강의 소개(Part 1 overview) | 126 |
| `01-introduction.Rmd` | R/RStudio 설치, 패키지, 기초 문법, R Markdown 맛보기 | 1100 |
| `02-data-type.Rmd` | 스칼라·벡터·리스트·행렬·배열·요인·데이터프레임 | 4162 |
| `03-string-regexp.Rmd` | 문자열 함수, 정규표현식 | 1301 |
| `04-math-distribution-functions.Rmd` | 수학 함수, 분포 함수, formula | 607 |
| `05-control-flow.Rmd` | 조건문, 반복문, 함수 | 1232 |
| `06-algorithms.Rmd` | 재귀, 탐색, 정렬, Newton-Raphson | 1575 |
| `07-simulation.Rmd` | 몬테칼로, CLT, 검정 시뮬레이션 | 1934 |
| `08-introduction-2nd.Rmd` | Part 2 (통계패키지활용) overview | 64 |
| `09-file-import-export.Rmd` | 텍스트·바이너리·Excel 입출력 | 332 |
| `10-data-manupulation.Rmd` | readr, tibble, dplyr, tidyr | 2530 |
| `11-data-visualization.Rmd` | base graphics, ggplot2 | 3903 |
| `12-basic-stat-analysis.Rmd` | Q-Q plot, t-검정, ANOVA, tidymodels 정리 | 1586 |
| `13-rmarkdown-more.Rmd` | R Markdown 문법, 청크, YAML, 인용 | 957 |
| `15-references.Rmd` | 참고문헌 | 2 |

지원 폴더:

- `dataset/`, `data/` : 예제 데이터 (본문에서 `dataset/xxx` 상대경로로 참조). `dataset.zip`은 배포용 사본.
- `assignment/` : 과제 템플릿. `*solution.Rmd`, `assignment-solution/` 은 gitignore 대상 (정답 비공개).
- `figures/`, `images/`, `video/` : 정적 자원. `css/style.css` 에 콜아웃 스타일.
- `book.bib`, `packages.bib` : 인용 DB. `_bookdown.yml`, `_output.yml`, `_render.R` : 빌드 설정.
- `init-funs/`, `code/`, `demo/`, `examples/`, `test/`, `misc/` : 보조 스크립트·실험용. 책에 포함되지 않음.
- `2020/` : 초기 버전 아카이브 (gitignore). **수정 금지.**
- `docs/`, `_bookdown_files/` : **생성물. 직접 편집 금지.**
- `upgrade/` : 업그레이드 작업 산출물. **`upgrade/curriculum-plan.md` (교과 재구성안)**, 감사 보고서 `upgrade/audit/`, 렌더 로그 `upgrade/logs/`.

## 툴체인

- R 4.6.1, bookdown 0.47, rmarkdown 2.31, knitr 1.51, quarto CLI 1.9.38 (`/usr/lib/rstudio-server/bin/quarto/bin/quarto`)
- tidyverse 2.0.0, ggplot2(4.x), kableExtra 1.4.1, gt 1.3.0, DT, svglite, plotly, shiny, tidymodels 1.5.0
- LLM/AI: ellmer 0.4.2 (설치됨). 편집기는 Positron (`.vscode/settings.json`에 native pipe 설정).
- 검증 도구: styler, lintr, spelling, testthat 설치됨.

## 빌드 & 검증 명령

```bash
# 한 장의 코드 청크를 순차 실행해 오류·deprecation 경고 보고 (렌더보다 빠름)
Rscript .claude/skills/check-chapter/scripts/run_chunks.R 02-data-type.Rmd

# 한 장만 렌더 (docs/ 에 해당 장 HTML 갱신)
bash .claude/skills/build-book/scripts/render.sh 02-data-type.Rmd

# 전체 책 렌더 (수 분 소요, 로그는 upgrade/logs/)
bash .claude/skills/build-book/scripts/render.sh
```

- `_bookdown.yml` 의 `new_session: true` → 각 장은 **독립 R 세션**에서 렌더된다. 장마다 setup 청크에서 필요한 패키지를 직접 로드해야 한다.
- 코드 청크를 고쳤으면 **반드시 실행 검증** 후 보고한다. 렌더나 실행 없이 "수정 완료"라고 하지 않는다.

## 작업 규칙

1. **언어**: 본문은 한국어 평서체("~이다", 개조식은 "~임/~함"). 기술 용어는 첫 등장 시 영문 병기: 벡터(vector).
2. **코드 스타일**: 새로 쓰는 코드는 native pipe `|>`, tidyverse 현행 API (`across()`, `pivot_longer/wider()`, `slice_*()`, `linewidth`). **`%>%` 는 구식이 아니라 선택의 문제다** (강사 판단). 한 절 안에서 표기를 섞지 않는 선에서 기존 `%>%` 는 그대로 두어도 된다. 두 연산자의 차이(placeholder, 함수 호출이 아닌 우변)를 다루는 절은 오히려 교육적으로 유용하다.
3. **기존 장 수정 시**: 예제 데이터와 설명 흐름을 유지한다. 구식 API는 현행 API로 바꾸되 결과가 달라지면 본문 설명도 함께 고친다.
4. **헤딩 ID (`{#id}`) 는 공개 URL 앵커**다. 기존 ID를 바꾸지 않는다. 새 절에는 영문 kebab-case ID를 붙인다.
5. **콜아웃**: `block2` 청크의 `rmdnote / rmdtip / rmdimportant / rmdcaution / rmdwarning` 다섯 종류만 사용 (css/style.css 정의).
6. **외부 링크**를 새로 넣을 때는 접근 가능한지 확인한다. 죽은 링크는 교체하거나 삭제한다.
7. **AI 예시 출력을 지어내지 않는다.** 강의노트에 LLM 응답을 실을 때는 실제로 얻은 응답을 모델명·날짜와 함께 기록한다. 렌더 중 실시간 API 호출은 금지 (`eval=FALSE` 또는 저장된 결과 사용).
8. **커밋은 사용자가 요청할 때만.** `docs/` 재생성물은 본문 변경과 분리해 커밋한다. 정답 파일은 절대 커밋하지 않는다.
9. 큰 바이너리(mp4, zip, Rdata)를 새로 추가하지 않는다.
10. 스타일·문체 세부 규칙은 `lecture-style` 스킬을 따른다. `.Rmd`를 편집하기 전에 로드한다.

## 업그레이드 프로젝트 (2026-09 시작)

### 배경

6년간 누적된 노트는 R 4.0 / RStudio / `%>%` 시대 기준으로 작성됐다. LLM과 코딩 에이전트가 코드 작성을 대신하는 환경에서 학생에게 필요한 역량은 **문제를 명세하고, 생성된 코드를 읽고 검증하며, 통계적으로 해석하는 능력**이다.

### 원칙

1. **문법 사전은 줄이고 프로그래밍 개념은 늘린다.** 이 둘은 대립하지 않는다. 지금 "기초"로 분류된 분량의 대부분이 개념이 아니라 문법 레퍼런스이기 때문이다. 대상이 학부 2학년이고 대부분 이 강의로 프로그래밍에 입문한다는 점이 이 원칙의 근거다.
2. **PRIMM 을 각 절의 축으로 삼는다.** 예측 → 실행 → 조사 → 수정 → 제작. 입문자 교수법이면서 동시에 AI 코드 검증 동작과 같다. 기존의 "코드 → 출력 → 설명" 순서를 "질문 → 예측 → 코드 → 대조 → 설명"으로 바꾸는 것이 개정의 기본 동작이다.
3. **모든 장에 "AI와 함께" 절을 둔다.** 과제 명세 → 프롬프트 → 생성 코드 → 검증 → 흔한 오류 순서. 템플릿은 `ai-curriculum` 스킬.
4. **검증이 새 중심축이다.** 디버깅, 최소 재현 예제, 경계 사례, testthat, 시뮬레이션. 현재 노트에 거의 없는 영역이다.
5. **도구 현행화**: Positron/RStudio, Quarto, tidyverse 2.x, ggplot2 4.x, ellmer 기반 LLM 활용.
6. **평가 개편**: AI 사용을 허용한다는 전제에서 과정 기록, 검증 과제, 구두 설명, "AI 코드의 버그 찾기" 유형을 도입한다. 세부는 `assignment` 스킬.

전체 재구성안은 **`upgrade/curriculum-plan.md`** 에 있다. 장 구성을 건드리는 작업 전에 반드시 읽는다.

### 진행 상태

| 장 | 상태 | 비고 |
|---|---|---|
| 전체 | 감사 전 | `/audit-chapter` 로 장별 감사 보고서 생성 후 갱신 |

(장을 감사·개정할 때마다 이 표를 갱신한다: `감사 전 → 감사 완료 → 개정 중 → 개정 완료 → 검증 완료`)

### 결정된 사항 (2026-09-10, 강사)

- **Quarto book 으로 전환한다.** `migrate-to-quarto` 스킬 절차를 따른다. 전환이 실행되기 전까지는 bookdown 기준으로 작업한다.
- **Part 1 과 Part 2 는 한 책으로 유지한다.** 별도 분리하지 않는다.
- **`%>%` 는 구식이 아니다.** 일괄 치환 대상에서 제외.
- **Quarto·git·renv 워크플로 장은 만들지 않는다.** 강의 범위 밖. 단 Quarto 문서 작성 자체(현 13장)는 유지·전환한다.
- **신규 장**: 프로그래밍과 계산, 정확성·디버깅·검증, AI와 함께 프로그래밍하기. 세부는 `upgrade/curriculum-plan.md`.
- 발표 슬라이드 허브 페이지는 **A안(주제 목록형)** 으로 확정. 시안 https://claude.ai/code/artifact/3fadbdb9-8241-473c-8cad-13ca6285e9d8
- **구 강의노트(bookdown) 는 삭제하지 않고 `docs/legacy/` 에서 계속 서빙한다.** Quarto 전환 직전에 `bookdown-archive-2026-09-10` 태그에서 렌더된 `docs/`를 꺼내 보존하고, Quarto 렌더 후 `docs/legacy/`로 합쳐 넣는다. 절차는 `migrate-to-quarto` 스킬 0·4단계. 허브 페이지와 새 책 서문 모두에 "이전 버전 강의노트" 링크를 건다.
- **정확성·디버깅·검증을 독립 장(6장)으로 둔다.** 근거(강사, 2026-09-10): "LLM을 통해 디버깅 작업을 예전에 비해 매우 효율적으로 수행할 수 있으나 결국 중요한 부분은 인간이 다시 한 번 확인하는 절차가 중요해짐." 즉 이 장의 핵심은 디버깅 기법 자체가 아니라 **AI가 내놓은 결과를 사람이 재확인하는 절차**다. 함수 장(5장)에 부속시키면 이 비중이 죽는다. 장 설계는 `ai-curriculum` 스킬 4b, 대응표는 `upgrade/curriculum-plan.md` 5절.

### 백업

- **`bookdown-archive-2026-09-10`** 태그: 이번 업그레이드(오류 수정 4건 + CLAUDE.md·스킬 + 재구성안 커밋 직후, Quarto 전환·장 구성 변경 착수 직전)의 스냅샷. 로컬 전용, `origin` 에는 푸시하지 않음.
  - 파일 하나 복원: `git show bookdown-archive-2026-09-10:02-data-type.Rmd`
  - `docs/` 전체 복원(렌더된 옛 사이트): `git checkout bookdown-archive-2026-09-10 -- docs`
  - 저장소 전체를 그 시점으로 되돌리려면: `git checkout bookdown-archive-2026-09-10`

### 열린 결정 (아직 미정)

- 학기별 주차 배정과 장 개수 (제안: 1학기 9장 / 2학기 7장).
- 장 번호 변경에 따른 파일명 변경 여부. 공개 URL 이 바뀌므로 Quarto 전환과 함께 처리하는 편이 낫다.
- 강의 연도·학기 표기 갱신 (index.Rmd 의 subtitle/description 이 2022/2023 혼재).
- **Quarto 전환 착수 시점.** 절차·보존 방법은 확정됐으나 실행 여부는 아직 지시받지 않음.

## 알려진 문제 (감사 시 우선 확인)

- 모든 장에 동일한 knitr hook 보일러플레이트 약 30줄이 반복됨. 공통 파일(`_common.R`)로 추출 후보.
- `gather/spread` 15회, `mutate_at/_if/_all` 계열 29회, `qplot` 5회, `feather` 5회, `..density..` 3회 등 실제로 superseded 된 관용구. (`%>%` 는 여기 해당하지 않음)
- `stringsAsFactors` 34회. R 4.0.0 이후 기본값이 바뀌었으므로 설명이 뒤집혀 있는 곳이 있는지 확인.
- `01-introduction.Rmd` 의 설치·IDE 안내가 구 버전 RStudio/R 기준. Positron 언급 없음.
- 외부 링크 다수 (statkclee, blog.penjee, 10bun.tv, lib.stat.cmu.edu 등) 소실 가능성.
- `README.md` 가 2020년 1학기 기준으로 오래됨.
- 디버깅·검증 내용이 사실상 없음. 노트 전체에서 디버깅 2회, `traceback`/`tryCatch`/`testthat` 0회.

### 수정 완료 (2026-09-10)

- `index.Rmd` 의 `citr` 설치 시도 제거 (CRAN 에서 삭제된 패키지).
- `06-algorithms.Rmd` 뉴튼-랩슨 → 뉴턴-랩슨, Newton-Rhapson → Newton-Raphson.
- `03-string-regexp.Rmd` 정규 표현식/정규표현식 혼용을 붙여쓰기로 통일, `regular rexpression` 오타 수정.
- `09-file-import-export.Rmd` R 4.0.0 이후 `stringsAsFactors` 기본값 변경을 반영하고 무의미해진 `error=TRUE` 제거.

## 스킬 목록 (`.claude/skills/`)

| 스킬 | 용도 |
|---|---|
| `lecture-style` | 장 작성·수정 시 문체, 구조, 청크 옵션, 콜아웃 규칙 (Rmd 편집 전 로드) |
| `audit-chapter` | 한 장을 감사해 구식 코드·죽은 링크·교수법 개선점을 보고서로 작성 |
| `check-chapter` | 장의 코드 청크를 실행해 오류·deprecation 경고 확인 |
| `build-book` | 단일 장 또는 전체 책 렌더 및 로그 확인 |
| `ai-curriculum` | AI 시대 교과 설계: "AI와 함께" 절 템플릿, 신규 장 설계, LLM 예시 기록 규칙 |
| `assignment` | 과제·퀴즈·시험 문항과 정답 파일 작성 (AI 허용 전제 평가 유형 포함) |
| `migrate-to-quarto` | bookdown → Quarto book 전환 절차. **전환 결정됨 (2026-09-10)** |
