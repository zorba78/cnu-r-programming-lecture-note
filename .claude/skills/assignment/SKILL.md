---
name: assignment
description: 강의노트의 특정 장 범위로 과제(homework)·퀴즈·시험 문항과 정답 파일을 작성한다. 기존 assignment/ 템플릿 형식을 따르며, AI 사용을 허용하는 전제의 평가 유형(검증 과제, AI 코드 버그 찾기, 과정 기록, 시뮬레이션 확인)을 포함한다. "과제 만들어줘", "퀴즈 문항", "기말 문제", "채점 기준" 요청에 사용.
argument-hint: <homework N | quiz | midterm | final> <범위 장>
---

# 과제·평가 작성 (assignment)

## 파일 규칙

| 종류 | 문제 파일 | 정답 파일 (gitignore 대상) |
|---|---|---|
| 과제 | `assignment/homeworkN_template.Rmd` | `assignment/homeworkN_solution.Rmd` |
| 퀴즈 | `assignment/quizN_template.Rmd` | `assignment/quizN_solution.Rmd` |
| 시험 | `assignment/midterm_YYYY.Rmd` / `final_YYYY.Rmd` | `assignment/*_solution.Rmd` |

- 정답 파일명은 반드시 `*solution.Rmd` 로 끝나야 `.gitignore` 에 걸린다. 작성 후 `git check-ignore <파일>` 로 확인한다.
- 기존 템플릿(`assignment/homework3_template.Rmd`) 의 YAML 을 그대로 쓴다:

```yaml
---
title: "Homework #N"
subtitle: "학교, 학과, 학번 입력"
author: "한글 이름 입력"
date: "`r paste('제출일자:', Sys.Date())`"
output:
  html_document:
    df_print: paged
---
```

- 문항은 `**1. (배점) 문제**`, 소문항은 `a)`, `b)`. 문항 사이 `<br/>`. 학생이 답을 쓸 빈 청크 `{r}` 를 문항 아래에 둔다.
- 문항 말미는 "~하시오." 명령형. 본문 강의노트 절을 `\@ref()` 대신 "강의노트 2.5절 참고" 처럼 텍스트로 지칭한다 (과제는 책 밖에서 렌더되므로 상호참조 불가).

## 문항 설계 원칙 (AI 허용 전제)

과제당 3~5문항, 유형을 섞는다. 배점 합 100.

| 유형 | 설명 | 예 |
|---|---|---|
| **A. 직접 구현** | 강의 범위의 핵심 개념을 짧게 구현 | 분산 계산 함수를 `var()` 없이 작성 |
| **B. 검증** | 주어진(또는 AI 가 만든) 코드가 맞는지 판정하고 근거 제시 | 이 `pivot_longer` 결과가 맞는지 행 수와 합계로 확인 |
| **C. 버그 찾기** | 실제 LLM 출력에서 수집한 오류 코드 수정 | `group_by` 후 `summarise` 결과가 기대와 다른 이유 설명 |
| **D. 시뮬레이션 확인** | 이론값과 모의실험 결과 비교 (07장 방식) | 신뢰구간 포함 확률 95% 확인 |
| **E. 과정 기록** | AI 를 썼다면 프롬프트·응답·수정 내역 첨부. 안 썼다면 그 사실 명시 | 모든 과제 공통 마지막 문항 (배점 5~10) |
| **F. 해석·설명** | 결과를 한국어 3~5문장으로 해석 | 두 군 차이의 통계적·실질적 의미 |

- A 유형만으로 채우지 않는다. 최소 B/C/D 중 하나 포함.
- "AI 사용 금지" 문항은 만들지 않는다. 대신 AI 가 틀리기 쉬운 문항(검증, 반례, 해석)으로 변별한다.
- 문항 상단에 AI 사용 안내 콜아웃 대신 다음 문구를 고정으로 넣는다:
  > AI 도구 사용 가능. 단, 사용한 프롬프트와 응답을 마지막 문항에 첨부하고, 제출 코드는 본인이 설명할 수 있어야 한다.
- 데이터는 강의노트의 `dataset/` 또는 내장 데이터. 새 데이터가 필요하면 `set.seed()` 로 생성하는 코드를 문항에 포함.

## 정답 파일

- 문제 파일을 복사한 뒤 각 답 청크를 채운다. 채점 포인트를 `<!-- 채점: ... -->` HTML 주석으로 문항마다 적는다.
- 배점 세부: 정답 60%, 검증·근거 25%, 코드 가독성·주석 15% (F 유형은 해석 정확성 80%, 표현 20%).
- **정답 코드는 실제로 실행해 확인한다**: `Rscript .claude/skills/check-chapter/scripts/run_chunks.R assignment/homeworkN_solution.Rmd`. 이어서 `Rscript -e 'rmarkdown::render("assignment/homeworkN_solution.Rmd")'` 로 렌더 확인 후 생성된 html 은 삭제하거나 gitignore(`*solution.html`) 에 걸리는지 확인.
- C 유형의 오류 코드는 실제 LLM 출력을 쓴다. 지어내야 한다면 "가공 예시" 라고 문항에 명시한다.

## 작성 절차

1. 범위 장의 절 목록을 뽑아 평가할 개념 3~5개 선정.
2. 유형표에 따라 문항 초안 → 배점.
3. 문제 파일 작성 → 정답 파일 작성 → 실행·렌더 검증.
4. 예상 소요 시간(학생 기준)을 문항별로 적어 사용자에게 보고. 합계 3시간 초과면 줄인다.
5. 사용자 검토 후 `git check-ignore` 로 정답 파일이 제외되는지 재확인.
