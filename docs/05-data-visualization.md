


# 데이터 시각화 {#ch-data-visualization}

\footnotesize

\BeginKnitrBlock{rmdimportant}<div class="rmdimportant">**학습 목표**
  
- R에서 기본으로 제공하는 그래프 생성 개념 및 관련 함수의 의미 및 사용 방법에 대해 학습한다. 
- Grammar of graphics를 기반으로 개발된 ggplot2 패키지에 대해 알아보고 사용 방법을 학습힌다. 
</div>\EndKnitrBlock{rmdimportant}

 \normalsize

> “The simple graph has brought more information to the data analyst’s mind than any other device.” 
>
> $\rightarrow$ **John Tukey**


- 그래프는 생각보다 더 많은 정보를 제공 
- 데이터 분석 시 통계량 만으로 데이터의 속성을 결정하는 것은 매우 위험(예: Anscombe's quartet 데이터 예제)

\footnotesize


```
  x1 x2 x3 x4   y1   y2    y3   y4
1 10 10 10  8 8.04 9.14  7.46 6.58
2  8  8  8  8 6.95 8.14  6.77 5.76
3 13 13 13  8 7.58 8.74 12.74 7.71
4  9  9  9  8 8.81 8.77  7.11 8.84
5 11 11 11  8 8.33 9.26  7.81 8.47
6 14 14 14  8 9.96 8.10  8.84 7.04
```

```
      x1       x2       x3       x4       y1       y2       y3       y4 
9.000000 9.000000 9.000000 9.000000 7.500909 7.500909 7.500000 7.500909 
```

```
      x1       x2       x3       x4       y1       y2       y3       y4 
3.316625 3.316625 3.316625 3.316625 2.031568 2.031657 2.030424 2.030579 
```

<div class="figure">
<img src="05-data-visualization_files/figure-epub3/unnamed-chunk-3-1.svg" alt="Anscombe's quartet: https://goo.gl/Ugv3Cz 에서 스크립트 발췌"  />
<p class="caption">(\#fig:unnamed-chunk-3)Anscombe's quartet: https://goo.gl/Ugv3Cz 에서 스크립트 발췌</p>
</div>

 \normalsize

- 시각화는 분석에 필요한 통계량 또는 분석 방법론에 대한 가이드를 제시
- 인간의 뇌 구조 상 추상적인 숫자나 문자 보다는 그림이나 도표를 더 빨리 이해
- 다른 통계 패키지(SPSS, SAS, STATA 등)와 비교할 수 없을 정도로 월등한 성능의 그래픽 도구 및 기능 제공


## R 기본 그래프 함수

- R의 그래픽은 그래픽 장치에 특정 그림(선, 점, 면 등)을 순차적으로 추가하는 명령(스크립트)을 통해 생성

- **그래픽 장치**: R에서 그래프가 출력되는 장치
   - windows: R 프로그램 내에서 출력
   - graphic files: pdf, jpeg, tiff, png, bmp 등의 확장자를 갖는 이미지 파일

-그래프 장치를 열기 위해 사용되는 함수
   - `windows()` 또는 `win.graph()`: 그래픽 장치를 열기 위해 사용하는 함수
   - `dev.cur()`: 현재 활성화된 그래프 장치 확인
   - `dev.set()`: 다수의 그래프 장치가 열려 있는 경우 `which = 번호`로 변경
   - `dev.list()`: 현재 열려 있는 그래픽 장치 목록 조회
   - `dev.off()`: 현재 작업 중인 그래픽 장치 중지
   - `graphics.off()`: 열려있는 모든 그래픽 장치 중지


- R 그래프의 구조

\footnotesize

<div class="figure" style="text-align: center">
<img src="05-data-visualization_files/figure-epub3/unnamed-chunk-4-1.svg" alt="R 그래프영역"  />
<p class="caption">(\#fig:unnamed-chunk-4)R 그래프영역</p>
</div>

 \normalsize

- Figure region: 범례(legend), x축, y축, 도표 등을 그래프가 표현하는 모든 구성요소를 포함하는 영역(plot region 포함)
- Plot region: 도표 부분 출력되는 영역
- Figure margin: figure region 안에서 plot region의 여백 부분을 나타내며, x, y 축 레이블(label), 제목(title), 각 축의 tick 및 값 등이 주로 위치하는 영역
- Outer margin: figure region 밖의 여백 부분


\footnotesize

\BeginKnitrBlock{rmdnote}<div class="rmdnote">R 기본 그래프 함수에 대한 강의 내용은 주로 [AIMS-R-users](http://users.monash.edu.au/~murray/AIMS-R-users/ws/ws11.html)에서 참고를 함</div>\EndKnitrBlock{rmdnote}

 \normalsize


그래프의 요소: **점(point)**, **선(line)**, **면(area)**, , **텍스트(text)**, **축(axis)**, **눈금(tick)**, **범례(legend)** 등


- **저수준 그래프 함수(low level plotting function)**: 위의 그래프 요소들을 개별적으로 작업(좌표축 정의, 여백 정의)하기 위한 함수군
- **고수준 그래프 함수(high level plotting function)**: 그래프의 함수 기능(저수준 그래프 함수)를 모아서 하나의 완성된 도표(산점도, 막대도표, 히스토그램, 상자그림 등)를 생성할 수 있는 함수군
   - 고수준 그래프 함수를 호출할 경우 자동으로 그래픽 장치가 열려서 `win.graph()` 등을 사용할 필요가 없으나, 이미 호출된 그래프는 사라짐
   
   
\footnotesize

\BeginKnitrBlock{rmdcaution}<div class="rmdcaution">**주의**: 일반적으로 R 기본 그래픽 함수로 도표 작성 시 저수준 그래프 함수는 고수준 그래프 함수로 생성한 그래프에 부가적 기능을 추가하기 위해 사용됨. 따라서 저수준 그래프 함수군은 고수준 그래프 함수을 통해 먼저 생성한 그래프(주로 아래 설명할 `plot()` 함수) 위에 적용됨. 
</div>\EndKnitrBlock{rmdcaution}

 \normalsize


## 고수준 그래프 함수 {#high-level-graph}

### **`plot()` 함수** {#plot-fun}

- R의 가장 대표적인 2차원 고수준 그래프 출력 함수
- `plot()`의 가장 일반적인 용도는 그래프 장치를 설정(축, 값의 범위 등) 후 저수준 그래프 함수(축, 선, 점, 면 등)를 그래프 장치에 적용
- 데이터가 저장되어 있는 객체(벡터, 행렬, 데이터 프레임 등) 하나 이상을 함수의 인수(argument)로 사용
- 데이터의 클래스에 따라 출력되는 그래프 결과가 다름 $\rightarrow$ `methods(plot)`을 통해 `plot()` 함수가 적용되는 클래스 확인 가능


\footnotesize


```r
#각 클래스에 적용되는 plot() 함수 리스트
methods(plot)
```

```
 [1] plot,ANY-method        plot,color-method      plot.acf*             
 [4] plot.ACF*              plot.augPred*          plot.compareFits*     
 [7] plot.data.frame*       plot.decomposed.ts*    plot.default          
[10] plot.dendrogram*       plot.density*          plot.ecdf             
[13] plot.factor*           plot.formula*          plot.function         
[16] plot.ggplot*           plot.gls*              plot.gtable*          
[19] plot.hcl_palettes*     plot.hclust*           plot.histogram*       
[22] plot.HoltWinters*      plot.intervals.lmList* plot.isoreg*          
[25] plot.lm*               plot.lme*              plot.lmList*          
[28] plot.medpolish*        plot.mlm*              plot.nffGroupedData*  
[31] plot.nfnGroupedData*   plot.nls*              plot.nmGroupedData*   
[34] plot.pdMat*            plot.ppr*              plot.prcomp*          
[37] plot.princomp*         plot.profile.nls*      plot.R6*              
[40] plot.ranef.lme*        plot.ranef.lmList*     plot.raster*          
[43] plot.shingle*          plot.simulate.lme*     plot.spec*            
[46] plot.stepfun           plot.stl*              plot.table*           
[49] plot.trans*            plot.trellis*          plot.ts               
[52] plot.tskernel*         plot.TukeyHSD*         plot.Variogram*       
see '?methods' for accessing help and source code
```

```r
#예시 1: 객체 클래스가 데이터 프레임인 경우
# mtcars 데이터 예시
class(mtcars)
```

```
[1] "data.frame"
```

```r
plot(mtcars)
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-7-1.svg)<!-- -->

 \normalsize

\footnotesize


```r
# 예시2: lm()으로 도출된 객체(list)
## 연비(mpg)를 종속 변수, 배기량(disp)을 독립변수로 한 회귀모형
## lm() 함수 사용 -> 객체 클래스는 lm

mod <- lm(mpg ~ disp, data = mtcars)
class(mod)
```

```
[1] "lm"
```

```r
par(mfrow = c(2, 2)) # 4개 도표를 한 화면에 표시(2행, 2열)
plot(mod)
dev.off() # 활성화된 그래프 장치 닫기
```

```
null device 
          1 
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-8-1.svg)<!-- -->

 \normalsize

\footnotesize


```r
# 예시3: 테이블 객체
class(Titanic)
```

```
[1] "table"
```

```r
plot(Titanic)
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-9-1.svg)<!-- -->

 \normalsize


- 객체의 클래스가 벡터나 행렬인 경우, 객체에 저장된 데이터를 2차원 평면(x-y 좌표)에 출력

\footnotesize


```r
# 예시1: 데이터 객체를 하나만 인수로 받는 경우
# -> x축은 객체의 색인이고, x의 데이터는 y 좌표에 매핑
x <- mtcars$disp
y <- mtcars$mpg

plot(x); plot(y)
```

<img src="05-data-visualization_files/figure-epub3/unnamed-chunk-10-1.svg" width="50%" /><img src="05-data-visualization_files/figure-epub3/unnamed-chunk-10-2.svg" width="50%" />

 \normalsize

\footnotesize


```r
# 두개의 객체를 인수로 받은 경우
# -> 2차원 산점도 출력

plot(x, y)
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-11-1.svg)<!-- -->

 \normalsize

- `plot()` 함수의 세부 옵션

\footnotesize


```r
plot(
  x, # x 축에 대응하는 데이터 객체
  y, # y 축에 대응하는 데이터 객체
  type, # 그래프 타입(예시 참조)
  main, # 제목 
  sub,  # 부제목 
  xlim, ylim, # x, y 축 범위 지정
  xlab, ylab, # x-y 축 이름
  lty, # 선 모양
  pch, # 점 모양
  cex, # 점 및 텍스트 크기
  lwd, # 선 굵기
  col  # 색상
)
```

 \normalsize

- `type` 인수: 그래프 타입 지정

\footnotesize


```r
# BOD 데이터셋 이용
x <- BOD$Time; y <- BOD$demand
x; y
```

```
[1] 1 2 3 4 5 7
```

```
[1]  8.3 10.3 19.0 16.0 15.6 19.8
```

```r
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
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-13-1.svg)<!-- -->

```r
par(op)
```

 \normalsize

- `xlim`, `ylim` 인수: x, y 축의 범위 지정


\footnotesize


```r
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
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-14-1.svg)<!-- -->

 \normalsize

- `xlab`, `ylab` 인수: x축과 y축 이름 지정

\footnotesize


```r
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
```

```
null device 
          1 
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-15-1.svg)<!-- -->

 \normalsize


- `lty` 인수: 선의 형태 지정

\footnotesize


```r
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
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-16-1.svg)<!-- -->

 \normalsize


- `pch` 인수: 점(point)의 모양을 지정

\footnotesize


```r
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
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-17-1.svg)<!-- -->

 \normalsize

- `cex` 인수: 텍스트 및 점의 크기 지정
   - `cex.axis`: 각 축의 눈금 레이블 크기 조정
   - `cex.lab`: x-y 축의 이름 크기 조정
   - `cex.main`: 그림 제목 크기 조정
   - `cex.sub`: 부제목 크기 조정

- 텍스트 `cex` 인수 적용 예시

\footnotesize


```r
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
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-18-1.svg)<!-- -->

 \normalsize

- `lwd` 인수: 선의 두께 지정
   - 점 `cex` 크기와 `lwd` 두께 


\footnotesize


```r
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
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-19-1.svg)<!-- -->

 \normalsize

- `col` 인수: 그래프의 점, 면, 선의 색상 
- `palette()` 함수를 통해 그래픽 기본 색상 확인(총 8개)

\footnotesize

<img src="figures/r-graphic-palette.png" width="100%" style="display: block; margin: auto;" />

 \normalsize

- `colors()`를 통해 R에서 기본으로 제공하는 색상 확인 가능(총 657개)
- 내장 색상 팔레트: `n` 개의 색상을 반환하고, 색상의 투명도는 `alpha` 인수를 통해 조정
   - `rainbow(n)`: Red $\rightarrow$ Violet
   - `heat.colors(n)`: White $\rightarrow$ Orange $\rightarrow$ Red
   - `terrain.colors(n)`: White $\rightarrow$ Brown $\rightarrow$ Green
   - `topo.colors(n)`: White $\rightarrow$ Brown $\rightarrow$ Green $\rightarrow$ Blue
   - `grey(n)`: White $\rightarrow$ Black

- [R Color Chart](https://rstudio-pubs-static.s3.amazonaws.com/3486_79191ad32cf74955b4502b8530aad627.html) 참고


### 주요 고수준 그래픽 함수{#main-high-level-graph}

#### **산점도** {#scatter-plot .unnumbered}

**`car::scatterplot()`**

- `plot(x, y)`를 통해 2차원 산점도를 그릴 수 있으나, car 패키지에 내장되어 있는 해당 함수를 이용해 보다 많은 정보(상자그림, 회귀곡선 등)를 포함

\footnotesize


```r
# car 패키지 설치
# install.packages("car")
# require(car)
car::scatterplot(mpg ~ disp, data = mtcars)
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-21-1.svg)<!-- -->

 \normalsize

- `plot()` 함수의 인수 적용 가능

\footnotesize


```r
# help(scatterplot) 참고
car::scatterplot(mpg ~ disp, data = mtcars, 
                 regLine = list(method = lm, lty = 1, col = "red"), 
                 col = "black", cex = 2, pch = 16)
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-22-1.svg)<!-- -->

 \normalsize


- `pairs()`: 산점도 행렬을 생성해주는 함수로, 객체의 클래스가 데이터 프레임인 경우 `plot(dat)`과 동일한 그래프를 반환

\footnotesize


```r
# iris dataset
plot(iris)
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-23-1.svg)<!-- -->

 \normalsize

- `car::scatterplotMatrix()`: R graphics 패키지의 `pair()`와 유사하나 각 변수 쌍별 회귀 곡선 및 분포 확인 가능


\footnotesize


```r
# iris dataset
car::scatterplotMatrix(iris, col = "black")
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-24-1.svg)<!-- -->

 \normalsize


\footnotesize


```r
# help(scatterplotMatrix)
car::scatterplotMatrix(iris, col = c("red", "blue", "green"), 
                       smooth = FALSE, 
                       groups = iris$Species, 
                       by.groups = FALSE, 
                       regLine = list(method = lm, lwd = 1, col = "gray"), 
                       pch = (15:17))
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-25-1.svg)<!-- -->

 \normalsize

#### 행렬 그래프 {#mat-plot .unnumbered}

- 행렬 객체를 `plot()` 함수의 입력으로 사용한 경우 1-2 번째 열 데이터로 산점도를 출력

\footnotesize


```r
# 행렬을 plot() 함수의 입력으로 받은 경우
par(mfrow = c(1,2))
x <- seq(-5, 5, 0.01)
X <- mapply(dnorm, 
            list(a = x, b = x, c = x), 
            c(0, 1, 2), 
            c(1, 2, 4))
X <- matrix(X, nrow = length(x), ncol = 3)
head(X)
```

```
             [,1]        [,2]       [,3]
[1,] 1.486720e-06 0.002215924 0.02156933
[2,] 1.562867e-06 0.002249385 0.02166383
[3,] 1.642751e-06 0.002283295 0.02175862
[4,] 1.726545e-06 0.002317658 0.02185368
[5,] 1.814431e-06 0.002352479 0.02194902
[6,] 1.906601e-06 0.002387763 0.02204463
```

```r
# plot() 함수를 이용한 행렬 그래프 출력
plot(X, type = "l", main = "plot matrix (X) using plot()")
text(0.2, 0.05, labels = "plot(X, type = `l`)")
plot(X[, 1], X[, 2], type = "l", 
     main = "scatterplot between X[, 1] and X[, 2]")
text(0.2, 0.05, labels = "plot(X[,1], X[,2], type = `l`)")
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-26-1.svg)<!-- -->

 \normalsize

- `matplot()`: 객체의 클래스가 행렬(matrix) 형태로 이루어진 데이터에 대한 그래프 출력
   - 열 기준으로 그래프 출력
   - x 가 주어지지 않은 경우, 행렬의 색인을 x 축으로 사용

\footnotesize


```r
# matplot 도표
par(mfrow = c(1, 2))
matplot(X, type = "l", 
        lwd = 2, 
        main = "matplot() without x")
matplot(x, X, type = "l", 
        lwd = 2, 
        main = "matplot() with x")
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-27-1.svg)<!-- -->

 \normalsize


#### 히스토그램{#histogram .unnumbered}

**`hist()`**

\footnotesize


```r
hist(
  x, # vector 객체
  breaks, # 빈도 계산을 위한 구간
  freq, # y축 빈도 또는 밀도(density) 여부
  col, # 막대 색상 지정
  border, # 막대 테두리 색 지정
  labels, # 막대 위 y 값 레이블 출력 여부 
  ...
)
```

 \normalsize


\footnotesize


```r
# airquality 데이터 셋
# help(airquality) 참고
glimpse(airquality)
```

```
Observations: 153
Variables: 6
$ Ozone   <int> 41, 36, 12, 18, NA, 28, 23, 19, 8, NA, 7, 16, 11, 14, 18, 1...
$ Solar.R <int> 190, 118, 149, 313, NA, NA, 299, 99, 19, 194, NA, 256, 290,...
$ Wind    <dbl> 7.4, 8.0, 12.6, 11.5, 14.3, 14.9, 8.6, 13.8, 20.1, 8.6, 6.9...
$ Temp    <int> 67, 72, 74, 62, 56, 66, 65, 59, 61, 69, 74, 69, 66, 68, 58,...
$ Month   <int> 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,...
$ Day     <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, ...
```

```r
temp <- airquality$Temp
hist(temp)
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-29-1.svg)<!-- -->

 \normalsize

- `hist()` 함수의 반환값

\footnotesize


```r
h <- hist(temp, plot = FALSE) # 그래프를 반환하지 않음
h
```

```
$breaks
 [1]  55  60  65  70  75  80  85  90  95 100

$counts
[1]  8 10 15 19 33 34 20 12  2

$density
[1] 0.010457516 0.013071895 0.019607843 0.024836601 0.043137255 0.044444444
[7] 0.026143791 0.015686275 0.002614379

$mids
[1] 57.5 62.5 67.5 72.5 77.5 82.5 87.5 92.5 97.5

$xname
[1] "temp"

$equidist
[1] TRUE

attr(,"class")
[1] "histogram"
```

 \normalsize


- `hist()` 함수의 인수 사용(`plot()` 함수의 인수 거의 대부분 사용 가능)

\footnotesize


```r
hist(temp,
main="La Guardia Airport 일중 최고 기온",
xlab = "온도",
ylab = "밀도",
xlim = c(50,100),
col = "orange",
freq = FALSE
)
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-31-1.svg)<!-- -->

 \normalsize

- `labels` 인수를 통해 빈도값 출력

\footnotesize


```r
hist(temp,
main = "La Guardia Airport 일중 최고 기온",
xlab = "온도",
ylab = "빈도",
xlim = c(50,100),
col = "orange",
labels = TRUE
)
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-32-1.svg)<!-- -->

 \normalsize

- `breaks` 인수를 통해 막대 구간 조정

\footnotesize


```r
op <- par(mfrow = c(1, 2))
hist(temp, breaks = 4, main = "breaks = 4")
hist(temp, breaks = 15, main = "breaks = 15")
par(op); dev.off()
```

```
null device 
          1 
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-33-1.svg)<!-- -->

 \normalsize


#### 막대 그래프 {#bar-plot .unnumbered}

- 히스토그램(`hist()`)은 연속형 데이터의 구간 별 빈도 또는 밀도를 나타냄
- 막대 도표(bar plot)는 해당 좌표의 값(value)를 나타냄

\footnotesize


```r
x = c(1,2,2,1,3,3,1,5)
par(mfrow = c(1, 2))
hist(x); barplot(x)
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-34-1.svg)<!-- -->

 \normalsize

**barplot()**

- `help(barplot)` 을 통해 함수 사용 방법 확인
- 보통 요약통계량(예: 그룹별 빈도, 평군)의 시각화를 위해 많이 사용

\footnotesize


```r
## Wool dataset: warpbreaks 
## 제직 중 방적 횟수
## 직조기 당 날실 파손 횟수 데이터
head(warpbreaks)
```

```
  breaks wool tension
1     26    A       L
2     30    A       L
3     54    A       L
4     25    A       L
5     70    A       L
6     52    A       L
```

```r
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
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-35-1.svg)<!-- -->

 \normalsize

- 데이터 프레임을 대상으로 `barplot()` 실행 시 수식 표현 가능
- 막대도표 + 표준오차

\footnotesize


```r
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
```

![](05-data-visualization_files/figure-epub3/unnamed-chunk-36-1.svg)<!-- -->

 \normalsize


<!-- #### 상자 그림 {#boxplot .unnumbered} -->

<!-- #### 바이올린 도표  -->

<!-- #### 모자이크 도표 -->

<!-- ## 저수준 그래프 함수 -->

<!-- ### lines() -->

<!-- ### ablines() -->

<!-- ### points() -->

<!-- ### text() -->

<!-- ### R 기본 그래프 이미지 파일로 저장 -->


<!-- ## ggplot2 -->

<!-- ### 기본 문법 -->

<!-- ### `geom_point()` -->

<!-- ### `geom_line()` -->

<!-- ### `geom_bar()` -->

<!-- ### `geom_errorbar()` -->

<!-- ### `geom_histogram()` -->

<!-- ### `geom_boxplot()` -->

<!-- ### `geom_density()` -->

<!-- ### `geom_smooth()` -->





