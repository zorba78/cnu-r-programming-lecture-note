---
output: html_document
editor_options: 
  chunk_output_type: console
---

# R 수학 함수 및 분포 함수




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


