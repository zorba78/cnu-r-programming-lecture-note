## ----chunk-setup, echo=FALSE, message=FALSE-------------------------------------------------------------------
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


## **학습목표(2 주차)**: R에서 사용 가능한 데이터 타입에 대해 알아보고, 고유 데이터 타입으로 구성한 객체(스칼라, 백터, 리스트)와 이와 연관된 함수들을 익힌다.


## ----rmarkdown-part, fig.align='center', echo=FALSE, fig.show="hold", out.width='100%', fig.cap="R 데이터 타입 구조 다이어그램: [R, Python 분석과 프로그래밍 (by R Friend)]( http://rfriend.tistory.com/)에서 발췌 후 수정"----
knitr::include_graphics('figures/datatype-diagram.png', dpi = NA)


## 스칼라를 입력시 R의 벡터 지정 함수인 `c()`(벡터 부분에서 상세 내용 학습)를 꼭 사용해서 입력할 필요가 없다. 단, 연속되지 않은 두 개 이상 스칼라면 벡터이므로 꼭 c()를 써야 한다.


## int x;

## x = 1;


## ---- comment=NA, prompt=FALSE--------------------------------------------------------------------------------
z <- 3
z


## ---- comment=NA----------------------------------------------------------------------------------------------
# 정수형 구분자 사용 예시
# typeof(): R 객체의 데이터 타입 반환하는 함수
typeof(10L)
typeof(10)


## ----operation, echo=FALSE, message=FALSE, warning=FALSE------------------------------------------------------
require(tidyverse)
require(rmarkdown)
require(knitr)
require(kableExtra)

`수치형 연산자` <- c("+, -, *, /", 
            "n %% m", 
            "n %/% m", 
            "n ^ m 또는 n ** m")
`설명` <- c("사칙연산", 
          "n을 m 으로 나눈 나머지", 
          "n을 m 으로 나눈 몫", 
          "n 의 m 승")
tab2_01 <- data.frame(`수치형 연산자`, `설명`, check.names = F)
options(kableExtra.html.bsTable = T)
knitr::opts_knit$set(kable.force.latex = FALSE)
kable(tab2_01,
      align = "ll",
      escape = TRUE, 
      booktabs = T, caption = "R언어의 기본 수치 연산자") %>%
  kable_styling(bootstrap_options = c("condensed", "striped"),
                position = "center", 
                font_size = 10, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "4cm") %>% 
  column_spec(2, width = "6cm") %>% 
  row_spec(1:4, monospace = TRUE)



## ----ex-operator, comment=NA, prompt=FALSE--------------------------------------------------------------------
# 숫자형 스칼라
a <- 3
b <- 10
a; b

# 덧셈
c <- a + b
c
# 덧셈을 함수로 입력
# "+"(a, b)로 입력한 결과
c <- "+"(a, b)

# 뺄셈
d <- b - a
d

# 곱셈
m <- a * b
m
# 나누기
dd <- b/a
dd
# 멱승
b^a

# 나누기의 나머지(remainder) 반환
r <- b %% a
r
# 나누기의 몫(quotient) 반환
q <- b %/% a
q
# 연산 우선 순위
nn <- (3 + 5)*3 - 4**2/4
nn



## ----ex-char, comment=NA, prompt=FALSE, error=TRUE------------------------------------------------------------
h1 <- c("Hello CNU!!")
h2 <- c("R is not too difficult.")
typeof(h1); typeof(h2)
h1
h2
# 문자열의 문자 수 반환
nchar(h1); nchar(h2)

# 문자열 연산 error 예시
h1 - h2
  


## ----logic-op-tab, echo=FALSE, message=FALSE------------------------------------------------------------------
`논리형 연산자` <- c("&", "&&", "|", "||", "!")
`설명` <- c("AND (vectorized)", "AND (atomic)", 
            "OR (vectorized)", "OR (atomic)", "NOT")

tab2_02 <- data.frame(`논리형 연산자`, `설명`, check.names = F)
options(kableExtra.html.bsTable = T)
# knitr::opts_knit$set(kable.force.latex = FALSE)
kable(tab2_02,
      align = "ll",
      escape = TRUE, 
      booktabs = T, caption = "R언어의 논리형 연산자") %>%
  kable_styling(bootstrap_options = c("condensed", "striped"),
                position = "center", 
                font_size = 10, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "3cm") %>% 
  column_spec(2, width = "7cm") %>% 
  row_spec(1:5, monospace = TRUE)
  


## ----comp-op-tab, echo=FALSE, message=FALSE-------------------------------------------------------------------
`비교 연산자` <- c(">", "<", "==", ">=", "<=", "!=")
`설명` <- c("크다(greater-than)", "작다(less-than)", "같다(equal)", 
          "크거나 같다(greater than equal)", "작거나 같다(less than equal)", "같지 않다(not equal)")

tab2_03 <- data.frame(`비교 연산자`, `설명`, check.names = F)
options(kableExtra.html.bsTable = T)
# knitr::opts_knit$set(kable.force.latex = FALSE)
kable(tab2_03,
      align = "ll",
      escape = TRUE, 
      booktabs = T, caption = "R언어의 비교 연산자") %>%
  kable_styling(bootstrap_options = c("condensed", "striped"),
                position = "center", 
                font_size = 10, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "3cm") %>% 
  column_spec(2, width = "7cm") %>% 
  kableExtra::footnote(general = "기술한 비교 연산자는 수치형 및 논리형 데이터 타입 모두에 적용 가능 하지만, 문자형은 비교 연산은 ==, != 만 가능함", 
                       threeparttable = TRUE) %>% 
  row_spec(1:6, monospace = TRUE)


## **참고**

## 
## - 논리형 스칼라도 숫자형 연산 가능 $\rightarrow$ 컴퓨터는 `TRUE`/`FALSE`를 1과 0 숫자로 인식

## - 수치 연산자는 스칼라 뿐 아니라 아래에서 다룰 벡터, 행렬, 리스트, 데이터프레임 객체의 연산에 사용 가능

## - `&`/`|`와 `&&`/`||`는 동일하게 AND/OR를 의미하지만 연산 결과가 다름.

## - `&`의 연산 대상이 벡터인 경우 백터 구성 값 각각에 대해 `&` 연산을 실행 하지만 `&&`는 하나의 값(스칼라)에만  논리 연산이 적용(아래 예시 참고)

## 

## ----logic-op-result, comment=NA, prompt=FALSE, tidy=TRUE, error=TRUE-----------------------------------------
typeof(TRUE) # TRUE의 데이터 타입
TRUE & TRUE # TRUE 반환
TRUE & FALSE # FALSE 반환

# 아래 연산은 모두 TRUE 반환
TRUE | TRUE 
TRUE | FALSE

# TRUE와 FALSE의 반대
!TRUE; !FALSE

# 전역변수 T에 FALSE 값 할당
T <- FALSE
T
T <- TRUE # 원상복귀

# TRUE/FALSE에 값을 할당할 수 없음
TRUE <- 1; TRUE <- FALSE

# &(|)와 &&(||)의 차이
l.01 <- c(TRUE, TRUE, FALSE, TRUE) # 논리형 값으로 구성된 벡터
l.02 <- c(FALSE, TRUE, TRUE, TRUE)

l.01 & l.02 # l.01과 l.02 각 원소 별 & 연산
l.01 && l.02 # l.01과 l.02의 첫 번째 원소에 대해 & 연산

# 비교 연산자 
x <- 9; y <- 4

# x > y 의 반환값 데이터 타입
typeof(x > y)
# 논리형 값 반환
x > y 
x < y
x == y
x != y



## -------------------------------------------------------------------------------------------------------------
one <- 80; two <- 90; three <- 75; four <- NA
four

# 'is.na()' 결측 NA가 포함되어 있으면 TRUE 
is.na(four)


## `is.na(object_name)`: 객체를 구성하고 있는 원소 중 `NA`를 포함하고 있는지 확인 $\rightarrow$ `NA`를 포함하면 `TRUE`, 아니면 `FALSE` 반환

## 
## **참고**: 자료에 `NA`가 포함된 경우 연산 결과는 모두 `NA`가 반환

## 

## ---- comment=NA, prompt=FALSE--------------------------------------------------------------------------------
NA + 1
NA & TRUE
NA <= 3


## ----comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-------------------------------------------------------
x <- NULL # NULL 지정
is.null(x) # NULL 객체인지 판단

x <- 1
is.null(x) 



## **`NA`와 `NULL`의 차이점**: 자료의 공백을 의미한다는 점에서 유사한 측면이 있으나 아래 내용처럼 큰 차이가 있음

## 
## - `NULL`: 값을 지정하지 않은 객체를 표현하는데 사용. 즉 아직 변수 또는 객체의 상태가 아직 미정인 상태를 나타냄

## - `NA`: 데이터 값이 결측임을 지정해주는 논리형 상수

## 

## ---- comment=NA, prompt=FALSE, error=TRUE, warning=TRUE------------------------------------------------------
# NA와 NULL은 다름
x <- NA
is.null(NA)
is.na(NULL)



## ---- comment=NA, prompt=FALSE, error=TRUE, warning=TRUE------------------------------------------------------
x <- Inf
is.finite(x)
is.infinite(x)

x <- 0/0
is.nan(x)
is.infinite(x)


## 지금까지 요인형(factor)을 제외하고 R 언어에서 객체가 가질 수 있는 데이터 유형에 대해 알아봄. 요인형은 4주 차에 예정된 "R 자료형: 팩터, 테이블, 데이터 프레임"에서 상세하게 배울 예정임.

## 

## ----vector-ex1, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-------------------------------------------
# 숫자형 벡터 
x <- c(2, 0, 2, 0, 0, 3, 2, 4)
x
# 문자형 벡터
y <- c("Boncho Ku", "R programming", "Male", "sophomore", "2020-03-24")
y



## ----vector-ex2, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-------------------------------------------
# 두 벡터의 결합 (1)
x <- 1:5
y <- 10:6
z <- c(x, y)
x
y
z

x <- 5:10
x1 <- x[1:3] # x 벡터에서 1에서 4번째 원소 추출
x2 <- c(x1, 15, x[4])
x2



## ----vector-ex3, comment=NA, prompt=FALSE, error=TRUE---------------------------------------------------------
# 숫자형 벡터와 문자열 벡터 혼용
k <- c(1, 2, "3", "4")
k
is.numeric(k) # 벡터가 숫자형인지 판단하는 함수
is.character(k) # 벡터가 문자열인지 판단하는 함수

# 숫자형 벡터와 문자열 벡터 결합
x <- 1:3
y <- c("a", "b", "c")
z <- c(x, y)
z
is.numeric(z)
is.character(z)

# 숫자형 벡터와 논리형 벡터 결합
x <- 9:4
y <- c(TRUE, TRUE, FALSE)
z <- c(x, y)

z # TRUE/FALSE 가 1과 0으로 변환

is.numeric(z)
is.logical(z)



## ----vector-ex4, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-------------------------------------------
x <- y <- 1:3 # x와 y 동시에 [1, 2, 3] 할당
x 
y
z <- c(x, y)
z


## ----vector-ex5, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-------------------------------------------
x <- c("Boncho Ku", "R programming", "Male", "sophomore", "2020-03-24")

# 벡터 원소 이름 지정
names(x) <- c("name", "course", "gender", "grade", "date") 
x
y <- c(a = 10, b = 6, c = 9)
names(y)



## ----vector-ex6, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-------------------------------------------
x <- 1:50
# 객체의 길이 반환
# length(): 벡터, 행렬인 경우 원소의 개수, 데이터프레임인 경우 열의 개수 반환
length(x) 

# NROW(): 벡터인 경우 원소의 개수, 행렬, 데이터 프레임인 경우 행의 개수 반환
NROW(x)


## ----vector-ex7, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-------------------------------------------
x <- 1:3; y <- 2:4
length(x); length(y)
x; y

# 사칙연산(+, -, *, /)
# 백터 vs. 백터
x + y
x - y
x * y
x / y

# 그외 연산
# 나머지(remainder)
y %% x

# 몫(quotient)
y %/% x

# 멱승(exponent)
y ^ x



## ----vector-ex8, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-------------------------------------------
# 벡터(n by 1) vs. 스칼라(1 by 1)
x * 5 # 5을 x의 길이 만큼 재사용(반복) 후 곱 연산 수행

x <- c(2, 1, 3, 5, 4); y <- c(2, 3, 4)
x
y
length(x); length(y)


# x의 길이가 5이고 y의 길이가 3이기 때문에 5를 맞추기 위헤
# y의 원소 중 1-2 번째 원소를 재사용
x + y
x / y



## ----vector-ex9, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-------------------------------------------
# 연산 우선 순위
1:5 * 3
1:(5 * 3)



## ----vector-ex10, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE------------------------------------------
# 논리형 벡터
b1 <- c(TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, FALSE)
b2 <- c(FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE)

is.numeric(b1); is.numeric(b2)
is.logical(b1); is.logical(b2)

# 논리형 벡터 연산
b3 <- b1 + b2
is.numeric(b3)
b3
b1 - b2
b1 * b2
b1/b2




## ----vector-ex11, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE------------------------------------------
# 두 벡터의 비교 연산
x <- c(2, 4, 3, 10, 5, 9)
y <- c(3, 4, 6, 2, 10, 7)

x == y
x != y
x > y
x < y
x >= y
x <= y

# 비교 연산 시 두 벡터의 길이가 다른 경우
x <- 1:5; y <- 2:4

x == y
x != y
x > y
x < y
x >= y
x <= y



## ----vector-ex12, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE------------------------------------------
# 문자열 벡터 연산 (==, !=)
c1 <- letters[1:5]
# a-z로 구성된 벡터에서 1-2, 6-8 번째 원소 추출
c2 <- letters[c(1:2, 6:8)] 
c1
c2

c1 == c2
c1 != c2



## ----vector-ex13, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE------------------------------------------
# 결측을 포함한 벡터
x <- c(1:10, c(NA, NA))
y <- c(NA, NA, 1:10)
x
y
is.na(x); is.na(y)

# 결측을 포함한 벡터의 연산 
x + y
x / y
x < y
x > y



## ----vector-ex14, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE------------------------------------------
# NULL을 포함한 벡터 
x <- c(1, 2, 3, NULL, NULL, NULL) # 길이가 6?
length(x)
x



## ----vector-ex15, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE------------------------------------------
x <- c(1.2, 3.1, 4.2, 2.8, 3.3)
x[3] # x 원소 중 3 번째 원소 추출

# x 원소 중 2-3번째 원소 추출
x[2:3]



## ----vector-ex16, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE------------------------------------------
# x의 3 번째 원소 제거
x[-3]

# 맨 마지막 원소(5 번째) 제거
# 아래 script는 동일한 결과 출력
x[1:(length(x) - 1)]
x[-length(x)]


## ----vector-ex17, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE------------------------------------------
# 벡터를 이용한 인덱싱
# x 원소 중 1, 5번째 원소 추출
x[c(1, 5)] # c(1,5)는 벡터

v <- c(1, 4)
x[v]


# 인덱스 번호 중복 가능
x[c(1, 2, 2, 4)]

# 원소 이름으로 인덱싱
# 원소 이름 지정
names(x) <- paste0("x", 1:length(x)) # 문자열 "x"와 숫자 1:5(벡터 길이)를 결합한 문자열 반환
x["x3"]
x[c("x2", "x4")]



## ----vector-ex18-1, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE----------------------------------------
z <- c(5, 2, -3, 8)
# z의 원소 중 z의 제곱이 8보다 큰 원소 추출
w <- z[z^2 > 8]
w


## ----vector-ex18-2, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE----------------------------------------
z^2
idx <- z^2 > 8
idx
z[idx]


## -------------------------------------------------------------------------------------------------------------
# 위 벡터 z 의 원소 중 z^2 > 8 인 원소의 값을 0으로 치환
z[idx] <- 0


## ---- eval=FALSE----------------------------------------------------------------------------------------------
## # seq(): 수열 생성 함수
## seq(
##   from, # 시작값
##   to,   # 끝값
##   by    # 공차(증가치)
## )
## 
## # 기타 인수
## # length.out = n
## #   - 생성하고자 하는 벡터의 길이가 n인 수열 생성
## # along.with = 1:n
## #   - index가 1에서 n 까지 길이를 갖는 수열 생성
## 


## ----seq-example, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE------------------------------------------
x <- seq(from = 2, to = 30, by = 2)
x 

# 간격이 꼭 정수가 아니어도 사용 가능
x <- seq(from = 0, to = 3, by = 0.2)

# by 대신 length.out 으로 생성된 수열의 길이 조정
x <- seq(from = -3, to = 3, length.out = 10)
x

# from, to 인수 없이 length.out=10 인 경우
seq(length.out = 10)

# by 대신 along.width 
seq(along.with=1:10)

seq(1, 5, along.with=1:10)

# 벡터 x에 seq() 함수 적용 시 1:length(x) 값 반환
seq(x)



## ----seq_along_ex, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-----------------------------------------
# 1부터 x 벡터의 길이 까지 1 단위 수열 값 반환
seq_along(x)


## ----seq_len_ex, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-------------------------------------------
# 1부터 n 까지 1 단위 수열 값 반환
seq_len(10)


## ---- eval=FALSE----------------------------------------------------------------------------------------------
## # rep(): 벡터 또는 벡터의 개별 원소를 반복한 값 반환
## rep(
##   x, # 반복할 값이 저장된 벡터
##   times, # 전체 벡터의 반복 횟수
##   each # 개별 원소의 반복 횟수
## )
## 


## ----rep-ex1, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE----------------------------------------------
x <- rep(4, 5) # 4를 5번 반복
x

# x <- c(1:3) 전체를 3번 반복한 벡터 반환
x <- c(1:3)
xr1 <- rep(x, times = 3)
xr1

# 벡터 x 의 각 원소를 4번씩 반복한 벡터 반환
xr2 <- rep(x, each = 4)
xr2

# 벡터 x 의 각 원소를 3번 반복하고 해당 벡터를 2회 반복
xr3 <- rep(x, each = 3, times = 2)
xr3

# 문자형 벡터의 반복
# 아래 sex 벡터의 각 원소를 2 번 반복하고 해당 벡터를 4회 반복
sex <- c("Male", "Female")
sexr <- rep(sex, each = 2, times = 4)
sexr


## ----rep-ex2, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE----------------------------------------------
# 1:5 벡터를 3 번 반복
rep.int(1:5, 3)

# 불완전한 사이클로 벡터 반복
rep_len(1:5, length.out = 7)


## ----subset-ex, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE--------------------------------------------
x <- c(6, 1:3, NA, NA, 12)
x

# 일반적 필터링 적용 
x[x > 5]

# subset() 함수 적용
subset(x, x > 5)



## ---- eval=FALSE----------------------------------------------------------------------------------------------
## # which(): 논리형 벡터를 인수로 받고 해당 논리형 벡터가 참인 index 반환
## which(
##   logical_vec # 논리형 벡터
## )


## ----which-ex, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE---------------------------------------------
x <- c(3, 8, 3, 1, 7)

# x의 원소값이 3인 index 반환
which(x == 3)

# x의 원소가 4보다 큰 원소의 index 반환
which(x > 4)

# 9월(Sep)과 12월(Dec)와 같은 원소 index
# month.abb: R 내장 벡터로 월 약어(Jan ~ Dec)를 저장한 문자열 벡터
which(month.abb == c("Sep", "Dec"))

# 조건을 만족하는 원소가 존재하지 않는다면?
x <- which(x > 9)
x
length(x) # 길이가 0인 벡터 반환 is.null(x) == TRUE ??
is.null(x)

# 특정 조건 만족 여부를 확인 
# any(condition) -> 하나라도 condition을 만족하는 원소가 존재하는지 판단
# TRUE 또는 FALSE 값 반환
any(x > 9)



## ----set-equal-ex, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-----------------------------------------
x <- y <- c(1, 9, 7, 3, 6)
setequal(x, y)



## ----set-union-ex, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-----------------------------------------
y <- c(1, 9, 8, 2, 0, 3)
union(x, y)



## ----set-intersect-ex, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-------------------------------------
intersect(x, y)


## ----set-diff-ex, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE------------------------------------------
setdiff(x, y)
setdiff(y, x)


## ----in-op-ex, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE---------------------------------------------
x <- c("apple", "banana", "strawberry", "mango", "peach", "orange")
y <- c("strawberry", "orange", "mango")

x %in% y
y %in% x



## ----identical-ex, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-----------------------------------------
x <- 1:3
y <- c(1, 3, 4)
x == y


## ----all-ex, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE-----------------------------------------------
all(x == y)


## ----identical-ex1, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE----------------------------------------
# 두 객체의 동일성 여부 테스트
identical(x, y)


## ----identical-ex2, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE----------------------------------------
x <- 1:5; y <- c(1, 2, 3, 4, 5)
x
y

# all() 함수로 동일성 확인
all(x == y)

# identical 함수로 동일성 확인
identical(x, y)

# x, y 데이터 타입 확인
typeof(x)
typeof(y)



## **리스트 예시**: 통계프로그래밍언어 중간고사 성적 테이블

## 
## - 중간고사 성적 테이블은 이름, 학번, 출석률, 점수, 등급으로 이루어졌다고 가정하면 "김상자"의 성적 리스트는 다음과 같이 나타낼 수 있음

## - `LIST(이름 = "김상자", 학번 = "202015115", 점수 = 95, 등급 = "A-")`

## - 위 record에서 보듯이 문자형과 숫자형이 LIST 안에 같이 표현되고 있음

## 

## ---- comment=NA, prompt=FALSE--------------------------------------------------------------------------------
# 벡터로 위 record를 입력한 경우
vec <- c(`이름` = "김상자", `학번` = "202015115", 
         `점수` = 95, `등급` = "A-")
vec
typeof(vec)



## 객체 명칭 규칙을 벗어나는 이름을 객제명으로 사용하고 싶다면 다음과 같이 홀따옴표 \``object_name`\` 표시를 통해 사용 가능함

## 

## ---- comment=NA, prompt=TRUE---------------------------------------------------------------------------------
#공백이 있는 이름을 객체 명칭으로 사용
`golf score` <- c(75, 82, 92)
`golf score`

`3x` <- c(3, 6, 9, 12)
`3x`



## ---- eval=FALSE----------------------------------------------------------------------------------------------
## # list 함수 사용 prototype
## list(name_1 = object_1, ..., name_m = object_m)
## 
## # name_1, ..., name_m: 리스트 원소 이름
## # object_1, ..., object_m: 리스트 원소에 대응한 객체
## 


## ----list-ex1, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE---------------------------------------------
# lst 객체 생성
lst <- list(`이름` = "김상자", 
            `학번` = "202015115", 
            `점수` = 95, 
            `등급` = "A-")
lst

# lst 내 객체의 데이터 타입 확인
# lapply(): lst 객체에 동일한 함수 적용 (추후 학습)
lapply(lst, typeof)



## ---- comment=NA, prompt=FALSE, error=TRUE, warning=TRUE------------------------------------------------------
names(lst)


## ----list-ex2, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE---------------------------------------------
list("김상자", "202015115", 95, "A-")


## ----list-ex3, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE---------------------------------------------
# 길이가 1이고 객체가 NULL인 리스트 생성
z <- vector(mode = "list", length=1)
z



## ----list-ex4, comment=NA, prompt=FALSE, error=TRUE, warning=TRUE---------------------------------------------
x <- list(name = c("A", "B", "C"), 
          salary = c(500, 450, 600), union = T)
x


## -------------------------------------------------------------------------------------------------------------
lval <- unlist(x)
typeof(lval)


## ----list-tab, echo=FALSE-------------------------------------------------------------------------------------
`색인방법` <- c("x$name", "x[[i]] 또는 x[[name]]", "x[i] 또는 x[name]")
`동작` <- c("리스트 x 에서 객체명(name)에 해당하는 객체에 접근", 
            "리스트 x 에서 i 번째 또는 name에 해당하는 객체 반환", 
            "리스트 x 에서 i 번째 또는 name에 해당하는 부분 리스트 반환")
tab2_04 <- data.frame(`색인방법`, `동작`, check.names = F)
options(kableExtra.html.bsTable = T)
# knitr::opts_knit$set(kable.force.latex = FALSE)
kable(tab2_04,
      align = "ll",
      escape = TRUE, 
      booktabs = T, caption = "리스트 데이터 접근 방법") %>%
  kable_styling(bootstrap_options = c("condensed", "striped"),
                position = "center", 
                font_size = 10, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "3cm") %>% 
  column_spec(2, width = "7cm") %>% 
  row_spec(1:3, monospace = TRUE)



## ----list-ex5, comment=NA, prompt=FALSE, error=TRUE-----------------------------------------------------------
lst$`학번`


## ----list-ex6, comment=NA, prompt=FALSE, error=TRUE-----------------------------------------------------------
lst[[2]]
z <- lst[["학번"]]
z
typeof(z)



## ----list-ex7, comment=NA, prompt=FALSE, error=TRUE-----------------------------------------------------------
lst[2]
j <- lst["학번"]
j
typeof(j)



## ----lst-ex8, comment=NA, prompt=FALSE, error=TRUE------------------------------------------------------------
# 리스트 lst 에서 1 ~ 3 번째 까지 부분 리스트 추출
lst[1:3]



## ----lst-ex9, comment=NA, prompt=FALSE, error=TRUE------------------------------------------------------------
x
# salary에서 2-3번째 원소 추출
x$salary[2:3]
x[[2]][2:3]
x[["salary"]][2:3]

# 부분 리스트도 길이가 1인 리스트이므로, 
# 부분 리스트 내 객제 접근 시 리스트 접근이 선행
# x의 2번째 부분 리스트에서 첫 번째 객체의 2-3번째 원소 추출
x[2][[1]][2:3]




## ----lst-ex10, comment=NA, prompt=FALSE, error=TRUE-----------------------------------------------------------
length(lst); length(x)


## ----lst-ex11, comment=NA, prompt=FALSE, error=TRUE-----------------------------------------------------------
# 리스트 lst 에 5회 차 퀴즈 점수 추가
lst$quiz <- c(10, 8, 9, 9, 8)

# 리스트 lst이 원소 quiz 제거
lst$quiz <- NULL
lst

# 벡터 색인을 이용해 원소 추가 가능
lst[[5]] <- c(10, 8, 9, 9, 8)
lst

# 부분 리스트 괄호에서도 색인 통해 추가/삭제 가능
lst[5] <- NULL
lst

# 여러 개의 리스트 동시 추가/삭제 가능
lst[5:9] <-  c(10, 8, 9, 9, 8)
lst
lst[5:9] <-  NULL
lst



## ----lst-ex12, comment=NA, prompt=FALSE, error=TRUE-----------------------------------------------------------
# 리스트 lst와 x 결합
c(lst, x)



## 리스트 내에 리스트를 가질 수 있다. 이를 재귀 리스트(recursive list)라고 한다. 예를 들어 위 예제에서 각 학생의 성적 데이터가 리스트로 구성되어 있다면, 전체 성적 데이터베이스는 리스트로 구성된 리스트임. 아래 예제 처럼 간단한 재귀 리스트 구현이 가능


## ----recursive-list, comment=NA, prompt=FALSE, error=TRUE-----------------------------------------------------
kim <- list(id = "20153345", sex = "Male", score = 85, grade = "B+")
lee <- list(id = "20153348", sex = "Female", score = 75, grade = "B0")

gr <- list(kim=kim, lee=lee)
gr


## **학습목표(3 주차)**: 행렬, 배열, 요인형과 테이블에 대해 살펴보고, 이들 객체에 대한 연산과 연관된 함수에 대해 익힌다.


## ---- eval=FALSE----------------------------------------------------------------------------------------------
## # matrix(): 행렬 생성 함수
## # 상세 내용은 help(matrix)를 통해 확인
## 
## matrix(data, # 행렬을 생성할 데이터 벡터
##        nrow, # 행의 개수 (정수)
##        ncol, # 열의 개수 (정수)
##        byrow, # TRUE: 행 우선, FALSE: 열 우선
##               # default = FALSE
##        dimnames # 행렬읠 각 차원에 부여할 이름 (리스트)
##        )


## ----make-matrix-ex1, comment=NA------------------------------------------------------------------------------
# byrow = FALSE
x <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), nrow = 3, ncol = 3)
x

# byrow = TRUE
x <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), nrow = 3, ncol = 3, byrow = T)
x



## ----make-matrix-ex2, comment=NA------------------------------------------------------------------------------
x <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), ncol = 3)
x
x <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), nrow = 3)
x


## ----make-matrix-ex3, comment=NA------------------------------------------------------------------------------
# length(x) < nrow * ncol 인 경우 
# nrow * ncol에 해당하는 길이 만큼
# x의 원소를 사용해 행렬 생성
x <- c(1, 2, 3, 4, 5, 6, 7, 8, 9)
y <- matrix(x, nrow = 2, ncol = 3)
y

# length(x) > nrow * ncol 인 경우 
# x의 첫 번쨰 원소부터 초과하는 만큼 
# x 원소의 값을 재사용
z <- matrix(x, nrow = 3, ncol = 4)
z



## ----make-matrix-ex4, comment=NA------------------------------------------------------------------------------
# x (length=9)로 행렬 생성 시 nrow=4 를
# 인수로 입력한 경우
h <- matrix(x, nrow = 4)
h

# x (length=9)로 행렬 생성 시 ncol=2 만 
# 인수로 입력한 경우
h <- matrix(x, nrow = 2)
h



## ----mat-op-ex1, comment=NA-----------------------------------------------------------------------------------
x <-matrix(1:9, 3, 3, byrow = T)
x + 4


## ----mat-op-ex2, comment=NA-----------------------------------------------------------------------------------
x*4


## ----mat-op-sum, comment=NA-----------------------------------------------------------------------------------
x <- matrix(1:9, 3, 3, byrow = T)
y <- matrix(c(1, 3, -6, -1, 2, 3, 2, 4, -7), ncol = 3)
x + y


## ----mat-op-eprod-1, comment=NA-------------------------------------------------------------------------------
x * y


## ----mat-op-eprod-2, comment=NA, error=TRUE-------------------------------------------------------------------
z <- y[, 1:2] # y 행렬에서 1-2 번째 열 추출
z # 3 by 2 행렬
x + z
x * z
x / z



## ----mat-op-mprod-1, comment=NA-------------------------------------------------------------------------------
X <- matrix(c(1,1,1,-1,-1,1,1,1), nrow = 2, ncol = 4)
Y <- matrix(c(1,1,1,1, -2, 1, 3, 2, -1, 2, 1, 2), nrow = 4, ncol = 3)
Z <- X %*% Y
Z


## ----mat-vec-op-01, comment=NA--------------------------------------------------------------------------------
#행렬-벡터 합 연산
# X = 3 by 3 행렬; y = 3 by 1 벡터
x <- c(1, 1, 1, 2, 3, 2, 4, 2, 1)
X <- matrix(x, nrow = 3)
y <- c(20, 18, 23)# 재사용

X + y


## ----mat-vec-op-02, comment=NA, error=TRUE--------------------------------------------------------------------
#행렬-벡터 합 연산
# 행렬 X의 길이와 벡터 y의 길이가 같은 경우
x <- c(1:9); X <- matrix(x, nrow = 3)
length(X); y <- x
X + y

# 길이가 다른 경우
# 1) 행렬 길이보다 큰 경우
y <- c(1:10)
X + y

# 1) 행렬 길이의 약수가 아닌 경우
# y 재사용
y <- c(1:4)
X + y


## ----comment=NA-----------------------------------------------------------------------------------------------
x <- c(1, 1, 1, 1, 2, 1, 3, 4, 1, 1, 3, 4)
y <- c(7, 6, 8)
X <- matrix(x, nrow = 4, ncol = 3)
X %*% y


## ----transpose-ex, comment=NA---------------------------------------------------------------------------------
# t(object_name): 전치행렬 반환
x <- 1:6
X <- matrix(x, nrow = 2, ncol = 3, byrow = T)
t(X)

# 전치행렬과 행렬 간 곱
x <- c(1, 1, 1, 1, 1, 22.3, 23.2, 21.5, 25.3, 28.0)
X <- matrix(x, nrow = 5)
t(X) %*% X


## ----vec-vec-transpose, comment=NA----------------------------------------------------------------------------
x <- 1:4
x %*% t(x) # 행렬 반환
t(x) %*% x # 스칼라 반환 x %*% x와 동일 결과 출력



## **참고**: 전치행렬의 성질(통계수학 II 강의내용 참고)

## 
##   - $(\mathrm{\mathbf{X}}^T)^T = \mathrm{\mathbf{X}}$

##   - $(\mathrm{\mathbf{X} + \mathbf{Y}})^T = \mathrm{\mathbf{X}}^T + \mathrm{\mathbf{Y}}^T$

##   - $(\mathrm{\mathbf{X}\mathbf{Y}})^T = \mathrm{\mathbf{Y}}^T\mathrm{\mathbf{X}}^T$

##   - $(c\mathrm{\mathbf{X}})^T = c\mathrm{\mathbf{X}}^T$, $c$는 임의의 상수

## 
## 


## ----inv-mat, comment=NA--------------------------------------------------------------------------------------
# 2 by 2 행렬의 역행렬
x <- c(1, 2, 3, 4)
X <- matrix(x, 2)
solve(X)

# 항등 행렬이 나오는지 확인
X %*% solve(X)



## **참고**: 역행렬의 성질(통계수학 II 강의내용 참고)

## 
## 
##   - $(\mathrm{\mathbf{X}}^{-1})^{-1} = \mathrm{\mathbf{X}}$

##   - $(\mathrm{\mathbf{X}}^T)^{-1} = (\mathrm{\mathbf{X}}^{-1})^T$

##   - $(\mathrm{\mathbf{XY}}^{-1}) = \mathrm{\mathbf{Y}}^{-1}\mathrm{\mathbf{X}}^{-1}$

## 
## 

## ----det-example, comment=NA----------------------------------------------------------------------------------
X <- matrix(c(1, 2, 0, 5, 4, -2, 0, -1, 0), ncol = 3)
det(X)


## **참고**: 행렬식의 성질(통계수학 II 강의내용 참고)

## 
## 
##    - 행렬 $\mathrm{\mathbf{X}}$, $\mathrm{\mathbf{Y}}$가 정방행렬이면 $\det(\mathrm{\mathbf{XY}}) = \det(\mathrm{\mathbf{X}})\det(\mathrm{\mathbf{Y}})$

##    - $\det(\mathrm{\mathbf{X}}) = \det(\mathrm{\mathbf{X}}^T)$

##    - $\det(c\mathrm{\mathbf{X}}) = c^n \det(\mathrm{\mathbf{X}})$ 여기서 $c$는 임의의 상수

##    - $\det(\mathrm{\mathbf{X}}^{-1}) = \det(\mathrm{\mathbf{X}})^{-1}$

## 

## 

## 그외 정칙(non-singluar), 비정칙(non-singular), 양정치(positive definite) 행렬 모두 행렬식으로 정의할 수 있고 자세한 내용은 통계수학 II를 통해 학습. 추가적으로 여인수 $c_{ij}$ 를 이용한 역행렬 공식은 아래와 같음

## 
## 
## $$\mathrm{\mathbf{X}}^{-1} = \frac{1}{\det(\mathrm{\mathbf{X}})}

## \begin{bmatrix}

## c_{11} & c_{12} &  \cdots & c_{1n} \\

## c_{21} & c_{22} &  \cdots & c_{2n} \\

## \vdots & \vdots & \cdots & \vdots \\

## c_{n1} & c_{n2}  & \cdots & c_{nn}

## \end{bmatrix}

## $$

## 

## **예습**: $3\times 3$ 정방행렬 $\mathrm{\mathbf{X}}$가 아래와 같이 주어졌을 때, $\mathrm{\mathbf{X}}$의 행렬식과 역행렬 $\mathrm{\mathbf{X}}^{-1}$을 직접 계산해 보고, R에서 각각을 구하는 함수를 사용하여 계산 결과가 맞는지 확인

## 
## 
## $$\mathrm{\mathbf{X}} =

## \begin{bmatrix}

## 6 & 1 & 4 \\

## 2 & 5 & 3 \\

## 1 & 1 & 2

## \end{bmatrix}

## $$

## 
## 


## ----mat-index, comment=NA------------------------------------------------------------------------------------
x <- 1:12
X <- matrix(x, ncol = 4)
X

# 1행만 선택
X[1, ]

# 3열만 선택
X[, 3]

# 1:3행만 선택
X[1:3, ]

# 1-2행, 3-4열 선택
X[1:2, 3:4]



## ----mat-row-col-name, comment=NA-----------------------------------------------------------------------------
# matrix 함수 내에서 행렬 이름 동시 부여
X <- matrix(1:9, ncol = 3, 
            dimnames = list(c("1", "2", "3"), # 행 이름
                            c("A", "B", "C")))# 열 이름
X

# dimnames()를 이용한 이름 확인
dimnames(X) # 행렬에 대한 리스트 반환

# dimnames() 함수로 행 이름 변경
dimnames(X)[[1]] <- c("r1", "r2", "r3")

# dimnames() 함수로 열 이름 변경
dimnames(X)[[2]] <- c("c1", "c2", "c3")
dimnames(X)
X

# rownames()를 통해 행 이름 확인
rownames(X)
# colnames()를 통해 열 이름 확인
colnames(X)


# rownames()를 이용해 행 이름 변경
rownames(X) <- c("apple", "strawberry", "orange")
rownames(X)
# colnames()를 이용해 행 이름 변경
colnames(X) <- c("costco", "emart", "homeplus")
colnames(X)
X



## ----mat-name-index, comment=NA-------------------------------------------------------------------------------
X[c("apple", "orange"), c("emart")]

# 2번째 열에 해당(emart)를 제외한 나머지 열 반환
X[, colnames(X)[-2]]



## ----mat-idx-assign, comment=NA-------------------------------------------------------------------------------
y <- c(1:12); Y <- matrix(y, ncol = 3)
Y

# 2, 4 행과 2-3열에 다른 값 할당
Y[c(2, 4), 2:3] <- matrix(c(1, 2, 1, 4), ncol = 2)

# 행렬 값 할당 다른 예시
X <- matrix(nrow = 4, ncol = 3) # NA 값으로 구성된 4 by 3 행렬
X
y <- c(1, 0, 0, 1); Y <- matrix(y, ncol = 2)
X[3:4, 2:3] <- Y
X



## ----mat-filtering, comment=NA--------------------------------------------------------------------------------
X = matrix(c(1,2,4,3,2,3,5,6), nrow = 4, ncol = 2)

# X의 1열이 3보다 작거나 같은 행 필터링
X[X[,1] <= 3, ]

# 논리값을 활용한 필터링
idx <- X[, 1] <= 3; idx
X[idx, ]


## ----binding, comment=NA--------------------------------------------------------------------------------------
j <- rep(1, 4)
Z <- matrix(c(1:4, 1, 1, 0, 0, 1, 0, 1, 0), nrow = 4, ncol = 3)
Z
cbind(j, Z) # 열 기준으로 붙이기
# 길이가 다른 경우 재사용
cbind(1, Z)

# Z 행렬 앞에 j 열 붙혀서 새로운 Z 생성
Z <- cbind(j, Z)

# 행 기준으로 붙이기
Z <- rbind(Z, 2)



## ----mat-element-delete, comment=NA---------------------------------------------------------------------------
# 첫 번째 행 제거
Z[-1, ]

# 1, 5행 , 3열 제거
Z[-c(1, 5), -3]


## `cbind()` 또는 `rbind()` 함수는 다음 주에 배울 데이터 프레임에도 적용 가능하다.


## ----diag-mat, comment=NA-------------------------------------------------------------------------------------
D <- diag(c(1:5), 5)
D
# 3차원 항등 행렬(모든 대각원소가 1인 행렬)
I3 <- diag(1, 3)

#대각원소 추출
diag(D)

# 대각원소 재할당
diag(D) <- rep(1, 5)


## 객체는 속성(attribute)을 갖고 그 속성에 따라 데이터의 구조가 정해짐. 즉 속성은 데이터에 대한 메타 데이터임. 객체의 속성은 대표적으로 이름(names), 차원(dimension), 클래스(class)로 정의되고 객제에 대한 자세한 정보를 파악하기 위해 제공되는 몇 가지 함수들에 대해 알아봄.

## 
## R은 앞서 언급한 바와 같이 객체지향언어(object oriented program, OOP)이고 세 가지 유형의 객체지향 시스템(S3, S4, S5)이 존재함. R의 핵심적인 함수 및 패키지는 S3 객체 시스템을 사용하고 있기 때문에 알아둘 필요가 있으나 본 강의의 범위를 벗어나기 때문에 이번 학기에는 다루지 않을 것임.

## 

## ----dim-ex, comment=NA---------------------------------------------------------------------------------------
# dim(): 객체의 차원(dimension)을 반환
Z
dim(Z)


## ----ncol-row-ex, comment=NA----------------------------------------------------------------------------------
nrow(Z); ncol(Z)


## ----attribute-ex-1, comment=NA-------------------------------------------------------------------------------
x <- 1:9; X <- matrix(x, ncol = 3)
# 객체의 속성 확인
attributes(x)
attributes(X)


## ----attribute-ex-2, comment=NA-------------------------------------------------------------------------------
# 객체의 class 확인
class(x); class(X)
# 객체의 class 부여
class(x) <- "this is a vector"


## ----attribute-ex-3, comment=NA-------------------------------------------------------------------------------
# 객체의 구조 파악
str(x); str(X)

# x와 X에 이름(name) 속성을 추가한 경우
names(x) <- paste0("x", 1:9)
dimnames(X) <- list(paste0("r", 1:3), 
                    paste0("c", 1:3))
attributes(x); attributes(X)
class(x); class(X)
str(x); str(X)


## ----attributes-ex-4, comments=NA-----------------------------------------------------------------------------
# 객체 속성 요소 확인
attr(x, "names")
attr(X, "dimnames")


## ----vec-mat-ex1, comment=NA----------------------------------------------------------------------------------
z <- 1:8
U <- matrix(z, 4, 2)
length(z) # 입력 벡터 원소의 길이가 8


## ----vec-mat-ex2, comment=NA----------------------------------------------------------------------------------
class(z) # 벡터
attributes(z)

class(U) # 행렬
attributes(U)


## -------------------------------------------------------------------------------------------------------------
Z <- matrix(c(1:8), 4, 2)
z <- Z[2, ]

attributes(Z) # 행과 열의 차원 수를 표시

# 객체 z의 속성및 형태는? 
attributes(z) # 차원이 존재하지 않음



## -------------------------------------------------------------------------------------------------------------
z <- Z[2, , drop = FALSE]
attributes(z)


## -------------------------------------------------------------------------------------------------------------
z <- as.matrix(Z[2, ])
class(z)
z # 행렬이 변환됨을 유의


## ---- eval=FALSE----------------------------------------------------------------------------------------------
## # array() 함수 인수 구조
## array(data, # 저장할 데이터 벡터 또는 행렬
##       dim,  # 배열의 차원 지정
##       dimnames # 배열 차원 명칭
##       )


## -------------------------------------------------------------------------------------------------------------
x <- c(75, 84, 93, 65, 78, 92)
y <- c(82, 78, 85, 88, 75, 88)

first_term <- matrix(x, nrow = 3, ncol = 2)
second_term <- matrix(y, nrow = 3, ncol = 2)

first_term
second_term

# 위 두 데이터를 2층 짜리 배열로 구성
Z <- array(data = c(first_term, second_term), 
           dim = c(3, 2, 2))
Z

# Z의 속성
attributes(Z)

# Z의 클래스
class(Z)

# Z의 구조
str(Z)


## ----array-index, comment=NA----------------------------------------------------------------------------------
# 첫 번째 층만 추출
Z[, , 1]

# 두 번째 층에서 2-3행 만 추출
Z[2:3, , 2]


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%', fig.cap="https://www.geeksforgeeks.org/matlab-rgb-image-representation/ 에서 발췌"----
knitr::include_graphics('figures/Pixel.jpg', dpi = NA)


## **목표**

## 
## 

##   - R에서 웹 url로 이미지를 불러오기

##   - 불러온 이미지를 R에서 plotting 해보기

##   - 이미지 데이터를 직접 수정 해보기

## 
## 

## ----ex-step1, eval=FALSE-------------------------------------------------------------------------------------
## install.packages("jpeg") # jpeg 파일 입출력 관련 package
## install.packages("cowplot") # ggplot add-on package


## ----ex-step2, comment=NA, echo=TRUE, message=FALSE-----------------------------------------------------------
require(tidyverse)
require(jpeg)
require(cowplot)


## ----ex-step3, comment=NA-------------------------------------------------------------------------------------
myurl <- "https://img.livescore.co.kr/data/editor/1906/ba517de8162d92f4ea0e9de0ec98ba02.jpg"
z <- tempfile()
download.file(myurl,z,mode="wb")
pic <- readJPEG(z)



## ----ex-step4, comment=NA, fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'-------------------
ggdraw() +
  draw_image(pic)



## -------------------------------------------------------------------------------------------------------------
pic[300:460, 440:520, 1] <- 0.5
pic[300:460, 440:520, 2] <- 0.5
pic[300:460, 440:520, 3] <- 0.5

ggdraw() +
  draw_image(pic)


## -------------------------------------------------------------------------------------------------------------
pic <- readJPEG(z)
yr <- pic[300:460, 440:520, 1]
yg <- pic[300:460, 440:520, 2]
yb <- pic[300:460, 440:520, 3]
n <- nrow(yr); p <- ncol(yr)

t <- 0.2
wr <- t * yr + (1 - t)*matrix(runif(length(yr)), nrow = n, ncol = p)
wg <- t * yg + (1 - t)*matrix(runif(length(yg)), nrow = n, ncol = p)
wb <- t * yb + (1 - t)*matrix(runif(length(yb)), nrow = n, ncol = p)


pic[300:460, 440:520, 1] <- wr
pic[300:460, 440:520, 2] <- wg
pic[300:460, 440:520, 3] <- wb

ggdraw() +
  draw_image(pic)



## ---- eval=FALSE----------------------------------------------------------------------------------------------
## # factor 정의 함수
## factor(data, # factor로 표현하고자 하는 값. 주로 문자형
##        levels, # 요인의 수준, 미리 정한 값
##        labels, # 수준에 대한 레이블링
##        ordered # 순서형 자료 표시 여부
##                # TRUE/FALSE, default = FALSE
##        )


## ----factor-ex1, comment=NA-----------------------------------------------------------------------------------
score <- rep(c(4:6), each = 4)
fscore <- factor(score)

typeof(fscore) # factor의 기본 데이터 타입
attributes(fscore) # factor의 속성

# factor의 구조
str(fscore)

# levels(): factor의 수준(levels) 반환 함수
levels(fscore)

# nlevels(): level의 개수 반환
nlevels(fscore)


## ----factor-ex2, comment=NA-----------------------------------------------------------------------------------
c(fscore, factor(4)) # 강제로 정수형 벡터로 변환


## ----factor-ex3, comment=NA-----------------------------------------------------------------------------------
x <- rep(c(1:2), each = 4)

# factor의 범주 수준 지정
sex <- factor(x, levels = 1:2)
sex

# factor의 범주 수준 및 범주 명칭 지정
sex <- factor(x, levels = 1:2, labels = c("male", "female"))
sex # level의 값이 명칭으로 변경
str(sex)

# 값은 존재하지 않으나 수준을 미리 정해 놓은 경우
severity <- factor(1:2, levels = c(1, 2, 3), labels = c("Mild", "Moderate", "Severe"))
severity[2] <- "Severe"

# 존재하지 않는 수준 할당 
severity[1] <- "Good"
severity


## ----factor-ex4-----------------------------------------------------------------------------------------------
severity <- factor(rep(1:3, times = 3), levels = 1:3, 
                   labels = c("Mild", "Moderate", "Severe"), 
                   ordered = T)
severity
is.ordered(severity) # 순서형 범주 체크



## **과제 제출 방식**

## 

##    - R Markdown 문서(`Rmd`) 파일과 해당 문서를 컴파일 후 생성된 `html` 파일 모두 제출할 것

##    - 모든 문제에 대해 작성한 R 코드 및 결과가 `html` 문서에 포함되어야 함.

##    - 해당 과제에 대한 R Markdown 문서 템플릿은 https://github.com/zorba78/cnu-r-programming-lecture-note/assignment 에서 다운로드 또는 스크래이핑 가능

##    - 최종 파일명은 `학번-성명.Rmd`, `학번-성명.html` 로 저장

## 

## 

