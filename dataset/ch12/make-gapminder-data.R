# 12장 데이터 핸들링: Gapminder 통합 사례 파일 생성 스크립트
#
#   Rscript dataset/ch12/make-gapminder-data.R      (프로젝트 폴더에서 실행, readxl 필요)
#
# 원자료는 Gapminder(https://www.gapminder.org/data/) 가 공개한 세 파일이며 dataset/gapminder/ 에 있다.
#   _GM-Population - Dataset - v6.xlsx         인구. 2019년 12월 공개
#   GM-GDP per capita - Dataset - v26.xlsx     GDP, PPP(2011년 불변 국제달러). 2020년 1월 공개
#   GM-Life Expectancy- Dataset - v11.xlsx     기대수명. 2020년 1월 공개
# 지역 구분은 이전 강의노트(현행 10장)의 dataset/gapminder/gapminder-exercise.xlsx region 시트
# (UN 하위 지역 22개, 234곳)를 그대로 옮긴다.
#
# 값은 바꾸지 않았다. 2000~2020년만 남기고 열 이름을 영문 소문자로 바꾸었을 뿐이다.
# 2020년 값은 공개 시점(2019년 말)의 추계다.
# 원자료끼리 맞지 않는 곳(국가 코드의 대소문자, 국가 이름 표기, 자료가 있는 국가의 범위, 지역 이름의 오타)도
# 그대로 두었다. 강의노트 12장 통합 사례가 그것을 확인하는 절차를 다룬다.
#
#   gapminder-population.csv       geo, name, year, population         한 행 = 국가 하나의 한 해
#   gapminder-gdp.csv              geo, name, year, gdp_total          GDP 총액
#   gapminder-life-expectancy.csv  geo, name, year, life_expectancy
#   gapminder-regions.csv          iso, country, region                한 행 = 국가나 영토 하나
#   gapminder-world.csv            year, population, gdp_total, gdp_per_capita, life_expectancy   Gapminder 의 세계 값
#   gdp-per-capita-wide.csv        country, 2001, ..., 2020            독일, 한국, 미국의 1인당 GDP(넓은 표)

library(readxl)

src <- "dataset/gapminder"
out <- "dataset/ch12"
years <- 2000:2020
options(scipen = 999)   # GDP 총액이 1e+13 같은 지수 표기로 저장되지 않게 한다

read_gm <- function(file, sheet) {
  d <- as.data.frame(read_excel(file.path(src, file), sheet = sheet))
  d[d$time %in% years, ]
}
write_out <- function(d, file) {
  write.csv(d, file.path(out, file), row.names = FALSE, fileEncoding = "UTF-8")
}

pop_file <- "_GM-Population - Dataset - v6.xlsx"
gdp_file <- "GM-GDP per capita - Dataset - v26.xlsx"
lex_file <- "GM-Life Expectancy- Dataset - v11.xlsx"


# ---- 1. 국가별 지표 세 표 ------------------------------------------------------------

pop <- read_gm(pop_file, "data-for-countries-etc-by-year")
gdp <- read_gm(gdp_file, "data-for-countries-etc-by-year")
lex <- read_gm(lex_file, "data-for-countries-etc-by-year")

population <- data.frame(geo = pop$geo, name = pop$name, year = pop$time,
                         population = pop$Population)
gdp_total <- data.frame(geo = gdp$geo, name = gdp$name, year = gdp$time,
                        gdp_total = gdp$`GDP total`)
life_exp <- data.frame(geo = lex$geo, name = lex$name, year = lex$time,
                       life_expectancy = lex$`Life expectancy`)

write_out(population, "gapminder-population.csv")
write_out(gdp_total, "gapminder-gdp.csv")
write_out(life_exp, "gapminder-life-expectancy.csv")


# ---- 2. 지역 구분 -------------------------------------------------------------------

regions <- as.data.frame(read_excel(file.path(src, "gapminder-exercise.xlsx"), sheet = "region"))
write_out(regions[, c("iso", "country", "region")], "gapminder-regions.csv")


# ---- 3. Gapminder 가 발표한 세계 값 (외부 합계 대조용) -----------------------------------

w_pop <- read_gm(pop_file, "data-for-world-by-year")
w_gdp <- read_gm(gdp_file, "data-for-world-by-year")
w_lex <- read_gm(lex_file, "data-for-world-by-year")
stopifnot(identical(w_pop$time, w_gdp$time), identical(w_pop$time, w_lex$time))

world <- data.frame(year = w_pop$time,
                    population = w_pop$Population,
                    gdp_total = w_gdp$`GDP total`,
                    gdp_per_capita = w_gdp$`Income per person`,
                    life_expectancy = w_lex$`Life expectancy`)
write_out(world, "gapminder-world.csv")


# ---- 4. 넓은 표 예제: 세 나라의 1인당 GDP, 2001~2020 --------------------------------------

countries <- c("Germany", "South Korea", "United States")
pc <- merge(gdp_total, population, by = c("geo", "name", "year"))
pc <- pc[pc$name %in% countries & pc$year >= 2001, ]
pc$gdp_per_capita <- round(pc$gdp_total / pc$population, 2)
wide <- reshape(pc[, c("name", "year", "gdp_per_capita")], idvar = "name", timevar = "year",
                direction = "wide")
names(wide) <- sub("gdp_per_capita.", "", names(wide), fixed = TRUE)
names(wide)[1] <- "country"
wide <- wide[order(wide$country), c("country", as.character(2001:2020))]
write_out(wide, "gdp-per-capita-wide.csv")
