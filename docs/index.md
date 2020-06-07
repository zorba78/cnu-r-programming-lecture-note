--- 
title: "통계 프로그래밍 언어"
subtitle: "2020년도 1학기 충남대학교 정보통계학과 강의 노트"
author: "한국한의학연구원, 구본초"
date: "2020-06-07"
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
description: "2020년도 1학기 정보통계학과 통계 프로그래밍 언어 강의 노트로 해당 노트는 https://zorba78.github.io/cnu-r-programming-lecture-note/ 에서 확인 가능"
site: bookdown::bookdown_site
github-repo: zorba78/cnu-r-programming-lecture-note
editor_options: 
  chunk_output_type: console
---



# Course Overview{-#overview}

\BeginKnitrBlock{rmdnote}<div class="rmdnote">본 문서는 2020년도 1학기 정보통계학과에서 개설한 "통계 프로그래밍 언어" 강의를 위해 개발한 강의 노트이고 주 단위로 업데이트될 예정임. 본 강의 노트는  https://zorba78.github.io/cnu-r-programming-lecture-note/ 에서 확인할 수 있고, 해당 페이지에서 pdf 파일 다운로드가 가능함. 본 문서는 Yihui Xie가 개발한 **bookdown** 패키지 [@xie-2016]를 활용하여 생성한 문서이고 Google Chrome 또는 Firefox 브라우저에 최적화 됨. 아울러 충남대학교 정보통계학과 이상인 교수님의 2019년도 2학기 "통계패키지활용" 강의 노트와 동국대학교 ICT빅데이터학부 김진석 교수님의 [R 프로그래밍 및 실습](http://datamining.dongguk.ac.kr/lectures/R/_book/index.html) 강의 자료 내용과 구성을 참고하여 작성함. 

재택 수업 시 학생들이 사용하고 있는 컴퓨터의 인터넷 접속이 원활하다는 가정 하에서 강의를 진행할 예정이기 때문에 수강 시 온라인 상태 유지가 필수임. 
</div>\EndKnitrBlock{rmdnote}


#### 강의소개{#intro-lec .unnumbered}

R은 뉴질랜드 오클랜드 대학의 Robert Gentleman 과 Ross Ihaka 가 AT&T 벨 연구소에서 개발한 S 언어를 기반으로 개발한 GNU 환경의 통계 계산 및 프로그래밍 언어이다. 현재 R 소프트웨어는 통계학 뿐 아니라 데이터 과학을 포함한 의학, 생물학 등 다양한 분야에서 활용되고 있으며 특히 통계 소프트웨어 개발과 데이터 분석에 많이 활용되고 있다. 본 강의는 데이터 분석을 위한 R의 기초 문법과 통계학 입문에서 학습한 몇 가지 중요한 통계적 이론에 대한 시뮬레이션 방법을 다룬다. 아울러 R package를 활용한 데이터 헨들링 및 시각화 그리고 Rmarkdown을 활용한 재현가능(reproducible)한 문서 작성법에 대해 학습하고자 한다. 


#### 교과 목표{#purpose-course .unnumbered}

> - **R 기초 문법 습득**
> - **R package를 활용한 데이터 핸들링 및 자료 시각화**
> - **R 시뮬레이션을 통한 통계학 기초 이론 확인**
> - **R을 이용한 데이터 분석 실습**
> - **R markdown을 이용한 재현가능(reproducible)한 보고서 작성 방법 습득**



#### 선수과목{#pre-course .unnumbered}

> **통계학 개론**

#### 수업 방법{#course-method .unnumbered}

- **강의: 50 %**
- **실험/실습: 50%**

#### 평가방법{#grade-method .unnumbered}

> - **중간고사: 40 %**
> - **기말고사: 40 %**
> - **출석: 10 %**
> - **과제: 10 %**

#### 수업 규정{#policy-course .unnumbered}

> - 3번 지각은 1번 결석으로 처리
> - 특별한 사유 없이 수업 중간에 이탈한 경우 결석으로 처리
> - 특별한 사유로 인해 결석 또는 지각을 할 경우 사유를 증빙할 수 있는 서류 제출 시 출석으로 인정
> - 출결 미달, 중간 또는 기말고사 미 응시인 경우 F 학점으로 처리
> - 수업 중 휴대폰 및 각종 모바일 기기 사용 금지

#### 교재 및 참고문헌{#material-course .unnumbered}

> 별도의 교재 없이 본 강의 노트로 수업을 진행할 예정이며, 수업의 이해도 향상을 위해 아래 소개할 도서 및 웹 문서 등을 참고할 것을 권장함.

**참고 자료**

- 빅데이터 분석 도구 R 프로그래밍 [@noman-2012]
- 실리콘밸리 데이터과학자가 알려주는 따라하며 배우는 데이터 과학 [@kwon-2017]
- R을 이용한 데이터 처리&분석 [@seo-2014]
- R 그래픽스 [@ryu-2005]
- [ggplot2: elegant graphics for data analysis](https://ggplot2-book.org/) [@wickham-2016]
- [R for data science](https://r4ds.had.co.nz/) [@wickham-2016r]
- Statistical Computing with R [@rizzo-2019]

#### 강의 계획{#course-schedule .unnumbered}

<table class="table table-condensed table-striped" style="font-size: 10px; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">(\#tab:make-schedule-tab)강의 계획표</caption>
 <thead>
  <tr>
   <th style="text-align:center;"> 주차 </th>
   <th style="text-align:left;"> 강의 내용 </th>
   <th style="text-align:center;"> 과제 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> Week 1 </td>
   <td style="text-align:left;width: 6cm; "> R 소개, R/R Studio 설치, R 패키지 설치, R 맛보기 및 markdown 문서 만들기 </td>
   <td style="text-align:center;"> 과제 1 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 2 </td>
   <td style="text-align:left;width: 6cm; "> R 자료형: 스칼라, 벡터, 리스트 </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 3 </td>
   <td style="text-align:left;width: 6cm; "> R 자료형: 행렬 및 배열 </td>
   <td style="text-align:center;"> 과제 2 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 4 </td>
   <td style="text-align:left;width: 6cm; "> R 자료형: 팩터, 테이블, 데이터 프레임 </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 5 </td>
   <td style="text-align:left;width: 6cm; "> R 자료형: 문자열과 정규 표현식 </td>
   <td style="text-align:center;"> 과제 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 6 </td>
   <td style="text-align:left;width: 6cm; "> 데이터 프레임 가공 및 시각화 I </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 7 </td>
   <td style="text-align:left;width: 6cm; "> 데이터 프레임 가공 및 시각화 II </td>
   <td style="text-align:center;"> 과제 4 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 8 </td>
   <td style="text-align:left;width: 6cm; "> 중간고사 </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 9 </td>
   <td style="text-align:left;width: 6cm; "> 데이터 프레임 가공 및 시각화 III </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 10 </td>
   <td style="text-align:left;width: 6cm; "> R 프로그래밍: 조건문, 반복문, 함수 </td>
   <td style="text-align:center;"> 과제 5 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 11 </td>
   <td style="text-align:left;width: 6cm; "> 통계시뮬레이션 I: 표본분포 및 중심극한정리 </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 12 </td>
   <td style="text-align:left;width: 6cm; "> 통계시뮬레이션 2: 신뢰구간과 가설검정 </td>
   <td style="text-align:center;"> 과제 6 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 13 </td>
   <td style="text-align:left;width: 6cm; "> R을 이용한 기초통계 분석 </td>
   <td style="text-align:center;">  </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 14 </td>
   <td style="text-align:left;width: 6cm; "> R markdown 활용 </td>
   <td style="text-align:center;"> 과제 7 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> Week 15 </td>
   <td style="text-align:left;width: 6cm; "> 기말고사 </td>
   <td style="text-align:center;">  </td>
  </tr>
</tbody>
</table>


<!-- ```{r include=FALSE} -->
<!-- # automatically create a bib database for R packages -->
<!-- knitr::write_bib(c( -->
<!--   .packages(), 'bookdown', 'knitr', 'rmarkdown' -->
<!-- ), 'packages.bib') -->
<!-- ``` -->
