## ---- echo=FALSE, message=FALSE---------------------------------------------------------------------------------------------------
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

## ---- echo=FALSE, message=FALSE, warning=FALSE, fig.show="hold", fig.width=8, fig.height=6, fig.cap="Anscombe's quartet: https://goo.gl/Ugv3Cz 에서 스크립트 발췌"----
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



## ---- fig.align='center', echo=FALSE, fig.show='hold', fig.width=8, fig.height=6, fig.show="hold", fig.cap="R 그래프영역"---------
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

## ---- fig.width=9, fig.heigth=12, fig.show="hold"---------------------------------------------------------------------------------
#각 클래스에 적용되는 plot() 함수 리스트
methods(plot)

#예시 1: 객체 클래스가 데이터 프레임인 경우
# mtcars 데이터 예시
class(mtcars)
plot(mtcars)



## ---- message=FALSE, fig.width=9, fig.height=8, fig.show="hold"-------------------------------------------------------------------
# 예시2: lm()으로 도출된 객체(list)
## 연비(mpg)를 종속 변수, 배기량(disp)을 독립변수로 한 회귀모형
## lm() 함수 사용 -> 객체 클래스는 lm

mod <- lm(mpg ~ disp, data = mtcars)
class(mod)
par(mfrow = c(2, 2)) # 4개 도표를 한 화면에 표시(2행, 2열)
plot(mod)
dev.off() # 활성화된 그래프 장치 닫기



## ---- message=FALSE, fig.width=9, fig.height=8, fig.show="hold"-------------------------------------------------------------------
# 예시3: 테이블 객체
class(Titanic)
plot(Titanic)



## ---- out.width="50%"-------------------------------------------------------------------------------------------------------------
# 예시1: 데이터 객체를 하나만 인수로 받는 경우
# -> x축은 객체의 색인이고, x의 데이터는 y 좌표에 매핑
x <- mtcars$disp
y <- mtcars$mpg

plot(x); plot(y)


## ---- fig.width = 8, fig.height=6-------------------------------------------------------------------------------------------------
# 두개의 객체를 인수로 받은 경우
# -> 2차원 산점도 출력

plot(x, y)



## ---- eval=FALSE------------------------------------------------------------------------------------------------------------------
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


## ---- fig.width=10, fig.height=6--------------------------------------------------------------------------------------------------
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



## ---- fig.show="hold"-------------------------------------------------------------------------------------------------------------
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



## ---- fig.show="hold", fig.width=10, fig.height=7---------------------------------------------------------------------------------
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



## ---- fig.show="hold", fig.width=8, fig.height=8----------------------------------------------------------------------------------
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





## ---- fig.show="hold", fig.width=7, fig.height=7----------------------------------------------------------------------------------
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



## ---- fig.show="hold", fig.width=9, fig.height=7----------------------------------------------------------------------------------
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




## ---- fig.show="hold", fig.width=7, fig.height=7----------------------------------------------------------------------------------
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



## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='100%'------------------------------------------------------------
knitr::include_graphics('figures/r-graphic-palette.png', dpi = NA)


## ---- fig.show="hold", fig.width=8, fig.height=6----------------------------------------------------------------------------------
# car 패키지 설치
# install.packages("car")
# require(car)
car::scatterplot(mpg ~ disp, data = mtcars)



## ---- fig.show="hold", fig.width=8, fig.heigh=6-----------------------------------------------------------------------------------
# help(scatterplot) 참고
car::scatterplot(mpg ~ disp, data = mtcars, 
                 regLine = list(method = lm, lty = 1, col = "red"), 
                 col = "black", cex = 2, pch = 16)



## ---- fig.show="hold", fig.width=8, fig.heigh=8-----------------------------------------------------------------------------------
# iris dataset
plot(iris)



## ---- fig.show="hold", fig.width=8, fig.heigh=8-----------------------------------------------------------------------------------
# iris dataset
car::scatterplotMatrix(iris, col = "black")



## ---- fig.show="hold", fig.width=8, fig.heigh=8-----------------------------------------------------------------------------------
# help(scatterplotMatrix)
car::scatterplotMatrix(iris, col = c("red", "blue", "green"), 
                       smooth = FALSE, 
                       groups = iris$Species, 
                       by.groups = FALSE, 
                       regLine = list(method = lm, lwd = 1, col = "gray"), 
                       pch = (15:17))



## ---- fig.show="hold", fig.width=8, fig.heigh=6-----------------------------------------------------------------------------------
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



## ---- fig.show="hold", fig.width=8, fig.heigh=6-----------------------------------------------------------------------------------
# matplot 도표
par(mfrow = c(1, 2))
matplot(X, type = "l", 
        lwd = 2, 
        main = "matplot() without x")
matplot(x, X, type = "l", 
        lwd = 2, 
        main = "matplot() with x")



## ---- eval=FALSE------------------------------------------------------------------------------------------------------------------
## hist(
##   x, # vector 객체
##   breaks, # 빈도 계산을 위한 구간
##   freq, # y축 빈도 또는 밀도(density) 여부
##   col, # 막대 색상 지정
##   border, # 막대 테두리 색 지정
##   labels, # 막대 위 y 값 레이블 출력 여부
##   ...
## )


## ---- fig.show="hold", fig.width=8, fig.heigh=8-----------------------------------------------------------------------------------
# airquality 데이터 셋
# help(airquality) 참고
glimpse(airquality)
temp <- airquality$Temp
hist(temp)



## ---------------------------------------------------------------------------------------------------------------------------------
h <- hist(temp, plot = FALSE) # 그래프를 반환하지 않음
h


## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.heigh=8--------------------------------------------------------------------

hist(temp,
main="La Guardia Airport 일중 최고 기온",
xlab = "온도",
ylab = "밀도",
xlim = c(50,100),
col = "orange",
freq = FALSE
)



## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.heigh=8--------------------------------------------------------------------
hist(temp,
main = "La Guardia Airport 일중 최고 기온",
xlab = "온도",
ylab = "빈도",
xlim = c(50,100),
col = "orange",
labels = TRUE
)



## ---- warning=FALSE, fig.show="hold", fig.width=10, fig.height=7------------------------------------------------------------------
op <- par(mfrow = c(1, 2))
hist(temp, breaks = 4, main = "breaks = 4")
hist(temp, breaks = 15, main = "breaks = 15")
par(op); dev.off()


## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.heigh=6--------------------------------------------------------------------
x = c(1,2,2,1,3,3,1,5)
par(mfrow = c(1, 2))
hist(x); barplot(x)




## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.heigh=6--------------------------------------------------------------------
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



## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.heigh=7--------------------------------------------------------------------
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


