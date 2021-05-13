--- 
title: "통계 프로그래밍 언어"
subtitle: "2021년도 1학기 충남대학교 정보통계학과 강의노트"
author: "한국한의학연구원, 구본초"
date: "2021-05-13"
knit: "bookdown::render_book"
documentclass: krantz
bibliography: [book.bib, packages.bib]
biblio-style: apalike
link-citations: yes
colorlinks: yes
graphics: yes
lot: yes
lof: yes
fontsize: 11pt
description: "2021년도 1학기 정보통계학과 통계 프로그래밍 언어 강의 노트로 해당 노트: https://zorba78.github.io/cnu-r-programming-lecture-note/"
site: bookdown::bookdown_site
github-repo: zorba78/cnu-r-programming-lecture-note
editor_options: 
  chunk_output_type: console
---




# Course Overview{-#overview}

\BeginKnitrBlock{rmdnote}<div class="rmdnote">
- 본 문서는 2021년도 1학기 충남대학교 정보통계학과에서 개설한 "통계 프로그래밍 언어" 강의를 위해 개발한 강의 노트임 
- 주 단위로 업데이트 될 예정 
- https://zorba78.github.io/cnu-r-programming-lecture-note/ 에서 확인
- pdf 파일 다운로드가 가능하지만 권장하지는 않음.
- **Google Chrome** 또는 **Firefox** 브라우저 사용 권장
- **온라인 상태 유지 필수**


본 문서는 Yihui Xie가 개발한 **bookdown** 패키지 [@xie-2016]를 활용하여 생성한 문서임. 충남대학교 정보통계학과 이상인 교수님의 2019년도 2학기 "통계패키지활용" 
강의 자료 내용과 구성을 참고하여 작성함. 

</div>\EndKnitrBlock{rmdnote}


#### 강의소개{#intro-lec .unnumbered}

R은 뉴질랜드 오클랜드 대학의 Robert Gentleman 과 Ross Ihaka 가 AT&T 벨 연구소에서 개발한 S 언어를 기반으로 개발한 GNU 환경의 통계 계산 및 프로그래밍 언어이다. 현재 R 소프트웨어는 통계학 뿐 아니라 데이터 과학을 포함한 의학, 생물학 등 다양한 분야에서 활용되고 있으며 특히 통계 소프트웨어 개발과 데이터 분석에 많이 활용되고 있다. 본 강의는 데이터 분석을 위한 R의 기초 문법과 통계학 입문에서 학습한 몇 가지 중요한 통계적 이론에 대한 시뮬레이션 방법을 다룬다. 아울러 R package를 활용한 데이터 헨들링 및 시각화 그리고 Rmarkdown을 활용한 재현가능(reproducible)한 문서 작성법에 대해 학습하고자 한다. 


#### 교과 목표{#purpose-course .unnumbered}

> - **R 기초 문법 습득**
> - **R 프로그래밍 능력 향상**
> - **R 시뮬레이션을 통한 통계학 기초 이론 확인**
> - **R markdown을 이용한 재현가능(reproducible)한 보고서 작성 방법 이해**


#### 선수과목{#pre-course .unnumbered}

> **통계학 개론**, **통계수학 1**/**통계수학 2** (필수는 아님)


#### 수업 방법{#course-method .unnumbered}

- **강의: 40 %**
- **실험/실습: 60%**


#### 평가방법{#grade-method .unnumbered}

> - **기말고사: 70 %**
> - **출석: 10 %**
> - **과제: 10 %**
> - **퀴즈: 10 %**


#### 교재 및 참고문헌{#material-course .unnumbered}

> 별도의 교재 없이 본 강의 노트로 수업을 진행할 예정이며, 수업의 이해도 향상을 위해 아래 소개할 도서 및 웹 문서 등을 참고할 것을 권장함.


#### 참고문헌{#ref-course .unnumbered}

- 빅데이터 분석 도구 R 프로그래밍 [@noman-2012]
- 실리콘밸리 데이터과학자가 알려주는 따라하며 배우는 데이터 과학 [@kwon-2017]
- R을 이용한 데이터 처리&분석 [@seo-2014]
- [R for data science](https://r4ds.had.co.nz/) [@wickham-2016r]
- Statistical Computing with R [@rizzo-2019]
- [R programming for data science](https://bookdown.org/rdpeng/rprogdatascience/) [@peng-2016]






