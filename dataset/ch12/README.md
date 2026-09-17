# 12장 데이터 핸들링 연습 파일

강의노트 12장 "데이터 핸들링"에서 쓰는 파일이다. 두 묶음으로 되어 있다.

1~4절에서 함수를 익힐 때 쓰는 자료(`mpg`, `titanic3.csv`, `nycflights13`, tidyr 내장 자료)는 이 폴더에 없다. `titanic3.csv` 는 `dataset/titanic3.csv` 에 있고, 나머지는 패키지에 들어 있다.

## 도서관 자료 (교육용 가상 자료)

**모두 교육용 가상 자료**이며 도서관 이름, 수치, 인구는 실제와 무관하다(시도 명칭만 실제). 11장 `dataset/ch11/library-loans.csv` 의 도서관 20곳을 이어받았고, 2026년 8월 대출권수는 11장 수치와 같다. 5절(결합), 7절(검증), 8절(AI와 함께)에서 쓴다.

| 파일 | 한 행 | 일부러 넣어 둔 함정 |
|---|---|---|
| `libraries.csv` | 도서관 하나 (20행) | 시도는 2026년 현재 정식 명칭(강원특별자치도, 전북특별자치도). 5월에 개관한 새솔도서관(L21)이 아직 등록되지 않음 |
| `loans-2026.csv` | 도서관 하나, 월은 열 (21행) | 월마다 열이 하나인 넓은 표. 휴관한 달은 빈칸(여울도서관 6~8월, 이음도서관 2월, 새솔도서관 1~4월). 기본 정보에 없는 L21 |
| `sido-population.csv` | 시도 하나 (18행) | 다른 기관 자료라 2022년 명칭(강원도, 전라북도)을 씀. 세종특별자치시 행이 두 번 들어 있음 |

파일을 다시 만들려면 프로젝트 폴더에서 `Rscript dataset/ch12/make-ch12-data.R` 을 실행한다. 1~7월 값은 `set.seed(20260917)` 로 만든다.

## Gapminder 자료 (공개 자료에서 추출)

[Gapminder](https://www.gapminder.org/data/) 원자료(`dataset/gapminder/` 의 인구 v6, GDP v26, 기대수명 v11, 2019년 12월과 2020년 1월 공개)에서 2000~2020년만 뽑았다. 값은 바꾸지 않았고 열 이름만 영문 소문자로 바꾸었다. **2020년 값은 공개 시점의 추계**다. 6절의 넓은 표 예제와 7절의 통합 사례에서 쓴다.

| 파일 | 한 행 | 행 |
|---|---|---:|
| `gapminder-population.csv` | 나라 하나의 한 해: `geo`, `name`, `year`, `population` | 4,137 |
| `gapminder-gdp.csv` | 나라 하나의 한 해: `gdp_total`(PPP, 2011년 불변 국제달러) | 4,095 |
| `gapminder-life-expectancy.csv` | 나라 하나의 한 해: `life_expectancy` | 3,960 |
| `gapminder-regions.csv` | 나라나 영토 하나: `iso`, `country`, `region`(UN 하위 지역 22개) | 234 |
| `gapminder-world.csv` | 한 해의 세계 값: 인구, GDP, 1인당 GDP, 기대수명 | 21 |
| `gdp-per-capita-wide.csv` | 나라 하나(독일, 한국, 미국), 연도는 열: 1인당 GDP 2001~2020 | 3 |

원자료끼리 맞지 않는 곳은 **고치지 않고 그대로** 두었다. 강의노트가 확인하는 절차를 다룬다.

- 나라 코드: 지표 표는 소문자(`afg`), 지역 표는 대문자(`AFG`). 교황청은 Gapminder 가 `hos`, 지역 표가 국제표준 코드 `VAT` 를 씀
- 자료가 있는 나라 수: 인구 197, GDP 195(교황청, 리히텐슈타인 없음), 기대수명 189. 안도라, 도미니카, 마셜제도는 기대수명이 18년치뿐
- 나라 이름: 지역 표는 UN 표기(`Republic of Korea`), Gapminder 는 흔히 쓰는 이름(`South Korea`). 28개 나라의 이름이 다름
- 지역 표에만 있는 영토 37곳(푸에르토리코, 마카오 등), 지역 이름의 오타 `Northen America`

지역 표는 이전 판 강의노트의 `dataset/gapminder/gapminder-exercise.xlsx` region 시트를 옮긴 것이다. 파일을 다시 만들려면 `Rscript dataset/ch12/make-gapminder-data.R` 을 실행한다(readxl 필요).
