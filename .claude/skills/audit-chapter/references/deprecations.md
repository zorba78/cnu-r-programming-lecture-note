# 구식·폐기 패턴 목록 (2026-09 기준, R 4.6 / tidyverse 2.x / ggplot2 4.x)

`grep -nE '<pattern>' <장.Rmd>` 로 검색한다. "수준": D=deprecated(경고), S=superseded(동작하나 권장 안 함), R=removed/CRAN 제거, T=도구·환경 안내 구식.

## 파이프·기본

| 패턴 | 수준 | 대체 | 비고 |
|---|---|---|---|
| `%>%` | — | **대체 대상 아님** | 강사 판단(2026-09-10): `\|>` 와 선택의 문제이지 구식이 아니다. 일괄 치환하지 않는다. 한 절 안에서 표기를 섞지만 않으면 된다. 두 연산자의 차이(placeholder `_`, 우변이 함수 호출이어야 함)를 설명하는 절은 오히려 유용하다 |
| `stringsAsFactors` | T | 설명 갱신 | R 4.0 부터 기본 FALSE. "FALSE 로 바꿔야 한다"는 설명은 구식 |
| `require(pkg)` 본문 | S | `library(pkg)` | setup 청크는 예외 |
| `tidy=TRUE` / formatR | S | 제거 | 코드 직접 정리 |
| `prompt=TRUE` | S | 제거 | 복사 불편 |
| `read.csv(..., stringsAsFactors=)` | T | 설명 갱신 | |
| `feather::` / `.feather` | S | `arrow::read_feather()` / parquet | feather 패키지는 유지보수 중단 |
| `xlsx::` (Java) | S | `readxl`, `writexl`, `openxlsx` | |
| `plyr::`, `reshape2::melt/dcast` | S | `dplyr`, `tidyr::pivot_*` | |
| `citr` | R | 제거 | CRAN 에서 삭제됨 (index.Rmd 에서 설치 시도) |
| `Sys.setlocale("LC_ALL","ko_KR")` 안내 | T | 확인 | R 4.2+ Windows 는 UTF-8 기본. CP949 설명 재검토 |

## dplyr / tidyr / purrr

| 패턴 | 수준 | 대체 | 동작 차이 |
|---|---|---|---|
| `gather(` | S | `pivot_longer(cols, names_to, values_to)` | 인수 순서·이름 다름, 열 순서 결과 다를 수 있음 |
| `spread(` | S | `pivot_wider(names_from, values_from)` | |
| `mutate_at/_if/_all`, `summarise_at/_if/_all`, `summarize_*` | S | `mutate(across(cols, fn))` | `.funs=list(a=,b=)` 이름 규칙 → `.names` |
| `filter_all/_at/_if` | S | `filter(if_any()/if_all())` | |
| `rename_all/_at/_if` | S | `rename_with()` | |
| `sample_n(`, `sample_frac(` | S | `slice_sample(n=, prop=)` | |
| `top_n(` | S | `slice_max()/slice_min()` | `top_n` 은 동점 포함, 정렬 안 함 |
| `summarise()` 가 여러 행 반환 | D | `reframe()` | dplyr 1.1 부터 경고 |
| `group_by() |> summarise()` 후 그룹 잔존 | T | `.by=` 인수 또는 `.groups=` 설명 | dplyr 1.1 의 `.by` 소개 권장 |
| `do(` | S | `reframe()`/`nest()`+`map()` | |
| `map_dfr(`, `map_dfc(`, `map_df(` | S | `map() |> list_rbind()` | |
| `separate(` | S | `separate_wider_delim/position/regex()` | |
| `distinct(.keep_all)` 등 | OK | | |
| `tibble::data_frame(` | R | `tibble()` | |
| `as.tibble(` | R | `as_tibble()` | |
| `nest()` 구 문법 `nest(-x)` | S | `nest(data = c(...))` | |
| `funs(` | R | `list(` / 람다 `\(x)` | |

## ggplot2 (4.x)

| 패턴 | 수준 | 대체 | 비고 |
|---|---|---|---|
| `qplot(` | D | `ggplot() + geom_*` | |
| `..density..`, `..count..`, `stat(density)` | D | `after_stat(density)` | |
| `size=` in `geom_line/segment/hline` 등 선 굵기 | D | `linewidth=` | 3.4.0+ |
| `aes_string(`, `aes_(` | D | `aes(.data[[var]])` 또는 `{{ }}` | |
| `theme(... = element_text(size))` 등 | OK | | 4.0 에서 theme 상속 구조 바뀜: 기존 그림 재확인 |
| `scale_*_discrete(guide=FALSE)` | D | `guide="none"` | |
| `geom_text(check_overlap)` | OK | | |
| `ggsave` 기본 dpi 설명 | T | | |
| `vioplot`, `car::scatterplot` 등 base 계열 | 유지 | | Part 2 는 base graphics 도 가르침. 삭제 대상 아님 |

## stringr / readr

| 패턴 | 수준 | 대체 |
|---|---|---|
| `read_csv()` 열 타입 메시지 설명 | T | readr 2.x 는 `show_col_types` |
| `read_csv(..., col_types = cols())` 설명 | OK | |
| `str_c` 등 | OK | stringr 1.5: `str_split_1`, `str_like` 신규 |
| `regmatches`/base regex | 유지 | Part 1 에서 base 우선 |

## R Markdown / 도구 안내

| 패턴 | 수준 | 대체 |
|---|---|---|
| RStudio 스크린샷·버전(1.x) | T | RStudio 2025.x 또는 Positron 병기 |
| `install.packages("tidyverse")` 만 안내 | OK | `pak::pak()` 병기 가능 |
| R Markdown 만 설명 | T | Quarto 병기 (`.qmd`, `#| ` 옵션, callout) |
| Shiny 언급 (08장 목표) | T | 실제 장이 없음. 삭제 또는 신설 결정 |
| `here` 패키지 주석 | OK | |
| `webshot`/`phantomjs` | R | `webshot2` |

## 데이터·링크

- `dataset/owid-covid-data.xlsx` (2020-04-21 집계) → 갱신 또는 다른 데이터
- `http://lib.stat.cmu.edu/datasets/Plasma_Retinol` 등 http 링크 → 접속 확인
- `img.livescore.co.kr` 이미지 (과제 3) → 접속 확인, 저작권 확인
- 유튜브·개인 블로그 링크 → 접속 확인

## 실행 시 나오는 경고 문구 (run_chunks.R 이 자동 표시)

`was deprecated in`, `is deprecated`, `superseded`, `defunct`, `Please use`, `no longer`
