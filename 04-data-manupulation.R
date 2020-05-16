## ---- echo=FALSE, message=FALSE----------------------------------------------------------------------------
rm(list = ls())
require(knitr)
opts_chunk$set(size="footnotesize",
                      comment = NA,
                      highlight = TRUE)
def.chunk.hook  <- knitr::knit_hooks$get("chunk")
knit_hooks$set(chunk = function(x, options) {
  x <- def.chunk.hook(x, options)
  ifelse(options$size != "normalsize", paste0("\\", options$size,"\n\n", x, "\n\n \\normalsize"), x)
})

hook_output = knit_hooks$get('output')
knit_hooks$set(output = function(x, options) {
  # this hook is used only when the linewidth option is not NULL
  if (!is.null(n <- options$linewidth)) {
    x = knitr:::split_lines(x)
    # any lines wider than n should be wrapped
    if (any(nchar(x) > n)) x = strwrap(x, width = n)
    x = paste(x, collapse = '\n')
  }
  hook_output(x, options)
})
opts_chunk$set(tidy.opts=list(blank=FALSE, width.cutoff=80))
options(linewidth = 60)

require(tidyverse)
require(rmarkdown)
require(knitr)
require(kableExtra)


## **학습 목표**

## 
## - Hadely Weckam이 개발한 데이터의 전처리 및 시각화를 위해 각광받는 tidyverse 패키지에 대해 알아본다

## - 데이터를 읽고, 저장하고, 목적에 맞게 가공하고, tidyverse 하에서 반복 계산 방법에 대해 알아본다.

## 

## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='100%', fig.cap="Data 분석의 과정. @wickham-2016r 에서 발췌"----
knitr::include_graphics('figures/data-science.png', dpi = NA)


## R 기본 함수를 이용해서 데이터 저장 파일의 가장 기본적인 형태인 텍스트 파일을 읽고 저장하는 방법에 대해 먼저 살펴봄. Base R에서 외부 데이터를 읽고 저장을 위한 함수는 매우 다양하지만 가장 많이 사용되고 있는 함수들에 대해 살펴볼 것임


## 외부 데이터를 불러온다는 것은 외부에 저장되어 있는 파일을 R 작업환경으로 읽어온다는 의미이기 때문에, 현재 작업공간의 작업 디렉토리(working directory) 확인이 필요.


## ----read-table-proto, eval=FALSE--------------------------------------------------------------------------
## # read.table(): 텍스트 파일 읽어오기
## read.table(
##   file, # 파일명. 일반적으로 폴더명 구분자
##         # 보통 folder/파일이름.txt 형태로 입력
##   header = FALSE, # 첫 번째 행을 헤더(변수명)으로 처리할 지 여부
##   sep = "", # 구분자 ",", "\t" 등의 형태로 입력
##   comment.char = "#", # 주석문자 지정
##   stringsAsFactors = TRUE, # 문자형 변수를 factor으로 변환할 지 여부
##   encoding = "unknown" # 텍스트의 encoding 보통 CP949 또는 UTF-8
##                        # 한글이 입력된 데이터가 있을 때 사용
## )


## 예시에 사용된 데이터들은 Clinical trial data analysis using R [@chen-2010]에서 제공되는 데이터임.


## ----read-table-ex1, error=TRUE----------------------------------------------------------------------------
# tab 구분자 데이터 불러오기
# dataset 폴더에 저장되어 있는 DBP.txt 파일 읽어오기
dbp <- read.table("dataset/DBP.txt", sep = "\t", header = TRUE)
str(dbp)

# 문자형 값들을 factor로 변환하지 않는 경우
dbp2 <- read.table("dataset/DBP.txt", sep = "\t", 
                   header = TRUE, 
                   stringsAsFactors = FALSE)
str(dbp2)

# 데이터 형태 파악
head(dbp)

# 콤마 구분자 데이터 불러오기
# dataset 폴더에 저장되어 있는 diabetes_csv.txt 파일 읽어오기
diab <- read.table("dataset/diabetes_csv.txt", sep = ",", header = TRUE)
str(diab)
head(diab)


# Encoding이 다른 경우(한글데이터 포함): 
# 한약재 사전 데이터 (CP949 encoding으로 저장)
# tab 구분자 데이터 사용
# UTF-8로 읽어오기
herb <- read.table("dataset/herb_dic_sample.txt", sep = "\t", 
                   header = TRUE, 
                   encoding = "UTF-8", 
                   stringsAsFactors = FALSE)
head(herb)

# CP949로 읽어오기
herb <- read.table("dataset/herb_dic_sample.txt", sep = "\t", 
                   header = TRUE, 
                   encoding = "CP949", 
                   stringsAsFactors = FALSE)
head(herb)




## ----read-table-ex2----------------------------------------------------------------------------------------

# Plasma 데이터: http://lib.stat.cmu.edu/datasets/Plasma_Retinol 
input1 <- ("64	2	2	21.4838	1	1298.8	57	6.3	0	170.3	1945	890	200	915
76	2	1	23.87631	1	1032.5	50.1	15.8	0	75.8	2653	451	124	727
38	2	2	20.0108	2	2372.3	83.6	19.1	14.1	257.9	6321	660	328	721
40	2	2	25.14062	3	2449.5	97.5	26.5	0.5	332.6	1061	864	153	615
72	2	1	20.98504	1	1952.1	82.6	16.2	0	170.8	2863	1209	92	799
40	2	2	27.52136	3	1366.9	56	9.6	1.3	154.6	1729	1439	148	654
65	2	1	22.01154	2	2213.9	52	28.7	0	255.1	5371	802	258	834
58	2	1	28.75702	1	1595.6	63.4	10.9	0	214.1	823	2571	64	825
35	2	1	23.07662	3	1800.5	57.8	20.3	0.6	233.6	2895	944	218	517
55	2	2	34.96995	3	1263.6	39.6	15.5	0	171.9	3307	493	81	562")

input2 <- ("AGE: Age (years)
	SEX: Sex (1=Male, 2=Female).
	SMOKSTAT: Smoking status (1=Never, 2=Former, 3=Current Smoker)
	QUETELET: Quetelet (weight/(height^2))
	VITUSE: Vitamin Use (1=Yes, fairly often, 2=Yes, not often, 3=No)
	CALORIES: Number of calories consumed per day.
	FAT: Grams of fat consumed per day.
	FIBER: Grams of fiber consumed per day.
	ALCOHOL: Number of alcoholic drinks consumed per week.
	CHOLESTEROL: Cholesterol consumed (mg per day).
	BETADIET: Dietary beta-carotene consumed (mcg per day).
	RETDIET: Dietary retinol consumed (mcg per day)
	BETAPLASMA: Plasma beta-carotene (ng/ml)
	RETPLASMA: Plasma Retinol (ng/ml)")

plasma <- read.table(textConnection(input1), sep = "\t", header = F)
codebook <- read.table(textConnection(input2), sep = ":", header = F)
varname <- gsub("^\\s+", "", codebook$V1) # 변수명 지정

names(plasma) <- varname
head(plasma)



## ----write-table-proto, eval=FALSE-------------------------------------------------------------------------
## # write.table() R 객체를 텍스트 파일로 저장하기
## write.table(
##   data_obj, # 저장할 객체 이름
##   file,  # 저장할 위치 및 파일명  또는
##          # 또는 "파일쓰기"를 위한 연결 명칭
##   sep,   # 저장 시 사용할 구분자
##   row.names = TRUE # 행 이름 저장 여부
## )


## ----write-table-ex-1--------------------------------------------------------------------------------------
# 위에서 읽어온 plasma 객체를 dataset/plasma.txt 로 내보내기
# 행 이름은 생략, tab으로 데이터 구분

write.table(plasma, "dataset/plasma.txt", 
            sep = "\t", row.names = F)



## ----write-table-ex-2--------------------------------------------------------------------------------------
# clipboard로 복사 후 excel 시트에 해당 데이터 붙여넣기
# Ctrl + V
write.table(plasma, "clipboard", 
            sep = "\t", row.names = F)


## ----im-exp-Rdata-ex---------------------------------------------------------------------------------------
# 현재 작업공간에 존재하는 모든 객체를 "output" 폴더에 저장
# output 폴더가 존재하지 않는 경우 아래 명령 실행
# dir.create("output") 
ls()
save.image(file = "output/all_obj.Rdata")

rm(list = ls()) 
ls()
# 저장된 binary 파일(all_obj.Rdata) 불러오기
load("output/all_obj.Rdata")
ls()

# dnp, plasma 데이터만 output 폴더에 sub_obj.Rdata로 저장
save(dbp, plasma, file = "output/sub_obj.Rdata")
rm(list = c("dbp", "plasma"))
ls()

# sub_obj.Rdata 파일 불러오기
load("output/sub_obj.Rdata")
ls()


## ----im-exp-rds-ex-----------------------------------------------------------------------------------------
# 대용량 파일 dataset/pulse.csv 불러오기
# system.time(): 명령 실행 시가 계산 함수
system.time(pulse <- read.csv("dataset/pulse.csv", header = T))

# saveRDS()함수를 이용해 output/pulse.rds 파일로 저장
saveRDS(pulse, "output/pulse.rds")
rm(pulse); ls()

system.time(pulse <- readRDS("output/pulse.rds"))



## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='100%'-------------------------------------
knitr::include_graphics('figures/tidyverse_packages.png', dpi = NA)


## ----read_csv-proto, eval=FALSE----------------------------------------------------------------------------
## read_csv(
##   file, # 파일 명
##   col_names = TRUE, # 첫 번째 행를 변수명으로 처리할 것인지 여부
##                     # read.table(), read.csv()의 header 인수와 동일
##   col_types = NULL, # 열(변수)의 데이터 형 지정
##                     # 기본적으로 데이터 유형을 자동으로 감지하지만,
##                     # 입력 텍스트의 형태에 따라 데이터 유형을
##                     # 잘못 추측할 수 있기 때문에 간혹 해당 인수 입력 필요
##                     # col_* 함수 또는 campact string으로 지정 가능
##                     # c=character, i=integer, n=number, d=double,
##                     # l=logical, f=factor, D=date, T=date time, t=time
##                     # ?=guess, _/- skip column
##   progress, # 데이터 읽기/쓰기  진행 progress 표시 여부
## )


## ----read_csv-ex-------------------------------------------------------------------------------------------
# dataset/titanic3.csv 불러오기
titanic <- read_csv("dataset/titanic3.csv")
titanic

# read.csv와 비교
head(read.csv("dataset/titanic3.csv", header = T), 10)

# column type을 변경
titanic2 <- read_csv("dataset/titanic3.csv", 
                     col_types = "iicfdiicdcfcic")
titanic2

# 특정 변수만 불러오기
titanic3 <- read_csv("dataset/titanic3.csv", 
                     col_types = cols_only(
                       pclass = col_integer(), 
                       survived = col_integer(), 
                       sex = col_factor(), 
                       age = col_double()
                     ))
titanic3

# 대용량 데이터셋 읽어올 때 시간 비교
# install.packages("feather") # feather package
require(feather)
system.time(pulse <- read.csv("dataset/pulse.csv", header = T))
write_feather(pulse, "dataset/pulse.feather")
system.time(pulse <- readRDS("output/pulse.rds"))
system.time(pulse <- read_csv("dataset/pulse.csv"))
system.time(pulse <- read_feather("dataset/pulse.feather"))



## ----read_xlsx-ex, eval=FALSE------------------------------------------------------------------------------
## read_xlsx(
##   path, # Excel 폴더 및 파일 이름
##   sheet = NULL, # 불러올 엑셀 시트 이름
##                 # default = 첫 번째 시트
##   col_names = TRUE, # read_csv()의 인수와 동일한 형태 입력
##   col_types = NULL  # read_csv()의 인수와 동일한 형태 입력
## )
## 


## ----readxls-ex--------------------------------------------------------------------------------------------
# 2020년 4월 21일자 COVID-19 국가별 유별률 및 사망률 집계 자료
# dataset/owid-covid-data.xlsx 파일 불러오기 
# install.packages("readxl")
require(readxl)
covid19 <- read_xlsx("dataset/covid-19-dataset/owid-covid-data.xlsx")
covid19

# 여러 시트를 동시에 불러올 경우
# dataset/datR4CTDA.xlsx 의 모든 시트 불러오기
path <- "dataset/datR4CTDA.xlsx"
sheet_name <- excel_sheets(path)
dL <- lapply(sheet_name, function(x) read_xlsx(path, sheet = x))
names(dL) <- sheet_name

# Tidyverse 에서는? (맛보기)
path %>% 
  excel_sheets %>% 
  set_names %>% 
  map(~read_xlsx(path = path, sheet = .x)) -> dL2




## ----create_tibble-ex1-------------------------------------------------------------------------------------
head(iris)
as_tibble(iris)



## ----create_tibble-ex2, error=TRUE-------------------------------------------------------------------------
# 벡터로부터 tibble 객체 생성
tibble(x = letters, y = rnorm(26), z = y^2)

# 데이터 프레임으로 위와 동일하게 적용하면?
data.frame(x = letters, y = rnorm(26), z = y^2)

# 벡터의 길이가 다른 경우
# 길이가 1인 벡터는 재사용 가능
tibble(x = 1, y = rep(0:1, each = 4), z = 2)

# 데이터 프레임과 마찬가지로 비정상적 문자를 변수명으로 사용 가능
# 역따옴표(``) 
tibble(`2000` = "year", 
       `:)` = "smile", 
       `:(` = "sad")



## ----------------------------------------------------------------------------------------------------------
tribble(
   ~x, ~y,   ~z,
  "M", 172,  69,
  "F", 156,  45, 
  "M", 165,  73, 
)


## ----------------------------------------------------------------------------------------------------------
head(iris)
dd <- as_tibble(iris)
dd



## `dplyr`에서 제공하는 "동사"(함수)로 데이터(데이터 프레임) 전처리 방법에 대해 익힌다.


## ---- echo=FALSE-------------------------------------------------------------------------------------------
`동사(함수)` <- c("filter()", "arrange()", "select()", "mutate()", "summarise()", "group_by()")
`내용` <- c("행 추출", "내림차순/오름차순 정렬", "열 선택", "열 추가 및 변환", "집계", "그룹별 집계 및 함수 적용")
`R base 패키지 함수` <- c("subset()",  
                         "order(), sort()", 
                         "data[, c('var_name01', 'var_name03')]", 
                         "transform()", 
                         "aggregate()", 
                         "") 
tab4_01 <- data.frame(`동사(함수)`, 
                      `내용`, 
                      `R base 패키지 함수`, 
                       check.names = FALSE, 
                       stringsAsFactors = FALSE)
kable(tab4_01,
      align = "lll",
      escape = TRUE, 
      booktabs = T, caption = "dplyr 패키지 함수와 R base 패키지 함수 비교") %>%
  kable_styling(bootstrap_options = c("striped"), 
                position = "center", 
                font_size = 10, 
                full_width = TRUE, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "2cm") %>% 
  column_spec(2, width = "4cm") %>% 
  column_spec(3, width = "4cm") %>% 
  row_spec(1:6, monospace = TRUE)



## R에서 데이터 전처리 및 분석을 수행할 때, 간혹 동일한 이름의 함수명들이 중복된 채 R 작업공간에 읽어오는 경우가 있는데, 이 경우 가장 마지막에 읽어온 패키지의 함수를 작업공간에서 사용한다. 예를 들어 R base 패키지의 `filter()` 함수는 시계열 데이터의 노이즈를 제거하는 함수이지만, tidyverse 패키지를 읽어온 경우, dplyr 패키지의 `filter()` 함수와 이름이 중복되기 때문에 R 작업공간 상에서는 dplyr 패키지의 `filter()`가 작동을 함. 만약 stats 패키지의 `filter()` 함수를 사용하고자 하면 `stats::filter()`를 사용. 이를 더 일반화 하면 현재 컴퓨터 상에 설치되어 있는 R 패키지의 특정 함수는 `::` 연산자를 통해 접근할 수 있으며, `package_name::function_name()` 형태로 접근 가능함.


## ----pipe-ex-----------------------------------------------------------------------------------------------
# base R 문법 적용
print(head(iris, 4))

# %>% 연산자 이용
iris %>% head(4) %>% print

# setosa 종에 해당하는 변수들의 평균 계산
apply(iris[iris$Species == "setosa", -5], 2, mean)

# tidyverse의 pipe 연산자 이용
# require(tidyverse)

iris %>% 
  filter(Species == "setosa") %>% 
  select(-Species) %>% 
  summarise_all(mean)

# Homework #3 b-c 풀이를 위한 pipe 연산 적용
# df <- within(df, {
#   am <- factor(am, levels = 0:1, 
#                labels = c("automatic", "manual"))
# })
# ggregate(cbind(mpg, disp, hp, drat, wt, qsec) ~ am, 
#           data = df, 
#           mean)
# aggregate(cbind(mpg, disp, hp, drat, wt, qsec) ~ am, 
#           data = df, 
#           sd)

mtcars %>% 
  mutate(am = factor(vs, 
                     levels = 0:1, 
                     labels = c("automatic", "manual"))) %>% 
  group_by(am) %>% 
  summarise_at(vars(mpg, disp:qsec), 
               list(mean = mean, 
                    sd = sd))



## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='60%', fig.cap="filter() 함수 다이어그램"----
knitr::include_graphics('figures/dplyr-filter.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%', fig.cap="가능한 모든 boolean 연산 종류: x는 좌변, y는 우변을 의미하고 음영은 연산 이후 선택된 부분을 나타냄."----
knitr::include_graphics('figures/venn-diagram.png', dpi = NA)


## ----filter-proto, eval=FALSE------------------------------------------------------------------------------
## # filter() 동사 prototype
## dplyr::filter(x, # 데이터 프레임 또는 티블 객체
##               condition_01, # 첫 번째 조건
##               condition_02, # 두 번째 조건
##                             # 두 번째 인수 이후 조건들은
##                             # condition_1 & condition 2 & ... & condition_n 임
##               ...)


## ---- echo=FALSE-------------------------------------------------------------------------------------------
`변수명` <- c("manufacturer", "model", "displ", 
              "year", "cyl", "trans", "drv", 
              "cty", "hwy", "fl", "class")
`변수설명(영문)` <- c("manufacturer name",
                      "model name",
                      "engine displacement, in litres",
                      "year of manufacture",
                      "number of cylinders",
                      "type of transmission",
                      "the type of drive train, where f = front-wheel drive, r = rear wheel drive, 4 = 4wd",
                      "city miles per gallon",
                      "highway miles per gallon",
                      "fuel type: e = E85, d = diesel, r = regular, p = premium, c = CNG", 
                      "'type' of car")
`변수설명(국문)` <- c("제조사", 
                "모델명", 
                "배기량 (리터)", 
                "제조년도", 
                "엔진 기통 수", 
                "트렌스미션", 
                "구동 유형: f = 전륜구동, r = 후륜구동, 4 = 4륜 구동", 
                "시내 연비", 
                "고속 연비", 
                "연료: e = 에탄올 85, r = 가솔린, p = 프리미엄, d = 디젤, c = CNP", 
                "자동차 타입")
tab4_03 <- data.frame(`변수명`, 
                      `변수설명(영문)`, 
                      `변수설명(국문)`, 
                       check.names = FALSE, 
                       stringsAsFactors = FALSE)
kable(tab4_03,
      align = "lll",
      escape = TRUE, 
      booktabs = T, caption = "mpg 데이터셋 설명(코드북)") %>%
  kable_styling(bootstrap_options = c("striped"), 
                position = "center", 
                font_size = 10, 
                full_width = TRUE, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "2cm") %>% 
  column_spec(2, width = "5cm") %>% 
  column_spec(3, width = "5cm") %>% 
  row_spec(1:length(`변수명`), monospace = TRUE)



## ----filter-ex-mpg-----------------------------------------------------------------------------------------
glimpse(mpg)

# 현대 차만 추출
## 기본 문법 사용
# mpg[mpg$manufacturer == "hyundai", ]
# subset(mpg, manufacturer == "hyundai")

## filter() 함수 사용
# filter(mpg, manufacturer == "hyundai")

## pipe 연산자 사용
mpg %>% 
  filter(manufacturer == "hyundai")

# 시내 연비가 20 mile/gallon 이상이고 타입이 suv 차량 추출
## 기본 문법 사용
# mpg[mpg$cty >= 20 & mpg$class == "suv", ]
# subset(mpg, cty >= 20 & class == "suv")

## filter() 함수 사용
# filter(mpg, cty >= 20, class == "suv")

## pipe 연산자 사용
mpg %>% 
  filter(cty >= 20, 
         class == "suv")

# 제조사가 audi 또는 volkswagen 이고 고속 연비가 30 miles/gallon 인 차량만 추출
mpg %>% 
  filter(manufacturer == "audi" | manufacturer == "volkswagen", 
         hwy >= 30)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='40%', fig.cap="arrange() 함수 다이어그램"----
knitr::include_graphics('figures/dplyr-arrange.png', dpi = NA)


## ---- eval=FALSE-------------------------------------------------------------------------------------------
## arrange(data, # 데이터 프레임 또는 티블 객체
##         var1, # 기준 변수 1
##         var2, # 기준 변수 2
##         ...)


## ----arrange-ex-mpg----------------------------------------------------------------------------------------
# 시내 연비를 기준으로 오름차순 정렬
## R 기본 문법 사용
# mpg[order(mpg$cty), ]

## arrange 함수 사용
# arrange(mpg, cty)

## pipe 사용
mpg_asc <- mpg %>% arrange(cty)
mpg_asc %>% print


# 시내 연비는 오름차순, 차량 타입은 내림차순(알파벳 역순) 정렬
## R 기본 문법 사용
### 문자형 벡터의 순위 계산을 위해 rank() 함수 사용
mpg_sortb <- mpg[order(mpg$cty, -rank(mpg$class)), ]

## arrange 함수 사용
mpg_sortt <- mpg %>% arrange(cty, desc(class))
mpg_sortt %>% print

# 두 데이터 셋 동일성 여부
identical(mpg_sortb, mpg_sortt)



## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='50%', fig.cap="select() 함수 다이어그램"----
knitr::include_graphics('figures/dplyr-select.png', dpi = NA)


## ----select-proto, eval=FALSE------------------------------------------------------------------------------
## select(
##   data, # 데이터 프레임 또는 티블 객체
##   var_name1, # 변수 이름 (따옴표 없이도 가능)
##   var_name2,
##   ...
## )


## ----select-ex-1-------------------------------------------------------------------------------------------
# 제조사(manufacturer), 모델명(model), 배기량(displ)
# 제조년도(year), 시내연비 (cty)만 추출

## 기본 R 문법 이용한 변수 추출
glimpse(mpg[, c("manufacturer", "model", "displ", "year", "cty")])
# glimpse(mpg[, c(1:4, 8)])
# glimpse(mpg[, names(mpg) %in% c("manufacturer", "displ", "model",
#                         "year", "cty")])

## select() 함수 이용
### 아래 스크립트는 모두 동일한 결과를 반환
# mpg %>% select(1:4, 8)
# 
# mpg %>% 
#   select(c("manufacturer", "model", "displ", "year", "cty"))

mpg %>% 
  select("manufacturer", "model", "displ", "year", "cty") %>% 
  glimpse



## ----------------------------------------------------------------------------------------------------------
# 제조사(manufacturer), 모델명(model), 배기량(displ)
# 제조년도(year), 시내연비 (cty)만 추출
## select() 따옴표 없이 변수명 입력
mpg %>% 
  select(manufacturer, model, displ, year, cty) %>% 
  glimpse

## : 연산자로 변수 범위 지정
mpg %>% 
  select(manufacturer:year, cty) %>% 
  glimpse

## 관심 없는 열을 -로 제외 가능
mpg %>% 
  select(-cyl, -trans, -drv, -hwy, -fl, -class) %>% 
  glimpse

## 조금 더 간결하게 (`:`와 `-` 연산 조합)
mpg %>% 
  select(-cyl:-drv, -hwy:-class) %>% 
  glimpse

### 동일한 기능: -는 괄호로 묶을 수 있음
mpg %>% 
  select(-(cyl:drv), -(hwy:class)) %>% 
  glimpse

# select() 함수를 이용해 변수명 변경 가능
mpg %>% 
  select(city_mpg = cty) %>% 
  glimpse



## ----------------------------------------------------------------------------------------------------------
# "m"으로 시작하는 변수 제거
## 기존 select() 함수 사용
mpg %>% 
  select(-manufacturer, -model) %>% 
  glimpse

## select() + starts_with() 함수 사용
mpg %>% 
  select(-starts_with("m")) %>% 
  glimpse

# "l"로 끝나는 변수 선택: ends_with() 함수 사용
mpg %>% 
  select(ends_with("l")) %>% 
  glimpse

# dplyr 내장 데이터: starwars에서 이름, 성별, "color"를 포함하는 변수 선택
## contains() 함수 사용
starwars %>% 
  select(name, gender, contains("color")) %>% 
  head

# 다시 mpg 데이터... 
## 맨 마지막 문자가 "y"로 끝나는 변수 선택(제조사, 모델 포함)
## matches() 사용
mpg %>% 
  select(starts_with("m"), matches("y$")) %>% 
  glimpse

# cty, hwy 변수를 각각 1-2 번째 열에 위치
mpg %>% 
  select(matches("y$"), everything()) %>% 
  glimpse



## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='60%', fig.cap="mutate() 함수 다이어그램"----
knitr::include_graphics('figures/dplyr-mutate.png', dpi = NA)


## ---- error=TRUE-------------------------------------------------------------------------------------------
# mpg 데이터 셋의 연비 단위는 miles/gallon으로 입력 -> kmh/l 로 변환
mile <- 1.61 #km
gallon <- 3.79 #litres
kpl <- mile/gallon

## 기본 R 문법
glimpse(transform(mpg, 
                  cty_kpl = cty * kpl, 
                  hwy_kpl = hwy * kpl))

## tidyverse 문법
mpg %>% 
  mutate(cty_kpl = cty*kpl, 
         hwy_kpl = hwy*kpl) %>% 
  glimpse

# 새로 생성한 변수를 이용해 변환 변수를 원래 단위로 바꿔보기
## R 기본 문법: transform() 사용
glimpse(transform(mpg, 
                  cty_kpl = cty * kpl, 
                  hwy_kpl = hwy * kpl,
                  cty_raw = cty_kpl/kpl,
                  hwy_raw = hwy_kpl/kpl,
                  )) 

## Tidyverse 문법
mpg %>% 
  mutate(cty_kpl = cty*kpl, 
         hwy_kpl = hwy*kpl, 
         cty_raw = cty_kpl/kpl,
         hwy_raw = hwy_kpl/kpl) %>% 
  glimpse



## ----------------------------------------------------------------------------------------------------------
`연비` <- mpg %>% 
  transmute(cty_kpl = cty*kpl, 
            hwy_kpl = hwy*kpl, 
            cty_raw = cty_kpl/kpl,
            hwy_raw = hwy_kpl/kpl)
`연비` %>% print


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='60%', fig.cap="summarise() 함수 다이어그램"----
knitr::include_graphics('figures/dplyr-summarise.png', dpi = NA)


## ----------------------------------------------------------------------------------------------------------
# cty, hwy의 평균과 표준편차 계산
mpg %>% 
  summarise(mean_cty = mean(cty),
            sd_cty = sd(cty), 
            mean_hwy = mean(hwy), 
            sd_hwy = sd(hwy))


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='80%', fig.cap="group_by() 함수 다이어그램"----
knitr::include_graphics('figures/dply-group-by.png', dpi = NA)


## ----------------------------------------------------------------------------------------------------------
# 모델, 년도에 따른 cty, hwy 평균 계산
by_mpg <- group_by(mpg, model, year)
## 그룹 지정 check
by_mpg %>% 
  head %>% 
  print

## 통계량 계산
by_mpg %>% 
  summarise(mean_cty = mean(cty), 
            mean_hwy = mean(hwy)) %>% 
  print


## ---- eval=FALSE-------------------------------------------------------------------------------------------
## ## by_group() chain 연결
## mean_mpg <- mpg %>%
##   group_by(model, year) %>%
##   summarise(mean_cty = mean(cty),
##             mean_hwy = mean(hwy))


## ----------------------------------------------------------------------------------------------------------
# 제조사 별 시내연비가 낮은 순으로 정렬
audi <- mpg %>% 
  group_by(manufacturer) %>% 
  arrange(cty) %>% 
  filter(manufacturer == "audi")

audi %>% print


## 그룹화된 데이터셋을 다시 그룹화 하지 않은 원래 데이터셋으로 변경할 때 `ungroup()` 함수를 사용


## ----------------------------------------------------------------------------------------------------------
# 1 ~ 8행에 해당하는 데이터 추출
slice_mpg <- mpg %>% slice(1:8)
slice_mpg %>% print

# 각 모델 별 첫 번째 데이터만 추출
slice_mpg_grp <- mpg %>% 
  group_by(model) %>% 
  slice(1) %>% 
  arrange(model)

slice_mpg_grp %>% print


## ----------------------------------------------------------------------------------------------------------
# mpg 데이터에서 시내 연비가 높은 데이터 5개 추출
mpg %>% 
  top_n(5, cty) %>% 
  arrange(desc(cty))


## ----------------------------------------------------------------------------------------------------------
# mpg 데이터에서 중복데이터 제거 (모든 열 기준)
mpg_uniq <- mpg %>% distinct()
mpg_uniq %>% print

# model을 기준으로 중복 데이터 제거
mpg_uniq2 <- mpg %>% 
  distinct(model, .keep_all = TRUE) %>% 
  arrange(model)

mpg_uniq2 %>% head(6) %>% print

# 위 그룹별 slice(1) 예제와 비교
identical(slice_mpg_grp %>% ungroup, mpg_uniq2)


## ----------------------------------------------------------------------------------------------------------
# 전체 234개 행에서 3개 행을 랜덤하게 추출
mpg %>% sample_n(3)

# 전체 234개 행의 5%에 해당하는 행을 랜덤하게 추출
mpg %>% sample_frac(0.05)


## ----------------------------------------------------------------------------------------------------------
# 변수명 변셩 
## R 기본 문법으로 변수명 변경
varn_mpg <- names(mpg) # 원 변수명 저장
names(mpg)[5] <- "cylinder" # cyl을 cylinder로 변셩
names(mpg) <- varn_mpg #

## Tidyverse 문법: rename() 사용
mpg %>% 
  rename(cylinder = cyl) %>% 
  head %>% 
  print

## cty를 city_mpg, hwy를 hw_mpg로 변경
mpg %>% 
  rename(city_mpg = cty, 
         hw_mpg = hwy) %>% 
  print


## ----------------------------------------------------------------------------------------------------------
# 전체 행 개수 (nrow(data))와 유사
mpg %>% 
  tally %>% 
  print

# 제조사, 년도별 데이터 개수 
mpg %>% 
  group_by(manufacturer, year) %>% 
  tally %>% 
  ungroup %>% 
  print



## ----------------------------------------------------------------------------------------------------------
# 제조사, 년도별 데이터 개수: tally() 예시와 비교
mpg %>% 
  count(manufacturer, year) %>% 
  print


## ----------------------------------------------------------------------------------------------------------
# 제조사, 년도에 따른 배기량, 시내연비의 평균 계산(그룹 별 n 포함)
mpg %>% 
  group_by(manufacturer, year) %>% 
  summarise(
    N = n(), 
    mean_displ = mean(displ), 
    mean_hwy = mean(cty)) %>% 
  print

# mutate, filter에서 사용하는 경우
mpg %>% 
  group_by(manufacturer, year) %>% 
  mutate(N = n()) %>% 
  filter(n() < 4) %>% 
  print
  


## ----------------------------------------------------------------------------------------------------------
# mtcars 데이터셋 사용
## filter_all()
### 모든 변수들이 100 보다 큰 케이스 추출
mtcars %>% 
  filter_all(all_vars(. > 100)) %>% 
  print

### 모든 변수들 중 하나라도 300 보다 큰 케이스 추출
mtcars %>% 
  filter_all(any_vars(. > 300)) %>% 
  print

## filter_at()
### 기어 개수(gear)와 기화기 개수(carb)가 짝수인 케이스만 추출
mtcars %>% 
  filter_at(vars(gear, carb),
            ~ . %% 2 == 0) %>% # 대명사 앞에 ~ 표시를 꼭 사용해야 함
  print

## filter_if()
### 내림한 값이 원래 값과 같은 변수들 모두 0이 아닌 케이스 추출
mtcars %>% 
  filter_if(~ all(floor(.) == .), 
            all_vars(. != 0)) %>% 
  # filter_if(~ all(floor(.) == .),
  #           ~ . != 0) %>%
  print



## ----------------------------------------------------------------------------------------------------------
# select_all() 예시
## mpg 데이터셋의 모든 변수명을 대문자로 변경
mpg %>% 
  select_all(~toupper(.)) %>% 
  print

# select_if() 예시
## 문자형 변수를 선택하고 선택한 변수의 이름을 대문자로 변경
mpg %>% 
  select_if(~ is.character(.), ~ toupper(.)) %>% 
  print

# select_at() 예시
## model에서 cty 까지 변수를 선택하고 선택한 변수명을 대문자로 변경
mpg %>% 
  select_at(vars(model:cty), ~ toupper(.)) %>% 
  print



## ----------------------------------------------------------------------------------------------------------
# mutate_all() 예시
## 문자형 변수를 선택 후 모든 변수를 요인형으로 변환
mpg %>% 
  select_if(~is.character(.)) %>% 
  mutate_all(~factor(.)) %>% 
  head %>% 
  print

# mutate_at() 예시
## cty, hwy 단위를 km/l로 변경
mpg %>% 
  mutate_at(vars(cty, hwy), 
            ~ . * kpl) %>%  # 원래 변수를 변경
  head %>% 
  print

## "m"으로 시작하거나 "s"로 끝나는 변수 선택 후 요인형으로 변환
mpg %>% 
  mutate_at(vars(starts_with("m"), 
                 ends_with("s")), 
            ~ factor(.)) %>% 
  summary

# mutate_if() 예시 
## 문자형 변수를 요인형으로 변환
mpg %>% 
  mutate_if(~ is.character(.), ~ factor(.)) %>% 
  summary




## ----------------------------------------------------------------------------------------------------------
# summary_all() 예시
## 모든 변수의 최솟값과 최댓값 요약
## 문자형 변수는 알파벳 순으로 최솟값과 최댓값 반환
## 복수의 함수를 적용 시 list()함수 사용
mpg %>% 
  summarise_all(list(min = ~ min(.), 
                     max = ~ max(.))) %>% 
  glimpse

# summary_at() 예시
## dipl, cyl, cty, hwy에 대해 제조사 별 n수와 평균과 표준편차 계산
mpg %>% 
  add_count(manufacturer) %>% # 행 집계 결과를 열 변수로 추가하는 함수
  group_by(manufacturer, n) %>% 
  summarise_at(vars(displ, cyl, cty:hwy), 
               list(mean = ~ mean(.), 
                    sd = ~ sd(.))) %>% 
  print

# summary_if() 예시
## 1) 문자형 변수이거나 모든 값이 1999보다 크거나 같은 변수이거나 
##     8보다 작거나 같고 정수인 변수를 factor 변환
## 2) 수치형 변수에 대한 제조사 별 n, 평균, 표준편차를 구한 후
## 3) 평균 cty (cty_mean) 기준 내림차순으로 정렬
mpg %>% 
  mutate_if(~ is.character(.) | all(. >= 1999) | 
              (all(. <= 8) & is.integer(.)), 
            ~ factor(.)) %>% 
  add_count(manufacturer) %>% 
  group_by(manufacturer, n) %>% 
  summarise_if(~ is.numeric(.), 
               list(mean = ~ mean(.), 
                    sd = ~ sd(.))) %>% 
  arrange(desc(cty_mean)) %>% 
  print



## 본 강의에서는 **mutating join** 에 대해서만 다룸


## ----------------------------------------------------------------------------------------------------------
# install.packages("nycflights13")
require(nycflights13)


## ---- echo=FALSE-------------------------------------------------------------------------------------------
flights %>% print


## ---- echo=FALSE-------------------------------------------------------------------------------------------
`변수` <- c("year, month, day", 
            "dep_time, arr_time",
            "sched_dep_time, sched_arr_time", 
            "dep_delay, arr_delay", 
            "carrier", 
            "tailnum", 
            "flight", 
            "origin, dest", 
            "air_time", 
            "distance", 
            "hour, minutes", 
            "time_hour")

`설명` <- c("출발년도, 월, 일", 
            "실제 출발-도착 시간(현지시각)", 
            "예정 출발-도착 시간(현지시각)", 
            "출발 및 도착 지연 시간(분, min)", 
            "항공코드 약어(두개 문자)", 
            "비행기 일련 번호", 
            "항공편 번호", 
            "최초 출발지, 목적지", 
            "비행 시간(분, min)", 
            "비행 거리(마일, mile)", 
            "예정 출발 시각(시, 분)으로 분리", 
            "POSIXct 포맷으로로 기록된  예정 항공편 날짜 및 시간")

tab4_03 <- data.frame(`변수`, 
                      `설명`, 
                       check.names = FALSE, 
                       stringsAsFactors = FALSE)
kable(tab4_03,
      align = "ll",
      escape = TRUE, 
      booktabs = T, caption = "flights 데이터셋 코드북") %>%
  kable_styling(bootstrap_options = c("striped"), 
                position = "center", 
                font_size = 11, 
                full_width = TRUE, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "5cm") %>% 
  column_spec(2, width = "5cm") %>% 
  row_spec(1:nrow(tab4_03), monospace = TRUE)



## ---- echo=FALSE-------------------------------------------------------------------------------------------
airlines %>% print


## ---- echo=FALSE-------------------------------------------------------------------------------------------
airports %>% print


## ---- echo=FALSE-------------------------------------------------------------------------------------------
`변수` <- names(airports)
`설명` <- c("FAA 공항 코드", 
          "공항 명칭", 
          "위도", 
          "경도", 
          "고도", 
          "타임존 차이(GMT로부터)", 
          "일광 절약 시간제(섬머타임): A=미국 표준 DST, U=unknown, N=no DST", 
          "IANA 타임존")
tab4_04 <- data.frame(`변수`, 
                      `설명`, 
                       check.names = FALSE, 
                       stringsAsFactors = FALSE)
kable(tab4_04,
      align = "ll",
      escape = TRUE, 
      booktabs = T, caption = "airports 데이터셋 코드북") %>%
  kable_styling(bootstrap_options = c("striped"), 
                position = "center", 
                font_size = 11, 
                full_width = TRUE, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "5cm") %>% 
  column_spec(2, width = "5cm") %>% 
  row_spec(1:nrow(tab4_04), monospace = TRUE)




## ---- echo=FALSE-------------------------------------------------------------------------------------------
planes %>% print


## ---- echo=FALSE-------------------------------------------------------------------------------------------
`변수` <- names(planes)
`설명` <- c("항공기 일련번호", 
            "제조년도", 
            "항공기 유형", 
            "제조사", 
            "모델명", 
            "엔진 개수", 
            "좌석 수", 
            "속력", 
            "엔진 유형")

tab4_05 <- data.frame(`변수`, 
                      `설명`, 
                       check.names = FALSE, 
                       stringsAsFactors = FALSE)
  
kable(tab4_05,
      align = "ll",
      escape = TRUE, 
      booktabs = T, caption = "planes 데이터셋 코드북") %>%
  kable_styling(bootstrap_options = c("striped"), 
                position = "center", 
                font_size = 11, 
                full_width = TRUE, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "5cm") %>% 
  column_spec(2, width = "5cm") %>% 
  row_spec(1:nrow(tab4_05), monospace = TRUE)  



## ---- echo=FALSE-------------------------------------------------------------------------------------------
weather %>% print


## ---- echo=FALSE-------------------------------------------------------------------------------------------
`변수` <- c("origin", 
          "year, month, day, hour", 
          "temp, dewp", 
          "humid", 
          "wind_dir, wind_speed, wind_gust", 
          "precip", 
          "pressure", 
          "visib", 
          "time_hour")
`설명` <- c("기상관측소", 
          "년도, 월, 일, 시간", 
          "기온, 이슬점 (F)", 
          "습도", 
          "바람방향(degree), 풍속 및 돌풍속도(mph)", 
          "강수량(inch)", 
          "기압(mbar)", 
          "가시거리(mile)", 
          "POSIXct 포맷 일자 및 시간")

tab4_06 <- data.frame(`변수`, 
                      `설명`, 
                       check.names = FALSE, 
                       stringsAsFactors = FALSE)
  
kable(tab4_06,
      align = "ll",
      escape = TRUE, 
      booktabs = T, caption = "weather 데이터셋 코드북") %>%
  kable_styling(bootstrap_options = c("striped"), 
                position = "center", 
                font_size = 11, 
                full_width = TRUE, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "5cm") %>% 
  column_spec(2, width = "5cm") %>% 
  row_spec(1:nrow(tab4_06), monospace = TRUE)  



## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='80%', fig.cap="NYC flight 2013 데이터 관계도(https://r4ds.had.co.nz/ 에서 발췌)"----
knitr::include_graphics('figures/dplyr-flights-db-scheme.png', dpi = NA)


## ----------------------------------------------------------------------------------------------------------
x <- tribble(
  ~key, ~val_x,
     1, "x1",
     2, "x2",
     3, "x3"
)
y <- tribble(
  ~key, ~val_y,
     1, "y1",
     2, "y2",
     4, "y3"
)

inner_join(x, y, by = "key") %>% print



## ----------------------------------------------------------------------------------------------------------
left_join(x, y, by = "key") %>% print


## ----------------------------------------------------------------------------------------------------------
right_join(x, y, by = "key") %>% print


## ----------------------------------------------------------------------------------------------------------
full_join(x, y, by = "key") %>% print


## ----------------------------------------------------------------------------------------------------------
# flights 데이터 간소화(일부 열만 추출)
flights2 <- flights %>% 
  select(year:day, hour, origin, dest, tailnum, carrier)

# flights2 와 airlines 병합
flights2 %>% 
  left_join(airlines, by = "carrier") %>% 
  print

# flights2와 airline, airports 병합
## airports 데이터 간소화
airports2 <- airports %>% 
  select(faa:name, airport_name = name) %>% 
  print

flights2 %>% 
  left_join(airlines, by = "carrier") %>% 
  left_join(airports2, by = c("origin" = "faa")) %>% 
  print


# flights2와 airline, airports, planes 병합
planes2 <- planes %>% 
  select(tailnum, model)

flights2 %>% 
  left_join(airlines, by = "carrier") %>% 
  left_join(airports2, by = c("origin" = "faa")) %>% 
  left_join(planes2, by = "tailnum") %>% 
  print

# flights2와 airline, airports2, planes2, weather2 병합
## weather 데이터 간소화
weather2 <- weather %>% 
  select(origin:temp, wind_speed)

flights2 %>% 
  left_join(airlines, by = "carrier") %>% 
  left_join(airports2, by = c("origin" = "faa")) %>% 
  left_join(planes2, by = "tailnum") %>% 
  left_join(weather2, by = c("origin", "year", 
                             "month", "day", "hour")) %>% 
  glimpse



## ---- echo=FALSE-------------------------------------------------------------------------------------------
`dplyr::*_join()` <- c("inner_join(x, y)", 
                       "left_join(x, y)", 
                       "right_join(x, y)",
                       "full_join(x, y)")

`base::merge()` <- c("merge(x, y)", 
                    "merge(x, y, all.x = TRUE)", 
                    "merge(x, y, all.y = TRUE)", 
                    "merge(x, y, all.x = TRUE, all.y = TRUE)")

tab4_07 <- data.frame(`dplyr::*_join()`, 
                      `base::merge()`, 
                       check.names = FALSE, 
                       stringsAsFactors = FALSE)

kable(tab4_07,
      align = "ll",
      escape = TRUE, 
      booktabs = T, caption = "dplyr join 함수와 merge() 함수 비교") %>%
  kable_styling(bootstrap_options = c("striped"), 
                position = "center", 
                font_size = 11, 
                full_width = TRUE, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "5cm") %>% 
  column_spec(2, width = "5cm") %>% 
  row_spec(1:nrow(tab4_07), monospace = TRUE)



## **연습 데이터**:  Gapminder 데이터 활용. 각 대륙에 속한 국가의 인구, 경제, 보건, 교육, 환경, 노동에 대한 년도 별 국가 통계를 제공함. [Gapminder](https://gapminder.org)는 스웨덴의 비영리 통계 분석 서비스를 제공하는 웹사이트로, UN이 제공하는 데이터를 기반으로 인구 예측, 부의 이동 등에 관한 연구 논문 및 통계정보, 데이터를 공유함 [@gapminder]. R 패키지 중 `gapminder` [@gapminder-package]는 1950 ~ 2007 년 까지 5년 단위의 국가별 인구(population), 기대수명(year), 일인당 국민 총소득(gross domestic product per captia, 달러)에 대한 데이터를 제공 하지만, 본 강의에서는 현재 Gapminder 사이트에서 직접 다운로드 받은 가장 최근 데이터를 가지고 dplyr 패키지의 기본 동사를 학습함과 동시에 최종적으로 gapminder 패키지에서 제공하는 데이터와 동일한 형태의 구조를 갖는 데이터를 생성하는 것이 목직임. 해당 데이터는 [github 계정](https://github.com/zorba78/cnu-r-programming-lecture-note/blob/master/dataset/gapminder/gapminder-exercise.xlsx)에서 다운로드가 가능함.

## `gapminder-exercise.xlsx`는 총 4개의 시트로 구성되어 있으며, 각 시트에 대한 설명은 아래와 같음.


## ---- echo = FALSE-----------------------------------------------------------------------------------------
`시트 이름` <- c("region", "country_pop", "gdpcap", "lifeexp")
`설명` <- c("국가별 지역 정보 포함", 
            "국가별 1800 ~ 2100년 까지 추계 인구수(명)", 
            "국가별 1800 ~ 2100년 까지 국민 총소득(달러)", 
            "국가별 1800 ~ 2100년 까지 기대수명(세)")
tab4_08 <- data.frame(`시트 이름`, 
                      `설명`, 
                       check.names = FALSE, 
                       stringsAsFactors = FALSE)
kable(tab4_08,
      align = "ll",
      escape = TRUE, 
      booktabs = T, caption = "gapminder-exercise.xlsx 설명") %>%
  kable_styling(bootstrap_options = c("striped"), 
                position = "center", 
                font_size = 11, 
                full_width = TRUE, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "3cm") %>% 
  column_spec(2, width = "7cm") %>% 
  row_spec(1:4, monospace = TRUE)


## ---- eval=FALSE-------------------------------------------------------------------------------------------
## install.packages("gapminder")


## **Gapminder 데이터 핸들링 실습**


## ----------------------------------------------------------------------------------------------------------
require(readxl)
require(gapminder)
path <- "dataset/gapminder/gapminder-exercise.xlsx"
# base R 문법 적용
# sheet_name <- excel_sheets(path)
# gapmL <- lapply(sheet_name, function(x) read_excel(path = path, sheet = x))
# names(gapmL) <- sheet_name

# pipe 연산자 이용
path %>% 
  excel_sheets %>% 
  set_names %>% 
  map(read_excel, path = path) -> gapmL

# 개별 객체에 데이터 저장
command <- paste(names(gapmL), "<-", 
                 paste0("gapmL$", names(gapmL)))
for (i in 1:length(command)) eval(parse(text = command[i]))

# check
ls()
region %>% print
country_pop %>% print
gdpcap %>% print
lifeexp %>% print



## ----------------------------------------------------------------------------------------------------------
gap_unfilter <- country_pop %>% 
  left_join(gdpcap, by = c("iso" = "iso_code", 
                           "country", 
                           "year")) %>% 
  left_join(lifeexp, by = c("iso" = "iso_code", 
                            "country", 
                            "year"))
gap_unfilter %>% print


## ----------------------------------------------------------------------------------------------------------
gap_filter <- gap_unfilter %>% 
  filter(population >= 60000, 
         between(year, 1950, 2020))
gap_filter %>% print


## ----------------------------------------------------------------------------------------------------------
gap_filter <- gap_filter %>% 
  mutate(iso = toupper(iso), 
         gdp_cap = gdp_total/population) %>% 
  select(-gdp_total) 
gap_filter %>% print  


## ----------------------------------------------------------------------------------------------------------
gap_filter <- gap_filter %>% 
  left_join(region %>% select(-country), 
            by = c("iso"))
gap_filter %>% print


## ----------------------------------------------------------------------------------------------------------
gap_filter <- gap_filter %>% 
  select(iso:country, region, everything())


## ----------------------------------------------------------------------------------------------------------
gap_filter <- gap_filter %>% 
  mutate_if(~ is.character(.), ~factor(.)) %>% 
  mutate(population = as.integer(population))


## ----------------------------------------------------------------------------------------------------------
gap_filter <- country_pop %>% 
  left_join(gdpcap, by = c("iso" = "iso_code", 
                           "country", 
                           "year")) %>% 
  left_join(lifeexp, by = c("iso" = "iso_code", 
                            "country", 
                            "year")) %>% 
  filter(population >= 60000, 
         between(year, 1950, 2020)) %>% 
  mutate(iso = toupper(iso), 
         gdp_cap = gdp_total/population) %>% 
  select(-gdp_total) %>% 
  left_join(region %>% select(-country), 
            by = c("iso")) %>% 
  select(iso:country, region, everything()) %>% 
  mutate_if(~ is.character(.), ~factor(.)) %>% 
  mutate(population = as.integer(population)) 

# write_csv(gap_filter, "dataset/gapminder/gapminder_filter.csv")



## ----------------------------------------------------------------------------------------------------------
gap_filter %>% 
  filter(year == 2020) %>% 
  group_by(region) %>% 
  summarise(Population = sum(population), 
            `GDP/Captia` = mean(gdp_cap), 
            `Life expect` = mean(life_expectancy, na.rm = TRUE)) %>% 
  arrange(desc(Population))


## 지금까지 배운 dplyr 패키지와 관련 명령어를 포함한 주요 동사 및 함수에 대한 개괄적 사용 방법은 RStudio 에서 제공하는 [cheat sheet](https://rstudio.com/resources/cheatsheets/)을 통해 개념을 다질 수 있음.


## **Tidy data**에 대한 개념을 알아보고, tidyr 패키지에서 제공하는 데이터 변환 함수 사용 방법에 대해 익힌다.


## 시작 전 tidyverse 패키지를 R 작업공간으로 불러오기!!


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='100%', fig.cap="데이터의 구성 요소"-------
knitr::include_graphics('figures/tidydata-structure-01.png', dpi = NA)


## 
## **Tidy Data Principles**

## 
##   - **각각의 변수는 하나의 열로 구성된다(Each variable forms a column)**.

##   - **각각의 관측은 하나의 행으로 구성된다(Each observation forms a row)**.

##   - **각각의 값은 반드시 자체적인 하나의 셀을 가져야 한다(Each value must have its own cell)**.

##   - 각각의 관찰 단위는 테이블을 구성한다(Each type of observational unit forms a table).

## 

## ---- echo=FALSE-------------------------------------------------------------------------------------------
set.seed(1981)
preg <- matrix(c(NA, sample(20, 5)), ncol = 2, byrow = T)
colnames(preg) <- paste0("treatment", c("a", "b"))
rownames(preg) <- c("James McGill", "Kimberly Wexler", "Lalo Salamanca")

kable(preg,
      align = "lcc",
      escape = TRUE,
      booktabs = T, caption = "Tidy data 예시 데이터 1") %>%
  kable_styling(bootstrap_options = c("striped"),
                position = "center",
                font_size = 11,
                full_width = TRUE,
                latex_options = c("striped", "HOLD_position")) %>%
  column_spec(1, width = "4cm") %>%
  column_spec(2, width = "2cm") %>%
  column_spec(3, width = "2cm")



## ---- echo=FALSE-------------------------------------------------------------------------------------------
kable(t(preg),
      align = "lccc",
      escape = TRUE,
      booktabs = T, caption = "Tidy data: 예시 데이터 1과 동일 내용, 다른 레이아웃") %>%
  kable_styling(bootstrap_options = c("striped"),
                position = "center",
                font_size = 11,
                full_width = TRUE,
                latex_options = c("striped", "HOLD_position")) %>%
  column_spec(1, width = "2cm") %>%
  column_spec(2, width = "3cm") %>%
  column_spec(3, width = "3cm") %>% 
  column_spec(4, width = "3cm")



## ---- echo=FALSE-------------------------------------------------------------------------------------------
preg %>%
  data.frame %>%
  rownames_to_column(var = "name") %>%
  as_tibble %>%
  pivot_longer(contains("treatment"),
               names_to = "treatment",
               values_to = "result") %>%
  mutate(treatment = str_remove(treatment,
                                "treatment")) %>%
  arrange(treatment) -> preg

kable(preg,
      align = "lcc",
      escape = TRUE,
      booktabs = TRUE,
      caption = "Tidy data: 예시 데이터 1 구조 변환") %>%
  kable_styling(bootstrap_options = c("striped"),
                position = "center",
                font_size = 11,
                full_width = TRUE,
                latex_options = c("striped", "HOLD_position")) %>%
  column_spec(1, width = "4cm") %>%
  column_spec(2, width = "2cm") %>%
  column_spec(3, width = "2cm")



## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='70%'--------------------------------------
knitr::include_graphics('figures/tidyr-pre.png', dpi = NA)


## ---- echo=FALSE-------------------------------------------------------------------------------------------
# wide format 예시
mtcars %>% head %>% print

# long format 예시
mtcars %>%
  rownames_to_column(var = "model") %>%
  gather(variable, value, mpg:carb) %>%
  arrange(model) %>%
  as_tibble %>%
  print


## dplyr 패키지와 마찬가지로 tidyr 패키지에서 제공하는 함수는 데이터 프레임 또는 티블에서만 작동함


## ---- eval=FALSE-------------------------------------------------------------------------------------------
## # pivot_longer()의 기본 사용 형태
## pivot_longer(
##   data, # 데이터 프레임
##   cols, # long format으로 변경을 위해 선택한 열 이름
##         # dplyr select() 함수에서 사용한 변수선정 방법 준용
##   names_to, # 선택한 열 이름을 값으로 갖는 변수명칭 지정
##   names_prefix, #변수명에 처음에 붙는 접두어 패턴 제거(예시 참조, optional)
##   names_pattern, # 정규표현식의 그룹지정(())에 해당하는 패턴을 값으로 사용
##                  # 예시 참조(optional)
##   values_to # 선택한 열에 포함되어 있는 셀 값을 저장할 변수 이름 지정
## )
## 
## # gather() 기본 사용 형태
## gather(
##   data, # 데이터 프레임
##   key, # 선택한 열 이름을 값으로 갖는 변수명칭 지정
##   value, # 선택한 열에 포함되어 있는 셀 값을 저장할 변수 이름 지정
##   ... # long format으로 변경할 열 선택
## )
## 


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'--------------------------------------
knitr::include_graphics('figures/tidyr-pivot_longer.png', dpi = NA)


## ---- echo=FALSE-------------------------------------------------------------------------------------------
gap_filter %>%
  filter(grepl("KOR|USA|DEU", iso),
         between(year, 2001, 2020)) %>%
  select(iso:year, gdp_cap) %>%
  pivot_wider(names_from = year,
              values_from = gdp_cap) %>%
  select(-region, -iso) #%>%
  # write_csv("dataset/tidyr-wide-ex01.csv", col_names = TRUE)



## ---- message=FALSE----------------------------------------------------------------------------------------
# 데이터 불러오기: read_csv() 함수 사용
wide_01 <- read_csv("dataset/tidyr-wide-ex01.csv")
wide_01



## ----------------------------------------------------------------------------------------------------------
# wide_01 데이터 tidying
## pivot_wider() 사용
tidy_ex_01 <- wide_01 %>%
  pivot_longer(`2001`:`2020`,
               names_to = "year",
               values_to = "gdp_cap")
tidy_ex_01 %>% print

## gather() 사용
tidy_ex_01 <- wide_01 %>%
  gather(year, gdp_cap, `2001`:`2020`)
tidy_ex_01 %>% print



## ----------------------------------------------------------------------------------------------------------
billboard %>% print
names(billboard)

# pivot_wider()을 이용해 데이터 정돈
billb_tidy <- billboard %>%
  pivot_longer(starts_with("wk"),
               names_to = "week",
               values_to = "rank")
billb_tidy %>% print

# pivot_longer() 함수의 인수 중 value_drop_na 값 조정을 통해
# 데이터 값에 포함된 결측 제거 가능
billb_tidy <- billboard %>%
  pivot_longer(starts_with("wk"),
               names_to = "week",
               values_to = "rank",
               values_drop_na = TRUE)
billb_tidy %>% print

# pivot_longer() 함수의 인수 중 names_prefix 인수 값 설정을 통해
# 변수명에 처음에 붙는 접두어(예: V, wk 등) 제거 가능
billb_tidy <- billboard %>%
  pivot_longer(starts_with("wk"),
               names_to = "week",
               values_to = "rank",
               names_prefix = "wk",
               values_drop_na = TRUE)
billb_tidy %>% print

# pivot_longer() 함수의 인수 중 names_ptypes 또는 values_ptypes 인수 값 설정을 통해
# 새로 생성한 변수(name과 value 에 해당하는)의 데이터 타입 변경 가능
billb_tidy <- billboard %>%
  pivot_longer(starts_with("wk"),
               names_to = "week",
               values_to = "rank",
               names_prefix = "wk",
               names_ptypes = list(week = integer()),
               values_drop_na = TRUE)
billb_tidy %>% print

# 연습: wide_01 데이터에서 year을 정수형으로 변환(mutate 함수 사용하지 않고)



## ---- echo=FALSE-------------------------------------------------------------------------------------------
who %>% print

`변수명` <- c("country", "iso2, iso3", "year", "new_sp_m014 - newrel_f65")
`변수설명` <- c("국가명", "2자리 또는 3자리 국가코드", "년도",
            "변수 접두사: new_ 또는 new;
            진단명: sp = positive pulmonary smear,
            sn = negative pulmonary smear,
            ep = extrapulmonary, rel = relapse;
            성별: m = male, f = female;
            연령대: 014 = 0-14 yrs,
            1524 = 14-24 yrs,
            2534 = 25-34 yrs,
            3544 = 35-44 yrs,
            4554 = 45-54 yrs,
            5564 = 55-64 yrs,
            65 = 65 yrs or older")

tab4_09 <- data.frame(`변수명`,
                      `변수설명`,
                       check.names = FALSE,
                       stringsAsFactors = FALSE)
kable(tab4_09,
      align = "ll",
      escape = TRUE,
      booktabs = T, caption = "tidyr 패키지 내장 데이터 who 코드 설명") %>%
  kable_styling(bootstrap_options = c("striped"),
                position = "center",
                font_size = 11,
                full_width = TRUE,
                latex_options = c("striped", "HOLD_position")) %>%
  column_spec(1, width = "3cm") %>%
  column_spec(2, width = "6cm") %>%
  row_spec(1:length(`변수명`), monospace = TRUE)




## ----------------------------------------------------------------------------------------------------------
# pivot_longer()를 이용해 who 데이터셋 데이터 정돈
who_tidy <- who %>%
  pivot_longer(
    new_sp_m014:newrel_f65,
    names_to = c("diagnosis", "sex", "age_group"),
    names_prefix = "^new_?",
    names_pattern = "([a-z]+)_(m|f)([0-9]+)",
    names_ptypes = list(
      diagnosis = factor(levels = c("rel", "sn", "sp", "ep")),
      sex = factor(levels = c("f", "m")),
      age_group = factor(levels = c("014", "1524", "2534", "3544",
                                    "4554", "5564", "65"),
                         ordered = TRUE)
    ),
    values_to = "count",
    values_drop_na = TRUE
  )

who_tidy %>% print



## ---- eval=FALSE-------------------------------------------------------------------------------------------
## # pivot_wider()의 기본 사용 형태
## pivot_wider(
##   data, # 데이터 프레임
##   names_from, # 출력 시 변수명으로 사용할 값을 갖고 있는 열 이름
##   values_from, # 위에서 선택한 변수의 각 셀에 대응하는 측정 값을 포함하는 열 이름
##   values_fill #
## )
## 
## # spread() 기본 사용 형태
## spread(
##   data, # 데이터 프레임
##   key, # 출력 시 변수명으로 사용할 값을 갖고 있는 열 이름
##   value # 위에서 선택한 변수의 각 셀에 대응하는 측정 값을 포함하는 열 이름
## )
## 


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'--------------------------------------
knitr::include_graphics('figures/tidyr-pivot_wider.png', dpi = NA)


## ----------------------------------------------------------------------------------------------------------
# 위 예시에서 생성한 tidy_ex_01 데이터 예시
## long format으로 변환한 데이터를 다시 wide format으로 변경
## pivot_wider() 함수

wide_ex_01 <- tidy_ex_01 %>%
  pivot_wider(
    names_from = year,
    values_from = gdp_cap
  )
wide_ex_01 %>% print

## 데이터 동일성 확인
all.equal(wide_01, wide_ex_01)

## spread() 함수
wide_ex_01 <- tidy_ex_01 %>%
  spread(year, gdp_cap)

all.equal(wide_01, wide_ex_01)


## ----------------------------------------------------------------------------------------------------------
# table2 데이터셋 check
table2 %>% print

# type 변수의 값은 사실 관측 단위의 변수임
# type 값에 대응하는 값을 가진 변수는 count 임
## 데이터 정돈(pivot_wider() 사용)

table2_tidy <- table2 %>%
  pivot_wider(
    names_from = type,
    values_from = count
  )
table2_tidy %>% print



## ----------------------------------------------------------------------------------------------------------
# 1) mtcars 데이터셋: 행 이름을 변수로 변환 후 long format 변환
## rownames_to_column() 함수 사용
mtcars2 <- mtcars %>%
  rownames_to_column(var = "model") %>%
  pivot_longer(
    -c("model", "vs", "am"),
    names_to = "variable",
    values_to = "value"
  )

# 2) 엔진 유형 별 variable의 평균과 표준편차 계산
# "사람"이 읽기 편한 형태로 테이블 변경
mtcars2 %>%
  mutate(vs = factor(vs,
                     labels = c("V-shaped",
                                "Straight"))) %>%
  group_by(vs, variable) %>%
  summarise(Mean = mean(value),
            SD = sd(value)) %>%
  pivot_longer(
    Mean:SD,
    names_to = "stat",
    values_to = "value"
  ) %>%
  pivot_wider(
    names_from = variable,
    values_from = value
  )

# 조금 더 응용...
## 위 Mean ± SD 형태로 위와 유사한 구조의 테이블 생성
### tip: 한글로 "ㄷ(e) + 한자" 통해 ± 입력 가능

mtcars2 %>%
  mutate(vs = factor(vs,
                     labels = c("V-shaped",
                                "Straight"))) %>%
  group_by(vs, variable) %>%
  summarise(Mean = mean(value),
            SD = sd(value)) %>%
  mutate(res = sprintf("%.1f ± %.1f",
                       Mean, SD)) %>%
  select(-(Mean:SD)) %>%
  pivot_wider(
    names_from = variable,
    values_from = res
  )




## ---- eval=FALSE-------------------------------------------------------------------------------------------
## # separate() 함수 기본 사용 형태
## seprate(
##   data, # 데이터 프레임
##   col, # 분리 대상이 되는 열 이름
##   into, # 분리 후 새로 생성한 열들에 대한 이름(문자형 벡터) 지정
##   sep = "[^[:alnum:]]+", # 구분자: 기본적으로 정규표현식 사용
##   convert # 분리한 열의 데이터 타입 변환 여부
## )


## ----------------------------------------------------------------------------------------------------------
# table3 데이터 체크
table3 %>% print

# rate 변수를 case와 population으로 분리
table3 %>%
  separate(rate,
           into = c("case", "population"),
           sep = "/") %>%
  print


table3 %>%
  separate(rate,
           into = c("case", "population"),
           convert = TRUE) -> table3_sep

## sep 인수값이 수치형 백터인 경우 분리할 위치로 인식
## 양수: 문자열 맨 왼쪽에서 1부터 시작
## 음수: 문자열 맨 오른쪽에서 -1부터 시작
## sep의 길이(length)는 into 인수의 길이보다 작아야 함

# year 변수를 century와 year로 분할
table3 %>%
  separate(year,
           into = c("century", "year"),
           sep = -2) %>%
  print




## ---- eval=FALSE-------------------------------------------------------------------------------------------
## # unite() 기본 사용 형태
## unite(
##   data, # 데이터프레임
##   ..., # 선택한 열 이름
##   sep, # 연결 구분자
## )


## ----------------------------------------------------------------------------------------------------------
# table5 체크
table5 %>% print

# century와 year을 결합한 new 변수 생성
table5 %>%
  unite(new, century, year) %>%
  print

# _없이 결합 후 new를 정수형으로 변환
table5 %>%
  unite(new, century, year, sep = "") %>%
  mutate(new = as.integer(new)) %>%
  print

# table5 데이터 정돈(separate(), unite() 동시 사용)
table5 %>%
  unite(new, century, year, sep = "") %>%
  mutate(new = as.integer(new)) %>%
  separate(rate, c("case", "population"),
           convert = TRUE) %>%
  print



## ----------------------------------------------------------------------------------------------------------
# 기어 종류(`am`) 별 `mpg`, `cyl`, `disp`, `hp`, `drat`, `wt`, `qsec`의
# 평균과 표준편차 계산
mtcar_summ1 <- mtcars %>%
  mutate(am = factor(am,
                     labels = c("automatic", "manual"))) %>%
  group_by(am) %>%
  summarise_at(vars(mpg:qsec),
               list(mean = ~ mean(.),
                    sd = ~ sd(.)))
mtcar_summ1 %>% print

# am을 제외한 모든 변수에 대해 long format으로 데이터 변환
mtcar_summ2 <- mtcar_summ1 %>%
  pivot_longer(
    -am,
    names_to = "stat",
    values_to = "value"
  )
mtcar_summ2 %>% print

# stat 변수를 "variable", "statistic"으로 분리 후
# variable과 value를 wide format으로 데이터 변환
mtcar_summ3 <- mtcar_summ2 %>%
  separate(stat, c("variable", "statistic")) %>%
  pivot_wider(
    names_from = variable,
    values_from = value
  )
mtcar_summ3 %>% print



## ----  fig.show='hold'-------------------------------------------------------------------------------------
# ggplot trailer
tidy_ex_01 <- wide_01 %>%
  pivot_longer(`2001`:`2020`,
               names_to = "year",
               values_to = "gdp_cap",
               names_ptypes = list(
                 year = integer()
               ))
tidy_ex_01 %>%
  ggplot +
  aes(x = year, y = gdp_cap,
      color = country,
      group = country) +
  geom_point(size = 3) +
  geom_line(size = 1) +
  labs(x = "Year",
       y = "Total GDP/captia") +
  theme_classic()

tidy_ex_01 %>%
  ggplot +
  aes(x = year, y = gdp_cap,
      group = country) +
  geom_point(size = 3) +
  geom_line(size = 1) +
  labs(x = "Year",
       y = "Total GDP/captia") +
  facet_grid(~ country) +
  theme_minimal()




## 
## **과제 제출 방식**

## 
##    - R Markdown 문서(`Rmd`) 파일과 해당 문서를 컴파일 후 생성된 `html` 파일 모두 제출할 것

##    - 모든 문제에 대해 작성한 R 코드 및 결과가 `html` 문서에 포함되어야 함.

##    - 해당 과제에 대한 R Markdown 문서 템플릿은 https://github.com/zorba78/cnu-r-programming-lecture-note/blob/master/assignment/homework4_template.Rmd 에서 다운로드 또는 `Ctrl + C, Ctrl + V` 가능

##    - 최종 파일명은 `학번-성명.Rmd`, `학번-성명.html` 로 저장

##    - 압축파일은 `*.zip` 형태로 생성할 것

## 
## **주의 사항**

## 
##   - 과제에 필요한 텍스트 데이터 파일은 가급적 제출 파일(rmd 및 html 파일)이 생성되는 폴더 안에 폴더를 만든 후 텍스트 파일을 저장할 것. 예를 들어 `homework4.Rmd` 파일이 `C:/my-project` 에서 생성된다면 `C:/my-project/exercise` 폴더 안에 텍스트 파일 저장

##   - 만약 `Rmd` 파일이 작업 디렉토리 내 별도의 폴더 (예: `C:/my-project/rmd`)에 저장되어 있고 텍스트 데이터 파일이 `C:/my-project/exercise`에 존재 한다면, 다음과 같은 chunk 가 Rmd 파일 맨 처음에 선행되어야 함.

## 

## ----1-b-ans-----------------------------------------------------------------------------------------------
# path <- "텍스트 파일이 저장된 폴더명"
# filename <- dir(path)


## ----1-c-ans-----------------------------------------------------------------------------------------------



## ----1-d-ans-----------------------------------------------------------------------------------------------



## ----1-e-ans-----------------------------------------------------------------------------------------------



## ----1-f-ans-----------------------------------------------------------------------------------------------



## ----1-g-ans-----------------------------------------------------------------------------------------------



## ----1-h-ans-----------------------------------------------------------------------------------------------



## ----1-i-ans-----------------------------------------------------------------------------------------------



## ----1-j-ans-----------------------------------------------------------------------------------------------




## ----1-k-ans-----------------------------------------------------------------------------------------------



## ----1-l-ans-----------------------------------------------------------------------------------------------



## ----1-n-ans-----------------------------------------------------------------------------------------------



## ----1-o-ans-----------------------------------------------------------------------------------------------



## ----1-p-ans-----------------------------------------------------------------------------------------------
# 1.
# 2.
# 3.

