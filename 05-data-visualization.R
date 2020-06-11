## ---- echo=FALSE, message=FALSE-----------------------------------------------------------------------
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



## ----r-graphic-layout, fig.align='center', echo=FALSE, fig.show='hold', fig.width=8, fig.height=6, fig.show="hold", fig.cap="R 그래프영역"----
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

## ---- fig.width=9, fig.heigth=12, fig.show="hold"-----------------------------------------------------
#각 클래스에 적용되는 plot() 함수 리스트
methods(plot)

#예시 1: 객체 클래스가 데이터 프레임인 경우
# mtcars 데이터 예시
class(mtcars)
plot(mtcars)



## ---- message=FALSE, fig.width=9, fig.height=8, fig.show="hold"---------------------------------------
# 예시2: lm()으로 도출된 객체(list)
## 연비(mpg)를 종속 변수, 배기량(disp)을 독립변수로 한 회귀모형
## lm() 함수 사용 -> 객체 클래스는 lm

mod <- lm(mpg ~ disp, data = mtcars)
class(mod)
par(mfrow = c(2, 2)) # 4개 도표를 한 화면에 표시(2행, 2열)
plot(mod)
dev.off() # 활성화된 그래프 장치 닫기



## ---- message=FALSE, fig.width=9, fig.height=8, fig.show="hold"---------------------------------------
# 예시3: 테이블 객체
class(Titanic)
plot(Titanic)



## ---- out.width="50%"---------------------------------------------------------------------------------
# 예시1: 데이터 객체를 하나만 인수로 받는 경우
# -> x축은 객체의 색인이고, x의 데이터는 y 좌표에 매핑
x <- mtcars$disp
y <- mtcars$mpg

plot(x); plot(y)


## ---- fig.width = 8, fig.height=6---------------------------------------------------------------------
# 두개의 객체를 인수로 받은 경우
# -> 2차원 산점도 출력

plot(x, y)



## ---- eval=FALSE--------------------------------------------------------------------------------------
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


## ---- fig.width=10, fig.height=6----------------------------------------------------------------------
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



## ---- fig.show="hold"---------------------------------------------------------------------------------
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



## ---- fig.show="hold", fig.width=10, fig.height=7-----------------------------------------------------
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



## ----plot-linetype, fig.show="hold", fig.width=8, fig.height=8, fig.cap="lty 파라미터 값에 따른 선 형태"----
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





## ----plot-symbol, fig.show="hold", fig.width=7, fig.height=7, fig.cap="R graphics 점 표현 기호 및 대응 번호"----
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



## ---- fig.show="hold", fig.width=9, fig.height=7------------------------------------------------------
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




## ---- fig.show="hold", fig.width=7, fig.height=7------------------------------------------------------
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



## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='100%'--------------------------------
knitr::include_graphics('figures/r-graphic-palette.png', dpi = NA)


## ---- fig.show="hold", fig.width=8, fig.height=6------------------------------------------------------
# car 패키지 설치
# install.packages("car")
# require(car)
car::scatterplot(mpg ~ disp, data = mtcars)



## ---- fig.show="hold", fig.width=8, fig.heigh=6-------------------------------------------------------
# help(scatterplot) 참고
car::scatterplot(mpg ~ disp, data = mtcars, 
                 regLine = list(method = lm, lty = 1, col = "red"), 
                 col = "black", cex = 2, pch = 16)



## ---- fig.show="hold", fig.width=8, fig.heigh=8-------------------------------------------------------
# iris dataset
plot(iris)



## ---- fig.show="hold", fig.width=8, fig.heigh=8-------------------------------------------------------
# iris dataset
car::scatterplotMatrix(iris, col = "black")



## ---- fig.show="hold", fig.width=8, fig.heigh=8-------------------------------------------------------
# help(scatterplotMatrix)
car::scatterplotMatrix(iris, col = c("red", "blue", "green"), 
                       smooth = FALSE, 
                       groups = iris$Species, 
                       by.groups = FALSE, 
                       regLine = list(method = lm, lwd = 1, col = "gray"), 
                       pch = (15:17))



## ---- fig.show="hold", fig.width=8, fig.heigh=6-------------------------------------------------------
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



## ---- fig.show="hold", fig.width=8, fig.heigh=6-------------------------------------------------------
# matplot 도표
par(mfrow = c(1, 2))
matplot(X, type = "l", 
        lwd = 2, 
        main = "matplot() without x")
matplot(x, X, type = "l", 
        lwd = 2, 
        main = "matplot() with x")



## ---- eval=FALSE--------------------------------------------------------------------------------------
## hist(
##   x, # vector 객체
##   breaks, # 빈도 계산을 위한 구간
##   freq, # y축 빈도 또는 밀도(density) 여부
##   col, # 막대 색상 지정
##   border, # 막대 테두리 색 지정
##   labels, # 막대 위 y 값 레이블 출력 여부
##   ...
## )


## ---- fig.show="hold", fig.width=8, fig.heigh=8-------------------------------------------------------
# airquality 데이터 셋
# help(airquality) 참고
glimpse(airquality)
temp <- airquality$Temp
hist(temp)



## -----------------------------------------------------------------------------------------------------
h <- hist(temp, plot = FALSE) # 그래프를 반환하지 않음
h


## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.heigh=8----------------------------------------
par(family = "nanumgothic")
hist(temp,
main="La Guardia Airport 일중 최고 기온",
xlab = "온도",
ylab = "밀도",
xlim = c(50,100),
col = "orange",
freq = FALSE
)



## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.heigh=8----------------------------------------
par(family = "nanumgothic")
hist(temp,
main = "La Guardia Airport 일중 최고 기온",
xlab = "온도",
ylab = "빈도",
xlim = c(50,100),
col = "orange",
labels = TRUE
)



## ---- warning=FALSE, fig.show="hold", fig.width=10, fig.height=7--------------------------------------
op <- par(mfrow = c(1, 2))
hist(temp, breaks = 4, main = "breaks = 4")
hist(temp, breaks = 15, main = "breaks = 15")
par(op); dev.off()


## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.heigh=6----------------------------------------
x = c(1,2,2,1,3,3,1,5)
par(mfrow = c(1, 2))
hist(x); barplot(x)




## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.heigh=6----------------------------------------
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



## ---- warning=FALSE, fig.show="hold", fig.width=8, fig.height=7---------------------------------------
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



## ---- warning=FALSE, fig.show="hold", fig.width=9, fig.height=6---------------------------------------
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



## ---- eval=FALSE--------------------------------------------------------------------------------------
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


## ----boxplot-ex, warning=FALSE, fig.show="hold", fig.width=8, fig.height=8----------------------------
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



## ----vioplot-ex, warning=FALSE, fig.show="hold", fig.width=8, fig.height=8----------------------------
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


## ---- echo = FALSE, fig.show="hold", fig.width=9, fig.height=7----------------------------------------
# require(vcd)
mosaicplot(~ Survived + Sex, data = Titanic, 
           shade = TRUE, 
           cex = 1.1)
mar_tab <- c(margin.table(Titanic, c(2, 4)))
text(0.3, 0.5, labels = mar_tab[1], col = "white", cex = 2)
text(0.68, 0.7, labels = mar_tab[3], col = "white", cex = 2)
text(0.3, 0.016, labels = mar_tab[2], col = "white", cex = 2)
text(0.68, 0.2, labels = mar_tab[4], col = "white", cex = 2)



## ---- eval=FALSE--------------------------------------------------------------------------------------
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


## ---- fig.show="hold", fig.width = 10, fig.height=7---------------------------------------------------
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


## ---- fig.show="hold", fig.width = 10, fig.height=7---------------------------------------------------
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


## -----------------------------------------------------------------------------------------------------
# 그래프 파라미터 조회 
# 처음 12개 파라미터들에 대해서만 조회
unlist(par()) %>% head(12)

# 파라미터 이름으로 값 추출
par("mar")


## ----tab-05-01, echo=FALSE----------------------------------------------------------------------------
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




## ----layout-par, echo=FALSE, fig.show="hold", out.width="50%", fig.cap="레이아웃 파라미터. AIMS-R-Users 에서 발췌"----
knitr::include_graphics('figures/graphics-figureAnatomy1.png', dpi = NA)
knitr::include_graphics('figures/graphics-figureAnatomy2.png', dpi = NA)


## 아래 `par()` 함수의 파라미터 값에 대한 도표 생성을 위한 R 스크립트는 [Graphical parameters of R graphics package](http://rstudio-pubs-static.s3.amazonaws.com/315576_85cccd774c29428ba46969316cbc76c0.html)에서 참고 및 발췌

## 

## ---- echo=FALSE, fig.show="hold", fig.width=8, fig.height=7, fig.show="hold"-------------------------
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



## ---- echo=FALSE, fig.show="hold", fig.width=8, fig.height=7------------------------------------------
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



## ----fig-anatomy, fig.show="hold", fig.width=7, fig.height=7, fig.cap="fig 인수 조정 예시: Graphical parameters of R graphics package에서 발췌"----
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



## ----mar-anatomy, echo=FALSE, fig.show="hold", fig.width=7, fig.height=7, fig.cap="Figure 영역에서 기본 여백: Graphical parameters of R graphics package 에서 발췌"----
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


## ---- fig.show="hold", out.width="50%", fig.width=4, fig.height=8-------------------------------------
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




## ---- fig.show="hold", fig.width=8, fig.height=6------------------------------------------------------
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




## ---- fig.show="hold", fig.width=8, fig.height=7------------------------------------------------------
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



## ---- message=FALSE, fig.show="hold", fig.width=8, fig.height=6---------------------------------------
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



## ---- message=FALSE, fig.show="hold", fig.width=10, fig.height=7--------------------------------------
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



## ----oma-anatomy, echo=FALSE, fig.show="hold", fig.width=9, fig.height=6, fig.cap="Outer 여백 조정 파라미터(mar = c(2, 3, 3, 1)) Graphical parameters of R graphics package에서 발췌"----
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



## ----points-ex, fig.show="hold", fig.width=10, fig.height=6-------------------------------------------
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



## ----plot-linewidth, echo=FALSE, fig.show="hold", fig.width=7, fig.height=7, fig.cap="선 두께(lwd) 파라미터: Graphical parameters of R graphics package 에서 발췌"----
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


## ---- fig.show="hold", fig.width=8, fig.height=6------------------------------------------------------
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



## ----abline-example, fig.show="hold", fig.width=8, fig.height=6, fig.cap="abline(), lines() 함수를 이용한 회귀직선 및 오차 거리 표시 예제"----
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




## ----arrow-type, fig.show="hold", fig.width=7, fig.height=7, fig.cap= "arrows() 함수 주요 파라미터 변경에 따른 화살표 출력 결과"----
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




## ----rectangle-coord, fig.show="hold", fig.width=7, fig.height=7, fig.cap="rect() 좌표 인수"----------
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




## ---- fig.show="hold", fig.width=7, fig.height=7------------------------------------------------------
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
        border = "black",
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



## ----polygon-example, fig.show="hold", fig.width=8, fig.height=6, fig.cap="polygon()을 이용한 확률밀도함수 곡선 아래 면적 표시 예시"----
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



## ---- eval=FALSE--------------------------------------------------------------------------------------
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


## ----text-adj-par, echo=FALSE, fig.show='hold', out.width='80%', fig.cap="text() 함수에서 adj 파라미터 값에 따른 텍스트 위치: AIMS-R-users 에서 발췌"----
knitr::include_graphics('figures/graphics-adjPlot.png', dpi = NA)


## ----text-pos-par, echo=FALSE, fig.show='hold', out.width='80%', fig.cap="text() 함수에서 pos 파라미터 값에 따른 텍스트 위치: AIMS-R-users 에서 발췌"----
knitr::include_graphics('figures/graphics-posPlot.png', dpi = NA)


## ----text-srt-par, echo=FALSE, fig.show='hold', out.width='80%', fig.cap="text() 함수에서 srt 파라미터 값에 따른 텍스트 위치: AIMS-R-users 에서 발췌"----
knitr::include_graphics('figures/graphics-srtPlot.png', dpi = NA)


## ---- eval=FALSE--------------------------------------------------------------------------------------
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


## ----mtext-anatomy, fig.show="hold", fig.width=9, fig.height=6----------------------------------------
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





## ---- fig.show="hold", fig.width=9, fig.height=6------------------------------------------------------
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



## ----expression-math, echo=FALSE, fig.show='hold', out.width='50%', fig.height=8, fig.width=6, fig.cap="R expression() 함수 내 수식 표현 방법"----
knitr::include_graphics('figures/expression-table-01.png', dpi = NA)
knitr::include_graphics('figures/expression-table-02.png', dpi = NA)

knitr::include_graphics('figures/expression-table-03.png', dpi = NA)
knitr::include_graphics('figures/expression-table-04.png', dpi = NA)

knitr::include_graphics('figures/expression-table-05.png', dpi = NA)


## ----greek-letters, echo=FALSE, fig.show='hold', fig.width=8, fig.height=7, fig.cap="R 그리스 문자 표현"----
knitr::include_graphics('figures/greek-letters.png', dpi = NA)



## ---- fig.show="hold", fig.width=8, fig.height=6------------------------------------------------------
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



## ---- eval=FALSE, tidy=FALSE--------------------------------------------------------------------------
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
##                                   bgroup('(', -frac((x-mu)^2,
##                                                     2*sigma^2), ')')
##                                 )),
##      adj = 0)
## text(4, 5.8, "Binomial distribution:", adj = 0)
## text(4, 4.8, expression(paste(f, "(", x, ";", list(n, p), ")"
##                                 == bgroup("(", atop(n, x) ,")")
##                               *p^x*(1-p)^{n-x})),
##      adj = 0)
## 
## text(0.3, 3.5, "Matrix:", adj = 0)
## text(0.3, 2.5,
##      expression(bold(X) == bgroup("[", atop(1 ~~ 2 ~~ 3,
##                                             4 ~~ 5 ~~ 6), "]")),
##      adj = 0)
## text(2, 3.5, "Multiple regression formula:",
##      adj = 0)
## text(2, 2.5,
##      expression(paste(y[i] == beta[0] + beta[1]*x[1] +
##                         beta[2]*x[2] + epsilon[i]~~
##                       "where", ~~i == list(1, ldots, n))),
##      adj = 0)
## 
## text(2, 1.5, "Regression equation:", adj = 0)
## text(2, 0.5,
##      expression(hat(bold(beta)) == bgroup("(", bold(X)^T*bold(X),
##                                           ")")^-1*bold(X)^T*bold(y)),
##      adj = 0)
## 


## ----math-example, echo=FALSE, fig.show='hold', out.width='100%', fig.width=8, fig.height=6, fig.cap="R 그래픽 수식 표현 예시"----
knitr::include_graphics('figures/math-example.png', dpi = NA)


## ----save-graph---------------------------------------------------------------------------------------
# save-example.png에 cars 산점도 저장
png("figures/save-example.png")
plot(cars)
dev.off()



## **Prerequisites**: tidyverse 패키지 또는 ggplot2 패키지 읽어오기: `require(tidyverse)` 또는 `require(ggplot2)` 실행

## 


## **Grammar of graphics**: 그래프를 구현하기 위한 일관적인 체계로 그래프를 데이터, 스케일, 레이어, 좌표 등과 같은 의미론적 요소(sementic components) 로 나눔


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%', fig.cap=cap--------------------
cap <- "ggplot의 grammar of graphics 주요 구성 요소"
knitr::include_graphics('figures/grammar-graphics-intro.png', dpi = NA)


## ----base-barplot-a, fig.width=7, fig.height=5, fig.show="hold", fig.cap="R 기본 barplot() 생성 그래프"----
# R 기본 데이터셋: ToothGrowth
ToothGrowth %>% 
  group_by(supp, dose) %>% 
  summarise(mean = mean(len)) %>% 
  mutate(dose = factor(dose, 
                       ordered = TRUE))-> tg_long
tg_long %>% 
  spread(supp, mean) %>% 
  column_to_rownames("dose") %>% # 열 값을 열이름으로 변환(in tibble 패키지)
  as.matrix -> tg_mat

# R graphics: barplot() 사용
barplot(tg_mat, beside = TRUE)



## ----base-barplot-b, fig.width=7, fig.height=5, fig.show="hold", fig.cap="R 기본 barplot() 생성 그래프: 데이터 전치"----
# tg_mat 행렬 전치
barplot(t(tg_mat), beside = TRUE)



## ----base-lineplot, fig.width=7, fig.height=5, fig.show="hold", fig.cap="R 기본 선 그래프: plot(), lines() 함수 사용"----
plot(tg_mat[,1], type="l", col = "blue")
lines(tg_mat[,2], type="l", col = "black")



## ----ggplot-bar-intro-a, fig.widgh=7, fig.height=5, fig.show="hold", fig.cap="ggplot()과 geom_bar()을 이용한 막대 도표"----
# require(ggplot2)
ggplot(data = tg_long, 
       aes(y = mean)) -> gmap # 기본 mapping 유지를 위해 
                              # ggplot 클래스 객체 저장
gmap + 
  geom_bar(aes(x = supp, fill = dose), 
           stat = "identity", # 데이터 고유값을 막대 높이로 사용
           position = "dodge") # 막대 위치 조정(beside 조건과 유사)


## ----ggplot-bar-intro-b, fig.width=7, fig.height=5, fig.show="hold", fig.cap="x와 fill의 mapping 변경"----
gmap + 
  geom_bar(aes(x = dose, fill = supp), 
           stat = "identity", 
           position = "dodge")


## ----ggplot-line-intro, fig.width=7, fig.height=5, fig.show="hold", fig.cap="geom_line()을 이용한 선 그래프 생성"----
gmap + 
  geom_line(aes(x = dose, 
                group = supp, 
                color = supp), 
            size = 1)
  


## ---- eval=FALSE--------------------------------------------------------------------------------------
## ggplot(data = <DATA>) +
##   <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>)) +
##   <SCALE_FUNCTION> +
##   <LABEL or GUIDES> +
##   <ANNOTATION> +
##   <THEME>
## 


## ggplot 계열 함수에서 범주형 변수(categorical variable)은 이산형(**discrete**), 수치형 변수(numeric variable)을 연속형(**continuous**)이라고 명칭함.

## 

## ---- eval=FALSE--------------------------------------------------------------------------------------
## # ggplot()을 이용한 ggplot 생성
## # 표현식 1
## ggplot(data = <DATA>, # 데이터 프레임, 티블 객체
##        mapping = aes(x = <X-axis>,
##                      y = <Y-axis>,
##                      color = <색 속성을 부여할 변수 이름>,
##                      fill = <면의 색 속성을 부여할 변수 이름>,
##                      group = <group 변수 지정>
##                              # 보통 선 그래프 작성 시 이을 선에 대한
##                              # 그룹을 지정하기 위해 사용
##                      group
##                      ...)) +
##   <GEOM_FUNCTION>
## # 표현식 2
## ggplot(data = <DATA>) +
##   aes(...) +
##   <GEOM_FUNCTION>(mapping = aes(...))
## 
## # 표현식 3
## ggplot(data = <DATA>) +
##   <GEOM_FUNCTION>(mapping = aes(x, y, ...))
## 
## 
## # 표현식 4
## <GGPLOT_OBJECT> <- ggplot(data = <DATA>)
## <GGPLOT_OBJECT> +
##   <GEOM_FUNCTION>(mapping = aes(...))
## 


## ----ggplot-begin, eval=FALSE-------------------------------------------------------------------------
## # cars 데이터셋
## ## ggplot() 내에 aes() 지정
## ggplot(data = cars,
##        aes(x = speed, y = dist)) +
##   geom_point()
## 
## ## aesthetic을 ggplot() 함수 밖에서 지정
## ggplot(data = cars) +
##   aes(x = speed, y = dist) +
##   geom_point()
## 
## ## geom 계열 함수 내에서 asthetic 지정
## ggplot(data = cars) +
##   geom_point(aes(x = speed, y = dist))
## 
## ## ggplot 객체 생성
## gp <- ggplot(data = cars); gp
## 
## gp <- gp +
##   aes(x = speed, y = dist); gp
## 
## gp + geom_point()
## 
## ## 참고: R 기본 plot()의 결과는 객체로 저장되지 않음
## grph <- plot(cars); grph
## 
## 


## ---- out.width="50%", fig.width=7, fig.height=5, fig.show="hold", message=FALSE----------------------
# 막대도표 예시
# `aes()` 함수 외부에서 사용 시 단일 값을 입력
gpcol <- ggplot(data = mpg, aes(x = class))
gpcol + geom_bar() + 
  labs(title = "Default geom_bar()") # 그래프 제목 지정

gpcol + geom_bar(fill = "navy") + 
  labs(title = "fill = 'navy'")
  
  


## ---- out.width="50%", fig.width=7, fig.height=5, fig.show="hold", message=FALSE----------------------
# 막대도표 예시
gpcol + geom_bar(color = "red") + 
  labs(title = "color = 'red'")

gpcol + geom_bar(color = "red", fill = "white")+ 
    labs(title = "color = 'red', fill = 'white'")



## ---- out.width="50%", fig.width=7, fig.height=5, fig.show="hold", message=FALSE----------------------
# 연료 타입에 따라 면 색 지정
gpcol + 
  geom_bar(aes(fill = fl)) + 
  labs(title = "Filled by fuel types (fl)")

# 연료 타입에 따라 막대 선 색 지정
gpcol + 
  geom_bar(aes(color = fl)) + 
  labs(title = "Colored by fuel types (fl)")



## ---- out.width="50%", fig.width=7, fig.height=5, fig.show="hold", message=FALSE----------------------
# alpha: 0-1 사이 값을 갖고 투명도 지정
# 주로 aes() 함수 밖에서 사용됨
set.seed(20200605)
df1 <- tibble(
  x = rnorm(5000), 
  y = rnorm(5000)
)

gpalpha <- ggplot(data = df1, aes(x, y))
gpalpha + geom_point() + 
  labs(title = "alpha = 1") 
gpalpha + geom_point(alpha = 0.1) + 
  labs(title = "alpha = 0.1")



## ---- out.width="50%", fig.width=7, fig.height=5, fig.show="hold", message=FALSE----------------------
# 다중 집단에 하나의 aesthetic만 적용한 경우
## gapminder 데이터셋
gapm <- read_csv("dataset/gapminder/gapminder_filter.csv")
gapm_filter <- gapm %>% 
  filter(grepl("Asia", region))
gpgroup <- ggplot(data = gapm_filter, 
                  aes(x = year, y = life_expectancy))

gpgroup + geom_line(size = 0.5, alpha = 0.2) 
gpgroup_l <- gpgroup + geom_line(aes(group = country), 
                                 size = 0.5, alpha = 0.2)
gpgroup_l



## ---- out.width="50%", fig.width=7, fig.height=5, fig.show="hold", message=FALSE----------------------
# 전체 아시아 국가의 평균 추세선 
## geom_line과 geom_smooth 모두 group을 country로 지정
gpgroup_l + 
  geom_smooth(aes(group = country), 
              method = "loess", 
              size = 0.5, 
              color = "blue", 
              se = FALSE)

## 모든 국가에 가장 적합한 하나의 곡선으로 fitting
gpgroup_l + 
  geom_smooth(aes(group = 1), 
              method = "loess", 
              size = 1, 
              color = "blue", 
              se = FALSE)



## ---- out.width="50%", fig.width=7, fig.height=5, fig.show="hold", message=FALSE----------------------
# size 지정
gpsize <- ggplot(data = mtcars, 
                 aes(disp, mpg))

gpsize + geom_point(size = 4)

gpsize + geom_point(aes(size = hp), 
                    alpha = 0.5)



## ---- out.width="50%", fig.width=7, fig.height=5, fig.show="hold", message=FALSE----------------------
gpshape <- ggplot(data = mtcars, 
                  aes(hp, mpg))
gpshape + 
  geom_point(shape = 5) # 

# 실린더 개수에 따라 점 모양 지정
gpshape + 
  geom_point(aes(shape = factor(cyl)), 
             size = 4)
## pch를 인수로 사용해도 동일한 그래프 출력
# gpshape + 
#   geom_point(aes(pch = factor(cyl)), 
#              size = 4)



## ---- out.width="50%", fig.width=7, fig.height=5, fig.show="hold", message=FALSE----------------------
# linetype 지정
## economics_long 데이터셋
gplty <- ggplot(data = economics_long, 
                aes(x = date, y = value01))

gplty + 
  geom_line(aes(group = variable, color = variable), 
            size = 0.5, 
            linetype = 6)

# 실린더 개수에 따라 점 모양 지정
gplty + 
  geom_line(aes(linetype = variable, 
                color = variable), 
            size = 0.5)



## ---- fig.width=7, fig.height=5, fig.show="hold", message=FALSE---------------------------------------
# gap-minder 데이터
gpline <- ggplot(data = gapm_filter, 
                  aes(y = gdp_cap)) 
# geom_line
gpline + 
  geom_line(aes(x = year, 
                group = country), 
            size = 0.5, 
            alpha = 0.3, 
            linetype = "solid") -> gpline
gpline



## ---- fig.width=7, fig.height=5, fig.show="hold", message=FALSE---------------------------------------
# geom_path
highlight_country <- c("South Korea", "China", "Japan", 
                       "India", "Taiwan", "Singapore")

# dplyr 패키지 체인과 ggplot 함수 연결 가능
gppath <- gapm %>% 
  filter(year >= 2000, 
         country %in% highlight_country) %>% 
  ggplot(aes(x = gdp_cap, 
             y = life_expectancy))

gppath + geom_path(aes(group = country))




## ---- fig.width=7, fig.height=5, fig.show="hold", message=FALSE---------------------------------------
# 선 굵기 및 색상 조정
gppath + 
  geom_path(aes(color = country), 
            size = 4, 
            alpha = 0.5) -> gppath

# 선과 점 동시에 출력
gppath + 
  geom_point(aes(shape = country), 
             size = 2)


## ---- fig.width=7, fig.height=5, fig.show="hold", message=FALSE---------------------------------------
# geom_abline, geom_hline, geom_vline
## abline
m <- lm(gdp_cap ~ year, data = gapm_filter)
gpline +   
  geom_abline(slope = coef(m)[2], 
              intercept = coef(m)[1], 
              size = 2, 
              color = "blue") -> gplines
gplines


## ---- fig.width=7, fig.height=5, fig.show="hold", message=FALSE, out.width="50%"----------------------
## hline
gplines + 
  geom_hline(yintercept = mean(gapm_filter$gdp_cap, 
                               na.rm = TRUE), 
             color = "red", 
             size = 1) -> gplines
gplines + ggtitle("Addling a horizontal line: mean of gdp_cap")

## vline  
gplines + 
  geom_vline(xintercept = mean(gapm_filter$year, 
                               na.rm = TRUE), 
             color = "red", 
             size = 1) + 
  ggtitle("Adding a vertical line: mean of year")



## ---- fig.width=7, fig.height=5, fig.show="hold", message=FALSE---------------------------------------
# geom_point
## 갭마인더 데이터: 2015년 기대수명 vs. 일인당 국민소득 산점도
gppoint <- gapm %>% 
  mutate(continent = gsub("(.+\\s)", "", region) %>% 
  # region 변수에서 공백 앞 문자 모두 제거
           factor) %>% 
  filter(year == 2015) %>% 
  ggplot(aes(x = life_expectancy, y = gdp_cap))

gppoint + 
  geom_point(size = 1)



## ---- fig.width=7, fig.height=5, fig.show="hold", message=FALSE---------------------------------------
## 점의 크기는 해당 국가 인구수(log10 변환) 에 비례
## 각 대륙에 따라 색 구분
## 투명도는 0.3
## --> Bubble plot
gppoint + 
  geom_point(aes(size = log(population, base=10), 
                 color = continent), 
             alpha = 0.3)



## ---- fig.width=7, fig.height=5, fig.show="hold", message=FALSE---------------------------------------
## mpg 데이터 셋
## cylinder 개수에 따른 시내 연비
gppoint2 <- ggplot(data = mpg, 
                   aes(x = cyl, y = cty))
gppoint2 + geom_point(size = 3)



## ---- fig.width=7, fig.height=5, fig.show="hold", message=FALSE, out.width="50%"----------------------
# geom_jitter
## geom_point에서 position 인수 조정
gppoint2 + 
  geom_point(position = "jitter") + 
  ggtitle("geom_point() with position = 'jitter'")

## geom_jitter: jittering 크기는 0.3
## class로 색 조정
gppoint2 + 
  geom_jitter(aes(color = class), 
              width = 0.3) + 
  ggtitle("Jittering using geom_jitter()")



## ---- eval=FALSE--------------------------------------------------------------------------------------
## # geom_bar(), geom_col() 주요 함수 인수
## <MAPPING> = aes() 함수를 통해 수행
##             geom_bar()의 경우 aes() 내 x 위치에 대응하는
##             변수명만 입력해도 되지만, geom_col()의 경우,
##             x, y 에 대응하는 변수 모두 입력
## <ARGUMENTS>
##   - width: 상자의 너비 조정
##   - positon: 문자열 또는 위치 조정 관련 함수 호출 가능
##     두 개 이상의 범주가 한 그래프에 표현된 경우,
##     디폴트 값은 "stack" (position_stack() 호출).
##     두 번째 범주에 해당하는 막대를 나란히 배열하고자 할 때,
##     positon = "dodge", "dodge2", 또는 position_dodge(값) 사용
## 


## ---- message=FALSE-----------------------------------------------------------------------------------
# geom_bar()와 geom_col() 예시
p1 <- ggplot(data = mpg, 
       aes(x = class)) + 
  geom_bar() + 
  labs(title = "p2: Barplot via geom_bar()", 
       caption = "The y-axis indicates the number of cases in each class")

p2 <- mpg %>% 
  group_by(class) %>% 
  summarise(mean = mean(cty)) %>% 
  ggplot(aes(x = class, y = mean)) + 
  geom_col() +
  labs(title = "p1: Barplot via geom_col()", 
       caption = "The y axis indicates the identical values of means")



## ----bar-plots-ex, fig.width=10, fig.heigh=7, echo=FALSE, fig.show="hold", message=FALSE--------------
require(ggpubr)
require(gridExtra)

ggarrange(p1, p2, ncol = 2)



## -----------------------------------------------------------------------------------------------------
# geom_bar(stat = "identity") 인 경우 geom_col()과 동일한 결과 도출
p1 <- mpg %>% 
  group_by(class) %>% 
  summarise(mean = mean(cty)) %>% 
  ggplot(aes(x = class, y = mean)) + 
  geom_bar(stat = "identity") +
  labs(title = "p1: Barplot via geom_bar(stat = 'identity')")

# 막대도표 x-y 축 변환
# 이 경우 geom_bar()에 aesthetic 추가
p2 <- ggplot(mpg) + 
  geom_bar(aes(y = class)) + 
  labs(title = "p2: Map 'class' variable to y")
  



## ----bar-plots-ex2, fig.width=10, fig.heigh=7, echo=FALSE, fig.show="hold"----------------------------
ggarrange(p1, p2, ncol = 2)



## -----------------------------------------------------------------------------------------------------
# diamonds dataset
# 2개의 범주형 변수가 aesthetic에 mapping된 경우
# stacked barplot
gbar_init <- ggplot(data = diamonds) + 
  aes(x = color, fill = cut)
p1 <- gbar_init + 
  geom_bar()
  
# fill에 해당하는 범주에 대해 나란히 배열
p2 <- gbar_init + 
  geom_bar(position = "dodge2")



## ----bar-plots-ex3, fig.width=11, fig.heigh=7, echo=FALSE, fig.show="hold"----------------------------
ggarrange(p1, p2, ncol = 2)



## -----------------------------------------------------------------------------------------------------
# gapminder region 별 중위수 계산
gapm_median <- gapm %>%
  filter(year == 2015) %>%
  group_by(region) %>%
  summarise(median = median(gdp_cap, na.rm = TRUE))

p1 <- ggplot(gapm_median) + 
  aes(x = region, y = median) + 
  geom_bar(stat = "identity") + 
  coord_flip()

p2 <- gapm_median %>% 
  mutate(region = reorder(region, median)) %>% 
  ggplot(aes(x = region, y = median)) +
  geom_bar(stat = "identity") +
  coord_flip() # x-y 축 뒤집기



## ---- echo=FALSE, fig.width=12, fig.height=7, fig.show="hold"-----------------------------------------
ggarrange(p1, p2, ncol = 2)


## ---- eval=FALSE--------------------------------------------------------------------------------------
## # geom_errorbar(), geom_linerange() 주요 함수 인수
## <MAPPING> = 기본 x, y에 대한 aesthetic 기본 mapping 이외
##             범위를 지정하는 ymin (ymax), xmin (ymax) 지정 필수
## 
## <ARGUMENTS>
##   - width: geom_errorbar()에서 범위선에 수직인 선의 너비 짖어
##   - positon: 문자열 또는 위치 조정 관련 함수 호출 가능
##     positon = "dodge", "dodge2", 또는 position_dodge(값) 사용
## 


## ---- errorbar-ex1, fig.width=10, fig.heigh=6, fig.show="hold"----------------------------------------
# geom_errorbar() 예시
# diamonds cut, color에 따른 carat의 평균, 표준편차,  95% 신뢰구간 계산
# dplyr + pipe operator를 이용한 통계량 계산
carat_summ <- diamonds %>% 
  group_by(cut, color) %>% 
  summarise(N = n(), 
            mean = mean(carat), 
            sd = sd(carat)) %>% 
  # 95 % 신뢰구간(모분산 모른다고 가정)
  mutate(lcl = mean - qt(0.975, N-1)*sd/sqrt(N), 
         ucl = mean + qt(0.975, N-1)*sd/sqrt(N))

gerror_init <- ggplot(data = carat_summ) + 
  aes(x = cut, y = mean, color = color) 

# 오차 막대 도표 (디폴트) 오차 범위는 95 % 신뢰구간
gerror_init + 
  geom_errorbar(aes(ymin = lcl, 
                    ymax = ucl))



## ---- errobar-ex2, fig.width=10, fig.heigh=6----------------------------------------------------------
# 오차 막대 도표2
# 선과 점 추가
# 집단 별 위치 및 막대 조정
gerror_init + 
  geom_errorbar(aes(ymin = lcl, 
                    ymax = ucl), 
                width = 0.1,  # 선 너비 지정
                position = position_dodge(0.8)) + 
  geom_line(aes(group = color)) + 
  geom_point(size = 3)



## ---- errobar-ex3, fig.width=10, fig.heigh=6, fig.show="hold"-----------------------------------------
# 점과 선에 대해서도 동일하게 position 조정 필요
# position은 수동으로 조정("dodge" 등 대신 position_dodge(value) 입력)
gerror_init + 
  geom_errorbar(aes(ymin = lcl, 
                    ymax = ucl), 
                width = 0.1,  # 선 너비 지정
                position = position_dodge(0.8)) + 
  geom_line(aes(group = color), 
            position = position_dodge(0.8)) + 
  geom_point(size = 3, 
             position = position_dodge(0.8))



## ---- errobar-ex4, fig.width=10, fig.heigh=7, fig.show="hold"-----------------------------------------
# warpbreaks 데이터
# R 기본 그래픽스 barplot() 예제와 동일한 그래프 생성

break_summ <- warpbreaks %>%
  group_by(wool, tension) %>% 
  summarise(N = n(),  
            mean = mean(breaks), 
            sem = sd(breaks)/sqrt(N)) 

ggplot(data = break_summ) + 
  aes(x = tension, y = mean, fill = wool) + # aesthetic 지정
  geom_col(position = position_dodge(0.9), 
           color = "black") + # 테두리 선 색상 지정(검정)
  geom_errorbar(aes(ymin = mean - sem, 
                    ymax = mean + sem), 
                position = position_dodge(0.9), 
                width = 0.1)




## ---- fig.width = 11, fig.height=7, fig.show="hold"---------------------------------------------------
# geom_linerange 예시
# 정규 난수 생성
# 표본 크기 n = 30, 반복 N = 200
# 평균 mu = 20, 표준편차 sx = 10
# 각 표본에 대한 95 % 신뢰구간 계산(모분산은 안다고 가정)
set.seed(20200609)
n <- 30; N = 200
mu <- 20; sx <- 10
X <- mapply(rnorm, 
            rep(n, N), 
            rep(mu, N), 
            rep(sx, N))
mi <- apply(X, 2, mean) # 각 반복에 대한 표본 평균 계산
si <- apply(X, 2, sd) # 각 반복에 대한 표준편차 계산
alpha <- 0.05 # 유의수준
lower_ci <- mi - qnorm(1-alpha/2)*si/sqrt(n) # 신뢰구간 하한
upper_ci <- mi + qnorm(1-alpha/2)*si/sqrt(n) # 신뢰구간 상한
df_ci <- tibble(lower_ci, upper_ci) %>% 
  mutate(nsim = seq_len(N), 
         mu_contain = lower_ci <= mu & 
           mu <= upper_ci)

ggci_init <- ggplot(df_ci) +
  aes(x = nsim) # simulation 횟수 정보

ggci_init + 
  geom_linerange(
    aes(ymin = lower_ci, # 하한
        ymax =upper_ci,  # 상한
        color = mu_contain), # 색 지정
    size = 1.2, 
    alpha = 0.3
  ) + 
  geom_hline(yintercept = mu,
             color = "tomato", 
             size = 1)



## ---- eval=FALSE--------------------------------------------------------------------------------------
## <MAPPING>: 필수 aesthetic은 x, y, label 임
## 
## 다음 aesthetic 속성들은 geom_text() 또는 geom_label()
## 함수에서 인수(aes() 함수 외부)로 사용 가능
## 
## - angle: 텍스트 각도 조정
## - family: 텍스트 폰트 페미리
## - fontface: 텍스트 형태("bold", "italic", "bold.italic", "plain" 가능)
## - hjust: 텍스트 수평 위치 조정
## - vjust: 텍스트 수직 위지 초정
## 
## <ARGUMENTS> (중요 인수)
##   - parse: 논리값, 기본 그래픽스 수식 표현식(expression(), 또는 bquote()) 사용 여부
##   - check_overlap: 이전에 생성된 텍스트 위에 새로운 텍스트가 중첩(overlapping)될 경우
##                    인수값이 TRUE 이면 출력하지 않음. (geom_text()에서만 사용 가능)
## 


## -----------------------------------------------------------------------------------------------------
gtext_init <- mtcars %>% 
  rownames_to_column(var = "model") %>% 
  ggplot(aes(x = wt, y = mpg)) 

gtext1 <- gtext_init + 
  geom_text(aes(label = model), 
            size = 4) +  # x-y aesthetic 사용
  labs(title = "geom_text() with size = 4")
  
# 중첩되는 텍스트 제거
gtext2 <- gtext_init + 
  geom_text(aes(label = model), 
            size = 4, 
            check_overlap = TRUE) + 
  labs(title = "Remove overlapped text with check_overlap = TRUE")

# geom_label() 
# check_overlap 옵션 사용할 수 없음
gtext3 <- gtext_init + 
  geom_label(aes(label = model), 
             size = 4) + 
  labs(title = "geom_label()")

gtext4 <- gtext_init + 
  geom_point(size = 1) + 
  geom_text(aes(label = model, 
                color = factor(cyl)), 
            size = 4, 
            fontface = "italic", 
            check_overlap = TRUE) + 
  labs(title = "Both points and texts: using italic fontface")
  


## ---- fig.width = 11, fig.height=9, fig.show="hold", echo=FALSE---------------------------------------
ggarrange(gtext1, gtext2, gtext3, gtext4, 
          ncol = 2, nrow = 2)



## `vjust`, `hjust` 모두 (0, 1) 밖의 값을 갖을 수 있으나, 이러한 위치 조정은 그래프의 크기에 상대적이기 때문에 해당 값들을 이용해 텍스트 위치를 과도하게 조정하는 것이 바람직한 방법은 아님.

## 

## ---- fig.width=8, fig.height=8, fig.show="hold", fig.cap="hjust와 vjust 값에 따른 텍스트 위치. https://ggplot2.tidyverse.org/articles/ggplot2-specs.html 인용"----
# hjust, vjust 별 문자 위치 표시
adj_val <- c(-0.5, 0, 0.5, 1)
df_adjust <- expand.grid(hjust = adj_val, 
                         vjust = adj_val)
df_adjust <- df_adjust %>% 
  mutate(just_label = sprintf("(h=%.1f, v=%.1f)", 
                              hjust, vjust))
ggplot(data = df_adjust) + 
  aes(x = hjust, y = vjust) + 
  geom_point(color = "gray", 
             alpha = 0.8, 
             size = 5) + 
  geom_text(aes(label = just_label, 
                hjust = hjust, 
                vjust = vjust))
  


## ---- eval=FALSE, warnings=FALSE----------------------------------------------------------------------
## set.seed(12345)
## x <- rnorm(100, 5, 2)
## df_dummy <- data.frame(x = 0, y = 0)
## # 정규분포 pdf
## expr1 <- expression(paste(f,
##                           "(", x, ";", list(mu, sigma), ")"
##                           == frac(1, sigma*sqrt(2*pi))*~~exp *
##                             bgroup('(',
##                                    -frac((x-mu)^2,
##                                          2*sigma^2), ')')))
## # 회귀계수 추정 공식
## expr2 <- expression(hat(bold(beta)) ==
##                     bgroup("(", bold(X)^T*bold(X),
##                      ")")^-1*bold(X)^T*bold(y))
## # 그리스 문자
## expr3 <- expression(alpha[1]~~beta[2]~~gamma[3]~~delta[4]
##                     ~~epsilon[5]~~theta[6]~~pi[7])
## #
## expr4 <- bquote(paste("Estimated" ~~
##                         hat(mu) ==
##                         .(sprintf("%.2f", mean(x)))))
## 
## ggplot(data = df_dummy) +
##   aes(x = x, y = y) +
##   geom_point(size = 0) +
##   geom_text(x = 0, y = 0, label = expr1,
##             size = 10) +
##   geom_text(x = 0, y = -0.025, label = expr2,
##             size = 10) +
##   geom_text(x = 0, y = -0.04,
##             label = "y[i] == beta[0] + beta[1]~x + epsilon[i]",
##             parse = TRUE, # 수식 내용이 문자열로 label 값으로 사용
##             size = 10) +
##   geom_text(x = 0, y = 0.025, label = expr3,
##             size = 10) +
##   geom_text(x = 0, y = 0.04, label = deparse(expr4),
##             parse = TRUE,
##             size = 10)
## 
## ## ggplot 객체 저장
## # ggsave("figures/ggplot-text-math.png", plot = last_plot())
## 
## 


## ---- echo=FALSE, message=FALSE, fig.align='center', echo=FALSE, fig.show='hold', out.width='100%', warnings=FALSE----
knitr::include_graphics('figures/ggplot-text-math.png', dpi = NA)


## ---- eval=FALSE--------------------------------------------------------------------------------------
## <MAPPING> = 기본 x, y에 대한 aesthetic 기본 mapping 이외
##             범위를 지정하는 ymin (ymax), xmin (ymax) 지정 필수


## ---- fig.width=8, fig.height=6, fig.show="hold"------------------------------------------------------
# gapminder 데이터셋
gapm %>% 
  filter(iso == "KOR") %>% 
  select(year, gdp_cap) %>% 
  ggplot(aes(x = year, y = gdp_cap)) + 
  geom_ribbon(aes(ymin = gdp_cap - 5000, 
                  ymax = gdp_cap + 5000), 
              fill = "gray", 
              alpha = 0.5) + 
  geom_line(size = 1.5, 
            color = "black")



## ---- fig.width=8, fig.height=5, fig.show="hold"------------------------------------------------------
x <- seq(-3, 3, by = 0.01)
z <- dnorm(x)
df_norm <- data.frame(x, z)
idx <- -1.2 < x  & x < 0.7 # 해당 구간 index 설정
df_area <- df_norm %>% 
  filter(idx)
expr <- bquote(P({-1.2 < Z} < 0.7 ) == 
                 .(sprintf("%.3f", pnorm(0.7) - pnorm(-1.2))))

# 각 geom 별로 다른 데이터 적용
ggplot() + 
  geom_line(data = df_norm, 
            aes(x = x, y = z), size = 1) + 
  geom_area(data = df_area, 
            aes(x = x, y = z), 
            fill = "red", alpha = 0.2) + 
  geom_text(aes(x = -1, y = 0.2, 
                # expr 이 3 행으로 구성되었기 때문에 paste로 collapse
                label = paste(deparse(expr), collapse = "")),
            parse = TRUE, size = 5, 
            hjust = 0)



## ---- eval=FALSE--------------------------------------------------------------------------------------
## <MAPPING>: 하나의 변수를 x 또는 y에 대응
## <ARGUMENTS>
##   - binwidth: 히스토그램의 너비 조정. 결국 범주의 개수 조정
##   - bins: 히스토그램 생성 시 범주화 개수(기본값 = 30)
## 


## ---- message=FALSE, warning=FALSE--------------------------------------------------------------------
# diamonds 데이터셋
p0 <- ggplot(data = diamonds, aes(x = carat))
p1 <- p0 + geom_histogram() + 
  labs(title = "bins, binwidth = default")
p2 <- p0 + geom_histogram(binwidth = 0.01) + 
  labs(title = "binwidth = 0.05")
p3 <- p0 + geom_histogram(bins = 150) + 
  labs(title = "bins = 150")
p4 <- ggplot(data = diamonds, aes(y = carat)) + 
  geom_histogram() + # y 축 기준으로 히스토그램 생성
  labs(title = "Map to y (flipped)")
  


## ---- echo=FALSE, fig.width=9, fig.height=9, fig.show="hold"------------------------------------------
ggarrange(p1, p2, p3, p4, 
          ncol = 2, nrow = 2)


## -----------------------------------------------------------------------------------------------------
# iris 데이터셋. 변수: Sepal Length
p0 <- ggplot(data = iris, aes(x = Petal.Length))
p1 <- p0 + 
  geom_histogram(aes(fill = Species), 
                 color = "white",
                 bins = 20, 
                 alpha = 0.2) + 
  labs(title = "p1: Histograms of petal length: frequency")

p2 <- p0 + 
  geom_histogram(aes(fill = Species, 
                     y = ..density..), # y축을 밀도로 변경
                 color = "white", # 막대 테두리선 지정
                 alpha = 0.2, 
                 bins = 20) +  
  labs(title = "p2: Histograms of petal length: density")



## ---- echo=FALSE, fig.width=10, fig.height=4, fig.show="hold"-----------------------------------------
ggarrange(p1, p2, ncol = 2, nrow = 1)



## ---- eval=FALSE--------------------------------------------------------------------------------------
## <MAPPING>: 커널 밀도를 추정할 변수 (x 또는 y)
## 
## <ARGUMENTS>
##    - adjust: 커널 함수의 복잡도 조정(수치영 값 입력)
## 


## -----------------------------------------------------------------------------------------------------
# geom_histogram() 예시 이어서
# dataset: iris

p1 <- p0 + 
  geom_density() + 
  labs(title = "p1: Basic geom_density()")

p2 <- p0 + 
  geom_density(aes(color = Species)) + 
  labs(title = "p2: geom_density(aes(color = Species))")

p3 <- p0 + 
  geom_density(aes(fill = Species, 
                   color = Species), 
               alpha = 0.2) + 
  labs(title = "p3: geom_density(aes(color = Species))")
p4 <- p0 + 
  geom_density(aes(fill = Species, 
                   color = Species), 
               alpha = 0.2) + 
  geom_histogram(aes(y = ..density.., # 밀도로 변환 필요
                     fill = Species), 
                 color = "white", 
                 alpha = 0.3, 
                 bins = 20) + 
  labs(title = "p4: Overlaying multiple histograms with multiple densities")



## ---- echo=FALSE, fig.width=12, fig.height=8, fig.show="hold"-----------------------------------------
ggarrange(p1, p2, p3, p4, ncol = 2, nrow = 2)



## ---- eval=FALSE--------------------------------------------------------------------------------------
## <MAPPING>
##   - x: 이산형(discrete) 변수를 x에 대한 aesthetic으로 mapping
##   - y: 상자그림으로 표현할 변수
## 
## <ARGUMENTS>
##   - outlier.*: outlier의 aesthetic 조정 (*=color, fill, shape, size, ...)
##   - width: 상자의 너비 조정
##   - varwidth: 논리값. 상자의 크기를 sqrt(n)에 비례하여 조정
## 
## 


## -----------------------------------------------------------------------------------------------------
# diamond 데이터 셋
## cut 범주에 따른 carat의 분포

p0 <- ggplot(data = diamonds, 
             aes(y = carat))
p1 <- p0 + 
  geom_boxplot() # 디폴트 상자 그림

p2 <- p0 + 
  geom_boxplot(aes(x = cut, 
                   fill = cut))

p3 <- p0 + 
  geom_boxplot(aes(x = cut, 
                   fill = cut), 
               width = 0.5) # 상자 크기 조정

p4 <- p0 + 
  geom_boxplot(aes(x = cut, 
# aesthetic에 x 이외의 factor가 추가된 경우 자동으로 dodge                   
                   fill = color), 
               # outlier 표시 모양 및 색상 지정
               outlier.shape = 4, 
               outlier.color = "red")



## ---- echo=FALSE, fig.width=14, fig.height=8, fig.show="hold"-----------------------------------------
ggarrange(p1, p2, p3, p4, ncol = 2, nrow = 2)



## -----------------------------------------------------------------------------------------------------
# mpg 데이터셋
p0 <- ggplot(data = mpg) + 
  aes(x = class, y = cty)

p1 <- p0 + 
  geom_boxplot(aes(fill = class), 
               outlier.shape = NA, 
               alpha = 0.1) + # 이상치 표시하지 않음
  geom_jitter(aes(color = class), 
              alpha = 0.5, 
              width = 0.2) + 
  labs(title = "p1: boxplot with jittered data points per each class (unordered)")

p2 <- mpg %>% 
  # stats::reorder() 함수를 이용해 특정 통계량 기준으로 데이터 정렬 가능
  mutate(class = reorder(class, cty, median)) %>% 
  ggplot(aes(x = class, y = cty)) + 
  geom_boxplot(aes(fill = class), 
               outlier.shape = NA, 
               alpha = 0.1) + 
  geom_jitter(aes(color = class), 
              alpha = 0.5, 
              width = 0.2) + 
  labs(title = "p2: ordered by median of cty for each car class")



## ---- echo=FALSE, fig.width=12, fig.height=5, fig.show="hold"-----------------------------------------
ggarrange(p1, p2, ncol = 2)



## -----------------------------------------------------------------------------------------------------
p0 <- ggplot(data = diamonds) + 
  aes(x = carat, y = price)

p1 <- p0 + 
  geom_point(alpha = 0.2) + 
  geom_smooth() + 
  labs(title = "p1: geom_smooth() default")

p2 <- p0 + 
  geom_point(aes(color = color), 
             alpha = 0.2) + 
  geom_smooth(aes(color = color)) + 
  labs(title = "p2: geom_smooth() for different color groups")

p3 <- p0 + 
  geom_point(aes(color = color), 
             alpha = 0.2) + 
  geom_smooth(aes(color = color), 
              se = FALSE) + # 표준오차 영역 삭제
  labs(title = "p3: geom_smooth() without the SE region")

p4 <- p0 + 
    geom_point(aes(color = color), 
             alpha = 0.2) + 
  geom_smooth(aes(color = color), 
              se = FALSE, 
# 선형 회귀 곡선을 추세선으로 사용
              method = "lm") + 
  labs(title = "p4: geom_smooth() using the linear regression curve")  
  



## ---- echo=FALSE, fig.width=12, fig.height=8, fig.show="hold", cache=TRUE-----------------------------
ggarrange(p1, p2, p3, p4, ncol = 2, nrow = 2)


## -----------------------------------------------------------------------------------------------------
gppoint + 
  geom_point(aes(size = population, 
                 color = continent), 
             alpha = 0.3) + 
  scale_size_continuous(range = c(1, 20))
  


## -----------------------------------------------------------------------------------------------------
p0 <- ggplot(data = diamonds, 
             aes(y = carat))
p1 <- p0 + geom_boxplot(aes(x = color, 
                   fill = color), 
               width = 0.5)
p2 <- p1 + 
  coord_flip()



## ---- fig.width=11, fig.height=6, fig.show="hold", cache=TRUE-----------------------------------------
ggarrange(p1, p2, ncol = 2)


## -----------------------------------------------------------------------------------------------------
# gap-minder 데이터 
gapm <- read_csv("dataset/gapminder/gapminder_filter.csv")
gapm %>% 
  mutate(continent = gsub("(.+\\s)", "", region) %>% 
           factor) %>% 
  filter(year == 2015) %>% 
  ggplot(aes(x = life_expectancy, y = gdp_cap)) + 
  geom_point(aes(size = population, 
                 color = continent), 
             alpha = 0.3) -> p1

p2 <- p1 + 
  guides(size = FALSE, # size 관련 guide(범례는 출력하지 않음)
         color = guide_legend(
           title = "Contient", # 범례 제목 변경
           title.theme = element_text(face = "bold"), # 범례 제목 폰트 굵은체
           override.aes = list(size = 5) # 범례 표시 점의 크기를 5로
         )) + 
  theme(legend.position = "top") # 범례 위치를 맨 위로 조정



## ---- echo=FALSE, fig.width=12, fig.height=6, fig.show="hold"-----------------------------------------
ggarrange(p1, p2, ncol = 2)


## ---- eval = FALSE------------------------------------------------------------------------------------
## facet_grid(<ROW VARIABLE> ~ <COLUMN VARIABLE>, ...)
## 


## ---- eval = FALSE------------------------------------------------------------------------------------
## facet_wrap(~ <DISCRETE VARIABLE>,
##            ncol = n,  # 열 개수
##            nrow = m,  # 행 개수
##            scale: x, y 스케일
##                   "free": x-y 스케일을 모든 패널에 동일하게 고정
##                   "free": x-y 모두 각 panel에 맞게 조정
##                   "free_x": y의 스케일은 모든 고정하고 x 만 각 페널에 맞게 조정
##                   "free_y": x의 스케일은 모든 고정하고 y 만 각 페널에 맞게 조정
##            )
## 


## ---- fig.width=12, fig.height=5, fig.show="hold"-----------------------------------------------------
# mpg 데이터 셋
p0 <- ggplot(data = mpg) + 
  aes(x = displ, y = hwy)

# class 별 displ vs. hwy 산점도
p1 <- p0 + 
  geom_point(size = 2) + 
  facet_grid(. ~ class)
p1



## ---- fig.width=12, fig.height=6, fig.show="hold", cache=TRUE-----------------------------------------
p2 <- p0 + 
  # 모든 facet에 동일한 데이터를 표현하려면 
  #  geom 내부에서 데이터를 재정의
  geom_point(data = mpg %>% select(-class, -cyl), 
             color = "gray", alpha = 0.3) + 
  geom_point(size = 2) + 
  facet_grid(cyl ~ class)
p2



## ---- fig.width=12, fig.height=8, fig.show="hold", cache=TRUE-----------------------------------------
# economics_long 데이터셋
glimpse(economics_long)
economics_long %>% 
  mutate(variable = factor(variable, 
                           levels = unique(variable), 
                           labels = c("Personal consumption expenditures", 
                                      "Total population", 
                                      "Personal saving rates", 
                                      "Median duration of unemployment", 
                                      "# of unemployed in thausand"))) %>% 
  ggplot(aes(x = date, y = value)) + 
  geom_line(size = 1) + 
  facet_wrap(~ variable, nrow = 2, 
             scale = "free_y") + 
  theme(
    strip.background = element_blank(), 
    strip.text = element_text(hjust = 0, 
                              face = "bold")
  )




## 두 개 이상의 ggplot 객체를 한 화면에 출력하고자 할 때(R 기본 그래픽스에서 `par(mfrow = c(n, m))`와 유사하게), 별도의 패키지(예: gridExtra, ggpubr, cowplot 패키지 등)가 요구됨. 이 중 가장 사용하기 용이한 패키지와 함수는 `ggubr::ggarrange()` 임.

## 

## **`theme()`** 함수를 이용한 그래프 조정 옵션은 `help(theme)` 또는 [ggplot2 공식 메뉴얼](https://ggplot2.tidyverse.org/reference/theme.html) 또는 [Statistical tools for high-throughput data analysis](http://www.sthda.com/english/wiki/ggplot2-themes-and-background-colors-the-3-elements)를 참고

## 

## -----------------------------------------------------------------------------------------------------
p0 <- ggplot(mtcars, aes(wt, mpg)) +
  geom_point() 

p1 <- p0 + theme_grey() + 
  labs(title = "Basic theme: theme_grey() (default)")

p2 <- p0 + theme_bw() + 
  labs(title = "Basic theme: theme_bw()")

p3 <- p0 + theme_light() + 
  labs(title = "Basic theme: theme_light()")

p4 <- p0 + theme_minimal() + 
  labs(title = "Basic theme: theme_minimal()")

p5 <- p0 + theme_classic() + 
  labs(title = "Basic theme: theme_classic()")

p6 <- p0 + theme_linedraw() + 
  labs(title = "Basic theme: theme_linedraw()")




## ---- echo=FALSE, fig.width=10, fig.height=7, fig.show="hold"-----------------------------------------
ggarrange(p1, p2, p3, p4, p5, p6, 
          ncol = 3, 
          nrow = 2)


## **ggplot 관련 알아두면 유용한 팁

## 
##    - [ggplot2](https://ggplot2.tidyverse.org/reference/index.html)는 ggplot2에 포함된 모든 함수에 대한 메뉴얼을 제공

##    - [r-statistics.co](http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html)에서 ggplot 예시 확인 가능

##    - ggplot2 패키지에서 제공하는 기본 theme 외에 ggtheme, ggpubr 과 같은 패키지를 통해 보다 다양한 theme을 적용할 수 있음

## 

## -----------------------------------------------------------------------------------------------------
covid19 <- read_delim("dataset/covid-19-dataset/covid19-cases-20200601.txt", 
                      delim = "\t")
country <- readxl::read_excel("dataset/covid-19-dataset/country_info.xlsx")
country_pubhealth <- read_csv("dataset/covid-19-dataset/country_pubhealth.csv")

# glimpse(covid19); glimpse(country); 
# glimpse(country_pubhealth)



## ---- echo=FALSE, message=FALSE-----------------------------------------------------------------------
owid_codebook <- readxl::read_excel("dataset/covid-19-dataset/owid_covid_codebook.xlsx")

col_cntry <- names(country)
desc_cntry <- c("3자리 국가코드", "국가명", "지역", "총인구수", 
                "인구밀도", "중위연령", "65세 이상 인구수", 
                "70세 이상 인구수" ,"일인당 국민소득", "극빈층 비율")
cb_cntry <- tibble(Dataset = "country", 
                   Varialbe = col_cntry, 
                   Description = desc_cntry)
cb_cntry

col_health <- names(country_pubhealth)
desc_health <- c("국가명", "심혈관계 질환 사망률", "당뇨병 유병률", 
                 "여성 흡연율", "남성흡연율", "구내 세수시설 설치 비율", 
                 "1000명 당 병상 수")
cb_health <- tibble(Dataset = "pubhealth", 
                    Variable = col_health, 
                    Description = desc_health)
cb_health

col_covid19 <- names(covid19)
desc_covid19 <- c("3자리 국가코드", "조사일자", "누적(전체) 확진자", 
                  "신규 확진자 수", "누적(전체) 사망자 수", "신규사망자 수", 
                  "누적(전체) 검사 수", "신규 검사수", 
                  "신규 검사 수(7일 이동평균 값)")
cb_covid <- tibble(Dataset = "covid19", 
                    Variable = col_covid19, 
                    Description = desc_covid19)
cb_covid



## -----------------------------------------------------------------------------------------------------
covid19_full <- covid19 %>% 
  filter(iso_code != "OWID_WRL", 
         date >= as.Date("2020-03-01") &
           date <= as.Date("2020-05-31")) 
# glimpse(covid19_full)



## -----------------------------------------------------------------------------------------------------
covid19_full <- covid19_full %>% 
  left_join(country, by = "iso_code") %>%  #country의 siso_code와 공통 변수
  left_join(country_pubhealth, by = c("location")) # 공통 변수: location
# glimpse(covid19_full)



## -----------------------------------------------------------------------------------------------------
covid19_full <- covid19_full %>% 
  # 하나 이상의 어떤 문자와 공백을 포함한 문자열을 그룹화
    mutate(continent = gsub("(.+\\s)", "", region) %>% 
           factor) 
# glimpse(covid19_full)


## -----------------------------------------------------------------------------------------------------
covid19_full <- covid19_full %>% 
    mutate_at(vars(matches("cases|deaths")), 
          list(per_million =~ ./population * 10^6)) 
# glimpse(covid19_full)



## -----------------------------------------------------------------------------------------------------
# 각 국가별로 grouping을 한 후 total_case의 최댓값이 1000 명을 초과한 경우만 추출
covid19_full <- covid19_full %>% 
  group_by(location) %>%  
  filter(max(total_cases) > 1000)
# glimpse(covid19_full)



## -----------------------------------------------------------------------------------------------------
# 위에서 location 에 대한 grouping이 유지가 되고 있음
# 각 국가별 첫 번째 행이고 그 첫 번째 행이 결측이면 0 값을 대체하고
# 아니면 원래 관측값을 반환
covid19_full <- covid19_full %>% 
  mutate(total_tests = ifelse(row_number() == 1 & 
# 첫 번째 값을 추출하기 위해 dplyr 제공 first() 함수 사용
                                is.na(first(total_tests)), 
                              0, total_tests)) %>% 
# help(fill) 참고  
  fill(total_tests, .direction = "down") %>% 
  ungroup 
# glimpse(covid19_full)


## -----------------------------------------------------------------------------------------------------
# 4 번과 유사
covid19_full <- covid19_full %>% 
    mutate_at(vars(contains("_tests")),
                 list(per_thousand = ~ ./population * 10^3))
# glimpse(covid19_full)
  


## -----------------------------------------------------------------------------------------------------
covid19_full <- covid19_full %>% 
  select(iso_code:date, location, continent, population, 
         matches("cases|deaths|tests"))
glimpse(covid19_full)


## ---- fig.width=11, fig.height=5, fig.show="hold"-----------------------------------------------------
Sys.setlocale("LC_TIME", "english")
covid19_full %>%
  ungroup %>%
  group_by(continent, date) %>%
  summarise(confirm_case_date = sum(new_cases)) %>%
  ungroup %>%
  ggplot(aes(x = date)) +
  geom_bar(aes(y = confirm_case_date,
               fill = continent,
               alpha = continent),
           stat = "identity",
           position = "identity",
           # color = "white"
           alpha = 0.3) +
  scale_fill_brewer(palette = "Set1") +
  scale_x_date(date_breaks = "2 weeks",
               date_labels = "%b-%d") +
  theme_minimal(base_size = 15) +
  labs(x = "", y = "",
       title = "World COVID-19 cases over time") +
  theme(
    legend.position = "bottom",
    panel.grid = element_line(size = 0.5,
                              linetype = "dashed"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )


## ---- fig.width=11, fig.height=5, fig.show="hold"-----------------------------------------------------
Sys.setlocale("LC_TIME", "english") # date 영문 표시를 위해 필요
covid19_full %>% 
  filter(iso_code == "KOR") %>% 
  mutate(total_tests_n = max(total_tests)) %>% 
  ungroup %>% 
  ggplot(aes(x = date)) + 
  geom_bar(aes(y = new_tests), 
           stat = "identity", 
           fill = "lightblue", 
           color = "white") + 
  geom_line(aes(y = new_tests_smoothed, 
                group = location), 
            size = 1, 
            color = "red") + 
  # x의 데이터 유형이 date
  # date label에 대한 자세한 설명은 help(strptime)으로 확인
  scale_x_date(date_breaks = "2 weeks", 
               date_labels = "%b-%d") + 
  # y = Inf 는 텍스트의 위치를 맨 위에 위치시킬 때 유용
  geom_text(aes(x = as.Date('2020-03-01'), y = Inf, 
                label = paste("Total number of COVID-19 tests performed:", 
                              # 출력 숫자 자리수 콤마 표시를 위해 사
                              format(unique(total_tests_n), 
                               big.mark = ","))), 
            vjust = 1, 
            hjust = 0, 
            color = "black", 
            size = 4) +  
  theme_minimal(base_size = 15) + # minimal theme 사용
  labs(x = "", 
       y = "", 
       title = "Daily COVID-19 tests in South Korea", 
       subtitle = "Test unit: people tested") + 
  theme(
    legend.position = "none", # 범례 표시 제거
    panel.grid = element_line(size = 0.5, linetype = "dashed"), 
    panel.grid.minor.x = element_blank(), 
    panel.grid.major.x = element_blank(), 
    axis.ticks = element_blank()
  )



## ---- fig.width=11, fig.height=8, fig.show="hold"-----------------------------------------------------
require(RColorBrewer)
getPalette = colorRampPalette(brewer.pal(9, "Set1"))
covid19_full %>%
  filter(date == as.Date("2020-05-31")) %>%
  mutate(total_tests_per_cases = total_tests/total_cases) %>%
  filter(total_tests_per_cases != 0) %>%
  select(iso_code:continent,
         total_tests_per_cases) %>%
  arrange(desc(total_tests_per_cases)) %>% 
  slice(1:24) %>% 
  mutate(location = factor(location,
                           levels = unique(location))) %>%
  ggplot(aes(x = reorder(location, desc(location)),
             y = total_tests_per_cases)) +
  geom_bar(aes(fill = location),
           stat = "identity") +
  geom_text(aes(label = sprintf("%.1f", total_tests_per_cases)),
            hjust = -0.5,
            size = 4) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 300),
                     breaks = c(0, 100, 200)) +
  scale_fill_manual(values = getPalette(24)) +
  labs(x = "", y = "",
       title = "Total COVID-19 tests per each confirmed case at May 31, 2020")  +
  coord_flip() +
  theme_minimal(base_size = 15) +
  theme(
    legend.position = "none",
    panel.grid = element_line(size = 0.5,
                              linetype = "dashed"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank()
  )


