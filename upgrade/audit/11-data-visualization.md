# 감사 보고서: 11-data-visualization.Rmd (현 데이터 시각화, 공개 사이트 10장 → 새 13장 데이터 시각화)

- 감사일 2026-10-16 · R 4.6.1 · ggplot2 4.0.3 · tidyverse 2.0.0 · dplyr 1.2.1 · knitr 1.51 · rmarkdown 2.31 · 감사자 Claude (lecture-auditor) · 대상 3,903줄 / 코드 청크 167개(`eval=FALSE` 20개, `echo=FALSE` 34개, `warning=FALSE` 14개, `include_graphics` 15회)
- 공개 사이트에서는 10장이다(`docs/ch-data-visualization.html` 의 절 번호 10). 공개 페이지 5개(`ch-data-visualization.html`, `r-basic-graphics.html`, `high-level-graph.html`, `low-level-graphic.html`, `ggplot2-package.html`)는 2023-05-15 렌더본이고, 원문의 마지막 커밋은 2022-03-08(`9720612`)이다
- 실행: 저장소 **사본**에서만 실행했다. 2065–2069줄이 git 추적 파일 `figures/save-example.png` 를 다시 쓰기 때문이다. `git archive HEAD` 로 장, `dataset/gapminder/gapminder_filter.csv`, `dataset/covid-19-dataset/`, `figures/`, 실행 스크립트만 `/tmp/audit11/clone` 에 풀었다
  - `run_chunks.R 11-data-visualization.Rmd --timeout=180`: **OK 145 / ERROR 2 / EXPECTED-ERROR 0 / SKIP 20**(모두 eval=FALSE), 24초. ERROR 2건은 앞 청크가 남긴 `par()` 상태 때문이며 렌더에서는 나지 않는다(B-5)
  - deprecation 경고는 기본값에서 세션당 한 번만 나오므로 `options(lifecycle_verbosity = "warning")` 로 다시 실행했다: **17개 청크, 21줄**(B-1·B-2)
  - `rmarkdown::render(html_document(keep_md = TRUE))` 로 렌더해 메시지·경고·그림 121장을 출력 전체와 대조했다(오류 0)
  - 실행 전후 작업 트리의 `figures/save-example.png` md5 는 같다(`665049f1…`). 저장소에서 돌린 재현 스크립트(v1–v8)는 파일을 쓰지 않는다. 감사 뒤 `git status --short` 는 감사 전과 같다(미추적 `upgrade/plans/*` 4개만)
- 방법: 장 정독 → 구식 패턴 grep(코드 줄만 집계) → 청크 실행과 렌더 → 렌더 그림 열람(Anscombe, 히스토그램 한글, 모자이크, `fig-anatomy`, `mfrow`, 정규분포, `mtext`, 기본 선 그래프, `new`, COVID 2장) → 정적 그림 11개 열람 → 본문 주장을 출력과 대조하는 재현 스크립트 8개 → 외부 링크 curl(브라우저 UA, HEAD·GET) → 패키지·`dataset.zip`·배포본 대조
- 표기: **[재현]** R 4.6.1 에서 실행해 확인함 · **[추론]** 문서·코드 검토에 근거한 판단(실행으로 확인하지 않음)
- 결과: **치명 3 · 중요 20 · 경미 41**. 외부 링크 10건 중 소실 1건(Monash, 503), 다른 사이트로 넘어가는 것 1건(sthda → datanovia)
- 재현 스크립트는 저장소 밖 `/tmp/audit11/repro/`(v1–v8)에 있다(세션이 끝나면 사라질 수 있다). 핵심 코드는 I 절에 실었다
- 이 감사는 이 보고서와 `upgrade/plans/data-visualization-decisions.md` 의 "강사 확인 항목" 외의 파일을 수정하지 않았다. CLAUDE.md 진행 상태 표는 오케스트레이터 7단계(기록)에 남긴다

## 요약

현 장은 R 기본 그래픽(90–2071줄, 1,982줄)과 ggplot2(2073–3611줄, 1,539줄), COVID-19 확장 예제(3614–3893줄, 290줄)로 이루어진다. 기본 그래픽의 절반 이상이 `par()` 파라미터와 저수준 함수의 해부 그림이다. 청크는 렌더에서 모두 돌아간다. 문제는 세 갈래다.

- **그림 속 글자나 설명이 계산과 다르다(A).** 정규분포 그림은 표준편차 √2, √3 인 곡선에 `σ = 2`, `σ = 3` 을 붙였다(1469–1497). COVID 예제는 "총 확진자 2,000명 이상"이라 적고 `max(total_cases) > 1000` 으로 거른다. 그 결과 "확진자 1명당 검사 수 상위 24개국" 막대 24개 중 11개(1위 뉴질랜드 포함)가 설명대로라면 빠져야 할 나라다(3717–3723, 3855–3893). "모분산을 안다고 가정"한 신뢰구간 시뮬레이션은 표본 표준편차와 정규분위수를 섞어, 이론 포함률이 95%가 아니라 94.0%다(2829–2841). 숫자가 그럴듯해서 배포본에 그대로 실려 있다.
- **그래프가 조용히 무언가를 바꾸는데 장이 말하지 않는다(B).** `geom_histogram()` 의 기본 위치는 쌓기라서 "겹쳐 그린" 종별 밀도 히스토그램의 전체 넓이가 3이다. "인구에 비례"한다는 거품 크기는 인구 19,766배 차이를 면적 36배로 그린다. "World COVID-19 cases" 막대는 대륙을 쌓지 않고 겹쳐 그린다. 같은 장의 다른 그림 6개도 제목이나 글자가 코드와 다르다(`mfrow = c(2, 3)` 제목을 단 3×2 배치, 반올림으로 `plt = c(0, 1, 0, 1)` 이 된 해부 그림 등). `warning=FALSE` 청크 14개가 이런 신호를 가린다.
- **구식 API 와 환경 의존.** 선 굵기 `size` 18줄과 `element_line(size)` 3줄, `..density..` 2줄, `guides(size = FALSE)` 이 경고를 내고, 배포본 페이지에 경고 5종이 그대로 보인다. `coord_flip()` 은 ggplot2 4.0.3 도움말에서 Superseded 다. 그림 `r-graphic-palette.png` 는 R 4.0 이전 기본 팔레트다. `par()` 를 되돌리지 않는 청크가 많아 콘솔에서 순서대로 실행하면 1026줄과 1314줄에서 오류가 난다. 기본 그래픽의 한글 글꼴(`family = "nanumgothic"`)은 운영체제에 따라 다르게 동작한다.

재구성안의 처리 방침은 "현행화·압축. ggplot2 4.x. `par()` 전수는 부록"이고 분량 목표는 3,903 → 2,400줄이다. 이 감사는 압축과 함께 **"그림이 무엇을 계산해 그렸는지 확인한다"**(그려진 행 수, stat 이 만든 값, 위치 조정, 척도 한계, 그림 속 글자와 코드의 일치)를 장의 검증 축으로 삼기를 제안한다(G). 12장이 세운 "변환한 뒤 확인하기"를 그림으로 잇는다. 결정은 강사에게 남긴다.

---

## A. 치명: 결과가 설명과 다르고, 숫자나 그림이 그것을 가림

### A-1. 정규분포 곡선의 σ 표기가 틀림 [재현]

**줄** 1464–1466(주석), 1469–1472(계산), 1485, 1491, 1497(표기). 그림은 공개 페이지 `low-level-graphic.html` 의 `lines()` 절

```r
y <- mapply(dnorm, list(x, x, x), c(0, 0, 0), c(1, sqrt(2), sqrt(3)))   # 표준편차 1, √2, √3
expression(paste(mu == 0, "," ~~ sigma == 2))                           # 둘째 곡선 표기
expression(paste(mu == 0, "," ~~ sigma == 3))                           # 셋째 곡선 표기
```

주석(1464–1466)은 "분산 = 1, 2, 3"이라 적고 계산도 그에 맞게 표준편차 √2, √3 을 쓴다. 그런데 그림의 글자는 표준편차 기호 σ 를 써서 `σ = 2`, `σ = 3` 이라 적는다.

| 곡선 | 사용한 표준편차 | 그림 표기 | 정점 높이(실제) | σ = 표기값일 때 정점 |
|---|---|---|---|---|
| 둘째(파랑) | 1.414 | σ = 2 | 0.282 | 0.199 |
| 셋째(초록) | 1.732 | σ = 3 | 0.230 | 0.133 |

통계학과 학생은 이 그림으로 "σ = 2 인 정규분포의 모양"을 기억하게 된다. 곡선 세 개의 상대적 모양은 그럴듯해서 그림만으로는 알아채기 어렵다. **수정**: 표기를 `sigma^2 == 2`, `sigma^2 == 3` 으로 바꾸거나 표준편차를 2, 3 으로 바꾼다. 새 장에서는 **버그 찾기 문항**으로 쓴다: "둘째 곡선의 정점 높이가 0.282 다. σ = 2 라는 표기는 맞는가? `dnorm(0, 0, 2)` 와 비교하라."

### A-2. COVID 예제: 설명은 "확진자 2,000명 이상", 코드는 "1,000명 초과", 순위 그림의 11개국이 기준 밖 [재현]

**줄** 3717(설명), 3720(주석), 3723(코드), 3855–3893(순위 그림)

```r
# 5. 2020년 5월 31일 기준 총 확진자 수가 2000 명 이상인 국가만 추출      ← 3717 본문
# 각 국가별로 grouping을 한 후 total_case의 최댓값이 1000 명을 초과한 경우만 추출   ← 3720 주석
filter(max(total_cases) > 1000)                                          ← 3723 코드
```

본문, 주석, 코드가 서로 다르다. 코드대로면 114개국, 본문대로면 89개국이다. 차이 25개국(Albania, Costa Rica, Estonia, Iceland, Kenya, Latvia, Lithuania, Nepal, New Zealand, Slovakia, Slovenia, Tunisia 등)이 뒤의 그림 세 장에 모두 들어간다.

영향이 가장 큰 곳은 3855–3893 의 "확진자 1명당 검사 수 상위 24개국" 막대그림이다. 확진자가 적은 나라일수록 비율이 크므로, 기준을 1,000으로 낮추면 순위 위쪽이 바뀐다.

| 순위 | 국가 | 확진자 | 검사 수 | 검사/확진 | 본문 기준(2,000명 이상)이면 |
|---|---|---:|---:|---:|---|
| 1 | New Zealand | 1,154 | 281,609 | 244.0 | 제외 |
| 3 | Lithuania | 1,670 | 302,859 | 181.4 | 제외 |
| 5–7 | Slovakia, Ethiopia, Latvia | 1,521 / 1,063 / 1,065 | — | 113 / 103 / 102 | 제외 |
| 12–23 | Slovenia, Nepal, Tunisia, Estonia, Kenya, Iceland | 1,076–1,888 | — | 33.8–53.7 | 제외 |

24개 중 11개, 그리고 1위 막대가 본문의 기준과 맞지 않는다. 막대 높이와 라벨 숫자는 각각 옳게 계산되어 있어서 출력만으로는 알아챌 수 없다. 덧붙여 6단계 결측 대체(3728–3745)가 검사 기록이 없는 39개국(114개 중)의 `total_tests` 를 0 으로 만들고, 3864 의 `filter(total_tests_per_cases != 0)` 이 이들을 순위에서 조용히 뺀다. 그림 제목은 이 제외를 알리지 않는다.

**수정**: 기준을 하나로 정해 본문·주석·코드를 맞춘다. 그림 부제에 "검사 기록이 있는 n개국 중"을 적는다. 새 장에서는 **버그 찾기 문항**으로 쓴다: "본문은 2,000명 이상이라 했다. 그림의 1위 국가는 기준을 만족하는가? `filter(location == "New Zealand", date == max(date))` 로 확인하라."

### A-3. "모분산을 안다고 가정"한 신뢰구간이 표본 표준편차와 정규분위수를 섞음 [재현]

**줄** 2829(주석), 2838–2841(계산), 2850–2860(그림)

```r
# 각 표본에 대한 95 % 신뢰구간 계산(모분산은 안다고 가정)
si <- apply(X, 2, sd)                                   # 표본 표준편차
lower_ci <- mi - qnorm(1-alpha/2)*si/sqrt(n)            # z 분위수 × 표본 표준편차
```

모분산을 알면 `sx`(= 10)와 z 분위수를, 모르면 `si` 와 t 분위수를 써야 한다. 코드는 둘을 섞었다. n = 30 에서 이 구간의 이론 포함률은 `2*pt(qnorm(0.975), 29) - 1` = **0.9403** 이다. 2만 번 반복 시뮬레이션에서 z·s 구간 0.9411, t·s 구간 0.9505 였다. 이 장의 시드에서는 200개 중 186개(0.930)가 μ 를 포함한다(t·s 188개, σ 사용 187개).

수치 차이는 1%p 정도라 그림에서 보이지 않는다. 그러나 주석이 가정을 잘못 적은 채 공식을 가르치므로 학생이 그대로 옮겨 쓴다. 같은 장 2750 의 오차 막대 예제는 `qt()` 를 옳게 쓴다. **수정**: `qt(1 - alpha/2, n - 1) * si / sqrt(n)` 으로 바꾸고 주석을 "모분산을 모른다고 가정"으로 고친다. 새 장에서는 이 예제를 9장 `#sec-ci-meaning` 의 참조로 대체하는 안을 제안한다(G-1). 강사가 A 가 아니라 B 로 볼 수 있는 항목이다(수치 영향이 작음). 판단을 남긴다.

---

## B. 중요: 구식 API, 설명과 동작의 불일치, 학생 환경에서 실패

| # | 줄 | 문제 | 근거 | 수정 |
|---|---|---|---|---|
| B-1 | 2166, 2361, 2363, 2375, 2383, 2432, 2439, 2462, 2492, 2509, 2521, 2529, 2855, 2860, 3049, 3070, 3491, 3823 (aes 밖 `size`), 3798, 3846, 3888 (`element_line(size)`) | 선 굵기에 `size` 를 쓴다. ggplot2 3.4.0 부터 deprecated. 렌더 출력에 경고가 21번 나온다. 배포본 `ggplot2-package.html` 에도 `Using size aesthetic for lines was deprecated`, `The size argument of element_line() is deprecated` 가 실려 있다. 2286 "size: 점, 선, 텍스트의 크기 또는 굵기"도 구식 설명이다 | 재현(lifecycle_verbosity = "warning") | `linewidth`. 2286 은 "점·글자 크기는 `size`, 선 굵기는 `linewidth`"로 |
| B-2 | 3138, 3182 | `y = ..density..` (3.4.0 deprecated). 배포본에 경고 노출 | 재현 | `after_stat(density)` |
| B-3 | 3406 | `guides(size = FALSE)`. 3.3.4 부터 `"none"`. 배포본에 경고 노출. 3409 `title.theme` 은 4.0.3 에서 `guide_legend()` 의 정식 인수가 아니며 `theme` 인수로 옮겨 처리된다(경고 없음) | 재현(`formals(guide_legend)`) | `guides(size = "none", color = guide_legend(theme = theme(legend.title = element_text(face = "bold"))))` |
| B-4 | 2703, 2709, 3375, 3884 (`coord_flip`), 2145, 2154, 2648, 2653, 2702, 2708, 3786, 3818, 3874 (`geom_bar(stat = "identity")`), 2109 (`spread`), 3711, 3753 (`mutate_at`) | `coord_flip()` 은 ggplot2 4.0.3 도움말에 **Superseded** 로 표시되어 있다(가로 막대는 `aes(y = )` 로 직접 그림). `geom_bar(stat = "identity")` 는 `geom_col()` 과 같다(2599 본문도 그렇게 설명). `spread()`·`mutate_at()` 은 12장 감사 B-11 과 같은 superseded 관용구 | 재현(도움말 Rd) | `geom_col(aes(x = median, y = region))`, `pivot_wider()`, `mutate(across(...))`. 3384 의 `coord_flip` 예제는 "x·y 바꿔 매핑" 예제로 |
| B-5 | 197, 380, 512, 538, 630, 650, 753, 807, 882, 895, 1228, 1241, 1269, 1294, 1345, 1384–1390, 1416, 1467, 1570, 1780, 1992 (되돌리지 않는 `par()`/`layout()`), 1026, 1314 (오류 위치) | 그래픽 상태가 청크 밖으로 샌다. knitr 는 청크마다 장치를 새로 열어 렌더에서는 문제가 없다. 그러나 학생이 Positron·RStudio 콘솔에서 순서대로 실행하면 앞 청크의 `mfrow`·`layout()` 이 남는다. `run_chunks.R` 이 이 상황을 재현했다: 1026 `par(pin = c(5, 2))` 는 894 청크의 `mfrow = c(2, 3)` 이 남은 장치에서 `plot region too large`, 1314 `split.screen()` 은 1291 청크의 `layout()` 이 남은 장치에서 `parameter "i" in "mfg" is out of range`. 새 장치에서는 둘 다 실행된다. 본문은 `par()` 가 전역 상태라는 점을 말하지 않는다 | 재현(v7) | "그래픽 상태" 소절: `op <- par(...)` → 그린 뒤 `par(op)`, 함수 안에서는 `on.exit(par(op))`. 상태와 부수효과 개념의 교재로 쓴다(G-4) |
| B-6 | 428–431, 436–440 | (1) `r-graphic-palette.png` 는 R 4.0.0 이전 팔레트(`red`, `green3`, `blue`, `cyan`, `magenta`, `yellow`, `gray`)다. R 4.6.1 `palette()` 는 `"black" "#DF536B" "#61D04F" "#2297E6" "#28E2E5" "#CD0BBC" "#F5C710" "gray62"` 를 돌려준다 (2) 색 함수 설명 5개 중 4개가 틀렸다. `heat.colors()` 는 빨강 → 주황 → 노랑(`#FF0000` `#FF8000` `#FFFF00`), `terrain.colors()` 는 초록 → 황갈 → 밝은 회색(`#00A600` `#ECB176` `#F2F2F2`), `topo.colors()` 는 청보라 → 초록 → 노랑(`#4C00FF` `#00FF4D` `#FFFF00`)이다. 본문은 셋 다 방향이 반대이고 "White"로 시작한다. `grey(n)` 은 `grey(5)` 에서 `invalid gray level, must be in [0,1]` 오류다(n 개를 만드는 함수는 `gray.colors(n)`) (3) R 3.6 의 `hcl.colors()`, R 4.0 의 `palette.colors()` 를 다루지 않는다 | 재현(v1), 문서: https://developer.r-project.org/Blog/public/2019/11/21/a-new-palette-for-r/ | 그림을 `palette()` 출력으로 다시 만들거나 삭제. 색 함수는 실행 결과로 보인다 |
| B-7 | 1238, 1101, 1818–1820, 1554, 3107–3108, 71/78 | **그림 속 글자가 코드와 다르다(렌더 그림으로 확인).** (1) 1238 제목 "mfrow = c(2, 3)" — 코드(1229)는 `mfrow = c(3, 2)`, 그림은 3행 2열. 이 절이 가르치는 "행, 열 순서"를 거꾸로 적었다 (2) 1101 `round(op[[...]])` 에 자릿수가 없어 `fig-anatomy` 그림이 `plt = c(0, 1, 0, 1)`, `mai = c(1, 1, 1, 0)`, 새 그림의 `fig = c(0, 1, 0, 1)` 을 보인다(실제 새 `fig` 는 `c(0.4, 0.9, 0.4, 0.9)`). 같은 장 1061 은 `round(x, 2)` 다 (3) 1818–1820 `mtext` 해부 그림의 side 4 글자는 `at = 0.0, 0.5, 1.0`, 실제 `at` 은 −1, 0, 1(`adj_par` 를 찍음) (4) 1554 mpg 평균선에 `bar(x)` 표기(y 의 평균) (5) 3107–3108 `binwidth = 0.01` 그림에 제목 "binwidth = 0.05" (6) Anscombe 그림의 y축 이름이 `expression(y₁)` 으로 찍힌다(x 는 `eval(xl)`, y 는 `yl` 그대로) | 재현(렌더 그림, v1) | 각각 코드에 맞춘다. 새 장의 "그림의 글자와 코드 대조" 연습 소재로 쓴다(G-4) |
| B-8 | 691, 696–697 | 상자그림을 "다섯 통계량: 최솟값, 1사분위수, 중앙값, 3사분위수, 최댓값"으로 정의하고 해부 그림에 `min(x)`, `quantile(x, 0.25)`, `max(x)` 를 붙인다. 수염은 상자에서 1.5 IQR 안의 가장 먼 관측값까지이고 그 밖은 점(이상치)으로 그린다. 상자 경계는 `quantile()` 기본값(type 7)이 아니라 Tukey 힌지(`fivenum()`)다. 이 시드(`set.seed(20200522)`, n = 100)는 이상치가 0개라 그림의 수치가 우연히 맞는다(힌지 −0.7209 대 `quantile` −0.7204) | 재현(v1), `?boxplot.stats` | 정의를 고치고 이상치를 하나 넣은 예측 문항으로(G-4) |
| B-9 | 3126–3143, 3173–3187 | `geom_histogram()` 의 기본 위치는 `position_stack()` 이다. `alpha = 0.2` 로 겹쳐 그리려 한 종별 히스토그램이 실제로는 쌓인다(바닥이 0 이 아닌 막대 21개 중 3개, versicolor 와 virginica 가 겹치는 4.5–5.1 구간). `y = ..density..` 판(p2)은 종마다 넓이 1 인 밀도를 쌓아 **전체 넓이가 3** 이다. p4 는 쌓인 히스토그램 위에 쌓지 않은 밀도곡선을 겹쳐 겹침 구간에서 둘이 어긋난다. 제목 "Overlaying multiple histograms"(3187)와 다르다 | 재현(v3, `layer_data()`) | `position = "identity"` 를 명시하거나 `facet_wrap(~ Species)`. 예측 문항으로(G-4) |
| B-10 | 2557–2564, 3354–3358, 3401 | "점의 크기는 인구수(log10 변환)에 비례"(2557) — `scale_size()` 는 값 범위를 크기 1–6 으로 선형 대응시키고 면적은 크기의 제곱이다. 2015년 인구 최소(Dominica 71,175)와 최대(China 1,406,847,868)는 19,766배인데 그려진 면적은 36배다. log10 을 `aes()` 안에서 취해 범례 제목이 `log(population, base = 10)` 이 되고 범례 값도 로그 단위다 | 재현(v3) | `scale_size_area()` 또는 `scale_size(range = , transform = "log10")` 와 범례 단위 표기. "크기 인코딩은 무엇에 비례하는가"를 검증 항목으로 |
| B-11 | 3772–3802 | 제목 "World COVID-19 cases over time" 막대가 `position = "identity"` 라 대륙별 막대를 **겹쳐** 그린다. 막대 꼭대기는 세계 합계가 아니라 그날 가장 큰 대륙 값이다(5월 말 약 77,000 은 아메리카). 반투명 색이 섞여 범례 색과 다르게 보인다. `alpha` 를 `aes()` 안(3785)과 밖(3789)에 동시에 주었다(밖이 이김) | 재현(렌더 그림) | `position = "stack"` 이나 `facet_wrap(~ continent)`. 세계 합계와 대조하는 검증 문항으로 |
| B-12 | 3830–3838 | 한국 검사 수 그림의 총 검사 수 글자를 `geom_text(aes(x = , y = Inf, label = ...))` 로 넣어 **92행마다 한 번씩, 92번 겹쳐** 그린다. ggplot2 4.0.3 렌더에 `All aesthetics have length 1, but the data has 92 rows. Please consider using annotate()` 경고가 나온다. 같은 그림에서 5월 21–22일 `new_tests` 결측 2행이 `Removed 2 rows` 경고와 함께 빠진다(배포본에 경고 노출). 막대가 없는 날은 0 이 아니라 결측이다 | 재현(렌더) | `annotate("text", ...)`. 빈 막대의 뜻을 본문에 적는다 |
| B-13 | 3616–3617, 3621–3628, 3728–3745 | (1) "감염자 및 사망자 수 통계는 하루 단위로 업데이트" — OWID `covid-19-data` 저장소는 2026-03-24 보관 처리되었고 README 는 "last updated on 19 August 2024" 라 적는다. 자료는 2020-06-01 스냅샷이다 (2) 3621 은 `country_info.txt` 를 읽는다고 하나 코드는 `.xlsx` (3) 검사 수 결측 대체: 첫 관측이 결측이면 0, 이후는 앞 값으로 채운다. 검사 기록이 없는 39개국이 0 이 되어 3864 에서 빠진다(A-2). 49개국은 첫 행이 3월 1일이 아니다(3월 2일–5월 1일). "결측을 0 으로 바꾸는 것"의 의미를 설명하지 않는다 | 재현(v5, v6), 링크 https://github.com/owid/covid-19-data | 자료 시점과 출처 판(2020-06-01)을 명시. 결측 대체는 12장 `#sec-na-summary` 와 연결 |
| B-14 | 2542, 3643 | `gdp_cap`·`gdp_per_capita` 를 "일인당 국민소득"이라 부른다. Gapminder 값은 1인당 GDP(PPP, 2011년 불변 국제달러)이고 OWID 값도 1인당 GDP(PPP)다. GDP 와 국민총소득(GNI)은 다른 지표다. 한국 2015년 `gdp_cap` 34,178 | 재현(v2), 12장 감사 B-6 과 같은 문제 | "1인당 GDP(PPP)"와 단위를 축 제목에 |
| B-15 | 2065–2069, 3776, 8 | 렌더가 저장소와 세션을 바꾼다. (1) `png("figures/save-example.png")` 가 **git 추적 그림**을 렌더마다 다시 쓴다. 이 파일은 2020-06 부터 2023-04 까지 7번 커밋되었다(렌더 산출물이 본문 커밋에 섞임, CLAUDE.md 규칙 9 와 같은 유형). 본문은 이 그림을 표시하지 않는다 (2) `Sys.setlocale("LC_TIME", "en_US.UTF-8")` 는 세션 전체의 날짜 표기를 바꾸고 원래 값으로 돌리지 않는다. 주석 처리된 `"english"`(3775)는 Windows 용 이름이다 (3) setup 의 `rm(list = ls())` 가 호출한 쪽 객체를 지운다. 이 감사의 렌더 스크립트도 `t0` 를 잃고 `object 't0' not found` 로 끝났다 | 재현(git log, 렌더) | `tempfile(fileext = ".png")` 에 저장 후 `file.exists()`·`file.size()` 로 확인. 날짜는 `"%m-%d"` 처럼 언어와 무관한 형식. `rm(list = ls())` 삭제 |
| B-16 | 2355, 3395, 3624–3638 | 학생 환경에서 실패한다. `dataset.zip`(15파일)에는 `dataset/gapminder/gapminder_filter.csv` 와 `dataset/covid-19-dataset/` 이 없다(대신 다른 판의 `dataset/owid-covid-data.xlsx` 가 있음). `gapminder_filter.csv` 는 현 10장 1758 의 주석 처리된 코드로 만든 파일이고 생성 스크립트가 없다(12장 감사 F-2) | 재현(zip 목록) | 새 장 자료를 한 폴더(`dataset/ch13/`)에 생성 스크립트와 함께 둔다 |
| B-17 | 151, 982, 1748, 1753, 1758 (캡션 출처), 3555 | AIMS-R-users(`users.monash.edu.au/~murray/AIMS-R-users/ws/ws11.html`)는 HEAD·GET 모두 **503**. 본문과 캡션 5곳이 이 출처를 든다. 3555 의 sthda 링크는 `datanovia.com/learn/data-visualization/ggplot2/themes` 로 넘어간다(다른 사이트, 200) | 재현(curl) | 출처 표기를 "AIMS-R-users(Murray Logan), 현재 접속 불가"로 하거나 R 문서(`?par`)로 대체. 3555 는 ggplot2 공식 문서만 남긴다 |
| B-18 | 586, 601, 36 | 기본 그래픽 한글: `par(family = "nanumgothic")` 은 글꼴 이름을 운영체제에 맡긴다. 이 리눅스의 png 장치에서는 한글이 나왔으나(렌더 그림 확인), `pdf()` 장치에서는 `font family 'nanumgothic' not found in PostScript font database` 경고가 33번 났다. Windows 에서는 `windowsFonts()` 등록이 필요하다[추론]. 청크는 `warning=FALSE` 로 이를 가린다. `require(extrafont)`(36)은 로드만 하고 장 안에서 함수를 부르지 않는다 | 재현(v1) | `showtext` 0.9-8 또는 `ragg` 1.5.2(+`systemfonts`)로 한 가지 방식을 정한다(강사 확인 6). Positron 에서의 설정을 함께 적는다 |
| B-19 | 95, 101, 160 | 그래픽 장치 안내가 `windows()`/`win.graph()` 뿐이다(Windows 전용). Positron·RStudio 의 플롯 창, macOS `quartz()`, 파일 장치 `png()`/`ggsave()` 구분이 없다 | 추론 | 장치 개념은 "화면 장치와 파일 장치" 두 가지로 압축 |
| B-20 | 749, 1138, 1506–1510, 2450–2451, 3348–3349, 2370–2371 | 정의 서술 오류. (1) 749 `y ~ x + y`(y 가 양변에) → `y ~ x1 + x2` (2) 1138 mar 를 `c(bottom, left, top, left)` → `right` (3) 1510 `v`: "x축과 수직선(y축과 수평선)", 2450 "y 축에 수평" → y축과 평행 (4) 3348 `scale_shape_*` 가 "점 모양, 크기, 색"을, 3349 `scale_linetype_*` 이 "선 종류, 굵기"를 정한다고 적었다. 각각 모양과 선 종류만 정한다 (5) 2370 "전체 아시아 국가의 평균 추세선" 아래 코드(2372–2377)는 `group = country` 라 나라마다 곡선을 하나씩 그린다. `group = 1`(2380–2385)은 나라를 같은 무게로 합친 곡선이다(인구 가중이 아님, 12장 `#sec-gapminder-case` 의 단순 대 가중 평균과 같은 구조) | 재현(코드·도움말 대조) | 각 정의를 고친다. (5)는 12장과 교차 참조하는 해석 문항으로 |

---

## C. 경미: 표기·정리·렌더

| # | 줄 | 내용 | 근거 |
|---|---|---|---|
| C-1 | 7–37 | setup 보일러플레이트: `rm(list = ls())`(8, B-15), `require()`(9, 33–36), PDF 전용 `size` 훅(10, 13–17. html_document 렌더에서는 `\normalsize` 가 출력에 새어 나옴. bookdown 배포본에는 없음), 쓰지 않는 `tidy.opts`(30), 무효인 `options(linewidth = 60)`(31, CLAUDE.md 시범 전환 7번), 쓰지 않는 `extrafont` | 재현 |
| C-2 | 179, 463, 476, 488, 495, 510, 536, 566, 585, 600, 628, 641, 2138, 2638, 2666, 2686, 2741, 2764, 2780, 2798 | 청크 옵션 오타 20곳: `fig.heigh`(17), `fig.heigth`(179), `fig.widgh`(2138). knitr 가 무시해 기본 크기로 그려진다 | 재현 |
| C-3 | 2973, 3020 | `warnings=FALSE` 는 knitr 옵션이 아니다(`warning`) | 재현 |
| C-4 | 449, 472, 483 | `{.unnumbererd}` 오타 3곳. 배포본에서 이 셋만 `10.2.3.1` 처럼 번호가 붙고 형제 헤딩은 번호가 없다 | 재현(docs) |
| C-5 | 445, 2061, 3351, 3364, 3385, 3423, 3509 | 445 "주요 고수준 그래픽 함수"는 내용 없는 헤딩(바로 같은 수준의 "산점도"가 이어짐). 2061·3351·3364·3385·3423·3509 는 ID 가 없어 한글 자동 앵커(`r-기본-그래프-이미지-파일로-저장`, `guides-x-y-축-및-그래프-제목-관련`, `facets-국소-시각화-기법` 등)가 공개 URL 이 되었다(F-6) | 재현(docs) |
| C-6 | 1504, 1461 | 헤딩 "ablines()" → `abline()`(ID `ablines` 는 공개 앵커라 유지). 1461 "`line()` 함수 사용 예시" → `lines()`(`line()` 은 Tukey 저항 직선 함수) | 재현 |
| C-7 | 792, 797, 820 | "vioplot::viplot()", `install.packages(vioplot)`(따옴표 없음, 주석), 리스트에 의미 없는 `data = warpbreaks` 인수(경고 없음) | 재현 |
| C-8 | 283 | `range <- data.frame(...)` 이 `base::range` 와 같은 이름의 객체를 전역에 만든다(함수 호출은 여전히 됨) | 재현 |
| C-9 | 588–590, 603–605 | 히스토그램 x축 "온도"에 단위가 없다. `airquality$Temp` 는 화씨(56–97) | 재현 |
| C-10 | 940–946 | `par()` 표: `din` 은 읽기 전용인데 "조정"으로 적음. `mfg` 값 "= c(rows, columns)"는 위치 `c(i, j)` | 추론(`?par`) |
| C-11 | 1260, 1261 | "드려지는지", "c(1,1)은 차원과 상관 없이 맨 처음 출력한 그래프가 생성"(뜻 불명) | 추론 |
| C-12 | 1342–1356 | `new = TRUE` 예제가 상자그림 위에 축이 다른 바이올린 그림을 덮어 setosa 상자를 가린다(렌더 그림). 눈금 위치가 서로 다른 두 y축이 한 그림에 놓이는데 이를 설명하지 않는다 | 재현(렌더) |
| C-13 | 1366 | 캡션 "Outer 여백 조정 파라미터(mar = c(2, 3, 3, 1))" → `oma`(본문 1364 는 oma) | 재현 |
| C-14 | 1524 | "일변량 회귀모형" → 단순 선형회귀 | 추론 |
| C-15 | 1688 | 다각형 이름 "Star (Jewish)" → "육각별(hexagram)" | 추론 |
| C-16 | 1702, 3055 | `$Z ~ \stackrel{i.i.d}{\sim} N(0, 1)$` — 확률변수 하나에 i.i.d, 불필요한 `~` | 추론 |
| C-17 | 1737–1738 | `adj` 주석 "0=오른쪽, 0.5=가운데 정렬, 1=왼쪽 정렬 (원점 기준)" — 그림(`graphics-adjPlot.png`)과는 "글자가 놓이는 쪽"으로 읽으면 맞으나 "정렬" 용어와 반대다(adj = 0 은 왼쪽 정렬) | 재현(그림 열람) |
| C-18 | 1787, 1792, 1844, 2435, 3127, 3177 | 주석·제목과 코드 불일치: "line=0, 1, 2, 3"(루프 0:4), "side = 3 (top)"(코드 side = 1), legend 절 그림 제목 "points() function example 2", linetype 청크 주석 "실린더 개수에 따라 점 모양", "변수: Sepal Length"(코드 Petal.Length), p3 제목이 p2 와 같음 | 재현 |
| C-19 | 2215, 2281, 2288 | `ggplot(data = car, ...)` → `cars`, 괄호 누락. 2288 linetype 이 참조하는 그림은 `fig:plot-symbol` 이 아니라 `fig:plot-linetype` | 재현 |
| C-20 | 2625, 2633 | 그림 제목 p1/p2 가 서로 바뀜("p2: Barplot via geom_bar()" 가 p1) | 재현 |
| C-21 | 2731, 2734 | "xmin (ymax)" → xmax, "짖어" → 지정 | 재현 |
| C-22 | 2757 | "오차 막대 도표 (디폴트) 오차 범위는 95 % 신뢰구간" — `geom_errorbar()` 에 기본 범위는 없다. 범위는 넘겨준 `ymin`/`ymax` 다 | 추론 |
| C-23 | 2582, 2588, 3257, 3269 | jitter 에 시드가 없어 렌더마다 그림이 바뀐다 | 재현 |
| C-24 | 3039–3051 | 한국 1인당 GDP 에 근거 없는 ±5,000 띠(`geom_ribbon`)를 그린다. 신뢰대처럼 보이나 아무것도 나타내지 않는다 | 재현 |
| C-25 | 3061–3063 | `df_norm %>% filter(idx)` 가 전역 벡터 `idx` 에 기댄다. 행 순서가 바뀌면 조용히 어긋난다 | 추론 |
| C-26 | 3157 | `adjust`: "커널 함수의 복잡도" → 대역폭 배수(클수록 매끈) | 추론(`?geom_density`) |
| C-27 | 3283–3288, 3297 | "generalized addictive model" → additive. `geom_smooth()` 기본 방법은 관측 1,000개 미만 loess, 이상 gam 인데(도움말), diamonds(53,940행) p1 이 gam 임을 본문이 말하지 않는다(렌더 메시지 `using method = 'gam'`) | 재현 |
| C-28 | 3423, 3440–3444, 3493 | "국소 시각화 기법" → 작은 다중 그림(small multiples). 원형 블록의 `scale:` 과 코드 3493 의 `scale = "free_y"` 는 인수 이름 `scales` 의 부분 일치로 동작한다(`facet_wrap()` 에 `...` 없음, 경고 없음) | 재현(v3) |
| C-29 | 3505 | "ggubr::ggarrange()" → ggpubr. "가장 사용하기 용이"는 근거 없음. 장 전체가 `ggarrange()` 14회에 기대고 `gridExtra` 는 로드만 함(0회) | 재현 |
| C-30 | 3605, 3609 | 굵은 글씨 닫는 `**` 누락. "ggtheme" → ggthemes | 재현 |
| C-31 | 3641–3666 | 코드북 표: 열 이름 오타 `Varialbe`(3645, 출력에 보임), "구내 세수시설 설치 비율"(`handwashing_facilities`), 설명을 위치로 붙임(지금은 순서가 맞음, v5) | 재현 |
| C-32 | 3690, 3720 | 주석 "siso_code", "1000 명을 초과"(A-2) | 재현 |
| C-33 | 3869–3871, 3878–3881 | `factor(levels = unique())` 뒤 `reorder(location, desc(location))` 로 순서를 두 번 뒤집는다(결과는 맞음). `limits = c(0, 300)` 은 300 을 넘는 나라를 경고만 남기고 빼는데 청크가 `warning=FALSE` 다(지금 최댓값 244 라 빠진 막대 없음). 막대 24개에 24색을 주지만 색이 아무 변수도 나타내지 않는다 | 재현(v6) |
| C-34 | 3482–3489 | `economics_long` 변수 이름을 `labels` 위치로 붙인다. 지금은 `unique()` 순서(pce, pop, psavert, uempmed, unemploy)와 맞다. 순서가 바뀌면 조용히 틀린다. "thausand" | 재현(v3) |
| C-35 | 2083 | "2005년 Hadley Wickham이 개발 및 배포" — CRAN 첫 판은 0.5.1, 2007-06-10 | 재현(CRAN Archive) |
| C-36 | 58 | 캡션의 `goo.gl` 단축 주소. 지금은 Wikimedia 파일 페이지로 넘어간다. 원 주소로 바꾼다 | 재현(curl) |
| C-37 | 2203, 2192–2213 외 | 오탈자: "학습힌다"(46), ", ,"(155), "demend"(309), "pair()"(485), "평군"(639), "설졍"(706), "goodness-of-test"(861), "Muptiple"(1238, 1250), "dsip"(1304), "sementic"(2087), "asthetic"(2192, 2193, 2208, 2213, 2261), "덧붙혀"(2203), "yintecept"(2451), "Addling"(2522), "positon"(2610, 2614, 2735, 2736), "페미리"·"위지 초정"(2878, 2881), "갖을"(2943), "csae"(3027), "Contient"(3408, 그림 범례 제목에 보임), "overrride"(3390), "존제"(3425), "페널"(3443, 3444), "파레트"(3342), "메뉴얼"(3555, 3607), "diamond"(3214) | 재현 |
| C-38 | 3088, 3151, 3197, 3283 | `-\`geom_...\`` 처럼 대시 뒤 공백이 없어 목록이 되지 않는다 | 재현(렌더) |
| C-39 | 874 | "버클리 주립대 대학원" → UC Berkeley(캘리포니아대학교 버클리) | 추론 |
| C-40 | 819–822, 2492 | 리스트 바이올린 그림의 `col = rainbow(4)`, `geom_path(size = 4)` 처럼 정보 없이 눈에 띄는 설정 | 추론 |
| C-41 | 85–87, 55, 917, 924, 1870, 2083, 2196, 3246, 3505 | 멋 부린 표현과 근거 없는 주장(CLAUDE.md 작업 규칙 11). 목록과 고쳐 쓰기 예는 G-9 | 재현(grep) |

---

## D. 외부 링크·로컬 자원·패키지·배포본

**외부 링크** (브라우저 UA, HEAD·GET)

| 줄 | URL | 상태 | 조치 |
|---|---|---|---|
| 58 (캡션) | `https://goo.gl/Ugv3Cz` | 200, `commons.wikimedia.org/wiki/File:Anscombe's_quartet_3.svg` 로 이동 | 원 주소로 교체, 또는 `https://en.wikipedia.org/wiki/Anscombe%27s_quartet`(200) |
| 151 | `http://users.monash.edu.au/~murray/AIMS-R-users/ws/ws11.html` | **503**(https 로 넘어간 뒤 HEAD·GET 모두) | 출처 표기만 남기거나 `?par` 로 대체 |
| 442 | `https://rstudio-pubs-static.s3.amazonaws.com/3486_…html` | 200 (4.6 MB) | R 색 이름 표. `colors()` 로 대체 가능 |
| 989 | `http://rstudio-pubs-static.s3.amazonaws.com/315576_…html` | 200 (2.4 MB) | 부록 B 의 출처 |
| 2948 (캡션) | `https://ggplot2.tidyverse.org/articles/ggplot2-specs.html` | 200 | 유지 |
| 3555 | `https://ggplot2.tidyverse.org/reference/theme.html` | 200 | 유지 |
| 3555 | `http://www.sthda.com/english/wiki/ggplot2-themes-and-background-colors-the-3-elements` | 200, `www.datanovia.com/learn/data-visualization/ggplot2/themes` 로 이동(다른 사이트) | 삭제 |
| 3607 | `https://ggplot2.tidyverse.org/reference/index.html` | 200 | 유지 |
| 3608 | `http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html` | 200 (https 로 이동) | https 로 |
| 3616 | `https://ourworldindata.org/` | 200 | 자료 판 명시(B-13) |
| 추가 제안 | `https://r4ds.hadley.nz/data-visualize.html`, `https://r4ds.hadley.nz/communication.html`, `https://ggplot2-book.org/`, `https://clauswilke.com/dataviz/`, `https://socviz.co/`, `https://patchwork.data-imaginist.com/`, `https://ggplot2.tidyverse.org/news/index.html`, `https://tidyverse.org/blog/2025/09/ggplot2-4-0-0/`, `https://developer.r-project.org/Blog/public/2019/11/21/a-new-palette-for-r/`, `https://stat.ethz.ch/R-manual/R-devel/library/grDevices/html/plotmath.html`, `https://www.gapminder.org/data/` | 모두 200 | 새 장의 출처로 |

**그림 자원** — 참조 15개 모두 존재. 모두 열어 확인했다.

| 줄 | 파일 | 크기 | 확인 결과 | 새 장 |
|---|---|---|---|---|
| 431 | `figures/r-graphic-palette.png` | 675×70 | R 4.0 이전 팔레트(B-6) | 버림 또는 재생성 |
| 983–984 | `figures/graphics-figureAnatomy1.png`, `…2.png` | 350×285 | 장치·figure·plot 영역과 여백 이름. 오류 없음. 출처 AIMS(B-17) | 1은 본문, 2는 부록 B |
| 1749, 1754, 1759 | `figures/graphics-adjPlot.png`, `graphics-posPlot.png`, `graphics-srtPlot.png` | 450×300/112/150 | `adj`·`pos`·`srt` 위치. 오류 없음(C-17 용어만) | 부록 B |
| 1879–1885 | `figures/expression-table-01.png` ~ `05.png` | 785×754 | `demo(plotmath)` 표의 화면 캡처. 01 확인, 표기 오류 없음 | 부록 B 또는 `demo(plotmath)` 안내로 대체 |
| 1893 | `figures/greek-letters.png` | 1361×774 | 그리스 문자 24쌍. 오류 없음 | 부록 B |
| 2058 | `figures/math-example.png` | 975×724 | 정규·이항분포, 행렬, 회귀식 수식. 오류 없음. `eval=FALSE` 코드(2013–2053)의 결과 | 부록 B |
| 2094 | `figures/grammar-graphics-intro.png` | 1942×598 | 자료 → 매핑+geom → 좌표계 → 그림 개략도. 점의 색(성별)과 위치 순서가 표의 값과 맞음 | **본문 유지** |
| 3021 | `figures/ggplot-text-math.png` | 2928×1740 | `geom_text()` 수식. 원 코드(2973–3011, eval=FALSE)는 ggplot2 4.0.3 에서 실행된다(v4) | 부록 B |
| 2067 (쓰기) | `figures/save-example.png` | 480×480 | 렌더가 다시 쓰는 추적 파일(B-15). 본문에 표시하지 않음 | 버림(임시 파일로) |

**자료**

| 줄 | 파일 | 형식·크기 | 비고 |
|---|---|---|---|
| 2355, 3395 | `dataset/gapminder/gapminder_filter.csv` | 13,159행 × 7열, 1950–2020, 22개 지역 | `life_expectancy` 결측 16. `gdp_cap` 은 1인당 GDP(PPP). 지역 이름이 미리 손질되어(`Melanesia Oceania`, `Caribbean America`) 2544·3397 의 정규식 `gsub("(.+\\s)", "", region)` 이 5개 대륙을 만든다. 손질하지 않은 이름(예: `Australia and New Zealand`)이면 조용히 틀린다. 생성 스크립트 없음, zip 없음(B-16) |
| 3624 | `dataset/covid-19-dataset/covid19-cases-20200601.txt` | 21,816행 × 9열, 2019-12-31 – 2020-06-04 | `iso_code` 에 `OWID_WRL` 과 `NA` 가 있다. 3월 1일–5월 31일 필터 뒤 `NA` 0행 |
| 3626 | `…/country_info.xlsx` | 210행 × 10열 | `iso_code` 중복 0. 결합 뒤 `location`·`region` 결측 0 |
| 3627 | `…/country_pubhealth.csv` | 212행 × 7열 | `location` 으로 결합(이름 결합). 짝 없는 나라 0, 중복 0 |
| 3638 | `…/owid_covid_codebook.xlsx` | — | 읽고 쓰지 않음 |
| — | 내장 자료 | `mtcars`, `iris`, `airquality`, `BOD`, `cars`, `warpbreaks`, `Titanic`, `UCBAdmissions`, `anscombe`, `ToothGrowth`, `ggplot2::mpg`·`diamonds`·`economics_long` | 모두 결측 없음(airquality 의 Ozone·Solar.R 제외, 이 장은 Temp 만 씀) |

**개인정보 의심 파일**: `dataset/students.txt`, `dataset/room-allocation.txt`, `dataset/StudentList.xls`, `data/stat-students.xlsx` 는 이 장에서 쓰지 않는다(grep 확인). 이 감사에서도 열지 않았다.

**패키지** (설치·CRAN 확인)

| 패키지 | 줄 | 설치 / CRAN | 비고 |
|---|---|---|---|
| ggplot2 · tidyverse · dplyr | 33, 2139 | 4.0.3 · 2.0.0 · 1.2.1 (CRAN 동일) | B-1~B-4 |
| car | 457, 465, 490, 497 | 3.1-5 / 3.1-5 | `scatterplotMatrix(iris)` 가 Species(요인)를 수치로 다뤄 loess 경고 80건(렌더 출력에는 나오지 않음) |
| vioplot | 810–822, 1317, 1351 | 0.5.1 / 0.5.1 | — |
| ggpubr · gridExtra | 2639, 2640 | 1.0.0 · 2.3.1 | `ggarrange()` 14회. gridExtra 0회 |
| kableExtra · knitr · rmarkdown | 35, 9, 34 | 1.4.1 · 1.51 · 2.31 (CRAN knitr 1.52, rmarkdown 2.32) | — |
| extrafont | 36 | 0.20 / 0.20 | 로드만 함(B-18) |
| RColorBrewer · readxl | 3859, 3626 | 1.1-3 · 1.5.0 (CRAN 1.5.0.1) | — |
| vcd | 839 (주석) | 1.4-14 | 쓰지 않음 |
| 새 장 후보 | — | patchwork 1.3.2 · scales 1.4.0 · ggrepel 0.9.8 · viridisLite 0.4.3 · showtext 0.9-8 · ragg 1.5.2 · systemfonts 1.3.2 · palmerpenguins 0.1.1 · gapminder 1.0.1 | 모두 설치·CRAN 확인 |

**배포본 상태**: 공개 페이지 5개는 2023-05-15 렌더본이다. `ggplot2-package.html` 에 경고 5종(`size` aesthetic, `..density..`, `guides(FALSE)`, `element_line(size)`, `Removed 2 rows`)이 실려 있다. A-1·A-2·A-3, B-7 의 그림이 모두 배포 중이다.

---

## E. 실행 로그와 구식 API

**실행 요약** (R 4.6.1, 사본)

```
== run_chunks.R --timeout=180: OK 145 / ERROR 2 / EXPECTED-ERROR 0 / NO-ERROR? 0 / SKIP 20   (24초)
  45    999 (이름 없음)  ERROR  plot region too large                     ← B-5: 894 청크의 mfrow 가 남은 장치. 새 장치에서는 실행됨
  52   1313 (이름 없음)  ERROR  parameter "i" in "mfg" is out of range    ← B-5: 1291 청크의 layout() 이 남은 장치. 새 장치에서는 실행됨
  경고 건수: 488 scatterplotMatrix 80건(loess), 585/600/615 글꼴 29/44/56건(pdf 장치), 1142 2건, 3393 1건(guides FALSE)
== lifecycle_verbosity = "warning" 재실행: deprecation 경고 청크 17개
   2161, 2352, 2369, 2424, 2454, 2488, 2502, 2515, 2824, 3039, 3057, 3479, 3811 : size aesthetic for lines
   3146, 3191 : ..density..
   3774, 3811, 3858 : element_line(size)
== rmarkdown::render(html_document(keep_md = TRUE)): 오류 0, 그림 121장
   경고: size aesthetic 16회, ..density.. 2회, guides(FALSE) 1회, element_line(size) 2회,
         geom_text "All aesthetics have length 1, but the data has 92 rows" 1회(3830), Removed 2 rows 1회(3817)
   메시지: summarise() regroup 4회(2105, 2747, 2804, 3780) · stat_bin bins = 30 2회 · geom_smooth gam 3회, lm 1회
           · read_csv 열 명세 1회(2355) · Loading required package: RColorBrewer(3859)
```

- 기본값에서는 lifecycle 경고가 세션당 한 번만 나와 `run_chunks.R` 이 3개 청크만 보고했다. 장 전체를 감사할 때는 `options(lifecycle_verbosity = "warning")` 을 함께 준다(다른 장 감사에도 해당).
- `warning=FALSE` 청크 14개(58, 585, 600, 615, 628, 641, 668, 693, 752, 796, 3102, 3623, 3637, 3858)는 렌더에서도 경고를 숨긴다. 3858 은 `limits` 로 막대가 빠져도 알리지 않는 구조다(C-33).
- `eval=FALSE` 20개 중 실행 가능한 코드는 2013(수식 그림), 2249(`ggplot-begin`), 2973(ggplot 수식)이다. 2249 는 기본 문법 첫 예제인데 결과 그림이 없다. 2973 은 4.0.3 에서 실행됨을 확인했다(v4).

**구식·권장 대체** (코드 줄 기준. 동작 차이는 실행해 확인)

| 줄 | 현재 | 대체 | 동작 차이 |
|---|---|---|---|
| B-1 의 21줄 | `size = ` (선), `element_line(size = )` | `linewidth = ` | 값은 같다. 경고만 사라진다 |
| 3138, 3182 | `..density..` | `after_stat(density)` | 없음 |
| 3406 | `guides(size = FALSE)` | `guides(size = "none")` | 없음 |
| 3409 | `guide_legend(title.theme = )` | `guide_legend(theme = theme(legend.title = ))` | 없음(4.0.3 이 내부에서 옮김) |
| 2703, 2709, 3375, 3884 | `coord_flip()` | `aes(x = 값, y = 범주)` | 가로 막대·상자그림은 같다. `geom_text(hjust = )` 처럼 방향에 기대는 설정은 다시 확인 |
| 9곳(B-4) | `geom_bar(stat = "identity")` | `geom_col()` | 없음 |
| 2109 | `spread(supp, mean)` | `pivot_wider(names_from = supp, values_from = mean)` | spread 는 행을 정렬, pivot_wider 는 처음 나온 순서(12장 감사 E) |
| 3711, 3753 | `mutate_at(vars(matches(...)), list(per_million = ~ ...))` | `mutate(across(matches(...), \(x) x / population * 1e6, .names = "{.col}_per_million"))` | 새 열 이름 규칙이 `.names` 로 바뀜 |
| 2639–2642 외 14회 | `ggpubr::ggarrange()` | `patchwork`(`p1 + p2`, `p1 / p2`) | 범례 공유 방식이 다름(`plot_layout(guides = "collect")`) |
| 3014 (주석) | `ggsave()` 미사용 | `ggsave(path, plot, width, height, dpi)` | 크기 단위 기본값이 인치. 저장한 그림은 다시 열어 확인 |
| 9, 33–36, 2139, 2639, 2640, 3859 | `require()` | `library()` | 없으면 경고 대신 오류 |
| 82곳 | `%>%` | 새 코드는 `\|>` | `%>% ungroup`·`%>% factor`·`as.matrix` 처럼 괄호 없는 오른쪽이 8곳(2111, 2546, 3398, 3702, 3743, 3778, 3781, 3815) — `\|>` 로 기계 치환하면 파싱 오류 |
| 2544, 3397, 3701 | `gsub("(.+\\s)", "", region)` 로 대륙 만들기 | 지역-대륙 대응표를 `left_join()` | 지금 자료에서는 결과가 같다. 표는 짝 없는 지역을 `anti_join()` 으로 확인할 수 있다 |

**자료·환경이 가린 오류**

| 항목 | 무엇이 가렸나 |
|---|---|
| A-1 σ 표기 | 세 곡선의 상대적 모양이 그럴듯함 |
| A-2 확진자 기준 | 막대 높이와 라벨 숫자는 각각 옳음. 순위 그림에 기준을 적지 않음 |
| A-3 신뢰구간 | 포함률 차이 1%p 가 시뮬레이션 변동에 묻힘 |
| B-5 `par()` 상태 | knitr 가 청크마다 장치를 새로 엶 |
| B-8 상자그림 정의 | 시드가 이상치 0개인 표본을 만듦 |
| B-9 히스토그램 쌓기 | 세 종의 꽃잎 길이가 거의 겹치지 않음(겹치는 막대 3개) |
| B-11 겹친 막대 | 반투명 색이 섞여 겹침이 쌓임처럼 보임 |
| C-33 `limits` | 지금 최댓값(244)이 한계(300) 안에 있음 |
| C-34 위치로 붙인 라벨 | 지금 `unique()` 순서가 라벨 순서와 같음 |
| 대륙 정규식 | `gapminder_filter.csv`·`country_info.xlsx` 의 지역 이름이 미리 손질됨 |

---

## F. 다른 장으로 번지는 문제

1. **12장(데이터 핸들링)과 자료가 갈린다.** 현 장은 `dataset/gapminder/gapminder_filter.csv`(1950–2020, 생성 스크립트 없음)를, 새 12장은 `dataset/ch12/gapminder-*.csv`(2000–2020, `make-gapminder-data.R`)를 쓴다. 기대수명 추세선(2352–2385, 1950년부터)을 살리려면 12장 추출 스크립트를 넓히거나 13장 자료 스크립트를 따로 둔다(강사 확인 3). 지표 이름은 12장과 같게 "1인당 GDP(PPP, 2011년 불변 국제달러)"로 맞춘다.
2. **9장(시뮬레이션)과 중복.** 2822–2860 의 신뢰구간 시뮬레이션은 9장 `#sec-ci-meaning` 과 같은 주제다. A-3 을 고쳐 살리기보다 9장 그림을 참조하고 13장은 `geom_linerange()`/`geom_pointrange()` 사용법만 남기는 안을 제안한다.
3. **12장의 단순 평균 대 가중 평균.** `geom_smooth(aes(group = 1))`(2380)은 나라를 같은 무게로 합친 곡선이다. 12장 `#sec-gapminder-case` 의 결론과 이어지는 해석 문항으로 쓴다(B-20).
4. **14장(기초통계 분석, 현 12장)** 이 Q-Q 그림·상자그림을 쓴다. 상자그림 정의(B-8)를 13장에서 바로잡고 14장이 참조한다.
5. **`figures/save-example.png` 재작성**(B-15)은 렌더할 때마다 추적 파일을 바꾼다. 현 장을 다시 렌더하기 전에 2065–2069 청크를 `eval=FALSE` 로 두거나 임시 파일로 바꾼다. `output/`·`pulse.feather` 문제(09·10 감사)와 같은 유형이다.
6. **이 장의 공개 URL**(legacy 보존 대상): `ch-data-visualization.html`, `r-basic-graphics.html`, `high-level-graph.html`, `low-level-graphic.html`, `ggplot2-package.html`. 앵커는 `#plot-fun`, `#scatter-plot`, `#histogram`, `#bar-plot`, `#boxplot`, `#violin-plot`, `#mosaicplot`, `#par`, `#pin`, `#fin`, `#fig-par`, `#mar`, `#mfrow-mfcol`, `#mfg`, `#new`, `#oma`, `#points`, `#lines`, `#ablines`, `#arrows`, `#rect`, `#polygon`, `#text`, `#legend`, `#math-expression`, `#basic-grammar`, `#geom-lines` … `#geom-statistics`, `#scale-x-y`, `#scale-colors-fill`, `#scale-size-line-shape`, `#theme-complete`, `#ggplot-application`, `#covid-19-visualization` 와 자동 생성 한글 앵커 5개(C-5).
7. **허브**: `hub/index.html` 651·665 줄이 현행 노트를 "10장 데이터 시각화"로 연결한다. 새 13장 공개 뒤 함께 바꾼다.
8. **감사 절차**: lifecycle 경고가 세션당 한 번만 나오는 점은 `check-chapter` 스킬의 한계다. `run_chunks.R` 에 `options(lifecycle_verbosity = "warning")` 을 기본으로 넣을지 검토한다(이 감사는 스크립트를 고치지 않았다).

---

## G. 새 장 재구성 제안 (새 13장 데이터 시각화)

재구성안 5절의 처리는 "현행화·압축. ggplot2 4.x. `par()` 전수는 부록 B", 분량 목표는 3,903 → 2,400줄이다. 이 감사는 압축의 기준을 "그림을 읽고 확인하는 데 필요한가"로 잡기를 제안한다. AI 는 `ggplot()` 코드를 즉시 써 준다. 그러나 막대가 쌓였는지 겹쳤는지, 경고와 함께 빠진 행이 있는지, 점 크기가 무엇에 비례하는지, 제목과 계산이 맞는지는 학생이 확인해야 한다. A-1·A-2 와 B-7 이 보여 주듯 사람이 쓴 그림도 마찬가지다.

### G-1. 절별 처리

| 현 절 (줄) | 처리 | 목표 줄 | 이유 |
|---|---|---:|---|
| 도입·Anscombe (40–88) | 유지·재작성 | 80 | 평균·표준편차가 같은 네 자료(v1: x 평균 9.0, y 평균 7.5, sd 3.32/2.03)를 먼저 숫자로 보이고 그림을 예측하게 한다. y축 표기 버그(B-7) 수정. 87·86 의 근거 없는 주장 삭제(G-9) |
| 그래픽 장치·구조 (90–167) | 압축 | 60 | 화면 장치와 파일 장치 두 가지(B-19). `r-graphic-layout` 그림과 `graphics-figureAnatomy1.png` 로 영역 이름만 |
| 고수준 함수 (169–912, 744줄) | 압축 | 300 | `plot()` 이 클래스마다 다른 그림을 그린다(190 `plot(lm)`, 203 `plot(Titanic)`), `type`, `hist()` 의 구간(615), `hist()` 대 `barplot()`(628, 예측 문항), 막대+표준오차(641, 668), 상자그림 해부(정의 수정, B-8), 모자이크(UCBAdmissions, 877–911, 심슨 역설). car:: 4개 청크는 1개로, `matplot` 은 축소 |
| 저수준 함수 (914–2071, 1,158줄) | 본문 축소 + **부록 B 이동** | 200 | 본문은 "그림 위에 덧그리기" 예제 둘로 `points/lines/abline/text/legend/polygon` 을 함께 보인다: `abline-example`(1512, 회귀선과 잔차)과 `polygon-example`(1704, 확률 면적). `par()` 는 "그래픽 상태" 소절로(B-5). `pin/fin/fig/mar/mfg/new/oma` 해부(999–1405), `arrows/rect` 해부, `mtext` 해부, 수식 표·그리스 문자·`math-example` 은 부록 B |
| 이미지 저장 (2061–2071) | ggplot 저장과 합침 | 30 | `png()`/`ggsave()` 를 임시 파일에 저장하고 크기·해상도를 확인(B-15) |
| ggplot2 도입 (2073–2172) | 유지 | 120 | ToothGrowth 로 기본 그래픽과 ggplot 을 대조. 기본 선 그래프가 VC 선을 y < 13 에서 잘라 그리는 그림(2128–2134)을 예측 문항으로 |
| 기본 문법·aesthetics (2174–2443) | 재구성 | 250 | 매핑(aes 안)과 설정(aes 밖)의 차이, `group`(2361 톱니 그림 예측), `size` 와 `linewidth`. 4.0 의 `ink`/`paper`·`element_geom()` 은 한 문단 |
| geoms (2445–3330, 886줄) | 압축·재배열 | 450 | 막대(`geom_bar` 의 `stat_count` 대 `geom_col`), 히스토그램(구간, **기본 쌓기**, B-9), 밀도, 상자그림+jitter(3248–3280, `outlier.shape = NA` 와 `reorder()`), 산점도와 jitter(2569–2590), 선과 경로, 오차 막대(2741–2793, 위치 맞추기), `geom_smooth()` 기본 방법(C-27), 글자(`check_overlap`, `annotate()`). `geom_ribbon` ±5000(C-24)과 수식 글자(2968–3022)는 삭제·부록 |
| scales·coord·guides (3332–3419, 88줄) | **강화** | 200 | 지금은 예제가 거의 없다. 로그 축(Gapminder 1인당 GDP), 색 척도(이산·연속, `scale_*_viridis_*`, 색각 이상 고려), 크기 척도(`scale_size_area()`, B-10), **척도 한계 대 `coord_cartesian()`**(G-5 의 4), `labs()` 와 단위, `guides(... = "none")` |
| facets (3423–3507) | 유지 | 100 | 회색 배경 점 기법(3465–3475)과 `facet_wrap(scales = "free_y")`(3479–3501) |
| themes (3509–3611) | 압축 | 60 | 테마 6종 비교 그림 1장(3570–3600). 요소 목록은 부록 B |
| COVID-19 확장 (3614–3893, 290줄) | 재구성 또는 교체(강사 확인 2) | 200 | 유지하면 "그래프 검증 통합 사례"로: 기준 불일치(A-2), 겹친 막대(B-11), 92번 겹친 글자(B-12), 결측 막대, 0 으로 대체 후 제외(B-13)를 학생이 찾게 한다. 교체하면 12장 Gapminder 통합 사례를 그림으로 잇는다 |
| (신설) 그래프 검증하기 | 신설 | 150 | G-5 |
| (신설) AI와 함께 | 신설 | 220 | G-6 |
| (신설) 연습문제 | 신설 | 100 | 읽기 문항을 절반으로(G-4 변형) |
| 합계 | | 약 2,520 | 목표 2,400 보다 120줄 많다. 기본 그래픽 고수준 절(300)과 geoms(450)에서 줄일 여지가 있다 |

### G-2. 살릴 예제와 그림 (파일 경로, 줄)

- **정적 그림(본문)**: `figures/grammar-graphics-intro.png`(2094), `figures/graphics-figureAnatomy1.png`(983)
- **정적 그림(부록 B)**: `figures/graphics-figureAnatomy2.png`(984), `figures/graphics-adjPlot.png`·`graphics-posPlot.png`·`graphics-srtPlot.png`(1749–1759), `figures/expression-table-01~05.png`(1879–1885), `figures/greek-letters.png`(1893), `figures/math-example.png`(2058), `figures/ggplot-text-math.png`(3021)
- **R 청크(기본 그래픽)**: Anscombe(58), `r-graphic-layout`(111), `plot(mod)` 진단 그림(190), `type`(251), `plot-linetype`(329)·`plot-symbol`(355)(ggplot 의 `linetype`·`shape` 와 공유), 구간 수 비교(615), `hist()` 대 `barplot()`(628), warpbreaks 막대와 표준오차(641, 668)와 같은 그림의 ggplot 판(2798), 상자그림 해부(693, 정의 수정), Titanic 모자이크(838), UCBAdmissions(877, 894), `abline-example`(1512), `polygon-example`(1704), `legend()`(1840)
- **R 청크(ggplot2)**: ToothGrowth 대조(2101–2166), 톱니 그림과 `group`(2352–2364), `geom_smooth` 의 `group`(2369–2385), mpg jitter(2569–2590), 막대 정렬 `reorder()`(2693–2716), 오차 막대 세 단계(2741–2793), `check_overlap`(2892–2932), 히스토그램 구간(3102–3121), 종별 히스토그램·밀도(3126–3194, 쌓기 교재), 상자그림+jitter(3248–3280), `geom_smooth` 네 가지(3291–3328), `facet_grid` 회색 배경(3465–3475), `economics_long` `facet_wrap`(3479–3501), 테마 비교(3570–3600)
- **자료**: 내장 자료 전부, Gapminder(F-1), COVID 는 강사 결정 후

### G-3. 버리거나 옮길 것

| 대상 (줄) | 처리 | 이유 |
|---|---|---|
| `r-graphic-palette.png`(431), 색 함수 설명(436–440) | 버림 → `palette()`·`hcl.colors()` 실행 결과로 | R 4.0 이전 팔레트, 설명 4/5 오류(B-6) |
| car:: 산점도 4개 청크(453–504) | 1개로 | 같은 내용 반복. `scatterplotMatrix(iris)` 는 요인 열로 loess 경고 80건 |
| `pin`/`fin`/`fig`/`mar`/`oma` 해부(995–1405), `mfg`(1257–1285), `split.screen`(1309–1332), `new`(1336–1357) | 부록 B | 재구성안의 "`par()` 전수는 부록". 해부 그림의 표기 오류(B-7) 수정 후 이동 |
| `arrows`·`rect`·도형(1561–1699), `mtext` 해부(1779) | 부록 B | 타이핑 성격. AI 가 대신하는 부분 |
| 수식 표현(1862–2059), ggplot 수식(2968–3022) | 부록 B | 같은 이유. 코드는 4.0.3 에서 실행됨 |
| `geom_ribbon` ±5,000(3039–3051) | 삭제 | 아무것도 나타내지 않는 띠(C-24). 대신 예측구간이나 분위수 띠를 보인다 |
| `save-graph`(2065–2069) | 임시 파일로 | 추적 파일 재작성(B-15) |
| COVID 코드북 표 3개(3637–3667) | 삭제 또는 `glimpse()` | 12장 감사 G-1 과 같은 이유 |
| 신뢰구간 시뮬레이션(2822–2860) | 9장 참조 | 중복과 A-3 |
| `ggarrange()` 14회 | `patchwork` | 현행 표준 |

### G-4. 교재로 쓸 버그와 예측(PRIMM) 문항: 모두 이 감사에서 실제 결과를 확인함

- **버그 찾기(A-1)**: 둘째 곡선 정점 0.282. `σ = 2` 인 정규분포의 정점은? → `dnorm(0, 0, 2)` = 0.199. 코드는 표준편차 √2
- **버그 찾기(A-2)**: 본문은 "확진자 2,000명 이상". 순위 1위 New Zealand 의 확진자는? → 1,154. 24개 중 기준 밖 11개
- **버그 찾기(A-3)**: "모분산을 안다"면서 쓴 `si` 는 무엇인가? 이 구간의 포함률은? → 0.940(이론), 이 시드 186/200
- **제목과 코드(B-7)**: `mfrow = c(2, 3)` 이라 적힌 그림은 몇 행 몇 열인가? → 3행 2열. `binwidth = 0.05` 라 적힌 히스토그램의 실제 구간 폭은? → 0.01
- `plot(tg_mat[, 1], type = "l"); lines(tg_mat[, 2])` 에서 VC 선은 다 보일까? → 0.5 mg 점(7.98)이 축 범위(13.23–26.06) 밖이라 잘림(2128–2134)
- `hist(x)` 와 `barplot(x)` (x = 1, 2, 2, 1, 3, 3, 1, 5)의 막대 수는? → 그림으로 대조(628)
- 상자그림의 오른쪽 수염 끝은 항상 `max(x)` 일까? → 이상치가 있으면 아님. `x <- c(rnorm(100), 5)` 로 확인(B-8)
- `ggplot(gapm_filter, aes(year, life_expectancy)) + geom_line()` 은 어떤 모양일까? → 나라를 이어 그린 톱니(2361)
- iris 종별 히스토그램을 `fill = Species, alpha = 0.2` 로 그리면 막대가 겹칠까 쌓일까? → 쌓임(3개 막대). 밀도판의 전체 넓이는? → 3(B-9)
- 오차 막대만 `position_dodge(0.8)` 를 주면 점과 선은 어디에 놓일까? → 오차 막대와 어긋남(2764–2776)
- 인구가 19,766배 차이 나는 두 나라의 점 면적은 몇 배로 그려질까? → 36배(B-10)
- `diamonds` 에서 `geom_smooth()` 의 기본 방법은? → gam(관측 1,000개 이상). 234행 mpg 에서는? → loess
- "World COVID-19 cases" 막대 꼭대기 값은 세계 합계인가? → 가장 큰 대륙 값(B-11)
- 한국 검사 수 그림의 총 검사 수 글자는 몇 번 그려졌을까? → 92번(B-12)
- `ylim(15, 30)` 과 `coord_cartesian(ylim = c(15, 30))` 은 같은 상자그림을 그릴까? → 아님. `ylim` 은 29행을 버리고 midsize 중앙값 27 → 26, suv 17.5 → 18.0 으로 바뀜(v8)
- 콘솔에서 894 청크 뒤에 `par(pin = c(5, 2)); plot(...)` 을 실행하면? → `plot region too large`. 새 장치에서는 됨(B-5)
- `scale = "free_y"` 는 왜 오류가 나지 않을까? → 인수 이름 부분 일치(C-28)

### G-5. 새로 필요한 검증 절차 ("그림이 무엇을 그렸는지 확인하기")

12장 `#sec-verify-transform` 과 6장(검증)의 절차를 그림에 적용한다.

1. **그려진 행 수**: `nrow(data)` 와 `nrow(layer_data(p))` 를 비교하고, `Removed n rows` 경고를 숨기지 않는다(`warning=FALSE` 금지). 빠진 행이 결측인지 척도 밖인지 구분한다.
2. **stat 이 만든 값**: `layer_data(p)` 로 `count`, `density`, `ymin`/`ymax`, 상자그림의 `lower`/`middle`/`upper` 를 꺼내 `table()`, `fivenum()`, 손으로 계산한 값과 대조한다.
3. **위치 조정**: 막대·히스토그램이 쌓였는지(`ymin > 0`) 겹쳤는지 확인하고, 쌓았다면 막대 꼭대기가 합계와 같은지 대조한다.
4. **척도 한계**: 확대가 목적이면 `coord_cartesian()`. `scale_*(limits = )`·`xlim()`·`ylim()` 은 자료를 버리고 통계량을 바꾼다(v8).
5. **인코딩**: 크기는 면적(`scale_size_area()`), 로그 축은 축 제목에 적고, 색이 아무 변수도 나타내지 않으면 쓰지 않는다(C-33).
6. **글자와 코드**: 제목·축·범례·주석의 숫자와 기호를 코드의 인수와 대조한다(B-7, A-1). 단위를 적는다(C-9, B-14).
7. **필터와 설명**: 그림에 들어간 집단 수를 본문의 기준과 대조한다(A-2).
8. **저장과 재현**: `ggsave()` 로 임시 파일에 저장해 `file.exists()`·크기를 확인하고, 시드를 고정한다(C-23).
9. **상태**: `par()` 를 되돌리고 `Sys.setlocale()` 같은 전역 설정을 쓰지 않는다(B-5, B-15).

### G-6. "AI와 함께" 절 제안

- 위치는 장 끝, 연습문제 앞. ID 는 `sec-ai-visualization`(12장 `sec-ai-handling` 과 같은 형식).
- 과제 명세 후보 (1) "Gapminder 2015년 자료로 1인당 GDP(로그 축)와 기대수명의 거품 그림을 그리고 점 크기는 인구, 색은 대륙으로" — 검증 항목: 188개국이 모두 그려졌나, 크기가 면적 비례인가(B-10), 로그 축 표기, 대륙 매핑을 정규식으로 했나 표로 했나, 지표 이름(B-14). (2) "iris 세 종의 꽃잎 길이 분포를 한 그림에 겹쳐서" — 검증 항목: 위치 조정(B-9), 밀도 넓이, `after_stat()`. (3) COVID 를 유지한다면 "대륙별 일일 확진자 추이" — 쌓기 대 겹치기(B-11), 결측과 음수 신규 확진(재현: 8행이 음수, 대륙·날짜 합계는 음수 없음).
- 흔한 오류 후보는 **실제 LLM 응답으로 확인한 뒤에만 싣는다**(CLAUDE.md 규칙 7): `size` 로 선 굵기, `..density..`, `guides(FALSE)`, `coord_flip()`, `geom_histogram()` 기본 쌓기, `ylim()` 으로 확대, `aes()` 안 상수, `annotate()` 대신 `geom_text()`.
- 개인정보: 명단 파일을 프롬프트에 붙이지 말라는 `rmdwarning`(12장과 같은 문구). 저장소의 개인정보 의심 파일 4종은 쓰지 않는다.

### G-7. 일상의 예를 먼저 (강사 결정 2026-09-11)

- 매핑: 성적표의 열(키, 몸무게, 성별)을 종이 위 가로 위치, 세로 위치, 점 색에 하나씩 대응시키는 일(`grammar-graphics-intro.png` 와 같은 구조).
- 쌓기와 겹치기: 반별 출석 인원을 한 막대에 쌓을 때와 반마다 투명 막대를 같은 자리에 겹칠 때 막대 꼭대기가 뜻하는 것.
- 척도 한계: 사진을 확대하는 것(`coord_cartesian`)과 사진 가장자리를 잘라 내고 남은 부분으로 평균을 다시 내는 것(`ylim`)의 차이.
- 그래픽 상태: 화이트보드를 4칸으로 나눠 쓰고 지우지 않으면 다음 사람도 4칸에 쓴다(`par(mfrow)`).
- 상자그림 수염: 반 키 분포에서 유난히 큰 한 명은 수염 끝이 아니라 점으로 따로 표시된다.

### G-8. 자료 선택

- 내장 자료(mtcars, iris, mpg, diamonds, warpbreaks, UCBAdmissions, Titanic, ToothGrowth, economics_long)는 결측이 없거나 거의 없다. "빠진 행" 검증에는 Gapminder(`life_expectancy` 결측 16)나 `airquality`(Ozone 결측 37)를 쓴다[재현].
- Gapminder 는 12장 자료와 정의를 맞춘다(F-1, 강사 확인 3).
- COVID 2020-06-01 자료는 유지하면 시점과 출처 판을 명시한다. 2020년 3–5월 자료는 학생에게 맥락 설명이 필요하다(강사 확인 2).
- `palmerpenguins`(설치 확인)는 결측과 종 간 겹침이 있어 히스토그램 쌓기·결측 행 교재 후보다. 도입 여부는 강사에게 남긴다.

### G-9. 멋 부린 표현과 근거 없는 주장 (작업 규칙 11) — 새 장에 옮기지 않을 문장

| 줄 | 현재 | 고쳐 쓰기 예 |
|---|---|---|
| 55 | "그래프는 생각보다 더 많은 정보를 제공" | "요약 통계량이 같은 자료도 그림은 다를 수 있다(Anscombe)" |
| 86 | "인간의 뇌 구조 상 추상적인 숫자나 문자 보다는 그림이나 도표를 더 빨리 이해" | 삭제(근거 없음) |
| 87 | "다른 통계 패키지와 비교할 수 없을 정도로 월등한 성능의 그래픽 도구" | "R 은 기본 그래픽과 ggplot2 두 체계로 그림을 코드로 만든다" |
| 917, 924 | "그래프의 미학적 효과를 극대화 하기 위해", "미학적 특성 설정" | "여백·크기·배치를 정한 뒤 요소를 덧그린다" |
| 1870 | TeX 각주 "다른 워드 프로세서와 비교할 수 없을 정도로 강력" | "수식 조판 프로그램" |
| 2083 | "R 에서 가장 유명한 데이터 시각화 패키지 중 하나" | "2007년 CRAN 에 처음 배포된 패키지" |
| 2196 | "그래프의 미적 효과 극대화" | "자료와 무관한 요소(글꼴, 배경, 격자)를 정한다" |
| 3246 | "`geom_boxplot()` + `geom_jitter()` 콜라보레이션" | "상자그림 위에 관측값 점 겹치기" |
| 3505 | "가장 사용하기 용이한 패키지와 함수는 `ggubr::ggarrange()`" | "여러 그림을 배치하는 패키지로 patchwork 를 쓴다" |
| 3605 | "알아두면 유용한 팁" | "참고 자료" |

---

## H. 작업 순서와 작업량

1. **공개 사이트(현 장)에 남아 있는 동안 고칠 것** (각 5분 안팎): A-1(1485·1491·1497 표기), A-2(3717·3720·3723 기준 일치), A-3(2840–2841 `qt()`·`sx` 와 주석), B-7 의 (1) 1238 제목과 (5) 3108 제목, B-6 의 436–440 설명. 다시 렌더하기 전에 2065–2069 를 임시 파일로 바꾸지 않으면 추적 파일 `figures/save-example.png` 가 바뀔 수 있다(F-5). B-1~B-3 을 함께 고치면 배포본의 경고 노출이 사라진다.
2. 새 13장은 G 의 구성을 따른다. B·C 대부분은 재작성으로 해소된다. 부록 B 를 쓸 때 B-7 의 해부 그림 표기를 고친다.
3. 12장 Gapminder 자료와의 정합(F-1)은 설계 단계에서 결정한다.
4. CLAUDE.md 진행 상태 표에 "현 11장(구 데이터 시각화): 감사 완료, 치명 3건 배포 중"을 기록한다(오케스트레이터 7단계).

- 작업량: A 3곳 / B 20곳 / C 41곳 / 신규 작성: 그래픽 상태, 쌓기와 겹치기, 척도와 한계, 크기·색 인코딩, 그래프 검증하기 — 소절 약 6개 + "AI와 함께" 1절 + 연습문제 + 부록 B(`par()`·저수준 함수·수식·테마 요소)

---

## I. 측정값과 재현 코드 (새 장에서 재사용)

코드는 저장소 루트에서 실행한다. 파일을 쓰지 않는다. 전체 스크립트는 `/tmp/audit11/repro/v1_base.R` – `v8_limits.R`.

### I-1. 치명 3건

```r
library(tidyverse)
# A-1: 표준편차 √2, √3 곡선의 정점 대 σ = 2, 3 일 때
dnorm(0, 0, c(1, sqrt(2), sqrt(3)))   # 0.399 0.282 0.230
dnorm(0, 0, 1:3)                      # 0.399 0.199 0.133
# A-2: 기준 1,000 초과 대 2,000 이상
covid19 <- read_delim("dataset/covid-19-dataset/covid19-cases-20200601.txt", delim = "\t", show_col_types = FALSE)
country <- readxl::read_excel("dataset/covid-19-dataset/country_info.xlsx")
d <- covid19 |> filter(iso_code != "OWID_WRL", date >= as.Date("2020-03-01"), date <= as.Date("2020-05-31")) |>
  left_join(country, join_by(iso_code), relationship = "many-to-one")
m <- d |> summarise(maxc = max(total_cases), .by = location)
c(gt1000 = sum(m$maxc > 1000), ge2000 = sum(m$maxc >= 2000))   # 114 89
m |> filter(location == "New Zealand")                          # 1154
# A-3: z 분위수 × 표본 표준편차의 포함률 (n = 30)
2 * pt(qnorm(0.975), 29) - 1                                    # 0.9403
```

### I-2. 그림이 계산한 값 (B-9, B-10, G-5)

```r
p <- ggplot(iris, aes(Petal.Length)) + geom_histogram(aes(fill = Species, y = after_stat(density)), bins = 20)
d <- layer_data(p)
sum(d$ymin > 0 & d$count > 0)                                   # 3: 쌓인 막대
d |> summarise(area = sum(density * (xmax - xmin)), .by = group) |> pull(area) |> sum()   # 3
g <- read_csv("dataset/gapminder/gapminder_filter.csv", show_col_types = FALSE) |> filter(year == 2015)
s <- layer_data(ggplot(g, aes(life_expectancy, gdp_cap)) + geom_point(aes(size = population)))$size
c(pop_ratio = max(g$population) / min(g$population), area_ratio = (max(s) / min(s))^2)   # 19766, 36
```

### I-3. 척도 한계 대 좌표 확대 (G-4, G-5)

```r
p <- ggplot(mpg, aes(class, hwy)) + geom_boxplot()
mid <- \(q) suppressWarnings(layer_data(q))$middle
rbind(none = mid(p), ylim = mid(p + ylim(15, 30)), coord = mid(p + coord_cartesian(ylim = c(15, 30))))
# midsize 27 / 26 / 27, suv 17.5 / 18.0 / 17.5. ylim 은 29행을 버림
```

### I-4. 그래픽 상태 (B-5)

```r
pdf(NULL, width = 7, height = 7)
par(mfrow = c(2, 3), oma = c(0, 0, 2, 0)); for (i in 1:6) plot(1)   # 894 청크가 남기는 상태
try({par(pin = c(5, 2)); plot(1:10)})                             # plot region too large
dev.off()
```

### I-5. 색 함수 (B-6)

```r
palette()            # "black" "#DF536B" "#61D04F" "#2297E6" "#28E2E5" "#CD0BBC" "#F5C710" "gray62"
heat.colors(3); terrain.colors(3); topo.colors(3)
try(grey(5))         # invalid gray level, must be in [0,1]
```
