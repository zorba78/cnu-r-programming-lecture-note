# CP949 CSV 파일 읽기 코드 요청 (11장 "AI와 함께")

- 모델: Claude Sonnet 5. Claude Code 의 하위 에이전트로 호출했고, 도구를 쓰지 않고 한 번에 답하도록 지시했다(아래 "호출 방법"). 한 번만 요청했고 다른 응답을 골라 싣지 않았다.
- 날짜: 2026-09-14
- 쓰인 곳: `11-data-import-export.qmd` 의 @sec-ai-import. 본문에는 응답의 첫 번째 코드 블록(readr 판)만 실었다. 실행할 때는 파일 경로 두 곳에 `dataset/ch11/` 만 덧붙였다.
- 프롬프트의 오류 메시지는 R 4.6.1, readr 2.2.0 에서 `dataset/ch11/library-loans.csv` 를 실제로 읽어 얻은 콘솔 출력이다. 붙여 넣은 7줄도 같은 파일의 앞부분이다.

## 호출 방법

학생 요청 앞에 다음 지시를 붙여 보냈다. 9장과 같은 지시문이다.

> 아래 [요청]은 통계학과 2학년 학생이 AI 채팅 도우미에게 보낸 메시지다. 일반적인 AI 채팅 도우미가 이 학생에게 답하듯이, 한 번에 답하라.
> 규칙: 도구를 쓰지 마라. 파일을 읽거나 쓰지 말고, 코드를 실행하지 마라. 되묻지 말고 바로 답하라. 네 최종 메시지는 학생에게 보낼 답변 본문 그 자체여야 한다.

## 학생 요청 (프롬프트 전문)

````text
과제로 받은 CSV 파일(library-loans.csv)을 R로 읽으려고 하는데 계속 오류가 나.

read.csv("library-loans.csv") 를 실행하면 이렇게 나오고

Error in read.table(file = file, header = header, sep = sep, quote = quote,  : 
  more columns than column names

readr 패키지의 read_csv("library-loans.csv") 를 실행하면 이렇게 나와.

Rows: 24 Columns: 1
Error in nchar(x, "width") : invalid multibyte string, element 1

메모장으로 열어 보면 앞부분은 이렇게 생겼어.

전국 공공도서관 2026년 8월 대출 현황
※ 교육용 가상 자료: 도서관 이름과 수치는 실제와 무관함
도서관,시도,우편번호,개관일,열람석,대출권수,이용자수
누리도서관,서울,04157,2004.03.15,320,"48,215",12904
한빛도서관,서울,02831,1998.11.02,410,"61,530",15220
가람도서관,경기,16489,2011.06.20,250,"35,108",9870
솔빛도서관,인천,21554,2015.09.01,180,"22,764",6412

이 파일을 제대로 읽어서 분석에 쓸 수 있는 데이터프레임으로 만드는 R 코드를 짜 줘.
````

## 응답 전문

아, 이 파일 딱 봐도 전형적인 "공공데이터 포털 스타일" CSV네요. 두 가지 문제가 겹쳐 있어서 각각 에러가 다르게 난 거예요.

## 왜 에러가 났는지

**1) `read.csv` 에러 — "more columns than column names"**
파일 맨 위 두 줄(`전국 공공도서관...`, `※ 교육용...`)이 진짜 헤더가 아닌데, `read.csv`는 무조건 첫 줄을 열 이름으로 인식합니다. 첫 줄엔 콤마가 없으니 "열이 1개"라고 착각하고, 그다음 진짜 헤더 줄(`도서관,시도,...`)이 7개 필드로 나오니까 "열 이름 개수보다 필드가 더 많다"고 에러를 낸 거예요.

**2) `read_csv` 에러 — "invalid multibyte string"**
이건 인코딩 문제입니다. `Rows: 24 Columns: 1`도 같은 이유(첫 줄에 콤마가 없어서 1열로 오인)로 나온 거고, 그 이후 진짜 에러는 파일이 **UTF-8이 아니라 EUC-KR(CP949)**로 저장돼 있어서 생긴 겁니다. 한국 엑셀에서 "다른 이름으로 저장 → CSV"를 하면 기본적으로 EUC-KR/CP949로 저장되는데, `read_csv`는 기본적으로 UTF-8이라고 가정하고 읽다가 깨진 바이트를 만나서 죽는 거예요. 메모장에서 멀쩡하게 보인 건 메모장이 인코딩을 자동 감지해서 보여주기 때문이지, 파일이 UTF-8이라는 증거는 아닙니다.

## 해결 코드

```r
library(readr)
library(dplyr)

# 인코딩이 확실하지 않으면 먼저 추정
guess_encoding("library-loans.csv")
# confidence가 가장 높게 나온 인코딩을 아래 locale()에 넣으면 됩니다

loans <- read_csv(
  "library-loans.csv",
  skip = 2,                               # 제목 줄 + 설명 줄 2개 건너뛰기
  locale = locale(encoding = "CP949"),    # 안 되면 "EUC-KR"도 시도
  col_types = cols(
    우편번호 = col_character(),           # "04157"의 앞자리 0이 사라지지 않게
    대출권수 = col_number(),              # "48,215" 같은 천단위 콤마 숫자를 바로 숫자로
    .default = col_guess()
  )
) |>
  mutate(개관일 = as.Date(개관일, format = "%Y.%m.%d"))  # "2004.03.15" -> Date형

glimpse(loans)
```

## 정제 포인트 3가지 (놓치기 쉬움)

- **우편번호**: 그냥 두면 숫자로 인식돼 `04157`이 `4157`로 앞자리 0이 날아갑니다. 반드시 문자형으로.
- **대출권수**: `"48,215"`처럼 따옴표+콤마로 감싸져 있어서 그냥 읽으면 텍스트로 들어옵니다. `col_number()`(또는 나중에 `parse_number()`)로 콤마를 제거하면서 숫자로 바꿔야 합니다.
- **개관일**: `.`으로 구분된 날짜라 `read_csv`가 자동으로 날짜인지 못 알아채고 문자로 들어옵니다. `format = "%Y.%m.%d"`를 명시해서 `as.Date()`로 변환해야 합니다.

## CP949도 안 맞으면

`guess_encoding("library-loans.csv")` 결과를 보고 다른 인코딩(예: `"UTF-8"`, `"UTF-8-BOM"`)이 더 높은 확신도로 나오면 그걸로 바꿔서 넣어보세요. 그리고 파일 맨 아래에도 출처 표시 같은 꼬리말 줄이 있을 수 있으니, 다 읽은 다음 `tail(loans)`로 마지막 행들이 이상한 `NA` 행은 아닌지 한 번 확인하는 게 좋습니다.

## base R로 하고 싶다면

```r
loans_base <- read.csv(
  "library-loans.csv",
  skip = 2,
  fileEncoding = "CP949",
  colClasses = c(우편번호 = "character", 대출권수 = "character"),
  check.names = FALSE
)

loans_base$대출권수 <- as.numeric(gsub(",", "", loans_base$대출권수))
loans_base$개관일   <- as.Date(loans_base$개관일, format = "%Y.%m.%d")
```

원리는 동일합니다: 앞의 설명 줄 건너뛰기 + 인코딩 지정 + 우편번호/대출권수만 따로 손봐주기.
