---
output: html_document
editor_options: 
  chunk_output_type: console
---

# R 수학 함수, 분포 함수, 모형식 표현




## 수학함수

R은 광범위한 수학 함수를 내장하고 있고 다음 열거한 함수 목록은 그 일부임

- `exp()`: 지수(`e`)를 밑으로 하는 지수 함수
- `log()`: 자연 로그 함수
- `log10()`: 10을 밑으로 하는 로그
- `sqrt()`: 제곱근
- `abs()`: 절대값
- `sin()`, `cos()`, `tan()` ... : 삼각함수
- `min()`, `max()`: 벡터 내 최솟값과 최댓값 반환
- `which.min()`, `which.max()`: 벡터 내 최댓값과 최솟값에 대한 인덱스 반환
- `sum()`, `prod()`: 벡터 원소들의 합과 곱 결과 반환
- `cumsum()`, `cumprod()`: 백터 원소들의 누적합과 누적곱
- `round()`, `floor()`, `ceiling()`: 수치형 값의 반올림, 내림, 올림
- `factorial()`: 팩토리얼 함수 $n!$
- `choose()`: 조합 함수 ($_n C_r = \frac{n!}{r!(n-r)!}$)
- `rev()`: 역순으로 배열 
- `rank()`: 백터 원소 값들의 순위 반환
- `sweep()`: 각 원소에서 요약통계량(예: 평균)으로부터 편차 계산 시 유용

**확장예제1: 확률계산**

- $P_i$: $n$ 개의 독립적인 사건이 있고 $i$ 번째 사건이 발생할 확률
- $n = 3$ 일 때, 각 사건의 이름을 각각 A, B, C 라고 할 때 이 중 사건 하나가 발생할 확률

\footnotesize


```r
P(사건 하나가 발생할 확률) = 
P(A가 일어나고 B와 C가 일어나지 않을 확률) + 
  P(A가 일어나지 않고 B가 일어나고 C가 일어나지 않을 확률) + 
  P(A, B가 일어나지 않고 C만 일어날 확률)
```

 \normalsize

- 여기서 P(A가 일어나고 B와 C가 일어나지 않을 확률) = $P_A(1-P_B)(1-P_C)$ $\rightarrow$ 나머지도 마찬가지임
- 일반화 하면

$$
\sum_{i=1}^{n} P_i(1-P_1)(1-P_2)\cdots (1-P_{i-1})(1-P_{i+1})\cdots (1-P_{n})
$$


- 수학함수로 구현: `prod()` 함수 활용

\footnotesize


```r
# 벡터 p에서 p_i 계산 함수
p <- c(0.2, 0.4, 0.3)
notp <- 1 - p
p[1] * prod(notp[-1]) +
p[2] * prod(notp[-2]) +
p[3] * prod(notp[-3])
```

```
[1] 0.452
```

```r
p <- runif(10, 0, 1)
notp <- 1 - p
# 일반화 하려면 어떻게 해야 할까? -> 반복문 활용
tot <- 0
for (i in 1:length(p)) {
  tot <- tot + p[i] * prod(notp[-i])
}
```

 \normalsize


**확장예제2: 누적합, 누적곱**

\footnotesize


```r
# cumsum, cumprod 함수 사용 예시
x <- c(2, 4, 1, 3, 7, 8)
cumsum(x); cumprod(x)
```

```
[1]  2  6  7 10 17 25
```

```
[1]    2    8    8   24  168 1344
```

 \normalsize


**확장예제3: 최솟값, 최댓값**

\footnotesize


```r
# which.min, which.max 사용 예시
set.seed(100)
x <- sample(1:100, 100)
idx_min <- which.min(x)
x[idx_min]
```

```
[1] 1
```

```r
idx_max <- which.max(x)
x[idx_max]
```

```
[1] 100
```

```r
# min(), max(), pmin(), pmax() 비교
set.seed(5)
x <- runif(5, 2, 4)
y <- runif(5, 2, 4)
z <- cbind(x, y)

min(z); max(z) # z의 전체 값 중 최솟값과 최댓값 반환
```

```
[1] 2.2093
```

```
[1] 3.913
```

```r
pmin(z); pmax(z) # 아무 값을 반환하지 않음
```

```
            x        y
[1,] 2.400429 3.402115
[2,] 3.370437 3.055920
[3,] 3.833752 3.615870
[4,] 2.568799 3.913000
[5,] 2.209300 2.220906
```

```
            x        y
[1,] 2.400429 3.402115
[2,] 3.370437 3.055920
[3,] 3.833752 3.615870
[4,] 2.568799 3.913000
[5,] 2.209300 2.220906
```

```r
# 두 열을 비교해 각 행에서 최솟값, 최댓값을 반환
pmin(z[, 1], z[, 2]) 
```

```
[1] 2.400429 3.055920 3.615870 2.568799 2.209300
```

```r
pmax(z[, 1], z[, 2])
```

```
[1] 3.402115 3.370437 3.833752 3.913000 2.220906
```

 \normalsize


**확장예제5: `sweep()` 함수 활용**


\footnotesize


```r
X <- matrix(1:12, 3, 4)
m <- apply(X, 2, mean)
M <- matrix(m, ncol = 4, nrow = 3, byrow = TRUE)
X - M
```

```
     [,1] [,2] [,3] [,4]
[1,]   -1   -1   -1   -1
[2,]    0    0    0    0
[3,]    1    1    1    1
```

```r
# sweep 함수 활용
sweep(X, 2, colMeans(X))
```

```
     [,1] [,2] [,3] [,4]
[1,]   -1   -1   -1   -1
[2,]    0    0    0    0
[3,]    1    1    1    1
```

 \normalsize



**확장예제6: 미분/적분**

- 문자의 미분 및 수치 적분 가능

\footnotesize


```r
# 도함수 구하기
## D() 함수 사용
dx <- D(expression(exp(x^2)), "x") # exp(x^2)을 x에 대해서 1차 미분한 도함수
set.seed(3)
x <- runif(3, 1, 2)
eval(dx) # 위 입력한 x에 대한 도함수 값 출력
```

```
[1]  9.141245 94.842390 18.856751
```

```r
## deriv() 함수 사용
grad <- D(expression(x*sin(x)), "x")
# 도함수를 R의 function으로 바로 반환 가능
dx2 <- deriv(expression(x*sin(x)), "x", function.arg = TRUE) 
dx2(x)
```

```
[1] 1.074580 1.757109 1.361092
attr(,"gradient")
             x
[1,] 1.3778035
[2,] 0.5482219
[3,] 1.2386966
```

```r
# 수치 적분
## integrate() 함수 사용
## 주어진 함수의 적분식을 구한 후, 입력 구간에 대한 적분값 계산
integrate(f = function(x) x^2, lower = 0, upper = 1)
```

```
0.3333333 with absolute error < 3.7e-15
```

 \normalsize



## 통계 분포 함수

R은 현존하는 대부분의 통계 확률 분포 함수를 제공하고 `접두사 + 분포이름` 형태의 함수명을 갖고 있으며, 보통 다음과 같은 접두사를 통해 분포 함수 생성

- `d`: 밀도(density)의 약어로 확률 밀도함수(probability density function, pdf) 또는 이산형 분포의 확률 질량 함수(probability mass function, pmf)
- `q`: 분위수(quantile)의 약어로 상위 %에 해당하는 $x$ 값을 반환
- `p`: 누적분포함수(cumulative density function, cdf)
- `r`: 특정 분포로부터 난수(확률변수) 생성


> 예: `dnorm()`, `qnorm()`, `pnorm()`, `rnorm()` 은 정규분포 관련 함수임


\footnotesize

<table class=" lightable-paper lightable-striped" style='font-size: 12px; font-family: "Arial Narrow", arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;'>
<caption style="font-size: initial !important;">(\#tab:unnamed-chunk-7)일반적인 R 통계 분포함수(일부 제시)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Distribution </th>
   <th style="text-align:left;"> Density/Mass function </th>
   <th style="text-align:left;"> R pdf </th>
   <th style="text-align:left;"> R cdf </th>
   <th style="text-align:left;"> R quantile </th>
   <th style="text-align:left;"> RV generation </th>
   <th style="text-align:left;"> Parameter </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 균일분포 </td>
   <td style="text-align:left;"> $\frac{1}{b -a},~\mathrm{for}~x \in [a, b]$ </td>
   <td style="text-align:left;"> dunif </td>
   <td style="text-align:left;"> punif </td>
   <td style="text-align:left;"> qunif </td>
   <td style="text-align:left;"> runif </td>
   <td style="text-align:left;"> min (a), max (b) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 지수분포 </td>
   <td style="text-align:left;"> $\lambda \exp{(-\lambda x)}$ </td>
   <td style="text-align:left;"> dexp </td>
   <td style="text-align:left;"> pexp </td>
   <td style="text-align:left;"> qexp </td>
   <td style="text-align:left;"> rexp </td>
   <td style="text-align:left;"> rate ($\lambda$) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 정규분포 </td>
   <td style="text-align:left;"> $\frac{1}{\sqrt{2\pi}\sigma}\exp \left\{-\frac{(x - \mu)^2}{2\sigma^2} \right \}$ </td>
   <td style="text-align:left;"> dnorm </td>
   <td style="text-align:left;"> pnorm </td>
   <td style="text-align:left;"> qnorm </td>
   <td style="text-align:left;"> rnorm </td>
   <td style="text-align:left;"> mean ($\mu$), sd ($\sigma$) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> $\chi^2$ 분포 </td>
   <td style="text-align:left;"> $\frac{1}{\Gamma(\nu/2)2^{\nu/2}}x^{(\nu/2) - 1}e^{(-x/2)}$ </td>
   <td style="text-align:left;"> dchisq </td>
   <td style="text-align:left;"> pchisq </td>
   <td style="text-align:left;"> qchisq </td>
   <td style="text-align:left;"> rchisq </td>
   <td style="text-align:left;"> df ($\nu$) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> $t$ 분포 </td>
   <td style="text-align:left;"> $\frac{\Gamma(\frac{\nu + 1}{2})}{\Gamma{(\frac{\nu}{2}})}\frac{1}{\sqrt{\nu\pi}}\frac{1}{(1 + x^2/\nu)^{(\nu + 1)/2}}$ </td>
   <td style="text-align:left;"> dt </td>
   <td style="text-align:left;"> pt </td>
   <td style="text-align:left;"> qt </td>
   <td style="text-align:left;"> rt </td>
   <td style="text-align:left;"> df ($\nu$) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 이항분포 </td>
   <td style="text-align:left;"> ${n \choose x} p^x (1 - p)^{n - x}$ </td>
   <td style="text-align:left;"> dbinom </td>
   <td style="text-align:left;"> pbinom </td>
   <td style="text-align:left;"> qbinom </td>
   <td style="text-align:left;"> rbinom </td>
   <td style="text-align:left;"> size ($n$), prob ($p$) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 포아송 분포 </td>
   <td style="text-align:left;"> $\frac{e^{-\lambda}\lambda^x}{x!}$ </td>
   <td style="text-align:left;"> dpois </td>
   <td style="text-align:left;"> ppois </td>
   <td style="text-align:left;"> qpois </td>
   <td style="text-align:left;"> rpois </td>
   <td style="text-align:left;"> lambda ($\lambda$) </td>
  </tr>
</tbody>
</table>

 \normalsize


**예제: 확률 분포 함수**


\footnotesize


```r
## 카이제곱분포 
x <- seq(0, 30, by = 0.1)
y <- dchisq(x, df = 3) # 자유도가 3인 카이제곱분포 밀도 함수
plot(x, y, type = "l",
     bty = "n", 
     xlab = "", ylab = "", 
     main = expression(paste("PDF of ", ~chi^2, " distribution")), 
     lwd = 2, 
     cex.main = 2)

# P(5 < V < 10)
pchisq(10, df = 3) - pchisq(5, df = 3)
```

```
[1] 0.153231
```

```r
## 그림에 표현
idx <- x >= 5 & x <= 10
polygon(c(5, x[idx], 10), 
        c(0, y[idx], 0), 
        col = "blue", 
        border = "blue")
abline(h = 0, col = "darkgray")
text(x = 10, y = 0.05, cex = 2, 
     bquote(P({5 <= V} <= 10 ) ==
              .(sprintf("%.3f", pchisq(10, df = 3) - pchisq(5, df = 3)))),
     adj = 0)
```

<img src="04-math-distribution-functions_files/figure-html/unnamed-chunk-8-1.svg" width="672" />

```r
# 분위수
qchisq(pchisq(10, df = 3), df = 3) 
```

```
[1] 10
```

```r
# 난수 생성
v <- rchisq(1000, df = 3)
mean(v) # 카이제곱분포의 평균은 이론적으로 자유도 값과 같음 
```

```
[1] 2.994
```

 \normalsize



## 모형식 표현

<!-- ### Prerequisites  -->

<!-- #### 표준 평가(standard evaluation)와 비표준 평가(non-standard evaluation) {.unnumbered} -->

<!-- 1. 표준 평가(standard evaluation): R이 변수와 그에 대한 값을 찾아가는 일반적인 방법 $\rightarrow$ Lexical Scoping -->


<!-- ```{r} -->
<!-- d <- data.frame(x = c(1, 3, 5), y = c(2, 4, 6)) -->
<!-- x <- "y" -->
<!-- d[, x, drop = FALSE] -->

<!-- ``` -->


<!-- - `x` 는 변수명이고 `x`에 할당된 값 "y"를 사용해 데이터 열을 입력 -->
<!-- - 위 예제에서 데이터프레임 `d` 에서 변수명 "x"를 가져오고 싶다면  -->


<!-- ```{r, eval=FALSE} -->
<!-- d[, "x", drop = FALSE] -->
<!-- ``` -->


<!-- > 표준평가에서 사용자가 작성한 이름은 R 환경에서 정의한 값에 대한 참조로 취급하고,  -->
<!-- 특정 객체 내 이름을 참조하기 위해서는 문자열로 표현되는 리터럴 값(literal value)이  -->
<!-- 필요하고, 이를 위해 따옴표를 사용함 -->


<!-- 2. 비표준 평가(non-standard evaluation, NSE): 대부분의 프로그래밍 언어는 함수의 인수로  -->
<!-- 값만 부여할 수 있는 반면, R은 인수에 표현식을 할당해 함수의 인수로 지정 가능. 이러한  -->
<!-- 표현식을 인수로 할당한 겨우 표현을 평가(계산 또는 실행)하지 않고, 함수 내부의  -->
<!-- 원하는 곳에서 실행하도록 하는 방식 -->


<!-- ```{r, eval=FALSE} -->
<!-- mtcars[mtcars$mpg < 20 & mtcars$cyl == 6, ] -->
<!-- subset(mtcars, mpg < 20 & cyl == 6) -->

<!-- ``` -->

<!-- > 비표준 평가 시 사용자가 작성한 이름은 리터럴로 취급 -->



<!-- ```{block2, type="rmdimportant"} -->

<!-- **R의 유래**: LISP 프로그래밍 언어가 출발점 -->

<!--    - LISP: (**LIS**)t (**P**)rocessing 의 약어 -->
<!--    - Meta programming -->
<!--    - REPL 방식으로 작동: (**R**)ead [읽고], (**E**)valuate [평가하고], (**P**)rint [출력하는] 과정을 (**L**)oop [반복] -->


<!-- **예**: 사용자가 콘솔에 '1+2'를 입력 $\rightarrow$ '1+2'는 단순 문자열임 -->

<!-- 1. Read -->
<!--    - R은 '1+2' 을 R 문법에 맞춰서 읽음(Read). 이러한 과정을 파싱(parsing)이라고 함.  -->
<!--    - Parsing 처리 이후 '1+2'는 `+()` 함수에 1과 2를 인수로 넘겨 처리 -->

<!-- 2. Evaluate: `+(1, 2)`를 수행 후 3이라는 결과를 얻음 -->
<!-- 3. Print: R 콘솔에 3을 출력 -->

<!-- ``` -->


<!-- #### `substitute()`/`deparse()` 함수 {.unnumbered} -->

<!-- > - R 코드 상 NSE 구현을 가능하게 해주는 함수 중 하나  -->
<!-- > - 프로그램의 일부를 파싱만 하고 평가(evaluate) 하지 않고 코드를 확인 -->
<!-- > - Lexical scoping 사용 $\rightarrow$ `substitute(x)`는 `x` 가 무엇인지를 참조 후,  -->
<!-- x에 들어 있는 표현식을 인용 -->
<!-- > - `substitute()`가 반환한 결과 $\rightarrow$ **promise** -->


<!-- ```{block2, type="rmdnote"} -->
<!-- **promise**: 값을 계산하기 위해 필요한 표현(**expression)**과 환경으로  -->
<!-- 일반적으로 주어진 R 환경에서 즉각적으로 평가되고 값을 산출하기 때문에  -->
<!-- 사용자가 인식하지 못함 -->

<!-- ``` -->


<!-- ```{r} -->
<!-- f <- function(x) substitute(x) -->

<!-- # x가 실행되지 않고 파싱 결과만 출력 -->
<!-- f(1+2); f(1:10) -->

<!-- x <- 10 -->
<!-- f(x = x) -->

<!-- y <- 13 -->
<!-- f(x = x + y^2) -->

<!-- ``` -->


<!-- > - `substitute()` 함수는 `deparse()` 함수와 쌍을 이룸 -->
<!-- > - `deparse()` 함수는 `substitute()` 함수의 결과인 표현식을 문자형 벡터로 변환 -->


<!-- ```{r} -->
<!-- g <- function(x) deparse(substitute(x)) -->
<!-- f(1+2); g(1+2) -->
<!-- g(x); g(x = x + y^2) -->


<!-- ``` -->



\footnotesize

\BeginKnitrBlock{rmdtip}<div class="rmdtip">**R에서 통계적 모형 표현 방법**

- 지금까지 별다른 설명 없이 `~`가 들어간 수식표현을 특정함수(예: `lm()`, `t.test()`, 심지어 그래프 생성에 필요한 함수 등)의 인수로 사용함.
- R은 (통계적) 모형을 표현하기 위해 **formula** 표현을 사용 $\rightarrow$ 일반적으로 `좌변 ~ 우변`형태로 표시
- 보통은 특정 함수 내에서 호출되며 데이터에 포함되어 있는 변수를 평가하지 않고 해당 함수에서 해석할 수 있도록 변수값을 불러올 수 있음.
- **formula**는 "language" 객체의 일종이며 "formula" 클래스를 속성으로 갖는 평가되지 않은 표현식(unevaluated expression)
</div>\EndKnitrBlock{rmdtip}

 \normalsize



\footnotesize


```r
typeof(quote(x + 10)) # 객체의 형태가 "language"
```

```
[1] "language"
```

```r
class(quote(x + 10)) # 객체의 클래스가 "call"
```

```
[1] "call"
```

 \normalsize

- R에서 **formula**을 특정하는 `~`의 의미는 "즉시 평가(evaluate)하지 않고 이 코드의 의미를 전달(캡쳐)" $\rightarrow$ 인용(quote) 연산자로 볼 수 있는 이유임

\footnotesize


```r
# 수식 표현
a <- y ~ x
b <- y ~ x + b
c <- ~ x + y + z

typeof(c); class(c); attributes(c)
```

```
[1] "language"
```

```
[1] "formula"
```

```
$class
[1] "formula"

$.Environment
<environment: R_GlobalEnv>
```

 \normalsize

- 가장 기본적인 **formula**의 형태는 아래와 같음


```
반응변수(response variable) ~ 독립변수(independent variables)
```


- `~` 는 "(좌변)은 (우변)의 함수로 나타낸 모형" 으로 해석됨. 
- 우변과 좌변 모두 일반적으로 여러 개의 변수들이 있을 수 있으며, 해당 변수듸 추가는 `+`로 표시됨
- 좌변은 반응변수, 우변은 설명변수를 의미

\footnotesize

\BeginKnitrBlock{rmdtip}<div class="rmdtip">일반적으로 좌편에 $y$로 표현되는 반응변수는 학문 분야에 따라 종속변수(dependent variable), 표적변수(target variable), 결과변수(outcome variable), 
레이블(label, $y$가 범주형일 경우) 등으로 명칭되며, 우변에 $y$를 설명하기 위해 사용하는 변수($x$)를 마찬가지로 분야와 성격에 따라 독립변수(independent variable), 
설명변수(exploratory variable), 예측변수(predictor variable), 위험 인자(risck factor), 공변량(covariate) 등으로 명칭된다. 
</div>\EndKnitrBlock{rmdtip}

 \normalsize


- **formula**를 구성하는 항으로 벡터 객체를 직접 사용할 수 있으나, 데이터 프레임의 변수명을 **formula**의 항으로 구성할 수 있음. 
- **formula**의 항으로 지정된 벡터 또는 변수들의 값은 **formula**를 호출해 사용할 때 까지 연결되지 않은 "언어"로써만 존재
- **formula**는 양면수식(two-sided formula, 좌변과 우변 모두에 하나 이상의 항이 존재)과 단면수식(one-sided formula, 우변에만 하나 이상의 항 존재)
 

\footnotesize


```r
set.seed(1)
x1 <- rnorm(100, 2, 4)
x2 <- runif(100, 2, 4)
x3 <- rpois(100, 3)
y <- 2*x1 + 3*x2 + 0.5*x3 + 5 + rnorm(100, 0, 4)

f1 <- y ~ x # y는 x의 함수
f2 <- y ~ x1 + x2 # y는 x1과 x2의 함수를 지칭하는 모형
typeof(f2); class(f2); attributes(f2)
```

```
[1] "language"
```

```
[1] "formula"
```

```
$class
[1] "formula"

$.Environment
<environment: R_GlobalEnv>
```

```r
names(iris)
```

```
[1] "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width"  "Species"     
```

```r
f3 <- Species ~ Sepal.Length + Sepal.Width + Petal.Length
# 붓꽃의 종은 꽃받침 길이와 너비, 꽃잎의 길이에 대한 함수


f4 <- ~ x1 + x2
f5 <- y ~ x1 + x2 + x3
length(f3); length(f4)
```

```
[1] 3
```

```
[1] 2
```

```r
f4[[1]]; f4[[2]]
```

```
`~`
```

```
x1 + x2
```

```r
f5[[1]]; f5[[2]]; f5[[3]]
```

```
`~`
```

```
y
```

```
x1 + x2 + x3
```

 \normalsize


**수식 사용 이유**

> - 변수 간의 관계를 알기 쉽게 표현
> - 복잡한 변수의 관계를 표현해 함수 내에서 손쉽게 해당 항에 대응하는 데이터 값에 접근 가능



**수식표현 방법**

- 위에서 기술환대로 `좌변항 ~ 우변항`으로 표현
- `formula()` 또는 `as.formula()` 함수를 통해 텍스트를 **formula** 형태로 생성 가능

\footnotesize


```r
f6 <- "y ~ x1 + x2 + x3"
h <- as.formula(f6)
h
```

```
y ~ x1 + x2 + x3
```

```r
h <- formula(f6)
h
```

```
y ~ x1 + x2 + x3
```

```r
fs <- c(f1, f2, f6) # formula 객체를 concatenate 할 경우 list 객체
fl <- lapply(fs, as.formula)
```

 \normalsize

**formula**로 표현한 모형의 항에 대응하는 값으로 데이터 행렬 및 데이터 프레임 생성

- `model.frame()`: formula 객체에 표현된 항에 대응하는 데이터 값으로 이루어진 데이터 프레임 반환
- `model.matrix()`: 디자인 행렬을 생성하는 함수로 



\footnotesize


```r
d1 <- model.frame(y ~ x1 + x2) # 벡터값을 데이터 프레임으로 반환
head(d1)
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["y"],"name":[1],"type":["dbl"],"align":["right"]},{"label":["x1"],"name":[2],"type":["dbl"],"align":["right"]},{"label":["x2"],"name":[3],"type":["dbl"],"align":["right"]}],"data":[{"1":"15.23103","2":"-0.5058152","3":"2.535016","_rn_":"1"},{"1":"25.03651","2":"2.7345733","3":"2.437291","_rn_":"2"},{"1":"19.26211","2":"-1.3425144","3":"3.033594","_rn_":"3"},{"1":"29.55232","2":"8.3811232","3":"2.537901","_rn_":"4"},{"1":"10.58213","2":"3.3180311","3":"2.362337","_rn_":"5"},{"1":"25.53836","2":"-1.2818735","3":"3.037152","_rn_":"6"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

```r
# formula를 구성하고 있는 변수명에 대응하는 변수를 데이터 프레임에서 추출
f3
```

```
Species ~ Sepal.Length + Sepal.Width + Petal.Length
```

```r
d2 <- model.frame(f3, iris) 
head(d2)
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["Species"],"name":[1],"type":["fct"],"align":["left"]},{"label":["Sepal.Length"],"name":[2],"type":["dbl"],"align":["right"]},{"label":["Sepal.Width"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["Petal.Length"],"name":[4],"type":["dbl"],"align":["right"]}],"data":[{"1":"setosa","2":"5.1","3":"3.5","4":"1.4","_rn_":"1"},{"1":"setosa","2":"4.9","3":"3.0","4":"1.4","_rn_":"2"},{"1":"setosa","2":"4.7","3":"3.2","4":"1.3","_rn_":"3"},{"1":"setosa","2":"4.6","3":"3.1","4":"1.5","_rn_":"4"},{"1":"setosa","2":"5.0","3":"3.6","4":"1.4","_rn_":"5"},{"1":"setosa","2":"5.4","3":"3.9","4":"1.7","_rn_":"6"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

```r
# model.matrix()에서는 디자인 행렬만 반환
# y 값은 포함하지 않고 우변에 해당하는 항에 대응하는 데이터 반환
X1 <- model.matrix(y ~ x1 + x2)
head(X1)
```

```
  (Intercept)         x1       x2
1           1 -0.5058152 2.535016
2           1  2.7345733 2.437291
3           1 -1.3425144 3.033594
4           1  8.3811232 2.537901
5           1  3.3180311 2.362337
6           1 -1.2818735 3.037152
```

 \normalsize


**formula** 관련 함수

- `terms()`: formula 객체에 포함되어 있는 항의 구조 파악 
- `all.vars()`:  formula에 포함되어 있는 변수명 추출
- `update()`: formula를 구성하는 항을 수정


\footnotesize


```r
terms(f2)
```

```
y ~ x1 + x2
attr(,"variables")
list(y, x1, x2)
attr(,"factors")
   x1 x2
y   0  0
x1  1  0
x2  0  1
attr(,"term.labels")
[1] "x1" "x2"
attr(,"order")
[1] 1 1
attr(,"intercept")
[1] 1
attr(,"response")
[1] 1
attr(,".Environment")
<environment: R_GlobalEnv>
```

```r
all.vars(f2)
```

```
[1] "y"  "x1" "x2"
```

```r
update(f2, ~ . + x3)
```

```
y ~ x1 + x2 + x3
```

 \normalsize



**formula**에 사용되는 연산자와 의미


| Symbol  | Example      | Meaning                             |
|---------|--------------|-------------------------------------|
| `+`     | `X + Z`      | 변수 항 포함                        |
| `-`     | `X + Z - X`  | 변수 항 제거                        |
| `:`     | `X:W`        | X와 W의 교호작용                    |
| `%in%`  | `X:W`        | 지분(nesting)                       |
| `*`     | `X*Z`        | X + Z + X:Z                         |
| `^`     | `(X+W+Z)^3`  | 3차 교호작용항까지 모든 항을 포함   |
| `I`     | `I(X^2)`     | as is: X^2을 포함                   |
| `1`     | `X - 1`      | 절편 제거                           |
| `.`     | `Y ~ .`      | 모든 변수 포함(X + W + Z)           |


\footnotesize

\BeginKnitrBlock{rmdtip}<div class="rmdtip">일반 연산 시 `A %in% B`의 의미는 `A`가 `B`의 원소를 포함하는지에 대한 논리값을 반환해 주지만, **formula**에서 `%in%`은 중첩 또는 지분(nesting)을 내포함. 
R의 리스트 객체는 중첩 및 지분 구조의 대표적 형태임. 예를 들어 리스트에 포함된 한 원소에 대응하는 데이터의 형태 및 값은 동일 리스트의 다른 원소에 대응한 
데이터의 형태 및 값이 다름. 즉, 리스트 객체는 한 객체에 여러 형태의 데이터 구조를 가질 수 있고 이를 중접된 구조라고 함. 

또한 실험계획법(experimental design)에서 지분 설계(nested design) 방법이 있는데, 두 개 요인(factor) A와 B가 존재할 때 A의 수준에 따른 B의 수준이 모두 다른 경우, 
즉 교호작용이 존재하지 않는 형태의 실험설계법을 지칭함. 예를 들어 A사와 B사의 오랜지 주스 당도에 차이가 있는지를 알기 위해 각 회사에서 생산하고 있는 주스 3종을 
랜덤하게 선택했다고 가정해 보자. 여기서 주 관심사는 두 회사에서 생산한 주스의 당도의 동질성이지 오랜지 주스 간 당도 차이는 관삼사항이 아님. 이 경우, 
주 관심요인은 회사(C)이고, 요인 C는 회사 A, B라는 두 개의 수준(level)을 갖고 있음. 오랜지 주스(O)는 각 회사 별로 3개의 수준을 갖고 있는데, 
각 회사에서 생산하는 오랜지 주스는 생산 공정에 차이가 있기 떄문에 각 회사에 지분되어 있음. 즉, 회사 A에서 생산한 오랜지 주스 O~1~, O~2~, O~3~은 
회사 B에서 생산한 O~1~, O~2~, O~3~과 다름. 
</div>\EndKnitrBlock{rmdtip}

 \normalsize



\footnotesize


```r
set.seed(10)
x <- runif(30)
z <- runif(30, 2, 3)
w <- sample(0:1, 30, replace = TRUE)
y <- 3 + 2.5*x + x^2 + 1.5*z + 0.5 * w + 2*w*x + rnorm(30, 0, 2)

head(model.matrix(~ x))
```

```
  (Intercept)          x
1           1 0.50747820
2           1 0.30676851
3           1 0.42690767
4           1 0.69310208
5           1 0.08513597
6           1 0.22543662
```

```r
head(model.matrix(~ x + z)) # x + z
```

```
  (Intercept)          x        z
1           1 0.50747820 2.535597
2           1 0.30676851 2.093088
3           1 0.42690767 2.169803
4           1 0.69310208 2.899832
5           1 0.08513597 2.422638
6           1 0.22543662 2.747746
```

```r
head(model.matrix(~ x + z - x)) # x + z에서 z 항 제거
```

```
  (Intercept)        z
1           1 2.535597
2           1 2.093088
3           1 2.169803
4           1 2.899832
5           1 2.422638
6           1 2.747746
```

```r
head(model.matrix(~ x:w)) # 교호작용항만 포함
```

```
  (Intercept)       x:w
1           1 0.5074782
2           1 0.3067685
3           1 0.0000000
4           1 0.0000000
5           1 0.0000000
6           1 0.0000000
```

```r
head(model.matrix(~ x*w)) # x + w + x:w
```

```
  (Intercept)          x w       x:w
1           1 0.50747820 1 0.5074782
2           1 0.30676851 1 0.3067685
3           1 0.42690767 0 0.0000000
4           1 0.69310208 0 0.0000000
5           1 0.08513597 0 0.0000000
6           1 0.22543662 0 0.0000000
```

```r
head(model.matrix(~ (x + z + w)^3)) # x + z + w + x:z + z:w + x:w + x:w:z
```

```
  (Intercept)          x        z w       x:z       x:w      z:w     x:z:w
1           1 0.50747820 2.535597 1 1.2867602 0.5074782 2.535597 1.2867602
2           1 0.30676851 2.093088 1 0.6420935 0.3067685 2.093088 0.6420935
3           1 0.42690767 2.169803 0 0.9263056 0.0000000 0.000000 0.0000000
4           1 0.69310208 2.899832 0 2.0098799 0.0000000 0.000000 0.0000000
5           1 0.08513597 2.422638 0 0.2062536 0.0000000 0.000000 0.0000000
6           1 0.22543662 2.747746 0 0.6194427 0.0000000 0.000000 0.0000000
```

```r
head(model.matrix(~ x + I(x^2))) # x + x^2
```

```
  (Intercept)          x      I(x^2)
1           1 0.50747820 0.257534127
2           1 0.30676851 0.094106916
3           1 0.42690767 0.182250156
4           1 0.69310208 0.480390494
5           1 0.08513597 0.007248133
6           1 0.22543662 0.050821668
```

```r
# head(model.matrix(~ x + x^2))
head(model.matrix(~ x - 1))
```

```
           x
1 0.50747820
2 0.30676851
3 0.42690767
4 0.69310208
5 0.08513597
6 0.22543662
```

```r
dat <- data.frame(y, x, w, z)
head(model.matrix(y ~ ., data = dat))
```

```
  (Intercept)          x w        z
1           1 0.50747820 1 2.535597
2           1 0.30676851 1 2.093088
3           1 0.42690767 0 2.169803
4           1 0.69310208 0 2.899832
5           1 0.08513597 0 2.422638
6           1 0.22543662 0 2.747746
```

```r
head(model.matrix(y ~ .^2, data = dat))
```

```
  (Intercept)          x w        z       x:w       x:z      w:z
1           1 0.50747820 1 2.535597 0.5074782 1.2867602 2.535597
2           1 0.30676851 1 2.093088 0.3067685 0.6420935 2.093088
3           1 0.42690767 0 2.169803 0.0000000 0.9263056 0.000000
4           1 0.69310208 0 2.899832 0.0000000 2.0098799 0.000000
5           1 0.08513597 0 2.422638 0.0000000 0.2062536 0.000000
6           1 0.22543662 0 2.747746 0.0000000 0.6194427 0.000000
```

```r
# nested 구조
dat2 <- expand.grid(C = c("A", "B"), O = paste0("O", 1:3), 
                    y = runif(3, 1, 2))
dat2 <- dat2[order(dat2$C, dat2$O), ]
model.matrix(y ~ C + O %in% C, data = dat2)
```

```
   (Intercept) CB CA:OO2 CB:OO2 CA:OO3 CB:OO3
1            1  0      0      0      0      0
7            1  0      0      0      0      0
13           1  0      0      0      0      0
3            1  0      1      0      0      0
9            1  0      1      0      0      0
15           1  0      1      0      0      0
5            1  0      0      0      1      0
11           1  0      0      0      1      0
17           1  0      0      0      1      0
2            1  1      0      0      0      0
8            1  1      0      0      0      0
14           1  1      0      0      0      0
4            1  1      0      1      0      0
10           1  1      0      1      0      0
16           1  1      0      1      0      0
6            1  1      0      0      0      1
12           1  1      0      0      0      1
18           1  1      0      0      0      1
attr(,"assign")
[1] 0 1 2 2 2 2
attr(,"contrasts")
attr(,"contrasts")$C
[1] "contr.treatment"

attr(,"contrasts")$O
[1] "contr.treatment"
```

 \normalsize


