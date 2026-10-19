# 새 13장 데이터 시각화 설계서 (data-visualization)

- 작성 2026-10-16 · 설계 워커(lecture-planner) · 파이프라인 2단계
- 출처: 현행 `11-data-visualization.Rmd` (3,903줄, 공개 사이트 10장). 감사 `upgrade/audit/11-data-visualization.md` (치명 3 · 중요 20 · 경미 41)
- 산출물(다음 단계): 노트 `13-data-visualization.qmd`, 슬라이드 `13-data-visualization-slides.qmd`, AI 기록 `ai-transcripts/13-data-visualization/gapminder-bubble-2015.md`
- 따른 문서: `upgrade/curriculum-plan.md` 5절 13장 행("현행화·압축. ggplot2 4.x. `par()` 전수는 부록"), 6절 공통 구조, 7절 분량(3,903 → 2,400줄), `upgrade/plans/data-visualization-decisions.md` 의 가정 9건, 감사 G 절, 앞 장 `12-data-handling.qmd`(3,071줄, 절 8개 + 연습문제)
- 분량 목표: 노트 약 2,430줄(절 10개 + 연습문제, 소절 37개), 슬라이드 60장(표지 1, 절 표지 10, 본문 49)
- 이 설계서의 수치는 2026-10-16 R 4.6.1, ggplot2 4.0.3, dplyr 1.2.1 에서 실행해 확인한 값이다. 집필 워커는 렌더한 출력으로 다시 확인하고, 다르면 출력을 따른다.

---

## 0. 집필 전제

### 0.1 문서 설정

- YAML 은 12장(`12-data-handling.qmd` 1~31줄)을 따른다. 제목 `title: "데이터 시각화"`, 부제 `"통계 패키지 활용: 개편 13장 초안"`. 본문은 `##` 부터.
- **경고와 메시지를 숨기지 않는다.** 12장은 `execute: warning: false, message: false` 였으나 이 장은 `warning: true`, `message: true` 로 둔다. `Removed 37 rows ...`, `geom_smooth() using method = 'gam'`, `stat_bin() using bins = 30` 은 본문이 읽고 설명하는 교재다. 감사 E 절: 현 장의 `warning=FALSE` 청크 14개가 결함을 가렸다. 소음만 되는 메시지(패키지 적재)는 해당 청크에 `#| message: false` 를 준다. readr 열 유형 메시지는 `options(readr.show_col_types = FALSE)` 로 끈다.
- `error: true` 를 문서 수준에 둔다(3.2 의 `plot region too large` 재현).
- 그림 기본 크기는 집필 워커가 정한다(권장 `fig-width: 7`, `fig-height: 4.5`). 두 그림을 나란히 둘 때는 patchwork 로 한 그림을 만들거나 `#| layout-ncol: 2` 를 쓴다.
- jitter 를 쓰는 청크는 모두 `position_jitter(seed = <정수>)` 로 시드를 고정한다(감사 C-23).
- 그림 파일을 저장하는 코드는 `tempfile(fileext = ".png")` 에만 쓴다. 저장소의 추적 파일(`figures/save-example.png`)을 쓰지 않는다(감사 B-15).
- `Sys.setlocale()`, `rm(list = ls())` 를 쓰지 않는다(감사 B-15).

### 0.2 패키지와 버전

| 패키지 | 설치 버전 | 학생 최소 버전 | 쓰는 곳 |
|---|---|---|---|
| ggplot2 | 4.0.3 | **4.0.0** | 전체. `theme_grey(ink =, paper =)`, `get_labs()`, 경고 문구 `values outside the scale range` 가 이 버전 기준 |
| dplyr | 1.2.1 | 1.2.0 | 자료 준비의 `replace_values()`, `unmatched` (12장과 같음) |
| tidyr | 1.3.2 | 1.3.0 | 4.1 `pivot_wider()` |
| readr | 2.2.0 | 2.1.0 | Gapminder 파일 읽기 |
| patchwork | 1.3.2 | 1.1.0 | 8.2, 여러 그림 배치 (감사 B-4, 결정 5: `ggarrange()` 대체) |
| scales | 1.4.0 | 1.2.0 | 7.2·7.3 축 눈금 표기 `label_comma()`, `label_number(scale_cut = cut_short_scale())` |
| png | 0.1.9 | 0.1-7 | 8.4 저장한 그림의 픽셀 크기 확인 하나뿐. 없으면 그 줄만 `eval: false` 로 |

- 쓰지 않는 패키지: `car`, `vioplot`, `ggpubr`, `gridExtra`, `extrafont`, `kableExtra`, `RColorBrewer`, `showtext`, `ragg`, `palmerpenguins`(결정 9), `countrycode`(미설치).
- 본문 앞에 12장 것과 같은 형식의 버전 콜아웃을 둔다: "ggplot2 4.0.0 이상이 필요하다. `packageVersion("ggplot2")` 로 확인한다. 이 강의노트는 ggplot2 4.0.3 으로 실행했다."

### 0.3 상호참조

- `@sec-` 참조는 **이 파일 안의 소절에만** 쓴다. 장마다 단독 렌더하므로 다른 장의 ID 는 풀리지 않는다.
- 다른 장은 글로 가리킨다: "12장 '변환 절차 검증하기' 절", "9장 '신뢰구간의 의미' 소절". 확인한 앵커는 12장 `#sec-verify-transform`, `#sec-invariants`, `#sec-transform-assert`, `#sec-gapminder-case`, `#sec-na-summary`, `#sec-pivot-wider`, 9장 `#sec-ci-meaning` (모두 존재).
- 아래 소절 ID 37개는 08, 09, 11, 12장 `.qmd` 의 `{#sec-...}` 142개와 겹치지 않음을 확인했다.

### 0.4 코드와 문체

- 새 코드는 `|>`, `linewidth`, `after_stat()`, `guides(x = "none")`, `geom_col()`, 가로 막대는 `aes(y = 범주)` (`coord_flip()` 쓰지 않음), `.by =`, `library()`.
- **이전 판 노트의 코드**를 실을 때: 버그 찾기나 경고 읽기의 대상인 부분은 원문 그대로 두고, 나머지는 현행 표기로 옮긴 뒤 "현행 문법으로 옮기면 다음과 같다"고 밝힌다(12장 연습문제 8 방식).
- 그림 속 글자는 한국어로 쓴다. 이 렌더 환경(리눅스, `png` 장치, `bitmapType = "cairo"`)에서 ggplot2 와 기본 그래픽 모두 한글이 글꼴 패키지 없이 나오는 것을 확인했다(시험 그림 `/tmp/plan13/ko-gg.png`, `ko-base.png`). 기본 그래픽에 `par(family = ...)` 를 쓰지 않는다(감사 B-18).
- 단위를 축 제목에 적는다: `airquality$Temp` 는 화씨(감사 C-9), Gapminder 1인당 GDP 는 "1인당 GDP(PPP, 2011년 불변 국제달러)"(감사 B-14, 12장과 같은 이름). "1인당 국민소득"이라 부르지 않는다.
- **감사 G-9 의 문장은 옮기지 않는다.** 현 장 50–52줄의 Tukey 인용구도 옮기지 않는다. 1.1 의 Anscombe 자료가 같은 사실을 수치로 보인다.

---

## 1. 학습 목표

허브의 장 소개 문단도 이 목록에서 뽑는다.

- 그림을 그리기 전에 자료의 어느 열을 그림의 어느 속성(가로 위치, 세로 위치, 색, 크기, 모양)에 대응시킬지 표로 **명세**하고, 그 명세를 `ggplot()` 코드로 옮길 수 있다.
- 그림이 자료의 값을 그대로 그렸는지, 개수·밀도·사분위수·평활선 같은 값을 **계산해** 그렸는지 구분하고, `layer_data()` 로 그 값을 꺼내 직접 계산한 값과 대조할 수 있다.
- 막대를 쌓을지 나란히 둘지 겹칠지, 축 범위를 척도 한계(`ylim()`)로 정할지 좌표 확대(`coord_cartesian()`)로 정할지에 따라 그림과 통계량이 어떻게 달라지는지 실행하기 전에 **예측**할 수 있다.
- 그림에 들어간 행 수, 빠진 행의 경고, 크기와 색이 나타내는 값, 제목·축 이름·범례의 글자와 단위를 코드와 대조하는 **확인 절차**를 적용할 수 있다.
- 기본 그래픽에서 `par()` 로 바꾼 설정이 다음 그림에 남는 이유를 설명하고, 설정을 되돌리는 코드를 쓸 수 있다.
- AI 가 생성한 시각화 코드를 그려진 점의 수, 대응표, 크기 비례, 축 표기로 **검증**하고, 같은 자료로 단순 평균과 인구 가중 평균이 다른 선을 그린다는 점을 그림에서 **해석**할 수 있다.

---

## 2. 도입 예: 일상의 예를 먼저 두고 정의는 뒤에

강사 결정(2026-09-11)과 감사 G-7. 각 예는 해당 소절의 **첫 문단**에 두고, 용어 정의와 코드는 그 뒤에 둔다. 슬라이드에서도 같은 순서다.

| 핵심 용어 | 일상의 예 | 둘 곳 | 예 다음에 정의할 것 |
|---|---|---|---|
| 매핑(aesthetic mapping) | 성적표의 열(키, 체질량지수, 성별)을 종이 위 가로 위치, 세로 위치, 점 색에 하나씩 대응시켜 점을 찍는 일. 학생 한 명이 점 하나다 | 4.2 `#sec-aes-mapping` | `aes()`, 이어서 `grammar-graphics-intro.png` (그림의 표가 같은 구조: id, ht, sex, bmi → x = ht, y = bmi, color = sex) |
| stat (계산하는 단계) | 출석부 한 줄이 학생 한 명일 때 반별 인원 막대를 그리려면 먼저 반마다 세어야 한다. 막대 높이는 출석부에 적힌 값이 아니라 센 값이다 | 5.1 `#sec-bar-count` | `geom_bar()` 의 `stat_count()`, `geom_col()` 의 `stat_identity()` |
| 위치 조정(쌓기·나란히·겹치기) | 반별 출석 인원을 남녀로 나눠 한 막대에 쌓으면 꼭대기는 반 전체 인원이다. 남녀 막대를 같은 자리에 반투명하게 겹치면 꼭대기는 둘 중 큰 쪽이다 | 6.1 `#sec-stack-dodge` | `position_stack()`, `position_dodge()`, `position_identity()` |
| 척도 한계 대 좌표 확대 | 단체 사진에서 가운데를 확대해 보는 것과, 사진 가장자리를 잘라 낸 뒤 남은 사람만으로 평균 키를 다시 내는 것 | 7.1 `#sec-limits-zoom` | `ylim()`·`scale_y_continuous(limits =)` 와 `coord_cartesian(ylim =)` |
| 그래픽 상태 | 화이트보드를 4칸으로 나눠 쓰고 선을 지우지 않으면 다음 사람도 4칸에 쓴다 | 3.2 `#sec-graphics-state` | `par()` 가 장치의 전역 설정이라는 것, `op <- par(...)`, `par(op)` |
| 상자그림의 수염 | 반 학생들의 키 분포에서 유난히 큰 한 명은 수염 끝에 붙지 않고 점으로 따로 찍힌다 | 2.3 `#sec-boxplot-whisker` | 힌지, IQR, 1.5 IQR 규칙, 이상점 |

---

## 3. 절과 소절

표기: 각 소절에 ID, **PRIMM** (학생에게 실행 전에 예측하게 할 질문), 자료, 예상 줄 수, 내용 순서, 확인한 값. "이전 판 노트의 코드"는 현 장의 줄 번호다.

### 머리 (약 110줄)

YAML, setup, 학습 목표 콜아웃, 도입 두 문단, 예제 자료 표, 버전 콜아웃, `library()` 청크.

- 도입 문단 내용(사실만): 12장에서 만든 요약표를 그림으로 옮긴다. 그림 코드는 AI 가 바로 써 준다. 그러나 막대가 쌓였는지 겹쳤는지, 경고와 함께 빠진 행이 있는지, 점 크기가 무엇에 비례하는지, 제목의 숫자가 코드와 맞는지는 그림을 보는 사람이 확인해야 한다. 이 장은 함수를 나열하지 않고 그림이 **무엇을 계산해 그렸는지** 확인하는 데 집중한다. 인수 전체는 ggplot2 함수 목록(https://ggplot2.tidyverse.org/reference/index.html, 접근 확인 감사 D)과 부록 B(예정)에서 찾는다.
- 예제 자료 표:

| 자료 | 내용 | 쓰는 절 |
|---|---|---|
| `anscombe`, `mtcars`, `cars`, `BOD`, `airquality`, `warpbreaks`, `iris`, `ToothGrowth` | R 에 들어 있는 자료 | 1~9 |
| `Titanic`, `UCBAdmissions` | R 에 들어 있는 교차표 | 2 |
| `mpg`, `diamonds`, `economics_long` | ggplot2 에 들어 있는 자료 | 4~8 |
| `dataset/ch12/gapminder-*.csv` 네 파일 | 12장의 Gapminder 추출 자료(2000~2020년). 같은 정의, 같은 파일 | 4.4, 5.1, 7, 9.4, 10 |

### 1절. 그림으로 자료 보기 `{#sec-why-plot}` (약 110줄)

**1.1 요약 통계량이 같은 네 자료 `{#sec-anscombe}`** (약 70줄)
- PRIMM: 평균, 표준편차, 상관계수가 소수 둘째 자리까지 같은 네 자료의 산점도는 서로 비슷할까?
- 자료: `anscombe`
- 순서: 네 쌍의 평균·표준편차·상관계수를 먼저 표로 보인다(x 평균 9.0, y 평균 7.50, x 표준편차 3.32, y 표준편차 2.03, 상관 0.816, 넷째만 0.817) → 예측 콜아웃 → 그림 2×2 → 해석(직선, 곡선, 이상점 하나가 기울기를 정함, x 가 한 값에 몰림).
- 이전 판 노트의 코드 58–83줄을 고쳐 쓴다: y축 이름 `ylab = yl` 을 `ylab = eval(yl)` 로(감사 B-7(6)). 원래 버그는 연습문제 읽기 문항 R4 로 쓴다. `par(mfrow)` 는 `op <- par(...)` / `par(op)` 형식 유지(3.2 의 예고).
- 그림 캡션의 출처는 `https://en.wikipedia.org/wiki/Anscombe%27s_quartet` (200 확인, 감사 D). `goo.gl` 단축 주소를 쓰지 않는다.

**1.2 그림을 그리는 두 체계와 그래픽 장치 `{#sec-two-systems}`** (약 40줄)
- PRIMM: `p <- plot(cars)` 를 실행하면 `p` 에는 무엇이 담길까? (답: `NULL`. 기본 그래픽은 장치에 그리고 끝나며 그림을 객체로 남기지 않는다. ggplot2 는 그림을 객체로 남긴다.)
- 자료: `cars`
- 내용: 화면 장치(Positron·RStudio 의 그림 창)와 파일 장치(`png()`, `pdf()`, `ggsave()`) 두 가지로 압축한다(감사 B-19). `windows()`, `win.graph()` 는 쓰지 않는다. 두 체계 대조 표 하나: 그리는 방식(순서대로 덧그림 / 레이어를 더한 객체), 결과(장치에 남음 / 객체로 남음, 출력할 때 그림), 설정(`par()` 전역 상태 / 객체 안의 테마), 계산 값 확인(`hist(..., plot = FALSE)` 같은 반환값 / `layer_data()`).

### 2절. 기본 그래픽: 고수준 함수 `{#sec-base-graphics}` (약 280줄)

절 도입 두 줄: 고수준 함수는 호출할 때마다 새 그림을 시작한다. 저수준 함수는 3절.

**2.1 plot() 은 받은 객체에 따라 다르게 그린다 `{#sec-plot-generic}`** (약 70줄)
- PRIMM: `class()` 가 각각 `"data.frame"`, `"lm"`, `"table"` 인 세 객체를 `plot()` 에 넣으면 어떤 그림이 나올까?
- 자료: `mtcars`, `lm(mpg ~ disp, mtcars)`, `Titanic`, `BOD`
- 순서: 예측 → `plot(mtcars[, 1:4])`(산점도 행렬), `plot(mod)` 진단 그림 4장(`op <- par(mfrow = c(2, 2))` … `par(op)`), `plot(Titanic)`(모자이크) → `methods(plot)` 으로 클래스별 방법이 있음을 보인다(개수는 적재한 패키지에 따라 다르므로 숫자를 본문에 적지 않는다) → `type` 8종 그림(BOD, 이전 판 251–276줄) → `pch` 기호 표(355–369줄)와 `lty` 표(329–350줄)를 한 그림으로(4.3 의 `shape`, `linetype` 이 같은 번호를 쓴다) → `palette()` 의 실행 결과(R 4.0 이후 8색 `"black" "#DF536B" ...`). `col = 2` 의 색은 팔레트 순서로 정해진다는 한 문장.
- `plot(x)` 한 인수와 `plot(x, y)` 두 인수의 차이(213–228줄)는 한 문단으로.

**2.2 히스토그램과 막대그림 `{#sec-hist-barplot}`** (약 80줄)
- PRIMM 1: `x <- c(1, 2, 2, 1, 3, 3, 1, 5)` 일 때 `hist(x)` 와 `barplot(x)` 는 막대가 각각 몇 개이고 높이는 얼마일까? (답: `hist` 는 구간 [1,2], (2,3], (3,4], (4,5] 의 4개, 높이 5, 2, 0, 1. 1 과 2 가 첫 구간에 함께 들어간다. `barplot` 은 값 8개를 그대로 높이로 그린 8개.)
- PRIMM 2: `hist(airquality$Temp, breaks = 4)` 의 막대는 몇 개일까? (답: 5개. 구간 경계 50, 60, …, 100. `breaks` 에 준 수는 제안이고 R 이 보기 좋은 경계를 고른다. `breaks = 15` 는 21개.)
- 자료: `airquality$Temp`(화씨 56–97), 직접 만든 `x`, `warpbreaks`
- 순서: `hist(temp)` 와 반환값 `h <- hist(temp, plot = FALSE)` 의 `breaks`, `counts`(기본 구간 55–100, 5도 간격, 빈도 8 10 15 19 33 34 20 12 2) → "그림이 계산한 값을 꺼낼 수 있다"는 이 장의 첫 예 → PRIMM 2 → PRIMM 1(이전 판 628–634줄) → `warpbreaks` 에서 양모·장력별 파손 횟수 합의 쌓은 막대와 나란한 막대(이전 판 641–663줄, `beside = TRUE`). 쌓은 막대의 꼭대기 = 두 양모의 합(6.1 의 예고).
- 축 이름에 단위: "일 최고 기온(화씨)".

**2.3 상자그림의 수염 `{#sec-boxplot-whisker}`** (약 75줄)
- 일상 예(표 2) → 정의: 상자는 아래 힌지·중앙값·위 힌지, 수염은 상자에서 1.5 IQR 안에 있는 **가장 먼 관측값**까지, 그 밖은 점(이상점). 이전 판의 "최솟값 … 최댓값 다섯 통계량" 정의(691줄)와 `min(x)`, `max(x)` 라벨(696–697줄)을 고친다(감사 B-8). 상자 경계는 `quantile()` 기본값이 아니라 `fivenum()` 의 힌지다.
- PRIMM: 오른쪽 수염 끝은 항상 `max(x)` 일까? `x` 에 값 5 하나를 더하면?
- 자료: `set.seed(20200522); x <- rnorm(100)` (이전 판 694–695줄). 이상점 0개, 수염 끝 = 최댓값 2.206. `x2 <- c(x, 5)`: 위 수염 끝 2.206 그대로, 5 는 점. `boxplot.stats(x2)$stats`, `$out` 로 대조.
- 해부 그림은 이전 판 693–724줄을 라벨만 고쳐 살린다(`min(x)` → "아래 수염 끝", `quantile(x, 0.25)` → "아래 힌지" 등).
- 수식 인터페이스 한 예: `boxplot(breaks ~ wool + tension, data = warpbreaks)` (767–770줄). 설명의 `y ~ x + y` 오기(749줄)를 `y ~ x1 + x2` 로(감사 B-20(1)).
- 5.3 에서 ggplot2 의 상자그림이 같은 자료에서 다르게 그려지는 경우를 다룬다고 예고 한 줄.

**2.4 범주형 자료의 모자이크 그림 `{#sec-mosaic}`** (약 55줄)
- PRIMM: UC Berkeley 대학원 지원자 전체로 보면 남자 합격률이 높다. 학과별로 나누어 보아도 남자 합격률이 높을까?
- 자료: `Titanic`(이전 판 838–849줄, 성별 × 생존: 남 1,364/367, 여 126/344), `UCBAdmissions`(877–911줄)
- 확인 값: 전체 합격률 남 44.5%, 여 30.4%. 학과별로는 6개 중 4개(A, B, D, F)에서 여자가 높다. A 학과 여 82.4%, 남 62.1%. 심슨의 역설(Simpson's paradox)이라는 이름은 결과를 본 뒤에 붙인다.
- 학과별 그림은 `par(mfrow = c(2, 3), oma = ...)` 를 쓰므로 `op <- par(...)` … `par(op)` 로 감싼다. 이 청크가 이전 판에서 다음 청크의 오류를 일으킨 상태(감사 B-5)라는 사실을 3.2 에서 다시 쓴다.
- "버클리 주립대"(874줄)는 "캘리포니아대학교 버클리(UC Berkeley)"로(감사 C-39). 로그선형모형 콜아웃(833–835줄)은 옮기지 않는다.

### 3절. 덧그리기와 그래픽 상태 `{#sec-base-state}` (약 170줄)

**3.1 그림 위에 덧그리기 `{#sec-add-layers}`** (약 90줄)
- PRIMM: `mtcars` 의 마력(`hp`)과 연비(`mpg`) 산점도에 회귀직선과 두 변수의 평균선(가로, 세로)을 그린다. 세 직선은 한 점에서 만날까? (답: 만난다. 최소제곱 회귀직선은 (x̄, ȳ) = (146.7, 20.09) 를 지난다. `predict(m, data.frame(hp = mean(mtcars$hp)))` = 20.09 = `mean(mtcars$mpg)`.)
- 자료: `mtcars`, `iris`, 표준정규분포
- 순서: `abline-example`(이전 판 1512–1558줄) 으로 `plot(type = "n")`, `lines()` 잔차선, `points()`, `abline()` 세 개, `text()` 를 한 번에 보인다. 평균 라벨의 `bar(x)` 를 mpg 쪽은 `bar(y)` 로 고친다(감사 B-7(4)). "일변량 회귀모형" 주석은 "단순 선형회귀"로(C-14) → `legend()`(1840–1859줄, iris 세 종의 점 모양과 색). 제목 "points() function example 2"는 내용에 맞게(C-18) → `polygon()` 으로 곡선 아래 넓이(`polygon-example`, 1704–1726줄): P(−1.5 < Z < 0.7) = 0.691. 수식 `$Z ~ \stackrel{i.i.d}{\sim}$` 는 `$Z \sim N(0, 1)$` 로(C-16).
- 저수준 함수의 인수 해부(`arrows`, `rect`, `mtext`, `text` 의 `adj`·`pos`·`srt`)는 부록 B 로 보낸다는 한 문장.

**3.2 그림 영역과 그래픽 상태 `{#sec-graphics-state}`** (약 80줄)
- 일상 예(화이트보드 4칸) → 정의: `par()` 는 열린 장치 하나에 걸린 설정이고, 바꾸면 그 장치에서 그리는 다음 그림에 남는다.
- 그림: R 청크 `r-graphic-layout`(이전 판 111–142줄, 장치·figure·plot 영역과 여백 이름) 과 정적 그림 `figures/graphics-figureAnatomy1.png`(983줄, 출처 "AIMS-R-users(Murray Logan), 현재 접속 불가" 로 표기, 감사 B-17). 영역 이름(plot region, figure margin, outer margin)과 여백 인수 `mar`, `oma` 의 순서 `c(아래, 왼쪽, 위, 오른쪽)` 만 설명(이전 판 1138줄의 `left` 중복 오기를 옮기지 않음, B-20(2)).
- PRIMM 1(그림 글자와 코드 대조): 이전 판 노트의 코드 1227–1239줄을 그대로 싣고 그린다. 제목에는 "mfrow = c(2, 3)" 이라 적혀 있다. 그림은 몇 행 몇 열인가? (답: 코드는 `mfrow = c(3, 2)`, 그림은 3행 2열. 제목이 틀렸다. 감사 B-7(1).) `mfrow` 는 행 순서, `mfcol` 은 열 순서로 채운다는 대조는 이 그림 한 장과 `mfcol` 판 한 장으로.
- PRIMM 2(상태): 앞에서 `par(mfrow = c(2, 3))` 을 실행한 장치에 이어서 `par(pin = c(5, 2)); plot(1:10)` 을 실행하면? (답: `plot region too large` 오류. 6칸으로 나뉜 한 칸에 폭 5인치 그림 영역이 들어가지 않는다. 새 장치에서는 실행된다.) 렌더에서는 knitr 가 청크마다 장치를 새로 열어 상태가 넘어가지 않으므로, **한 청크 안에서** 재현한다(`tryCatch()` 로 메시지 출력, 감사 I-4). 이전 판 노트의 999–1026줄과 894줄 청크가 콘솔에서 이 오류를 냈다는 사실을 함께 적는다.
- 고치는 법: `op <- par(mfrow = c(1, 2)); ...; par(op)`. 함수 안에서는 `on.exit(par(op))`. 5장(함수)의 부수효과 개념과 같다는 한 문장.
- `pin`, `fin`, `fig`, `mfg`, `layout()`, `split.screen()`, `new`, `oma` 해부는 부록 B.

### 4절. ggplot2 의 문법 `{#sec-ggplot-grammar}` (약 290줄)

**4.1 같은 그림을 두 체계로 `{#sec-base-vs-ggplot}`** (약 70줄)
- PRIMM: `plot(tg_mat[, "OJ"], type = "l")` 다음에 `lines(tg_mat[, "VC"])` 를 실행하면 VC 선은 다 보일까? (답: 아니다. 첫 `plot()` 이 y축 범위를 OJ 값 13.23–26.06 으로 정한다. VC 0.5 mg 평균 7.98 은 범위 아래, VC 2 mg 평균 26.14 는 범위 위라 선이 잘린다. x축은 용량이 아니라 1, 2, 3 번호다.)
- 자료: `ToothGrowth` (이전 판 2101–2172줄). 평균표는 `summarise(mean = mean(len), .by = c(supp, dose))` (OJ 13.23, 22.70, 26.06 / VC 7.98, 16.77, 26.14). 행렬은 `pivot_wider()` 로(감사 B-4, 12장 '긴 표를 넓은 표로' 소절 참조). `spread()`, `column_to_rownames()` + 괄호 없는 `%>% as.matrix` 를 옮기지 않는다.
- 순서: 기본 그래픽 `barplot(tg_mat, beside = TRUE)` 과 전치 `barplot(t(tg_mat), ...)` → 예측 → 선 그림 → ggplot2 는 같은 긴 표에서 `x` 와 `fill` 의 매핑만 바꾸면 된다(`geom_col(position = "dodge")` 두 장, `geom_line(aes(group = supp, colour = supp), linewidth = 1)`). 이전 판의 `geom_bar(stat = "identity")` 와 `size = 1` 은 쓰지 않는다.

**4.2 매핑: 열을 그림의 속성에 대응시키기 `{#sec-aes-mapping}`** (약 70줄)
- 일상 예(성적표 → 점) → 그림 `figures/grammar-graphics-intro.png` (2094줄, 1942×598. `Read` 로 열어 표의 7행과 점의 위치·색이 맞음을 확인함) → 용어 표: 자료(data), 매핑(`aes()`), geom, stat, 위치 조정(position), 척도(scale), 좌표계(coord), 패널 나누기(facet), 테마(theme). 각 한 줄, 이 장의 어느 절에서 다루는지 열 하나.
- PRIMM: `p <- ggplot(cars, aes(speed, dist))` 만 실행하고 `p` 를 출력하면 무엇이 그려질까? (답: 축과 눈금만 있는 빈 판. geom 이 없으면 점을 그리지 않는다.)
- 순서: 예측 → 빈 판 → `p + geom_point()` → `class(p)` 와 1.2 의 `plot()` 반환값 대조 → `aes()` 를 `ggplot()` 에 둘 때와 geom 안에 둘 때(이전 판 2249–2277줄의 `eval=FALSE` 청크를 실행해 결과를 보인다. 감사 E: 기본 문법 첫 예제인데 그림이 없었음).
- 슬라이드에서는 이 소절에서 레이어를 하나씩 더하는 4장면(자료+매핑 → +geom → +척도 → +labs)을 보인다(7절 참조).

**4.3 매핑과 설정: aes() 안과 밖 `{#sec-aes-setting}`** (약 65줄)
- PRIMM: `ggplot(mtcars, aes(wt, mpg)) + geom_point(aes(colour = "blue"))` 의 점은 무슨 색이고 범례에는 무엇이 적힐까? (답: 점은 `#F8766D`(붉은색), 범례 제목 `colour`, 항목 `blue`. `aes()` 안의 `"blue"` 는 색이 아니라 "blue" 라는 값 하나뿐인 변수로 다뤄진다.)
- 자료: `mpg`(이전 판 2295–2329줄), `mtcars`(2392–2420줄)
- 순서: `geom_bar(fill = "navy")`(설정) 대 `geom_bar(aes(fill = fl))`(매핑) → 예측 → 고친 코드 `geom_point(colour = "blue")` → 크기와 모양: `aes(size = hp)`, `aes(shape = factor(cyl))` 한 그림씩 → **`size` 와 `linewidth`**: 점과 글자는 `size`, 선 굵기는 `linewidth`(ggplot2 3.4.0 부터). 이전 판 노트의 코드 한 줄(`geom_line(size = 1)`)을 실행해 deprecation 경고를 **출력 그대로** 보이고 읽는다(감사 B-1, 이전 판 2286줄 설명 교체). 경고는 세션에서 한 번만 나온다는 사실(감사 E)도 한 줄.
- 2.1 의 `pch`·`lty` 표를 `shape`·`linetype` 에 그대로 쓴다고 참조.

**4.4 선으로 잇기: group 과 순서 `{#sec-group-order}`** (약 85줄, 자료 준비 청크 포함)
- **자료 준비 청크 `gm-prepare`** (이 장의 Gapminder 기준표, 이후 5.1, 7.2, 7.3, 9.4, 10 이 씀): `dataset/ch12/` 의 인구·GDP·기대수명·지역 네 파일을 12장 '통합 사례'와 같은 방법으로 합친다. 인구 표 기준 `left_join()` 두 번(`by = c("geo", "year")`, `relationship = "one-to-one"`), `iso = replace_values(toupper(geo), "HOS" ~ "VAT")`, 지역 결합 `inner_join(..., relationship = "many-to-one", unmatched = c("error", "drop"))`, `region` 오타 `"Northen America" ~ "Northern America"`, `gdp_per_capita = gdp_total / population`, 대륙 대응표(5절의 `region_continent`, 22행) 결합 `unmatched = "error"`. 확인: `stopifnot(nrow(gm) == 4137, n_distinct(gm$geo) == 197, n_distinct(gm$continent) == 5)`. 본문 설명은 "12장에서 확인한 결합을 그대로 쓴다" 두세 줄로 줄이고, 대륙 대응표는 표 그대로 보인다.
- PRIMM 1: 아시아 50개 나라의 2000~2020년 기대수명을 `ggplot(asia, aes(year, life_expectancy)) + geom_line()` 으로 그리면 어떤 모양일까? (답: 해마다 50개 값을 세로로 잇는 톱니 모양. 1,050행을 x 순서로 한 선으로 이었다. 이전 판 2361줄과 같은 현상.)
- 순서: 예측 → 톱니 → `aes(group = name)` 으로 나라마다 선 하나 → `geom_smooth(aes(group = 1))` 은 50개 나라를 **같은 무게로** 합친 곡선이다(인구 가중이 아님. 이전 판 2370줄의 "평균 추세선" 설명을 고침, 감사 B-20(5)). 12장 '통합 사례'의 단순 평균 대 가중 평균과 같은 구조이며 9.4 에서 다시 다룬다는 한 줄.
- PRIMM 2: 한국, 중국, 일본, 인도, 대만, 싱가포르의 1인당 GDP(x)와 기대수명(y)을 2000~2020년 순서로 잇는다. `geom_line()` 과 `geom_path()` 는 같은 그림일까? (답: 다르다. `geom_line()` 은 x(1인당 GDP) 순서로, `geom_path()` 는 행 순서(연도)로 잇는다. 일본 2002·2008·2009년, 싱가포르 2001·2008·2009·2019년, 대만 2001·2009년에 1인당 GDP 가 전년보다 줄어 두 선이 갈린다.) 이전 판 2470–2499줄, 자료만 ch12 로.
- `geom_hline()`, `geom_vline()`, `geom_abline()` 은 3.1 의 `abline()` 과 같다는 한 줄. 이전 판 2502–2532줄(연도에 대한 1인당 GDP 회귀선)은 옮기지 않는다.

### 5절. geom 과 stat: 그림이 계산한 값 `{#sec-geom-stat}` (약 310줄)

절 도입: 이 절에서 `layer_data(p, i)` 를 도입한다. 그림의 i 번째 레이어가 그리려고 계산한 표를 돌려준다. **결측이거나 척도 밖인 행은 그리는 단계에서 빠지므로 `layer_data()` 에는 남아 있다**(airquality 에서 153행, y 결측 37행 확인). 통계를 계산하는 레이어(`stat_boxplot` 등)는 척도 밖 행을 계산 전에 뺀다. 집필 워커는 이 구분을 본문에 정확히 적는다.

**5.1 개수를 세는 막대와 값을 그리는 막대 `{#sec-bar-count}`** (약 70줄)
- 일상 예(출석부) → PRIMM: `ggplot(mpg, aes(x = class)) + geom_bar()` 에는 y 를 주지 않았다. 막대 높이는 무엇인가?
- 자료: `mpg`(이전 판 2620–2669줄), `gm` 2015년
- 순서: 예측 → `layer_data(p)$count` 와 `table(mpg$class)` 대조(5, 47, 41, 11, 33, 35, 62) → `geom_col()` 로 차급별 시내 연비 평균. 이전 판 제목 p1/p2 가 서로 바뀐 것(C-20)을 옮기지 않는다. `geom_bar(stat = "identity")` 는 `geom_col()` 과 같다는 한 줄 → 가로 막대는 `aes(y = class)` → 정렬: 2015년 22개 지역의 1인당 GDP 중앙값을 `reorder()` 로 정렬한 가로 막대(이전 판 2693–2716줄, `coord_flip()` 대신 `aes(x = median, y = reorder(region, median))`, 감사 B-4).

**5.2 히스토그램과 밀도 곡선 `{#sec-hist-density}`** (약 55줄)
- PRIMM: `diamonds` 의 캐럿을 `binwidth = 0.01` 로 그리면 0.3, 0.5, 0.7, 1.0, 1.5, 2.0 캐럿 근처에 무엇이 보일까? (답: 뾰족한 막대. 무게가 특정 값에 몰려 있다. 기본 30구간에서는 보이지 않는다.)
- 자료: `diamonds`(이전 판 3102–3121줄), `iris`(3161–3171줄)
- 순서: 기본값과 메시지 `stat_bin() using bins = 30. Pick better value binwidth.` 를 **출력 그대로** 보인다 → 예측 → `binwidth = 0.01`, `bins = 150`. 이전 판의 제목 "binwidth = 0.05"(3108줄)는 9.2 의 교재로 남기고 여기서는 맞는 제목으로 → `geom_density(adjust = 0.5, 1, 2)`: `adjust` 는 대역폭 배수이며 클수록 매끄럽다(이전 판 3157줄 "복잡도" 설명 교체, C-26). `aes(y = carat)` 로 가로 히스토그램 한 줄.

**5.3 상자그림, 바이올린, 관측값 점 `{#sec-box-violin}`** (약 75줄)
- PRIMM 1: `mpg` 의 suv 시내 연비(`cty`)를 기본 그래픽 `boxplot()` 과 ggplot2 `geom_boxplot()` 으로 그린다. 연비 19 인 suv 한 대는 두 그림에서 같은 곳에 그려질까? (답: 아니다. 기본 그래픽은 힌지(`fivenum`)로 위 경계 15, 수염 한계 15 + 1.5×3 = 19.5 라 19 가 수염 끝이다. ggplot2 는 `quantile()` 기본값(type 7)으로 위 경계 14.75, 한계 18.875 라 19 가 이상점이고 수염 끝은 18 이다. `boxplot(cty ~ class, mpg, plot = FALSE)$stats` 와 `layer_data()` 의 `upper`, `ymax`, `outliers` 로 대조.) 2.3 의 정의와 연결한다.
- PRIMM 2: 봉우리가 둘인 자료, 정규분포 자료, 균일분포 자료의 상자그림은 서로 구별될까? (이전 판 796–824줄의 모의 자료 `bimodal`, `normal`, `unif`, `set.seed(20200522)` 를 긴 표로 만들어 `geom_boxplot()` 과 `geom_violin()` 을 나란히. vioplot 패키지는 쓰지 않는다.)
- 상자그림 위에 관측값 점(이전 판 3248–3280줄): `geom_boxplot(outlier.shape = NA)` 와 `geom_jitter(width = 0.2)` 를 함께 쓸 때 `outlier.shape = NA` 를 주는 이유(이상점이 두 번 그려짐). `reorder(class, cty, median)` 정렬. "콜라보레이션"(3246줄) 같은 표현은 옮기지 않는다. jitter 시드 고정.
- diamonds 상자그림 네 장(3214–3244줄)은 옮기지 않는다(같은 내용 반복).

**5.4 평활선: geom_smooth() 의 기본 방법 `{#sec-smooth}`** (약 40줄)
- PRIMM: 같은 `geom_smooth()` 를 `mpg`(234행)와 `diamonds`(53,940행)에 쓰면 같은 방법으로 적합할까? (답: 아니다. 관측 1,000개 미만은 `loess`, 이상은 `gam`. 메시지 `geom_smooth() using method = 'loess' and formula = 'y ~ x'`, `method = 'gam' and formula = 'y ~ s(x, bs = "cs")'` 를 출력 그대로 읽는다. 감사 C-27.)
- 자료: `mpg`(displ, hwy), `diamonds`(carat, price, 이전 판 3291–3328줄)
- 순서: 예측 → 두 메시지 → `method = "lm"` 과 기본값 나란히 → 회색 띠(`se = TRUE`)는 적합한 평균 곡선의 신뢰대라는 한 줄. "generalized addictive model" 오기를 옮기지 않는다. diamonds 점 53,940개를 다 그리면 렌더가 느리므로 diamonds 는 메시지 확인용으로 `layer_data()` 만 호출하거나 표본으로 그린다(집필 워커 판단).

**5.5 평균과 오차 막대 `{#sec-errorbar}`** (약 70줄)
- PRIMM: 오차 막대에만 `position = position_dodge(0.8)` 를 주고 점(`geom_point()`)에는 주지 않으면 점은 어디에 놓일까? (답: 컷 가운데. 오차 막대는 컷마다 색 7개만큼 옆으로 비켜 35개 위치에 놓이고, 점은 컷 가운데 5개 위치에 모인다. `layer_data()` 의 x 고유값: 오차 막대 35개, 점 5개.)
- 자료: `warpbreaks`(이전 판 2798–2816줄), `diamonds` 의 cut × color 별 캐럿 평균과 t 분포 95% 신뢰구간(2741–2793줄, `qt()` 를 쓰는 옳은 코드)
- 순서: `warpbreaks` 평균 ± 표준오차 막대그림(`geom_col(position = position_dodge(0.9))` + `geom_errorbar()`), 평균과 표준오차 값을 `summarise()` 표와 `layer_data()` 의 `ymin`, `ymax` 로 대조(양모 A·장력 L: 평균 44.56, 표준오차 6.03) → 예측 → 어긋난 그림 → 세 레이어에 같은 `position_dodge(0.8)`. 이전 판 세 단계(2741, 2764, 2780줄)를 두 단계로 줄인다.
- "오차 막대의 기본 범위는 95% 신뢰구간"(2757줄)이라는 서술은 옮기지 않는다. `geom_errorbar()` 에 기본 범위는 없고 넘겨준 `ymin`, `ymax` 를 그린다(C-22).
- 신뢰구간 시뮬레이션(2822–2862줄)은 옮기지 않고 "신뢰구간 200개의 의미는 9장 '신뢰구간의 의미' 소절"이라고 글로 참조한다(결정 7). 이 코드의 결함(A-3)은 연습문제 R3.

### 6절. 위치 조정: 쌓기, 나란히, 겹치기 `{#sec-position}` (약 180줄)

**6.1 쌓기와 나란히 `{#sec-stack-dodge}`** (약 60줄)
- 일상 예(출석 인원 쌓기 대 겹치기) → PRIMM: `diamonds` 의 색(`color`)별 막대를 컷(`cut`)으로 칠하면 막대 꼭대기는 무엇을 나타낼까? (답: 기본은 쌓기라서 그 색의 다이아몬드 전체 수. `layer_data()` 의 x 별 `max(ymax)` = `table(diamonds$color)` = 6,775, 9,797, 9,542, 11,292, 8,304, 5,422, 2,808.)
- 자료: `diamonds`(이전 판 2671–2689줄)
- 순서: 예측 → 쌓기 → `position = "dodge2"`(나란히) → `position = "fill"`(비율, 꼭대기가 모두 1) → 세 위치의 막대 꼭대기가 각각 무엇인지 한 표.

**6.2 히스토그램의 기본 위치 `{#sec-hist-stack}`** (약 70줄)
- PRIMM: iris 세 종의 꽃잎 길이 히스토그램을 `aes(fill = Species), alpha = 0.2, bins = 20` 으로 그리면 막대는 겹칠까 쌓일까? 밀도로 바꾸면(`y = after_stat(density)`) 막대 넓이의 합은 얼마일까?
- 자료: `iris`(이전 판 3126–3149, 3173–3194줄)
- 확인 값(감사 I-2): 바닥이 0 이 아닌 막대 3개(4.26–5.19cm 구간, versicolor 와 virginica 가 겹치는 곳). 밀도판 넓이의 합 3(종마다 1씩 쌓임). `position = "identity"` 로 고치면 바닥이 0 이 아닌 막대 0개.
- 순서: 예측 → 이전 판 노트의 코드 결과(제목 "Overlaying multiple histograms"(3187줄)와 그림이 다름) → `layer_data()` 로 `ymin > 0` 인 막대와 넓이 합 계산 → 두 가지 고침: `position = "identity"` 와 `facet_wrap(~ Species, ncol = 1)` → 밀도 곡선을 겹친 p4(3178–3187줄)는 쌓인 히스토그램과 쌓지 않은 밀도 곡선이 어긋난다는 것을 고친 판으로만 보인다. 이전 판의 `..density..` 는 `after_stat(density)` 로(감사 B-2).
- 감사가 지적한 사실: 세 종의 꽃잎 길이가 거의 겹치지 않아 쌓인 막대가 3개뿐이라 그림만으로는 알아채기 어렵다(감사 E "자료가 가린 오류").

**6.3 겹친 점: 투명도와 흩뜨리기 `{#sec-overplotting}`** (약 50줄)
- PRIMM: `mpg` 234행으로 실린더 수(`cyl`)와 시내 연비(`cty`)의 산점도를 그리면 점이 몇 개 보일까? (답: 33개. `nrow(distinct(mpg, cyl, cty))` = 33. 같은 자리의 점이 겹친다.)
- 자료: `mpg`(이전 판 2569–2592줄), 정규 난수 5,000쌍(2331–2346줄, `set.seed(20200605)`)
- 순서: 예측 → 확인 → `position_jitter(width = 0.3, height = 0, seed = 1)` (세로로는 흩뜨리지 않아 연비 값을 바꾸지 않음) → 점 5,000개에 `alpha = 0.1`. jitter 는 그림에서 점의 위치를 바꾸므로 `layer_data()$x` 가 원래 값과 다르다는 것을 한 줄로 확인.

### 7절. 척도, 좌표, 글자 `{#sec-scales}` (약 250줄)

감사 G-1: 현 장은 이 부분(3332–3419줄, 88줄)에 예제가 거의 없다. 강화한다.

**7.1 척도 한계와 좌표 확대 `{#sec-limits-zoom}`** (약 80줄)
- 일상 예(사진 확대 대 잘라 내고 다시 평균) → PRIMM: `mpg` 차급별 고속도로 연비 상자그림에 `ylim(15, 30)` 을 더한 그림과 `coord_cartesian(ylim = c(15, 30))` 을 더한 그림은 같을까? (답: 다르다. `ylim()` 은 범위 밖 29행을 버린 뒤 상자를 다시 계산해 midsize 중앙값이 27 → 26, suv 가 17.5 → 18 로 바뀐다. 경고 `Removed 29 rows containing non-finite outside the scale range (stat_boxplot())`. `coord_cartesian()` 은 계산을 그대로 두고 보이는 범위만 줄인다.)
- 자료: `mpg`(감사 I-3)
- 순서: 예측 → 세 그림(원본, `ylim`, `coord_cartesian`) → 중앙값 비교 표(`layer_data()$middle`) → 경고를 출력 그대로 읽는다 → 축 범위 대 자료 범위: `ggplot_build(p)$layout$panel_params[[1]]$y.range` (좌표 확대 그림 14.25–30.75, 여백 5% 포함) 와 `range(mpg$hwy)` (12–44) → 점 그림에서는 같은 `ylim()` 이 점을 지우기만 한다(`mpg` displ–hwy 에 `ylim(20, 30)` 이면 100행 제거 경고, `layer_data()` 에는 y 가 `NA` 인 100행으로 남음).
- 슬라이드는 세 장면을 차례로 보인다(7절 참조).

**7.2 로그 척도 `{#sec-log-scale}`** (약 45줄)
- PRIMM: 2015년 1인당 GDP 는 623 달러에서 115,940 달러까지다. 보통 축에 그리면 나라 대부분은 어디에 모일까?
- 자료: `gm` 2015년, 세 지표가 모두 있는 189개 나라
- 순서: 보통 축 산점도(기대수명 대 1인당 GDP) → `scale_x_log10(labels = scales::label_comma())` → 로그 축은 눈금 간격이 곱으로 늘어난다(1,000, 10,000, 100,000) → **로그 척도에서 `layer_data()$x` 는 로그를 취한 값**: 한국 2015년 34,178 달러 → `log10(34178)` = 4.534 로 확인 → 축 제목에 "로그 눈금"을 적는다. 이전 판 2548줄은 x 와 y 를 반대로(기대수명이 x) 두었다. 이 장은 x = 1인당 GDP, y = 기대수명.

**7.3 크기와 색 인코딩 `{#sec-size-color}`** (약 80줄)
- PRIMM: 2015년 인구가 가장 많은 중국(1,406,847,868명)과 가장 적은 마셜제도(57,444명)는 24,491배 차이다. `aes(size = population)` 으로 그리면 두 점의 면적은 몇 배일까? (답: 36배. `scale_size()` 는 값의 범위를 크기 1–6 에 대응시키고 면적은 크기의 제곱이다. `(max(size) / min(size))^2` = 36. `scale_size_area(max_size = 15)` 로 바꾸면 24,491배, 즉 면적이 인구에 비례.)
- 자료: `gm` 2015년 189개 나라(감사 I-2 와 같은 계산, 자료만 ch12)
- 순서: 7.2 그림에 `aes(size = population, colour = continent)` → 예측 → `layer_data()$size` 로 계산 → `scale_size_area()`, 크기 범례의 단위(`labels = scales::label_number(scale_cut = scales::cut_short_scale())`) → 큰 점이 작은 점을 덮으므로 `arrange(desc(population))` 으로 그리는 순서를 정한다 → 이전 판 노트의 코드 2557–2564줄(`aes(size = log(population, base = 10))`)을 실행해 범례 제목이 `log(population, base = 10)` 이 되고 범례 값이 로그 단위임을 보인다(감사 B-10).
- 색: 대륙(이산) 대 기대수명(연속)의 척도가 다르다는 것, `scale_colour_viridis_d()` 처럼 색각 이상에도 구별되는 팔레트 한 줄, 색이 아무 변수도 나타내지 않으면 쓰지 않는다(이전 판 COVID 그림의 24색, 감사 C-33). 범례 끄기는 `guides(size = "none")` (이전 판 3406줄 `guides(size = FALSE)` 는 경고, 감사 B-3).
- 이 소절의 최종 그림 `p_bubble` 은 10절의 **기준 그림**이다. 객체 이름을 10절의 AI 코드가 덮어쓰지 않도록 `ref_` 접두어를 붙인 사본도 남긴다(`ref_bubble_data`, 189행).

**7.4 제목, 축 이름, 주석 글자 `{#sec-labels-text}`** (약 45줄)
- PRIMM: `mtcars` 산점도에 `geom_text(aes(x = 4, y = 30, label = "평균선"))` 을 더하면 글자는 몇 번 그려질까? (답: 32번. 자료의 행마다 하나씩. ggplot2 4.0.3 이 레이어를 만들 때 `All aesthetics have length 1, but the data has 32 rows. Please consider using annotate() ...` 경고를 낸다. `annotate("text", ...)` 는 1번. 이전 판 COVID 한국 검사 수 그림이 같은 이유로 글자를 92번 겹쳐 그렸다(감사 B-12).)
- 순서: `labs(title, subtitle, x, y, colour, size, caption)` 로 축 제목에 지표 이름과 단위 → `get_labs(p)` 로 그림에 실제로 붙은 글자를 꺼낸다(9.2 에서 다시 씀) → 예측 → `annotate()` → 자동차 이름 글자 겹침(`check_overlap = TRUE`, 이전 판 2892–2932줄을 두 장으로 줄임). `hjust`·`vjust` 그림(2948줄)과 수식 글자(2968–3022줄)는 부록 B.

### 8절. 나누어 그리기, 배치, 테마, 저장 `{#sec-facet-layout}` (약 170줄)

**8.1 작은 다중 그림: facet `{#sec-facets}`** (약 70줄)
- PRIMM: `economics_long` 의 다섯 지표를 `facet_wrap(~ variable, scales = "free_y")` 로 그렸다. 두 패널에서 선의 높이를 비교해 "실업자 수가 개인 저축률보다 크다"고 말해도 될까? (답: 안 된다. 패널마다 y 척도가 다르다. 비교할 수 있는 것은 패널 안의 모양이다.)
- 자료: `mpg`(이전 판 3450–3475줄), `economics_long`(3479–3501줄)
- 순서: `facet_grid(. ~ class)` → 행 `cyl` × 열 `class` 와 회색 배경 점(패널 변수를 뺀 자료를 `data =` 로 다시 줌) → 예측 → `facet_wrap(scales = "free_y")`. 패널 이름은 **이름을 붙인 벡터**와 `labeller = as_labeller()` 로 붙인다. 이전 판처럼 `factor(levels = unique(variable), labels = c(...))` 로 위치에 기대어 붙이면 순서가 바뀔 때 조용히 틀린다(감사 C-34). 이전 판의 `scale = "free_y"`(인수 이름 부분 일치)는 연습문제 R6.
- "국소 시각화 기법"이라는 제목(3423줄)은 쓰지 않고 "작은 다중 그림(small multiples)"으로(C-28).

**8.2 여러 그림 붙이기: patchwork `{#sec-patchwork}`** (약 30줄)
- 내용: `p1 + p2`, `p1 / p2`, `(p1 | p2) / p3`, `plot_layout(guides = "collect")`, `plot_annotation(tag_levels = "A")`. 3.2 의 `par(mfrow)` 와 달리 장치에 상태를 남기지 않는다는 대조 한 문단. 이전 판의 "가장 사용하기 용이한 패키지는 ggubr::ggarrange()"(3505줄)를 옮기지 않는다.
- PRIMM 은 이 소절에 두지 않는다(짧은 소절). 절의 예측은 8.1 이 맡는다.

**8.3 테마 `{#sec-themes}`** (약 40줄)
- 내용: 완성 테마 6종을 한 그림으로(이전 판 3570–3600줄, patchwork `wrap_plots()` 3×2) → `theme(legend.position = "top")`, `element_blank()` 두 예 → ggplot2 4.0 의 `theme_grey(ink = "white", paper = "black")` 한 문단(글자·선 색과 바탕색을 한 번에 바꿈, 실행 확인) → 테마 요소 목록(3511–3551줄)은 부록 B. 참고 링크는 ggplot2 공식 문서만(감사 D: sthda 링크 삭제).

**8.4 그림 저장 `{#sec-save-plot}`** (약 30줄)
- PRIMM: `ggsave(f, p, width = 6, height = 4, dpi = 150)` 로 저장한 PNG 는 가로 세로 몇 픽셀일까? (답: 900 × 600. 크기 단위의 기본값은 인치. `dim(png::readPNG(f))` 가 600 900 3.)
- 내용: `f <- tempfile(fileext = ".png")` → `ggsave()` → `file.exists(f)`, `file.size(f)` → 크기를 주지 않으면 메시지 `Saving 7 x 7 in image` (출력 그대로) → 기본 그래픽은 `png(f); plot(cars); dev.off()` (이전 판 2065–2069줄을 임시 파일로, 감사 B-15). 저장한 파일을 다시 열어 확인한다는 것이 11장의 "쓰고 다시 읽기"와 같다는 한 줄.

### 9절. 그림 검증하기 `{#sec-verify-plot}` (약 250줄)

12장 '변환 절차 검증하기'(`#sec-verify-transform`)의 대조를 그림에 적용한다. 감사 G-5 를 이 절의 축으로 둔다.

**9.1 그림이 그린 것을 확인하는 절차 `{#sec-plot-checklist}`** (약 50줄)
- 12장 '무엇이 보존되어야 하는가' 표와 같은 형식의 표 하나(열: 확인할 것, 확인 방법, 이 장에서 본 곳):

| 확인할 것 | 방법 | 본 곳 |
|---|---|---|
| 그려진 행 수 | `nrow(data)` 대 `layer_data()` 에서 x·y 가 모두 있는 행 수. `Removed n rows` 경고를 숨기지 않는다 | 5절 도입, 7.1 |
| 빠진 행의 이유 | 결측인지 척도 밖인지. `sum(is.na())` 와 범위 비교 | 7.1 |
| stat 이 계산한 값 | `count`, `density`, `lower`/`middle`/`upper`, `ymin`/`ymax` 를 `table()`, `fivenum()`, `summarise()` 와 대조 | 5.1, 5.3, 5.5 |
| 위치 조정 | 막대 바닥이 0 인지(`ymin > 0`), 쌓았다면 꼭대기 = 합계 | 6.1, 6.2 |
| 척도와 좌표 | 확대가 목적이면 `coord_cartesian()`. `ylim()` 은 자료를 버리고 통계량을 바꾼다 | 7.1 |
| 인코딩 | 크기는 면적 비례인가, 로그 축은 표기했는가, 색이 나타내는 변수가 있는가 | 7.2, 7.3 |
| 글자와 코드 | 제목·축·범례·주석의 숫자와 기호를 코드의 인수와 대조. 단위 | 3.2, 9.2 |
| 필터와 설명 | 그림에 들어간 집단 수 = 본문의 기준 | 9.4 |
| 저장과 재현 | 임시 파일에 저장해 크기 확인, jitter 시드 | 6.3, 8.4 |
| 상태 | `par()` 되돌리기, 전역 설정(`Sys.setlocale()`) 쓰지 않기 | 3.2 |

- 본문 두세 줄: AI 가 써 준 그림 코드에도, 이전 판 강의노트처럼 사람이 쓴 그림에도 같은 표를 쓴다.

**9.2 그림 속 글자와 코드 대조 `{#sec-labels-vs-code}`** (약 55줄)
- PRIMM(버그 찾기): **이전 판 노트의 코드**(1463–1500줄, 기본 그래픽 정규분포 곡선 세 개)를 그대로 싣고 그린다. 둘째 곡선의 정점 높이는 0.282 이고 그림에는 "μ = 0, σ = 2" 라고 적혀 있다. 이 표기는 맞는가? (답: 틀렸다. 코드는 표준편차 `sqrt(2)`, `sqrt(3)` 을 썼다. `dnorm(0, 0, c(1, sqrt(2), sqrt(3)))` = 0.399, 0.282, 0.230. σ = 2, 3 이면 정점은 0.199, 0.133. 주석은 "분산 = 2, 3"이라 적어 계산은 주석과 맞고 글자만 틀렸다. 감사 A-1.)
- 고침 두 가지: 표기를 `sigma^2 == 2` 로 바꾸거나 표준편차를 2, 3 으로 바꾼다. 어느 쪽인지는 그림의 목적이 정한다.
- 두 번째 예: 이전 판 3107–3108줄의 `geom_histogram(binwidth = 0.01) + labs(title = "binwidth = 0.05")`. 글자와 인수를 코드로 꺼내 대조한다: `get_labs(p)$title` 은 `"binwidth = 0.05"`, `p$layers[[1]]$stat_params$binwidth` 는 0.01 (실행 확인). 그림 제목에 숫자를 손으로 쓰지 말고 인수에서 만든다(`sprintf()`).
- 3.2 의 `mfrow` 제목 예를 한 줄로 다시 가리킨다.

**9.3 확인을 코드로 남기기 `{#sec-plot-assert}`** (약 40줄)
- 12장 `check_sido_rate()`(12장 '검증을 코드로 남기기')와 같은 방식으로 `check_plot_rows()` 를 만든다. 요구 조건(이름을 붙인 `stopifnot()`):
  1. 레이어의 x·y 가 모두 있는 행 수 = 기대한 행 수 (`layer_data()` 는 결측·척도 밖 행을 남기므로 `complete.cases(d[c("x", "y")])` 로 센다)
  2. 축 제목이 비어 있지 않다(`get_labs()`)
- 시험: `airquality` 의 Temp–Ozone 산점도에 기대 행 수 153 을 주면 첫 조건에서 멈춘다(실제 116 행). 기대 수를 `sum(!is.na(airquality$Ozone))` 로 주면 통과. "검증 함수도 틀린 입력에서 멈추는지 확인해야 믿을 수 있다"는 12장의 문장과 같은 순서로 쓴다(그 문장을 그대로 복사하지 않는다).
- 이 함수는 9.4 와 10.3 에서 다시 쓴다. 통계를 계산하는 레이어(상자그림 등)에는 맞지 않는다는 한계를 한 줄로 적는다.

**9.4 통합 사례: 대륙별 기대수명 추이 `{#sec-gapminder-trend-case}`** (약 105줄)
- 이전 판 COVID 확장 예제(3614–3893줄)를 대신한다(결정 2). 12장 '통합 사례'의 단순 평균 대 가중 평균을 그림으로 잇는다(감사 F-3).
- 요구사항(문장으로 먼저): 2000~2020년 대륙별 기대수명 추이를 대륙마다 한 패널에 그린다. 나라별 선을 회색으로 깔고, 대륙 값은 **그 대륙에 사는 사람 한 명의 기대수명**(인구 가중 평균)으로 굵은 선을 그린다. 그림에 들어간 나라 수를 부제에 적는다.
- 1단계: 빠른 방법 `stat_summary(fun = mean, geom = "line")` 를 쓰고 `layer_data()` 를 `summarise(mean(life_expectancy), .by = c(continent, year))` 와 대조한다 → 같다(실행 확인: 아시아에서 `all.equal` TRUE). 즉 단순 평균이며 요구사항과 다르다. 4.4 의 `geom_smooth(aes(group = 1))` 도 같은 종류.
- 2단계: `weighted.mean(life_expectancy, population)` 으로 대륙·연도별 표(105행 = 5 × 21)를 만들어 `geom_line()` 레이어에 따로 준다. 단순 평균 선은 점선으로 함께 그린다.
- 예측 콜아웃: 2020년 오세아니아에서 두 선의 차이는 얼마일까? (답: 단순 70.3년, 가중 76.8년. 인구 대부분이 오스트레일리아(82.4년, 2017년)와 뉴질랜드에 있고 섬나라들은 기대수명이 낮다. 다른 대륙의 2020년: 아시아 단순 75.5 / 가중 73.9, 아메리카 76.1 / 77.5, 유럽 79.4 / 78.9, 아프리카 66.4 / 66.9. 오세아니아 21년 중 최대 차이 8.06년.)
- 3단계(필터와 설명): 해마다 나라 수를 센다. 안도라, 도미니카, 마셜제도는 기대수명이 2017년까지만 있어 2018년부터 아메리카 34 → 33, 유럽 40 → 39, 오세아니아 11 → 10. 오세아니아 단순 평균은 2017 → 2018 에 69.3 → 70.0 으로 올랐는데, 이 가운데 약 0.5년은 마셜제도(64.5년)가 빠진 효과다. 가중 평균은 마셜제도 인구가 작아 거의 변하지 않는다. 부제에 "2018년부터 3개 나라 자료 없음"을 적거나 21년 모두 자료가 있는 나라로 제한한다. 어느 쪽을 골랐는지 본문에 적는다.
- 4단계: 9.3 의 `check_plot_rows()` 를 가중 평균 레이어에 적용(105행), `get_labs()` 로 부제와 범례에 "인구 가중"이 들어갔는지 확인.
- **세계 값과의 대조는 하지 않는다.** `gapminder-world.csv` 의 세계 기대수명은 나라별 인구 가중 계산과 2000년 1.56%, 2020년 0.13% 차이가 나고, 원인을 확인하지 못했다(설계 단계 실행). 12장이 2020년 한 해만 대조한 결과(0.2% 안)를 인용하는 것은 된다.
- 마무리 콜아웃(`callout-important`): 요약선을 그리는 함수는 평균의 정의를 묻지 않는다. 선이 무엇의 평균인지는 `layer_data()` 로 확인하고 범례나 부제에 적는다.

### 10절. AI와 함께: 거품 그림 코드의 검증 `{#sec-ai-visualization}` (약 220줄)

세부는 6절(이 설계서의 "AI와 함께" 설계)에 있다. 소절 구성:

- 10.1 작업 요구사항 `{#sec-ai-visualization-spec}` (약 50줄): 학생 상황 두 줄, 프롬프트 전문(```` ```text ````), 요청이 잘 쓴 점과 AI 가 볼 수 있는 범위(파일마다 앞 4행, 2000년 아프가니스탄·알바니아 등), 개인정보 `callout-warning`(12장과 같은 내용, 문장은 새로 씀).
- 10.2 AI 가 생성한 코드 `{#sec-ai-visualization-gen}` (약 45줄): 응답의 설명 요약과 코드 그대로. 경로만 `dataset/ch12/` 를 덧붙인다. 첫 줄 주석 `# 생성: <모델명>, <날짜>. ...`.
- 10.3 검증 `{#sec-ai-visualization-verify}` (약 70줄): 6.3 의 검증 항목을 실제 응답에 적용.
- 10.4 AI 가 보지 못한 부분 `{#sec-ai-visualization-gaps}` (약 40줄): 실제 응답에서 확인된 것만 표로.
- 10.5 연습 `{#sec-ai-visualization-practice}` (약 15줄).

### 연습문제 `{#sec-ex-visualization .unnumbered}` (약 100줄)

8절(이 설계서)에 문항 목록이 있다.

### 분량 합계

| 부분 | 줄 |
|---|---:|
| 머리 | 110 |
| 1 그림으로 자료 보기 | 110 |
| 2 기본 그래픽: 고수준 함수 | 280 |
| 3 덧그리기와 그래픽 상태 | 170 |
| 4 ggplot2 의 문법 | 290 |
| 5 geom 과 stat | 310 |
| 6 위치 조정 | 180 |
| 7 척도, 좌표, 글자 | 250 |
| 8 나누어 그리기, 배치, 테마, 저장 | 170 |
| 9 그림 검증하기 | 250 |
| 10 AI와 함께 | 220 |
| 연습문제 | 100 |
| 합계 | 약 2,440 |

모든 절에 소절이 있고, 소절 하나가 100줄을 넘지 않는다(가장 긴 9.4 가 약 105줄이면 단계 두 개를 하나로 합쳐 100줄 안으로). 감사 G-1 안(약 2,520줄)보다 80줄 적다. 기본 그래픽은 450줄(감사 안 560줄)로 줄였다(결정 4).

---

## 4. 이전 판 재사용 대응표

"살림"은 집필에서 빠지면 검수에서 치명으로 반려된다(오케스트레이터 지시). "부록 B"는 이번에 파일을 만들지 않고 목록만 남긴다(결정 4).

### 4.1 본문 예제와 R 청크

| 현 장 줄 | 예제 | 처리 | 새 장 위치와 쓰는 법 | 안 살리면 이유 |
|---|---|---|---|---|
| 40–48 | 학습 목표 | 버림 | 1절(이 설계서)로 대체 | 기억 동사 목표 |
| 50–56, 85–87 | Tukey 인용, 근거 없는 주장 | 버림 | — | 감사 G-9 |
| 58–83 | Anscombe 2×2 | **살림** | 1.1, y축 이름 고쳐 실행. 원래 버그는 연습 R4 | — |
| 90–167 | 그래픽 장치, 그래프 요소, 고수준·저수준 정의 | 압축 | 1.2 (화면·파일 장치 두 가지) | `windows()` 만 안내(B-19) |
| 111–142 | `r-graphic-layout` 영역 그림 | **살림** | 3.2 | — |
| 151 | AIMS-R-users 링크 | 버림 | 출처 표기만 3.2 캡션에 | 503(B-17) |
| 179–208 | `plot(mtcars)`, `plot(lm)`, `plot(Titanic)` | **살림** | 2.1 PRIMM | — |
| 213–228 | `plot(x)` 대 `plot(x, y)` | 압축 | 2.1 한 문단 | — |
| 232–247 | `plot()` 인수 목록 | 부록 B | — | 사전형 |
| 251–276 | `type` 8종(BOD) | **살림** | 2.1 | — |
| 281–325 | `xlim`·`ylim`, `xlab`·`ylab` 격자 그림 | 부록 B | — | 사전형. 4.1 이 축 범위의 효과를 예측으로 다룸 |
| 329–350 | `plot-linetype` (lty 0–6) | **살림** | 2.1 참조표, 4.3 에서 `linetype` 과 공유 | — |
| 355–369 | `plot-symbol` (pch 1–25) | **살림** | 2.1 참조표, 4.3 에서 `shape` 과 공유 | — |
| 371–425 | `cex` 계열, `lwd` 크기 그림 | 부록 B | — | 사전형 |
| 427–442 | `palette()` 그림, 색 함수 설명 | 교체 | 2.1 에 `palette()` 실행 결과 | 그림이 R 4.0 이전 팔레트, 설명 5개 중 4개 틀림(B-6) |
| 449–504 | `car::scatterplot`, `scatterplotMatrix` 4청크 | 버림 | 2.1 의 `plot(mtcars[, 1:4])` 가 산점도 행렬을 대신함 | 같은 내용 반복, 패키지 추가, `scatterplotMatrix(iris)` loess 경고 80건(D) |
| 472–480 | `pairs()` / `plot(iris)` | 압축 | 2.1 에 한 줄 | — |
| 506–546 | 행렬 `plot`, `matplot()` | 부록 B | — | 기본 그래픽 전용, ggplot2 는 긴 표로 그림 |
| 553–580 | `hist()` 인수, 반환값 | **살림** | 2.2 (반환값은 "그림이 계산한 값"의 첫 예) | — |
| 585–611 | 한글 제목 `hist()`, `labels = TRUE` | 압축 | 2.2, `par(family)` 없이 한글 제목과 화씨 단위 | `nanumgothic` 운영체제 의존(B-18) |
| 615–620 | `breaks = 4` 대 `15` | **살림** | 2.2 PRIMM 2 | — |
| 628–634 | `hist(x)` 대 `barplot(x)` | **살림** | 2.2 PRIMM 1 | — |
| 641–663 | warpbreaks 쌓은·나란한 막대 | **살림** | 2.2 | — |
| 668–687 | warpbreaks 막대 + 표준오차 `arrows()` | **살림** | 연습 W3 (ggplot2 판 2798줄과 같은 값을 그리는지 대조) | 본문은 5.5 의 ggplot2 판 하나로 |
| 693–724 | 상자그림 해부 | **살림** | 2.3, 라벨 고침(B-8) | — |
| 731–783 | `boxplot()` 인수, 벡터·행렬·데이터프레임·리스트 4장 | 압축 | 2.3 에 수식 인터페이스 한 예 | 같은 그림 반복 |
| 786–824 | `vioplot` 과 모의 자료(bimodal, normal, unif) | **살림(자료)** | 5.3 PRIMM 2, `geom_violin()` 으로 | vioplot 패키지는 쓰지 않음 |
| 827–849 | Titanic 모자이크 | **살림** | 2.4 | — |
| 852–872 | `mosaicplot()` 인수 | 버림 | — | 사전형 |
| 874–911 | UCBAdmissions 합친 표와 학과별 6장 | **살림** | 2.4 PRIMM (심슨의 역설) | — |
| 914–976 | `par()` 조회, 파라미터 표 | 부록 B | 3.2 에서 `par("mar")` 한 줄 | 사전형 |
| 982–985 | `graphics-figureAnatomy1.png`, `…2.png` | 1 **살림**, 2 부록 B | 3.2 | — |
| 995–1133 | `pin`, `fin`, `fig` 해부 그림 | 부록 B | 3.2 에서 오류 재현에만 `pin` 사용 | 해부. `fig-anatomy` 표기 오류(B-7(2)) 고친 뒤 이동 |
| 1136–1218 | `mar` 해부 | 부록 B | — | 해부. `left` 중복 오기(B-20(2)) |
| 1221–1254 | `mfrow`, `mfcol` 3×2 | **살림** | 3.2 PRIMM 1 (제목 오류를 교재로) | — |
| 1257–1332 | `mfg`, `layout()`, `split.screen()` | 부록 B | — | 해부. 1314줄 콘솔 오류는 3.2 에서 사실로만 언급 |
| 1336–1357 | `new = TRUE` 상자그림 + 바이올린 | 버림 | — | 축이 다른 두 그림을 덮어 설명 없이 가림(C-12) |
| 1360–1405 | `oma` 해부 | 부록 B | — | 해부 |
| 1408–1436 | `points()` (cars, iris) | **살림** | 3.1, `legend()` 예와 합쳐 하나로 | — |
| 1439–1459 | `lwd` 해부 그림 | 부록 B | — | 해부 |
| 1461–1501 | 정규분포 곡선 세 개(σ 표기 오류) | **살림(버그 교재)** | 9.2 PRIMM | 치명 A-1 |
| 1504–1558 | `abline-example` (회귀선, 잔차선, 평균선) | **살림** | 3.1 PRIMM, `bar(y)` 고침 | — |
| 1561–1640 | `arrows()`, `rect()` 해부 | 부록 B | — | 타이핑 성격 |
| 1643–1699 | `polygon()` 도형 4개 | 부록 B | — | "Star (Jewish)" 명칭(C-15). 도형 그리기는 통계 맥락 없음 |
| 1701–1726 | `polygon-example` 확률 넓이 | **살림** | 3.1 | — |
| 1728–1830 | `text()`, `mtext()` 인수와 해부 | 부록 B | 3.1 에서 `text()` 한 번 사용 | 해부. `mtext` 그림의 `at` 표기 오류(B-7(3)) 고친 뒤 이동 |
| 1833–1859 | `legend()` | **살림** | 3.1 | — |
| 1862–2059 | 수식 표현, 그리스 문자, 수식 예 | 부록 B | — | 사전형 |
| 2061–2071 | `png()` 저장 | **살림(바꿈)** | 8.4, 임시 파일로 | 추적 파일 재작성(B-15) |
| 2073–2172 | ToothGrowth 기본 그래픽 대 ggplot2 | **살림** | 4.1 PRIMM | — |
| 2174–2247 | 문법 틀, 용어 목록 | 압축 | 4.2 용어 표 | — |
| 2249–2277 | `ggplot-begin` (eval=FALSE) | **살림(실행)** | 4.2 | 결과 그림이 없었음(E) |
| 2280–2346 | 색 aesthetic, `alpha` | **살림** | 4.3(fill, colour), 6.3(alpha 5,000점) | — |
| 2348–2387 | Gapminder 아시아 `group` 톱니, `geom_smooth(group)` | **살림(자료 교체)** | 4.4 PRIMM 1, ch12 자료 | `gapminder_filter.csv` 쓰지 않음(결정 3) |
| 2390–2420 | `size = hp`, `shape = factor(cyl)` | **살림** | 4.3 | — |
| 2424–2441 | `economics_long` linetype | 압축 | 4.3 에서 한 문장, 자료는 8.1 에서 씀 | — |
| 2445–2467 | `geom_line` 소개(Gapminder) | 압축 | 4.4 | — |
| 2470–2499 | `geom_path()` 여섯 나라 | **살림(자료 교체)** | 4.4 PRIMM 2 | — |
| 2502–2532 | `geom_abline/hline/vline` (연도 회귀선) | 버림 | 4.4 한 줄 | 아시아 나라를 섞은 회귀선은 뜻이 없음 |
| 2535–2566 | Gapminder 2015 산점도와 거품 그림 | **살림(자료 교체)** | 7.2, 7.3, 10 의 기준 그림 | — |
| 2569–2592 | mpg cyl–cty, jitter | **살림** | 6.3 PRIMM | — |
| 2594–2669 | `geom_bar` 대 `geom_col`, 가로 막대 | **살림** | 5.1 PRIMM | — |
| 2671–2689 | diamonds 쌓기 대 `dodge2` | **살림** | 6.1 PRIMM | — |
| 2691–2716 | 지역별 중앙값 정렬 막대 | **살림(자료 교체)** | 5.1, `coord_flip()` 대신 y 매핑 | — |
| 2721–2793 | `geom_errorbar` 세 단계 | **살림** | 5.5 PRIMM (두 단계로) | — |
| 2796–2818 | warpbreaks 막대 + 오차 막대(ggplot2) | **살림** | 5.5 | — |
| 2822–2862 | 신뢰구간 시뮬레이션 | 버림 | 5.5 에서 9장 참조, 연습 R3 | 9장과 중복, 치명 A-3 |
| 2864–2932 | `geom_text`, `geom_label`, `check_overlap` | **살림** | 7.4 (두 장으로) | — |
| 2935–2965 | `hjust`·`vjust` 그림 | 부록 B | — | 사전형 |
| 2968–3022 | `geom_text()` 수식 | 부록 B | — | 사전형 |
| 3024–3052 | `geom_ribbon` ±5,000 | 버림 | — | 아무것도 나타내지 않는 띠(C-24) |
| 3054–3080 | `geom_area` 정규분포 넓이 | 버림 | — | 3.1 `polygon-example` 과 중복 |
| 3084–3121 | 히스토그램 구간 4장 | **살림** | 5.2 PRIMM, 제목 오류는 9.2 | — |
| 3124–3149 | iris 종별 히스토그램(쌓임) | **살림** | 6.2 PRIMM | — |
| 3151–3194 | `geom_density` 4장 | **살림** | 5.2(`adjust`), 6.2(겹친 밀도) | — |
| 3197–3244 | diamonds 상자그림 4장 | 버림 | — | 5.3 의 mpg 예와 같은 내용 |
| 3246–3280 | mpg 상자그림 + jitter, `reorder()` | **살림** | 5.3 | — |
| 3283–3328 | `geom_smooth` 4장 | **살림** | 5.4 PRIMM | — |
| 3332–3360 | 척도 설명, `scale_size_continuous` | **살림(강화)** | 7.1~7.3 | 예제가 거의 없었음 |
| 3364–3381 | `coord_flip()` 상자그림 | 교체 | 5.1 의 y 매핑으로 | Superseded(B-4) |
| 3385–3419 | `guides()`, `guide_legend()` | **살림** | 7.3 (`guides(size = "none")`) | — |
| 3423–3475 | `facet_grid`, 회색 배경 점 | **살림** | 8.1 | — |
| 3477–3501 | `economics_long` `facet_wrap(free_y)` | **살림** | 8.1 PRIMM, 이름 붙인 벡터로 | — |
| 3504–3507 | `ggarrange()` 팁 | 교체 | 8.2 patchwork | 결정 5 |
| 3509–3557 | 테마 요소 목록 | 부록 B | 8.3 에 두 예 | 사전형 |
| 3560–3600 | 완성 테마 6종 | **살림** | 8.3 | — |
| 3604–3611 | 참고 팁 | 압축 | 장 끝 참고 자료(ggplot2 문서, https 로 바꾼 r-statistics.co) | — |
| 3614–3767 | COVID 자료 준비 | 버림 | — | 결정 2 (2020-06 스냅샷, OWID 저장소 보관 처리) |
| 3770–3803 | COVID 대륙별 막대(겹침) | 버림(교재로만) | 연습 R5 의 코드 읽기 | B-11. 자료를 싣지 않으므로 코드와 사실만 |
| 3807–3852 | 한국 검사 수(글자 92번) | 버림(교재로만) | 7.4 PRIMM 의 사례 언급 | B-12 |
| 3855–3893 | 검사/확진 순위 24개국 | 버림(교재로만) | 연습 R2 의 코드 읽기 | A-2 |

### 4.2 정적 그림 (`figures/`)

| 파일 | 열어 본 결과 | 처리 |
|---|---|---|
| `grammar-graphics-intro.png` (1942×598) | 이 설계 단계에서 `Read` 로 확인. 표 7행(id, ht, sex, bmi)과 점 7개의 위치·색(M 검정, F 빨강)이 맞다. 표기 오류 없음 | **본문 4.2**, 슬라이드 4절 |
| `graphics-figureAnatomy1.png` (350×285) | `Read` 로 확인. Device, Outer Margin 1–4, Figure region, Figure Margin 1–4, Plot region, `mai`, `pin`, `fin`, `din` 표기 오류 없음 | **본문 3.2**, 슬라이드 3절. 캡션에 출처 "AIMS-R-users(Murray Logan), 현재 접속 불가" |
| `r-graphic-palette.png` (675×70) | `Read` 로 확인. R 4.0 이전 팔레트(white, black, red, green3, blue, cyan, magenta, yellow, gray) | 버림. 2.1 에서 `palette()` 실행 결과로 대체 |
| `graphics-figureAnatomy2.png` | 감사 D 에서 확인, 오류 없음 | 부록 B |
| `graphics-adjPlot.png`, `graphics-posPlot.png`, `graphics-srtPlot.png` | 감사 D, 오류 없음(용어 C-17 만) | 부록 B |
| `expression-table-01.png` ~ `05.png` | 감사 D, 01 확인 오류 없음 | 부록 B 또는 `demo(plotmath)` 안내 |
| `greek-letters.png` | 감사 D, 오류 없음 | 부록 B |
| `math-example.png` | 감사 D, 오류 없음 | 부록 B |
| `ggplot-text-math.png` | 감사 D, 원 코드 4.0.3 에서 실행됨 | 부록 B |
| `save-example.png` | 렌더가 다시 쓰는 추적 파일(B-15), 본문에 표시하지 않음 | 버림. 새 장은 쓰지 않음 |

### 4.3 자료

| 자료 | 처리 | 새 장 |
|---|---|---|
| `anscombe`, `mtcars`, `cars`, `BOD`, `airquality`, `warpbreaks`, `iris`, `ToothGrowth`, `Titanic`, `UCBAdmissions` | 살림 | 1~9절 |
| `mpg`, `diamonds`, `economics_long` | 살림 | 4~8절 |
| `dataset/gapminder/gapminder_filter.csv` | 버림 | 생성 스크립트 없음, `dataset.zip` 에 없음(B-16). ch12 파일로 대체(결정 3) |
| `dataset/covid-19-dataset/` 네 파일 | 버림 | 결정 2 |
| 개인정보 의심 파일 4종 | 쓰지 않음 | 현 장도 쓰지 않음(감사 D 확인) |

### 4.4 부록 B 로 보낼 목록 (이번에는 파일을 만들지 않음)

`plot()` 인수 목록(232–247), `xlim`·`ylim`·`xlab`·`ylab` 격자(281–325), `cex` 계열과 `lwd`(371–425), 행렬 `plot`·`matplot`(506–546), `par()` 파라미터 표(939–976), `pin`·`fin`·`fig`·`mar`·`mfg`·`layout`·`split.screen`·`oma` 해부(995–1405, 그림의 표기 오류 B-7(2) 고친 뒤), `lwd` 해부(1445–1459), `arrows`·`rect`·도형 `polygon`(1561–1699), `text`·`mtext` 인수와 해부(1728–1830, B-7(3) 고친 뒤), 수식 표현·그리스 문자·수식 예(1862–2059), `hjust`·`vjust` 그림(2948–2965), `geom_text` 수식(2968–3022), 테마 요소 목록(3511–3551), 정적 그림 9개(4.2 표의 "부록 B").

---

## 5. 새 연습 자료 명세

**새 자료 파일을 만들지 않는다.** `dataset/ch13/` 와 `make-ch13-data.R` 은 필요 없다. 이유: 함수는 내장 자료로 익히고, 검증과 AI 절은 12장 Gapminder 파일(2000~2020년, `dataset/ch12/make-gapminder-data.R`)을 그대로 쓴다(결정 3). 오케스트레이터 상태 파일의 "3a 연습 자료" 단계는 건너뛴다.

쓰는 파일: `dataset/ch12/gapminder-population.csv`(4,137행), `gapminder-gdp.csv`(4,095행), `gapminder-life-expectancy.csv`(3,960행), `gapminder-regions.csv`(234행). `gapminder-world.csv` 는 쓰지 않는다(9.4).

**대륙 대응표** `region_continent` 는 본문 청크에서 `tribble()` 로 만든다(22행). 지역 이름은 12장에서 오타를 고친 뒤의 이름이다. 대륙 이름은 한국어이고, 순서는 10절 프롬프트의 순서(아프리카, 아메리카, 아시아, 유럽, 오세아니아)로 `factor` 수준을 정한다.

| 대륙 | 지역(region) |
|---|---|
| 아프리카 | Eastern Africa, Middle Africa, Northern Africa, Southern Africa, Western Africa |
| 아메리카 | Caribbean America, Central America, Northern America (원자료 `Northen America`), South America |
| 아시아 | Central Asia, Eastern Asia, South-Eastern Asia, Southern Asia, Western Asia |
| 유럽 | Eastern Europe, Northern Europe, Southern Europe, Western Europe |
| 오세아니아 | Melanesia Oceania, Micronesia Oceania, Oceania (오스트레일리아, 뉴질랜드), Polynesia Oceania |

- 지역 이름 22개 가운데 6개(`Caribbean America`, `Melanesia Oceania`, `Micronesia Oceania`, `Polynesia Oceania`, `Oceania`, `Northen America`)는 UN 표준 하위 지역 이름(`Caribbean`, `Melanesia`, `Australia and New Zealand`, `Northern America` 등)과 다르다. 이전 판 강의노트가 손질한 이름이다(감사 D). 대응표를 표로 쓰고 `unmatched = "error"` 로 결합하면 짝 없는 지역이 생길 때 멈춘다. 이전 판처럼 정규식 `gsub("(.+\\s)", "", region)` 으로 마지막 낱말을 대륙으로 쓰면 이 자료에서는 결과가 같지만, 손질하지 않은 이름에서는 조용히 틀린다(감사 E). 본문에서 이 차이를 한 문단으로 설명한다.

**정답 값** (집필과 AI 절 검증의 기준, 설계 단계 실행 결과)

| 항목 | 값 |
|---|---|
| `gm` 행 수 / 나라 수 | 4,137 / 197 |
| 2015년 인구·GDP·기대수명이 모두 있는 나라 | 189 (인구 197, GDP 195, 기대수명 189) |
| 2015년 기대수명이 없는 나라 | 8: Holy See, Liechtenstein, Monaco, Nauru, Palau, St. Kitts and Nevis, San Marino, Tuvalu |
| 2015년 189개 나라의 대륙별 수 | 아프리카 54, 아메리카 34, 아시아 50, 유럽 40, 오세아니아 11 |
| 이름(`name` = `country`)으로 지역을 결합하면 | 189개 중 162개만 짝 (27개 탈락) |
| 소문자 코드(`geo` = `iso`)로 결합하면 | 0개 짝 |
| 비표준 지역 이름 6개에 속한 2015년 나라 | 25 (Caribbean America 12, Melanesia 4, Micronesia 3, Northen America 2, Oceania 2, Polynesia 2) |
| 2015년 1인당 GDP 범위 | 623 ~ 115,940 |
| 한국 2015년 | 인구 50,823,087, 1인당 GDP 34,178, 기대수명 82.3 |
| 2015년 인구 최대 / 최소 | 중국 1,406,847,868 / 마셜제도 57,444, 비 24,491 |
| `scale_size()` 기본의 면적비 / `scale_size_area()` | 36 / 24,491 |
| 인구 표 기준 `left_join()` 후 2015년 산점도 | 197행, 경고 `Removed 8 rows containing missing values or values outside the scale range` |

---

## 6. "AI와 함께" 절 설계

### 6.1 과제 명세 (학생이 받는 과제문)

> 12장의 Gapminder 파일 네 개(인구, GDP, 기대수명, 지역)로 2015년 나라별 거품 그림을 그린다. x축은 1인당 GDP(로그 축), y축은 기대수명, 점 하나는 나라 하나, 점 크기는 인구에 비례, 색은 대륙(다섯 개)이다. AI 에게 코드를 요청하고, 받은 코드의 그림을 9.1 의 확인 절차로 검증한 뒤, 7.3 에서 직접 만든 그림과 대조한다. 프롬프트, 응답, 검증 결과를 함께 제출한다.

### 6.2 학생 프롬프트 전문

`student-ai` 에 아래 [요청] 부분을 그대로 보낸다(지시문은 `.claude/agents/student-ai.md`). 각 파일의 앞 5줄은 `dataset/ch12/` 파일에서 그대로 복사한 것이다(설계 단계에서 `head -5` 로 확인). 노트 10.1 에도 이 전문을 ```` ```text ```` 블록으로 싣는다.

```text
통계 수업 과제로 Gapminder 자료를 가지고 그림을 그리려고 해. R tidyverse(ggplot2)를 쓸 거고 파일은 네 개야.

1) gapminder-population.csv : 나라별 연도별 인구 (2000~2020년)
"geo","name","year","population"
"afg","Afghanistan",2000,20779957
"afg","Afghanistan",2001,21606992
"afg","Afghanistan",2002,22600774
"afg","Afghanistan",2003,23680871

2) gapminder-gdp.csv : 나라별 연도별 GDP (구매력평가 기준, 2011년 불변 국제달러)
"geo","name","year","gdp_total"
"afg","Afghanistan",2000,14265982427
"afg","Afghanistan",2001,13965937903
"afg","Afghanistan",2002,22967932809
"afg","Afghanistan",2003,24996520016

3) gapminder-life-expectancy.csv : 나라별 연도별 기대수명
"geo","name","year","life_expectancy"
"afg","Afghanistan",2000,54.63
"afg","Afghanistan",2001,54.76
"afg","Afghanistan",2002,55.65
"afg","Afghanistan",2003,56.36

4) gapminder-regions.csv : 나라별 지역 구분
"iso","country","region"
"AFG","Afghanistan","Southern Asia"
"ALB","Albania","Southern Europe"
"DZA","Algeria","Northern Africa"
"ASM","American Samoa","Polynesia Oceania"

2015년 자료로 거품 그림을 그리고 싶어. 나라 하나가 점 하나이고, x축은 1인당 GDP(로그 축), y축은 기대수명이야. 점 크기는 인구에 비례하게 하고, 색은 대륙으로 구분해 줘. 대륙은 아프리카, 아메리카, 아시아, 유럽, 오세아니아 다섯 개야. 코드 짜 줘.
```

- 기록: `ai-transcripts/13-data-visualization/gapminder-bubble-2015.md`. 머리에 모델, 날짜, 쓰인 곳, 호출 방법(12장 기록과 같은 형식), 프롬프트 전문, 응답 전문. 한 번만 요청하고 응답을 고르지 않는다.
- 이 요청이 명세로서 잘 쓴 점(노트 10.1 에 쓸 것): 파일마다 역할과 단위를 적었다, 머리글과 값의 모양을 보였다, "인구에 비례"와 "대륙 다섯 개"처럼 확인할 수 있는 조건을 적었다.
- AI 가 볼 수 있는 범위: 파일마다 2000년 아프가니스탄 4행(지역 표는 4개 나라). 2015년 행, 기대수명이 없는 나라, 22개 지역 이름 전체, 이름 표기 차이는 보이지 않는다. 코드의 대소문자 차이(`afg` 대 `AFG`)는 보인다.

### 6.3 검증 항목 (노트 10.3, 실제 응답에 적용)

검증은 AI 코드를 실행한 결과와 7.3 의 기준 그림(`ref_bubble_data`, 189행)을 대조한다. AI 코드는 `pop`, `gm`, `df` 같은 이름을 다시 쓸 수 있으므로, 기준값은 10절 앞에서 `ref_` 이름으로 따로 남겨 둔다.

1. **연도와 행**: 그림에 쓴 자료가 2015년 한 해뿐인가(`distinct(year)`). 그려진 점의 수가 189 인가(9.3 `check_plot_rows()`). 경고 `Removed n rows` 가 있으면 몇 행이고 왜인가(인구 표 기준 `left_join()` 이면 기대수명 없는 8개 나라).
2. **결합**: 지역 표와 결합할 때 짝을 잃은 나라가 있는가(`anti_join()`). 이름으로 결합했다면 27개가 빠지거나 대륙이 `NA` 가 된다. 소문자 코드 그대로면 전부.
3. **대륙 대응**: `count(region, continent)` 로 22개 지역이 빠짐없이 다섯 대륙에 대응되었는가, `NA` 대륙이 있는가. 대륙별 나라 수가 54, 34, 50, 40, 11 인가.
4. **x 값**: 1인당 GDP 를 `gdp_total / population` 으로 계산했는가(총 GDP 를 그리지 않았는가). 한국 2015년 34,178, 로그 척도면 `layer_data()$x` = 4.534.
5. **크기 비례**: `layer_data()$size` 로 가장 큰 점과 가장 작은 점의 면적비를 계산해 인구비 24,491 과 비교한다. `scale_size()` 기본이면 36, `scale_size(range = c(a, b))` 면 (b/a)², `scale_size_area()` 면 24,491. 프롬프트가 "인구에 비례"를 요구했으므로 이 항목이 명세 대조다.
6. **글자**: `get_labs()` 로 x축 제목에 지표 이름·단위·로그 눈금이 있는가, 크기 범례 값이 인구 단위인가(로그를 취한 값이 아닌가), 범례에 `NA` 항목이 있는가.

### 6.4 예상되는 "AI 가 보지 못한 부분"

아래는 설계 단계의 **예상**이다. 노트 10.4 에는 실제 응답에서 확인된 것만 싣는다(작업 규칙 7). 응답이 피해 간 항목은 "응답이 처리함"으로 기록하고, 흔한 오류 목록에 넣지 않는다.

| 자료의 결함 | 앞 5줄에 보이나 | 어긋나면 드러내는 검증 |
|---|---|---|
| 2015년 기대수명이 없는 8개 나라 | 아니오 | 항목 1 (경고 8행, 또는 `inner_join()` 이면 조용히 189) |
| 지역 이름 22개 중 6개가 UN 표준 이름과 다름(오타 `Northen America` 포함). UN 표준 이름으로 대응표를 쓰면 25개 나라가 `NA` | 아니오(`Polynesia Oceania` 한 행만 보임) | 항목 3 |
| 나라 이름 표기 차이(28개, 2015년 189개 중 27개) | 아니오 | 항목 2 |
| 코드 대소문자(`afg` 대 `AFG`) | 예 | 항목 2 |
| 크기 척도의 기본값이 면적 비례가 아님 | 자료 결함이 아니라 함수 기본값 | 항목 5 |
| 교황청 코드 `hos` 대 `VAT` | 아니오 | 2015년 그림에는 영향 없음(교황청은 GDP·기대수명 없음). 노트에 쓰지 않아도 된다 |

- AI 응답이 설치되지 않은 패키지(`countrycode` 등)를 쓰면: 설치하지 않고 그 청크를 `eval: false` 로 싣고, 같은 대응을 표로 만든 판으로 검증한다. 강사 확인 항목으로 기록한다(9절).
- 렌더 중 API 호출 금지. 생성 코드 청크는 실행하되(12장처럼) 경로만 `dataset/ch12/` 로 덧붙이고 첫 줄 주석에 밝힌다. 실행해서 오류가 나면 오류도 그대로 싣는다.

### 6.5 노트 10.5 연습 (세 문항)

1. 지역 표 **전체**(22개 지역 이름)를 프롬프트에 붙여 다시 요청하고, 대륙 대응이 달라지는지와 항목 3 의 결과를 기록하시오.
2. "점 크기는 인구에 비례"를 빼고 요청하시오. 응답의 크기 척도와 면적비를 항목 5 로 계산하고, 명세 한 줄이 결과를 바꾸었는지 쓰시오.
3. 짝과 함께, 이 절의 검증 항목 가운데 하나에 걸리는 그림 코드를 일부러 만들어 교환하고 상대의 결함을 찾으시오. AI 의 도움을 받았다면 프롬프트와 응답을 함께 제출하시오.

---

## 7. 슬라이드 계획

- 총 60장: 표지 1, 절 표지 10, 본문 49. 12장 덱(본문 60장)보다 본문이 적다. 범위 55~65장.
- 규칙: 개조식, 줄표(—)·가운뎃점(·) 금지, `{.smaller}` 금지, R 청크 그림은 `::: {}` 로 감싼다(CLAUDE.md 슬라이드 (14)), 경고가 긴 청크는 경고 요지를 본문에 적고 출력은 `pull()`, `nrow()` 처럼 짧게(슬라이드 (10), (13)). 노트의 경고 정책과 달리 슬라이드는 `#| warning: false` 를 쓸 수 있으나 **경고 문구를 읽는 슬라이드**(4.3 의 `size`, 7.1 의 `Removed 29 rows`, 7.4 의 32행)는 경고 첫 줄을 텍스트로 싣는다.
- 예측 슬라이드는 `## 예측해 보자 {.predict}` 로, 묻는 코드나 그림을 함께 싣는다.

| 절 | 본문 장수 | 예측 슬라이드 | 실을 그림 |
|---|---:|---|---|
| 1 그림으로 자료 보기 | 3 | Anscombe: 요약 통계 표 → "산점도가 비슷할까" | Anscombe 2×2 (R 청크) |
| 2 기본 그래픽 | 6 | `hist(x)` 대 `barplot(x)` 막대 수, 상자그림 수염 끝 | `plot()` 세 객체 축소판, hist·barplot 나란히, 상자그림 해부(고친 라벨), UCB 학과별 모자이크 |
| 3 덧그리기와 상태 | 4 | 세 직선이 한 점에서 만날까, `mfrow = c(2, 3)` 제목 그림의 행·열 | `abline-example`, `figures/graphics-figureAnatomy1.png`, 3×2 그림 |
| 4 ggplot2 의 문법 | 6 | VC 선이 다 보일까, `aes(colour = "blue")`, 톱니 모양 | ToothGrowth 기본 그래픽 선(잘림), `figures/grammar-graphics-intro.png`, 레이어 4장면, 아시아 톱니 대 group |
| 5 geom 과 stat | 6 | `geom_bar()` 막대 높이, suv 연비 19 의 위치, 오차 막대만 비킨 그림 | `layer_data()` 표, 두 체계 상자그림 나란히, 봉우리 둘인 자료의 상자그림 대 바이올린, 어긋난 오차 막대 |
| 6 위치 조정 | 4 | iris 히스토그램 겹침 대 쌓임, mpg 점 33개 | diamonds 세 위치, iris 쌓임 → 고침 2장면, jitter 전후 |
| 7 척도, 좌표, 글자 | 6 | `ylim` 대 `coord_cartesian`, 면적 36배, 글자 32번 | mpg 상자그림 3장면, 보통 축 대 로그 축, 거품 그림 기본 대 `scale_size_area()` |
| 8 나누어 그리기와 배치 | 4 | `free_y` 패널끼리 비교해도 되나 | `facet_grid` 회색 배경, `economics_long` 패널, 테마 6종 |
| 9 그림 검증하기 | 5 | σ 표기가 맞나 | 확인 절차 표, 정규분포 곡선(이전 판), 대륙별 기대수명 단순 대 가중 |
| 10 AI와 함께 | 5 | "189개가 모두 그려졌을까" | 프롬프트 요약, AI 그림, 검증 결과 표, 보지 못한 부분 표 |
| 합계 | 49 | 예측 슬라이드 약 17 | |

**장면을 나누어 보이는 곳** (mp4 를 만들지 않는다. CLAUDE.md 슬라이드 (15) 의 `::: {.r-stack}` + `{.fragment fragment-index=k}` 방식, 장면마다 PNG):
- 4.2 레이어 쌓기 4장면: `ggplot(data, aes())` 빈 판 → `+ geom_point()` → `+ scale_x_log10()` → `+ labs()`.
- 6.2 iris 히스토그램 2장면: 기본(쌓임, 쌓인 막대 3개 표시) → `position = "identity"`.
- 7.1 mpg 상자그림 3장면: 원본 → `ylim(15, 30)` → `coord_cartesian(ylim = c(15, 30))`, 오른쪽 칸에 midsize·suv 중앙값이 장면과 함께 바뀐다.
- 노트에는 움직이는 그림을 두지 않는다.

**절 표지**(각 절): 번호, 제목, 의도 한 줄, 소절 목록, "이 절이 답하는 질문" 띠. 질문 예: 1절 "요약 통계가 같으면 그림도 같은가", 5절 "막대 높이는 누가 계산했는가", 6절 "막대 꼭대기는 무엇의 값인가", 7절 "축을 좁히면 통계량이 바뀌는가", 9절 "이 그림이 그린 것은 무엇인가".

---

## 8. 연습문제 설계

읽기 문항 R(실행하지 말고 답을 먼저 적은 뒤 확인)과 쓰기 문항 W. 읽기가 절반 가까이 되도록 한다. "이전 판 노트의 코드"는 출처 줄을 문항에 적지 않고 "이전 판 강의노트에 실려 있던 코드"라고만 밝힌다(12장 방식).

**읽기 문항**

- R1. `x <- c(4, 4, 5, 9, 9, 9, 10)` 일 때 `hist(x)` 의 막대 수와 높이, `barplot(table(x))` 의 막대 수와 높이를 적으시오. (값은 집필 워커가 실행해 확인)
- R2. (이전 판 COVID 순위 그림, 감사 A-2) 본문은 "2020년 5월 31일 기준 총 확진자 수가 2,000명 이상인 나라"라고 적었고 코드는 `group_by(location) |> filter(max(total_cases) > 1000)` 이었다. 이 차이로 "확진자 1명당 검사 수 상위 24개국" 막대그림의 위쪽 순위가 어떻게 바뀔 수 있는지 설명하시오. 그림 부제에 무엇을 적어야 하는가. (자료 없이 코드만 싣는다)
- R3. (감사 A-3) 주석은 "모분산은 안다고 가정"이고 코드는 `si <- apply(X, 2, sd); lower_ci <- mi - qnorm(1 - alpha/2) * si / sqrt(n)` 이다. 무엇이 섞였는가. n = 30 에서 이 구간이 μ 를 포함할 확률은 95% 보다 클까 작을까. 9장 '신뢰구간의 의미' 소절을 근거로 설명하시오.
- R4. (감사 B-7(6)) Anscombe 그림 코드에서 `xlab = eval(xl), ylab = yl` 이다. 두 축 이름은 각각 어떻게 찍히는가.
- R5. (감사 B-11) 대륙별 일일 확진자 막대를 `geom_col(aes(fill = continent), position = "identity", alpha = 0.3)` 으로 그렸다. 막대 꼭대기는 세계 합계인가. 합계를 보이려면 무엇을 바꾸는가.
- R6. `facet_wrap(~ variable, scale = "free_y")` 는 인수 이름이 `scales` 인데 오류 없이 동작한다. 이유는 무엇이고, 이것이 왜 위험한가. (감사 C-28)
- R7. 콘솔에서 `par(mfrow = c(2, 2)); hist(x); boxplot(x)` 를 실행한 뒤 `plot(y)` 를 실행하면 그림은 화면의 어디에 그려지는가. 이어서 `plot(z)` 를 두 번 더 실행하면?

**쓰기 문항**

- W1. 9.2 의 정규분포 곡선 코드를 고치되 표기를 바꾸는 판과 표준편차를 바꾸는 판 두 가지를 쓰고, 각 곡선의 정점 높이를 `dnorm()` 으로 계산해 그림의 글자와 대조하는 코드를 함께 쓰시오.
- W2. `mpg` 의 차급별 **시내** 연비(`cty`) 상자그림에 `ylim(10, 25)` 와 `coord_cartesian(ylim = c(10, 25))` 를 각각 적용하고, 중앙값이 바뀐 차급과 빠진 행 수를 `layer_data()` 와 경고로 보고하시오.
- W3. 이전 판 강의노트의 `warpbreaks` 기본 그래픽 막대 + 표준오차(`barplot()` + `arrows()`)와 5.5 의 ggplot2 판이 같은 평균과 표준오차를 그리는지 두 그림의 값을 꺼내 대조하시오(`barplot()` 의 반환값과 `layer_data()`).
- W4. 9.4 를 1인당 GDP 로 바꾸어 대륙별 2000~2020년 추이를 단순 평균과 인구 가중 평균 두 선으로 그리시오. GDP 가 없는 나라를 어떻게 다루었는지 부제에 적고, `check_plot_rows()` 로 행 수를 확인하시오.
- W5. `check_plot_rows()` 에 조건 하나를 더하시오: 크기 매핑이 있으면 가장 큰 점과 가장 작은 점의 면적비가 매핑한 변수의 비와 1% 안에서 같아야 한다. 7.3 의 기본 그림에서 멈추고 `scale_size_area()` 그림에서 통과하는지 보이시오.
- W6. (본인 공개 데이터, 2026 2학기 개인 프로젝트) 본인이 고른 공개 데이터로 그림 하나를 만든다. (a) 매핑 명세 표(열 → 그림 속성, 단위)를 먼저 쓰고, (b) 그림 코드를 쓰고, (c) 9.1 의 확인 절차 가운데 해당하는 항목의 확인 결과를 표로 정리하시오. AI 를 썼다면 프롬프트와 응답을 함께 제출하시오.

---

## 9. 강사 확인 항목 (2단계 설계)

`upgrade/plans/data-visualization-decisions.md` 의 "강사 확인 항목" 아래 "2단계 설계에서" 소제목으로 옮겼다(이 설계서와 같은 내용).

1. **절 구성**: 10절 + 연습문제, 소절 37개, 약 2,440줄. 기본 그래픽 두 절(2, 3절) 약 450줄. 가정: 이대로 집필.
2. **통합 사례**: COVID 대신 "대륙별 기대수명 추이(2000~2020): 단순 평균 대 인구 가중 평균"(9.4). 세계 기대수명 발표값(`gapminder-world.csv`)은 나라별 가중 계산과 2000년 1.56% 차이가 나고 원인을 확인하지 못해 대조 기준으로 쓰지 않는다. 가정: 이대로.
3. **AI 과제 프롬프트**: 2015년, "점 크기는 인구에 비례", "대륙 다섯 개"를 명세로 넣는다(검증 항목 3·5 와 직접 대응). 가정: 이대로.
4. **대륙 대응표**: 본문 `tribble()` 22행, 대륙 이름은 한국어. `dataset/ch13/` 과 생성 스크립트는 만들지 않는다. 가정: 이대로.
5. **car·vioplot 미사용**: `car::scatterplot`·`scatterplotMatrix` 는 `plot()` 산점도 행렬로, `vioplot` 은 `geom_violin()` 으로 대신한다. 가정: 빼기.
6. **경고·메시지 정책**: 문서 YAML 에서 `warning: true`, `message: true` (12장은 둘 다 false). 경고 문구를 본문 교재로 쓴다. 가정: 이대로.
7. **패키지 최소 버전**: ggplot2 4.0.0(`ink`/`paper`, `get_labs()`, 경고 문구), patchwork 1.1.0, scales 1.2.0, dplyr 1.2.0. 가정: 버전 콜아웃 하나로 안내.
8. **그림 속 한글**: 렌더 환경(리눅스, cairo png)에서 글꼴 패키지 없이 한글이 나오는 것을 확인했다. 학생 Windows·macOS 환경 안내는 넣지 않는다(결정 6 유지). 가정: 깨짐이 보고되면 그때 `ragg` 안내를 정한다.
9. **COVID 결함의 쓰임**: A-2, B-11 은 자료 없이 코드만 싣는 읽기 문항(R2, R5), B-12 는 7.4 PRIMM 의 사례 언급, A-3 은 읽기 문항 R3 과 9장 참조. 가정: 이대로.
10. **이전 판 코드의 표기**: 버그 찾기 대상 부분(예: `size = 1`, `ylab = yl`, σ 표기)은 원문 그대로, 나머지는 현행 표기로 옮기고 그 사실을 밝힌다. 가정: 12장 연습문제 8 방식.
11. **AI 응답이 미설치 패키지를 쓸 때**(`countrycode` 등): 설치하지 않고 `eval: false` 로 싣는다. 가정: 설치하지 않음. 강사가 설치를 허용하면 실행해 싣는다.
12. **부록 B**: 4.4 의 목록만 남기고 파일은 만들지 않는다(결정 4). 본문은 "부록 B(예정)"로 가리킨다. 가정: 이대로.
13. **슬라이드 분량**: 60장(표지 1, 절 표지 10, 본문 49). 가정: 이대로.

---

## 10. 집필 묶음 제안

자료 준비 청크(`gm-prepare`, 4.4)와 기준 그림(`ref_bubble_data`, 7.3)이 뒤 절에서 쓰이므로 순서대로 쓴다.

| 호출 | 범위 | 줄(약) | 주의 |
|---|---|---:|---|
| 3단계 1 | 머리, 1~3절 | 670 | 3.2 의 오류 재현은 한 청크 안에서. `par()` 를 쓰는 청크는 모두 `op`/`par(op)` |
| 3단계 2 | 4~5절 | 600 | `gm-prepare` 의 `stopifnot` 값(4137, 197, 5). 5절 도입의 `layer_data()` 와 결측 행 설명 |
| 3단계 3 | 6~8절 | 600 | 7.3 끝에 `ref_bubble_data` 남기기. jitter 시드. 8.4 는 임시 파일만 |
| 3단계 4 | 9절, 연습문제 | 350 | 9.4 의 세계 값 대조 금지. W 문항의 값은 실행해 확인 |
| 4단계 | 10절 | 220 | `student-ai` 응답을 받은 뒤. 응답에 없는 오류를 쓰지 않음 |

검수 단계가 확인할 것: 4.1 표의 "살림" 행이 모두 본문에 있는지, PRIMM 질문이 소절마다 예측 콜아웃으로 있는지, `warning: false` 가 문서 수준에 없는지, 감사 G-9 의 문장이 없는지, 슬라이드에 줄표·가운뎃점이 없는지.
