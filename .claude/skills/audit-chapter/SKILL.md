---
name: audit-chapter
description: 강의노트의 한 장(.Rmd)을 감사해 구식·폐기된 R/tidyverse API, CRAN에서 사라진 패키지, 죽은 외부 링크, 오래된 도구 안내(RStudio 버전 등), AI 시대 교수법 관점의 개선점을 심각도별로 정리한 보고서를 upgrade/audit/ 에 작성한다. "이 장 감사해줘", "뭐가 구식인지 봐줘", "업그레이드 계획 세워줘" 요청에 사용.
argument-hint: <chapter.Rmd>
---

# 장 감사 (audit-chapter)

목표: 한 장을 읽고 **무엇을, 왜, 어떻게 바꿔야 하는지**를 줄 번호와 함께 보고서로 남긴다. 이 스킬은 보고서만 쓰고 본문은 고치지 않는다. 수정은 사용자가 보고서를 보고 지시한다.

## 절차

1. **장 전체를 읽는다.** 2000줄 넘는 장은 나눠 읽되 빠짐없이 읽는다. 절 구조와 예제 데이터 흐름을 파악한다.
2. **구식 코드 스캔.** `references/deprecations.md` 의 패턴 표를 기준으로 `grep -n` 한다. 각 발견에 대해 대체 API 와 동작 차이(있으면)를 적는다.
3. **실행 검증.** `Rscript .claude/skills/check-chapter/scripts/run_chunks.R <장.Rmd>` 를 실행해 오류 청크와 deprecation 경고를 수집한다. 결과를 보고서에 붙인다.
4. **패키지 가용성.** 장에서 `library/require/install.packages/::` 로 쓰는 패키지 목록을 뽑고, 설치 여부와 CRAN 존재 여부를 확인한다.
   ```r
   Rscript -e 'p <- c("pkg1","pkg2"); ap <- rownames(available.packages(repos="https://cloud.r-project.org")); ip <- rownames(installed.packages()); for (x in p) cat(sprintf("%-14s installed=%-5s cran=%s\n", x, x %in% ip, x %in% ap))'
   ```
5. **외부 링크.** `grep -ohE 'https?://[^ )>"]+' <장.Rmd> | sort -u` 후 `curl -sIL -o /dev/null -w '%{http_code} %{url_effective}\n' --max-time 10 <url>` 로 상태 확인. 4xx/5xx/timeout 은 보고.
6. **도구·환경 안내 점검.** R 버전, RStudio 버전·스크린샷, 설치 경로, 패키지 설치 방법, 인코딩(CP949/UTF-8) 설명이 2026년 기준으로 맞는지. Positron, Quarto, native pipe 언급 여부.
7. **교수법 점검 (AI 시대 관점).** 각 절에 대해 다음을 묻는다.
   - 이 절의 내용은 LLM 이 대신할 수 있는 "타이핑" 인가, 학생이 반드시 이해해야 하는 "개념" 인가? 타이핑 성격이면 압축 후보.
   - 생성된 코드를 검증하는 활동(예상 결과 적기, 테스트, 시뮬레이션 비교)으로 바꿀 수 있는 예제가 있는가?
   - "AI와 함께" 절을 넣기 좋은 위치는 어디인가? (`ai-curriculum` 스킬 참고)
   - 예제 데이터가 시의성을 잃었는가 (예: 2020-04 COVID 집계).
8. **보고서 작성.** `upgrade/audit/<장 파일명 without .Rmd>.md` 에 아래 형식으로 저장한다 (`mkdir -p upgrade/audit`).
9. **CLAUDE.md 진행 상태 표**의 해당 장을 `감사 완료` 로 갱신한다.

## 보고서 형식

```markdown
# 감사 보고서: 02-data-type.Rmd
- 감사일: 2026-09-10 / R 4.6.1 / 감사자: Claude
- 규모: 4162줄, 코드 청크 N개, 실행 결과: OK n / ERROR n / SKIP n

## 요약 (3~5줄)

## A. 반드시 수정 (실행 오류, 제거된 패키지, 죽은 링크)
| # | 줄 | 내용 | 조치 |
|---|---|---|---|

## B. 권장 수정 (superseded/deprecated API, 구 도구 안내)
| # | 줄 | 현재 | 대체 | 동작 차이 |
|---|---|---|---|---|

## C. 교수법 개선 제안 (AI 시대)
- 압축 후보 절:
- 검증 활동으로 전환 가능한 예제:
- "AI와 함께" 절 삽입 위치와 주제:
- 데이터·예시 교체:

## D. 실행 로그 요약
(run_chunks.R 출력의 ERROR/경고 부분)

## E. 작업량 추정
- A: 약 n곳 / B: 약 n곳 / C: 신규 작성 약 n절
```

## 주의

- 발견 항목마다 **줄 번호**를 적는다. 줄 번호 없는 항목은 쓸모가 없다.
- `%>%` 처럼 수백 회 반복되는 항목은 개수만 세고 대표 줄 3개만 적는다.
- 동작이 바뀌는 대체(예: `sample_n` → `slice_sample` 의 인수명, `gather` → `pivot_longer` 의 열 순서)는 반드시 "동작 차이" 칸에 적는다.
- 판단이 어려운 교수법 항목은 제안으로 적고 결정은 사용자에게 남긴다.
