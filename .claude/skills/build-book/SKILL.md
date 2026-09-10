---
name: build-book
description: bookdown 강의노트를 렌더한다. 단일 장 미리보기(bookdown::preview_chapter) 또는 전체 책(bookdown::gitbook → docs/) 빌드를 실행하고 로그에서 오류를 추출해 보고한다. "렌더해줘", "빌드해줘", "HTML 확인", "배포 준비" 요청에 사용.
argument-hint: [chapter.Rmd]
---

# 렌더 (build-book)

## 명령

```bash
# 단일 장 (빠름, 1~3분). docs/ 의 해당 장 HTML 만 갱신
bash .claude/skills/build-book/scripts/render.sh 02-data-type.Rmd

# 전체 책 (느림, 10분 이상 가능). docs/ 전체 갱신
bash .claude/skills/build-book/scripts/render.sh
```

- 로그는 `upgrade/logs/render-<timestamp>.log` 에 남는다. 스크립트가 끝에 `Error`, `Quitting from lines`, `Execution halted` 줄을 추려 보여준다.
- 전체 빌드는 `run_in_background` 로 실행하고 완료 알림을 기다린다. 기다리는 동안 다른 작업을 해도 된다.
- 렌더 형식은 `bookdown::gitbook` 만 사용한다. PDF(`krantz.cls`)/EPUB 는 `_output.yml` 에서 주석 처리돼 있고 LaTeX 한글 환경 확인이 필요하므로 요청 없이 시도하지 않는다.

## 렌더 후 확인

1. 로그에 오류가 없는지. `Quitting from lines A-B (파일)` 이 있으면 해당 줄의 청크가 문제.
2. `git status --short docs/ | head` 로 어떤 HTML 이 바뀌었는지. 단일 장 렌더인데 다른 장 HTML 까지 바뀌었다면 `split_by: section` 때문에 번호가 밀린 것이니 전체 빌드가 필요하다.
3. 바뀐 HTML 을 `grep -c` 로 대략 확인하거나, 사용자가 로컬에서 `docs/index.html` 을 열어 보도록 안내한다.
4. `docs/` 변경은 본문 커밋과 **분리**한다. 사용자가 커밋을 요청할 때만 커밋한다.

## 주의

- `bookdown::clean_book(TRUE)` 는 `docs/` 를 지운다. 사용하지 않는다.
- `_bookdown_files/` 는 캐시. 그림이 갱신되지 않으면 해당 장의 `_bookdown_files/cnu-r-programming_files/figure-html/` 하위 파일을 지우고 다시 렌더.
- `index.Rmd` setup 청크가 `DT, citr, formatR, svglite` 설치를 시도한다. `citr` 은 CRAN 에 없어 경고가 난다 (오류는 아님). 감사 항목.
- 렌더 중 실시간 LLM API 호출 청크가 있으면 안 된다 (`ai-curriculum` 규칙).
