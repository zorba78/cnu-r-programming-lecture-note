---
name: lecture-style
description: 강의노트 .Rmd 장을 작성·수정·리팩터링할 때 따르는 문체, 장 구조, 헤딩/ID, knitr 청크 옵션, 콜아웃(block2), 수식, 인용, 데이터 경로 규칙. Rmd 파일을 편집하기 전에 항상 로드한다. (Korean lecture note house style, bookdown, knitr chunk conventions)
---

# 강의노트 스타일 가이드

이 문서는 기존 13개 장에서 관찰된 관례를 정리한 것이다. 기존 장을 고칠 때는 이 관례를 유지하고, 새 장은 이 관례로 작성한다. "현대화 권장" 항목은 업그레이드 시 새 코드에 적용하되 기존 코드를 일괄 치환하지는 않는다.

## 1. 장(chapter) 골격

```markdown
---
output: html_document
editor_options:
  chunk_output_type: console
---

# 장 제목(English term) {#chapter-id}

```{r chunk-setup, echo=FALSE, message=FALSE, warning=FALSE}
# ← 02-data-type.Rmd 의 chunk-setup 청크를 그대로 복사 (knitr hook + linewidth 60)
# 이어서 장에서 쓰는 패키지 로드: require(tidyverse); require(knitr); require(kableExtra)
```

```{block2, type="rmdimportant"}
**학습 목표**
- ...
```

## 절 제목 {#section-id}
```

- `_bookdown.yml` 은 `new_session: true`. **장마다 setup 청크에서 패키지를 로드**해야 한다. 다른 장의 객체를 참조하지 않는다.
- Part 구분은 `# (PART) 제목 {-}` 한 줄. 현재 Part 1 은 `01-introduction.Rmd`, Part 2 는 `08-introduction-2nd.Rmd` 에 있다.
- 일부 장은 첫머리에 `> **Sketch**` 인용문으로 장 개요를 둔다 (05장). 개정 장에서는 `rmdimportant` 콜아웃의 "학습 목표"로 통일한다.
- 파일명은 `NN-kebab-name.Rmd`. 번호는 책 순서. 새 장을 삽입할 때는 기존 번호를 밀지 말고 빈 번호(14 등)를 쓰거나 `_bookdown.yml` 에 `rmd_files:` 로 순서를 명시한다.

## 2. 헤딩과 ID

- `# 장 {#id}`, `## 절 {#id}`, `### 소절 {#id}`. ID 는 영문 소문자 kebab-case. 번호 없는 절은 `{#id .unnumbered}` 또는 `{-}`.
- **기존 ID 는 바꾸지 않는다.** `docs/` 의 HTML 파일명과 앵커가 ID 에서 생성되며 외부에서 링크된다.
- 코드 청크 안의 `## 주석` 은 헤딩이 아니다. 청크 내부에서는 `#`/`##` 주석을 자유롭게 쓴다.
- 함수 이름을 제목으로 쓸 때: `### **`paste()`**, **`paste0()`** {#paste}` 처럼 굵게 + 코드 서식.

## 3. 문체

- 본문: 한국어 평서체 "~이다/~한다". 목록·콜아웃에서는 개조식 "~임/~함" 도 허용 (기존 장이 혼용).
- 존댓말("~합니다") 사용하지 않는다.
- 용어는 첫 등장 시 영문 병기: `데이터 프레임(data frame)`, `요인(factor)`. 이후에는 한국어만.
- 자주 쓰는 용어 통일: 벡터, 행렬, 리스트, 데이터 프레임, 요인, 인수(argument), 반환(return), 객체, 함수, 청크(chunk), 패키지.
- 학생에게 직접 말할 때: "확인해 보자", "다음을 생각해 보자". 명령형 "하시오" 는 과제 문항에서만.
- 화살표는 `$\rightarrow$` (본문) 또는 `->` (코드 주석).

## 4. 코드 청크

- 전역 설정(setup 청크): `comment = NA`, `size = "footnotesize"`, `linewidth = 60` hook. 출력 폭이 60자로 강제 접히므로 긴 출력은 `head()` 로 줄인다.
- 자주 쓰는 옵션: `echo`, `eval`, `error=TRUE`(의도적 오류 예시), `message/warning=FALSE`, `fig.width/fig.height`, `out.width`, `fig.align='center'`, `fig.cap`, `fig.show`.
- 그림 청크: `fig.cap` 을 주면 `\@ref(fig:label)` 로 참조 가능. 레이블은 영문 kebab-case, 장 내 유일해야 한다 (같은 레이블이 두 장에 있어도 new_session 이라 렌더는 되지만 상호참조가 꼬인다).
- 코드 주석은 한국어. 청크 첫 줄에 `# 목적` 한 줄, 세부 설명은 해당 행 위에.
- 한 청크는 한 개념. 결과를 학생이 봐야 하는 청크는 출력을 숨기지 않는다.
- 의도적 오류 예시는 `error=TRUE` 로 두고 본문에 왜 오류가 나는지 설명한다.
- 코드 줄 폭 80자 이내. 긴 파이프는 `|>` 뒤에서 줄바꿈하고 2칸 들여쓰기.
- 데이터 경로는 프로젝트 루트 기준 상대경로 `dataset/xxx.csv`. `setwd()` 금지.
- 내장 데이터 우선순위: `mtcars`, `iris`, `mpg`, `diamonds`, `gapminder`, `airquality`, `sleep`. 이미 본문에서 쓰인 데이터를 재사용한다.
- 난수를 쓰면 `set.seed()` 를 청크 안에서 명시한다.

### 현대화 권장 (새 코드에 적용)

- 새 코드는 `|>`. **`%>%` 는 구식이 아니므로 일괄 교체하지 않는다** (강사 판단). 한 절 안에서 두 표기를 섞지 않는 것만 지킨다.
- `across()`, `pivot_longer()/pivot_wider()`, `slice_max()/slice_min()/slice_sample()`, `if_any()/if_all()`, `reframe()`.
- ggplot2: 선 굵기는 `linewidth`, 계산 변수는 `after_stat()`, `qplot()` 사용 금지.
- `prompt=TRUE` (콘솔 `>` 프롬프트 표시) 는 복사·붙여넣기를 방해하므로 새 청크에는 쓰지 않는다. 기존 청크는 개정 시 제거.
- `tidy=TRUE` (formatR) 는 쓰지 않는다. 코드는 styler 스타일로 직접 정리한다.
- `require()` 대신 `library()`. 단, setup 청크의 기존 `require()` 는 놔둔다.

## 5. 콜아웃 (block2)

`css/style.css` 에 정의된 다섯 종류만 사용한다.

| type | 용도 | 기존 사용 빈도 |
|---|---|---|
| `rmdnote` | 배경 설명, 참고 사항, 안내 | 61 |
| `rmdtip` | 실무 팁, 단축키, 더 간결한 방법 | 36 |
| `rmdimportant` | 학습 목표, 핵심 정리, 꼭 기억할 정의 | 23 |
| `rmdcaution` | 흔한 실수, 헷갈리는 동작 | 5 |
| `rmdwarning` | 데이터 손상·되돌릴 수 없는 결과 등 위험 | 5 |

```markdown
```{block2, type="rmdtip"}
**참고**: 콜아웃 안에서는 마크다운, 인라인 코드, 수식 모두 사용 가능
```
```

- 콜아웃 안에 R 코드 청크를 넣을 수 없다. 코드는 콜아웃 앞뒤에 둔다.
- 콜아웃 type 인수는 큰따옴표 `type="rmdnote"` 로 통일.

## 6. 수식·표·인용·상호참조

- 인라인 `$x_i$`, 디스플레이 `$$ ... $$`. 행렬/벡터는 `\mathbf{X}`. 분포 표기 `X \sim N(\mu, \sigma^2)`.
- 표: 작은 표는 마크다운 파이프 표. 데이터 표는 `knitr::kable()` + `kableExtra`. `df_print: paged` 가 켜져 있어 데이터 프레임 출력은 자동으로 페이지 표가 된다.
- 인용: `[@key]`. 키는 `book.bib` 에 추가. 패키지 인용은 `packages.bib`.
- 상호참조: 절 `\@ref(section-id)`, 그림 `\@ref(fig:label)`, 표 `\@ref(tab:label)`.
- 외부 링크: `[표시 텍스트](URL)`. 추가 전 접근 확인.

## 7. 연습문제·과제 연결

- 장 끝에 `## 연습문제 {#ex-<chapter-id> .unnumbered}` 를 둘 수 있다. 문항은 `1.`, 소문항은 `a)`.
- 정답은 본문에 싣지 않는다. 과제는 `assignment/` 로 (`assignment` 스킬 참고).

## 8. 수정 후 확인 절차

1. `Rscript .claude/skills/check-chapter/scripts/run_chunks.R <장.Rmd>` 로 청크 실행 확인.
2. 본문에서 언급하는 출력값(예: "평균은 20.09")이 실행 결과와 일치하는지 대조.
3. 새 레이블·ID 가 장 내에서 유일한지 `grep -n '{#' <장.Rmd>` 로 확인.
4. 렌더 확인이 필요하면 `bash .claude/skills/build-book/scripts/render.sh <장.Rmd>`.
