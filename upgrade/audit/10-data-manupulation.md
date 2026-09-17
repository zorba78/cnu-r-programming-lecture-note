# 감사 보고서: 10-data-manupulation.Rmd (현 10장 데이터 핸들링 → 새 12장 데이터 핸들링)

- 감사일 2026-09-17 · R 4.6.1 · tidyverse 2.0.0 · dplyr 1.2.1 · tidyr 1.3.2 · readr 2.2.0 · tibble 3.3.1 · ggplot2 4.0.3 · 감사자 Claude · 대상 2,530줄 / 코드 청크 98개(`echo=FALSE` 34개, 그중 kable 표 12개)
- 실행: 저장소 **사본**에서만 실행했다. 180줄이 git 추적 파일 `dataset/pulse.feather` 를 다시 쓰기 때문이다. `git archive HEAD` 로 장, 이 장이 읽는 `dataset/` 파일, `output/pulse.rds`, `figures/` 만 `/tmp/audit10/clone` 에 풀었다. `run_chunks.R 10-data-manupulation.Rmd --timeout=600` 결과는 **OK 86 / ERROR 0 / EXPECTED-ERROR 2 / SKIP 10**(모두 eval=FALSE)이고, 2분 11초 걸렸다(그중 `read_csv-ex` 청크 124초). deprecation 경고는 1건(2495)이다. 같은 사본을 `rmarkdown::render(html_document(keep_md = TRUE))` 로 렌더해 메시지와 경고까지 출력 전체를 대조했다(오류 0, 2분 14초). 실행 전후 작업 트리의 `dataset/pulse.feather`·`output/pulse.rds` md5 는 같다
- 방법: 장 정독 → 구식 패턴 grep(코드 줄만 따로 집계) → 청크 실행과 렌더 → 본문 주장을 출력과 대조하는 재현 스크립트 8개. 치명 후보는 올바른 코드와 수치를 비교했다. 조인은 키 유일성, 짝 없는 키, 행 수를 셌다. Gapminder 는 원자료 xlsx 의 ABOUT 시트와 world 합계로 대조했다. lifecycle 상태는 설치된 도움말과 NEWS 로 확인했다 → 외부 링크 curl(브라우저 UA, HEAD·GET) → 로컬 자원과 `dataset.zip` 목록 → 배포본(`docs/`, 2023-05-15 렌더) 출력 대조
- 표기: **[재현]** R 4.6.1 에서 실행해 확인함 · **[추론]** 문서·코드 검토에 근거한 판단(실행으로 확인하지 않음)
- 결과: **치명 3 · 중요 15 · 경미 42**. 외부 링크 8건(주석 포함) 중 소실 1건(MRAN), 주석 안의 404 1건
- 재현 스크립트는 저장소 밖 `/tmp/audit10/repro/`(v1–v8)에 두었다(세션이 끝나면 사라질 수 있다). 핵심 재현 코드는 I 절에 인라인으로 실었다
- 이 감사는 이 보고서 외의 파일을 수정하지 않았다. CLAUDE.md 진행 상태 표도 갱신하지 않았다(H 절). 감사 도중 작업 트리에 새 12장 관련 미추적 파일(`12-data-handling.qmd`, `12-data-handling-slides.qmd`, `docs/preview/12-data-handling*`, `ai-transcripts/12-data-handling/`, `dataset/ch12/`)이 생겼다. 이 감사가 만든 것이 아니며 읽지 않았다. 따라서 이 보고서는 현행 `10-data-manupulation.Rmd` 만 대상으로 하고, 새 초안이 G 의 제안을 이미 반영했는지는 확인하지 않았다

## 요약

현 10장은 readr·tibble·dplyr·tidyr 를 동사 사전 형식으로 훑는 장이다. 청크는 모두 돌아간다(오류 0). 문제는 세 갈래다.

- **출력이 이름표와 다르다(A).** 변속기(`am`)별이라고 적은 요약표는 실제로 엔진 형태(`vs`)별 통계다(398–405). `mean_hwy` 열에는 시내 연비가 들어 있다(1036). "group_by() 이후 적용되는 동사는 모두 그룹 별 연산"이라는 문장은 `arrange()` 에서 거짓이다. 그런데 한 회사만 남기는 예제가 이를 가린다(867–877). 세 표의 숫자가 모두 그럴듯해서 배포본에 그대로 실려 있다. 같은 장 2454–2461 줄의 올바른 am 표는 17.1/24.4 를 출력해, 398줄 표의 16.6/24.6 과 장 안에서 서로 어긋난다.
- **장의 "확인" 동작이 제 역할을 못한다(B).** 왕복 변환 뒤 "데이터 동일성 확인"으로 부른 `all.equal()` 은 TRUE 가 아니라 속성 차이 5줄을 출력한다. 본문은 이를 설명하지 않는다(2266–2273). "readr 가 base 보다 월등히 빠르다"(124)는 문장 바로 아래 청크는 `read_csv` 116초 대 `read.csv` 5.2초를 출력한다(배포본 70.0초 대 4.8초). 조인 절은 기본키와 외래키 정의가 뒤바뀌었고(1440–1441), 결합 뒤 행 수·짝 없는 키·NA 를 한 번도 보지 않는다. Gapminder 요약은 국가별 1인당 GDP 의 단순 평균을 지역 평균으로 제시한다(동아시아 30,459 대 인구 가중 20,627).
- **현행 API 가 하나도 없고, NA 를 다루지 않는다.** `across()`, `.by`, `join_by()`, `slice_*()`, `separate_wider_*()`, `filter_out()`(dplyr 1.2.0) 이 모두 0회다. 대신 superseded 된 scoped 동사(`_all/_at/_if`) 절 164줄을 "실제 데이터 전처리 시 가장 많이 사용"(1129)이라 소개한다. `gather/spread/separate/top_n/sample_n/transmute` 도 본문으로 가르친다. `is.na` 는 0회, `na.rm` 은 1회다. `filter()` 가 NA 행을 조용히 버린다는 사실도 다루지 않는다. titanic 의 `age < 18` 에서 `[` 는 417행, `filter()` 는 154행을 돌려준다.

재구성안의 처리 방침은 "현행화. across(), pivot_*(), .by"(동사 사전은 부록 D)다. 이 감사는 한 걸음 더 나가 **"변환한 뒤 확인하기"(행 수 불변식, 키 유일성, 짝 없는 키, NA 수, 외부 합계 대조)를 장의 뼈대로** 삼기를 제안한다(G). 새 11장이 입출력에서 세운 "읽은 뒤 원문과 대조" 절차를 변환·결합·요약으로 잇는 장이 된다. 결정은 강사에게 남긴다.

---

## A. 치명 — 코드가 본문과 다르게 동작하고, 결과가 그것을 가림

### A-1. 변속기(am)별 요약표가 실제로는 엔진 형태(vs)별 통계 [재현]

**줄** 398–405(청크 `pipe-ex`). 대조할 줄은 2315–2330, 2454–2461

```r
mtcars %>% 
  mutate(am = factor(vs,               # ← am 이 아니라 vs
                     levels = 0:1, 
                     labels = c("automatic", "manual"))) %>% 
  group_by(am) %>% 
  summarise_at(vars(mpg, disp:qsec), list(mean = mean, sd = sd))
```

열 이름은 `am` 이고 라벨은 자동/수동 변속기다. 그런데 값은 `vs`(엔진 형태: 0 = V형, 1 = 직렬)에서 온다. 결과표 13개 열의 수치가 모두 변속기가 아닌 엔진 형태별 통계다.

| 집단 | 출력(vs 기준) n / mpg 평균 | 실제 am 기준 n / mpg 평균 |
|---|---|---|
| automatic | 18 / 16.6 | 19 / 17.1 |
| manual | 14 / 24.6 | 13 / 24.4 |

`table(vs, am)` 을 보면 vs = 0 인 18대 중 12대가 자동, 6대가 수동이다. 두 분류가 섞였지만 평균 차이의 방향이 같아 숫자가 그럴듯하다. 장 안에 증거가 두 번 더 나온다. 2315–2330 의 V-shaped/Straight 표는 mpg 16.6/24.6 을, 2454–2461 의 올바른 am 표는 17.1/24.4 를 출력한다. 배포본 `docs/dplyr.html` 에도 틀린 표가 실려 있다. 바로 위 주석(386–396)의 "Homework #3 b-c 풀이"를 옮기면서 생긴 것으로 보인다[추론].

**수정**: `factor(am, ...)`. 새 12장에서는 원문을 **버그 찾기 문항**으로 쓴다. "같은 장의 두 표에서 자동 변속기 차의 mpg 평균이 16.6 과 17.1 로 다르다. 어느 쪽이 맞고 왜 다른가?"

### A-2. `mean_hwy` 열에 시내 연비 평균이 들어감 [재현]

**줄** 1029–1037

```r
mpg %>% group_by(manufacturer, year) %>%
  summarise(N = n(), mean_displ = mean(displ), mean_hwy = mean(cty))
```

주석(1030)은 "배기량, 시내연비의 평균 계산"이고 계산도 `cty` 다. 그런데 열 이름이 `mean_hwy` 다. 30행 모두 '고속 연비' 이름표 아래 시내 연비가 출력된다.

| manufacturer | year | 출력된 mean_hwy | 실제 mean(hwy) |
|---|---|---|---|
| audi | 1999 | 17.1 | 26.1 |
| audi | 2008 | 18.1 | 26.8 |
| chevrolet | 1999 | 15.1 | 21.6 |

값의 크기(13–28)가 연비로 자연스러워 출력만으로는 알아챌 수 없다. **수정**: `mean_cty = mean(cty)`. A-1 과 함께 "이름과 계산이 일치하는가"를 묻는 읽기 문항으로 쓸 수 있다.

### A-3. "group_by() 이후 동사는 모두 그룹별" — `arrange()` 는 그룹을 무시하는데 예제가 가림 [재현]

**줄** 867(문장), 869–877(예제), 881

867 은 "`group_by()` 이후 적용되는 동사는 모두 그룹 별 연산 수행"이라 적는다. 그러나 `arrange()` 는 기본값 `.by_group = FALSE` 에서 그룹을 무시한다. 예제 주석은 "제조사 별 시내연비가 낮은 순으로 정렬"이지만, 코드는 전체를 `cty` 순으로 정렬한다. 예제가 곧바로 `filter(manufacturer == "audi")` 로 한 회사만 남기므로 결과가 그룹 정렬과 구별되지 않는다. `identical(ungroup(audi), mpg |> filter(manufacturer == "audi") |> arrange(cty))` 도 TRUE 다.

```
mpg |> group_by(manufacturer) |> arrange(cty) 의 앞 12행 manufacturer
dodge dodge dodge dodge jeep chevrolet chevrolet chevrolet dodge dodge dodge dodge
arrange(cty, .by_group = TRUE) 로 바꾸면
audi audi audi audi audi audi audi audi audi audi audi audi
```

`select()`·`rename()` 도 그룹 변수를 남길 뿐 "그룹별 연산"을 하지 않는다. 이 문장을 믿은 학생은 `group_by() |> arrange()` 로 그룹 안 정렬을 기대한다. 결과도 그럴듯해 스스로 알아채기 어렵다.

**수정**: "그룹을 반영하는 동사는 `summarise()`·`mutate()`·`filter()`·`slice_*()` 이고, `arrange()` 는 `.by_group = TRUE` 일 때만 그룹 순으로 정렬한다"로 고친다. 예제는 그룹이 섞인 앞 행을 그대로 보여 주는 것으로 바꾼다. 새 12장의 예측 문항 후보다.

---

## B. 중요 — 서술이 틀렸거나, 실린 코드·자료와 어긋나거나, 학생 환경에서 실패함

| # | 줄 | 문제 | 근거 | 수정 |
|---|---|---|---|---|
| B-1 | 2266–2273 | "데이터 동일성 확인" `all.equal(wide_01, wide_ex_01)` 이 TRUE 가 아니라 `"Attributes: < Names: 1 string mismatch >"` 부터 `"Attributes: < Component 2: target is externalptr, current is numeric >"` 까지 5줄을 출력한다(`spread()` 판도 같음). 값은 같다. 차이는 `read_csv()` 가 돌려준 `spec_tbl_df` 클래스와 `spec`·`problems` 속성이다. 배포본에도 같은 목록이 실려 있으나 본문은 언급하지 않는다. **검증 출력을 읽지 않고 넘어가는 습관**을 보여 주는 셈이다. 흔한 우회책 `check.attributes = FALSE` 는 열 이름이 바뀐 경우(`country` → `Country`)에도 TRUE 를 돌려줘 위험하다 | 재현 | `all.equal(as_tibble(wide_01), wide_ex_01)` → TRUE. 또는 `testthat::expect_equal(wide_ex_01, wide_01)`(3판, waldo 비교): 통과하고, 열 이름 변경은 잡는다. 새 11장 왕복 검사(`#sec-round-trip`)와 연결 |
| B-2 | 124, 176–183 | "(readr) 읽고 저장하는 속도가 base R … 보다 월등히 뛰어남", "feather 패키지 … 더 빠르게" — 바로 아래 청크의 출력이 반대다. `pulse.csv`(69행 × 20,000열)에서 `read.csv` 5.17초, `readRDS` 0.082초, **`read_csv` 116.3초**, `read_feather` 0.097초(배포본 2023: 4.85 / 0.088 / **70.0** / 0.293초). 넓은 표에서는 readr 가 느리다(09 감사 I-1: 긴 표에서는 `read_csv` 0.10초 대 `read.csv` 1.44초). 부수 문제도 있다. (1) 장 렌더 시간 2분의 대부분이 이 청크다 (2) 180줄이 **git 추적 중인 12.5 MB 이진 파일** `dataset/pulse.feather` 를 렌더마다 다시 쓴다. 사본에서 12,557,968 B 가 12,238,744 B 로 바뀌었다(md5 변경, CLAUDE.md 규칙 9) (3) 181줄은 9장이 만든 `output/pulse.rds` 에 기댄다 (4) feather 0.4.0(2025-12)은 arrow 를 감싼 래퍼로 바뀌었다(Imports: arrow) | 재현 | 청크와 124줄 문장을 삭제한다. 형식·속도 비교는 새 11장 `#sec-formats` 가 측정값과 함께 다룬다 |
| B-3 | 1439–1441 | "기준 테이블(flights)의 키 → 기본키, 병합할 테이블의 키 → 외래키" — 거꾸로다. 기본키는 자기 표의 관측을 유일하게 식별하는 변수(`planes$tailnum`)이고, 외래키는 다른 표의 기본키를 가리키는 변수(`flights$tailnum`)다(R4DS 2판 19.2: "flights$tailnum is a foreign key that corresponds to the primary key planes$tailnum"). 어느 쪽이 기준 표인지와 무관하다 | 재현(문헌 대조. 유일성은 planes `tailnum`·airports `faa`·airlines `carrier` 모두 중복 0) | 정의를 바꾸고, "기본키는 유일해야 한다"를 `count(key) \|> filter(n > 1)` 로 확인하는 코드를 붙인다 |
| B-4 | 1226, 1427–1432, 1517–1563 | 결합 뒤 확인이 없다. (1) `weather` 의 결합 키 `origin, year, month, day, hour` 는 유일하지 않다. 2013-11-03 01시(서머타임 해제)에 세 공항 모두 2행씩이다. R4DS 2판은 `origin, time_hour` 를 쓴다(중복 0). 그 시각에 운항 편이 0편이라 이번에는 행이 늘지 않았을 뿐이다 (2) 네 번 left_join 한 결과가 336,776행으로 유지됐는지 확인하는 코드가 없다 (3) `planes` 에 없는 tailnum 722개 때문에 **52,606행(15.6%)의 `model` 이 NA** 가 된다. `temp` 결측도 1,573행이다(그중 1,556행은 짝이 되는 날씨 기록 자체가 없음). 본문은 이를 언급하지 않는다 (4) 1226 "mutating join 만 다룸"으로, 짝 없는 키를 찾는 도구 `anti_join()` 을 뺐다 (5) `by` 를 생략하면 `flights` 와 `planes` 가 `year`(운항 연도 대 제작 연도)와 `tailnum` 둘 다로 결합된다. 그러면 **332,146행(98.6%)이 NA** 가 되고 `Joining with by = join_by(year, tailnum)` 메시지 한 줄만 남는다. 장은 늘 `by` 를 주지만 이 함정을 설명하지 않는다 | 재현 | `join_by()`, `relationship = "many-to-one"`, `unmatched`, `anti_join()` 과 결합 전후 `nrow()`·NA 수 대조를 소절로 신설한다(G-3) |
| B-5 | 1763–1772 | "지역별 … 평균 일인당 국민소득"을 `mean(gdp_cap)`, 즉 **국가 값의 단순 평균**으로 계산한다. 지역의 1인당 GDP(총 GDP ÷ 총인구)와 다르다. 2020년 동아시아 30,459 대 인구 가중 20,627, 동아프리카 4,692 대 2,235, 중앙아프리카 6,080 대 2,618 이다. 세계 수준에서 Gapminder 원자료의 world 시트(16,596)와 대조하면 가중 평균은 16,488(−0.7%), 단순 평균은 19,281(+16%)이다. 또 `gdp_cap` 은 `na.rm` 없이, `life_expectancy` 는 `na.rm = TRUE` 로 계산해 기준이 다르다. 카리브 지역의 2020년 기대수명 결측 1개가 조용히 빠진다(1950–2020 전체로는 16행, Andorra·Dominica). 출력은 22개 지역 중 10개만 보이고 `# ℹ 12 more rows` 로 끝난다 | 재현 | 두 평균을 나란히 계산해 차이를 해석하는 활동으로 바꾼다(통계학과 강의의 핵심 개념). 요약에 `n`·`n_na` 열을 함께 둔다 |
| B-6 | 1606, 1611–1615, 1703, 1713, 1763, 2046–2048, 2510, 2520 | 지표 이름·단위·범위가 원자료와 다르다. (1) `gdpcap` 시트의 값은 1인당 값이 아니라 `gdp_total`(GDP 총액)이다. 원자료 `GM-GDP per capita - Dataset - v26.xlsx` 의 ABOUT 시트는 "GDP per capita, PPP (constant 2011 international $)", "GDP total, PPP (constant 2011 international $)"라 적는다. 본문은 "국민 총소득(달러)"(1614), "1인당 국민소득"(1703, 2046–2048)이라 부른다. GDP 와 국민총소득(GNI)은 다른 지표이고, 단위는 2011년 불변 국제달러(PPP)다 (2) `gdpcap` 시트의 연도는 1800–2040 이다(1614는 2100) (3) gapminder 패키지는 1952–2007 이다(1606은 1950). 같은 문장에 "기대수명(year)"이라는 오기도 있다 (4) 1713 "대륙(region)"은 실제로 UN 하위 지역 22개이고, 원자료에 오타 `Northen America` 가 있다 (5) 그림 y축 "Total GDP/captia"(2510, 2520)가 가리키는 값은 1인당 값이다 | 재현 | 지표명을 "1인당 GDP(PPP, 2011년 불변 국제달러)"로 통일한다. 자료 버전(인구 v6, GDP v26, 기대수명 v11. 2019-12~2020-01 공개)을 적는다(G-6) |
| B-7 | 207, 220–224, 239–243 | tibble 과 data.frame 비교 설명. (1) 207 "데이터 프레임과 다르게 … factor로 형 변환을 하지 않음" — R 4.0.0 부터 `data.frame()` 도 변환하지 않는다 (2) 220 "데이터 프레임과 마찬가지로 비정상적 문자를 변수명으로 사용 가능" — 거짓이다. `data.frame()` 은 기본값 `check.names = TRUE` 로 `` `2000` ``, `` `:)` ``, `` `:(` `` 를 `X2000`, `X..`, `X...1` 로 바꾼다 (3) 241 "가장 큰 차이점은 … 속도 및 프린팅" — 검증에 영향을 주는 차이가 빠졌다. `$` 부분 일치(`df$a` 가 `abc` 열을 돌려주고, tibble 은 경고와 함께 NULL), `[, 1]` 결과(벡터 대 tibble), 길이 1 이 아닌 벡터의 재사용(data.frame 은 조용히 재사용, tibble 은 오류), `as_tibble(mtcars)` 가 **행 이름(차종)을 경고 없이 버림** | 재현 | "조용히 일어나는 일" 중심으로 다시 쓴다(3장 자료구조와 분담) |
| B-8 | 1947–1948, 1955–1968, 1980–1988, 2485 | tidy data 와 long format 을 같은 것으로 다룬다. (1) 1955–1968 은 mtcars(각 열이 변수인 tidy 자료)를 wide 예로, `gather()` 로 녹인 mtcars(변수 이름이 `variable` 열의 값이 된 **untidy** 자료)를 long 예로 든다 (2) 2485 "Tidy data를 만들기 위한 과정이 꼭 필요할까? → long format 데이터가 정말 필요할까?"는 둘을 동일시한다. 반면 같은 장 2277–2294 의 table2 예제에서는 long → wide 변환이 tidy 를 만든다 (3) 1985 `gather()` 는 "보다 쉽게 사용할 수 있고, 함수 명칭도 보다 직관적" — tidyr pivot 비네트는 반대로 쓴다: "Many people don't find the names intuitive and find it hard to remember which direction corresponds to spreading and which to gathering" (4) 1988 reshape 의 `melt()` 가 "`pivot_wider()` 또는 `gather()` 와 유사" — `melt()` 는 `pivot_longer()` 쪽이다 | 재현(문서 대조) | "무엇이 변수인가"를 판단하는 절로 다시 쓴다. tidy 여부는 모양(long/wide)이 아니라 관측 단위와 변수의 정의가 정한다 |
| B-9 | 2123–2124, 2185, 2200 | "`names_ptypes` 또는 `values_ptypes` 인수 값 설정을 통해 … 데이터 타입 변경 가능" — tidyr 1.2 이후 ptypes 는 **형을 확인**할 뿐 변환하지 않는다. `names_ptypes = list(week = integer())` 는 ``Can't convert `week` <character> to <integer>.`` 오류를 낸다. 코드(2130)는 옳게 `names_transform` 을 써서 주석과 코드가 어긋난다. 2200 who 예제는 모든 값이 levels 안에 있어서 통과할 뿐이다. 수준 하나를 빠뜨리면 ptypes 는 `loss of generality` 오류를 낸다. 같은 일을 `names_transform = list(diagnosis = \(x) factor(x, levels = …))` 로 하면 **76,046행 중 14,304행이 경고 없이 NA** 가 된다 | 재현 | "ptypes 는 확인(틀리면 오류), transform 은 변환(틀리면 조용히 NA)"으로 설명한다. ptypes 는 검증 도구로 소개할 가치가 있다 |
| B-10 | 297–325(표), 501–503, 513–515, 805–827, 장 전체 | NA 를 다루지 않는다(`is.na` 0회, `na.rm` 1회). 본문은 `mpg[조건, ]`·`subset()`·`filter()` 를 같은 결과로 나란히 둔다(501–518). 그러나 NA 가 있으면 결과가 다르다. `dataset/titanic3.csv`(age 결측 263개)에서 `age < 18` 을 걸면 **`[` 는 417행(그중 263행은 모든 열이 NA), `subset()`·`filter()` 는 154행**이다. `filter(age < 18)` 과 `filter(age >= 18)` 의 합은 154 + 892 = 1,046 으로 전체 1,309 와 다르다. `mean(age)` 는 NA 이고, pclass 별 평균 세 개도 모두 NA 다. dplyr 1.2.0 의 `filter_out(age < 18)` 은 NA 행을 남긴다(1,155행). 비교표(297–325)의 `aggregate()` 도 수식 인터페이스에서 NA 행을 조용히 뺀다(flights 의 `dep_delay` 결측 8,255행 제외) | 재현 | NA 소절 신설: 행 수 합 대조, `filter_out()`, `mean(na.rm = )` 앞뒤의 n 보고. mpg·mtcars·iris 는 결측이 없어 이 주제의 예제로 부적합하다 |
| B-11 | 334, 342, 384, 403, 791–802, 909–958, 1049–1212(특히 1129), 1733, 1755, 1947–2273, 2355–2445 | 장의 중심이 superseded API 다. 코드 줄 기준으로 scoped 동사 21회, `vars()` 7회, `gather/spread` 5회, `separate()` 5회, `top_n/sample_n/sample_frac/transmute` 각 1회다. 1129 는 `mutate_*` 를 "실제 데이터 전처리 시 가장 많이 사용"이라 소개한다. 반대로 `across()`, `where()`, `if_any()/if_all()`, `pick()`, `rename_with()`, `.by`, `join_by()`, `slice_max/min/sample/head/tail()`, `separate_wider_*()`, `reframe()`, `filter_out()`, `\|>` 는 모두 0회다. dplyr 1.2.0 NEWS 는 `.by` 와 `reframe()` 을 stable 로 올렸다 | 재현(도움말 `?scoped`, `?vars`, `?top_n`, `?sample_n`, `?transmute`, `?gather`, `?spread`, `?separate` 모두 Superseded 표기) | E 절 대체표를 따른다. 옛 관용구는 본문에서 빼고 부록 D 의 "옛 코드 읽기" 대응표로 옮긴다 |
| B-12 | 829–882, 1029–1044, 2313–2349 | 그룹이 남는 문제를 설명하지 않는다. 렌더 출력에 "`summarise()` has regrouped the output" 메시지가 4번 나온다(853, 1033, 2320, 2341). "사람이 읽기 편한" 최종 요약표 두 개(2315, 2336)에는 `# Groups: vs [2]` 가 붙어 있다. `.groups` 와 `.by` 는 0회이고, `ungroup()` 은 팁 한 줄(881)이다. dplyr 1.2.1 의 메시지는 스스로 `.by` 를 권한다. scoped 동사를 `across()` 로 바꾸면 1188줄처럼 메시지가 새로 생긴다(`summarise_at()` 은 내지 않음) | 재현(렌더) | `.by` 를 기본으로 하고, `group_by()` 는 여러 동사에 걸칠 때만 쓴다. `.by` 는 결과를 **처음 나온 순서**로 둔다는 차이를 적는다(E) |
| B-13 | 2381–2392, 2472–2480 | `separate(stat, c("variable", "statistic"))` 는 기본값 `sep = "[^[:alnum:]]+"` 로 **모든** 비영숫자에서 자른다. mtcars 열 이름에는 밑줄이 없어 맞게 나온다. 하지만 같은 장에서 만든 `cty_kpl`·`gdp_cap` 같은 이름에 쓰면 `"gdp_cap_mean"` 이 `gdp` / `cap` 으로 잘리고, **경고 한 줄**(`Expected 2 pieces. Additional pieces discarded in 1 rows [1].`)만 남는다. `separate_wider_delim()` 은 같은 입력에서 오류를 낸다 | 재현 | 요약 열 이름을 설계 단계에서 정한다: `pivot_longer(names_to = c(".value", "statistic"), names_pattern = "(.*)_(mean\|sd)")` 또는 `across(.names = "{.col}.{.fn}")`. 경고를 무시하면 안 되는 사례로 교재화한다 |
| B-14 | 1667–1673 | 시트를 개별 객체로 만들려고 `eval(parse(text = paste(names, "<-", …)))` 를 쓴다. 문자열로 코드를 만들어 실행하는 방식은 디버깅이 어렵고, 입력에 따라 임의의 코드를 실행한다. 곧이어 `ls()`(1673)가 학생이 만들지 않은 `def.chunk.hook`, `hook_output`, `` `base::merge()` ``, `` `dplyr::*_join()` ``, 전역 사본 `mpg` 등을 출력한다(knitr 설정과 표 청크가 만든 객체) | 재현 | 리스트를 그대로 쓴다(`gapmL$region`). 꼭 필요하면 `list2env(gapmL, envir = environment())`. `ls()` 는 삭제 |
| B-15 | 181, 1606, 1655, 2039 | 학생 환경에서 실패한다. `dataset.zip`(2021-03-04, 15파일)에는 `pulse.csv`·`pulse.feather`·`titanic3.csv` 만 있다. `dataset/gapminder/gapminder-exercise.xlsx`, `dataset/tidyr-wide-ex01.csv`, `output/pulse.rds` 는 없다. zip 사본에서 각 줄은 `` `path` does not exist: 'dataset/gapminder/gapminder-exercise.xlsx' ``, `'dataset/tidyr-wide-ex01.csv' does not exist in current working directory`, `cannot open compressed file 'output/pulse.rds'` 로 멈춘다. 1606 은 xlsx 의 GitHub 링크만 안내한다 | 재현(목록·오류 문구) | 새 12장 자료를 한 폴더에 모으고 받는 경로를 한 곳에 안내한다. `output/` 의존은 없앤다(B-2) |

---

## C. 경미 — 표기·정리·렌더

| # | 줄 | 내용 | 근거 |
|---|---|---|---|
| C-1 | 2–32 | setup 보일러플레이트: `rm(list = ls())`(3), `require()`(4, 28, 29, 31), PDF 전용 `size` 훅(5, 8–12), 쓰지 않는 `tidy.opts`(25). **`options(linewidth = 60)`(26)은 청크 옵션이 아니라서 무효**다(CLAUDE.md 시범 전환 7번, 09 감사 C-1). `require(rmarkdown)` 는 불필요 | 재현 |
| C-2 | 74, 81 | "RStudio의 수석 (데이터) 과학자" — 회사명이 2022년 Posit 으로 바뀜 | 추론 |
| C-3 | 83, 266, 351–407 | 파이프가 `%>%` 뿐이다(`%>%` 340줄, `\|>` 0회). CLAUDE.md 는 `%>%` 를 구식으로 보지 않지만 새로 쓰는 코드는 `\|>` 다. 이 장에는 파이프 오른쪽에 괄호 없는 함수 이름이 온 줄이 **103줄**이다(`print` 73, `glimpse` 16, `head` 4 …). 기계적으로 `\|>` 로 바꾸면 모두 `The pipe operator requires a function call as RHS` 파싱 오류가 난다. 최상위 표현식의 `%>% print` 는 자동 출력과 같아 불필요하다 | 재현 |
| C-4 | 85 | Tidy Tools Manifesto 링크(MRAN) 소실(D) | 재현 |
| C-5 | 96–119 | (1) tidyverse 2.0.0 의 핵심(부착) 패키지는 lubridate 를 포함해 9개(`tidyverse:::core`)인데, 8개로 적고 lubridate 를 "그 밖에"로 둠 (2) 119 magrittr "지금은 모든 tidyverse 패키지에 내장" — `%>%` 는 dplyr·tidyr·purrr·stringr·forcats·tibble 이 재수출하고 ggplot2·readr 는 하지 않음. magrittr 는 여전히 독립 패키지 (3) haven·readxl 은 함께 설치되지만 부착되지 않음(09 감사 B-3) (4) 99 "forcat", "Rdml" | 재현 |
| C-6 | 124 | `\@ref(data-import-export)` — 정의된 ID 가 없어 배포본 `readr.html` 첫 문장에 "??"로 나온다(9장 H1 에 ID 없음, 09 감사 C-2) | 재현(docs) |
| C-7 | 126, 134–149 | `read_csv()` 원형에 `na`, `locale`, `guess_max`, `show_col_types` 가 없다. 126 은 "경고 표시 … 데이터 디버깅에 유용"이라면서 `problems()` 를 보이지 않는다. 143 "campact". 모두 새 11장이 다룬다 | 재현(11장 대조) |
| C-8 | 159, 179, 314, 482, 1285, 1327, 1368, 1414, 1588, 1623, 1843, 1850, 1873, 2166 | `T`/`F` 약어 14줄 | 추론 |
| C-9 | 262, 272, 277 | "plyr 패키지를 최적화 … C++", "RStudio를 사용할 경우 코드 작성이 빨라짐", "purrr 패키지를 통해 행렬, 배열, 리스트 등에도 (dplyr) 적용 가능" — 역사 서술, 도구 의존, 오해 소지 | 추론 |
| C-10 | 297–325 | 비교표에서 `group_by()` 에 대응하는 base 함수 칸이 비어 있다(`split()`·`tapply()`·`aggregate()`). `subset()` 대응은 NA 가 없을 때만 성립한다(B-10) | 재현 |
| C-11 | 347 | "R base 패키지의 `filter()`" → stats. 마스킹 예로는 `library(MASS)` 뒤 `select(mpg, cty)` 가 `unused argument (cty)` 를 내는 경우가 학생이 실제로 만나는 오류다. `conflicted` 패키지를 소개할 수 있다 | 재현 |
| C-12 | 386–396 | 옛 과제 주석("Homework #3 b-c 풀이", "ggregate") | 추론 |
| C-13 | 420, 926, 1232–1233 | 측정 없는 속도 주장. mpg(234행)에서 `filter()` 851 µs, `subset()` 94 µs, `[` 67 µs. flights(336,776행)에서는 6.5 ms 대 6.0 ms. `distinct()` 306 µs 대 `unique()` 1,114 µs 는 주장대로다. `left_join()` 은 toy 자료에서 `merge()` 보다 느리고(1,366 대 682 µs) flights 에서는 빠르다(25 대 819 ms). "빠르다"는 빼거나 측정으로 보인다 | 재현 |
| C-14 | 468, 472 | mpg 코드북 "트렌스미션", "c = CNP"(같은 표 영문 칸은 CNG) | 재현 |
| C-15 | 525 | 주석은 "고속 연비가 30 miles/gallon 인"인데 코드는 `hwy >= 30` | 재현 |
| C-16 | 534–558, 1467–1514, 2024–2034, 2300 | 주석 처리된 코드·그림 블록. 2300 의 GitHub 경로는 `/blob/master/` 가 빠져 404 | 재현 |
| C-17 | 756–758 | "kmh/l" → km/L. 1.61 km·3.79 L 는 근삿값(1.609344, 3.785411784. kpl 0.4248 대 0.4251) | 재현 |
| C-18 | 774–779 | `transform()` 인수 끝의 쉼표(778). 의도한 오류(`object 'cty_kpl' not found`) 뒤에 오류가 하나 더 숨어 있다. 재사용 부분만 고치면 `argument … is empty` 가 난다 | 재현 |
| C-19 | 807, 860 | "R stat 패키지" → stats, "by_group() chain" → group_by() | 추론 |
| C-20 | 945–958 | `sample_n()`/`sample_frac()` 에 시드가 없어 렌더마다 출력이 바뀐다. 949 "`sample_(n)`" | 재현 |
| C-21 | 971 | `names(mpg)[5] <- …` 가 전역에 `mpg` 사본을 만들어 `ggplot2::mpg` 를 가린다(1673 `ls()` 에 보임) | 재현 |
| C-22 | 1016 | "`count()` … 집계 후 `ungroup()` 을 실행" — 그룹이 있는 입력에서는 원래 그룹을 유지한다(`group_by(manufacturer) \|> count(year)` 결과는 manufacturer 로 그룹) | 재현 |
| C-23 | 1073–1076 | `filter_all(all_vars(. > 100))` 은 0행(`<0 rows>`)을 출력하는 예제다 | 재현 |
| C-24 | 1087 | "대명사 앞에 ~ 표시를 꼭 사용해야 함" — 함수를 그대로 넘겨도 된다. `~` 는 익명 함수를 만드는 표기다 | 추론 |
| C-25 | 1193–1208 | `mutate_if(~ is.character(.) \| all(. >= 1999) \| (all(. <= 8) & is.integer(.)), …)` — 문자열 열에도 `all(. >= 1999)` 가 평가되어 문자 비교가 일어난다(결과는 우연히 무해). 어떤 열이 요인이 되는지(manufacturer, model, year, cyl, trans, drv, fl, class) 읽어 내기 어렵다 | 재현 |
| C-26 | 1262 | flights 코드북 "hour, minutes" → `minute` | 재현 |
| C-27 | 1435 | 그림 출처가 R4DS 1판이다. 2판 19장 그림 19.1 은 기본키를 색으로 구분한다 | 재현(링크) |
| C-28 | 990, 1517, 2019, 2250, 2360 | 헤딩: 1517 은 ID 가 없고 형제 헤딩과 달리 번호가 붙는다. 990·2019·2250 은 헤딩 안에 굵게 표기. 2360 ID `saparate` 는 오타지만 공개 앵커이므로 ID 는 유지한다(CLAUDE.md 규칙 4) | 재현 |
| C-29 | 1606, 1640–1654, 1694 | `gapminder` 를 설치·로드하고 쓰지 않는다. "gapminder 패키지와 동일한 형태의 구조"도 확인하지 않는다(year 가 dbl 대 int, 22개 지역 대 5개 대륙, 1950–2020 매년 대 1952–2007 5년 간격. 한국 1952년 기대수명이 40.5 대 47.5 로 자료 판도 다름). 1694 "인구 수 6만 이상"의 근거(gapminder 패키지 최소 인구 60,011)를 적지 않는다 | 재현 |
| C-30 | 1777 | cheat sheet 링크는 opensource.posit.co 로 리디렉트된다(작동). 직접 링크로 교체 | 재현 |
| C-31 | 1789, 1801, 1809 | "적어도 80% 이상의 시간" 출처 없음, "tidy = organized", "시작 전 tidyverse 패키지를 R 작업공간으로 불러오기!!"(setup 이 이미 로드) | 추론 |
| C-32 | 1839, 1890 | "2 × 2 교차설계 데이터 예시: 2개의 열, 3개의 행" — 3 × 2 표이고 교차설계(crossover)도 아니다. 1890 은 `person` 이라 적는데 코드(1898)의 열 이름은 `name` | 재현 |
| C-33 | 1973 | "tidyr 패키지에서 제공하는 함수는 데이터 프레임 또는 티블에서만 작동" — `replace_na()` 등은 벡터에도 작동한다 | 추론 |
| C-34 | 2077, 2097, 2104 | 주석은 "pivot_wider() 사용"인데 코드는 `pivot_longer()`. "value_drop_na" → `values_drop_na` | 재현 |
| C-35 | 2144–2157 | who 코드북 "1524 = 14-24 yrs" → 15–24(`?who`). 덧붙여 `iso2` 결측 294행은 모두 Namibia 로, 국가 코드 "NA" 가 결측으로 읽힌 것이다. NA 소절의 교재 후보 | 재현 |
| C-36 | 2226–2242, 2364–2373, 2394–2397, 2411–2420 | 원형 블록: `values_fill #` 빈 주석, `seprate(`(2366, 2411), unite 원형 끝 쉼표(2418). "sep의 길이는 into 인수의 길이보다 작아야"는 정확히 `length(into) - 1` | 재현 |
| C-37 | 2302–2349 | "사람이 읽기 편한" 요약표: 열이 알파벳 순(carb, cyl, disp …)이고 콘솔 폭에서 잘리며(`3.4 …`) 그룹이 남아 있다(B-12). 표는 `knitr::kable()` 이나 gt 로 낸다. 2334 "ㄷ + 한자"는 Windows 입력기 전용 | 재현 |
| C-38 | 2452 | "기어 종류(`am`)" → 변속기(`am`). gear 는 전진 기어 수(`?mtcars`) | 재현 |
| C-39 | 2485–2525 | `wide-01` 이라 적었지만 객체 이름은 `wide_01`. "wide 형태 그대로 시각화" 전략을 약속하고 보이지 않는다. `geom_line(size = 1)` deprecation(E) | 재현 |
| C-40 | 39, 74, 1803 외 | 오탈자: "Hadely Weckam"(39), "Hadely Wickham"(74), "Hadely Wickam"(1803), "unqiue"(926), "변셩"(968, 971), "`mutate_all`, `mutate_at`, `mutate_all`"(1170, 셋째는 `mutate_if`), "summary_*"(1174, 1183, 1193), "dipl"(1184), "포맷으로로"(1276), "captia"·"목직임"(1606), "Captia"(1770), "어러"(1794) | 재현 |
| C-41 | 178, 1242, 1653, 1654 | 본문 `require()` — 렌더에 "Loading required package: feather / nycflights13 / readxl / gapminder" 4줄이 출력된다(배포본은 "필요한 패키지를 로딩중입니다") | 재현 |
| C-42 | 297–325, 448–493, 1251–1424, 1569–1598, 1610–1632, 1841–1921, 2141–2177 | kable 표 12개가 `echo=FALSE` 청크 372줄을 차지한다(조인 절의 코드북·비교표 5개만 약 170줄). `stringsAsFactors = FALSE` 9회, PDF 전용 `latex_options` 반복 | 재현 |

---

## D. 외부 링크·로컬 자원·패키지·배포본

**외부 링크** (브라우저 UA, HEAD·GET)

| 줄 | URL | 상태 | 조치 |
|---|---|---|---|
| 85 | `https://mran.microsoft.com/web/packages/tidyverse/vignettes/manifesto.html` | **소실**. https 는 인증서 이름 불일치, 인증서를 무시하면 403 "Web App - Unavailable", http 도 403. MRAN 은 2023년 서비스 종료 | `https://tidyverse.tidyverse.org/articles/manifesto.html` (200) |
| 132 | `https://cran.r-project.org/web/packages/readr/vignettes/readr.html` | 200 | 새 12장에서는 불필요(11장 소관). 필요하면 `https://readr.tidyverse.org/articles/readr.html` (200) |
| 1435 (그림 캡션) | `https://r4ds.had.co.nz/` | 200 (1판) | `https://r4ds.hadley.nz/joins.html` (200) |
| 1467, 1483, 1498, 1512 (주석) | `https://statkclee.github.io/data-science/ds-dplyr-join.html` | 200 (페이지 10.5 MB), 렌더되지 않음 | 주석 블록과 함께 삭제 |
| 1606 | `https://gapminder.org` | 200 (`www.gapminder.org` 로 이동) | — |
| 1606 | `https://github.com/zorba78/cnu-r-programming-lecture-note/blob/master/dataset/gapminder/gapminder-exercise.xlsx` | HEAD 200 (연속 GET 은 429 속도 제한) | — |
| 1777 | `https://rstudio.com/resources/cheatsheets/` | 200 (`opensource.posit.co/resources/cheatsheets/` 로 이동) | `https://rstudio.github.io/cheatsheets/html/data-transformation.html`, `…/tidyr.html` (둘 다 200) |
| 2300 (주석) | `https://github.com/zorba78/cnu-r-programming-lecture-note/dataset/gapminder/gapminder_filter.csv` | **404** (`/blob/master/` 누락) | 주석 삭제 |
| 추가 제안 | `https://r4ds.hadley.nz/data-transform.html`, `https://r4ds.hadley.nz/data-tidy.html`, `https://dplyr.tidyverse.org/articles/colwise.html`, `https://dplyr.tidyverse.org/reference/filter_out.html`, `https://dplyr.tidyverse.org/reference/join_by.html`, `https://dplyr.tidyverse.org/articles/two-table.html`, `https://tidyr.tidyverse.org/articles/pivot.html`, `https://tidyr.tidyverse.org/articles/tidy-data.html`, `https://www.jstatsoft.org/article/view/v059i10`, `https://www.gapminder.org/data/` | 모두 200 | B·G 항목의 출처로 |

**로컬 자원** — 참조 파일은 모두 존재한다. 그림 15개(`figures/`)도 모두 있다.

| 줄 | 파일 | 형식·크기 | 비고 |
|---|---|---|---|
| 155–173 | `dataset/titanic3.csv` | CSV, 116,752 B, 1,309행 × 14열 | age 결측 263, embarked 결측 2. NA 교재 후보(B-10) |
| 179, 182 | `dataset/pulse.csv` | CSV, 11,866,553 B, 69행 × 20,000열 | B-2 |
| 180, 183 | `dataset/pulse.feather` (**쓰기**) | 12,557,968 B, git 추적 | 렌더마다 다시 씀(B-2) |
| 181 | `output/pulse.rds` | 5,930,981 B, git 추적 | 9장 산출물(F-1) |
| 1655 | `dataset/gapminder/gapminder-exercise.xlsx` | 4,154,338 B, 시트 4개: region 234×3, country_pop 59,297×4, gdpcap 46,995×4, lifeexp 56,130×4 | 원자료 `_GM-Population - Dataset - v6.xlsx`, `GM-GDP per capita - Dataset - v26.xlsx`, `GM-Life Expectancy- Dataset - v11.xlsx` 가 같은 폴더에 있으나 가공 스크립트는 없음 |
| 1758 (주석) | `dataset/gapminder/gapminder_filter.csv` | 846,193 B, 13,159행 × 7열 | 현재 파이프라인 결과와 `all.equal` TRUE. 11장 시각화가 읽음(F-2) |
| 2039 | `dataset/tidyr-wide-ex01.csv` | 1,237 B, 3행 × 21열 | 주석 코드(2024–2034)로 재생성하면 `all.equal` TRUE |
| — | 내장 자료 | `iris`, `mtcars`, `ggplot2::mpg`, `dplyr::starwars`, `nycflights13`(flights 336,776×19, airlines, airports, planes, weather), `tidyr::billboard`/`who`/`table2`/`table3`/`table5`, `gapminder` | — |

**개인정보 의심 파일**: `dataset/students.txt`, `dataset/room-allocation.txt`, `dataset/StudentList.xls`, `data/stat-students.xlsx` 는 이 장에서 **쓰지 않는다**(grep 확인). 이 감사에서도 열지 않았다.

**`dataset.zip`** (10,755,387 B, 2021-03-04, 15파일): 이 장의 파일 중 `pulse.csv`, `pulse.feather`, `titanic3.csv` 만 들어 있다. `gapminder/`, `tidyr-wide-ex01.csv`, `output/pulse.rds` 가 없어 해당 줄이 실패한다(B-15).

**패키지** (설치·CRAN 모두 확인)

| 패키지 | 줄 | 설치 / CRAN | 비고 |
|---|---|---|---|
| tidyverse | 28 | 2.0.0 / 2.0.0 | 핵심 9개(lubridate 포함) |
| dplyr · tidyr · readr · tibble | — | 1.2.1 · 1.3.2 · 2.2.0 · 3.3.1 (CRAN 동일) | dplyr 1.2.0: `filter_out()`, `when_any()/when_all()`, `recode_values()` 신설, `.by`·`reframe()` stable, `case_match()` soft-deprecated, `summarise()` 다행 반환 defunct |
| ggplot2 · purrr | — | 4.0.3 · 1.2.2 | `size` → `linewidth` 경고(2508, 2518) |
| knitr · rmarkdown · kableExtra | 4, 29, 31 | 1.51 · 2.31 · 1.4.1 (CRAN 1.52 · 2.32 · 1.4.1) | — |
| feather | 178 | 0.4.0 / 0.4.0 | 2025-12 재출시. arrow 래퍼(Imports: arrow ≥ 0.17.0) |
| nycflights13 · gapminder · readxl | 1242 · 1654 · 1653 | 1.0.2 · 1.0.1 · 1.5.0 (CRAN readxl 1.5.0.1) | gapminder 는 로드만 하고 쓰지 않음 |
| 새 12장 후보 | — | testthat 3.3.2 · waldo 0.6.2 · conflicted 1.2.0 · gt 1.3.0 · janitor 2.2.1 · arrow 25.0.0 | — |

**배포본 상태**: 이 장의 공개 페이지는 `data-handling.html`, `tidyverse.html`, `readr.html`(619,008 B), `dplyr.html`(288,361 B), `data-transformation.html`(155,292 B)이며 2023-05-15 에 렌더됐다. 장 원문의 마지막 커밋은 2022-03-08(`9720612`)이라 배포본은 원문과 같다. A-1·A-2·A-3 의 출력, "??"(C-6), 속성 차이 5줄(B-1), `read_csv` 70.0초(B-2)가 모두 배포 중이다.

---

## E. 실행 로그와 구식 API

**실행 요약** (R 4.6.1, 사본)

```
== run_chunks.R --timeout=600: OK 86 / ERROR 0 / EXPECTED-ERROR 2 / NO-ERROR? 0 / SKIP 10   (2분 11초)
   5    153 read_csv-ex         OK              124.0s  (대부분 read_csv("dataset/pulse.csv"))
   7    209 create_tibble-ex2   EXPECTED-ERROR  object 'y' not found        ← 의도(data.frame 은 방금 만든 열을 참조 못 함)
  26    755 (이름 없음)          EXPECTED-ERROR  object 'cty_kpl' not found  ← 의도(transform 재사용 불가. C-18)
  98   2495 (이름 없음)          OK  DEPRECATION: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
  SKIP eval=FALSE 10: 134 read_csv 원형, 432 filter 원형, 574 arrange 원형, 623 select 원형, 859 group_by 체인,
                      1640 install.packages("gapminder"), 1991 pivot_longer·gather 원형, 2226 pivot_wider·spread 원형,
                      2364 separate 원형, 2413 unite 원형
== rmarkdown::render(html_document(keep_md = TRUE)): 오류 0 (2분 14초)
   경고 1  : 2508 geom_line(size = 1) deprecation (배포본에도 같은 경고)
   메시지  : summarise() regroup 4회(853, 1033, 2320, 2341) · Loading required package 4회(178, 1242, 1653, 1654)
             · read_csv 열 명세 2회(155, 182)
   출력 시간: read.csv 5.167 s · readRDS 0.082 s · read_csv 116.308 s · read_feather 0.097 s
```

- `run_chunks.R` 은 메시지를 숨기므로 B-12 의 그룹 메시지는 렌더로만 보인다.
- superseded 함수는 경고를 내지 않는다(deprecated 가 아님). 실행 로그가 깨끗하다고 현행 코드라는 뜻은 아니다.
- `eval=FALSE` 10개 중 실행할 수 있는 코드는 859(체인)와 1640(설치)뿐이다. 나머지는 원형이라 `seprate(` 오타(2366)와 unite 원형 끝 쉼표(2418)가 드러나지 않는다.

**구식·권장 대체** (코드 줄 기준. 동작 차이는 모두 이 감사에서 실행해 확인)

| 줄 | 현재 | 대체 | 동작 차이 |
|---|---|---|---|
| 384, 1179 | `summarise_all(mean)`, `summarise_all(list(min = ~ min(.), max = ~ max(.)))` | `summarise(across(everything(), mean))`, `across(everything(), list(min = min, max = max))` | **열 순서**: scoped 는 함수 우선(`manufacturer_min, model_min, …`), `across()` 는 열 우선(`manufacturer_min, manufacturer_max, …`) |
| 403, 1188, 2458 | `summarise_at(vars(…), list(mean = …, sd = …))` | `summarise(across(c(…), list(mean = mean, sd = sd)))` | 같은 열 순서 차이(`all.equal` → "Names: 6 string mismatches"). 그룹이 두 개 이상이면 `across()` 판만 regroup 메시지를 낸다 |
| 1204 | `summarise_if(~ is.numeric(.), …)` | `summarise(across(where(is.numeric), …))` | 열 순서 차이 |
| 1140 | `mutate_all(~ factor(.))` | `mutate(across(everything(), factor))` | 없음(`identical` TRUE) |
| 1147, 1154 | `mutate_at(vars(…), ~ . * kpl)` | `mutate(across(c(cty, hwy), \(x) x * kpl))` | 없음 |
| 1162, 1199, 1733, 1755 | `mutate_if(~ is.character(.), ~ factor(.))` | `mutate(across(where(is.character), factor))` | 없음(Gapminder 자료에서 `identical` TRUE) |
| 1110 | `select_all(~ toupper(.))` | `rename_with(toupper)` | 없음(`identical` TRUE) |
| 1116, 1139 | `select_if(~ is.character(.), ~ toupper(.))` | `select(where(is.character)) \|> rename_with(toupper)` | 없음(`identical` TRUE) |
| 1122 | `select_at(vars(model:cty), ~ toupper(.))` | `select(model:cty) \|> rename_with(toupper)` | 없음(`identical` TRUE) |
| 1075, 1080 | `filter_all(all_vars(. > 100))` / `any_vars` | `filter(if_all(everything(), \(x) x > 100))` / `if_any` | 없음. dplyr 1.2.0 에서 입력 0개일 때 `if_any()` FALSE, `if_all()` TRUE 로 확정 |
| 1086 | `filter_at(vars(gear, carb), ~ . %% 2 == 0)` | `filter(if_all(c(gear, carb), \(x) x %% 2 == 0))` | 없음(8행) |
| 1093 | `filter_if(~ all(floor(.) == .), all_vars(. != 0))` | `filter(if_all(where(\(x) all(floor(x) == x)), \(x) x != 0))` | 없음(`identical` TRUE, 7행) |
| 917 | `top_n(5, cty)` | `slice_max(cty, n = 5)` | `top_n()` 은 정렬하지 않고 `slice_max()` 는 정렬한다. 동점은 둘 다 포함(hwy 기준 n = 5 → 6행), `with_ties = FALSE` 로 5행. `top_n(5)` 처럼 `wt` 를 빼면 마지막 열(class)을 기준으로 삼는다 |
| 954 | `sample_n(3)` | `slice_sample(n = 3)` | 같은 시드에서 `identical` TRUE |
| 957 | `sample_frac(0.05)` | `slice_sample(prop = 0.05)` | **행 수**: 234 × 0.05 = 11.7 을 `sample_frac` 은 12행(반올림), `slice_sample` 은 11행(내림) |
| 797 | `transmute()` | `mutate(…, .keep = "none")` | 없음(`identical` TRUE) |
| 845–855, 1032–1036, 2319–2320, 2340–2341 | `group_by() %>% summarise()` | `summarise(…, .by = c(…))` | `.by` 결과는 그룹이 없고 **처음 나온 순서**다(group_by 는 정렬). mtcars am 요약에서 group_by 는 automatic → manual, `.by` 는 manual → automatic |
| 1965, 2086 | `` gather(year, gdp_cap, `2001`:`2020`) `` | `` pivot_longer(`2001`:`2020`, names_to = "year", values_to = "gdp_cap") `` | **행 순서**: gather 는 열(연도) 우선, pivot_longer 는 행(국가) 우선. `identical` FALSE, 정렬 후 TRUE. gather 순서가 필요하면 `cols_vary = "slowest"` |
| 2236, 2271 | `spread(year, gdp_cap)` | `pivot_wider(names_from = year, values_from = gdp_cap)` | spread 는 행(id)과 새 열 이름을 **정렬**하고, pivot_wider 는 처음 나온 순서를 따른다(toy 자료: `abc; x,y` 대 `bac; y,x`) |
| 2383, 2390, 2443, 2475 | `separate(rate, into, sep = "/")`, 기본 `sep` | `separate_wider_delim(rate, "/", names = c(…))` | `convert` 인수가 없어 결과가 문자형이다(수치 변환은 따로). 조각 수가 맞지 않으면 경고 대신 **오류**(`too_many`/`too_few`) |
| 2401 | `separate(year, …, sep = -2)` | `separate_wider_position(year, c(century = 2, year = 2))` | 입력이 수치형이면 문자로 바꾼 뒤 적용 |
| 2130, 2200 | `names_ptypes` 로 형 변환 | 변환은 `names_transform`, 확인은 `names_ptypes` | ptypes 는 수준 누락 시 오류, transform 은 조용히 NA(B-9) |
| 1462–1560, 1537, 1547, 1558, 1685, 1688, 1741, 1744 | `by = "key"`, `by = c("origin" = "faa")` | `join_by(key)`, `join_by(origin == faa)` + `relationship`, `unmatched` | 없음 |
| 1668–1670 | `eval(parse(text = …))` | 리스트 그대로 또는 `list2env()` | 없음 |
| 2508, 2518 | `geom_line(size = 1)` | `geom_line(linewidth = 1)` | 경고 제거 |
| 178–183 | `feather::write_feather/read_feather` | 삭제(11장 `#sec-formats`) 또는 `arrow::write_feather()` | feather 0.4.0 은 arrow 래퍼 |
| 4, 28, 29, 31, 178, 1242, 1653, 1654 | `require()` | `library()` | 패키지가 없으면 경고 대신 오류 |
| 373 외 103줄 | `%>% print`, `%>% glimpse` 등 괄호 없는 RHS | `\|> print()` 또는 삭제 | `\|>` 는 괄호 없는 RHS 를 파싱 오류로 거부(C-3) |
| (없음) | — | `filter_out()` (dplyr 1.2.0) | 조건이 NA 인 행을 **남긴다**(titanic `age < 18` → 1,155행) |

**자료·환경이 가린 오류** (배포본에서 정상으로 보인 이유)

| 항목 | 무엇이 가렸나 |
|---|---|
| A-1 am/vs | 두 분류의 평균 차이 방향이 같아 수치가 그럴듯함 |
| A-2 mean_hwy | 값의 크기(13–28)가 연비로 자연스러움 |
| A-3 arrange | 예제가 한 회사만 남김 |
| B-1 all.equal | 값은 같고 속성만 달라 "대충 같다"로 읽힘 |
| B-4 weather 키 중복 | 중복 시각(2013-11-03 01시)에 운항 편이 0편 |
| B-9 names_ptypes | who 의 모든 값이 levels 안에 있음 |
| B-10 NA | mpg·mtcars·iris 에 결측이 없음 |
| B-13 separate | mtcars 열 이름에 밑줄이 없음 |
| B-15 zip | 저장소가 xlsx·csv·`output/` 을 git 으로 추적 |

---

## F. 다른 장으로 번지는 문제

1. **`output/pulse.rds`(181)와 `dataset/pulse.feather`(180)** — 9장 산출물에 기대고, 추적 중인 12.5 MB 이진 파일을 렌더마다 바꾼다. 09 감사 B-9·F-1 과 같은 문제라 함께 처리한다. 새 12장에서는 이 청크를 없애면 의존도 사라진다.
2. **`11-data-visualization.Rmd:2355, 3395`** 가 `dataset/gapminder/gapminder_filter.csv` 를 읽는다. 이 파일은 1758 의 주석 처리된 `write_csv()` 로 만든 것이고, 현재 파이프라인 결과와 `all.equal` TRUE(13,159행 × 7열)다. 새 12장에서 파이프라인을 바꾸면(year 정수화, 지역 오타 수정, 1인당 GDP 정의 변경) 새 13장(시각화)의 입력과 어긋난다. 함께 재생성하고 대조한다.
3. **뒤 장에 옛 관용구가 남아 있다**: `11-data-visualization.Rmd:2109` `spread()`, `:3711`·`:3753` `mutate_at()`, `12-basic-stat-analysis.Rmd:1150`·`:1511` `mutate_if()`, `:1472`·`:1489` `mutate_at()`. 새 12장이 scoped 동사를 가르치지 않으면 이 코드가 설명 없이 남는다. 부록 D 대응표로 참조하거나 해당 장 개편 때 함께 현행화한다.
4. **새 11장과 중복·충돌**: `11-data-import-export.qmd` 가 readr(`#sec-base-vs-readr`, `#sec-col-types`, `#sec-na-numbers`)와 저장 형식(`#sec-formats`)을 측정값과 함께 다룬다. 현 122–188 은 새 12장에서 삭제하고 교차 참조한다. 124 의 깨진 `\@ref(data-import-export)` 는 `@sec-read-text` 로 바꾼다.
5. **`\@ref(logical)`(422)** 은 Quarto 전환 때 새 2장 앵커로 갱신한다.
6. **`options(linewidth = 60)` 무효**는 모든 장 공통이다(CLAUDE.md 시범 전환 7번).
7. **이 장의 공개 URL** (legacy 보존 대상): `data-handling.html`, `tidyverse.html`, `readr.html`, `dplyr.html`, `data-transformation.html`. 앵커는 `#tibble`, `#pipe-op`, `#dplyr-filter` … `#dplyr-verb-variant-adverb`, `#dplyr-join`, `#ex-gapminder`, `#tidy-data`, `#long-format`, `#wider-format`, `#separate-unite`, `#saparate`, `#unite`.
8. **부록 D(dplyr·tidyr 동사 참조표)**: E 절 대체표를 "옛 코드 → 현행 코드" 대응표로 싣는다. 검색 결과, 옛 교재, 생성형 AI 출력에서 옛 관용구를 만날 수 있기 때문이다[추론. 실제 LLM 출력 사례는 수집한 뒤에만 싣는다, CLAUDE.md 규칙 7].
9. **6장(검증)·16장(AI와 함께)**: G-3 의 결합·요약 검증 루틴(행 수, 키, NA, 외부 합계)을 6장의 `testthat` 과 공유하고, 16장의 "AI 코드 버그 찾기" 소재로 넘긴다.

---

## G. 새 12장 재구성 제안 (교수법)

재구성안 5절 대응표의 이 장 행은 "12 | 데이터 핸들링 | 10 | 현행화. `across()`, `pivot_*()`, `.by`"이고, 분량 목표는 2,530 → 1,800줄이다(7절). 동사 사전은 부록 D 로 옮긴다. 이 감사는 현행화와 함께 각 절의 동작을 **"함수 소개"에서 "변환하고 → 불변식으로 확인한다"로** 바꾸기를 제안한다. AI 는 `left_join()` 한 줄을 즉시 써 준다. 그러나 행이 늘었는지, 짝 없는 키가 NA 로 남았는지, 평균이 무엇의 평균인지는 학생이 확인해야 한다. A-1·A-2·A-3 이 보여 주듯 사람이 쓴 코드도 마찬가지다.

### G-1. 절별 처리

| 현 절 (줄) | 처리 | 이유 |
|---|---|---|
| 도입·Tidyverse (34–121, 88줄) | 압축(약 30줄), 일상의 예로 시작 | "엑셀에서 필터·정렬·피벗 테이블을 써 본 경험 → 같은 동작을 코드로 적으면 다시 실행하고 검증할 수 있다". 핵심 패키지 9개는 한 줄로(C-5). 링크 교체(C-4), RStudio → Posit(C-2) |
| readr (122–188) | **삭제**, 11장 교차 참조 | 11장이 이미 다룬다. 속도 주장은 틀렸고 렌더 비용도 크다(B-2) |
| tibble (189–251) | 재작성: "tibble 과 data.frame: 조용히 달라지는 곳" | B-7. 부분 일치, `[` 결과, 재사용, 행 이름 손실, 이름 수정. 3장 자료구조와 분담 |
| dplyr 개요·비교표 (253–349) | 압축 + **행 수 불변식 표** 신설 | "동사는 표를 받아 표를 돌려준다. 각 동사가 행 수를 어떻게 바꾸는지 알면 결과를 검증할 수 있다"(G-3). 동사 사전은 부록 D |
| 파이프 (351–407) | 재작성 | `\|>` 기본, `%>%` 와의 차이(자리표시자 `_` 대 `.`, 오른쪽은 함수 호출이어야 함. 이 장의 103줄이 여기에 걸림, C-3). A-1 을 버그 찾기로 |
| filter·arrange·select·mutate·summarise (410–828) | 재구성 | 한 자료로 흐름을 잇고 동사마다 예측 문항을 둔다. **NA 소절 신설**(B-10): `filter()` 대 `[`, `filter_out()`, `mean(na.rm = )`, 행 수 합 대조. titanic·starwars 처럼 결측이 있는 자료로 |
| group_by (829–884) | 재작성: "그룹과 `.by`" | A-3 수정. `.by` 기본, `.groups`, 그룹 잔존(B-12), `.by` 결과 순서(E) |
| 유용한 함수 (885–1048) | 현행화·압축 | `slice_*()` 계열(동점, 행 수 반올림 차이), `distinct()`, `count()`/`add_count()`, `rename_with()`. A-2 수정 |
| 부가 기능 scoped (1049–1212) | **대체**: "여러 열에 같은 작업: `across()`" | `across()`/`where()`/`if_any()`/`if_all()`/`pick()`. 열 순서·`.names` 같은 동작 차이를 명시. 옛 코드 대응표는 부록 D(B-11) |
| 데이터 연결 (1213–1600) | **강화**, 장의 검증 중심 | 키 개념을 일상의 예로 시작하고 B-3 을 바로잡는다. `join_by()`, 키 유일성 확인, `relationship`/`unmatched`, **`anti_join()` 으로 짝 없는 키 찾기**, 결합 전후 행 수·NA, `by` 생략 함정(B-4). 코드북 표 5개(약 170줄)는 `glimpse()` 와 도움말 링크로 압축 |
| Gapminder 확장 예제 (1602–1773) | 재구성: "통합 사례: 세 표를 합쳐 요약하고 원자료와 대조" | `eval(parse())` 제거(B-14). 단계마다 행 수·NA 기록. 지표 이름·단위 정정(B-6). **가중 평균 대 단순 평균**, Gapminder world 시트와 대조(B-5). 자료 버전 명시 |
| Tidy data (1782–1976) | 재작성 | tidy ≠ long(B-8). "무엇이 변수인가"를 판단하는 연습이 중심. preg 예 수정(C-32) |
| Long/Wide (1978–2352) | 현행화 | `pivot_longer()`/`pivot_wider()` 만. `gather`/`spread` 는 부록 D. 왕복을 `expect_equal()` 로 확인(B-1, 11장 `#sec-round-trip`). transform 대 ptypes(B-9). who 의 Namibia NA(C-35). 요약표는 `.by` + `pivot_wider(names_glue = )` + `kable()`/gt |
| Separate/unite (2355–2482) | 현행화 | `separate_wider_delim/position/regex()` (조각 수 불일치를 오류로 알려 주는 검증 도구), `unite()`. mtcar_summ 은 `pivot_longer(names_pattern = )` 로(B-13) |
| ggplot trailer (2485–2525) | 13장(시각화)으로 이관 | 남긴다면 `linewidth`, y축 이름, wide 그대로 그리는 대조를 실제로 보인다(C-39) |
| (신설) 변환한 뒤 확인하기 | 신설 | G-3 루틴을 한 소절로. 6장·11장 상호참조 |
| (신설) AI와 함께 | 신설 | G-4 |
| (신설) 연습문제 | 신설 | 읽기 문항을 절반으로(A-1·A-2·A-3·B-10 변형) |

### G-2. 예측(PRIMM) 문항 후보 — 모두 이 감사에서 실제 결과를 확인함

- **버그 찾기(A-1)**: 398줄 표의 자동 변속기 mpg 평균은 16.6, 2461줄 표는 17.1 이다. 어느 쪽이 맞나? → 17.1. 398줄은 `vs` 를 `am` 이라 부름
- **이름과 계산(A-2)**: 1036줄 표의 audi 1999 `mean_hwy` 17.1 은 무엇의 평균인가? → 시내 연비. 실제 고속 연비 평균은 26.1
- `mpg |> group_by(manufacturer) |> arrange(cty)` 의 첫 행은 audi 일까? → dodge. `arrange()` 는 그룹을 무시함(A-3)
- titanic 에서 `titanic[titanic$age < 18, ]`, `subset(titanic, age < 18)`, `filter(titanic, age < 18)` 의 행 수는 같을까? → 417 / 154 / 154
- `nrow(filter(t, age < 18)) + nrow(filter(t, age >= 18))` 는 1,309 일까? → 1,046. 그러면 `filter_out(t, age < 18)` 은? → 1,155
- `top_n(mpg, 5, hwy)` 는 몇 행일까? → 6(동점). `slice_max(hwy, n = 5, with_ties = FALSE)` → 5
- `sample_frac(mpg, 0.05)` 와 `slice_sample(mpg, prop = 0.05)` 의 행 수는? → 12 / 11
- `left_join(flights2, planes2, join_by(tailnum))` 는 행이 늘까? → 336,776 그대로. 그러면 model 이 NA 인 행은? → 52,606
- `flights |> left_join(planes)` 처럼 `by` 를 빼면? → year 와 tailnum 으로 결합, 332,146행이 NA
- 키가 중복된 두 표를 결합하면? → 행이 늘고 `many-to-many` 경고(toy 3행 × 4행 → 5행)
- `all.equal(wide_01, wide_ex_01)` 은 TRUE 일까? → 속성 차이 5줄. `all.equal(as_tibble(wide_01), wide_ex_01)` → TRUE
- `data.frame(`2000` = "year")` 의 열 이름은? → `X2000`. `as_tibble(mtcars)` 에 차종 이름이 남을까? → 사라짐
- `summarise_at(vars(a, b), list(mean, sd))` 를 `across()` 로 바꾸면 열 순서가 같을까? → 다름
- `summarise(.by = am)` 과 `group_by(am) |> summarise()` 의 행 순서는? → manual 먼저 / automatic 먼저
- `separate("gdp_cap_mean", c("variable", "statistic"))` 은? → gdp / cap + 경고. `separate_wider_delim()` → 오류
- `names_ptypes` 에서 수준 하나를 빠뜨리면? → 오류. 같은 일을 `names_transform` 으로 하면? → 14,304행이 조용히 NA
- 2020년 동아시아 1인당 GDP 를 국가 값 단순 평균과 인구 가중으로 구하면? → 30,459 / 20,627
- `library(MASS)` 뒤 `select(mpg, cty)` 는? → `unused argument (cty)`
- `read_csv()` 는 `read.csv()` 보다 항상 빠를까? → 69행 × 20,000열 파일에서 116초 대 5.2초(B-2, 11장과 공유)

### G-3. 검증 활동 (6장·11장과 상호참조)

1. **행 수 불변식**: `filter()` ≤ n, `arrange()` = n(순서만 바뀜), `select()`·`mutate()`·`rename()` = n, `summarise()` = 그룹 수, `left_join()` ≥ nrow(x)(= 이면 다대일), `pivot_longer()` = nrow × 선택 열 수 − (`values_drop_na` 로 뺀 수). 변환 뒤 `stopifnot(nrow(after) == nrow(before))` 한 줄로 확인한다.
2. **키 검사**: `x |> count(key) |> filter(n > 1)` 가 0행인지, `anti_join(x, y, join_by(key))` 로 짝 없는 키가 몇 개인지 본다. 결합에는 `relationship = "many-to-one"` 을 명시한다.
3. **NA 감사**: 변환 전후의 `colSums(is.na(df))`. 요약에는 `n = n()`, `n_na = sum(is.na(x))` 를 함께 둔다.
4. **외부 합계와 대조**: Gapminder world 시트의 2020년 1인당 GDP 16,596 대 국가 합산 가중 16,488, 세계 인구 7,794,798,729 대 국가 합 7,786,445,859(−0.1%). 11장 `#sec-total-row` "합계 행은 참값이다"와 같은 논리다.
5. **왕복**: wide → long → wide 결과를 `testthat::expect_equal()` 로 확인한다. `check.attributes = FALSE` 는 열 이름 변경을 놓친다는 반례와 함께 보인다.
6. **대안 구현 대조**: base `aggregate()`/`tapply()` 와 `summarise(.by)` 를 비교한다. NA 처리 차이까지 드러난다(`aggregate()` 수식 인터페이스는 NA 행 제외).

### G-4. "AI와 함께" 절 제안

- 위치는 장 끝, 연습문제 앞이다. ID 는 `sec-ai-handling`(11장 `sec-ai-import` 와 같은 형식).
- 과제 명세 후보는 두 가지다. (1) "nycflights13 에서 항공기 제조사별 운항 편수와 평균 출발 지연을 구하는 코드" (2) "Gapminder 자료로 2020년 지역별 1인당 GDP 와 기대수명을 요약하는 코드".
- 검증 항목(1번 과제 기준, 모두 확인한 값): 결합 전후 행 수(336,776), `planes` 에 없는 tailnum(722개, 52,606행)을 어떻게 처리했나, `by` 를 생략해 year 까지 결합하지 않았나(332,146행 NA), `dep_delay` 결측 8,255행, 제조사 표기 불일치(`AIRBUS` 대 `AIRBUS INDUSTRIE`, `MCDONNELL DOUGLAS` 계열 3가지 표기)를 합쳤나. 2번 과제는 가중 대 단순 평균, world 시트 대조, 지역 결측 수.
- 흔한 오류 후보는 **실제 LLM 응답으로 확인한 뒤에만 싣는다**(CLAUDE.md 규칙 7): superseded 관용구(`mutate_at`, `gather`, `top_n`), `group_by()` 잔존, `mean()` 의 NA, `by` 생략, 다대다 결합, 비율의 단순 평균, `separate()` 오분할.
- 개인정보: 명단·성적 파일을 프롬프트에 붙이지 말라는 `rmdwarning` 을 둔다. 파일 **구조**(열 이름과 가짜 값 3행)만 건네는 연습을 넣는다. 저장소의 개인정보 의심 파일 4종은 쓰지 않는다.

### G-5. 일상의 예를 먼저

- `filter()` 와 NA: 출석부에서 3학년만 고른다. 학년 칸이 빈 학생은 어느 쪽에도 들어가지 않는다.
- `summarise()` 와 NA: 결석생의 점수 칸이 비었을 때 반 평균은 무엇이 되나.
- 결합과 키: 학번으로 성적표와 연락처 명단을 합친다. 같은 학번이 두 줄이면? 명단에 없는 학번은? (예시용 가상 자료로)
- 가중 평균: 반 평균들의 평균은 전체 평균이 아니다(반 인원이 다를 때). B-5 의 지역 1인당 GDP 와 같은 구조다.
- tidy: 엑셀 가로형 성적표(과목이 열) ↔ 세로형(과목, 점수). "한 칸에 한 값"이 아닌 칸(`홍길동/3학년`).
- `group_by()`: 반별로 나눠 줄 세우기와, 전체를 줄 세운 뒤 반 표시만 붙이기의 차이(A-3).

### G-6. 자료 선택

- mpg·mtcars 는 결측이 없어 NA 교재로 부적합하다. titanic3(age 결측 263)·starwars(height 결측 6, gender 결측 4)·who(Namibia `iso2`)를 함께 쓴다.
- nycflights13 은 R4DS 2판과 같은 자료라 유지한다. 코드북 표 5개는 `glimpse()` 와 도움말 링크로 압축한다.
- Gapminder 는 2019-12~2020-01 공개본(인구 v6, GDP v26, 기대수명 v11)이다. 2020년 값은 코로나 이전의 추계다. 현재 Gapminder 문서 페이지에는 인구 v9, 기대수명 v14 가 올라와 있다[재현: 페이지 문자열]. 갱신하거나, 유지한다면 버전·단위·추계임을 명시한다. 원자료 3개로 `gapminder-exercise.xlsx` 를 만드는 스크립트가 저장소에 없어 가공 과정을 재현할 수 없다. 생성 스크립트를 두기를 권한다(11장 `make-ch11-data.R` 방식).
- `pulse.csv` 속도 예제는 삭제한다(11장 소관).
- `tidyr-wide-ex01.csv` 는 파이프라인에서 재생성됨을 확인했다. 유지해도 된다.

---

## H. 작업 순서와 작업량

1. **현 10장이 공개 사이트에 남아 있는 동안 고칠 것** (각 5분 안팎): A-1(`vs` → `am`), A-2(`mean_hwy` → `mean_cty`), A-3(867 문장과 예제), B-3(1440–1441 두 줄), B-1(2267·2273 에 `as_tibble()`), C-6(124 `\@ref`), C-35(who "14-24"). 재렌더 전에 B-2 청크(176–183)를 지우거나 `eval=FALSE` 로 두지 않으면 렌더가 2분 늘고 추적 파일 `dataset/pulse.feather` 가 바뀐다.
2. B-2·B-15 의 `output/`·`pulse.feather` 의존은 09 감사 B-9 와 함께 처리한다.
3. 새 12장은 G 의 구성을 따른다. B·C 대부분은 재작성으로 해소된다. Gapminder 파이프라인을 바꾸면 F-2(시각화 장 입력)를 함께 재생성한다.
4. 뒤 장의 옛 관용구(F-3)는 부록 D 를 쓸 때 함께 정리한다.
5. CLAUDE.md 진행 상태 표의 현 10장 행을 `감사 완료` 로 갱신한다(이 감사에서는 보고서 외 파일을 편집하지 않았다).

- 작업량: A 3곳 / B 15곳 / C 42곳 / 신규 작성: tibble 차이(검증 관점), NA 와 행 손실, 그룹과 `.by`, 여러 열에 같은 작업(`across()`), 키와 결합 검증, 통합 사례(가중 평균·외부 합계 대조), tidy 판단, 변환한 뒤 확인하기 — 소절 약 8개 + "AI와 함께" 1절 + 연습문제(읽기 문항 절반) + 부록 D 대응표

---

## I. 측정값과 재현 코드 (새 12장에서 재사용)

측정 기기는 AMD Ryzen Threadripper 2990WX, NVMe SSD 다(09 감사와 같음). **시간의 절대값은 학생 노트북과 다르다.** 순서와 배율만 재사용하고, 본문에 실을 시간은 렌더 때 다시 잰다. 코드는 저장소 루트(또는 사본)에서 실행한다. 파일 쓰기는 없다.

### I-1. 치명 3건

```r
library(tidyverse)
# A-1: vs 를 am 이라 부른 표 대 올바른 표
mtcars |> mutate(am = factor(vs, levels = 0:1, labels = c("automatic", "manual"))) |>
  summarise(n = n(), mpg = mean(mpg), .by = am)    # automatic 18 / 16.6, manual 14 / 24.6
mtcars |> mutate(am = factor(am, levels = 0:1, labels = c("automatic", "manual"))) |>
  summarise(n = n(), mpg = mean(mpg), .by = am)    # manual 13 / 24.4, automatic 19 / 17.1 (.by 는 처음 나온 순서)
table(vs = mtcars$vs, am = mtcars$am)
# A-2: 이름과 계산
mpg |> summarise(mean_hwy = mean(cty), true_hwy = mean(hwy), .by = c(manufacturer, year)) |>
  arrange(manufacturer, year) |> head(3)          # audi 1999 17.1/26.1, audi 2008 18.1/26.8, chevrolet 1999 15.1/21.6
# A-3: arrange 는 그룹을 무시
mpg |> group_by(manufacturer) |> arrange(cty) |> pull(manufacturer) |> head(12)
mpg |> group_by(manufacturer) |> arrange(cty, .by_group = TRUE) |> pull(manufacturer) |> head(12)
```

### I-2. 동일성 확인 (B-1)

```r
wide_01 <- read_csv("dataset/tidyr-wide-ex01.csv", show_col_types = FALSE)
w <- wide_01 |> pivot_longer(-country, names_to = "year", values_to = "gdp_cap") |>
  pivot_wider(names_from = year, values_from = gdp_cap)
all.equal(wide_01, w)                          # 속성 차이 5줄 (spec_tbl_df)
all.equal(as_tibble(wide_01), w)               # TRUE
testthat::local_edition(3); testthat::expect_equal(w, wide_01)   # 통과
isTRUE(all.equal(rename(w, Country = country), wide_01, check.attributes = FALSE))  # TRUE ← 이름 변경을 놓침
```

### I-3. NA 와 행 손실 (B-10)

```r
titanic <- read_csv("dataset/titanic3.csv", show_col_types = FALSE)
c(bracket = nrow(titanic[titanic$age < 18, ]),       # 417 (263행이 모두 NA)
  subset  = nrow(subset(titanic, age < 18)),         # 154
  filter  = nrow(filter(titanic, age < 18)),         # 154
  both    = nrow(filter(titanic, age < 18)) + nrow(filter(titanic, age >= 18)),  # 1046 ≠ 1309
  out     = nrow(filter_out(titanic, age < 18)))     # 1155 (dplyr ≥ 1.2.0)
titanic |> summarise(n = n(), n_age = sum(!is.na(age)), mean_age = mean(age),
                     mean_age_rm = mean(age, na.rm = TRUE), .by = pclass)
unique(who$country[is.na(who$iso2)])                  # "Namibia"
```

### I-4. 결합 검증 (B-3, B-4)

```r
library(nycflights13)
planes |> count(tailnum) |> filter(n > 1)                           # 0행: 기본키
weather |> count(origin, year, month, day, hour) |> filter(n > 1)   # 3행: 2013-11-03 01시
weather |> count(origin, time_hour) |> filter(n > 1)                # 0행
flights2 <- flights |> select(year:day, hour, origin, dest, tailnum, carrier)
j <- flights2 |> left_join(select(planes, tailnum, model), join_by(tailnum), relationship = "many-to-one")
c(before = nrow(flights2), after = nrow(j), na_model = sum(is.na(j$model)))   # 336776 336776 52606
flights2 |> distinct(tailnum) |> anti_join(planes, join_by(tailnum)) |> nrow() # 722
z <- flights |> left_join(planes)            # 메시지: Joining with `by = join_by(year, tailnum)`
sum(is.na(z$manufacturer))                   # 332146
```

### I-5. 가중 평균과 외부 합계 (B-5, B-6)

```r
library(readxl)
p <- "dataset/gapminder/gapminder-exercise.xlsx"
L <- p |> excel_sheets() |> set_names() |> map(\(s) read_excel(p, sheet = s))
c2020 <- L$country_pop |> inner_join(L$gdpcap, join_by(iso == iso_code, country, year)) |> filter(year == 2020)
c(weighted   = sum(c2020$gdp_total) / sum(c2020$population),        # 16488
  unweighted = mean(c2020$gdp_total / c2020$population))            # 19281
read_excel("dataset/gapminder/GM-GDP per capita - Dataset - v26.xlsx",
           sheet = "data-for-world-by-year") |> filter(time == 2020) # Income per person 16596
```

2020년 지역별(22개 중 일부) 결과는 다음과 같다.

| 지역 | 국가 수 | 단순 평균 | 인구 가중 |
|---|---:|---:|---:|
| Eastern Asia | 7 | 30,459 | 20,627 |
| Eastern Africa | 18 | 4,692 | 2,235 |
| Middle Africa | 9 | 6,080 | 2,618 |
| Caribbean America | 12 | 15,337 | 9,921 |
| Northen America(원자료 표기) | 2 | 51,032 | 56,200 |
| Eastern Europe | 10 | 23,683 | 24,136 |

### I-6. 대체 API 의 동작 차이 (E)

```r
set.seed(1); nrow(sample_frac(mpg, 0.05)); set.seed(1); nrow(slice_sample(mpg, prop = 0.05))   # 12, 11
names(summarise_all(mpg, list(min = ~ min(.), max = ~ max(.))))[1:3]           # manufacturer_min model_min displ_min
names(summarise(mpg, across(everything(), list(min = min, max = max))))[1:3]   # manufacturer_min manufacturer_max model_min
m <- mtcars |> mutate(am = factor(am, labels = c("automatic", "manual")))
m |> group_by(am) |> summarise(mpg = mean(mpg)) |> pull(am)   # automatic manual
m |> summarise(mpg = mean(mpg), .by = am) |> pull(am)         # manual automatic
d <- tibble(id = c("b", "a", "c", "b", "a", "c"), k = rep(c("y", "x"), each = 3), v = 1:6)
spread(d, k, v); pivot_wider(d, names_from = k, values_from = v)   # abc; x,y  대  bac; y,x
tibble(stat = "gdp_cap_mean") |> separate(stat, c("variable", "statistic"))       # gdp / cap + 경고
try(tibble(stat = "gdp_cap_mean") |> separate_wider_delim(stat, "_", names = c("variable", "statistic")))  # 오류
```

### I-7. 속도 측정 (B-2, C-13)

| 측정 | 결과 |
|---|---|
| `pulse.csv`(69 × 20,000) 읽기: `read.csv` / `readRDS` / `read_csv` / `read_feather` | 5.167 / 0.082 / 116.308 / 0.097 초 (배포본 2023: 4.847 / 0.088 / 70.006 / 0.293) |
| mpg(234행): `filter()` / `subset()` / `[` | 851 / 94 / 67 µs |
| flights(336,776행): `filter()` / `subset()` | 6.5 / 6.0 ms |
| mpg: `distinct()` / `unique()` | 306 / 1,114 µs |
| toy 3행: `left_join()` / `merge()` | 1,366 / 682 µs |
| flights2 + airlines: `left_join()` / `merge(all.x = TRUE)` | 25 / 819 ms (`merge()` 는 결과를 키로 정렬) |
| flights: `summarise(.by)` 대 `aggregate()` | 12 / 73 ms (`aggregate()` 는 NA 8,255행 제외) |
