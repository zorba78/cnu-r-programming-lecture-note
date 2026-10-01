---
name: chapter-orchestrator
description: 개편 장 하나(강의노트 .qmd + 슬라이드 -slides.qmd + 허브 등록)를 워커 에이전트에 나눠 맡기고 관문마다 결과를 검증하는 오케스트레이터 절차. 오케스트레이터는 Fable 5.1 medium, 워커는 Opus 5.5 xhigh(.claude/agents/ 정의)가 기본이다. "13장 만들어줘", "새 장 노트와 슬라이드 생성", "장 개편 파이프라인 돌려줘", "오케스트레이터로 진행" 요청에 사용.
argument-hint: <새 장 번호> <장 키> [출처 현행 장 파일] 예) 13 data-visualization 11-data-visualization.Rmd
---

# 장 생성 오케스트레이터 (chapter-orchestrator)

개편 장 하나를 **설계 → 자료 → 노트 → 검수 → AI 절 → 슬라이드 → 허브 → 기록** 순서로 만든다. 8, 9, 11, 12장을 한 세션이 직접 쓰면서 겪은 절차를 역할별 워커로 나눈 것이다. 이 문서는 **오케스트레이터(메인 세션)가 따르는 지시**다. 워커의 지시는 `.claude/agents/lecture-*.md` 와 `.claude/agents/student-ai.md` 에 있다.

## 0. 모델과 역할

| 역할 | 모델 | effort | 정의 위치 | 하는 일 |
|---|---|---|---|---|
| 오케스트레이터 | Claude Fable 5.1 | medium | 메인 세션 (`/model fable`, `/effort medium`) | 단계 나누기, 워커 호출, 관문 검증, 강사 결정 사항 수집, 최종 보고 |
| `lecture-auditor` | Claude Opus 5.5 | xhigh | `.claude/agents/lecture-auditor.md` | 출처 현행 장 감사 보고서 (`audit-chapter` 스킬) |
| `lecture-planner` | Claude Opus 5.5 | xhigh | `.claude/agents/lecture-planner.md` | 장 설계서: 절 구조, 이전 판 예제·그림 재사용 대응표, 새 자료 명세, AI 절 과제, 슬라이드 분량 |
| `lecture-note-writer` | Claude Opus 5.5 | xhigh | `.claude/agents/lecture-note-writer.md` | 연습 자료 생성, `<장>.qmd` 집필, 렌더 자체 검증 |
| `lecture-slides-writer` | Claude Opus 5.5 | xhigh | `.claude/agents/lecture-slides-writer.md` | `<장>-slides.qmd` 집필, `slides-check.R` 로 배치 검사와 수정 |
| `lecture-reviewer` | Claude Opus 5.5 | xhigh | `.claude/agents/lecture-reviewer.md` | 독립 검수. 고치지 않고 발견 목록만 돌려준다 |
| `student-ai` | Claude Sonnet 5.5 | 기본 | `.claude/agents/student-ai.md` | "AI와 함께" 절에 실을 AI 응답을 실제로 생성한다. 도구 없이 한 번에 답한다 |

- 워커의 모델과 effort 는 에이전트 정의가 고정한다. 오케스트레이터는 `Agent` 호출에 `subagent_type` 만 주고 `model` 을 덮지 않는다. 특정 단계를 더 싼 모델로 돌리라는 지시가 있을 때만 `model` 을 덮고, 그 사실을 최종 보고에 적는다.
- 오케스트레이터의 모델과 effort 는 스킬이 바꿀 수 없다. 세션 시작 때 사용자가 `/model fable`, `/effort medium` 으로 맞춘다. 다르게 설정된 채 시작했으면 첫 보고에 그 사실을 한 줄 적고 진행한다.
- `student-ai` 만 Sonnet 인 이유: 학생이 일반 AI 채팅 도우미에게서 받을 법한 응답을 재현하는 역할이라 가장 강한 모델이 필요하지 않고, 응답을 고르거나 다듬지 않는 것이 기록 규칙(`ai-curriculum` 3절)이기 때문이다.

## 1. 오케스트레이터 행동 규칙

1. **직접 집필하지 않는다.** 노트, 슬라이드, 자료 생성 스크립트, 감사 보고서는 모두 워커가 쓴다. 오케스트레이터가 직접 고치는 것은 CLAUDE.md 진행 상태 표, `hub/topic-page.R` 의 `chapters` 한 줄, `hub/index.html` 의 상태 배지, 재구성안의 해당 행뿐이다.
2. **컨텍스트를 아낀다.** 원고 전체를 읽지 않는다. 구조는 `grep -n "^## \|^### "`, 분량은 `wc -l`, 렌더 결과는 로그의 마지막 30줄과 `metrics.tsv` 로 본다. 워커에게는 **보고를 40줄 이내**로, 산출물은 파일로 남기라고 지시한다.
3. **관문(gate)은 오케스트레이터가 직접 명령을 실행해 확인한다.** 워커가 "렌더 성공"이라고 보고해도 2절의 관문 명령을 다시 돌려 종료 코드와 핵심 수치를 본다. 증거 없는 "완료"는 반려한다.
4. **수정 루프는 단계마다 최대 2회.** 검수 발견을 집필 워커에게 돌려보내 고치게 하고, 두 번째에도 남은 항목은 고치지 않고 `upgrade/plans/<장 키>-decisions.md` 와 최종 보고의 "미해결" 에 적는다.
5. **강사 결정이 필요한 것은 모아 두고 멈추지 않는다.** 절 분배, 예제 교체, 새 패키지 도입처럼 강사 판단이 필요한 항목은 가정을 정해 진행하고, 가정과 대안을 `upgrade/plans/<장 키>-decisions.md` 에 적는다. 다음 중 하나면 진행을 멈추고 묻는다: 공개 URL 앵커(기존 `{#id}`) 변경, 큰 바이너리 추가, 개인정보로 보이는 자료 사용, `docs/` 루트(현행 사이트) 수정.
6. **워커를 병렬로 돌릴 수 있는 곳은 두 군데뿐이다.** 감사와 설계 준비(0단계의 예제 목록화)는 서로 독립이라 함께 보낸다. 노트 검수와 슬라이드 집필은 노트 렌더가 통과한 뒤 함께 보낸다. 같은 파일을 두 워커가 동시에 고치게 하지 않는다.
7. **한 워커 호출은 한 단계만** 맡긴다. 노트 집필처럼 긴 단계는 절 묶음으로 쪼개 순서대로 호출하되, 뒤 호출에는 앞 호출의 보고와 현재 파일 구조(`grep` 결과)를 넘긴다. 같은 워커를 이어서 부를 때는 `SendMessage` 로 같은 에이전트에 보내 맥락을 유지한다.
8. **화면에 나가는 문구는 모두 한국어**다. 진행 안내, 명령 설명, 워커에게 주는 프롬프트, 최종 보고 모두 해당한다.
9. **커밋은 하지 않는다.** 마지막 보고에 변경 파일 목록과 권장 커밋 묶음(원고 / `docs/` 렌더본)만 적는다.
10. 작업 규칙 11(멋 부린 표현 금지), 슬라이드 규칙(개조식, 줄표와 가운뎃점 금지, 채움 70~85%), LLM 기록 규칙(지어내지 않기)은 워커 정의에 들어 있다. 오케스트레이터는 검수 단계에서 이 규칙 위반을 **반려 사유**로 다룬다.

## 2. 입력과 산출물

인수: `<새 장 번호> <장 키> [출처 현행 장 파일]`. 출처를 생략하면 `upgrade/curriculum-plan.md` 5절 표의 "출처" 열에서 찾는다(예: 새 13장 → 현행 11장 `11-data-visualization.Rmd`).

| 산출물 | 경로 | 만드는 워커 |
|---|---|---|
| 감사 보고서 | `upgrade/audit/<출처 장 파일명>.md` | `lecture-auditor` (이미 있으면 생략) |
| 설계서 | `upgrade/plans/<장 키>.md` | `lecture-planner` |
| 결정 사항·가정 | `upgrade/plans/<장 키>-decisions.md` | 오케스트레이터가 만들고 모든 워커가 덧붙인다 |
| 진행 상태 | `upgrade/plans/<장 키>-status.md` | 오케스트레이터 |
| 연습 자료 | `dataset/ch<번호>/` + `dataset/ch<번호>/make-ch<번호>-data.R` | `lecture-note-writer` |
| 강의노트 | `<번호>-<장 키>.qmd` | `lecture-note-writer` |
| AI 응답 원문 | `ai-transcripts/<번호>-<장 키>/<slug>.md` | `student-ai` 의 응답을 `lecture-note-writer` 가 기록 |
| 슬라이드 | `<번호>-<장 키>-slides.qmd` | `lecture-slides-writer` |
| 렌더본 | `docs/preview/<번호>-<장 키>.html`, `...-slides.html` | `upgrade/render-preview.sh` |
| 배치 측정 | `upgrade/logs/slides-check-<번호>-<장 키>/metrics.tsv` | `lecture-slides-writer`, 오케스트레이터가 재실행 |
| 허브 | `hub/topic-page.R` 의 `chapters`, `hub/index.html`, `docs/hub/` | 오케스트레이터 |

`upgrade/plans/` 가 없으면 만든다. 상태 파일은 아래 단계 번호를 체크 목록으로 적어 두고, 세션이 끊겨 다시 시작할 때 산출물 존재 여부와 함께 읽어 **끝난 단계를 건너뛴다.**

## 3. 단계와 관문

각 단계는 "워커 → 산출물 → 관문 명령 → 통과 기준" 순서다. 관문을 통과하지 못하면 같은 워커에 발견 목록을 보내 고치게 한다(규칙 4).

### 0단계. 준비 (오케스트레이터)

1. 읽는다: CLAUDE.md 의 "업그레이드 프로젝트" 와 "진행 상태" 표, `upgrade/curriculum-plan.md` 5·6절의 해당 행, 메모리의 `feedback-reuse-old-examples`.
2. 출처 현행 장의 구조와 자원을 목록으로 뽑아 둔다(워커에게 넘길 입력이다).
   ```bash
   grep -n "^# \|^## \|^### " <출처>.Rmd
   grep -on "figures/[^)\"']*\|images/[^)\"']*\|video/[^)\"']*\|dataset/[^)\"']*" <출처>.Rmd | sort -u
   ```
3. `upgrade/plans/<장 키>-status.md` 와 `-decisions.md` 를 만든다. 이미 있으면 읽고 이어서 한다.
4. 바로 앞에 끝난 장(지금은 12장)의 `.qmd` 와 `-slides.qmd` 의 **YAML 머리와 setup 청크**만 뽑아 워커에게 "이 틀을 복사하라"고 넘긴다. 워커가 YAML 을 새로 짜다가 `comment: NA`, `error: false` 같은 함정(CLAUDE.md "시범 전환에서 걸린 것")에 다시 걸리지 않게 하기 위해서다.

### 1단계. 감사 (`lecture-auditor`, 보고서가 없을 때만)

- 입력: 출처 장 파일, `audit-chapter` 스킬.
- 산출물: `upgrade/audit/<출처>.md`.
- 관문: 보고서에 A(치명)·B(중요)·C(경미) 항목 수와 "새 장 재구성 제안" 절이 있는지 `grep -c` 로 본다. 치명 항목은 설계서에 "이전 판 노트의 코드" 로 밝혀 예측·버그 찾기 문항에 쓸 후보가 된다.

### 2단계. 설계 (`lecture-planner`)

- 입력: 0단계 목록, 감사 보고서, 재구성안 해당 행과 6절 공통 구조, `ai-curriculum` 스킬, 앞 장(12장)의 절 목록(`grep` 결과)을 분량 기준으로.
- 산출물: `upgrade/plans/<장 키>.md`. 반드시 들어가야 할 것:
  1. 학습 목표(명세·검증·해석 동사로).
  2. 절(`##`)과 소절(`###`) 목록과 각 소절의 PRIMM 질문 한 줄. 모든 절에 소절이 있어야 한다.
  3. **이전 판 재사용 대응표**: 현행 장의 예제 자료, 그림, 설명 중 살릴 것 → 새 절. 살리지 않는 것은 이유.
  4. 새 연습 자료 명세(필요할 때만): 파일, 열, 행 수, 심어 둘 함정(결측 표기, 중복 키, 인코딩 등)과 그 함정이 가르치는 것.
  5. "AI와 함께" 절의 과제 명세와 학생 프롬프트 초안.
  6. 슬라이드 계획: 절별 장수 목표(총 50~70장), 노트 그림 중 슬라이드에 실을 것.
  7. 강사 확인 항목(`-decisions.md` 로 옮긴다).
- 관문(오케스트레이터가 읽고 판단): 재구성안의 "처리" 열과 맞는가, 재사용 대응표가 비어 있지 않은가, 공개 앵커를 바꾸는 계획이 없는가. 어긋나면 사유를 적어 되돌린다.

### 3단계. 자료와 노트 집필 (`lecture-note-writer`)

- 3a. 연습 자료: 설계서의 자료 명세대로 `dataset/ch<번호>/make-ch<번호>-data.R` 을 쓰고 실행해 파일을 만든다. 관문: 스크립트를 오케스트레이터가 다시 실행해 같은 파일이 나오는지(`md5sum`) 본다. 시드가 고정돼야 한다.
- 3b. 노트 본문: 설계서의 절 순서대로 쓴다. 절이 많으면 **절 2~3개씩** 나눠 호출하고, 각 호출 끝에 워커가 `quarto render <장>.qmd` 를 돌려 통과시킨 뒤 보고하게 한다. AI 절은 4단계에서 쓰므로 자리만 남긴다.
- 관문(오케스트레이터):
  ```bash
  bash upgrade/render-preview.sh <번호>-<장 키>.qmd 2>&1 | tail -30
  grep -n "^## \|^### " <번호>-<장 키>.qmd            # 소절 없는 절이 없는지
  grep -n "{#" <번호>-<장 키>.qmd | grep -v "{#sec-"  # 영문 kebab-case ID 규칙
  grep -nE "^\s*\([a-z]\)" <번호>-<장 키>.qmd         # 알파벳 번호 목록으로 바뀌는 줄
  ```
  통과 기준: 렌더 종료 코드 0, 로그에 `Error`·`Warning: ... deprecated` 없음, 모든 `##` 아래 `###` 존재, 렌더본이 `docs/preview/` 에 생김.

### 4단계. AI 절 (`student-ai` → `lecture-note-writer`)

1. 오케스트레이터가 설계서의 학생 프롬프트를 **그대로** `student-ai` 에 보낸다. 지시문은 `student-ai` 정의에 있다(도구 없이 한 번에 답하기). 한 번만 보내고 응답을 고르지 않는다.
2. 응답 전문과 프롬프트 전문, 모델명, 날짜를 `ai-transcripts/<번호>-<장 키>/<slug>.md` 에 저장하도록 `lecture-note-writer` 에 넘긴다. 머리 형식은 `ai-transcripts/12-data-handling/sido-loans-per-capita.md` 를 따른다.
3. `lecture-note-writer` 가 응답의 코드를 실제로 실행해 보고, 맞는 부분과 틀린 부분을 검증 코드로 보인 뒤 "AI 가 보지 못한 부분" 과 "연습" 소절을 쓴다. 생성 코드 청크 첫 줄은 `# 생성: <모델명>, <날짜>`, 실행 청크는 `eval: false`.
- 관문: 3단계 관문 명령 재실행 + `grep -n "# 생성:" <장>.qmd` 로 모델명·날짜가 있는지, `ls ai-transcripts/<번호>-<장 키>/` 로 원문 파일이 있는지 본다. 응답을 얻지 못했으면 그 절을 "직접 실행해 보자" 형태로 바꾸게 하고 결정 파일에 적는다.

### 5단계. 노트 검수 (`lecture-reviewer`)와 슬라이드 집필 (`lecture-slides-writer`), 병렬

- `lecture-reviewer` 입력: 노트 파일, 설계서, 렌더본 경로. 산출물: `upgrade/plans/<장 키>-review-note.md` (발견마다 줄 번호, 심각도, 근거, 제안). 검수 항목은 워커 정의에 있다(수치 인용과 실제 출력 대조, 작업 규칙 11, 외부 링크 접근, 콜아웃 종류, PRIMM 순서, 재사용 대응표 이행 여부).
- `lecture-slides-writer` 입력: 노트 파일, 설계서의 슬라이드 계획, 12장 슬라이드 YAML 머리. 산출물: `<번호>-<장 키>-slides.qmd`, 렌더본, `upgrade/logs/slides-check-<번호>-<장 키>/metrics.tsv`.
- 노트 관문: 검수 발견 중 치명·중요 항목을 `lecture-note-writer` 에 보내 고치게 하고(최대 2회), 3단계 관문을 재실행한다. 노트의 절 번호가 바뀌면 슬라이드 `{.secno}` 도 바뀌어야 하므로 **노트 수정이 끝난 뒤** 슬라이드 워커에 절 목록을 다시 넘긴다.
- 슬라이드 관문(오케스트레이터가 직접 실행):
  ```bash
  bash upgrade/render-preview.sh <번호>-<장 키>-slides.qmd 2>&1 | tail -20
  Rscript upgrade/slides-check.R docs/preview/<번호>-<장 키>-slides.html upgrade/logs/slides-check-<번호>-<장 키>
  awk -F'\t' 'NR>1 && (($2=="content" && $4>680) || $5>1280 || $6>0 || $7>0 || $8<15)' upgrade/logs/slides-check-<번호>-<장 키>/metrics.tsv
  ```
  `metrics.tsv` 열은 `n kind title bottom right scroll vscroll minfont small` 순서다. 통과 기준: 마지막 명령의 출력이 비어 있다(`slides-check.R` 자체도 기준을 넘는 슬라이드 표를 출력하므로 둘 다 본다). 총 장수 50~70, 채움 60% 미만 슬라이드 목록이 보고에 있고 각각 합치거나 채운 사유가 있다. `::: {.notes}` 가 모든 본문 슬라이드에 있다(`grep -c "{.notes}"` 가 `##` 수와 비슷해야 한다). 줄표·가운뎃점 검사: `grep -n "—\|·" <장>-slides.qmd` 가 비어 있다(수 범위 `–` 는 허용).
- 슬라이드 검수: 노트 검수가 끝난 `lecture-reviewer` 에 `SendMessage` 로 슬라이드 검수를 이어서 맡긴다(개조식, 노트 그림 수록 여부, 예측 슬라이드에 대상 코드 포함, 대본 `~습니다` 체, 과장 표현). 산출물 `upgrade/plans/<장 키>-review-slides.md`. 발견은 슬라이드 워커에 돌려 고치게 하고 관문을 재실행한다.

### 6단계. 허브 등록 (오케스트레이터)

1. `hub/topic-page.R` 의 `chapters` 목록에 한 줄 추가한다(`num`, `part`, `anchor = "ch<번호>"`, `status = "개편 초안"`). 12장 줄을 복사해 고친다.
2. `hub/index.html` 에서 해당 장 행(`id="ch<번호>"`)의 노트 링크를 `../preview/<번호>-<장 키>.html` 과 `badge-draft-note`(초안 렌더)로, 슬라이드 링크를 `../preview/<번호>-<장 키>-slides.html` 과 `badge-open`(공개)로 바꾸고, 주제 상세 링크 `<p class="panel-link">` 를 넣는다. `panel-plan` 문단은 **학생이 읽는 장 소개** 두세 문장으로 설계서의 학습 목표에서 쓴다("현행 N장을 재구성한다" 같은 개편 기록은 쓰지 않는다). `legend-foot` 의 "슬라이드 N개 공개" 수를 올린다.
3. 다시 렌더해 주제 상세를 만들고 배포 위치로 복사한다. `render-preview.sh` 가 `topic-page.R` 과 `sync.sh` 를 부른다.
   ```bash
   bash upgrade/render-preview.sh <번호>-<장 키>-slides.qmd
   ls docs/hub/ && grep -c "preview/<번호>-<장 키>" docs/hub/index.html
   ```
   통과 기준: `docs/hub/<번호>-<장 키>.html` 이 생기고, `docs/hub/index.html` 의 상대 경로가 `docs/` 안 파일로 해석된다.

### 7단계. 기록 (오케스트레이터)

1. CLAUDE.md "진행 상태" 표에 새 장 행을 넣고(기존 행 형식대로 날짜, 파일, 감사 보고서, AI 원문 폴더, 학생 환경 주의 사항), 저장소 구조 표에 `.qmd` 한 줄을 넣는다. 이 세션에서 새로 걸린 Quarto·슬라이드 문제는 "슬라이드에서 걸린 것" 목록 끝에 번호를 이어 적는다.
2. `upgrade/curriculum-plan.md` 5절의 해당 행 끝에 `초안 <파일> (<날짜>)` 를 덧붙인다.
3. `upgrade/plans/<장 키>-status.md` 를 모두 체크하고, `-decisions.md` 를 최종 보고에 그대로 붙인다.
4. `git status --short` 로 변경 파일을 분류한다: 원고·스크립트·자료 / `docs/` 렌더본과 허브 / 의도치 않은 변경(`output/`, `dataset/pulse.feather`, `Rplots.pdf` 등은 되돌린다).

## 4. 워커 호출 프롬프트 뼈대

워커 정의가 역할 규칙을 갖고 있으므로, 호출 프롬프트에는 **이번 장의 사실**만 넣는다. 다음 머리를 모든 호출에 붙인다.

```
[장] 새 <번호>장 <제목> (장 키 <장 키>). 출처: 현행 <출처 파일>.
[읽을 것] upgrade/plans/<장 키>.md (설계서), upgrade/plans/<장 키>-decisions.md,
          upgrade/audit/<출처>.md, 이번 단계에 필요한 스킬 파일 경로.
[이번 단계] <단계 번호와 이름>. 맡는 범위: <절 번호 또는 파일>.
[틀] YAML 과 setup 청크는 <앞 장 파일> 의 것을 복사해 장 번호·제목만 바꾼다.
[보고 형식] 40줄 이내. (1) 만든/고친 파일과 줄 수, (2) 실행한 검증 명령과 결과 요약(종료 코드, 핵심 수치),
          (3) 설계서와 달리한 것과 이유, (4) 강사 확인이 필요한 것(-decisions.md 에도 덧붙일 것),
          (5) 다음 단계에 넘길 주의 사항. 파일 내용을 보고에 붙여 넣지 않는다.
```

단계별 덧붙임:

- 집필 (3b): 맡는 절 목록과 각 절의 PRIMM 질문(설계서에서 복사), 앞 호출이 만든 객체 이름(`setup` 과 앞 절에서 정의한 데이터 이름), 끝낼 때 `quarto render` 통과를 요구.
- AI 절 (4): 저장할 원문 파일 경로, 응답 전문(오케스트레이터가 `student-ai` 보고에서 그대로 옮긴다), 모델명 "Claude Sonnet 5.5", 날짜.
- 검수 (5): "고치지 말고 보고만", 발견마다 `파일:줄` 과 근거(실행 출력 또는 규칙 번호), 심각도 세 단계.
- 슬라이드 (5): 노트의 `##`/`###` 목록과 ID, 설계서의 슬라이드 계획, 노트 그림 파일 목록, 12장 슬라이드 YAML 머리의 경로.

## 5. 최종 보고 형식

마지막 메시지는 다음 순서로 쓴다. 보고를 읽는 사람은 작업 과정을 보지 않았다고 가정한다.

1. 결과 한 줄: 무엇이 어디에 생겼고 어떤 관문을 통과했는지(렌더 종료 코드, 슬라이드 장수, 배치 검사 결과).
2. 만든 파일 표(경로, 줄 수 또는 장수).
3. 강사 확인 항목(`-decisions.md` 전문).
4. 미해결 항목(수정 루프 2회 뒤 남은 것)과 그 위치.
5. 권장 커밋 묶음 두 개(원고 / `docs/` 렌더본)와 다음 명령.

## 6. 흔한 실패와 대응

- 워커가 YAML 을 새로 짜서 `comment: NA`, `error` 누락, `.smaller` 사용 같은 알려진 함정에 걸린다 → 0단계 4번의 틀 복사를 프롬프트에 명시했는지 확인하고, 틀을 그대로 쓰라고 되돌린다.
- 노트 집필 워커가 새 가상 자료로만 쓴다 → 설계서의 재사용 대응표 이행 여부가 검수 항목이다. 대응표의 "살릴 것" 중 빠진 항목은 치명으로 분류해 되돌린다(2026-09-17 12장 사례).
- 슬라이드 그림이 바로 이동할 때 사라진다(`r-stretch`) → 청크를 `::: {}` 로 감싸라고 지시한다. CLAUDE.md "슬라이드에서 걸린 것" 14번.
- `student-ai` 가 되묻거나 도구를 쓰려 한다 → 응답을 버리고 같은 프롬프트를 한 번 더 보낸다. 두 번째도 실패하면 그 절을 "직접 실행해 보자" 로 바꾼다. 응답을 손보지 않는다.
- 렌더 중 `dataset/pulse.feather`, `output/*.Rdata` 가 바뀐다 → `git checkout -- <파일>` 로 되돌리고 보고에 적는다.
- 세션이 끊겼다 → `upgrade/plans/<장 키>-status.md` 와 산출물 존재 여부로 끝난 단계를 판단하고 이어서 한다. 워커 맥락은 사라지므로 새 호출에는 앞 단계 보고 요약을 다시 넣는다.
