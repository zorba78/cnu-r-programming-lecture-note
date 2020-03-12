\mainmatter


# (PART) Get Started {-}

# Introduction {#intro-chap}

**1. R프로그램**

   - 데이터 분석을 위한 자료 전처리, 통계 및 시각화를 지원하는 컴퓨터 언어 및 환경
   - 1980년 AT&T 벨 연구소의 John Chambers가 개발한 S 언어를 기반으로 1995년 뉴질랜드 Auckland 대학의 통계학과 교수 Robert Gentleman과 Ross Ihaka 가 개발
   - [GNU](https://en.wikipedia.org/wiki/GNU_Project) 기반의 오픈 소스
   - 통계학, 전산학, 생물학, 의학 등 거의 모든 학문분야에서 분석도구로 활용되고 있고, 최근 data science 분야에서 널리 활용


**2. R 언어의 특징**

   - **무료 소프트웨어**
   - [CRAN (Comprehensive R Archive Network)](http://cran.r-project.org/web/view)에서 배포
   - 특정 vendor가 아닌 전 세계 연구자들이 개발한 알고리즘 및 최신 함수 활용 가능(packaging system)
   - 범용적으로 사용되는 거의 대부분의 운영체제(Windows, Mac, Linux)에서 작동 가능
   - 방대한 개발 및 사용 생태계 형성 
   - 강력한 그래픽 기능

> **Tips: 유용한 웹 사이트**
>
> - R과 관련한 거의 모든 문제는 Googling (구글을 이용한 검색)을 통해 해결 가능
> - 다음 사이트는 꼭 즐겨찾기 추가!!
>    - [Stack Overflow](https://stackoverflow.com)
>    - [RPubs](https://rpubs.com/)


## R 설치하기 {#installation}

R 다운로드 사이트: https://www.r-project.org 또는 https://cran.r-project.org

1. 웹 브라우저(i.e. Explore, Chrome, Firefox 등)의 주소 입력창에 https://www.r-project.org

2. 좌측 R Logo 하단 Download 아래 CRAN 클릭

<img src="figures/Rorg-main-add.png" width="80%" style="display: block; margin: auto;" />


3. 클릭 후 연결한 페이지를 스크롤 후 Korea 아래 링크^[해당 링크들은 접속 시점에 따라 변경될 수 있음] 클릭 


<img src="figures/CRAN-korea-01.png" width="80%" style="display: block; margin: auto;" />


4. 클릭 후 세 가지 운영체제(Linux, Mac OS X, Windowns)에 따른 R 버전 선택 가능^[본 노트는 Windows 버전 설치만 다룸]


<img src="figures/Rinstall-01.png" width="80%" style="display: block; margin: auto;" />

5. **Downloads R for Windows** 링크 클릭하면 다음과 같은 화면으로 이동

<img src="figures/Rinstall-02.png" width="80%" style="display: block; margin: auto;" />

6. 위 화면에서 **base** 링크 클릭 후 아래 화면에서 **Downloads R 3.4.2 for Windows** 를 클릭 후 설치 파일을 임의의 디렉토리에 저장 및 실행

<img src="figures/Rinstall-03.png" width="80%" style="display: block; margin: auto;" />


> **Tip**: 3개 subdirectories에 대한 간략 설멍
>
>    - `base`: R 실행 프로그램 
>    - `contrib`: R package의 바이너리 파일 
>    - `Rtools`: R package 개발 및 배포를 위한 프로그램


<!-- 8. 다운로드한 파일을 실행하면 아래와 같은 대화창이 나타남 -->
<!--     - 한국어 선택 $\rightarrow$ 환영 화면에서 [다음(N)>] 클릭 -->

<!-- \begin{figure}[H] -->
<!-- { -->
<!--   \centering -->
<!--   \includegraphics[width = 14cm, height = 11cm]{Figures/R-install-F01.png} -->
<!--   \caption[R 설치과정 01]{R 설치과정 01}\label{fig:R-install-06} -->
<!-- } -->
<!-- \end{figure}  -->

<!-- 9. GNU 라이센스에 대한 설명 및 동의 여부([다음(N)>]) 클릭 (그림 \ref{fig:R-install-07}) -->

<!-- \begin{figure}[H] -->
<!-- { -->
<!--   \centering -->
<!--   \includegraphics[width = 8cm, height = 8cm]{Figures/R-install-F02.png} -->
<!--   \caption[R GNU general license]{R GNU general license}\label{fig:R-install-07} -->
<!-- } -->
<!-- \end{figure}  -->

<!-- 10. 설치 디렉토리 설정 및 구성요소 설지 여부 -->
<!--     - 원하는 디렉토리 설정(예: `C:\R\R-3.4.2`) (그림 \ref{fig:R-install-08}) -->
<!--     - 기본 프로그램("Core Files"), 32 또는 64 bit 용 설치 파일, R console 한글 번역 모두 체크 뒤 [다음(N)>] 클릭 (그림 \ref{fig:R-install-09}) -->

<!-- \begin{figure}[H] -->
<!-- { -->
<!--   \centering -->
<!--   \includegraphics[width = 15cm, height = 10cm]{Figures/R-install-F03.png} -->
<!--   \caption[R 설치 디렉토리 설정]{R 설치 디렉토리 설정}\label{fig:R-install-08} -->
<!-- } -->
<!-- \end{figure}      -->

<!-- \begin{figure}[H] -->
<!-- { -->
<!--   \centering -->
<!--   \includegraphics[width = 8cm, height = 8cm]{Figures/R-install-F04.png} -->
<!--   \caption[R 구성요소 설치]{R 구성요소 설치}\label{fig:R-install-09} -->
<!-- } -->
<!-- \end{figure} -->



# References {-}

   
