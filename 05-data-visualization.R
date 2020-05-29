## ---- echo=FALSE, message=FALSE------------------------------------------------------------------------------------------------------------------------------------------------------------
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
require(kableExtra)
require(extrafont)



## **학습 목표**

## 

## - R에서 기본으로 제공하는 그래프 생성 개념 및 관련 함수의 의미 및 사용 방법에 대해 학습한다.

## - Grammar of graphics를 기반으로 개발된 ggplot2 패키지에 대해 알아보고 사용 방법을 학습힌다.

## 

## ---- echo=FALSE, message=FALSE, warning=FALSE, fig.show="hold", fig.width=8, fig.height=6, fig.cap="Anscombe's quartet: https://goo.gl/Ugv3Cz 에서 스크립트 발췌"-------------------------
# Anscombe 데이터셋
head(anscombe)
apply(anscombe, 2, mean)
apply(anscombe, 2, sd)

op <- par(mfrow = c(2,2))
ff <- y ~ x
for (i in 1:4) {
  ff[[2]] <- as.name(paste0("y", i))
  ff[[3]] <- as.name(paste0("x", i))
  modi <- lm(ff, data = anscombe)
  xl <- substitute(expression(x[i]), list(i = i))
  yl <- substitute(expression(y[i]), list(i = i))
  plot(ff, data = anscombe, col = "red", 
       pch = 21, 
       cex = 2.4, 
       bg = "orange", 
       xlim = c(3, 19), 
       ylim = c(3, 13), 
       xlab = eval(xl), ylab = yl)
  abline(modi, col = "blue")
}
par(op)



## ----r-graphic-layout, fig.align='center', echo=FALSE, fig.show='hold', fig.width=8, fig.height=6, fig.show="hold", fig.cap="R 그래프영역"-------------------------------------------------
par(oma = c(2, 2, 2, 2))
set.seed(10)
x <- rnorm(100)
hist(x, col = "#4A92FF")


region <- c("plot", "figure", "outer")
for (i in region) {
box(which = i, 
    lty = 1, 
    cex = 1.5, 
    col = "red")  
}
text(-2, 15, "plot region")
mtext("figure region", side = 3, adj = 0, at = -3, line = 2)
for (i in 1:4) {
mtext(paste("Figure margin", i), 
      side = i, 
      col = "red")  
}
mtext("outer margin area", side = 3, adj = 0, line = 1, outer = TRUE)
for (i in 1:4) {
mtext(paste("Outer margin", i), 
      side = i, 
      outer = TRUE, 
      col = "blue")  
}





## R 기본 그래프 함수에 대한 강의 내용은 주로 [AIMS-R-users](http://users.monash.edu.au/~murray/AIMS-R-users/ws/ws11.html)에서 참고를 함


## **주의**: 일반적으로 R 기본 그래픽 함수로 도표 작성 시 저수준 그래프 함수는 고수준 그래프 함수로 생성한 그래프에 부가적 기능을 추가하기 위해 사용됨. 따라서 저수준 그래프 함수군은 고수준 그래프 함수을 통해 먼저 생성한 그래프(주로 아래 설명할 `plot()` 함수) 위에 적용됨.

## 

## ---- fig.width=9, fig.heigth=12, fig.show="hold"------------------------------------------------------------------------------------------------------------------------------------------
#각 클래스에 적용되는 plot() 함수 리스트
methods(plot)

#예시 1: 객체 클래스가 데이터 프레임인 경우
# mtcars 데이터 예시
class(mtcars)
plot(mtcars)



## ---- message=FALSE, fig.width=9, fig.height=8, fig.show="hold"----------------------------------------------------------------------------------------------------------------------------
# 예시2: lm()으로 도출된 객체(list)
## 연비(mpg)를 종속 변수, 배기량(disp)을 독립변수로 한 회귀모형
## lm() 함수 사용 -> 객체 클래스는 lm

mod <- lm(mpg ~ disp, data = mtcars)
class(mod)
par(mfrow = c(2, 2)) # 4개 도표를 한 화면에 표시(2행, 2열)
plot(mod)
dev.off() # 활성화된 그래프 장치 닫기



## ---- message=FALSE, fig.width=9, fig.height=8, fig.show="hold"----------------------------------------------------------------------------------------------------------------------------
# 예시3: 테이블 객체
class(Titanic)
plot(Titanic)



## ---- out.width="50%"----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# 예시1: 데이터 객체를 하나만 인수로 받는 경우
# -> x축은 객체의 색인이고, x의 데이터는 y 좌표에 매핑
x <- mtcars$disp
y <- mtcars$mpg

plot(x); plot(y)


## ---- fig.width = 8, fig.height=6----------------------------------------------------------------------------------------------------------------------------------------------------------
# 두개의 객체를 인수로 받은 경우
# -> 2차원 산점도 출력

plot(x, y)



## ---- eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## plot(
##   x, # x 축에 대응하는 데이터 객체
##   y, # y 축에 대응하는 데이터 객체
##   type, # 그래프 타입(예시 참조)
##   main, # 제목
##   sub,  # 부제목
##   xlim, ylim, # x, y 축 범위 지정
##   xlab, ylab, # x-y 축 이름
##   lty, # 선 모양
##   pch, # 점 모양
##   cex, # 점 및 텍스트 크기
##   lwd, # 선 굵기
##   col  # 색상
## )


## ---- fig.width=10, fig.height=6-----------------------------------------------------------------------------------------------------------------------------------------------------------
# BOD 데이터셋 이용
x <- BOD$Time; y <- BOD$demand
x; y
ctype <- c("p", "l", "b", "o", "c", "h", "s", "n")
type_desc <- c("points", "lines", 
               "both points and lines", 
               "overlapped points and plots", 
               "empty points joined by lines", 
               "histogram like vertical lines", 
               "stair steps", 
               "no lines and points")

op <- par(mfrow = c(2, 4))
for (i in 1:length(ctype)) {
  plot(x, y, 
       type = ctype[i], 
       main = paste("type =", "'", ctype[i], "'"),
       sub = type_desc[i], 
       cex.main = 1.5, 
       cex.sub = 1.5, 
       cex = 2)
}
par(op)



## ---- fig.show="hold"----------------------------------------------------------------------------------------------------------------------------------------------------------------------
op <- par(mfrow = c(2, 3))
range <- data.frame(
  x1 = rep(c(0, 1), each = 3),
  x2 = rep(c(10, 5), each = 3), 
  y1 = rep(c(0, 5, 8), times = 2), 
  y2 = rep(c(30, 20, 16), times = 2)
  )
for (i in 1:6) {
  plot(x, y, 
       xlim = as.numeric(range[i, 1:2]), 
       ylim = as.numeric(range[i, 3:4]), 
       main = paste0("xlim = c(", 
                     paste(as.numeric(range[i, 1:2]), 
                           collapse = ", "), "), ", 
                     "ylim = c(", 
                     paste(as.numeric(range[i, 3:4]), 
                           collapse = ", "), ")")
       )
}
par(op)



## ---- fig.show="hold", fig.width=10, fig.height=7------------------------------------------------------------------------------------------------------------------------------------------
x_lab <- c(" ", "Time (days)")
y_lab <- c("Demand", "Oxygen demend (mg/l)")

op <- par(mfrow = c(2, 2))
lab_d <- expand.grid(x_lab, y_lab)

for (i in 1:4) {
  plot(x, y, 
       xlab = lab_d[i, 1], 
       ylab = lab_d[i, 2], 
       main = paste0("xlab = ", "'", lab_d[i, 1], "'", ", ", 
                     "ylab = ", "'", lab_d[i, 2], "'")
  )
}
par(op); dev.off()



## ----plot-linetype, fig.show="hold", fig.width=8, fig.height=8, fig.cap="lty 파라미터 값에 따른 선 형태"-----------------------------------------------------------------------------------
line_type <- c("blank", "solid", "dashed", "dotted",
               "dotdash", "longdash", "twodash")
plot(x = c(1:7), y = c(1:7), type="n", 
     axes = FALSE, 
     xlab = "", 
     ylab = "", 
     main = "Basic Line Types", 
     cex.main = 1.5)

for (i in 1:length(line_type)) {
  lines(c(1, 5.2), c(i, i), lty = i - 1, lwd = 2)  
  text(5.5, i, 
       labels = paste0("lty = ", i - 1, " (", 
                       line_type[i], ")"), 
       cex = 1.2, 
       adj = 0)
}





## ----plot-symbol, fig.show="hold", fig.width=7, fig.height=7, fig.cap="R graphics 점 표현 기호 및 대응 번호"-------------------------------------------------------------------------------
coord <- expand.grid(x = 1:5, y = 1:5)
plot(coord, type = "n", 
     xlim = c(0.8, 5.5), 
     ylim = c(0.8, 5.5), 
     xlab = "", 
     ylab = "", 
     main = "Basic plotting characters", 
     xaxt = "n", 
     yaxt = "n")
grid()
points(coord, pch=1:25, cex = 2.5)
text(coord + 0.2, labels = 1:25, cex = 1)



## ---- fig.show="hold", fig.width=9, fig.height=7-------------------------------------------------------------------------------------------------------------------------------------------
par(mfrow = c(2, 3))
plot(BOD, type = "p", cex = 2, 
     main = "cex = 2", 
     sub = "Subtitle")
plot(BOD, type = "p", 
     cex.axis = 2, 
     main = "cex.axis = 2", 
     sub = "Subtitle")
plot(BOD, type = "p", 
     cex.lab = 2, 
     main = "cex.lab = 2", 
     sub = "Subtitle")
plot(BOD, type = "p", 
     cex.main = 2, 
     main = "cex.main = 2", 
     sub = "Subtitle")
plot(BOD, type = "p",
     cex.sub = 2, 
     main = "cex.sub = 2", 
     sub = "Subtitle")




## ---- fig.show="hold", fig.width=7, fig.height=7-------------------------------------------------------------------------------------------------------------------------------------------
coord <- expand.grid(x = 1:5, y = 1:5)
plot(coord, type="n", 
     xlab = "cex", 
     ylab = "lwd", 
     xlim = c(0.5, 5.5), 
     ylim = c(0.5, 5.5),
     main = "pch and lwd size", 
     cex.main = 2, 
     cex.lab = 1.5)
points(coord, pch=16, cex = 1:5, col = "darkgray")
for (i in 1:5) {
  points(1:5, coord$y[coord$y == i], pch=21, 
         cex = 1:5, 
         lwd = i, col = "black")
}



## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='100%'---------------------------------------------------------------------------------------------------------------------
knitr::include_graphics('figures/r-graphic-palette.png', dpi = NA)


## ---- fig.show="hold", fig.width=8, fig.height=6-------------------------------------------------------------------------------------------------------------------------------------------
# car 패키지 설치
# install.packages("car")
# require(car)
car::scatterplot(mpg ~ disp, data = mtcars)



## ---- fig.show="hold", fig.width=8, fig.heigh=6--------------------------------------------------------------------------------------------------------------------------------------------
# help(scatterplot) 참고
car::scatterplot(mpg ~ disp, data = mtcars, 
                 regLine = list(method = lm, lty = 1, col = "red"), 
                 col = "black", cex = 2, pch = 16)



## ---- fig.show="hold", fig.width=8, fig.heigh=8--------------------------------------------------------------------------------------------------------------------------------------------
# iris dataset
plot(iris)



## ---- fig.show="hold", fig.width=8, fig.heigh=8--------------------------------------------------------------------------------------------------------------------------------------------
# iris dataset
car::scatterplotMatrix(iris, col = "black")



## ---- fig.show="hold", fig.width=8, fig.heigh=8--------------------------------------------------------------------------------------------------------------------------------------------
# help(scatterplotMatrix)
car::scatterplotMatrix(iris, col = c("red", "blue", "green"), 
                       smooth = FALSE, 
                       groups = iris$Species, 
                       by.groups = FALSE, 
                       regLine = list(method = lm, lwd = 1, col = "gray"), 
                       pch = (15:17))



## ---- fig.show="hold", fig.width=8, fig.heigh=6--------------------------------------------------------------------------------------------------------------------------------------------
# 행렬을 plot() 함수의 입력으로 받은 경우
par(mfrow = c(1,2))
x <- seq(-5, 5, 0.01)
X <- mapply(dnorm, 
            list(a = x, b = x, c = x), 
            c(0, 1, 2), 
            c(1, 2, 4))
X <- matrix(X, nrow = length(x), ncol = 3)
head(X)

# plot() 함수를 이용한 행렬 그래프 출력
plot(X, type = "l", main = "plot matrix (X) using plot()")
text(0.2, 0.05, labels = "plot(X, type = `l`)")
plot(X[, 1], X[, 2], type = "l", 
     main = "scatterplot between X[, 1] and X[, 2]")
text(0.2, 0.05, labels = "plot(X[,1], X[,2], type = `l`)")



## ---- fig.show="hold", fig.width=8, fig.heigh=6--------------------------------------------------------------------------------------------------------------------------------------------
# matplot 도표
par(mfrow = c(1, 2))
matplot(X, type = "l", 
        lwd = 2, 
        main = "matplot() without x")
matplot(x, X, type = "l", 
        lwd = 2, 
        main = "matplot() with x")



## ---- eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## hist(
##   x, # vector 객체
##   breaks, # 빈도 계산을 위한 구간
##   freq, # y축 빈도 또는 밀도(density) 여부
##   col, # 막대 색상 지정
##   border, # 막대 테두리 색 지정
##   labels, # 막대 위 y 값 레이블 출력 여부
##   ...
## )


## ---- fig.show="hold", fig.width=8, fig.heigh=8--------------------------------------------------------------------------------------------------------------------------------------------
# airquality 데이터 셋
# help(airquality) 참고
glimpse(airquality)
temp <- airquality$Temp
hist(temp)



## ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
h <- hist(temp, plot = FALSE) # 그래프를 반환하지 않음
h


## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.heigh=8-----------------------------------------------------------------------------------------------------------------------------

hist(temp,
main="La Guardia Airport 일중 최고 기온",
xlab = "온도",
ylab = "밀도",
xlim = c(50,100),
col = "orange",
freq = FALSE
)



## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.heigh=8-----------------------------------------------------------------------------------------------------------------------------
hist(temp,
main = "La Guardia Airport 일중 최고 기온",
xlab = "온도",
ylab = "빈도",
xlim = c(50,100),
col = "orange",
labels = TRUE
)



## ---- warning=FALSE, fig.show="hold", fig.width=10, fig.height=7---------------------------------------------------------------------------------------------------------------------------
op <- par(mfrow = c(1, 2))
hist(temp, breaks = 4, main = "breaks = 4")
hist(temp, breaks = 15, main = "breaks = 15")
par(op); dev.off()


## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.heigh=6-----------------------------------------------------------------------------------------------------------------------------
x = c(1,2,2,1,3,3,1,5)
par(mfrow = c(1, 2))
hist(x); barplot(x)




## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.heigh=6-----------------------------------------------------------------------------------------------------------------------------
## Wool dataset: warpbreaks 
## 제직 중 방적 횟수
## 직조기 당 날실 파손 횟수 데이터
head(warpbreaks)
count <- with(warpbreaks, 
              tapply(breaks, list(wool, tension), 
                     sum))

par(mfrow = c(1, 2))
barplot(count, legend = TRUE, 
        xlab = "Tension", 
        ylab = "Number of breaks", 
        ylim = c(0, 700), 
        cex.lab = 1.5) # stack 형태

barplot(count, legend = TRUE, beside = TRUE, 
        xlab = "Tension", 
        ylab = "Number of breaks", 
        ylim = c(0, 450), 
        cex.lab = 1.5) # 분리 형태



## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.height=7----------------------------------------------------------------------------------------------------------------------------
mean_breaks <- aggregate(breaks ~ wool + tension, 
                         data = warpbreaks, 
                         mean)
se_breaks <- aggregate(breaks ~ wool + tension, 
                       data = warpbreaks, 
                       FUN = function(x) sd(x)/sqrt(length(x)))

barplot(breaks ~ wool + tension, 
        data = mean_breaks, 
        ylim = c(0, 55), 
        beside = TRUE, 
        legend = TRUE, # 범례
        col = c("blue", "skyblue")
        ) -> bp
cent <- matrix(mean_breaks$breaks, 2, 3)
sem <- matrix(se_breaks$breaks, 2, 3)
arrows(bp, cent - sem, bp, cent + sem, angle = 90, code = 3, length = 0.05)



## ---- warning=FALSE, fig.show="hold", fig.width=9, fig.height=6----------------------------------------------------------------------------------------------------------------------------
set.seed(20200522)
x <- rnorm(100)
plab <- c("min(x)", "quantile(x, 0.25)", "median(x)", 
          "quantile(x, 0.75)", "max(x)") # x-axis 레이블
bxplt <- boxplot(x, 
                 horizontal = TRUE, # x-y 축 회전 여부
                 axes = F, # x-y 축 출력 여부
                 main = "Boxplot anatomy", 
                 cex.main = 2
                 ) # boxplot 수치 요약값 저장
axis(side = 1, at = bxplt$stats, 
     labels = FALSE, 
     las = 2) # x-axis 설졍
text(x = c(bxplt$stats), 
     y = 0.4, 
     labels = plab, 
     xpd = TRUE, # 텍스트 출력 영역 범위 지정
     srt = 25, # 레이블 로테이션 각도(degree)
     adj = 1.1, # 레이블 위치 조정
     cex = 1.2 # 레이블 크기 조정
     ) # x-axis 레이블 조정
abline(v = c(bxplt$stats), lty = 2, col = "gray") # 수직 선 출력
arrows(x0 = c(bxplt$stats)[2], y0 = 1.3, 
       x1 = c(bxplt$stats)[4], y1 = 1.3, 
       code = 3, 
       length = 0.1) # IQR 범위에 화살표 출력
text(x = -0.1, y = 1.3, 
     labels = "Interquartile range (IQR)", 
     adj = 0.5, pos = 3) # 



## ---- eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## boxplot(x, # boxplot 대상 객체 명
##         ... # 두 개 이상 객체(보통은 벡터)
##         )
## 또는
## 
## boxplot(formula, # 수식 표현
##         data, # 데이터 프레임 객체명
##         subset, # 부집단 선택
##         ... # help(boxplot)을 통해 인수 사용법 참고
##         )
## 


## ----boxplot-ex, warning=FALSE, fig.show="hold", fig.width=8, fig.height=8-----------------------------------------------------------------------------------------------------------------
par(mfrow = c(2, 2))
set.seed(20200522)
y <- rnorm(100, 2, 1)
# vector 객체 boxplot
boxplot(x, y, 
        main = "Boxplot for a vector object")
axis(side = 1, at = 1:2, labels = c("x", "y"))

# 행렬 객체 boxplot
head(X)
boxplot(X, 
        main = "Boxplot for a matrix `X`")

# 데이터 프레임 객체 boxplot
boxplot(breaks ~ wool + tension, 
        data = warpbreaks, 
        main = "Boxplot for a dataframe `warpbreaks`", 
        col = topo.colors(6))

# 리스트 객체 boxplot
## list 생성: mapply
set.seed(20200522)
xl <- mapply(rnorm, # 정규 난수 생성 함수
             c(50, 100, 150, 200), # 첫번째 인수 n
             c(0, 2, 4, 6), # 두 번째 인수 mean
             c(1, 1, 1, 2)) # 세번째 인수 sd
boxplot(xl, 
        main = "Boxplot for a list `xl`", 
        col = "lightgray")



## ----vioplot-ex, warning=FALSE, fig.show="hold", fig.width=8, fig.height=8-----------------------------------------------------------------------------------------------------------------
# install.packages(vioplot)
# require(vioplot)
## generating bimodal distribution
mu <- 2; sigma <- 1
set.seed(20200522)
bimodal <- c(rnorm(200, mu, sigma), 
             rnorm(300, -mu, sigma)) # 두 정규분포 혼합
normal <- rnorm(200, 2*mu, sigma) # 정규분포
unif <- runif(200, -2, 2) # uniform 분포 (-2, 2)

par(mfrow = c(2,2))
boxplot(bimodal, normal, unif, 
        main = "Boxplot for each distribution (vectors)")
vioplot::vioplot(bimodal, normal, unif, 
                 main = "Violin plot for each distribution (vectors)", 
                 col = "skyblue")

vioplot::vioplot(breaks ~ wool + tension, 
                 data = warpbreaks, 
                 main = "Violin plot for a dataframe `warpbreaks`", 
                 col = heat.colors(6))

vioplot::vioplot(xl, 
                data = warpbreaks, 
                main = "Violin plot for a list `xl`", 
                col = rainbow(4))



## 로그선형모형(log-linear model)은 다차원 교차표의 셀 빈도를 예측하기 위한 모형임. 해당 모형에 대한 기술은 본 강의의 범위 벗어나기 때문에 설명을 생략함.


## ---- echo = FALSE, fig.show="hold", fig.width=9, fig.height=7-----------------------------------------------------------------------------------------------------------------------------
# require(vcd)
mosaicplot(~ Survived + Sex, data = Titanic, 
           shade = TRUE, 
           cex = 1.1)
mar_tab <- c(margin.table(Titanic, c(2, 4)))
text(0.3, 0.5, labels = mar_tab[1], col = "white", cex = 2)
text(0.68, 0.7, labels = mar_tab[3], col = "white", cex = 2)
text(0.3, 0.016, labels = mar_tab[2], col = "white", cex = 2)
text(0.68, 0.2, labels = mar_tab[4], col = "white", cex = 2)



## ---- eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## mosaicplot(
##   x, # 테이블 객체
##   shade # goodness-of-test 결과 출력 여부
##   ...
## )
## 또는
## 
## mosaicplot(
##   formula, # 수식 표현식
##   data, # 데이터 프레임, 리스트 또는 테이블
##   shade
## )
## 


## ---- fig.show="hold", fig.width = 10, fig.height=7----------------------------------------------------------------------------------------------------------------------------------------
dimnames(UCBAdmissions)
collapse_admin_tab <- margin.table(UCBAdmissions, margin = c(1,2))
is.table(collapse_admin_tab)

par(mfrow = c(1, 2), 
    mar = c(2, 0, 2, 0)) # figure margin 조정
                         # bottom, left, top, right
mosaicplot(collapse_admin_tab, 
           main = "Student admissions at UC Berkeley", 
           color = TRUE)
mosaicplot(~ Dept + Admit + Gender, data = UCBAdmissions, 
           color = TRUE)


## ---- fig.show="hold", fig.width = 10, fig.height=7----------------------------------------------------------------------------------------------------------------------------------------
par(mfrow = c(2, 3), 
    oma = c(0, 0, 2, 0))
for (i in 1:6) {
  mosaicplot(
    UCBAdmissions[, , i], 
    xlab = "Admit", 
    ylab = "Sex", 
    main = paste("Department", LETTERS[i]), 
    color = TRUE
  )
}
mtext(
  expression(bold("Student admissions at UC Berkeley")), 
  outer = TRUE, 
  cex = 1.2
)


## ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# 그래프 파라미터 조회 
# 처음 12개 파라미터들에 대해서만 조회
unlist(par()) %>% head(12)

# 파라미터 이름으로 값 추출
par("mar")


## ----tab-05-01, echo=FALSE-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Parameter <- c("din, fin, pin", 
               "fig", "mai, mar", 
               "mfcol,mfrow", "mfg", 
               "new", "oma,omd,omi")
`값` <- c("= c(width, height)", "=c(left, right, bottom, top)", 
          "= c(bottom, left, top, right)", "= c(row, column)", 
         "=c(rows, columns)", "=TRUE or =FALSE", "=c(bottom, left, top, right)")
`설명` <- c("그래픽 장치(device), figure, plot 영역 크기(너비: width, 높이: height) 조정(인치 단위)", 
            "장치 내 figure 영역의 4개 좌표 조정을 통해 figure 위치 및 크기 조정", 
            "Figure 영역의 각 4개 마진의 크기 조정(인치 또는 현재 폰트 사이즈 기준 텍스트 길이 단위)", 
             "그래프 화면 출력을 열 또는 행 기준으로 분할", 
            "mfcol 또는 mfrow로 분할된 그림에서 figure의 위치 조정", 
            "현재 figure 영역을 새 그래프 장치로 인지(TRUE 이면 이미 출력된 그림 위에 새로운 고수준 그래프 함수가 생성) 여부", 
            "Outer margin (여백) 각 영역별 크기 조정(인치 또는 설정 텍스트 크기 기준)")
tab05_01 <- data.frame(
  Parameter, 
  `값`, 
  `설명`, 
  stringsAsFactors = FALSE
)

kable(tab05_01,
      align = "rll",
      escape = TRUE, 
      booktabs = T, caption = "") %>%
  kable_styling(bootstrap_options = c("striped"), 
                position = "center", 
                font_size = 11, 
                full_width = TRUE, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "2cm") %>% 
  column_spec(2, width = "4cm") %>% 
  column_spec(3, width = "5cm") %>% 
  row_spec(1:length(Parameter), monospace = TRUE)




## ----layout-par, echo=FALSE, fig.show="hold", out.width="50%", fig.cap="레이아웃 파라미터. AIMS-R-Users 에서 발췌"-------------------------------------------------------------------------
knitr::include_graphics('figures/graphics-figureAnatomy1.png', dpi = NA)
knitr::include_graphics('figures/graphics-figureAnatomy2.png', dpi = NA)


## 아래 `par()` 함수의 파라미터 값에 대한 도표 생성을 위한 R 스크립트는 [Graphical parameters of R graphics package](http://rstudio-pubs-static.s3.amazonaws.com/315576_85cccd774c29428ba46969316cbc76c0.html)에서 참고 및 발췌

## 

## ---- echo=FALSE, fig.show="hold", fig.width=8, fig.height=7, fig.show="hold"--------------------------------------------------------------------------------------------------------------
# set.seed(20200528)
# x <- runif(30)
# op <- par(
#   fin = c(5, 5), # figure 영역 size: 5 by 5 inches
#   pin = c(3.5, 3.5) # plot 영역 size: 3.5 by 3.5 inches
# )
# plot(x, 
#      ann = FALSE # x-y 축 레이블(제목) 출력 여부
#      )
# # margin (공백) 영역에 text 출력
# mtext("plot region size: width = 3.5, height = 3.5", 
#       side = 1, # 텍스트 위치(1=bottom, 2=left, 3=top, 4=right)
#       line = 2 # 공백 영역 텍스트 시작 라인 위치
#       )
# 
# opar <- par(
#   fin = c(5, 5), 
#   pin = c(2, 2)
# )
# hist(x, ann = FALSE)
# mtext("plot region size: width = 2, height = 2", 
#       side = 1, 
#       line = 2
#       )
op <- par(no.readonly = TRUE)
par(op)
par(pin = c(5, 2))
set.seed(1023)
plot(runif(10), runif(10)
    , xlim = c(0, 1), ylim = c(0, 1)
    , xlab = "x axis", ylab = "y axis"
    )
grid()
# box("inner", col = "green")
box("plot", col = "blue")
box("figure", col = "red")
mtext(side = 3, line = 1, at = 0, adj = 0, paste0("par(\"pin\") = c(", paste(par("pin"), collapse = ", "), ")"))
mtext(side = 3, line = 2, at = 0, adj = 0, paste0("par(\"plt\") = c(", 
    paste(round(par("plt"), 2), collapse = ", "), ")"))
mtext(side = 3, line = 0, at = 0, adj = 0, paste0("par(\"fig\") = c(", 
    paste(round(par("fig"), 2), collapse = ", "), ")"))



## ---- echo=FALSE, fig.show="hold", fig.width=8, fig.height=7-------------------------------------------------------------------------------------------------------------------------------
text_pos <- c(0, 1, 2, 3, 0, 1)
at_pos <- c(rep(0, 4), 0.5, 0.5)
par_nm <- c("mar", "mai", "fig", "fin", "plt", "pin")
pardf <- data.frame(
  text_pos, at_pos, par_nm, 
  stringsAsFactors = FALSE
)

plot_dimension <- function(x) {
  for (i in 1:nrow(pardf)) {
    # stopifnot(par(pardf$par_nm[i])[1] >= 4)  
      mtext(paste0(pardf$par_nm[i],  " = c(", 
               paste(round(x[[pardf$par_nm[i]]], 2), 
                     collapse = ", "), ")"), 
        side = 1, 
        at = pardf$at_pos[i], 
        line = pardf$text_pos[i], 
        cex = 0.8, adj = 0)
  }
}
par(op)
oldpar <- par(fin = c(op$fin[1]*0.8, op$fin[2] / 1.5))
opnew <- par()
set.seed(20200528)
plot(runif(20), runif(20), xlim = c(0, 1), ylim = c(0, 1),
    main = "Example of fin parameter")
box("figure", lty = 1, col = "red")
# box("outer", lty = 1, col = "blue")
par(oldpar)

plot_dimension(opnew)
mtext(sprintf("fin = c(Width = %.2f, Height = %.2f)", 
              par("fin")[1]*0.8, par("fin")[2]/1.5)
    , side = 3, at = 0, line = 0, font = 2, cex = 1, adj = 0)



## ----fig-anatomy, fig.show="hold", fig.width=7, fig.height=7, fig.cap="fig 인수 조정 예시: Graphical parameters of R graphics package에서 발췌"--------------------------------------------
text_loc <- seq(0, 0.25, by = 0.05)
par_name <- c("mar", "mai", "fig", "fin", "plt", "pin")

plot_dim <- function(x, y, op, title, ...) {
  for (i in 1:length(text_loc)) {
    text(x, y + text_loc[i], 
         paste0(par_name[i], " = c(", 
                paste(round(op[[par_name[i]]]), 
                            collapse = ", "), ")"), 
         adj = 0, ...)
  }
  text(x, y + text_loc[i] + 0.05, title, adj = 0)
}


# 1. plot area available when internal margins are 0
par(op)
par(mai = c(0, 0, 0, 0), xaxs = 'i', yaxs = 'i')
plot.new()
abline(h = c(0.4, 0.9), v = c(0.4, 0.9), lty = 4)
rect(0.4, 0.4, 0.9, 0.9, border = "red")
par(op)


# 2. Plot new fig
newfig <- c(0.4, 0.9, 0.4, 0.9)
par(fig = newfig, new = TRUE)
op_reduced <- par(no.readonly = TRUE)
set.seed(12345)
plot(runif(10), runif(10), typ = 'p', 
    xlab = 'X', ylab = 'Y', xlim = c(0, 1), ylim = c(0, 1))
par(op)
par(mai = c(0, 0, 0, 0), xaxs = 'i', yaxs = 'i', new = TRUE)

# 3. Info about dimensions
plot.new()
plot_dim(0.05, 0.5, op_reduced, "New plot dimension on the right", cex = 0.9)
plot_dim(0.5, 0.05, op, "Default plot dimensions", cex = 0.8)



## ----mar-anatomy, echo=FALSE, fig.show="hold", fig.width=7, fig.height=7, fig.cap="Figure 영역에서 기본 여백: Graphical parameters of R graphics package 에서 발췌"------------------------
par(op)
# start by plotting plt parameter values
# and fin
par(mar = rep(0, 4))

plot(1, 1
    , type = 'n', axes = FALSE, ann = FALSE
    , xaxs = 'i', yaxs = 'i'
    , xlim = c(0,10), ylim = c(0,10)
    , lab = c(10, 10, 7))
abline(v = op$plt[1:2] * 10, h = op$plt[3:4] * 10, lty = 1, col = "red")
arrows(0, 1.5, op$plt[1]*10, 1.5, code = 3, length = 0.1)
arrows(op$plt[2] * 10, 1.5, 10, 1.5, code = 3, length = 0.1)
arrows(6, 0, 6, op$plt[3]*10, code = 3, length = 0.1)
arrows(6, op$plt[4]*10, 6, 10, code = 3, length = 0.1)
text(0.2, 1, "mai[2]", cex = 0.8, adj = 0)
text(6.5, 1, "mai[1]", cex = 0.8, adj = 0)
text(9.3, 1, "mai[4]", cex = 0.8, adj = 0)
text(6.5, 9.5, "mai[3]", cex = 0.8, adj = 0)

# start by plotting a normal plot with standard parameter but in light colors
plot_color = "lightgray"
par(col.main= plot_color
    , col.lab = plot_color
    , col.sub = plot_color
    , col.axis = plot_color
    , fg = plot_color
    , new = TRUE
    , mar = op$mar)
set.seed(1023)
plot(runif(10), runif(10)
    , type = 'p'
    , xlim = c(0, 1), ylim = c(0, 1)
    , xlab = "x axis label", ylab = "y axis label"
    , main = "Plot Title"
    , sub = "Plot Subtitle")

plot_color = "black"
par(col.main= plot_color
    , col.lab = plot_color
    , col.sub = plot_color
    , col.axis = plot_color
    , fg = plot_color, new = TRUE)
plot(0.5, 0.5, type = 'n', axes = FALSE, xlim = c(0, 1), ylim = c(0, 1),
    xlab = '', ylab = '')
text(0.1, 0.6, "Default value for mai, mar, fin, plt", adj = 0)
text(0.1, 0.5, paste0("mar = c(", paste(par("mar") - 0.1, collapse = ", "), ") + 0.1"), adj = 0)
text(0.1, 0.4, paste0("mai = c(", paste(par("mai"), collapse = ", "), ")"), adj = 0)
text(0.1, 0.3, paste0("fin = c(", paste(round(par("fin"), 2), collapse = ", "), ")"), adj = 0)
text(0.1, 0.2, paste0("plt = c(", paste(round(par("plt"), 2), collapse = ", "), ")"), adj = 0)
text(0.1, 0.1, paste0("mex = c(", paste(round(par("mex"), 2), collapse = ", "), ")"), adj = 0)


text(0.7, 0.5, "mai[1] = fin[2] * plt[3]", cex = 0.8, col ="blue", adj = 0)
text(0.7, 0.4, "mai[2] = fin[1] * plt[1]", cex = 0.8, col ="blue", adj = 0)
text(0.7, 0.3, "mai[3] = fin[2] * (1 - plt[4])", cex = 0.8, col ="blue", adj = 0)
text(0.7, 0.2, "mai[4] = fin[1] * (1 - plt[2])", cex = 0.8, col ="blue", adj = 0)


box("plot", lty = "44")
box("figure", col = "red")
rect(0, 0, 1, 1, lty = 3, border = "blue")
for(k in 0:4){
    mtext(paste0("line ", k), line = k, at = 0.3, side = 1)
}
for(k in 0:3){
    mtext(paste0("line ", k), line = k, at = 0.1, side = 2)
}
for(k in 0:1){
    mtext(paste0("line ", k), line = k, at = 0.3, side = 3)
}
for(k in 0:1){
    mtext(paste0("line ", k), line = k, side = 4)
}
text(0.05, 0.95, "Area limited by xlim and ylim", col = "blue", cex = 0.8, adj = 0)


## ---- fig.show="hold", out.width="50%", fig.width=4, fig.height=8--------------------------------------------------------------------------------------------------------------------------
par(oma = c(0, 0, 3, 0), # 윗쪽 여백 크기 조정
    mfrow = c(3, 2))
for (i in 1:6) {
  set.seed(12345)
  plot(rnorm(20), rnorm(20),
       main = paste("Plot", i))
  box("figure")
}
# 윗쪽 여백(side=3)에 텍스트 출력
mtext(side = 3, line = 1, cex = 0.8, col = "blue",
    "Muptiple plots with mfrow = c(2, 3)",
    outer = TRUE) # outer 여백 사용 여부

par(oma = c(0, 0, 3, 0),
    mfcol = c(3, 2))
for (i in 1:6) {
  set.seed(12345)
  plot(rnorm(20), rnorm(20),
       main = paste("Plot", i))
  box("figure")
}
mtext(side = 3, line = 1, cex = 0.8, col = "blue",
    "Muptiple plots with mfcol = c(3, 2)",
    outer = TRUE)




## ---- fig.show="hold", fig.width=8, fig.height=6-------------------------------------------------------------------------------------------------------------------------------------------
df_order <- expand.grid(x = 1:2,
                        y = 1:3)
set.seed(123)
idx <- sample(2:6, nrow(df_order)-1)
df_order <- df_order[c(1,idx), ]
par(mfrow = c(2, 3),
    oma = c(0, 0, 3, 0))

for (i in 0:5) {
  set.seed(123)
  par(mfg = as.numeric(df_order[i+1, ]))
  plot(rnorm(20), rnorm(20),
       main = paste("Plot", i+1))
  box("figure")
}

mtext(side = 3, line = 1, cex = 0.8, col = "blue",
    "Multiple plots by row: order in mfrow changed by mfg parameter.",
    outer = TRUE)




## ---- fig.show="hold", fig.width=8, fig.height=7-------------------------------------------------------------------------------------------------------------------------------------------
# mtcars 데이터셋
graph_array <- matrix(c(1, 1, 2, 3), nrow = 2, byrow = TRUE)
par(oma = c(0, 0 , 3, 0))
layout(mat = graph_array)
plot(mpg ~ disp, # 데이터 프레임인 경우 수식 표현도 가능
     data = mtcars,
     main = "layout 1")
hist(mtcars$disp,
     main = "layout 2")
hist(mtcars$mpg,
     main = "layout 3")
mtext(side = 3, line = 1, cex = 1, col = "blue",
      "c(1, 1): scatter plot, c(2) = histogram: dsip, c(3) = histogram: mpg",
      outer = TRUE)



## ---- message=FALSE, fig.show="hold", fig.width=8, fig.height=6----------------------------------------------------------------------------------------------------------------------------
split.screen(fig = c(2, 2)) # 화면을 2 by 2로 분할
par(oma = c(0, 0, 3, 0))
screen(n = 4)
vioplot::vioplot(mpg ~ cyl, data = mtcars,
                 main = "screen n = 4")
screen(n = 1)
hist(mtcars$mpg,
     main = "screen n = 1")
screen(n = 3)
plot(mpg ~ wt, data = mtcars,
     main = "screen n = 3")
screen(n = 2)
boxplot(mpg ~ gear, data = mtcars,
        main = "screen n = 2")
mtext(side = 3, line = 1, cex = 0.8, col = "blue",
      "Split using split.screen()",
      outer = TRUE)



## ---- message=FALSE, fig.show="hold", fig.width=10, fig.height=7---------------------------------------------------------------------------------------------------------------------------
# boxplot + violin plot
## iris 데이터 셋
par(bty = "n") # x-y 축 스타일 지정
boxplot(Sepal.Length ~ Species,
        data = iris)
new_fig <- c(0.05, 0.46, 0.4, 0.99)
par(new = TRUE,
    fig = new_fig)
vioplot::vioplot(Sepal.Length ~ Species,
                 data = iris,
                 col = "skyblue",
                 yaxt = "s",
                 ann = FALSE)



## ----oma-anatomy, echo=FALSE, fig.show="hold", fig.width=9, fig.height=6, fig.cap="Outer 여백 조정 파라미터(mar = c(2, 3, 3, 1)) Graphical parameters of R graphics package에서 발췌"------
outer_margin <- function() {
  par(las = 0)
      for(k in 0:1){
        mtext(paste0("line ", k), line = k , side = 1, cex = 0.9, outer = TRUE)
    }
    for(k in 0:2){
        mtext(paste0("line ", k), line = k, side = 2, cex = 0.9, outer = TRUE)
    }
    for(k in 0:2){
        mtext(paste0("line ", k), line = k, at = 0, side = 3, cex = 0.9, outer = TRUE)
    }
    for(k in 0:0){
        mtext(paste0("line ", k), line = k, side = 4, cex = 0.9, outer = TRUE)
    }
}

par(op)
par(oma = c(2, 3, 3, 1))
par(mfrow = c(2,2),
    mar = c(3, 3, 1, 1),
    mgp = c(3, 1, 0.2), # 축 제목 여백 조정
    bty = 'n', # box type 지정
    las = 1, # 축 레이블 스타일 지정
    lab = c(4, 3, 7))
for(k in 0:3){
    set.seed(1023)
    plot(runif(10), runif(10)
        , xlim = c(0, 1), ylim = c(0, 1)
        , xlab = "x axis", ylab = "y axis"
        )
    grid()
    # box("figure")
}
mtext(text = "Example of outer Margins", line = 0, side = 3, outer = TRUE)
par(mfrow = c(1, 1), new = TRUE)
box("figure", col = "red")
outer_margin()



## ----points-ex, fig.show="hold", fig.width=10, fig.height=6--------------------------------------------------------------------------------------------------------------------------------
# cars 데이터셋
par(mfrow = c(1, 2))
plot(dist ~ speed, data = cars,
     type = "n",
     bty = "n",
     main = "points() function example 1: cars dataset")
points(cars$speed, cars$dist,
       pch = 16,
       col = "darkgreen",
       cex = 1.5)
shapes <- 15:17 # pch 지정
plot(Petal.Length ~ Sepal.Length, data = iris,
     type = "n",
     bty = "n",
     main = "points() function example 2: iris dataset")
points(iris$Sepal.Length,
       iris$Petal.Length,
       pch = shapes[as.numeric(iris$Species)], # 각 Species에 대해 shapes 할당
       col = as.numeric(iris$Species),
       cex = 1.5)



## ----plot-linewidth, echo=FALSE, fig.show="hold", fig.width=7, fig.height=7, fig.cap="선 두께(lwd) 파라미터: Graphical parameters of R graphics package 에서 발췌"-------------------------
# clean plot area to start drawing
par(mar = rep(0, 4), lend = 1)
plot(1, 1
    , type = 'n', axes = FALSE, ann = FALSE
    , xaxs = 'i', yaxs = 'i'
    , xlim = c(0,10), ylim = c(0,10)
    , lab = c(10, 10, 7))
# grid()
text(5, 9.5, "Line width parameter (lwd)", font = 2, adj = c(0.5, 0))
for (k in 1:9){
    text(0.5, k, labels = paste0("lwd = ", k), adj = c(0, 0))
    segments(1.5, k, 9, k, lwd = k)
}


## ---- fig.show="hold", fig.width=8, fig.height=6-------------------------------------------------------------------------------------------------------------------------------------------
# 정규분포 평균=0, 분산=1
# 정규분포 평균=0, 분산=2
# 정규분포 평균=0, 분산=3
par(mar = c(3, 0, 3, 0))
x <- seq(-5, 5, 0.01)
y <- mapply(dnorm,
            list(x, x, x),
            c(0, 0, 0),
            c(1, sqrt(2), sqrt(3)))

plot(x, y[,1],
     type = "n",
     bty = "n",
     yaxt = "n",
     ann = FALSE,
     xlim = c(-5, 5))
lines(c(0, 0), c(0, max(y[,1])), lty = 2, col = "lightgray")
lines(x, y[,1], lty = 1, lwd = 2,
      col = "black")
lines(c(0.3, 2), rep(max(y[,1]), 2), lty = 1, col = "gray")
text(2.1, max(y[,1]),
     expression(paste(mu == 0, "," ~~ sigma == 1)), # 수식 표현
     adj = 0)

lines(x, y[,2], lty = 2, lwd = 2, col = "blue")
lines(c(0.3, 2), rep(max(y[, 2]), 2), lty = 1, col = "gray")
text(2.1, max(y[,2]),
     expression(paste(mu == 0, "," ~~ sigma == 2)), # 수식 표현
     adj = 0)

lines(x, y[,3], lty = 3, lwd = 2, col = "green")
lines(c(0.3, 2), rep(max(y[,3]), 2), lty = 1, col = "gray")
text(2.1, max(y[,3]),
     expression(paste(mu == 0, "," ~~ sigma == 3)), # 수식 표현
     adj = 0)
mtext("Normal distribution", side = 3, adj = 0.2, cex = 2)



## ----abline-example, fig.show="hold", fig.width=8, fig.height=6, fig.cap="abline(), lines() 함수를 이용한 회귀직선 및 오차 거리 표시 예제"-------------------------------------------------
# 회귀직선과 x, y의 평균선, 회귀직선으로부터 각 점 까지 거리를 직선 표시
## mtcars 데이터
plot(mpg ~ hp, data = mtcars,
     type = "n",
     bty = "n",
     xlim = c(50, 350),
     ylim = c(5, 40),
     main = "abline() examples with mtcars dataset",
     xlab = "Horse power",
     ylab = "Miles/gallon",
     cex.main = 1.5)
m <- lm(mpg ~ hp, data = mtcars) # 일변량 회귀모형
yhat <- predict(m) # 회귀모형의 예측값

# 회귀직선으로부터 각 관측점 까지 거리(오차) 직선 표시 함수
dist_error <- function(i) {
  lines(c(mtcars$hp[i], mtcars$hp[i]),
        c(mtcars$mpg[i], yhat[i]),
        col = "green",
        lwd = 0.8,
        lty = 1)
}
for (i in 1:nrow(mtcars)) dist_error(i)

with(mtcars,
     points(hp, mpg,
            pch = 16,
            cex = 1))
abline(m, lty = 1, lwd = 3, col = "red")
abline(h = mean(mtcars$mpg),
       lty = 2,
       col = "darkgray") # mpg 평균
abline(v = mean(mtcars$hp),
       lty = 2,
       col = "darkgray") # hp 평균
text(mean(mtcars$hp), 40,
     # text 수식 표현 참고
     bquote(paste(bar(x) == .(sprintf("%.1f", mean(mtcars$hp))))),
     adj = 0,
     pos = 4)
text(350, mean(mtcars$mpg),
     bquote(paste(bar(x) == .(sprintf("%.1f", mean(mtcars$mpg))))),
     pos = 3)




## ----arrow-type, fig.show="hold", fig.width=7, fig.height=7, fig.cap= "arrows() 함수 주요 파라미터 변경에 따른 화살표 출력 결과"-----------------------------------------------------------
par(mar = rep(0, 4))
plot(1, 1,
     type = 'n', axes = FALSE, ann = FALSE,
     xaxs = 'i', yaxs = 'i',
     xlim = c(0,11), ylim = c(0,11))
text(5.5, 10.5,
     "Type of arrows by values of angle, length, and codes",
     font = 2, # 2=bold, 3=italic, 4=bold italic
     adj = c(0.5, 0),
     cex = 1.5)

angle_val <- c(60, 90, 120)
length_val <- c(0.25, 0.1, 0.5)
code_val <- c(0, 1, 3)
for (i in 1:3) {
  arrows(1, 9-i+1, 5, 9-i+1,
         length = length_val[i])
  text(6, 9-i+1, pos = 4,
       sprintf("angle = 30, length = %.2f, code = 2",
               length_val[i]))
}

for (i in 1:3) {
  arrows(1, 6-i+1, 5, 6-i+1,
         length = 0.25,
         angle = angle_val[i])
  text(6, 6-i+1, pos = 4,
       sprintf("angle = %d, length = 0.25, code = 2",
               angle_val[i]))
}

for (i in 1:3) {
  arrows(1, 3-i+1, 5, 3-i+1,
         length = 0.25,
         angle = 30,
         code = code_val[i])
  text(6, 3-i+1, pos = 4,
       sprintf("angle = 30, length = 0.25, code = %d",
               code_val[i]))
}




## ----rectangle-coord, fig.show="hold", fig.width=7, fig.height=7, fig.cap="rect() 좌표 인수"-----------------------------------------------------------------------------------------------
# 길이와 높이가 5인 정사각형 그리기
plot(x = 1:10,
     y = 1:10,
     type = "n",
     xlab = "", ylab = "",
     main = "Rectangle coordinates used in rect()")
rect(3, 3, 8, 8,
     density = 10, # 사각형 내부를 선으로 채움
     angle = 315) # 내부 선의 기울기 각도(degree)
text(3, 3, "(xleft = 3, ybottom = 3)", adj = 0.5,  pos = 1)
text(8, 3, "(xright = 8, ybottom = 3)", adj = 0.5, pos = 1)
text(8, 8, "(xright = 8, ytop = 8)", adj = 0.5, pos = 3)
text(3, 8, "(xleft = 3, ytop = 8)", adj = 0.5, pos = 3)
grid()




## ---- fig.show="hold", fig.width=7, fig.height=7-------------------------------------------------------------------------------------------------------------------------------------------
# polygon() 사용 예시
plot(x = 0:10,
     y = 0:10,
     type = "n",
     bty = "n",
     xaxt = "n",
     yaxt = "n",
     xlab = "",
     ylab = "",
     main = "Polygon examples")

# Pentagon
theta1 <- seq(-pi, pi, length = 6)
x <- cos(theta1 + 0.5*pi) # cosine 함수
y <- sin(theta1 + 0.5*pi)
x1 <- 2*x + 2; y1 <- -2*y + 7
polygon(x1, y1)
text(2, 9.2, "Pentagon", adj = 0.5, pos = 3, cex = 1.5)

# Octagon
theta2 <- seq(-pi, pi, length = 9)
x <- cos(theta2) # cosine 함수
y <- sin(theta2)

x2 <- 2*x + 7; y2 <- -2*y + 7
polygon(x2, y2,
        col = "#05B8FF",
        bolder = "black",
        lwd = 4)
text(7, 9.2, "Octagon", adj = 0.5, pos = 3, cex = 1.5)

# 별표시
x2 <- c(2, 4/3, 0, 2/3, 0, 4/3, 2, 8/3, 4, 10/3, 4, 8/3)
y2 <- c(4, 3.0, 3, 2.0, 1, 1.0, 0, 1.0, 1,  2.0, 3, 3.0)
polygon(x2, y2,
        density = 20,
        angle = 135,
        lty = 1,
        lwd = 2)
text(2, 4.1, "Star (Jewish)", adj = 0.5, pos = 3, cex = 1.5)

# Triangle (perpendicular)
x3 <- c(5, 9, 5)
y3 <- c(0, 0, 4)
polygon(x3, y3, lwd = 3, col = "gray")
x4 <- c(5, 5.3, 5.3, 5)
y4 <- c(0, 0.0, 0.3, 0.3)
polygon(x4, y4, lwd = 3) # 직각표시
text(7, 4.1, "Triangle (perpendicular)", adj = 0.5, pos = 3, cex = 1.5)



## ----polygon-example, fig.show="hold", fig.width=8, fig.height=6, fig.cap="polygon()을 이용한 확률밀도함수 곡선 아래 면적 표시 예시"-------------------------------------------------------
# 표준정규분포 곡선 하 면적 표시
x <- seq(-3, 3, by = 0.01)
z <- dnorm(x)
plot(x, z,
     type = "n",
     bty = "n",
     xlab = expression(bold(Z)),
     ylab = "Density",
     main = "Standard normal distribution")
idx <- x > -1.5 & x < 0.7 # 해당 구간 index 설정
polygon(c(-1.5, x[idx], 0.7),
        c(0, z[idx], 0),
        col = "green",
        border = "green")
lines(x, z, lty = 1, lwd = 2)
text(x = 0.5, y = 0.15,
     bquote(P({-1.5 < Z} < 0.7 ) ==
              .(sprintf("%.3f", pnorm(0.7) - pnorm(-1.5)))),
     # pnorm = P(Z <= c), 평균=0, 분산=1 인 경우
     adj = 1)



## ---- eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## text(x, # x-좌표값
##      y, # y-좌표값
##      label, # 입력할 텍스트 문자열
##      adj, # 원점 좌표를 기준으로 텍스트 문자열 자리 맞춤
##           # 0 - 1 사이 값은 수평 맞추기 지정
##           # 0=오른쪽, 0.5=가운데 정렬, 1=왼쪽 정렬 (원점 기준)
##      pos, # adj를 단순화하여 텍스트 자리 맞춤
##           # 1=bottom, 2=left, 3=top, 4=right,
##      srt  # 문자열 회전(in degree)
##      ...
##      )
## 


## ----text-adj-par, echo=FALSE, fig.show='hold', out.width='80%', fig.cap="text() 함수에서 adj 파라미터 값에 따른 텍스트 위치: AIMS-R-users 에서 발췌"--------------------------------------
knitr::include_graphics('figures/graphics-adjPlot.png', dpi = NA)


## ----text-pos-par, echo=FALSE, fig.show='hold', out.width='80%', fig.cap="text() 함수에서 pos 파라미터 값에 따른 텍스트 위치: AIMS-R-users 에서 발췌"--------------------------------------
knitr::include_graphics('figures/graphics-posPlot.png', dpi = NA)


## ----text-srt-par, echo=FALSE, fig.show='hold', out.width='80%', fig.cap="text() 함수에서 srt 파라미터 값에 따른 텍스트 위치: AIMS-R-users 에서 발췌"--------------------------------------
knitr::include_graphics('figures/graphics-srtPlot.png', dpi = NA)


## ---- eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## mtext(
##   text, # 입력할 텍스트 문자열
##   side, # 텍스트 문자열이 출력되는 여백 지정
##         # 1=bottom, 2=left, 3=top, 4=right
##   line, # 지정 여백에서 텍스트 출력 위치 지정
##   outer, # outer 여백 사용 여부
##   at,  # line 내에서 텍스트 열 위치(좌표축 기준) 지정
##   adj, # text() 함수의 adj 파라미터와 동일
##   ...
## )
## 


## ----mtext-anatomy, fig.show="hold", fig.width=9, fig.height=6-----------------------------------------------------------------------------------------------------------------------------
par(mar = c(4, 4, 4, 4),
    oma = c(4, 0, 0, 0))
set.seed(1345)
plot(rnorm(20),
     type = "o",
     xlab = "", ylab = "")
# side = 3 (top), line=0, 1, 2, 3 변경
for (i in 0:4) {
  mtext(paste("Side = 3, line =", i),
        side = 3,
        line = i)
}
# side = 3 (top), outer 여백 사용, line=0, 1, 2, 3 변경
for (i in 0:4) {
  mtext(paste("Side = 1, outer = TRUE, line =", i),
        side = 1,
        line = i,
        outer = TRUE)
}

# adj 인수 조정
adj_par <- c(0, 0.5, 1)
for (i in 1:3) {
  mtext(sprintf("Side = 1, line = %d, adj = %.1f",
                i, adj_par[i]),
  side = 1, line = i, adj = adj_par[i])
}

# side = 2 (left)
for (i in 1:3) {
  mtext(sprintf("Side = 2, line = %d, adj = %.1f",
                i, adj_par[i]),
  side = 2, line = i, adj = adj_par[i])
}

# side = 4 (right), at 조정
at_val <- c(-1, 0, 1)
for (i in 1:3) {
  mtext(sprintf("Side = 4, line = %d, at = %.1f",
                i, adj_par[i]),
  side = 4, line = i, at = at_val[i])
}
mtext("mtext parameter check",
      col = "blue",
      cex = 0.8,
      line = 0,
      adj = 0)





## ---- fig.show="hold", fig.width=9, fig.height=6-------------------------------------------------------------------------------------------------------------------------------------------
plot(Petal.Length ~ Sepal.Length, data = iris,
     type = "n",
     bty = "n",
     main = "points() function example 2: iris dataset")
points(iris$Sepal.Length,
       iris$Petal.Length,
       pch = shapes[as.numeric(iris$Species)], # 각 Species에 대해 shapes 할당
       col = as.numeric(iris$Species),
       cex = 1.5)
legend("bottomright", legend = unique(iris$Species), pch = 15:17, col = 1:3)
legend(4.5, 6, legend = unique(iris$Species), pch = 15:17, col = 1:3)

legend("top",
       legend = unique(iris$Species),
       pch = 15:17, col = 1:3,
       pt.cex = 3, # legend 점 크기 조정
       ncol = 3) # # legend 영역 열 개수 지정



## ----expression-math, echo=FALSE, fig.show='hold', out.width='50%', fig.height=8, fig.width=6, fig.cap="R expression() 함수 내 수식 표현 방법"---------------------------------------------
knitr::include_graphics('figures/expression-table-01.png', dpi = NA)
knitr::include_graphics('figures/expression-table-02.png', dpi = NA)

knitr::include_graphics('figures/expression-table-03.png', dpi = NA)
knitr::include_graphics('figures/expression-table-04.png', dpi = NA)

knitr::include_graphics('figures/expression-table-05.png', dpi = NA)


## ----greek-letters, echo=FALSE, fig.show='hold', fig.width=8, fig.height=7, fig.cap="R 그리스 문자 표현"-----------------------------------------------------------------------------------
knitr::include_graphics('figures/greek-letters.png', dpi = NA)



## ---- fig.show="hold", fig.width=8, fig.height=6-------------------------------------------------------------------------------------------------------------------------------------------
# 수식 표현 예시 expression() + paste()
par(cex = 1.5 ,
    cex.lab = 1.2)
set.seed(202005)
x <- rnorm(10, 25, 3)
y <- rnorm(10, 25, 3)

plot(x, y,
     type = "p",
     axes = TRUE,
     ann = FALSE,
     bty = "n")
mtext(expression(paste("Temperature", ~(degree*C))),
      side = 1, line = 3, cex = 1.5)
mtext(expression(paste("Respiration", ~(mL ~O[2] ~ h^-1))),
      side = 2,
      line = 3,
      cex = 1.5)



## ---- eval=FALSE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## par(cex = 1.5)
## plot(0:6, 0:6,
##      type = "n",
##      bty = "o",
##      xaxt = "n",
##      yaxt = "n",
##      ann = FALSE)
## text(0.3, 5.8, "Normal distribution:", adj = 0)
## text(0.3, 4.8, expression(paste(f, "(", x, ";", list(mu, sigma), ")"
##                                 == frac(1, sigma*sqrt(2*pi))*~~exp *
##                                   bgroup('(', -frac((x-mu)^2, 2*sigma^2), ')') )),
##      adj = 0)
## text(4, 5.8, "Binomial distribution:", adj = 0)
## text(4, 4.8, expression(paste(f, "(", x, ";", list(n, p), ")"
##                                 == bgroup("(", atop(n, x) ,")")*p^x*(1-p)^{n-x})),
##      adj = 0)
## 
## text(0.3, 3.5, "Matrix:", adj = 0)
## text(0.3, 2.5,
##      expression(bold(X) == bgroup("[", atop(1 ~~ 2 ~~ 3, 4 ~~ 5 ~~ 6), "]")),
##      adj = 0)
## text(2, 3.5, "Multiple regression formula:",
##      adj = 0)
## text(2, 2.5,
##      expression(paste(y[i] == beta[0] + beta[1]*x[1] + beta[2]*x[2] + epsilon[i]~~
##                       "where", ~~i == list(1, ldots, n))),
##      adj = 0)
## 
## text(2, 1.5, "Regression equation:", adj = 0)
## text(2, 0.5,
##      expression(hat(bold(beta)) == bgroup("(", bold(X)^T*bold(X), ")")^-1*bold(X)^T*bold(y)),
##      adj = 0)
## 


## ----math-example, echo=FALSE, fig.show='hold', out.width='100%', fig.width=8, fig.height=6, fig.cap="R 그래픽 수식 표현 예시"-------------------------------------------------------------
knitr::include_graphics('figures/math-example.png', dpi = NA)

