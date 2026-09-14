# 감사 보고서: 09-file-import-export.Rmd (현 9장 R 외부 데이터 입출력 → 새 11장 데이터 입출력)

- 감사일 2026-09-14 · R 4.6.1 · readr 2.2.0 · readxl 1.5.0 · knitr 1.51 · Quarto 1.9.38 · 감사자 Claude · 대상 338줄 / 코드 청크 12개
- 실행: 저장소 **사본**에서만 실행했다. `git archive HEAD` 로 장·`dataset/`·`output/` 만 풀어 둔 `$CLAUDE_JOB_DIR/tmp/io_audit/clone` 에서 `run_chunks.R 09-file-import-export.Rmd` → **OK 7 / ERROR 0 / SKIP 5**(모두 eval=FALSE), 6.6초. deprecation 경고 0건. `output/` 을 뺀 사본에서는 **OK 5 / ERROR 2**. 실행 전후 작업 트리의 `output/*`, `dataset/plasma.txt` 등 md5 가 같음을 확인했다
- 방법: 장 정독 → 구식 패턴 grep → 청크 실행(사본 2종) → 본문 주장을 수치로 재현(인코딩 호출 9종, 형식별 크기·읽기 시간, knitr·Quarto 렌더 실험, readxl 인수) → 외부 링크 curl(브라우저 UA, GET) → 로컬 자원 인코딩(`file -i`, `readr::guess_encoding()`)·xlsx 열기 → 배포본(`docs/`, 2023-05-15 렌더)과 2020 아카이브 렌더(`2020/04-data-manupulation.md`) 출력 대조
- 표기: **[재현]** R 4.6.1 에서 실행해 확인함 · **[추론]** 문서·코드 검토에 근거한 판단(실행으로 확인하지 않음)
- 결과: **치명 1 · 중요 10 · 경미 28**. 외부 링크 2건 중 1건 403, 1건은 보관(archived) 처리된 저장소
- 재현 스크립트는 저장소 밖 `/home/user/.claude/jobs/5f9e4386/tmp/io_audit/repro/` 에 두었다(세션이 끝나면 사라질 수 있다). 새 11장에서 다시 쓸 측정값과 코드는 I 절에 인라인으로 실었다

## 요약

현 9장은 텍스트·R 바이너리·Excel 세 형식의 읽기·쓰기 함수를 소개하는 짧은 장이다. 저장소 안에서는 모든 청크가 돌아간다. 문제는 **학생 기기에서 무엇이 일어나는가**와 **본문 주장이 사실인가**에 있다.

- **한글 인코딩 예제가 틀렸다(A-1).** `encoding = "CP949"` 로 읽으라고 가르치지만 `encoding` 은 문자열에 표시만 붙이는 인수다. R 4.6.1(UTF-8)에서 본문의 두 호출은 모두 `invalid multibyte string` 오류를 낸다. 옳은 인수는 `fileEncoding` 이다. 2020년 한국어 Windows(기본 인코딩 CP949)에서는 인수가 무시돼도 결과가 맞았다. 2021년 청크가 `eval=FALSE` 로 바뀐 뒤 배포본은 출력 없이 코드만 보여 준다.
- **사실 오류 5건.** `read.csv()` 의 `sep` 은 고정이 아니다(B-1). RDS 는 텍스트보다 압축률이 높지 않다. 같은 자료를 gzip 한 CSV 가 4.41 MB 로 RDS 5.93 MB 보다 작다(B-2). readxl 은 tidyverse 를 설치할 때 함께 설치된다(B-3). `read_xlsx()` 의 `col_types` 는 `read_csv()` 형식이 아니며 넘기면 오류다(B-4). COVID 자료의 날짜·지표 서술도 실제 파일과 다르다(B-5).
- **학생 환경에서 실패한다.** `output/` 폴더가 없으면 두 청크가 오류를 낸다(B-8). `dataset.zip` 에는 325줄이 읽는 경로가 없다(B-5).
- **워크플로가 위험하다.** `save.image()` → `rm(list = ls())` → `load()` 예제는 knitr 설정 훅 객체까지 지운다. 뒤의 `load()` 가 되살려 줄 뿐이다. `load()` 없이 끝나면 knitr·Quarto 모두 `could not find function "hook_output"` 로 렌더가 멈춘다(B-7).

더 근본적인 결함은 **가져온 자료를 원자료와 대조하는 절차가 없다**는 점이다. 장 전체의 확인 동작은 `str()`·`head()` 뿐이다. 행 수·결측·열 형식·인코딩을 원파일과 맞춰 보지 않는다. 이 장의 자료만으로도 대조가 필요한 사례가 나온다.

- `diabetes_csv.txt` 의 `frame` 빈 칸 12개는 `read.table()` 에서는 `""`, `read_csv()` 에서는 `NA` 가 된다.
- `readr::read_tsv()` 는 CP949 파일을 경고 없이 깨진 문자열로 읽고, `problems()` 는 0행이다.
- `fileEncoding = "EUC-KR"` 은 '똠·햏·뷁'이 든 4행 파일을 경고 한 줄만 남기고 2행째에서 멈춘다.

재구성안의 이 장 처리 방침은 "유지. arrow/parquet 추가"다. 이 감사는 한 걸음 더 나가 **"가져온 뒤 확인하기"를 장의 뼈대로** 삼기를 제안한다(G). 결정은 강사에게 남긴다.

---

## A. 치명 — 코드가 본문과 다르게 동작하고, 결과가 그것을 가림

### A-1. `encoding = "CP949"` 로 한글 파일을 읽는 예제 — 인수가 재인코딩하지 않아 현행 R 에서 전부 오류, `eval=FALSE` 가 가림 [재현]

**줄** 96–97(원형 주석), 136–154(청크 `read-table-ex1-1`, `error=TRUE, eval=FALSE`)

본문은 "Encoding이 다른 경우"라며 UTF-8 로 읽기(141–145)와 CP949 로 읽기(148–152)를 대비한다. 원형 주석(96–97)은 `encoding` 을 "한글이 입력된 데이터가 있을 때 사용"한다고 적는다. `?scan` 의 정의는 다르다. "If the value is "latin1" or "UTF-8" it is used to mark character strings as known to be in Latin-1 or UTF-8: it is not used to re-encode the input (see fileEncoding)." 즉 `"CP949"` 는 효과가 없다.

`dataset/herb_dic_sample.txt`(CP949, 13줄)로 R 4.6.1, `en_US.UTF-8` 에서 확인한 결과는 다음과 같다.

```
호출                                                          결과
read.table(f, sep = "\t", header = TRUE, encoding = "UTF-8")  오류 invalid multibyte string at '<b0><a1><c0><da>'   ← 본문 141
read.table(..., encoding = "CP949")                           같은 오류                                           ← 본문 148
read.table(...)                         (인수 없음)             같은 오류
read.table(..., colClasses = "character")                     읽히지만 바이트 그대로: validUTF8() FALSE,
   + encoding "CP949" / "UTF-8" / 없음                          nchar() 오류, korean[1] == "가자" FALSE,
                                                               세 호출 결과 identical() TRUE
read.table(..., fileEncoding = "CP949")                       정상: 가자 / 가자육 / 가자피, nchar 2 3 3
readr::read_tsv(f, locale = locale(encoding = "CP949"))       정상
readr::read_tsv(f)                                            오류·경고 없이 깨진 문자열, problems() 0행
```

**왜 2020년에는 맞았나.** 2020 아카이브 렌더(`2020/04-data-manupulation.md:251–292`)를 보면 UTF-8 호출은 `<U+02B8><ed>…` 로 깨지고 CP949 호출은 한글을 정상 출력한다. 당시 한국어 Windows 에서 R 의 기본(native) 인코딩이 CP949 였기 때문이다. `encoding = "CP949"` 가 무시돼도 파일을 기본 인코딩으로 읽으니 결과가 맞았다. 이 기기에서 `localedef -i ko_KR -f CP949` 로 CP949 로캘을 만들어 같은 호출을 돌리면 같은 양상이 나온다. 인수 없음과 `"CP949"` 는 한글이 정상이고, `"UTF-8"` 만 오류다.

R 4.2.0 부터 Windows 도 UTF-8 을 기본 인코딩으로 쓴다(R NEWS 4.2.0, Windows 10 1903 이상). 따라서 지금 학생 기기(Windows·macOS·Linux)에서는 본문의 두 호출이 모두 실패한다[Windows 는 추론]. 청크는 2021-05(`a50366d`)에 `eval=FALSE` 가 됐다. 그 뒤 배포본은 출력 없이 "CP949 로 읽으면 된다"는 코드만 보여 주고 있다.

**수정**: 원형에서 `encoding` 줄을 지우고 `fileEncoding = ""` 를 넣는다("파일의 인코딩을 선언하면 읽으면서 변환"). 청크는 실행되는 청크로 바꿔 실제 출력으로 대비한다.

```r
herb <- read.table("dataset/herb_dic_sample.txt", sep = "\t", header = TRUE,
                   fileEncoding = "CP949")
all(validUTF8(herb$korean))   # TRUE
# readr: read_tsv("dataset/herb_dic_sample.txt", locale = locale(encoding = "CP949"))
```

새 11장에서는 **CP949 ≠ EUC-KR** 도 함께 다룬다(I-3). 확장 한글('똠·햏·뷁')이 든 파일을 `"EUC-KR"` 로 읽으면 base R 은 행을 조용히 잃고 readr 는 오류를 낸다.

---

## B. 중요 — 서술이 틀렸거나, 실린 코드·자료와 어긋나거나, 학생 환경에서 실패함

| # | 줄 | 문제 | 근거 | 수정 |
|---|---|---|---|---|
| B-1 | 232 | "`read.csv()`/`write.csv()`: … 구분자 인수 `sep`이 콤마로 고정" — `read.csv()` 의 `sep` 은 기본값일 뿐 바꿀 수 있다(`read.csv(text = "a;b\n1;2", sep = ";")` 정상). 고정인 쪽은 `write.csv()` 다(`attempt to set 'sep' ignored` 경고). 더 중요한 기본값 차이를 적지 않았다: `header`(read.table FALSE / read.csv TRUE), `quote`(`"'` / `"`), `comment.char`(`#` / 없음), `fill` | 재현 | "`read.csv()` 는 `header = TRUE, sep = ",", quote = "\"", comment.char = ""` 를 기본값으로 둔 `read.table()`. `sep` 이 고정인 것은 `write.csv()`" |
| B-2 | 270–286 (273) | "`read.table()` 보다 읽는 속도가 빠르며, 다른 확장자 명의 텍스트 파일보다 높은 압축율". (1) **압축률**: `pulse.csv` 11,866,553 B, `saveRDS()` 기본 5,930,979 B(50.0%). **gzip CSV 는 4,411,994 B(37.2%)** 로 더 작다. RDS 가 CSV 보다 작은 이유는 형식이 아니라 `saveRDS()` 가 기본으로 gzip 압축하기 때문이다(`compress = FALSE` 면 11,467,666 B, 96.6%). 확장자는 압축률과 무관하다. (2) **속도**: `read.csv` 4.53초 vs `readRDS` 0.080초는 맞다. 그러나 같은 CSV 를 `data.table::fread()` 는 0.22초에 읽고 `readr::read_csv()` 는 119초 걸린다. 차이의 대부분은 형식이 아니라 **리더와 자료 모양**(69행 × 20,000열)에서 온다 | 재현 | "RDS 는 R 객체를 형식 그대로(요인·날짜 포함) 저장하고 기본으로 압축한다"로 바꾸고 크기·시간을 표로 보인다(I-1) |
| B-3 | 299 | "tidyverse 패키지 번들에는 포함되어 있지 않기 때문에 별도 설치 필요" — tidyverse 2.0.0 의 Imports 에 `readxl (>= 1.4.2)` 가 있어 `install.packages("tidyverse")` 로 **설치된다**. `library(tidyverse)` 가 **부착(attach)하지 않을 뿐**이다. 부착되는 패키지는 dplyr, forcats, ggplot2, lubridate, purrr, readr, stringr, tibble, tidyr 이고, 로드 뒤 `exists("read_xlsx")` 는 FALSE | 재현 | "tidyverse 와 함께 설치되지만 `library(readxl)` 로 따로 불러와야 함". haven 도 같다 |
| B-4 | 312–313 | `col_names`, `col_types` 모두 "read_csv()의 인수와 동일한 형태 입력" — `col_types` 는 다르다. `col_types = readr::cols()` 는 `is.character(col_types) is not TRUE`, readr 약식 `"cid"` 는 `Illegal column type: 'cid'` 오류를 낸다. readxl 은 `"skip"`, `"guess"`, `"logical"`, `"numeric"`, `"date"`, `"text"`, `"list"` 로 된 문자 벡터만 받는다 | 재현 | 313 주석을 허용값 목록으로 교체 |
| B-5 | 305, 321–322, 325 | COVID 자료 서술이 파일과 다르다. (1) **날짜**: 305는 "2020년 4월 23일", 321은 "4월 21일자"라 적었다. 325가 읽는 `dataset/covid-19-dataset/owid-covid-data.xlsx` 는 2019-12-31 ~ **2020-05-01**, 14,315행 × 16열, 208개 지역이다. 4-23 까지인 자료는 `dataset.zip` 안의 다른 파일(12,669행)이다. (2) **지표**: 누적·신규 확진자 수, 사망자 수, 백만 명당 수, 검사 수다. 유병률(prevalence)이 아니다(321은 "유별률" 오타). (3) **경로**: 322 주석 `dataset/owid-covid-data.xlsx` 와 325 코드 경로가 다르다. `dataset.zip` 에는 코드 경로가 없어 `` `path` does not exist `` 오류가 난다 | 재현 | 자료 교체를 권장한다(G-6). 유지한다면 날짜·지표·경로를 파일에 맞춘다 |
| B-6 | 104 | "예시에 사용된 데이터들은 Clinical trial data analysis using R [@chen-2010]에서 제공" — Chen & Peace(2010) 자료는 `DBP.txt` 와 `datR4CTDA.xlsx`(14시트: DBP, Ulcer, betablocker, Cimetidine 등)뿐이다. `diabetes_csv.txt` 는 Vanderbilt 당뇨 자료다(hbiostat.org, 403행 × 19열, 원본과 `all.equal` TRUE). Plasma 는 StatLib 자료다(Nierenberg et al. 1989, *Am J Epidemiol* 130:511, 315행 중 앞 10행과 코드북이 원문과 일치). `herb_dic_sample.txt`·`pulse.csv` 는 출처 표기가 없고, COVID 는 OWID 자료다. 인용 키 `chen-2010` 은 `book.bib:92` 에 있다 | 재현(diabetes·plasma 대조) / 추론(나머지) | 자료별 출처를 청크 주석이나 표로 적는다 |
| B-7 | 246–267 | `save.image()` → `rm(list = ls())` → `load()` 예제의 문제 세 가지. (1) bookdown(`envir = globalenv()`)과 Quarto(`share/rmd/execute.R` 의 `env <- globalenv()`) 모두 전역 환경에서 청크를 평가한다. 그래서 `rm(list = ls())` 가 setup 청크의 훅 보조 객체 `def.chunk.hook`·`hook_output` 까지 지운다. 렌더가 되는 것은 뒤의 `load()` 가 되살리기 때문이다. `load()` 없이 청크를 끝내면 `rmarkdown::render()` 와 Quarto 1.9.38 이 모두 `could not find function "hook_output"` 로 중단한다. 배포본 `ls()` 출력에도 이 훅 객체가 학생에게 보인다. (2) `rm(list = ls())` 는 패키지·옵션을 되돌리지 않는다. 실행 뒤에도 `readxl` 은 부착돼 있고 `digits = 3` 이 남았다. (3) `load()` 는 같은 이름의 객체를 경고 없이 덮어쓴다(작업 중인 `dbp` 가 저장본으로 바뀌고, 반환값은 이름뿐). 덧붙여 Quarto 에서 `save.image()` 를 쓰면 Quarto 내부 객체 `.main`(773.7 KB)·`.QuartoInlineRender` 까지 저장된다 | 재현 | `saveRDS()`/`readRDS()` 를 기본으로 삼는다. `save()`/`load()` 는 덮어쓰기 경고와 함께 소개한다. `save.image()`·`rm(list = ls())` 대신 "R 재시작 후 스크립트를 처음부터 실행"을 가르친다(R4DS 2e "Workflow: scripts and projects") |
| B-8 | 248–251, 281 | `output/` 폴더를 만들지 않는다(`dir.create()` 는 주석 처리). 저장소는 `output/` 을 git 으로 추적하므로 렌더가 된다. 그러나 `output/` 이 없는 사본에서는 청크 246·275가 `cannot open the connection` 으로 실패하고, knitr 기본값에서는 렌더도 멈춘다. `dataset.zip` 에도 `output/` 이 없다 | 재현 | `dir.create("output", showWarnings = FALSE)` 를 실행 코드로 둔다 |
| B-9 | 251, 260, 281 (저장소) | 렌더할 때마다 추적 중인 이진 파일 3개가 바뀐다: `all_obj.Rdata` 15,227 → 13,142 B, `pulse.rds` 5,930,981 → 5,930,979 B, `sub_obj.Rdata` 1,181 → 1,182 B. 쓰는 R 의 버전이 파일 머리에 기록되기 때문이다[추론]. `output/pulse.rds` 는 이미 21개 커밋에 걸쳐 13개 판(합계 77.1 MB, gzip 이라 git 이 더 줄이지 못함)이 쌓였다. CLAUDE.md 규칙 9(큰 바이너리 추가 금지)와 충돌하고, `10-data-manupulation.Rmd:181` 이 이 파일을 읽는다(F-1) | 재현 | `output/` 을 `.gitignore` 에 넣고 렌더 때 생성한다. 10장(새 12장)은 자기 청크에서 만들거나 CSV 에서 읽는다 |
| B-10 | 79 (78–80) | "현재 작업공간의 작업 디렉토리(working directory) 확인이 필요" — 작업공간(workspace: 메모리의 객체. 237·243·244는 이 뜻으로 씀)과 작업 디렉터리(디스크의 현재 폴더)를 한 구로 섞었다. 장 전체에 `getwd()`·상대 경로·프로젝트 설명이 없다. 입출력 장에서 학생이 가장 먼저 만나는 오류(`cannot open file … No such file or directory`)와 Windows 탐색기 경로를 붙여 넣을 때 나는 오류(`"C:\Users\..."` → `'\U' used without hex digits in character string`)도 다루지 않는다 | 추론 / 재현(경로 오류 문구) | 두 용어를 따로 정의하고 "경로와 작업 디렉터리" 소절을 신설한다(G-1) |

---

## C. 경미 — 표기·정리·렌더

| # | 줄 | 내용 | 근거 |
|---|---|---|---|
| C-1 | 8–34 | knitr 보일러플레이트: PDF 전용 `size` 훅, 쓰지 않는 `tidy.opts`, setup 의 `require()`. 또 **`options(linewidth = 60)` 은 R 전역 옵션이라 훅이 읽는 청크 옵션(`options$linewidth`)에 닿지 않는다.** 그래서 60자 접기가 한 번도 적용되지 않는다. knitr·Quarto 모두 150자 줄이 그대로 출력되고, 청크 옵션 `linewidth = 60` 을 준 청크만 접힌다(F-3) | 재현 |
| C-2 | 37 | 장 H1 에 ID 가 없어 공개 URL 이 `r-외부-데이터-입출력.html` 이 됨 | 재현(docs) |
| C-3 | 62–71 | "titanic3.csv 파일 일부": 머리 줄은 변수 5개 + 끝 쉼표, 자료 줄은 값 4개(68줄은 쉼표 뒤 공백). 실제 파일은 14열 | 재현 |
| C-4 | 75, 301 | 헤딩 안의 굵게(`**…**`) 표기. 301은 `##` 다음에 `####` 가 와서 수준을 건너뜀 | 추론 |
| C-5 | 79 | "디렉토리" → "디렉터리"(외래어 표기) | 추론 |
| C-6 | 89–90, 92 | 주석 "파일명. 일반적으로 폴더명 구분자"가 미완성 문장. `sep = ""` 가 "하나 이상의 공백·탭"이라는 설명이 없음. 50–57 예시는 칸 사이 공백 수가 제각각이라 기본값에서만 읽히고, `sep = " "` 이면 `more columns than column names` 오류(예측 문항 후보) | 재현 |
| C-7 | 144, 151 | 109 콜아웃이 "옛 습관"이라 설명한 `stringsAsFactors = FALSE` 를 바로 아래 청크가 그대로 씀 | 추론 |
| C-8 | 156–157, 188–189 | `textConnection()` 설명이 거꾸로다("텍스트에서 한 줄씩 읽어 문자형 벡터처럼"). 실제로는 문자형 벡터를 파일처럼 읽게 해 주는 연결이다. `read.table(text = input1, …)` 가 같은 결과를 내므로(`identical` TRUE) `textConnection()` 이 필요 없음 | 재현 |
| C-9 | 161 | Plasma 출처 링크 403(D) | 재현 |
| C-10 | 173–189 | 코드북을 `sep = ":"` 로 나누는 방식. 지금 14줄은 줄마다 콜론이 1개라 정상이다(VITUSE 설명의 콤마 4개도 보존, V2 앞 공백 1칸 남음). 그러나 설명에 콜론이 하나 더 있으면 앞 5줄 안에서는 `line 1 did not have 3 elements`, 6번째 줄 이후에서는 `line 6 did not have 2 elements` 오류가 난다. 작은따옴표(`Subject's`)가 있으면 `incomplete final line found by readTableHeader` 오류. 첫 콜론에서만 나누는 `sub(":.*$", "", x)` 가 견고함 | 재현 |
| C-11 | 188, 189, 218, 228, 278 | `header = F/T`, `row.names = F` 약어(`T`·`F` 는 재정의될 수 있는 변수) | 추론 |
| C-12 | 197, 202–208 | "저장 후 … 내보내기"는 순서가 뒤바뀐 표현이고, 204–205에는 "또는"이 중복. 원형의 첫 인수 이름은 `x` 다(본문 `data_obj`). 기본값 `quote = TRUE`, `na = "NA"`, `fileEncoding` 이 빠짐 | 재현(`formals(write.table)`) |
| C-13 | 214–218 | 원자료 폴더 `dataset/plasma.txt` 에 씀(추적 파일 덮어쓰기. 결과가 결정적이라 diff 는 안 생김). 같은 장의 다른 저장은 `output/` | 재현 |
| C-14 | 222–229 | clipboard 쓰기는 **Windows 전용**. Linux 에서는 `'mode' for the clipboard must be 'r' on Unix` 오류가 난다. macOS 도 같은 Unix 경로를 타며, `?connections` 는 `pipe("pbcopy", "w")` 를 안내한다. 대안 `clipr::write_clip()` 은 Linux 에서 xclip/xsel 과 DISPLAY 가 필요함 | 재현(Linux) / 추론(macOS) |
| C-15 | 239 | 확장자 관례 `.RData`/`.rda` 병기 | 추론 |
| C-16 | 250, 254, 257, 262, 266, 282 | `ls()` 출력에 knitr 훅 객체 `def.chunk.hook`·`hook_output` 이 보임(배포본 동일). 학생은 자기가 만들지 않은 객체를 보게 됨 | 재현(docs) |
| C-17 | 259 | "dnp" → "dbp" | 추론 |
| C-18 | 277 | "명령 실행 시가 계산 함수" → "실행 시간 측정 함수" | 추론 |
| C-19 | 278 | `read.csv(header = T)` — 기본값이 이미 TRUE | 재현 |
| C-20 | 272, 276 | "대용량" — 11.9 MB, 69행 × 20,000열 파형 행렬이다. 크다기보다 **극단적으로 넓은** 자료이고, 이 모양 때문에 리더별 시간 순서가 뒤집힌다(B-2, I-1) | 재현 |
| C-21 | 293 | readr 를 소개 없이 언급(readr 설명은 10장에 있음) | 추론 |
| C-22 | 294–296 | "과거 방법"(텍스트로 내보내기, Java 기반 xlsx)은 사실이지만(xlsx 0.6.5: rJava 사용, SystemRequirements java) 한 줄로 줄일 대상 | 재현 |
| C-23 | 298 | "(Hadley Wickham이 개발...)" — readxl 1.5.0 의 현 관리자(cre)는 Jennifer Bryan | 재현 |
| C-24 | 290, 303 | 절 제목은 "입출력"인데 Excel 쓰기(`writexl::write_xlsx()`) 예시가 없음. 303 `read_excel` 괄호 누락 | 추론 |
| C-25 | 323–324 | 주석 `install.packages()` + 본문 `require()` | 추론 |
| C-26 | 326 | `covid19` 출력: `df_print: paged` 는 **최대 10,000행을 JSON 으로 페이지에 넣는다**(`rmarkdown:::paged_table_html` 의 `max.print` 상한). 배포본 `import-export-excel.html` 이 1,902,734 B 인 이유다(JSON 1,845,472 B, 14,315행 중 10,000행). 표에 표시되는 전체 행 수도 10,000 일 것 | 재현(docs) / 추론(표시 문구) |
| C-27 | 325–326 | `date` 열이 문자형(`<chr>`)으로 읽혀 날짜 계산이 안 되는데 짚지 않음 | 재현 |
| C-28 | 330–333 | 14개 시트를 읽은 `dL` 을 확인하지 않음(시트별 차원 한 줄이면 됨) | 재현 |

---

## D. 외부 링크·로컬 자원·패키지·배포본

**외부 링크** (브라우저 UA, GET)

| 줄 | URL | 상태 | 조치 |
|---|---|---|---|
| 161 (주석) | `http://lib.stat.cmu.edu/datasets/Plasma_Retinol` | **403** (https 로 301 이동 뒤 403. 사이트 루트도 403, WebFetch 로도 403) | 대체 링크: Wayback `https://web.archive.org/web/20240203003556/https://lib.stat.cmu.edu/datasets/Plasma_Retinol` (200, 315행 원문 확인) 또는 OpenML `https://www.openml.org/d/511` (200) |
| 305 | `https://github.com/owid/covid-19-data/tree/master/public/data` | 200. 단 **저장소가 archived**(README: 2024-08-19 마지막 갱신). `public/data` 에 xlsx 는 없고 csv 만 있음 | 자료를 유지한다면 `https://catalog.ourworldindata.org/garden/covid/latest/compact/compact.csv` (200) |
| 추가 제안 | `https://r4ds.hadley.nz/workflow-scripts.html`, `https://r4ds.hadley.nz/data-import.html`, `https://r4ds.hadley.nz/arrow.html`, `https://readxl.tidyverse.org/`, `https://readr.tidyverse.org/`, `https://nanoparquet.r-lib.org/`, `https://here.r-lib.org/`, `https://cran.r-project.org/doc/manuals/r-release/R-data.html`, `https://hbiostat.org/data/` | 모두 200 | B-6·B-7·G 의 출처로 |

**로컬 자원** — 참조 파일 전부 존재, xlsx 2개 모두 readxl 로 열림

| 줄 | 파일 | 인코딩·형식 | 비고 |
|---|---|---|---|
| 116, 120 | `dataset/DBP.txt` | ASCII, LF, 41줄 | `data/DBP.txt`(12장 539줄에서 사용)는 CRLF 로 된 별도 사본 |
| 130 | `dataset/diabetes_csv.txt` | ASCII CSV, 404줄 | 같은 자료의 탭 구분판이 `diabetes.txt` |
| 141, 148 | `dataset/herb_dic_sample.txt` | **CP949**. `file -i` 는 `charset=iso-8859-1` 로 오판, `readr::guess_encoding()` 은 EUC-KR 0.93 / EUC-JP 0.68 | A-1 |
| 217 | `dataset/plasma.txt` (쓰기) | ASCII, 추적 파일, 다시 써도 바이트 동일 | C-13 |
| 251·256·260·265·281·284 | `output/all_obj.Rdata`, `sub_obj.Rdata`, `pulse.rds` | gzip, 추적 파일 | B-8, B-9 |
| 278 | `dataset/pulse.csv` | ASCII CSV, 70줄(69행 × 20,000열), 11,866,553 B, 결측 0 | B-2, I-1 |
| 325 | `dataset/covid-19-dataset/owid-covid-data.xlsx` | xlsx, 시트 1개, 14,315 × 16, 읽기 0.42초 | B-5 |
| 330 | `dataset/datR4CTDA.xlsx` | xlsx, 시트 14개 모두 읽힘 | — |
| 63 (예시) | `dataset/titanic3.csv` | ASCII CSV, 1,310줄 × 14열 | C-3 |

**`dataset.zip`** (10,755,387 B, 2020-04-24 사본, 15파일): `covid-19-dataset/` 폴더와 `output/` 이 없다. 텍스트 파일은 CRLF 라 줄 수만큼 크기가 크다. 이 사본으로 325줄을 실행하면 경로 오류가 난다(재현). 책 본문 어디에도 zip 을 안내하는 곳이 없어, 학생이 자료를 받는 경로는 확인하지 못했다.

**패키지** (설치·CRAN 모두 확인)

| 패키지 | 줄 | 설치 | 비고 |
|---|---|---|---|
| readxl | 324 | 1.5.0 | tidyverse 와 함께 설치, 부착은 따로(B-3) |
| knitr | 9 | 1.51 | setup `require()` |
| xlsx | 296 (본문 언급) | 0.6.5 | rJava·Java 필요 |
| 새 11장 후보 | — | arrow 25.0.0 (설치 126 MB, Imports 10개) · nanoparquet 0.5.1 (23 MB, Imports 없음) · writexl 2.0.1 · openxlsx 4.2.8.1 · clipr 0.8.1 · here 1.0.2 · data.table 1.18.4 · haven 2.5.5 · janitor 2.2.1 | — |

**배포본 상태**: `docs/text-import-export.html` 등은 2023-05-15 렌더다. **2026-09-10 수정(stringsAsFactors 원형·예제 교체)이 반영되지 않은 채 서빙 중**이다. 원형 주석은 여전히 `stringsAsFactors = TRUE, # 문자형 변수를 factor으로 변환할 지 여부`, 예제는 "factor로 변환하지 않는 경우" + `FALSE` 로 나온다. knit 중간 산출물 `docs/05-`, `06-`, `09-file-import-export.md`(각 1.87 MB, 페이징 표 JSON 포함)도 추적된 채 남아 있다.

---

## E. 실행 로그와 구식 API

**실행 요약** (`run_chunks.R`, R 4.6.1)

```
== output/ 이 있는 사본(git 추적 상태 그대로): OK 7 / ERROR 0 / EXPECTED-ERROR 0 / NO-ERROR? 0 / SKIP 5
   9    246 im-exp-Rdata-ex   OK        (rm(list = ls()) 뒤 load() 가 복원)
  10    275 im-exp-rds-ex     OK 5.7s   (read.csv 약 4.5초)
  12    320 readxls-ex        OK 0.4s
  SKIP eval=FALSE 5: 86 read.table 원형, 136 인코딩 예제, 200 write.table 원형, 224 clipboard, 307 read_xlsx 원형
== output/ 이 없는 사본: OK 5 / ERROR 2
   9    246 im-exp-Rdata-ex   ERROR  cannot open the connection
  10    275 im-exp-rds-ex     ERROR  cannot open the connection
```

- deprecation 경고는 없다. run_chunks 는 메시지를 숨기지만 배포본에는 `필요한 패키지를 로딩중입니다: readxl` 이 출력돼 있다.
- `eval=FALSE` 5개 가운데 실제 코드는 136(인코딩)·224(clipboard) 두 개다. 둘 다 렌더에서 한 번도 실행되지 않았고, 현행 환경에서 실패함을 A-1·C-14 에서 확인했다.

**구식·권장 대체**

| 줄 | 현재 | 대체 | 동작 차이 |
|---|---|---|---|
| 96, 143, 150 | `encoding = "CP949"` / `"UTF-8"` | `fileEncoding = "CP949"` / `readr::locale(encoding = "CP949")` | 결과가 달라짐(A-1) |
| 9, 324 | `require()` | `library()` | 패키지가 없을 때 경고 대신 오류 |
| 188–189 | `read.table(textConnection(x), …)` | `read.table(text = x, …)` | 없음(`identical` TRUE) |
| 188, 189, 218, 228, 278 | `T` / `F` | `TRUE` / `FALSE` | — |
| 144, 151 | `stringsAsFactors = FALSE` | 삭제 | 없음(R ≥ 4.0 기본값) |
| 227 | `write.table(x, "clipboard")` | `clipr::write_clip(x)` / macOS `pipe("pbcopy", "w")` | Windows 밖에서도 동작 |
| 251–266 | `save.image()` + `rm(list = ls())` + `load()` | `saveRDS()`/`readRDS()` + R 재시작 | 객체 이름을 호출자가 정하고, 전역 상태에 기대지 않음 |
| 281 | `saveRDS()` 기본(gzip) | 그대로 두되 선택지를 보임: `compress = "xz"`(3,615,432 B), `compress = FALSE`(읽기 0.018초) | — |
| 296 | xlsx (Java) | 읽기 readxl + 쓰기 `writexl::write_xlsx()` | Java 불필요 |
| 19 | `options(linewidth = 60)` | `knitr::opts_chunk$set(linewidth = 60)` | 접기가 실제로 적용됨(C-1) |
| (없음) | — | `readr::read_csv()`/`read_tsv()` + `spec()`·`problems()` | 새 11장에서 base 와 대조 |

파이프는 `%>%`·`|>` 모두 0회다.

**자료·환경이 가린 오류** (배포본이나 저장소에서 정상으로 보이는 이유)

| 항목 | 무엇이 가렸나 |
|---|---|
| A-1 인코딩 | 2020년 한국어 Windows 의 기본 인코딩 CP949. 이후 `eval=FALSE` |
| B-2 압축률 | 청크가 파일 크기를 재지 않음. 머릿속 비교 대상이 압축하지 않은 CSV |
| B-5 경로 | 작성자 기기의 `dataset/covid-19-dataset/`(zip 과 구조가 다름) |
| B-7 훅 삭제 | 같은 청크의 `load()` 가 훅 객체를 되살림 |
| B-8 `output/` 없음 | 저장소가 `output/` 을 추적 |
| C-1 linewidth | 오류가 아니라 긴 줄로 보일 뿐이라 눈에 띄지 않음 |
| C-10 코드북 | 현재 설명문에 콜론·작은따옴표가 없음 |

---

## F. 다른 장으로 번지는 문제

1. **`10-data-manupulation.Rmd:181` `readRDS("output/pulse.rds")`** — 9장이 만든(또는 git 이 추적하는) 파일에 기댄다. `new_session: true` 는 R 세션만 나눌 뿐 디스크는 공유한다. B-9 에서 `output/` 을 무시하면 10장 렌더가 깨진다. 새 12장은 파일을 스스로 만든다.
2. **`01-introduction.Rmd:657`** "RStudio의 Windows 버전 기본 text encoding은 CP949 임" — R 4.2 이후 Windows 기본 인코딩은 UTF-8 이다. 1장 감사 때 확인한다[추론].
3. **`options(linewidth = 60)` 은 모든 장에서 무효** — bookdown 12개 장과 Quarto 시범 원고 `08-algorithms.qmd:49`, `09-simulation.qmd:38` 이 해당한다(주석은 "출력 폭을 60자로 접는다"). `08-algorithms-slides.qmd:61` 의 `options(linewidth = 46, width = 46)` 은 `width` 만 효과가 있다. 청크 옵션으로 `linewidth` 를 준 곳은 `01-introduction.Rmd` 의 3개 청크뿐이다. 접기를 원하면 setup 에서 `knitr::opts_chunk$set(linewidth = 60)` 을 쓰거나 YAML `knitr: opts_chunk: linewidth: 60` 을 준다(Quarto 1.9.38 에서 재현).
4. **`df_print: paged`(`_output.yml`) / `df-print: paged`(8·9장 qmd)** — 큰 데이터 프레임을 출력하면 최대 10,000행이 페이지에 박힌다(C-26). 큰 자료를 다루는 새 11장은 `head()`·`glimpse()`·`dim()` 으로 출력한다.
5. **Quarto 의 전역 환경** — `.main`·`.QuartoInlineRender` 가 전역 환경에 있어 `save.image()` 결과에 섞인다. 훅 객체 삭제 문제(B-7)는 bookdown 과 같다. 8장처럼 setup 에 `hook_output` 을 두는 새 원고에서는 `rm(list = ls())` 시연 청크를 두지 않는다.
6. **이 장의 공개 URL** (legacy 보존 대상): `r-외부-데이터-입출력.html`, `text-import-export.html`, `binary-import-export.html`, `import-export-excel.html`(#readxl-funs).

---

## G. 새 11장 재구성 제안 (교수법)

재구성안 5절 대응표의 이 장 행은 "11 | 데이터 입출력 | 09 | 유지. arrow/parquet 추가"다. 절의 틀(텍스트 → 바이너리 → Excel)은 유지할 만하다. 다만 각 절의 동작을 **"함수 소개"에서 "읽고 → 원자료와 대조한다"로** 바꾸기를 제안한다. AI 는 `read_csv()` 한 줄을 즉시 써 준다. 그러나 결과가 원파일과 같은지(행 수, 결측, 열 형식, 인코딩)는 학생이 확인해야 한다. 새 11장은 6장(검증)의 도구를 파일 입출력에 적용하는 장이 된다.

### G-1. 절별 처리

| 현 절 (줄) | 처리 | 이유 |
|---|---|---|
| 도입: 텍스트 자료·구분자 (37–71) | 재작성, 일상의 예로 시작 | "카톡으로 받은 CSV 를 열었더니 한글이 깨졌다", "학번 앞자리 0 이 사라졌다"로 연다. 파일은 바이트의 줄이고 해석은 읽는 쪽이 한다. 첫 동작은 파일을 글자로 먼저 보는 `readLines(f, n = 3)`. titanic 발췌(C-3)는 실제 파일로 교체 |
| (신설) 경로와 작업 디렉터리 | 신설 | B-10. 작업공간(책상 위) vs 작업 디렉터리(서랍), `getwd()`, 상대 경로, 프로젝트(Positron 폴더 열기 / RStudio Project), Windows `\` 경로 오류. `here::here()` 는 소개 수준 |
| 텍스트 읽기 (75–195) | 재구성: readr 중심 + base 대조 | 원형 전수(86–99) 대신 핵심 인수 4개(구분자·머리줄·결측 코드·열 형식). `read.csv()` 와 `read_csv()` 의 차이를 **예측 문항**으로(B-1, I-4). `textConnection` 은 `read.table(text = )` 한 줄로 압축 |
| (신설) 가져온 뒤 확인하기 | 신설, **장의 중심** | 원자료 줄 수 vs `nrow()`, `spec()`, `problems()`(행 번호가 머리줄을 세어 1 크고, 인코딩 문제는 잡지 못함), 열별 결측 수, `""` vs `NA`, 앞자리 0, 원문 3행 대조. 6장 `testthat` 과 연결 |
| 한글 인코딩 (136–154) | 재작성 | A-1. `fileEncoding` / `locale(encoding = )`, `validUTF8()`, `guess_encoding()` 과 `file -i` 의 오판, CP949 ≠ EUC-KR(행 손실 사례), Windows R ≥ 4.2 의 UTF-8 기본. Excel "CSV UTF-8" 의 BOM 은 R 4.6.1 이 알아서 처리함(I-3) |
| 텍스트 쓰기 (197–232) | 압축 + 왕복 확인 | `write_csv()` / `write.csv(row.names = FALSE)`. 쓰기 → 읽기 → `all.equal()` 로 무엇이 사라지는지 보인다(앞자리 0·요인·날짜, I-5). 원자료 폴더에 쓰지 않는다(C-13). Excel 에서 열 파일은 `write_excel_csv()`. clipboard 는 삭제하거나 팁으로 |
| R 바이너리 (235–286) | 재작성 | RDS 를 기본으로. `load()` 덮어쓰기를 경고하고, `save.image()`·`rm(list = ls())` 대신 R 재시작을 가르친다(B-7). "RDS 가 빠르고 작다"는 주장은 **측정으로** 대체(B-2) |
| (신설) 형식 비교: CSV · RDS · parquet | 신설(재구성안의 arrow/parquet) | 같은 값을 긴/넓은 두 모양으로 저장해 크기·시간을 비교한다(I-1). parquet 는 긴 표에서 CSV 의 57%, 넓은 표에서 158% 로 "항상 작다"가 아니다. 수업용은 설치가 가벼운 `nanoparquet` 을 먼저, 메모리보다 큰 자료와 `open_dataset()` 은 `arrow` 로 소개 |
| Excel (290–335) | 현행화 | readxl(설치는 tidyverse 로, `library(readxl)` 은 따로), `col_types` 문자 벡터(B-4), `excel_sheets()` + 시트별 차원 확인, 날짜 일련번호(I-6), `writexl::write_xlsx()` 로 쓰기. xlsx(Java) 문단 삭제. COVID-2020 자료 교체(B-5) |
| (선택) 통계 패키지 파일 | 신설 후보 | `haven::read_sav()` — tidyverse 와 함께 설치, 부착은 따로. 값 레이블 → `as_factor()` 확인 |
| (신설) AI와 함께 | 신설 | G-4 |

### G-2. 예측(PRIMM) 문항 후보 — 모두 이 감사에서 실제 결과를 확인함

- 50–57줄 자료를 `sep = " "` 로 읽으면? → `more columns than column names`
- `read.table(f, encoding = "CP949")` 는 한글을 살릴까? → 오류(`fileEncoding` 이어야 함)
- `diabetes_csv.txt` 의 `frame` 빈 칸 12개는 `read.table()` 과 `read_csv()` 에서 각각 무엇이 될까? → `""` 12개 / `NA` 12개
- `007` 이 든 CSV 를 `read.csv()` 와 `read_csv()` 로 읽으면? → `7` / `"007"`(readr 2.2 는 앞자리 0 이 붙은 수를 문자로 추측)
- `pulse.csv` 를 gzip 한 파일과 `saveRDS()` 파일 중 어느 쪽이 작을까? → gzip CSV(4.41 MB < 5.93 MB)
- `read_csv()` 는 `read.csv()` 보다 항상 빠를까? → 긴 표 0.10초 vs 1.44초, 넓은 표 119초 vs 4.5초
- parquet 는 CSV 보다 항상 작을까? → 긴 표 57%, 넓은 표 158%
- CP949 파일을 `fileEncoding = "EUC-KR"` 로 읽으면 4행이 다 들어올까? → 2행, 경고 한 줄
- 날짜 열에 "미상" 한 칸이 섞인 Excel 을 읽으면? → `"43942"` 같은 문자열
- **버그 찾기**: 136–154 원 코드와 2020년 출력을 주고 "2020년에는 맞았다. 지금은 왜 오류인가?"

### G-3. 검증 활동 (6장과 상호참조)

1. **원자료 대조 루틴**: 행 수(따옴표 안 줄바꿈이 없는 파일이면 줄 수 − 1), `spec()`, `problems()`, 열별 결측 수, 원문 몇 줄과 결과 몇 행을 나란히 본다.

   ```r
   f <- "dataset/diabetes_csv.txt"
   d <- readr::read_csv(f, show_col_types = FALSE)
   stopifnot(nrow(d) == length(readLines(f)) - 1)
   readr::spec(d); readr::problems(d)
   colSums(is.na(d))
   readLines(f, n = 3); head(d, 2)
   ```

2. **왕복 확인**: 쓰기 → 읽기 → `all.equal()`. RDS·parquet 은 `identical()` TRUE, CSV 는 손실 목록이 나온다(I-5).
3. **인코딩 확인**: `all(validUTF8(x))` 에 알려진 값(`"가자" %in% x`) 확인을 더한다.
4. **경계 사례 파일**: 앞자리 0, 결측 코드 `-99`·`.`, 확장 한글, 날짜와 글자가 섞인 열, 3000번째 행에만 있는 이상값을 담은 작은 파일을 만들어 리더의 반응을 본다(I-4).
5. **테스트로 굳히기**: `testthat::expect_equal(nrow(d), 403)`, `expect_true(all(validUTF8(d$korean)))`.

### G-4. "AI와 함께" 절 제안

- 위치는 장 끝, 연습문제 앞이다. ID 는 `sec-ai-import`(8장 `sec-ai-algorithms` 와 같은 형식).
- 과제 명세 후보는 두 가지다. (1) "CP949 로 저장된 한글 CSV 를 읽어 범주별 빈도표를 만드는 코드" (2) "Excel 파일의 모든 시트를 읽어 한 데이터 프레임으로 합치는 코드".
- 검증 항목: 행 수(원자료, 시트별 합), `validUTF8()`, `spec()`, 결측 수, 날짜 열 형식, 왕복 확인.
- 흔한 오류 후보는 **실제 LLM 응답으로 확인한 뒤에만 싣는다**(CLAUDE.md 규칙 7): `encoding=` 과 `fileEncoding=` 혼동, `"EUC-KR"` 지정으로 확장 한글 손실, `setwd("C:/Users/…")` 절대 경로, 스크립트 첫 줄의 `rm(list = ls())`, 불필요한 `stringsAsFactors = FALSE`, `write.csv()` 가 만든 행 이름 열(`X` / `...1`), Excel 날짜 일련번호 방치, readr 형식 `col_types` 를 readxl 에 넘기기.
- 개인정보: 설문·명단 파일을 프롬프트에 붙이지 말라는 `rmdwarning` 을 둔다(ai-curriculum 3절). 파일 **구조**(열 이름과 가짜 값 3행)만 건네는 연습을 넣는다.

### G-5. 일상의 예를 먼저

- 인코딩: 같은 바이트 `B0 A1` 이 CP949 사전으로는 '가'이고, UTF-8 사전으로는 뜻 없는 조각이다. 카톡으로 받은 CSV 가 깨지는 경험에서 시작한다.
- 열 형식 추측: 엑셀에서 우편번호 01234·학번 앞자리 0 이 사라지는 경험.
- 작업 디렉터리는 "지금 서 있는 폴더", 작업공간은 "책상 위에 펼쳐 둔 물건".
- 날짜: 엑셀 셀에 43942 가 보이는 경험 → 1899-12-30 부터 센 날수.

### G-6. 자료 선택

- COVID 2020 스냅숏(B-5)은 시의성이 없고 원 저장소도 보관 처리됐다. 교체를 권장한다.
- `pulse.csv` 는 형식 비교에 쓰되 **넓은 표의 반례**로 쓴다(parquet 158%, readr 119초). 같은 값을 긴 형태로 바꾸면 같은 자료로 대조가 된다(I-1).
- `herb_dic_sample.txt`(CP949)는 좋은 인코딩 교재다. 유지하되 확장 한글 행을 더한 사본을 두면 CP949/EUC-KR 차이까지 보인다.
- Plasma 원 페이지는 접근할 수 없고(403) "Authorization: Contact Authors" 표기가 있다. 전체를 재배포하지 말고 발췌만 쓴다.

---

## H. 작업 순서와 작업량

1. **현 9장이 공개 사이트에 남아 있는 동안 고칠 것** (각 5분 안팎): A-1(두 호출의 `encoding` → `fileEncoding`, 원형 주석), B-1(한 문장), B-3(한 문장), B-4(주석 한 줄), B-8(`dir.create()` 주석 해제). 배포본이 2026-09-10 수정 전 렌더이므로(D) 재렌더가 필요하다.
2. B-9(`output/` 추적 해제)는 10장 의존(F-1)과 함께 처리한다.
3. 새 11장은 G 의 구성을 따른다. B·C 항목 대부분은 재작성으로 해소된다.
4. F-3(`linewidth` 무효)은 8·9장 qmd 에도 해당하므로 따로 한 번에 고친다.
5. CLAUDE.md 진행 상태 표의 현 9장 행을 `감사 완료` 로 갱신한다(이 감사에서는 CLAUDE.md 를 편집하지 않았다).

- 작업량: A 1곳 / B 10곳 / C 28곳 / 신규 작성: 경로·작업 디렉터리, 가져온 뒤 확인하기, 한글 인코딩, 형식 비교(parquet), Excel 쓰기·날짜 소절 5개 + "AI와 함께" 1절 + 연습문제(읽기 문항 절반)

---

## I. 측정값과 재현 코드 (새 11장에서 재사용)

측정 기기는 AMD Ryzen Threadripper 2990WX(32코어/64스레드), NVMe SSD 다. 소프트웨어는 R 4.6.1, readr 2.2.0(64스레드), data.table 1.18.4(32스레드), arrow 25.0.0, nanoparquet 0.5.1. **시간의 절대값은 학생 노트북과 다르다.** 순서와 배율만 재사용하고, 본문에 실을 시간은 렌더 때 다시 잰다. 시간은 준비 실행 1회 뒤 3~5회의 중앙값이다.

### I-1. 형식별 파일 크기와 읽기·쓰기 시간

**넓은 표** `dataset/pulse.csv` — 69행 × 20,000열, 메모리 12.8 MB

| 파일 | 크기 (B) | CSV 대비 |
|---|---:|---:|
| pulse.csv (원본) | 11,866,553 | 100.0% |
| pulse.csv.gz (`gzip -6`) | 4,411,994 | 37.2% |
| pulse.csv.xz (`xz -6`) | 2,746,676 | 23.1% |
| `saveRDS()` 기본(gzip) | 5,930,979 | 50.0% |
| `saveRDS(compress = FALSE)` | 11,467,666 | 96.6% |
| `saveRDS(compress = "xz")` | 3,615,432 | 30.5% |
| `save()` .RData | 5,930,972 | 50.0% |
| `arrow::write_parquet()` (snappy) | 18,706,054 | 157.6% |
| `arrow::write_parquet(compression = "zstd")` | 18,930,164 | 159.5% |
| `nanoparquet::write_parquet()` | 14,111,092 | 118.9% |
| `arrow::write_feather()` | 14,585,858 | 122.9% |

| 읽기 | 중앙값 |
|---|---:|
| `read.csv()` | 4.528 s |
| `readr::read_csv()` (64스레드, 1회씩 2번) | 118.59 s / 119.53 s |
| `readr::read_csv(col_types = cols(.default = col_double()))` | 119.59 s |
| `readr::read_csv(lazy = TRUE)` (값을 실제로 읽는 시간은 재지 않음) | 1.51 s |
| `data.table::fread()` / `nThread = 1` | 0.225 s / 0.219 s |
| `readRDS()` gzip / 비압축 | 0.080 s / 0.018 s |
| `arrow::read_parquet()` | 0.478 s |
| `nanoparquet::read_parquet()` | 0.238 s |
| **쓰기** `write.csv()` / `saveRDS()` gzip / `saveRDS(compress = FALSE)` | 1.409 s / 0.380 s / 0.032 s |

배포본(2023 렌더, Windows)에 실린 값은 `read.csv` 5.030초, `readRDS` 0.087초다. 왕복 결과는 `identical(pulse, readRDS(...))` TRUE, `write.csv` → `read.csv` 도 TRUE(최대 절대 오차 0), parquet 는 `all.equal` TRUE 였다.

**긴 표** — 같은 값을 `subject, t, value` 로 편 1,380,000행 × 3열, 메모리 21.1 MB

| 파일 | 크기 (B) | CSV 대비 | 읽기 중앙값 |
|---|---:|---:|---|
| CSV | 23,171,367 | 100.0% | `read.csv` 1.436 s · `read_csv` 0.101 s(1스레드 0.508 s) · `fread` 0.012 s(1스레드 0.047 s) |
| CSV.gz | 7,864,219 | 33.9% | — |
| RDS (gzip) | 8,733,228 | 37.7% | 0.096 s |
| parquet (arrow, snappy) | 13,169,513 | 56.8% | 0.020 s |

```r
# 저장소(또는 사본) 루트에서 실행. 쓰기는 저장소 밖 임시 폴더 B 에만
suppressPackageStartupMessages({library(readr); library(data.table); library(arrow)})
B <- tempfile("io-bench-"); dir.create(B)
tm <- function(expr, n = 5) {
  e <- substitute(expr); pf <- parent.frame()
  invisible(eval(e, pf))                                         # 준비 실행
  x <- vapply(seq_len(n), function(i) system.time(eval(e, pf))[["elapsed"]], 0)
  sprintf("median %.3f s (min %.3f, max %.3f, n=%d)", median(x), min(x), max(x), n)
}
csv <- "dataset/pulse.csv"
pulse <- read.csv(csv)
saveRDS(pulse, file.path(B, "pulse.rds"))
saveRDS(pulse, file.path(B, "pulse_nocomp.rds"), compress = FALSE)
saveRDS(pulse, file.path(B, "pulse_xz.rds"), compress = "xz")
write_parquet(pulse, file.path(B, "pulse.parquet"))
nanoparquet::write_parquet(pulse, file.path(B, "pulse_nano.parquet"))
file.copy(csv, file.path(B, "pulse.csv"))
system2("gzip", c("-kf6", shQuote(file.path(B, "pulse.csv"))))
file.size(file.path(B, c("pulse.csv", "pulse.csv.gz", "pulse.rds", "pulse_nocomp.rds", "pulse.parquet")))
tm(read.csv(csv), n = 3); tm(fread(csv)); tm(readRDS(file.path(B, "pulse.rds")))
tm(read_parquet(file.path(B, "pulse.parquet")), n = 3)
system.time(read_csv(csv, show_col_types = FALSE, progress = FALSE))     # 넓은 표: 약 119초
long <- data.frame(subject = rep(seq_len(nrow(pulse)), each = ncol(pulse)),
                   t       = rep(seq_len(ncol(pulse)), times = nrow(pulse)),
                   value   = as.vector(t(as.matrix(pulse))))
write.csv(long, file.path(B, "pulse_long.csv"), row.names = FALSE)
tm(read.csv(file.path(B, "pulse_long.csv")), n = 3)
tm(read_csv(file.path(B, "pulse_long.csv"), show_col_types = FALSE, progress = FALSE), n = 3)
```

### I-2. 한글 인코딩 — `herb_dic_sample.txt` (CP949)

결과표는 A-1 에 있다. 추가 측정은 다음과 같다.

- `grepl("가자", 깨진열)` → 경고 `unable to translate '<b0><a1><c0><da>' to a wide string`. `toupper()` → 오류 `invalid multibyte string 1`.
- 사후 복구 `iconv(깨진열, from = "CP949", to = "UTF-8")` 은 `fileEncoding` 결과와 `identical` TRUE.

```r
f <- "dataset/herb_dic_sample.txt"
readr::guess_encoding(f)                                                    # EUC-KR 0.93, EUC-JP 0.68
try(read.table(f, sep = "\t", header = TRUE, encoding = "CP949"))           # 오류
bad <- read.table(f, sep = "\t", header = TRUE, colClasses = "character")   # 오류 없이 깨진 바이트
c(validUTF8 = all(validUTF8(bad$korean)), match = "가자" %in% bad$korean)   # FALSE FALSE
ok <- read.table(f, sep = "\t", header = TRUE, fileEncoding = "CP949")
c(validUTF8 = all(validUTF8(ok$korean)), match = "가자" %in% ok$korean)     # TRUE TRUE
r0 <- readr::read_tsv(f, show_col_types = FALSE); nrow(readr::problems(r0)) # 0 — 인코딩은 못 잡음
```

옛 Windows 동작은 기본 인코딩이 CP949 인 로캘을 만들어 재현했다. 스크립트는 ASCII 로만 쓴다.

```bash
localedef -i ko_KR -f CP949 "$HOME/tmp/locales/ko_KR.CP949"
LOCPATH="$HOME/tmp/locales" LC_ALL=ko_KR.CP949 R --vanilla --no-echo -f legacy.R
# encoding = "unknown" OK / "UTF-8" ERROR invalid multibyte string, element 1 / "CP949" OK
```

### I-3. CP949 ≠ EUC-KR, 그리고 BOM

- `iconv(c("가자", "똠방각하", "햏", "뷁"), "UTF-8", "EUC-KR")` → 첫 값만 변환되고 나머지 3개는 `NA`. CP949 로는 4개 모두 변환된다.
- 이 4행을 CP949 로 저장한 파일을 읽은 결과:
  - `read.csv(fileEncoding = "CP949")` → 4행 정상
  - `read.csv(fileEncoding = "EUC-KR")` → **2행**(`가자`, `c방각하`), 경고 `invalid input found on input connection` 한 줄만
  - `readr::read_csv(locale = locale(encoding = "EUC-KR"))` → 오류 `Invalid multibyte sequence`
- UTF-8 BOM(Excel "CSV UTF-8") 파일: R 4.6.1 `read.csv()` 와 `read_csv()` 모두 BOM 없이 `이름`, `점수` 로 읽었다. BOM 을 따로 처리할 필요가 없다[Windows R < 4.2 에서는 달랐을 것 — 추론].
- 쓰기 바이트: `write.csv(fileEncoding = "UTF-8")` 37 B(첫 바이트 `22 ec 9d`), `write_excel_csv()` 40 B(`ef bb bf` BOM), `write.csv(fileEncoding = "CP949")` 30 B.

```r
x <- c("가자", "똠방각하", "햏", "뷁")
f <- tempfile(fileext = ".csv")
writeLines(iconv(c("이름", x), "UTF-8", "CP949"), f, useBytes = TRUE)
nrow(read.csv(f, fileEncoding = "CP949"))                   # 4
nrow(suppressWarnings(read.csv(f, fileEncoding = "EUC-KR"))) # 2
try(readr::read_csv(f, locale = readr::locale(encoding = "EUC-KR")))
```

### I-4. 열 형식 추측·결측 코드·앞자리 0·`problems()`

| 입력 | `read.csv()` | `readr::read_csv()` (2.2.0) |
|---|---|---|
| `diabetes_csv.txt` 의 `frame` 빈 칸 12개 | `""` 12개, NA 0 | NA 12개 |
| `id` = `007, 010` · `zip` = `01234, 34141` | `7, 10` · `1234, 34141` | `"007", "010"` · `"01234", "34141"` (`guess_parser(c("007","010"))` = character) |
| `sbp` = `120, -99, .` | character | character. `na = c("", "NA", "-99", ".")` 를 주면 numeric, 평균 120. `"."` 을 빼면 여전히 character |
| 5,000행 중 3000번째에만 `"<5"` | — | double 로 추측, NA 1개, 경고 `One or more parsing issues…`, `problems()$row` = **3001**(머리줄을 셈. 데이터 3000번째 행이 NA). `guess_max = Inf` 면 character |
| 1,500행 중 1001번째부터 텍스트 / 마지막 행만 텍스트 | — | 둘 다 character. readr 2.x 는 "앞 1000행만 본다"는 옛 설명과 달리 끝부분 행도 추측에 반영한다. 반면 5,000행 중간의 한 행은 놓친다(위 줄) — 파일 여러 곳에서 일부 행만 표본으로 보는 것으로 보임[추론] |
| 1,200행 NA 뒤 날짜 300행 | — | Date, NA 1200 (정상) |
| `diabetes_csv.txt` `ratio` 첫 값 | 원문 `3.599999905`, 화면 `3.6`, 17자리 `3.5999999049999998` | 같음 |

```r
f <- tempfile(fileext = ".csv")
v <- as.character(1:5000); v[3000] <- "<5"
write.csv(data.frame(id = 1:5000, x = v), f, row.names = FALSE)
d <- readr::read_csv(f, show_col_types = FALSE)   # 경고
readr::problems(d)                               # row 3001, expected "a double", actual "<5"
is.na(d$x[3000])                                 # TRUE
```

### I-5. 왕복 확인 — 무엇이 사라지나

원자료 `data.frame(id = c("007","010"), trt = factor(c("A","B")), visit = as.Date(c("2020-04-21","2020-04-23")))` 로 확인했다.

- `write.csv(d, f)` 를 기본값으로 쓰고 다시 읽으면 열 `X`(행 번호)가 붙는다. readr 로 읽으면 이름이 `...1` 이다.
- `write.csv(row.names = FALSE)` → `read.csv()`: `all.equal()` 이 차이 9줄을 보고한다. `id` 는 문자 → 수(`7`), `trt` 는 요인 → 문자, `visit` 는 Date → 문자가 됐다.
- `saveRDS()` → `readRDS()`: `identical` TRUE.
- `arrow::write_parquet()` → `read_parquet()`: 열 형식 character·factor·Date 가 보존되고 `identical` TRUE(`as.data.frame()` 뒤).
- `plasma` 를 `write.table(sep = "\t", row.names = FALSE)` → `read.table()`: `identical` TRUE. 저장소의 `dataset/plasma.txt` 와 바이트까지 같다.

### I-6. Excel 날짜 일련번호

`openxlsx` 로 A2:A3 에 날짜 2개, A4 에 "미상"을 넣은 xlsx 로 확인했다.

- `read_xlsx()` 기본 → character: `"43942" / "43944" / "미상"`
- `read_xlsx(col_types = "date")` → `2020-04-21 / 2020-04-23 / NA`, 경고 `Expecting date in A4 / R4C1: got '미상'`
- `as.Date(43942, origin = "1899-12-30")` = `janitor::excel_numeric_to_date(43942)` = 2020-04-21
- 장의 COVID 파일은 `date` 가 날짜 셀이 아니라 글자 셀이라 `<chr>` 로 읽힌다(C-27).

### I-7. 환경 오류 문구 (학생이 실제로 볼 메시지)

| 상황 | 메시지 | 근거 |
|---|---|---|
| Windows 경로를 그대로 붙여 넣음 `read.csv("C:\Users\student\data.csv")` | `'\U' used without hex digits in character string` | 재현(파서) |
| Linux·macOS 에서 `write.table(x, "clipboard")` | `'mode' for the clipboard must be 'r' on Unix` | 재현(Linux) |
| `clipr::write_clip()` 을 디스플레이 없는 Linux 에서 | `Clipboard on X11 requires that the DISPLAY envvar be configured.` | 재현 |
| `output/` 없이 `save.image(file = "output/all_obj.Rdata")` | 오류 `cannot open the connection`, 경고 `cannot open compressed file 'output/all_obj.RdataTmp', probable reason 'No such file or directory'` (임시 파일 이름이라 원인을 알아보기 어렵다) | 재현 |
| setup 에 `hook_output` 이 있는 문서에서 `rm(list = ls())` 로 청크를 끝냄 | `could not find function "hook_output"` (knitr·Quarto) | 재현 |
| `read_xlsx(col_types = readr::cols())` | `is.character(col_types) is not TRUE` | 재현 |
| zip 사본에서 325줄 | `` `path` does not exist: '…/dataset/covid-19-dataset/owid-covid-data.xlsx' `` | 재현 |
