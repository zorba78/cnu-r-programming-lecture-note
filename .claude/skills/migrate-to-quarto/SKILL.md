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
- 외부 헤딩 ID 변경으로 기존 URL 이 깨짐 → `docs/` 에 옛 경로 리다이렉트 필요 여부 결정.

### 3. 검증
- 장별 `quarto render <장>.qmd` 후 경고(`WARNING: Unable to resolve crossref`) 없는지.
- `check-chapter` 스크립트는 `.qmd` 에도 동작한다 (청크 fence 동일).
- 전체: `quarto render` → `docs/` 갱신. 옛 `docs/*.html` 은 지워지므로 커밋 전 diff 크기를 사용자에게 보고.

### 4. 마무리
- `_bookdown.yml`, `_output.yml`, `_render.R`, `krantz.cls`, `latex/` 는 `legacy/` 로 이동 (삭제는 사용자 결정).
- `CLAUDE.md` 툴체인·빌드 명령 절을 Quarto 기준으로 갱신. `build-book` 스킬의 명령도 갱신.
- README 갱신.
