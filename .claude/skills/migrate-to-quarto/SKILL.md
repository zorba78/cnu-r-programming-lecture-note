---
name: migrate-to-quarto
description: bookdown(gitbook) 강의노트를 Quarto book 으로 전환하는 절차. 사용자가 전환을 결정한 뒤에만 사용한다. Rmd → qmd 변환(콜아웃, 상호참조, 청크 옵션), _quarto.yml 구성, 브랜치에서 장별 렌더 검증, docs/ 배포 유지.
argument-hint: [chapter.Rmd | all]
---

# bookdown → Quarto book 전환 (migrate-to-quarto)

**상태**: 2026-09-10 강사가 Quarto 전환을 결정했다. 이 절차를 따른다.

## 왜 전환하는가 (판단 근거, 사용자에게 제시)

- Quarto 1.9 CLI 가 이미 설치됨. bookdown 은 유지보수 모드.
- 학생이 배울 문서 도구가 Quarto 이므로 강의노트 자체가 예시가 된다 (재구성안 15장).
- 콜아웃·탭·상호참조·다국어(`lang: ko`)가 내장. `css/style.css` 의 block2 CSS 불필요.
- 비용: 13개 장 약 2.1만 줄 변환 + 상호참조 ID 정리 + `docs/` 전면 재생성 (URL 구조가 바뀌어 기존 외부 링크가 깨짐).

## 절차

### 0. 준비
```bash
git switch -c quarto-migration
quarto --version   # 1.9.38
```

**구 강의노트(bookdown) 보존 — Quarto 렌더 전에 반드시 먼저 한다.**
GitHub Pages는 `docs/`를 그대로 서빙하고, 아래 `_quarto.yml` 초안도 `output-dir: docs`로 잡혀 있다. 손대지 않으면 Quarto 렌더가 지금 살아있는 bookdown 사이트를 그대로 덮어써 옛 페이지가 전부 사라진다. `bookdown-archive-2026-09-10` 태그(Quarto 전환 착수 직전의 마지막 bookdown 커밋)에서 렌더된 `docs/`를 꺼내 `docs/legacy/`로 옮겨 두면, 전환 후에도 그 경로는 살아남아 옛 강의노트를 그대로 서빙한다.

```bash
git checkout bookdown-archive-2026-09-10 -- docs
mkdir -p docs-legacy-staging
cp -r docs/. docs-legacy-staging/legacy/
git checkout HEAD -- docs   # 작업 트리를 다시 현재 커밋의 docs/로 되돌림 (Quarto가 새로 채울 자리)
```

`docs-legacy-staging/legacy/`는 4단계(Quarto `render` 완료 후) 맨 마지막에 `docs/legacy/`로 합쳐 넣는다. 옛 사이트 안의 상대 링크(`css/style.css`, `images/` 등)는 `docs/legacy/` 밑에서도 그대로 닫힌 경로이므로 손댈 필요 없다. 허브 페이지에는 `.../legacy/`(또는 `.../legacy/index.html`) 링크 하나만 "이전 버전 강의노트 (~2026, bookdown)"로 걸어 둔다.

### 1. 프로젝트 파일
`_quarto.yml` 초안 (bookdown 설정을 옮김):

```yaml
project:
  type: book
  output-dir: docs
lang: ko
book:
  title: "통계 프로그래밍 언어"
  subtitle: "충남대학교 정보통계학과 R 프로그래밍 강의노트"
  author: "구본초"
  date: today
  repo-url: https://github.com/zorba78/cnu-r-programming-lecture-note
  repo-actions: [edit]
  chapters:
    - index.qmd
    - part: "통계프로그래밍언어"
      chapters:
        - 01-introduction.qmd
        - 02-data-type.qmd
        # ...
    - part: "통계패키지활용"
      chapters:
        - 09-file-import-export.qmd
        # ...
    - 15-references.qmd
bibliography: [book.bib, packages.bib]
format:
  html:
    theme: cosmo
    toc: true
    toc-depth: 3
    code-tools: true
    df-print: paged
    css: css/quarto-style.css
execute:
  freeze: auto
  warning: false
  message: false
knitr:
  opts_chunk:
    comment: NA
```

- `execute: freeze: auto` 로 장별 캐시. bookdown 의 `new_session: true` 와 같은 효과.
- `08-introduction-2nd.Rmd` 의 `# (PART)` 는 `_quarto.yml` 의 `part:` 로 옮긴다. `index.Rmd` 의 YAML 은 `_quarto.yml` 로 흡수.

### 2. 장 변환 (한 장씩)
```bash
Rscript .claude/skills/migrate-to-quarto/scripts/rmd2qmd.R 02-data-type.Rmd   # → 02-data-type.qmd 생성, 원본 유지
quarto render 02-data-type.qmd
```

스크립트가 자동 처리하는 것:

| bookdown | Quarto |
|---|---|
| ```` ```{block2, type="rmdnote"} ```` … ```` ``` ```` | `::: {.callout-note}` … `:::` (tip/important/caution/warning 동일 매핑) |
| `\@ref(fig:label)` | `@fig-label` |
| `\@ref(tab:label)` | `@tbl-label` |
| `\@ref(section-id)` | `@sec-section-id` |
| 헤딩 `{#id}` | `{#sec-id}` (Quarto 절 참조는 `sec-` 접두 필요) |
| `fig.cap=` 이 있는 청크의 레이블 `foo` | `fig-foo` (레이블에 `_` 가 있으면 `-` 로) |
| 장 앞 `output: html_document` YAML | 제거 |
| `# (PART) ... {-}` | 제거 (yml 로 이동) |

수동 확인이 필요한 것:
- 청크 옵션은 knitr 식 `{r label, echo=FALSE}` 그대로 두어도 Quarto 가 읽는다. 새 코드는 `#| ` 로 쓴다.
- `linewidth` hook 등 setup 청크의 knitr hook 은 그대로 동작하지만, 공통 파일 `_common.R` 로 빼고 `_quarto.yml` 에 `knitr: opts_knit` 또는 각 장 첫 청크에서 `source("_common.R")`.
- `kableExtra` 표는 대부분 동작. `DT`, `plotly` 는 `html` 에서 정상.
- `{-}` / `.unnumbered` → `{.unnumbered}`.
- 수식 `$$` 는 그대로. `\mathrm{\mathbf{X}}` 도 그대로.
- 외부 헤딩 ID 변경으로 기존 URL 이 깨짐 → 개별 리다이렉트는 만들지 않는다. 대신 0단계에서 보존한 `docs/legacy/`가 옛 사이트 전체를 그대로 서빙하므로, 새 책 쪽에는 "이전 버전은 여기" 링크 하나만 눈에 띄게 둔다(허브 페이지, `index.qmd` 서문 모두).

### 3. 검증
- 장별 `quarto render <장>.qmd` 후 경고(`WARNING: Unable to resolve crossref`) 없는지.
- `check-chapter` 스크립트는 `.qmd` 에도 동작한다 (청크 fence 동일).
- 전체: `quarto render` → `docs/` 갱신. 옛 `docs/*.html` 은 지워지므로 커밋 전 diff 크기를 사용자에게 보고.

### 4. 마무리
- **`docs-legacy-staging/legacy/`를 `docs/legacy/`로 합쳐 넣는다** (`quarto render` 직후, 이 순서를 지켜야 Quarto가 만든 `docs/`를 옛 사본이 덮어쓰지 않는다):
  ```bash
  mkdir -p docs/legacy
  cp -r docs-legacy-staging/legacy/. docs/legacy/
  rm -rf docs-legacy-staging
  git add docs/legacy
  ```
  렌더 후 `docs/legacy/index.html`이 열리는지, `docs/legacy/css/style.css` 등 상대경로 자원이 함께 살아있는지 확인한다.
- `_bookdown.yml`, `_output.yml`, `_render.R`, `krantz.cls`, `latex/` (bookdown 소스 설정)는 삭제하지 않고 `bookdown-legacy/`로 이동한다 (렌더된 `docs/legacy/`와는 다른 폴더 — 하나는 소스, 하나는 산출물).
- `CLAUDE.md` 툴체인·빌드 명령 절을 Quarto 기준으로 갱신. `build-book` 스킬의 명령도 갱신.
- README 갱신. "이전 버전 강의노트(~2026, bookdown): `docs/legacy/`" 한 줄 추가.
