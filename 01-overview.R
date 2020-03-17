## ----chunk-setup, echo=FALSE, message=FALSE-------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(size="footnotesize",
                      comment = NA,
                      highlight = TRUE)
def.chunk.hook  <- knitr::knit_hooks$get("chunk")
knitr::knit_hooks$set(chunk = function(x, options) {
  x <- def.chunk.hook(x, options)
  ifelse(options$size != "normalsize", paste0("\\", options$size,"\n\n", x, "\n\n \\normalsize"), x)
})
# options(width = 85)


## **유용한 웹 사이트**: R과 관련한 거의 모든 문제는 Googling (구글을 이용한 검색)을 통해 해결 가능(검색주제 + "in R" or "in R software")하고 많은 해답들이 아래 열거한 웹 페이지에 게시되어 있음.

## 
## - R 프로그래밍에 대한 Q&A: [Stack Overflow](https://stackoverflow.com)

## - R 관련 웹 문서 모음: [Rpubs](https://rpubs.com/)

## - R package에 대한 raw source code 제공: [Github](https://github.com)

## - R을 이용한 통계 분석: [Statistical tools for high-throughput data analysis (STHDA)](http://www.sthda.com/english/)

## 

## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
options(knitr.graphics.auto_pdf = TRUE)
knitr::include_graphics('figures/Rorg-main-add.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/CRAN-korea-01.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/Rinstall-01.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/Rinstall-02.png', dpi = NA)


## 다음 하위폴더에 대한 간략 설멍

## 
## - **`base`**: R 실행 프로그램

## - **`contrib`**: R package의 바이너리 파일

## - **`Rtools`**: R package 개발 및 배포를 위한 프로그램

## 

## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/Rinstall-03.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/R-install-F01.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/R-install-F02.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/R-install-F03.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/R-install-F04.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/R-install-F05.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/R-install-F06.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/R-install-F07.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/R-install-F08.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/R-install-F09.png', dpi = NA)


## ----r-console, fig.align='center', echo=FALSE, fig.show='hold', out.width='100%', fig.cap="Windows에서 R 실행화면(콘솔 창, SDI 모드)", ref.label='r-console'----
knitr::include_graphics('figures/Rgui.png', dpi = NA)


## **실습**: 설치된 R을 실행 후 보이는 R 콘솔(consle) 창에서 명령어를 실행하고 결과 확인


## ----check-00, echo=TRUE, comment=NA--------------------------------------------------------------------------------------------------------------
# R의 설치 버전 및 현재 설정된 locale(언어, 시간대) 및 로딩된 R package 정보 출력
sessionInfo() 


## ----check-01, echo=TRUE, comment=NA--------------------------------------------------------------------------------------------------------------
#문자열 출력
print("Hello R") #문자열


## ----check-02, echo=TRUE, comment=NA--------------------------------------------------------------------------------------------------------------
# 수치형 값(scalar)을 변수에 할당(assign)
# 여러 명령어를 한줄에 입력할 때에는 세미콜론(;)으로 구분
a = 9; b = 7
a
b


## ----check-03, echo=TRUE, comment=NA--------------------------------------------------------------------------------------------------------------
a+b; a-b; a*b; a/b


## ----check-04, fig.align='center', fig.show='hold', echo=TRUE, fig.cap="정규분포 100개의 히스토그램"----------------------------------------------
# 난수 생성 시 값은 매번 달라지기 때문에 seed를 주어 일정값이 생성되도록 고정
# "="과 "<-"는 모두 동일한 기능을 가진 할당 연산자임
#평균이 0 이고 분산이 1인 정규분포에서 난수 100개 생성
set.seed(12345) # random seed 지정
x <- rnorm(100) # 난수 생성
hist(x) # 히스토그램


## R 명령어 또는 전체 프로그램 소스 실행 시 매우 빈번히 오류가 나타나는데, 이를 해결할 수 있는 가장 좋은 방법은 앞에서 언급한 Google을 이용한 검색 또는 R 설치 시 자체적으로 내장되어 있는 도움말을 참고하는 것이 가장 효율적임.


## ----tab-help, echo=FALSE, message=FALSE----------------------------------------------------------------------------------------------------------
# require(tidyverse)
require(rmarkdown)
require(knitr)
require(kableExtra)

`도움말 보기 명령어` <- c("`help` 또는 `?`", 
                  "`help.search` 또는 `??`", 
                  "`example`", 
                  "`vignette`")
`설명` <- c("도움말 시스템 호출", 
            "주어진 문자열을 포함한 문서 검색",
            "topic의 도움말 페이지에 있는 examples section 실행", 
            "topic의 pdf 또는 html 레퍼런스 메뉴얼 불러오기")
`사용법` <- c("`help(함수명)`", 
           "`help.search(pattern)`", 
           "`example(함수명)`", 
           "`vignette(패키지명 또는 패턴)`")
tab <- data.frame(`도움말 보기 명령어`, 
                  `설명`, 
                  `사용법`, 
                  check.names = F)
options(kableExtra.html.bsTable = T)
knitr::opts_knit$set(kable.force.latex = FALSE)
kable(tab,
      align = "lll",
      escape = FALSE, 
      booktabs = T, caption = "R help 관련 명령어 리스트") %>%
  kable_styling(bootstrap_options = c("condensed", "striped"),
                position = "center", 
                font_size = 10, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(2, width = "5cm")


## **Vignette** 의 활용

## 
## - `vignette()`에서 제공하는 문서는 데이터를 기반으로 사용하고자 하는 패키지의 실제 활용 예시를 작성한 문서이기 때문에 초보자들이 R 패키지 활용에 대한 접근성을 높혀줌.

## - `browseVignettes()` 명령어를 통해 vignette을 제공하는 R 패키지 및 해당 vignette 문서 확인 가능

## 

## **실습**: R 설치 후 Rgui 에서 제공하는 편집기(R editor)에 명령어를 입력하고 실행

## 

## ----r-console-edit, fig.align='center', echo=FALSE, fig.show='hold', out.width='100%'------------------------------------------------------------
knitr::include_graphics('figures/r-console-edit.png', dpi = NA)


## ----check-edit, echo=TRUE, eval=FALSE, comment=NA, tidy=TRUE-------------------------------------------------------------------------------------
# R에 내장된 cars 데이터셋 불러오기
# cars dataset에 포함된 변수들의 기초통계량 출력
# 2차원 산점도 
data(cars)
help(cars) # cars 데이터셋에 대한 설명 help 창에 출력
head(cars) # cars 데이터셋 처음 6개 행 데이터 출력
summary(cars) # cars 데이터셋 요약
plot(cars) # 변수가 2개인 경우 산점도 출력


## ----check-edit-out, echo=FALSE, comment=NA, fig.cap="cars 데이터셋의 speed와 dist 간 2차원 산점도: speed는 자동차 속도(mph)이고 dist는 해당 속도에서 브레이크를 밟았을 때 멈출 때 까지 걸린 거리(ft)를 나타냄."----
# R에 내장된 cars 데이터셋 불러오기
# cars dataset에 포함된 변수들의 기초통계량 출력
# 2차원 산점도 
data(cars)
# help(cars)
head(cars)
summary(cars) 
plot(cars) 


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='80%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/rstudio-homepage.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='70%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/rstudio-download.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='60%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/r-studio-download-02.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.widtht='60%'----------------------------------------------------------------------------
knitr::include_graphics('figures/Rstudio-installer.png', dpi = NA)


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='80%'-----------------------------------------------------------------------------
knitr::include_graphics('figures/Rstudio-init.png', dpi = NA)


## ----rstudio-windows, fig.align='center', echo=FALSE, fig.show='hold', out.width='90%', fig.cap="RStudio 화면구성: 우하단 그림은 http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html 에서 발췌", ref.label='rstudio-windows'----
knitr::include_graphics('figures/Rstudio-cap1.png', dpi = NA)



## ----rstudio-console, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%', fig.cap="RStudio 콘솔창에서 명령어 실행 후 출력결과 화면", ref.label='rstudio-console'----
knitr::include_graphics('figures/rstudio-console.png', dpi = NA)


## ----rstudio-new-script, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%', fig.cap="RStudio 스크립트 새로 열기", ref.label='rstudio-new-script'----
knitr::include_graphics('figures/rstudio-open-new-script.png', dpi = NA)


## RStudio는 코딩 및 소스 작성의 효율성을 위해 여러 가지 단축 키를 제공하고 있음. 단축키는 아래 그림과 같이 pull down 메뉴 `[Tools]` 또는 `[Help]`에서 `[Keyboard shortcut help]` 또는 `[Alt] + [Shift] + [K]` 단축키를 통해 확인할 수 있음. 또는 Rstudio cheatsheet에서 단축키에 대한 정보를 제공하는데 pull down 메뉴 `[Help]` $\rightarrow$ `[Cheatsheets]` $\rightarrow$ `[RStudio IDE Cheat Sheet]`을 선택하면 각 아이콘 및 메뉴 기능에 대한 개괄적 설명 확인 가능함.

## 

## ----rstudio-env, fig.align='center', echo=FALSE, fig.show='hold', out.width='90%', fig.cap="RStudio Environment 창 객체 상세 정보 및 스프레드 시트 출력 결과", ref.label='rstudio-env'----
knitr::include_graphics('figures/rstudio-environment.png', dpi = NA)



## ----rstudio-history, fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'------------------------------------------------------------
knitr::include_graphics('figures/Rstudio-historywin.png', dpi = NA)



## ----rstudio-file, fig.align='center', echo=FALSE, fig.show='hold', out.width='80%'---------------------------------------------------------------
knitr::include_graphics('figures/Rstudio-file.png', dpi = NA)



## ----rstudio-plotwin, fig.align='center', echo=FALSE, fig.show='hold', out.width='80%'------------------------------------------------------------
knitr::include_graphics('figures/RStudio-plotwin.png', dpi = NA)



## ----rstudio-packagewin, fig.align='center', echo=FALSE, fig.show='hold', out.width='80%'---------------------------------------------------------
knitr::include_graphics('figures/RStudio-packagewin.png', dpi = NA)



## ----help, eval=FALSE-----------------------------------------------------------------------------------------------------------------------------
## help(lm)


## ----rstudio-helpwin, fig.align='center', echo=FALSE, fig.show='hold', out.width='80%'------------------------------------------------------------
knitr::include_graphics('figures/RStudio-helpwin.png', dpi = NA)



## ----rstudio-glob-menu, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'----------------------------------------------------------
knitr::include_graphics('figures/rstudio-glob-menu.png', dpi = NA)


## ----rstudio-glob-option, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%', ref.label='rstudio-glob-option', fig.cap=fig_cap------
fig_cap <- "R General option 팝업 창"
knitr::include_graphics('figures/rstudio-glob-option.png', dpi = NA)


## ----rstudio-wd-set, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'-------------------------------------------------------------
knitr::include_graphics('figures/rstudio-wd-setting.JPG', dpi = NA)


## -------------------------------------------------------------------------------------------------------------------------------------------------
getwd() # 작업폴더 확인


## -------------------------------------------------------------------------------------------------------------------------------------------------
setwd("..") # 차상위 폴더로 이동 
getwd()
setwd("../..") # 차차상위 폴더로 이동
getwd()
setwd("D:/Current-Workspace/Lecture/misc/") # 절대 폴더 명 입력
setwd("..")
# dir() # 폴더 내 파일 명 출력
getwd()
setwd("misc") # Current-Workspace 하위폴더인 misc 으로 이동
getwd()
setwd("D:/Current-Workspace/Lecture/cnu-r-programming-lecture-note/")
getwd()


## R에서 디렉토리 또는 폴더 구분자는 `/` 임. Windows에서 사용하는 구분자는 `\`인데, R에서 `\`는 특수문자로 간주하기 때문에 Windows 의 폴더명을 그대로 사용 시 에러 메세지를 출력함. 이를 해결하기 위해 Windows 경로명을 그대로 복사한 경우 경로 구분자 `\` 대신 `\\`로 변경

## 
## **실습**:  `C:\r-project`를 컴퓨터에 생성 후 해당 폴더를 default 작업폴더로 설정


## ----rstudio-code-option, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'--------------------------------------------------------
knitr::include_graphics('figures/rstudio-code-edit-option.png', dpi = NA)


## ----rstudio-code-display, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'-------------------------------------------------------
knitr::include_graphics('figures/rstudio-code-display.png', dpi = NA)


## ----rstudio-code-saving, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'--------------------------------------------------------
knitr::include_graphics('figures/rstudio-code-saving.png', dpi = NA)


## ----rstudio-appearance, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'---------------------------------------------------------
knitr::include_graphics('figures/rstudio-appearance.png', dpi = NA)


## ----rstudio-pane-layout, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'--------------------------------------------------------
knitr::include_graphics('figures/rstudio-pane-layout.png', dpi = NA)


## **실습**: 개인 취향에 맞게 RStudio 에디터 및 theme을 변경해 보자!!


## ----rstudio-new-project-1, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'------------------------------------------------------
knitr::include_graphics('figures/R-newproject-01.png', dpi = NA)


## ----rstudio-new-project-2, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'------------------------------------------------------
knitr::include_graphics('figures/R-newproject-02.png', dpi = NA)


## ----rstudio-new-project-3, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'------------------------------------------------------
knitr::include_graphics('figures/R-newproject-03.png', dpi = NA)


## **실습**: 프로젝트 생성

## 
##    - 위에서 설정한 작업폴더 내에 `학번-r-programming` 프로젝트 생성

##    - 생성한 프로젝트 폴더 내에 `docs`, `figures`, `script` 폴더 생성

## 

## **R 패키지(package)**: 특수 목적을 위한 로직으로 구성된 코드들의 집합으로 R에서 구동되는 분석툴을 통칭

## 
##    - CRAN을 통해 배포: 3자가 이용하기 쉬움 $\rightarrow$ R 시스템 환경에서 패키지는 가장 중요한 역할

##    - CRAN [available package by name](https://cran.r-project.org/web/packages/available_packages_by_date.html) 또는 [available package by    date](https://cran.r-project.org/web/packages/available_packages_by_name.html)에서 현재 등재된 패키지 리스트 확인 가능

##    - R console에서 `available.packages()` 함수를 통해서도 확인 가능

##    - 현재 CRAN 기준(2020-03-17) 배포된 패키지의 개수는 16045 개임

## 
## **목적**: RStudio 환경에서 패키지를 설치하고 불러오기


## ----lib-path, comment=NA, tidy=TRUE--------------------------------------------------------------------------------------------------------------
.libPaths()


## ----window-env, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'-----------------------------------------------------------------
knitr::include_graphics('figures/window-env-system.png', dpi = NA)


## ----window-env-var, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'-------------------------------------------------------------
knitr::include_graphics('figures/window-env-var.png', dpi = NA)


## ----window-new-system-var, fig.align='center', echo=FALSE, fig.show="hold", out.width='90%'------------------------------------------------------
knitr::include_graphics('figures/window-new-system-var.png', dpi = NA)


## ----rstudio-package-install, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'----------------------------------------------------
knitr::include_graphics('figures/rstudio-package-install.png', dpi = NA)


## ----rstudio-package-win02, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'------------------------------------------------------
knitr::include_graphics('figures/rstudio-pack-win-02.png', dpi = NA)


## **실습**: `install.packages()` 함수를 이용해 `tidyverse` 패키지 설치


## ---- eval=FALSE, comment=NA, tidy=TRUE-----------------------------------------------------------------------------------------------------------
install.packages("tidyverse")


## **실습**: `tidyverse` 패키지 불러오기


## ----multiple-package, eval=TRUE, warning=FALSE---------------------------------------------------------------------------------------------------
require(tidyverse)


## 실무에서 R의 활용능력은 패키지 활용 여부에 달려 있음. 즉, 목적에 맞는 업무를 수행하기 위해 가장 적합한 패키지를 찾고 활용하느냐에 따라 R 활용능력의 차이를 보임. 앞서 언급한 바와 같이 CRAN에 등록된 패키지는 16000 개가 넘지만, 이 중 많이 활용되고 있는 패키지의 수는 약 200 ~ 300 개 내외이고, 실제 데이터 분석 시 10 ~ 20개 정도의 패키지가 사용됨. 앞 예제에서 설치하고 불러온 `tidyverse` 패키지는 Hadley Wickham [@tidyverse2019]이 개발한 데이터 전처리 및 시각화 패키지 번들이고, 현재 R 프로그램 환경에 지대한 영향을 미침. 본 강의 "데이터프레임 가공 및 시각화"에서 해당 패키지 활용 방법을 배울 예정


## 본 절에서 다루는 R 문법은 R 입문 시 객체(object)의 명명 규칙과 R 콘솔 창에서 가장 빈번하게 사용되는 기초적인 명령어만 다룰 예정임. 심화 내용은 2-3주 차에 다룰 예정임.


## 알아두면 유용한(콘솔창에서 매우 많이 사용되는) 명령어 및 단축키

## 
## - `ls()`: 현재 R 작업공간에 저장된 모든 객체 리스트 출력

## - `rm(object_name)`: `object_name`에 해당하는 객체 삭제

## - `rm(list = ls())`: R 작업공간에 저장된 모든 객체들을 일괄 삭제

## - 단축키 `[Ctrl] + [L]`: R 콘솔 창 일괄 청소

## - 단축키 `[Ctrl] + [Shift] + [F10]`: R session 초기화

## 
## **예시**


## ---- comment=NA----------------------------------------------------------------------------------------------------------------------------------
x <- 7
y <- 1:30 #1에서 30까지 정수 입력
ls() #현재 작업공간 내 객체명 출력


## ---- comment=NA----------------------------------------------------------------------------------------------------------------------------------
rm(x) # 객체 x 삭제
ls()
rm(a,b) # 객체 a,b 동시 삭제
ls()
# rm(list = ls()) # 모든 객체 삭제


## ----assign-diff, comment=NA, error=TRUE----------------------------------------------------------------------------------------------------------
# mean(): 입력 벡터의 평균 계산
mean(y <- 1:5)
y
mean(x = 1:5)
x


## ----objectName-ex01, echo = T, eval = T, prompt = F----------------------------------------------------------------------------------------------
# 1:10은 1부터 10까지 정수 생성
# 'c()'는 벡터 생성 함수
x <- c(1:10) 
# 1:10으로 구성된 행렬 생성
X <- matrix(c(1:10), nrow = 2, ncol = 5, byrow = T)
x
X
# 논리형 객체
.x <- TRUE
.x
# 알파벳 + 숫자
a1 <- seq(from = 1, to = 10, by = 2)
# 한글 변수명
가수 <- c("Damian Rice", "Beatles", "최백호", "Queen", "Carlos Gardel", "BTS", "조용필")
가수


## ----objName-ex02, comment=NA, error=TRUE---------------------------------------------------------------------------------------------------------
3x <- 7


## ----objName-ex03, comment=NA, error=TRUE---------------------------------------------------------------------------------------------------------
_x <- c("M", "M", "F")


## ----objName-ex04, comment=NA, error=TRUE---------------------------------------------------------------------------------------------------------
.3 <- 10


## [R 기초 문법] 절과 마찬가지로 R Markdown을 이용해 최소한의 문서(`html` 문서)를 작성하고 생성하는 방법에 대해 기술함. R Markdown에 대한 보다 상세한 내용은 본 수업의 마지막 주차에 다룰 예정임.


## ----rmarkdown-flow, fig.align='center', echo=FALSE, fig.show="hold", out.width='60%', fig.cap="R Markdown의 최종 결과물 산출과정(http://applied-r.com/project-reporting-template/)"----
knitr::include_graphics('figures/rmarkdown-flow.png', dpi = NA)


## RStudio를 처음 설치하고 위와 같이 진행할 경우 아래와 같은 패키지 설치 여부를 묻는 팝업 창이 나타남. 패키지 설치 여부에 `[Yes]`를 클릭하면 R Markdown 문서 생성을 위해 필요한 패키지들이 자동으로 설치


## ----rmarkdown-new-01, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'-----------------------------------------------------------
knitr::include_graphics('figures/rmarkdown-new-01.png', dpi = NA)


## ----rmarkdown-new-02, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'-----------------------------------------------------------
knitr::include_graphics('figures/rmarkdown-new-02.png', dpi = NA)


## ----rmarkdown-new-03, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'-----------------------------------------------------------
knitr::include_graphics('figures/rmarkdown-new-03.png', dpi = NA)


## ----rmarkdown-new-04, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'-----------------------------------------------------------
knitr::include_graphics('figures/rmarkdown-new-04.png', dpi = NA)


## ----rmarkdown-new-out, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%', fig.cap="test.html 문서 화면(저장 폴더 내 `test.html`을 크롬 브라우저로 실행)"----
knitr::include_graphics('figures/rmarkdown-new-out.png', dpi = NA)


## ----rmarkdown-part, fig.align='center', echo=FALSE, fig.show="hold", out.width='80%'-------------------------------------------------------------
knitr::include_graphics('figures/rmarkdown-part.png', dpi = NA)


## ---- fig.show='hold'-----------------------------------------------------------------------------------------------------------------------------
fit = lm(dist ~ speed, data = cars)
b   = coef(fit)
plot(cars)
abline(fit)


## ----knitr-logo, out.width='32.8%', fig.show='hold'-----------------------------------------------------------------------------------------------
knitr::include_graphics(rep('figures/knit-logo.png', 3))


## **Homework 1**: R Markdown 문서에 아래 내용을 포함한 문서를 `html` 파일 형식으로 출력 후 제출

## 
##    - 간략한 자기소개 및 "통계 프로그래밍 언어" 수업에 대한 본인만의 목표 기술

##    - 본인이 setting 한 RStudio 구성 캡쳐 화면을 그림 파일로 저장하고 R Markdown 문서에 삽입(화면 캡쳐 시 생성 프로젝트 내 폴더 내용 반드시 포함)

##    - 패키지 `ggplot2`를 불러오고 `cars` 데이터셋의 2차원 산점도(**hint**: `help(geom_point)` 또는 googling 활용)를 문서에 포함

## 
