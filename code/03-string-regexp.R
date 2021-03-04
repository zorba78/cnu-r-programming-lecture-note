## ---- echo=FALSE, message=FALSE----------------------------------------------------------------------------
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
## - 텍스트 문자 처리에 있어 가장 기본인 정규 표현식(regular rexpression)에 대해 알아본다.

## - R에서 기본으로 제공하는 문자열 차리 함수에 대해 알아본다

## 

## ----back-slash--------------------------------------------------------------------------------------------
# 문자열에 따옴표(single of double quote, ', ") 입력
double_quote <- "\"" 
double_quote
single_quote <- '\'' 
single_quote

x <- c("\"", "\\", '\'')
writeLines(x)

# 백슬레쉬가 포함된 문자열
x <- "abc\n\tabc"

# \n: Enter
# \t: tab 문자를 표현

writeLines(x)

# 특수문자 표현
x <- "\u00b5" # 그리스 문자 mu 표현 (유니코드)
x


## **참고자료**

## 
##    - [Youtube 동영상](https://www.youtube.com/watch?v=q8SzNKib5-4&t=18s): 영어 강의가 옥의 티...

##    - [regexr.com](https://regexr.com): 정규 표현식의 패턴 확인 가능

##    - [Wikibooks R programming: Text processing](https://en.wikibooks.org/wiki/R_Programming/Text_Processing)

## 

## ----nchar-proto, eval=FALSE-------------------------------------------------------------------------------
## # 문자열을 구성하는 문자 개수 반환
## nchar(
##   x, # 문자형 벡터
##   type # "bytes": 바이트 단위 길이 반환
##        # "char": 인간이 읽을 수 있는 글자 길이 반환
##        # "width": 문자열이 표현된 폭의 길이 반환
## )


## ----nchar-ex----------------------------------------------------------------------------------------------
x <- "Carlos Gardel's song: Por Una Cabeza"
nchar(x)

y <- "abcde\nfghij"
nchar(y)

z <- "양준일: 가나다라마바사"
nchar(z)

# 문자열 벡터
str <- sentences[1:10]
nchar(str)

s <- c("abc", "가나다", "1234[]", "R programming\n", "\"R\"")

nchar(s, type = "char")
nchar(s, type = "byte")
nchar(s, type = "width")



## 백터의 원소 개수를 반환하는 `length()` 함수와는 다름.


## ----paste-proto, eval=FALSE-------------------------------------------------------------------------------
## paste(
##   ..., # 한 개 이상의 R 객체. 강제로 문자형 변환
##   sep  # 연결 구분자: 디폴트 값은 공백(" ")
##   collapse # 묶을 객체가 하나의 문자열 벡터인 경우
##            # 모든 원소를 collapse 구분자로 묶은 길이가 1인 벡터 반환
## )


## ----paste-ex----------------------------------------------------------------------------------------------
i <- 1:length(letters)

paste(letters, i) # sep = " "
paste(letters, i, sep = "_") # sep = "-"

paste0(letters, i) # paste(letters, i, sep = "") 동일

# collapse 인수 활용
paste(letters, collapse = "")
writeLines(paste(str, collapse = "\n"))

# 3개 이상 객체 묶기
paste("Col", 1:2, c(TRUE, FALSE, TRUE), sep =" ", collapse = "<->")


# paste 함수 응용
# 스트링 명령어 실행 
exprs <- paste("lm(mpg ~", names(mtcars)[3:5], ", data = mtcars)")
exprs
sapply(1:length(exprs), function(i) coef(eval(parse(text = exprs[i]))))



## ----sprintf-format, echo=FALSE, message=FALSE-------------------------------------------------------------
Format <- c("%s", "%d", "%f", "%e, %E")
`설명` <- c("문자열", "정수형", "부동 소수점 수", "지수형")
sprintf_fmt <- data.frame(Format, `설명`, check.names = F, 
                          stringsAsFactors = FALSE)
kable(sprintf_fmt)


## ----sprintf-ex, error=TRUE--------------------------------------------------------------------------------
options()$digits #
pi # 파이 값
sprintf("%f", pi) 

# 소숫점 자리수 3자리 까지 출력
sprintf("%.3f", pi)

# 소숫점 출력 하지 않음
sprintf("%1.0f", pi)

# 출력 문자열의 길이를 5로 고정 후
# 소숫점 한 자리까지 출력
sprintf("%5.1f", pi)
nchar(sprintf("%5.1f", pi))

# 빈 공백에 0값 대입
sprintf("%05.1f", pi)

# 양수/음수 표현
sprintf("%+f", pi)
sprintf("%+f", -pi)

# 출력 문자열의 첫 번째 값을 공백으로
sprintf("% f", pi) 

# 왼쪽 정렬
sprintf("%-10.3f", pi)

# 수치형에 정수 포맷을 입력하면?
sprintf("%d", pi)
sprintf("%d", 100); sprintf("%d", 20L)

# 지수형
sprintf("%e", pi)
sprintf("%E", pi)
sprintf("%.2E", pi)


# 문자열 
sprintf("%s = %.2f", "Mean", pi)

# 응용 
mn <- apply(cars, 2, mean)
std <- apply(cars, 2, sd)

# Mean ± SD 형태로 결과 출력 (소숫점 2자리 고정)
res <- sprintf("%.2f \U00B1 %.2f", mn, std)
resp <- paste(paste0(names(cars), ": ", res), collapse = "\n")
writeLines(resp)


## ----substr-proto, eval=FALSE------------------------------------------------------------------------------
## substr(
##   x, # 문자형 벡터
##   start, # 문자열 추출 시작 위치
##   stop # 무자열 추출 종료 위치
## )


## ----substr-ex---------------------------------------------------------------------------------------------
cnu <- "충남대학교 자연과학대학 정보통계학과"
substr(cnu, start = 14, stop = nchar(str))

# 문자열 벡터에서 각 원소 별 적용
substr(str, 5, 15)



## ----low-up-fun-ex-----------------------------------------------------------------------------------------
LETTERS; tolower(LETTERS)

letters; toupper(letters)


## ----grep-proto, eval=FALSE--------------------------------------------------------------------------------
## # 일치하는 특정 문자열을 포함하는 원소값(문자형) 또는 인덱스(정수)를 반환
## 
## grep(
##   pattern, # 정규 표현식 또는 문자 패턴
##   string,  # 패턴을 검색할 문자열 벡터
##   value    # 논리값
##            # TRUE: pattern에 해당하는 원소값 반환
##            # FALSE: pattern이 있는 원소의 색인 반환
## )
## 


## ----grep-ex-----------------------------------------------------------------------------------------------
x <- c("Equator", "North Pole", "South Pole")

# x에서 Pole 이 있는 원소의 문자열 반환
grep("Pole", x, value = T)

# x에서 Pole 이 있는 원소의 색인 반환
grep("Pole", x, value = F)

# x에서 Eq를 포함한 원소 색인 반환
grep("Eq", x)


## ----grepl-proto, eval=FALSE-------------------------------------------------------------------------------
## # 일치하는 특정 문자열을 포함하는 원소 색인에 대한 논리값 반환
## 
## grepl(
##   pattern, # 정규 표현식 또는 문자 패턴
##   string  # 패턴을 검색할 문자열 벡터
## )
## 


## ----grepl-ex----------------------------------------------------------------------------------------------
# grepl() 예시
# Titanic data 불러오기
url1 <- "https://raw.githubusercontent.com/"
url2 <- "agconti/kaggle-titanic/master/data/train.csv"
titanic <- read.csv(paste0(url1, url2), 
                    stringsAsFactors = FALSE)

# 승객이름 추출 
pname <- titanic$Name

# 승객 이름이 James 인 사람만 추출
g <- grepl("James", pname)
pname[g]



## ----regexpr-ex1-------------------------------------------------------------------------------------------

x <- c("Darth Vader: If you only knew the power of the Dark Side. 
       Obi-Wan never told you what happend to your father", 
       "Luke: He told me enough! It was you who killed him!", 
       "Darth Vader: No. I'm your father")

# grep 계열 함수
grep("you", x); grepl("you", x)

# regexpr() 
regexpr("you", x) # 각 x의 문자열에서 you가 처음 나타난 위치 및 길이 반환
regexpr("father", x) # 패턴을 포함하지 않은 경우 -1 반환



## ----regexpr-ex2-------------------------------------------------------------------------------------------
idx <- regexpr("father", x)
substr(x, idx, idx + attr(idx, "match.length") - 1)


## ----gregexpr-ex-------------------------------------------------------------------------------------------
gregexpr("you", x) # 각 x의 문자열에서 you가 나타난 모든 위치 및 길이 반환
gregexpr("father", x) # 패턴을 포함하지 않은 경우 -1 반환


## ----sub-proto, eval=FALSE---------------------------------------------------------------------------------
## sub(pattern, # 검색하고자 하는 문자, 패턴, 표현
##     replacement, # 검색할 패턴 대신 변경하고자 하는 문자 및 표현
##     x # 문자형 벡터
##     )


## ----sub-ex------------------------------------------------------------------------------------------------
jude <- c("Hey Jude, don't make it bad", 
         "Take a sad song and make it better", 
         "Remember to let her into your heart", 
         "Then you can start to make it better")

sub("a", "X", jude)



## ----gsub-ex-----------------------------------------------------------------------------------------------
sub(" ", "_", jude)

gsub(" ", "_", jude)

gsub("a", "X", jude)



## ----------------------------------------------------------------------------------------------------------
bla <- c("I like statistics", 
         "I like R programming", 
         "I like bananas", 
         "Estates and statues are too expensive")

grepl("like", bla)

grepl("are", bla)

grepl("(like|are)", bla)



## ----------------------------------------------------------------------------------------------------------
gregexpr("stat", bla) 
gregexpr("(st)(at)", bla) 

# "at"에 대한 패턴을 찾지 못하고 
# "stat" 패턴과 과 동일한 결과 반환

regexec("(st)(at)", bla)
# "stat" 패턴도 동시에 반환됨을 유의
# 첫 번째 일치 패턴만 반환



## ----strsplt-proto, eval=FALSE-----------------------------------------------------------------------------
## strsplit(
##   x,    # 문자형 벡터
##   split # 분할 구분 문자(정규표현식 포함)
## )


## ----strsplit-ex-------------------------------------------------------------------------------------------
jude_w1 <- strsplit(jude, " ")
jude_w1

# 공백, 쉼표가 있는 경우 구분
jude_w2 <- strsplit(jude, "(\\s|,)")
jude_w2


## ----meta-char, echo=FALSE, message=FALSE------------------------------------------------------------------
Expression <- c("\\.", "\\+", "\\*", "?", "^", "$", "{}", "()", "|")
Name <- c("Period (마침표)", "Plus", "Asterisk", "Question mark", 
          "Caret", "Dollar", "Curly bracket", "Parenthesis", "Vertical bar")
`설명` <- c("무엇이든 한 글자를 의미", 
            "\\+ 앞에 오는 표현이 하나 이상 포함", 
            "\\* 앞에 오는 표현이 0 또는 하나 이상 포함", 
            "? 앞에 오는 표현이 0 또는 하나 포함", 
            "^ 뒤에 오는 표현으로 시작", 
            "$ 앞에 오는 표연으로 끝나는 경우", 
            "{} 앞에 정확히 {}에 있는 숫자만큼 반복되는 패턴 (예시 참고)", 
            "() 정규 표현식 내 하위(그룹) 표현식 (예시 참고)", 
            "| 의 왼쪽 또는 오른쪽 표현이 존재하는지")

meta_char1 <- data.frame(Expression, 
                         Name, `설명`, 
                         check.names = FALSE, 
                         stringsAsFactors = FALSE)

kable(meta_char1,
      align = "lll",
      escape = TRUE, 
      booktabs = T, caption = "정규표현식 메타 문자: 기본") %>%
  kable_styling(bootstrap_options = c("condensed", "striped"), 
                position = "center", 
                font_size = 10, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1:2, width = "3cm") %>% 
  column_spec(3, width = "7cm") %>% 
  row_spec(1:9, monospace = TRUE)


## ----escape-ex1, error=TRUE--------------------------------------------------------------------------------
# 마침표가 있는 위치 반환
str2 <- str[1:2]
regexpr(".", str2)


## ----escape-ex2, error=TRUE--------------------------------------------------------------------------------
# 에러 출력
regexpr("\.", str2)



## ----escape-ex3, error=TRUE--------------------------------------------------------------------------------
# 정확한 표현
regexpr("\\.", str2)



## ----dot-ex------------------------------------------------------------------------------------------------
# 문자열 자체가 존재하니까 참값 반환
grepl(".", jude) 
grepl(".", "#@#%@FDSAGF$%") 

# 문자없음 ""
grepl(".", "")

# a로 시작하고 중간에 어떤 글자가 하나 존재하고 b로 끝나는 패턴 
bla2 <- c("aac", "aab", "accb", "acadb")
g <- grepl("a.b", bla2)
bla2[g]

# a와 b 사이 어떤 두 문자 존재하는 패턴
g <- grepl("a..b", bla2)
bla2[g]


## ----plus-ex-----------------------------------------------------------------------------------------------
# "a"를 적어도 하나 이상 포함한 원소 반환
grepl("a+", c("ab", "aa", "aab", "aaab", "b"))

# "l"과 "n" 사이에 "o"가 하나 이상인 원소 반환
grepl("lo+n", c("bloon", "blno", "leno", "lnooon", "lololon"))



## ----asterisk-ex-------------------------------------------------------------------------------------------
# xx가 "a"를 0 또는 1개 이상 포함하고 있는가?
xx <- c("bbb", "acb", "def", "cde", "zde", "era", "xsery")
# "a" 존재와 상관 없이 모든 문자열이 조건에 부합
g <- grepl("a*", xx)
xx[g]

# "aab"와 "c" 사이에 "d"가 없거나 하나 이상인 경우 
# "caabec"인 경우 "aab"와 "c" 사이에 "e"가 존재하기 때문에 FALSE
grepl("aabd*c", c("aabddc", "caabec", "aabc"))



## ----question-ex-------------------------------------------------------------------------------------------
xx <- c("ac", "abbc", "abc", "abcd", "abbdc")

g <- grepl("ab?c", xx) ## "a"와 "c" 사이 "b"가 0개 또는 1개 포함
xx[g]

yy <- c("aabc", "aabbc", "daabec", "aabbbc", "aabbbbc")
g <- grepl("aabb?c", yy) ## "aab"와 "c" 사이에 "b"가 0개 또는 1개 있는 경우 일치
yy[g]



## ----caret-ex1---------------------------------------------------------------------------------------------
# str에서 "The"로 시작하는 문자열 반환
g <- grepl("^The", str)
str[g]


## ----caret-ex2---------------------------------------------------------------------------------------------
xx <- c("abc", "def", "xyz", "werx", "wbcsp", "cba")
# "a", "b", "c"를 순서 상관 없이 동시에 포함하지 않은 문자열 반환
g <- grepl("[^abc]", xx)
xx[g]


## ----caret-ex3---------------------------------------------------------------------------------------------
xx <- c("def", "wasp", "sepcial", "statisitc", "abbey load", "cross", "batman")
g <- grepl("^[abc]", xx)
xx[g]


## ----dollar-ex---------------------------------------------------------------------------------------------
g <- grepl("father$", x)
writeLines(x[g])


## ----c-bracket-ex------------------------------------------------------------------------------------------
xx <- c("tango", "jazz", "swing jazz", "hip hop", 
        "groove", "rock'n roll", "heavy metal")

# "z"가 정확히 2번 반복되는 원소 반환
g <- grepl("z{2}", xx)
xx[g]

# "e"가 2번 이상 반복되는 원소 반환
yy <- c("deer", "abacd", "abcd", "daaeb", "eel", "greeeeg")
g <- grepl("e{2,}", yy)
xx[g]

# "b"가 2번 이상 4번 이하 반복되고 앞에 "a"가 있는 원소 반환
zz <- c("ababababab", "abbb", "cbbe", "xabbbbcd")
g <- grepl("ab{2,4}", zz)
zz[g]


## **참고**: 위에서 소개한 메타 문자 중 `*`는 `{0,}`, `+`는 `{1,}`, `?`는 `{0,1}`과 동일한 의미를 가짐


## ----parenthesis-ex----------------------------------------------------------------------------------------
# ab가 1~4회 이상 반복되는 문자열 반환
g <- grepl("(ab){1,4}", zz)
zz[g]

# "The"로 시작하고  "punch"가 포함된 문자열 ㅂ반환
g <- grepl("^(The)+.*(punch)", str)
str[g]



## ----vertical-bar-ex---------------------------------------------------------------------------------------
g <- grepl("(is|was)", str)
str[g]

g <- grepl("(are|were)", str)
str[g]


## ----meta-char2, echo=FALSE, message=FALSE-----------------------------------------------------------------
Expression <- c("\\\\w", "\\\\d", "\\\\s", "\\\\W", "\\\\D", "\\\\S")
`설명` <- c("문자(letter), 숫자(digit), 또는 _ (underscore) 포함", 
            "숫자 0에서 9", 
            "공백문자(line break, tab, spaces)", 
            "\\\\w에 포함하지 않는 표현", 
            "숫자가 아닌 표현", 
            "공백이 아닌 표현")
meta_char2 <- data.frame(Expression, 
                         `설명`, 
                         check.names = FALSE, 
                         stringsAsFactors = FALSE)

kable(meta_char2,
      align = "ll",
      escape = TRUE, 
      booktabs = T, caption = "정규표현식 메타 문자: 문자집합") %>%
  kable_styling(bootstrap_options = c("condensed", "striped"), 
                position = "center", 
                font_size = 10, 
                full_width = TRUE, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "3cm") %>% 
  column_spec(2, width = "7cm") %>% 
  row_spec(1:6, monospace = TRUE)


## ----char-set-ex1------------------------------------------------------------------------------------------
# \w 를 이용해 email 추출

email <- c("demo@naver.com", 
           "sample@gmail.com", 
           "coffee@daum.net", 
           "redbull@nate.com", 
           "android@gmail.com", 
           "secondmoon@gmail.com", 
           "zorba1997@korea.re.kr")

# 이메일 주소가 naver 또는 gmail만 추출
g <- grepl("\\w+@(naver|gmail)\\.\\w+", email)
email[g]

# 숫자를 포함하는 문자열 추출: \d
ex <- c("ticket", "51203", "+-.,!@#", "ABCD", "_", "010-123-4567")
g <- grepl("\\d", ex)
ex[g]


# 뒤쪽 공백문자 제거
xx <- c("some text on the line 1; \n and then some text on line two        ")
sub("\\s+$", "", xx)


# 영문자(소문자 및 대문자 포함), 숫자, 언더바(_)를 제외한 문자 포함 
g <- grepl("\\W", ex)
ex[g]

# 숫자를 제외한 모든 문자 반환
g <- grepl("\\D", ex)
ex[g]

# 영문자, 숫자, 언더바를 제외한 모든 문자 포함하고
# 숫자와 특수문자를 포함하는 문자열도 제외
g <- grepl("\\W\\D", ex)
ex[g]

## 공백, 탭을 제외한 모든 문자 포함

blank <- c(" ", "_", "abcd", "\t", "%^$#*#*") 
g <- grepl("\\S", blank)
blank[g]



## ----meta-char3, echo=FALSE, message=FALSE-----------------------------------------------------------------
Expression <- c("[a-z]", "[A-Z]", "[0-9]", "[a-zA-Z]", 
                "[a-z0-9]", "[가-힝]", "[(abc)d]")
`설명` <- c("알파벳 소문자 중 하나", 
            "알파벳 대문자 중 하나", 
            "0에서 9까지 숫자 중 하나", 
            "모든 알파벳 중 하나", 
            "알파벳 소문자나 숫자 중 한 문자", 
            "모든 한글 중 하나", 
            "문자열 'abc'와 문자 'd' 중 하나")

meta_char3 <- data.frame(Expression, 
                         `설명`, 
                         check.names = FALSE, 
                         stringsAsFactors = FALSE)

kable(meta_char3,
      align = "ll",
      escape = TRUE, 
      booktabs = T, caption = "정규표현식 주요 문자 클래스") %>%
  kable_styling(bootstrap_options = c("condensed", "striped"), 
                position = "center", 
                font_size = 10, 
                full_width = TRUE, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "3cm") %>% 
  column_spec(2, width = "7cm") %>% 
  row_spec(1:7, monospace = TRUE)


## ----meta-char4, echo=FALSE, message=FALSE-----------------------------------------------------------------
Expression <- c("[[:punct:]]", "[[:alpha:]]", "[[:lower:]]", "[[:upper:]]", 
                "[[:digit:]]", "[[:alnum:]]", "[[:cntrl:]]", "[[:print:]]", 
                "[[:space:]]", "[[:blank:]]", "[[:xdigit:]]")
`설명` <- c("구둣점 문자 [][!#$%&’()*+,./:;<=>?@\\\\^_`{|}~-]", 
            "알파벳 [A-Za-z]와 동일한 표현", 
            "소문자 알파벳 [a-z]와 동일", 
            "대문자 알파벳 [A-Z]와 동일", 
            "숫자 0 ~ 9 [0-9]와 동일", 
            "알파벳과 숫자 [0-9A-Za-z]와 동일", 
            "제어문자 b", 
            "모든 인쇄 가능한 문자", 
            "공백문자 \\\\t\\\\r\\\\n\\\\v\\\\f", 
            "공백문자 중 \\\\t \\\\n", 
            "16 진수")

meta_char4 <- data.frame(Expression, 
                         `설명`, 
                         check.names = FALSE, 
                         stringsAsFactors = FALSE)

kable(meta_char4,
      align = "ll",
      escape = TRUE, 
      booktabs = T, caption = "정규표현식: POSIX 문자 클래스") %>%
  kable_styling(bootstrap_options = c("condensed", "striped"), 
                position = "center", 
                font_size = 10, 
                full_width = TRUE, 
                latex_options = c("striped", "HOLD_position")) %>% 
  column_spec(1, width = "3cm") %>% 
  column_spec(2, width = "7cm") %>% 
  row_spec(1:11, monospace = TRUE)


## ----------------------------------------------------------------------------------------------------------
movie <- c("terminator 3: rise of the machiens", 
           "les miserables", 
           "avengers: infinity war", 
           "iron man", 
           "indiana jones: the last crusade", 
           "irish man", 
           "mission impossible", 
           "the devil wears prada", 
           "parasite (gisaengchung)", 
           "once upon a time in hollywood")

# 각 영화제목의 첫글자를 대문자로 변경
# \b는 단어의 양쪽 가장 자리의 빈 문자를 의미
# \\1은 () 첫 번째 그룹, \\U는 대문자(perl)
gsub("\\b(\\w)", "\\U\\1", movie, perl = T)


# 엑셀에서 ()로 표시된 음수 데이터를 읽어온 경우
# 이를 음수로 표시
num <- c("0.123", "0.456", "(0.45)", "1.25")
gsub("\\(([0-9.]+)\\)", "-\\1", num)



## ----blank-det-ex------------------------------------------------------------------------------------------
txt <- c("        신종 코로나바이러스 감염증(코로나19) 환자 가운데 회복해서 항체가
         생긴 사람 중 절반가량은 체내에 바이러스가 남아 있는 것으로 나타났다.   ")
txt
# 모근 공백 제거
gsub("\\s", "", txt)

# 앞쪽 공백만 제거
gsub("^\\s+", "", txt)

# 뒤쪽 공백만 제거
gsub("\\s+$", "", txt)

# 양쪽에 존재하는 공백들 제거
gsub("(^\\s+|\\s+$)", "", txt)

# 가운데 \n 뒤에 존재하는 공백들을 없애려면??
gsub("(^\\s+| {2,}|\\s+$)", "", txt)



## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'--------------------------------------
knitr::include_graphics('figures/cellphone-str.png', dpi = NA)


## ----cellphone-ex------------------------------------------------------------------------------------------
phone <- c("042-868-9999", "02-3345-1234", 
           "010-5661-7578", "016-123-4567", 
           "063-123-5678", "070-5498- 1904", 
           "011-423-2912", "010-6745-2973")

g <- grepl("^(01)\\d{1}-\\d{3,4}-\\d{4}", phone)
phone[g]


## ----fig.align='center', echo=FALSE, fig.show='hold', out.width='90%'--------------------------------------
knitr::include_graphics('figures/email-str.png', dpi = NA)


## ----email-ex----------------------------------------------------------------------------------------------
# 크롤링한 데이터 불러오기
news_naver <- read.csv("dataset/news-scraping.csv", header = T, 
                       stringsAsFactors = FALSE)

# regmatches 함수: regexpr(), gregexpr(), regexec()로 검색한 패턴을
# 텍스트(문자열)에서 추출

# ID 추출
id <- regmatches(news_naver$url, regexpr("\\d{10}", news_naver$url))
contents <- news_naver$news_content
news_naver2 <- data.frame(id, title = news_naver$news_title, 
                          stringsAsFactors = FALSE)
tmp <- regmatches(contents, 
                  gregexpr("\\b[A-Za-z0-9[:punct:]]+@[A-Za-z0-9[:punct:]]+\\.[A-Za-z]+", 
                           contents))
names(tmp) <- id
x <- t(sapply(tmp, function(x) x[1:2], simplify = "array"))
colnames(x) <- paste0("email", 1:2)
email <- data.frame(id = row.names(x), x, stringsAsFactors = F)
res <- merge(news_naver2, email, by = "id")
head(res)

# stringr 패키지 사용

# email <- str_extract_all(contents,
#          "\\b[A-Za-z0-9[:punct:]]+@[A-Za-z0-9[:punct:]]+\\.[A-Za-z]+",
#          simplify = TRUE)
# email <- data.frame(email, stringsAsFactors = FALSE)
# names(email) <- paste0("email", 1:2)
# res <- data.frame(id, title = news_naver$news_title, email,
#                   stringsAsFactors = FALSE)
# head(res)



