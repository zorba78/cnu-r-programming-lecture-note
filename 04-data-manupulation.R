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
covid19 <- read_xlsx("dataset/owid-covid-data.xlsx")
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


