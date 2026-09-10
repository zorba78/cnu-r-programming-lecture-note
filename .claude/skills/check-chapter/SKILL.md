---
name: check-chapter
description: 강의노트 한 장(.Rmd)의 R 코드 청크를 순서대로 실제 실행해 오류 청크, 예상된 오류(error=TRUE), 건너뛴 청크(eval=FALSE), deprecation 경고를 표로 보고한다. 렌더보다 빠른 검증. Rmd 코드 청크를 수정한 뒤, 또는 "코드 돌아가는지 확인해줘" 요청에 사용.
argument-hint: <chapter.Rmd> [--from=N --to=N --timeout=60 --verbose]
---

# 청크 실행 검증 (check-chapter)

## 실행

```bash
Rscript .claude/skills/check-chapter/scripts/run_chunks.R 02-data-type.Rmd
Rscript .claude/skills/check-chapter/scripts/run_chunks.R 07-simulation.Rmd --timeout=120
Rscript .claude/skills/check-chapter/scripts/run_chunks.R 10-data-manupulation.Rmd --from=40 --to=60 --verbose
```

- 프로젝트 루트에서 실행한다 (데이터 경로가 `dataset/...` 상대경로).
- 스크립트는 ```` ```{r ...} ```` 청크만 순서대로 전역 환경에서 평가한다. `block2`, `bash` 등 다른 엔진은 무시.
- `eval=FALSE` → SKIP, `error=TRUE` → 오류가 나야 정상(EXPECTED-ERROR), 그 외 오류 → ERROR.
- 청크당 제한 시간 기본 60초. 시뮬레이션 장(07)은 늘려서 실행.
- `--from/--to` 로 일부만 실행할 수 있지만 앞 청크가 만든 객체가 없어 오류가 날 수 있다. 보고서에 그 점을 적는다.
- 종료 코드 1 = ERROR 가 1개 이상.
- 그래픽 출력은 버린다 (`pdf(NULL)`). `Rplots.pdf` 가 생기면 삭제.

## 결과 해석과 보고

1. **ERROR** 청크: 줄 번호, 레이블, 오류 메시지를 그대로 보고한다. 원인을 추정하되 "고쳤다"고 하지 않는다 (수정은 별도 요청).
2. **경고 중 deprecation** (`deprecated`, `superseded`, `defunct`): 청크 줄 번호와 함께 보고. `audit-chapter` 의 B 항목 근거가 된다.
3. **SKIP** 이 많은 장: `eval=FALSE` 청크는 렌더에서도 실행되지 않으므로 코드가 실제로 맞는지 별도 확인이 필요하다고 적는다.
4. **EXPECTED-ERROR 인데 오류가 안 난 청크**: R 동작이 바뀌어 더 이상 오류가 아닌 경우다. 본문 설명을 고쳐야 하므로 반드시 보고한다.
5. 렌더까지 확인해야 하면 (`fig.cap`, 상호참조, kable 출력 등) `build-book` 스킬의 단일 장 렌더를 이어서 실행한다.

## 한계

- knitr 청크 옵션 중 `eval=` 에 표현식이 들어간 경우 SKIP 처리.
- 청크 헤더 안에 `}` 가 있는 옵션(예: `fig.cap=paste0(...)`)은 정상 인식하지만, 중첩 중괄호 `{}` 는 오인할 수 있다.
- 인라인 R 코드(`` `r ...` ``)는 실행하지 않는다. 본문 수치 인용은 렌더로 확인.
- `readline()` 등 대화형 입력은 비대화형이라 빈 문자열을 반환한다.

## 부작용 주의

- 일부 장(09, 07)은 `output/` 에 파일을 쓴다. `output/*.Rdata`, `output/pulse.rds` 는 git 에 추적되므로 실행 후 `git status --short output/` 를 확인하고 변경됐으면 `git checkout -- output/` 로 되돌린다.
- 실행 후 작업 트리에 새 파일이 생겼는지 `git status --short` 로 확인해 보고에 포함한다.
