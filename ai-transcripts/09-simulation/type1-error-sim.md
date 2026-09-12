# 1종 오류율 시뮬레이션 함수 요청 (9장 "AI와 함께")

- 모델: Claude Sonnet 5. Claude Code 의 하위 에이전트로 호출했다. 도구를 쓰지 않고 한 번에 답하도록 지시했다(아래 "호출 방법").
- 날짜: 2026-09-12
- 쓰인 곳: `09-simulation.qmd` 의 @sec-ai-simulation. 본문에는 응답의 첫 번째 코드 블록(`sim_type1_error()`)만 수정 없이 실었다.

## 호출 방법

학생 요청 앞에 다음 지시를 붙여 보냈다.

> 아래 [요청]은 통계학과 2학년 학생이 AI 채팅 도우미에게 보낸 메시지다. 일반적인 AI 채팅 도우미가 이 학생에게 답하듯이, 한 번에 답하라.
> 규칙: 도구를 쓰지 마라. 파일을 읽거나 쓰지 말고, 코드를 실행하지 마라. 되묻지 말고 바로 답하라. 네 최종 메시지는 학생에게 보낼 답변 본문 그 자체여야 한다.

## 학생 요청 (프롬프트 전문)

R로 독립 이표본 t-검정의 1종 오류율을 시뮬레이션으로 추정하는 함수를 만들어 줘. 두 집단의 표본 크기와 표준편차, 반복 횟수를 인수로 받고, 유의수준 0.05에서 귀무가설을 기각한 비율을 반환하면 돼.

## 응답 전문

좋아요, 아래처럼 만들면 됩니다.

```r
sim_type1_error <- function(n1, n2, sd1, sd2, nsim = 10000, alpha = 0.05, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)

  reject_count <- 0

  for (i in seq_len(nsim)) {
    x <- rnorm(n1, mean = 0, sd = sd1)
    y <- rnorm(n2, mean = 0, sd = sd2)   # 귀무가설(H0: mu1 = mu2)이 참이 되도록 두 집단의 평균을 0으로 같게 둔다

    p_value <- t.test(x, y)$p.value
    if (p_value < alpha) reject_count <- reject_count + 1
  }

  reject_count / nsim
}
```

**설계에서 중요한 부분**

- **두 집단의 평균을 반드시 같게(코드에서는 0) 둬야 한다.** 1종 오류율은 "귀무가설이 참인데 기각하는 비율"이므로, 평균을 다르게 생성하면 그건 1종 오류가 아니라 검정력(power) 시뮬레이션이 돼버린다. 표준편차만 인수로 받고 평균은 안 받는 이유도 이 때문이다.
- `t.test(x, y)`는 기본적으로 **Welch의 t-검정**(등분산 가정을 하지 않음)을 쓴다. 등분산을 가정하는 스튜던트 t-검정과 비교하고 싶으면 `t.test(x, y, var.equal = TRUE)`로 바꿔서 같이 돌려보면 좋다.
- `seed` 인수는 선택적으로 넣었다. 기본값 `NULL`이면 매번 다른 결과가 나오고(원래 몬테칼로 시뮬레이션이 그래야 정상), `seed`를 지정하면 재현 가능한 결과를 얻을 수 있다.

`nsim`이 10000 정도면 실행 결과가 0.05 근처(대략 0.045~0.055 범위) 값으로 나오는 게 정상이다. 이 값에서 크게 벗어난다면 코드나 로직에 문제가 있다는 뜻이니 그 자체가 검증 포인트다.

**사용 예**

```r
sim_type1_error(n1 = 20, n2 = 20, sd1 = 1, sd2 = 1, nsim = 10000, seed = 1)
```

**더 짧게 쓰고 싶다면** `replicate()`로 for문 없이도 쓸 수 있다.

```r
sim_type1_error2 <- function(n1, n2, sd1, sd2, nsim = 10000, alpha = 0.05) {
  reject <- replicate(nsim, {
    x <- rnorm(n1, mean = 0, sd = sd1)
    y <- rnorm(n2, mean = 0, sd = sd2)
    t.test(x, y)$p.value < alpha
  })
  mean(reject)
}
```

**한 걸음 더 나가보고 싶다면**: `n1, n2`와 `sd1, sd2`를 불균형하게(예: `n1 = 10, sd1 = 3, n2 = 30, sd2 = 1`) 주고 `var.equal = TRUE`와 기본값(`FALSE`, Welch)의 결과를 비교해보세요. 일반적으로 **표본 크기가 작은 집단이 분산까지 크면** 등분산 가정을 쓴(`var.equal = TRUE`) 검정의 실제 1종 오류율이 0.05보다 눈에 띄게 커지는 반면, Welch 검정은 이런 불균형에서도 0.05 근처를 잘 유지합니다. 이게 통계학에서 Behrens–Fisher 문제로 불리는 현상이고, 실무에서 `t.test()`의 `var.equal` 기본값이 `FALSE`인 이유이기도 합니다.
