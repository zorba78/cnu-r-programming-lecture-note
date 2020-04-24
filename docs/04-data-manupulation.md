


# 데이터 관리(Data Management) {#data-manipulation}

\footnotesize

\BeginKnitrBlock{rmdimportant}<div class="rmdimportant">**학습 목표**

- Hadely Weckam이 개발한 데이터의 전처리 및 시각화를 위해 각광받는 tidyverse 패키지에 대해 알아본다
- 데이터를 읽고, 저장하고, 목적에 맞게 가공하고, tidyverse 하에서 반복 계산 방법에 대해 알아본다. 
</div>\EndKnitrBlock{rmdimportant}

 \normalsize


**데이터 분석과정**

1) 데이터를 R 작업환경(workspace)에 **불러오고(import)**, 
2) 불러온 데이터를 **가공하고(data management, data preprocessing)**, 
3) 가공한 데이터를 **분석(analysis, modeling)** 및 **시각화(visualization)** 후,  
4) 분석 결과를 **저장(save)** 및 외부 파일로 **내보낸(export)** 후, 
5) 이를 통해 전문가와 **소통(communicate)**


\footnotesize

<div class="figure" style="text-align: center">
<img src="figures/data-science.png" alt="Data 분석의 과정. @wickham-2016r 에서 발췌" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-3)Data 분석의 과정. @wickham-2016r 에서 발췌</p>
</div>

 \normalsize



**R의 데이터 가공(관리) 방법**

1. 기본 R을 활용: 지금까지 배워온 방법으로 분석을 위한 데이터 가공(색인, 필터, 병합 등)


2. **tidyverse** 패키지 활용
   - 직관적 코드 작성 가능
   - 빠른 실행속도


3. **data.table** 패키지 활용(본 강의에서는 다루지 않음)
   - 빠른 실행속도 
   

다양한 통계 함수와 최신 분석에 대한 여러 패키지 및 함수를 R 언어를 통해 활용 가능함에도 불구하고, 타 통계 소프트웨어(SAS, SPSS, Stata, Minitab 등)에 비해 데이터 가공 및 처리가 직관적이지 않고 불편했던 점은 R이 갖고 있던 큰 단점 중 하나임. RStudio의 수석 데이터 과학자인 Hadely Wickham의 tidyverse는 이러한 단점을 최대한 보완했고, 현재는 R을 통한 데이터 분석에서 핵심적인 도구로 자리매김 하고 있음. Tidyverse의 철학은 R 언어의 생태계에 혁신적인 변화를 가져왔을 뿐 아니라 지속적으로 진화하고 있기 때문에 해당 패키지들이 제공하는 언어 형태를 이해할 필요가 있음. 


## Prerequisites {#ch4-prerequi}

### 외부데이터 불러오기 및 저장 {#data-import-export}

\footnotesize

\BeginKnitrBlock{rmdnote}<div class="rmdnote">R 기본 함수를 이용해서 데이터 저장 파일의 가장 기본적인 형태인 텍스트 파일을 읽고 저장하는 방법에 대해 먼저 살펴봄. Base R에서 외부 데이터를 읽고 저장을 위한 함수는 매우 다양하지만 가장 많이 사용되고 있는 함수들에 대해 살펴볼 것임</div>\EndKnitrBlock{rmdnote}

 \normalsize


- 기본 R(base R)에서 제공하는 함수를 이용해 외부 데이터를 읽고, 내보내고, 저장하는 방법에 대해 살펴봄. 
- 가장 일반적인 형태의 데이터는 보통 텍스트 파일 형태로 저장되어 있음, 일반적으로
   - 첫 번째 줄: 변수명
   - 두 번째 줄 부터: 데이터 입력
   
```
id sex age edulev height 
1 Male 65   12 168
2 Female 74 9  145
3 Male 61   12 171
4 Male 85   6  158
5 Female 88 0  134
```

- 데이터의 자료값과 자료값을 구분하는 문자를 구분자(separator)라고 하며 주로 공백(` `), 콤마(`,`), tab 문자(`\t`) 등이 사용됨
- 주로 확장자 명이 `*.txt` 이며, 콤마 구분자인 경우 보통은 `*.csv` (comma separated values)로 저장

```
#titanic3.csv 파일 일부 

"pclass","survived","name","sex","age",
1,1,"Allen, Miss. Elisabeth Walton","female"
1,1,"Allison, Master. Hudson Trevor","male"
1,0,"Allison, Miss. Helen Loraine", "female"
1,0,"Allison, Mr. Hudson Joshua Creighton","male"
1,0,"Allison, Mrs. Hudson J C (Bessie Waldo Daniels)","female"
```



#### **텍스트 파일 입출력** {#text-import-export .unnumbered}


\footnotesize

\BeginKnitrBlock{rmdcaution}<div class="rmdcaution">외부 데이터를 불러온다는 것은 외부에 저장되어 있는 파일을 R 작업환경으로 읽어온다는 의미이기 때문에, 현재 작업공간의 작업 디렉토리(working directory) 확인이 필요.</div>\EndKnitrBlock{rmdcaution}

 \normalsize

- `read.table()/write.table()`: 
   - 가장 범용적으로 외부 텍스트 데이터를 R 작업공간으로 데이터 프레임으로 읽고 저장하는 함수
   - 텍스트 파일의 형태에 따라 구분자 지정 가능

\footnotesize


```r
# read.table(): 텍스트 파일 읽어오기
read.table(
  file, # 파일명. 일반적으로 폴더명 구분자 
        # 보통 folder/파일이름.txt 형태로 입력
  header = FALSE, # 첫 번째 행을 헤더(변수명)으로 처리할 지 여부
  sep = "", # 구분자 ",", "\t" 등의 형태로 입력
  comment.char = "#", # 주석문자 지정
  stringsAsFactors = TRUE, # 문자형 변수를 factor으로 변환할 지 여부
  encoding = "unknown" # 텍스트의 encoding 보통 CP949 또는 UTF-8
                       # 한글이 입력된 데이터가 있을 때 사용
)
```

 \normalsize

- `read.table()` 예시

\footnotesize

\BeginKnitrBlock{rmdnote}<div class="rmdnote">예시에 사용된 데이터들은 Clinical trial data analysis using R [@chen-2010]에서 제공되는 데이터임.</div>\EndKnitrBlock{rmdnote}

 \normalsize


\footnotesize


```r
# tab 구분자 데이터 불러오기
# dataset 폴더에 저장되어 있는 DBP.txt 파일 읽어오기
dbp <- read.table("dataset/DBP.txt", sep = "\t", header = TRUE)
str(dbp)
```

```
'data.frame':	40 obs. of  9 variables:
 $ Subject: int  1 2 3 4 5 6 7 8 9 10 ...
 $ TRT    : Factor w/ 2 levels "A","B": 1 1 1 1 1 1 1 1 1 1 ...
 $ DBP1   : int  114 116 119 115 116 117 118 120 114 115 ...
 $ DBP2   : int  115 113 115 113 112 112 111 115 112 113 ...
 $ DBP3   : int  113 112 113 112 107 113 100 113 113 108 ...
 $ DBP4   : int  109 103 104 109 104 104 109 102 109 106 ...
 $ DBP5   : int  105 101 98 101 105 102 99 102 103 97 ...
 $ Age    : int  43 51 48 42 49 47 50 61 43 51 ...
 $ Sex    : Factor w/ 2 levels "F","M": 1 2 1 1 2 2 1 2 2 2 ...
```

```r
# 문자형 값들을 factor로 변환하지 않는 경우
dbp2 <- read.table("dataset/DBP.txt", sep = "\t", 
                   header = TRUE, 
                   stringsAsFactors = FALSE)
str(dbp2)
```

```
'data.frame':	40 obs. of  9 variables:
 $ Subject: int  1 2 3 4 5 6 7 8 9 10 ...
 $ TRT    : chr  "A" "A" "A" "A" ...
 $ DBP1   : int  114 116 119 115 116 117 118 120 114 115 ...
 $ DBP2   : int  115 113 115 113 112 112 111 115 112 113 ...
 $ DBP3   : int  113 112 113 112 107 113 100 113 113 108 ...
 $ DBP4   : int  109 103 104 109 104 104 109 102 109 106 ...
 $ DBP5   : int  105 101 98 101 105 102 99 102 103 97 ...
 $ Age    : int  43 51 48 42 49 47 50 61 43 51 ...
 $ Sex    : chr  "F" "M" "F" "F" ...
```

```r
# 데이터 형태 파악
head(dbp)
```

```
  Subject TRT DBP1 DBP2 DBP3 DBP4 DBP5 Age Sex
1       1   A  114  115  113  109  105  43   F
2       2   A  116  113  112  103  101  51   M
3       3   A  119  115  113  104   98  48   F
4       4   A  115  113  112  109  101  42   F
5       5   A  116  112  107  104  105  49   M
6       6   A  117  112  113  104  102  47   M
```

```r
# 콤마 구분자 데이터 불러오기
# dataset 폴더에 저장되어 있는 diabetes_csv.txt 파일 읽어오기
diab <- read.table("dataset/diabetes_csv.txt", sep = ",", header = TRUE)
str(diab)
```

```
'data.frame':	403 obs. of  19 variables:
 $ id      : int  1000 1001 1002 1003 1005 1008 1011 1015 1016 1022 ...
 $ chol    : int  203 165 228 78 249 248 195 227 177 263 ...
 $ stab.glu: int  82 97 92 93 90 94 92 75 87 89 ...
 $ hdl     : int  56 24 37 12 28 69 41 44 49 40 ...
 $ ratio   : num  3.6 6.9 6.2 6.5 8.9 ...
 $ glyhb   : num  4.31 4.44 4.64 4.63 7.72 ...
 $ location: Factor w/ 2 levels "Buckingham","Louisa": 1 1 1 1 1 1 1 1 1 1 ...
 $ age     : int  46 29 58 67 64 34 30 37 45 55 ...
 $ gender  : Factor w/ 2 levels "female","male": 1 1 1 2 2 2 2 2 2 1 ...
 $ height  : int  62 64 61 67 68 71 69 59 69 63 ...
 $ weight  : int  121 218 256 119 183 190 191 170 166 202 ...
 $ frame   : Factor w/ 4 levels "","large","medium",..: 3 2 2 2 3 2 3 3 2 4 ...
 $ bp.1s   : int  118 112 190 110 138 132 161 NA 160 108 ...
 $ bp.1d   : int  59 68 92 50 80 86 112 NA 80 72 ...
 $ bp.2s   : int  NA NA 185 NA NA NA 161 NA 128 NA ...
 $ bp.2d   : int  NA NA 92 NA NA NA 112 NA 86 NA ...
 $ waist   : int  29 46 49 33 44 36 46 34 34 45 ...
 $ hip     : int  38 48 57 38 41 42 49 39 40 50 ...
 $ time.ppn: int  720 360 180 480 300 195 720 1020 300 240 ...
```

```r
head(diab)
```

```
    id chol stab.glu hdl ratio glyhb   location age gender height weight  frame
1 1000  203       82  56   3.6  4.31 Buckingham  46 female     62    121 medium
2 1001  165       97  24   6.9  4.44 Buckingham  29 female     64    218  large
3 1002  228       92  37   6.2  4.64 Buckingham  58 female     61    256  large
4 1003   78       93  12   6.5  4.63 Buckingham  67   male     67    119  large
5 1005  249       90  28   8.9  7.72 Buckingham  64   male     68    183 medium
6 1008  248       94  69   3.6  4.81 Buckingham  34   male     71    190  large
  bp.1s bp.1d bp.2s bp.2d waist hip time.ppn
1   118    59    NA    NA    29  38      720
2   112    68    NA    NA    46  48      360
3   190    92   185    92    49  57      180
4   110    50    NA    NA    33  38      480
5   138    80    NA    NA    44  41      300
6   132    86    NA    NA    36  42      195
```

```r
# Encoding이 다른 경우(한글데이터 포함): 
# 한약재 사전 데이터 (CP949 encoding으로 저장)
# tab 구분자 데이터 사용
# UTF-8로 읽어오기
herb <- read.table("dataset/herb_dic_sample.txt", sep = "\t", 
                   header = TRUE, 
                   encoding = "UTF-8", 
                   stringsAsFactors = FALSE)
head(herb)
```

```
                              herb                      herb_normal
1             <U+02B8><ed><U+00AD>             <U+02B8><ed><U+00AD>
2 <U+02B8><ed><U+00AD><eb><U+00BF> <U+02B8><ed><U+00AD><eb><U+00BF>
3 <U+02B8><ed><U+00AD><f9><U+00AB> <U+02B8><ed><U+00AD><f9><U+00AB>
4                 <d3><d7><cf><fd>                 <d3><d7><cf><fd>
5         <d3><d7><cf><fd><U+06AD>                 <d3><d7><cf><fd>
6         <d3><d7><cf><fd><e3><f3>                 <d3><d7><cf><fd>
                            korean
1         <U+00B0><U+00A1><c0><da>
2 <U+00B0><U+00A1><c0><da><U+0030>
3 <U+00B0><U+00A1><c0><da><c7><c7>
4         <U+00B4><e7><U+00B1><cd>
5         <U+00B4><e7><U+00B1><cd>
6         <U+00B4><e7><U+00B1><cd>
```

```r
# CP949로 읽어오기
herb <- read.table("dataset/herb_dic_sample.txt", sep = "\t", 
                   header = TRUE, 
                   encoding = "CP949", 
                   stringsAsFactors = FALSE)
head(herb)
```

```
    herb herb_normal korean
1   訶子        訶子   가자
2 訶子肉      訶子肉 가자육
3 訶子皮      訶子皮 가자피
4   當歸        當歸   당귀
5 當歸尾        當歸   당귀
6 當歸身        當歸   당귀
```

 \normalsize

- `read.table()` + `textConnection()`: 웹사이트나 URL에 있는 데이터를 `Copy + Paste` 해서 읽어올 경우 유용하게 사용
   - `textConnection()`: 텍스트에서 한 줄씩 읽어 문자형 벡터처럼 인식할 수 있도록 해주는 함수

\footnotesize


```r
# Plasma 데이터: http://lib.stat.cmu.edu/datasets/Plasma_Retinol 
input1 <- ("64	2	2	21.4838	1	1298.8	57	6.3	0	170.3	1945	890	200	915
76	2	1	23.87631	1	1032.5	50.1	15.8	0	75.8	2653	451	124	727
38	2	2	20.0108	2	2372.3	83.6	19.1	14.1	257.9	6321	660	328	721
40	2	2	25.14062	3	2449.5	97.5	26.5	0.5	332.6	1061	864	153	615
72	2	1	20.98504	1	1952.1	82.6	16.2	0	170.8	2863	1209	92	799
40	2	2	27.52136	3	1366.9	56	9.6	1.3	154.6	1729	1439	148	654
65	2	1	22.01154	2	2213.9	52	28.7	0	255.1	5371	802	258	834
58	2	1	28.75702	1	1595.6	63.4	10.9	0	214.1	823	2571	64	825
35	2	1	23.07662	3	1800.5	57.8	20.3	0.6	233.6	2895	944	218	517
55	2	2	34.96995	3	1263.6	39.6	15.5	0	171.9	3307	493	81	562")

input2 <- ("AGE: Age (years)
	SEX: Sex (1=Male, 2=Female).
	SMOKSTAT: Smoking status (1=Never, 2=Former, 3=Current Smoker)
	QUETELET: Quetelet (weight/(height^2))
	VITUSE: Vitamin Use (1=Yes, fairly often, 2=Yes, not often, 3=No)
	CALORIES: Number of calories consumed per day.
	FAT: Grams of fat consumed per day.
	FIBER: Grams of fiber consumed per day.
	ALCOHOL: Number of alcoholic drinks consumed per week.
	CHOLESTEROL: Cholesterol consumed (mg per day).
	BETADIET: Dietary beta-carotene consumed (mcg per day).
	RETDIET: Dietary retinol consumed (mcg per day)
	BETAPLASMA: Plasma beta-carotene (ng/ml)
	RETPLASMA: Plasma Retinol (ng/ml)")

plasma <- read.table(textConnection(input1), sep = "\t", header = F)
codebook <- read.table(textConnection(input2), sep = ":", header = F)
varname <- gsub("^\\s+", "", codebook$V1) # 변수명 지정

names(plasma) <- varname
head(plasma)
```

```
  AGE SEX SMOKSTAT QUETELET VITUSE CALORIES  FAT FIBER ALCOHOL CHOLESTEROL
1  64   2        2 21.48380      1   1298.8 57.0   6.3     0.0       170.3
2  76   2        1 23.87631      1   1032.5 50.1  15.8     0.0        75.8
3  38   2        2 20.01080      2   2372.3 83.6  19.1    14.1       257.9
4  40   2        2 25.14062      3   2449.5 97.5  26.5     0.5       332.6
5  72   2        1 20.98504      1   1952.1 82.6  16.2     0.0       170.8
6  40   2        2 27.52136      3   1366.9 56.0   9.6     1.3       154.6
  BETADIET RETDIET BETAPLASMA RETPLASMA
1     1945     890        200       915
2     2653     451        124       727
3     6321     660        328       721
4     1061     864        153       615
5     2863    1209         92       799
6     1729    1439        148       654
```

 \normalsize

- `write.table()`: R의 객체(벡터, 행렬, 데이터 프레임)를 저장 후 외부 텍스트 파일로 내보내기 위한 함수


\footnotesize


```r
# write.table() R 객체를 텍스트 파일로 저장하기
write.table(
  data_obj, # 저장할 객체 이름
  file,  # 저장할 위치 및 파일명  또는 
         # 또는 "파일쓰기"를 위한 연결 명칭
  sep,   # 저장 시 사용할 구분자
  row.names = TRUE # 행 이름 저장 여부
)
```

 \normalsize

- 예시

\footnotesize


```r
# 위에서 읽어온 plasma 객체를 dataset/plasma.txt 로 내보내기
# 행 이름은 생략, tab으로 데이터 구분

write.table(plasma, "dataset/plasma.txt", 
            sep = "\t", row.names = F)
```

 \normalsize

- 파일명 대신 Windows clipboard 로 내보내기 가능

\footnotesize


```r
# clipboard로 복사 후 excel 시트에 해당 데이터 붙여넣기
# Ctrl + V
write.table(plasma, "clipboard", 
            sep = "\t", row.names = F)
```

 \normalsize


- `read.csv()`/`write.csv()`: `read.table()` 함수의 wrapper 함수로 구분자 인수 `sep`이 콤마(`,`)로 고정(예시 생략)


#### R 바이너리(binary) 파일 입출력 {#binary-import-export .unnumbered}

R 작업공간에 존재하는 한 개 이상의 객체들을 저장하고 읽기 위한 함수

- R 데이터 관련 바이너리 파일은 한 개 이상의 객체가 저장된 바이너리 파일인 경우 `*.Rdata` 형태를 갖고, 단일 객체를 저장할 경우 보통 `*.rds` 파일 확장자로 저장

- `*.Rdata` 입출력 함수
   - `load()`: `*.Rdata` 파일 읽어오기
   - `save()`: 한 개 이상 R 작업공간에 존재하는 객체를 `.Rdata` 파일로 저장
   - `save.image()`: 현재 R 작업공간에 존재하는 모든 객체를 `.Rdata` 파일로 저장

\footnotesize


```r
# 현재 작업공간에 존재하는 모든 객체를 "output" 폴더에 저장
# output 폴더가 존재하지 않는 경우 아래 명령 실행
# dir.create("output") 
ls()
```

```
 [1] "codebook"       "dbp"            "dbp2"           "def.chunk.hook"
 [5] "diab"           "herb"           "hook_output"    "input1"        
 [9] "input2"         "plasma"         "varname"       
```

```r
save.image(file = "output/all_obj.Rdata")

rm(list = ls()) 
ls()
```

```
character(0)
```

```r
# 저장된 binary 파일(all_obj.Rdata) 불러오기
load("output/all_obj.Rdata")
ls()
```

```
 [1] "codebook"       "dbp"            "dbp2"           "def.chunk.hook"
 [5] "diab"           "herb"           "hook_output"    "input1"        
 [9] "input2"         "plasma"         "varname"       
```

```r
# dnp, plasma 데이터만 output 폴더에 sub_obj.Rdata로 저장
save(dbp, plasma, file = "output/sub_obj.Rdata")
rm(list = c("dbp", "plasma"))
ls()
```

```
[1] "codebook"       "dbp2"           "def.chunk.hook" "diab"          
[5] "herb"           "hook_output"    "input1"         "input2"        
[9] "varname"       
```

```r
# sub_obj.Rdata 파일 불러오기
load("output/sub_obj.Rdata")
ls()
```

```
 [1] "codebook"       "dbp"            "dbp2"           "def.chunk.hook"
 [5] "diab"           "herb"           "hook_output"    "input1"        
 [9] "input2"         "plasma"         "varname"       
```

 \normalsize


- `*.rds` 입출력 함수
   - `readRDS()`/ `saveRDS()`: 단일 객체가 저장된 `*.rds` 파일을 읽거나 저장
   - 대용량 데이터를 다룰 때 유용함
   - `read.table()` 보다 데이터를 읽는 속도가 빠르며, 다른 확장자 명의 텍스트 파일보다 높은 압축율을 보임

\footnotesize


```r
# 대용량 파일 dataset/pulse.csv 불러오기
# system.time(): 명령 실행 시가 계산 함수
system.time(pulse <- read.csv("dataset/pulse.csv", header = T))
```

```
 사용자  시스템 elapsed 
  20.58    0.04   20.63 
```

```r
# saveRDS()함수를 이용해 output/pulse.rds 파일로 저장
saveRDS(pulse, "output/pulse.rds")
rm(pulse); ls()
```

```
 [1] "codebook"       "dbp"            "dbp2"           "def.chunk.hook"
 [5] "diab"           "herb"           "hook_output"    "input1"        
 [9] "input2"         "plasma"         "varname"       
```

```r
system.time(pulse <- readRDS("output/pulse.rds"))
```

```
 사용자  시스템 elapsed 
   0.08    0.00    0.08 
```

 \normalsize



## Tidyverse {#tidyverse}



- "Tidy" + "Universe"의 조어로 "tidy data"의 기본 설계 철학, 문법 및 데이터 구조를 공유하는 RStudio 수석 과학자인 Hadley Wickham이 개발한 패키지 묶음(번들) 또는 메타 패키지로, 데이터 과학(data science)을 위한 R package를 표방 [@R-tidyverse] 

- 데이터 분석 과정 중 가장 긴 시간을 할애하는 데이터 전처리(data preprocessing, data management, data wrangling, data munging 등으로 표현)를 위한 다양한 함수들을 제공하며, 특히 파이프(pipe) 연산자로 지칭되는 `%>%`를 통한 코드의 간결성 및 가독성을 최대화 하는 것이 tidyverse 패키지들의 특징

- Hadley Wickham이 주창한 [Tidy Tools Manifesto](https://mran.microsoft.com/web/packages/tidyverse/vignettes/manifesto.html)에 따르면, tidyverse가 추구하는 프로그래밍 인터페이스에 대한 4 가지 원칙을 제시

> 1) 기존 데이터의 구조를 재사용
>
> 2) 파이프 연산자를 이용한 최대한 간결한 함수 작성
>
> 3) R의 특징 중 하나인 functional programming 수용
>
> 4) 사람이 읽기 쉬운 프로그램으로 설계


- Tidyverse를 구성하는 주요 패키지(알파벳 순)

> 1) **dplyr**: 가장 일반적인 데이터 가공 및 처리 해결을 위한 "동사"(함수)로 구성된 문법 제공
> 2) **forcat**: 범주형 변수 처리를 위해 Rdml factor와 관련된 일반적인 문제 해결을 위한 함수 제공
> 3) **ggplot2**: 그래픽 문법을 기반으로 2차원 그래픽을 생성하기 위해 고안된 시스템
> 4) **purrr**: 함수 및 벡터의 반복 작업을 수행할 수 있는 도구를 제공
> 5) **readr**: base R에서 제공하는 파일 입출력 함수보다 효율적인 성능을 갖는 입출력 함수로 구성
> 6) **stringr**: 가능한 한 쉬운 방법으로 문자열을 다룰 수 있는 함수 제공
> 7) **tibble**: Tidyverse에서 재해석한 데이터 프레임 형태로 tidyverse에서 다루는 데이터의 기본 형태
> 8) **tidyr**: 데이터를 정리하고 "tidy data"를 도출하기 위한 일련의 함수 제공



\footnotesize

<img src="figures/tidyverse_packages.png" width="100%" style="display: block; margin: auto;" />

 \normalsize


- 그 밖에 유용한 tidyverse에 소속되어 있는 패키지

> - **haven**: 타 통계 프로그램(SAS, SPSS, Stata)의 데이터 포멧 입출력 함수 제공
> - **readxl**: Excel 파일 입력 함수 제공
> - **lubridate**: 시간(년/월/일/시/분) 데이터 가공 및 연산 함수 제공
> - **magrittr**: Tidyverse의 문법(함수)를 연결 시켜주는 파이프 연산자 제공. 예전에는 독립적인 패키지였으나 지금은 모든 tidyverse 패키지에 내장되어 있음


## `readr` 패키지 {#readr}

- 기본적으로 \@(data-import-export) 절에서 학습했던 `read.table()`, `read.csv()`와 거의 동일하게 작동하지만, 읽고 저장하는 속도가 base R에서 제공하는 기본 입출력 함수보다 월등히 뛰어남. 최근 readr 패키지에서 제공하는 입출력 함수보다 더 빠르게 데이터 입출력이 가능한 feather 패키지 [@R-feather] 제공 

- 데이터를 읽는 동안 사소한 문제가 있는 경우 해당 부분에 경고 표시 및 행, 관측 정보를 표시해줌 $\rightarrow$ 데이터 디버깅에 유용

- 주요 함수^[주요 함수들의 사용방법은 거의 유사하기 때문에 read_csv() 함수에 대해서만 살펴봄]
   - `read_table()`, `write_table()`
   - `read_csv()`, `write_csv()`

- [readr vignette](https://cran.r-project.org/web/packages/readr/vignettes/readr.html)을 통해 더 자세한 예시를 살펴볼 수 있음

\footnotesize


```r
read_csv(
  file, # 파일 명
  col_names = TRUE, # 첫 번째 행를 변수명으로 처리할 것인지 여부
                    # read.table(), read.csv()의 header 인수와 동일
  col_types = NULL, # 열(변수)의 데이터 형 지정
                    # 기본적으로 데이터 유형을 자동으로 감지하지만, 
                    # 입력 텍스트의 형태에 따라 데이터 유형을 
                    # 잘못 추측할 수 있기 때문에 간혹 해당 인수 입력 필요
                    # col_* 함수 또는 campact string으로 지정 가능
                    # c=character, i=integer, n=number, d=double, 
                    # l=logical, f=factor, D=date, T=date time, t=time
                    # ?=guess, _/- skip column
  progress, # 데이터 읽기/쓰기  진행 progress 표시 여부
)
```

 \normalsize

- 예시

\footnotesize


```r
# dataset/titanic3.csv 불러오기
titanic <- read_csv("dataset/titanic3.csv")
```

```
Parsed with column specification:
cols(
  pclass = col_double(),
  survived = col_double(),
  name = col_character(),
  sex = col_character(),
  age = col_double(),
  sibsp = col_double(),
  parch = col_double(),
  ticket = col_character(),
  fare = col_double(),
  cabin = col_character(),
  embarked = col_character(),
  boat = col_character(),
  body = col_double(),
  home.dest = col_character()
)
```

```r
titanic
```

```
# A tibble: 1,309 x 14
   pclass survived name  sex     age sibsp parch ticket  fare cabin embarked
    <dbl>    <dbl> <chr> <chr> <dbl> <dbl> <dbl> <chr>  <dbl> <chr> <chr>   
 1      1        1 Alle~ fema~ 29        0     0 24160  211.  B5    S       
 2      1        1 Alli~ male   0.92     1     2 113781 152.  C22 ~ S       
 3      1        0 Alli~ fema~  2        1     2 113781 152.  C22 ~ S       
 4      1        0 Alli~ male  30        1     2 113781 152.  C22 ~ S       
 5      1        0 Alli~ fema~ 25        1     2 113781 152.  C22 ~ S       
 6      1        1 Ande~ male  48        0     0 19952   26.6 E12   S       
 7      1        1 Andr~ fema~ 63        1     0 13502   78.0 D7    S       
 8      1        0 Andr~ male  39        0     0 112050   0   A36   S       
 9      1        1 Appl~ fema~ 53        2     0 11769   51.5 C101  S       
10      1        0 Arta~ male  71        0     0 PC 17~  49.5 <NA>  C       
# ... with 1,299 more rows, and 3 more variables: boat <chr>, body <dbl>,
#   home.dest <chr>
```

```r
# read.csv와 비교
head(read.csv("dataset/titanic3.csv", header = T), 10)
```

```
   pclass survived                                            name    sex   age
1       1        1                   Allen, Miss. Elisabeth Walton female 29.00
2       1        1                  Allison, Master. Hudson Trevor   male  0.92
3       1        0                    Allison, Miss. Helen Loraine female  2.00
4       1        0            Allison, Mr. Hudson Joshua Creighton   male 30.00
5       1        0 Allison, Mrs. Hudson J C (Bessie Waldo Daniels) female 25.00
6       1        1                             Anderson, Mr. Harry   male 48.00
7       1        1               Andrews, Miss. Kornelia Theodosia female 63.00
8       1        0                          Andrews, Mr. Thomas Jr   male 39.00
9       1        1   Appleton, Mrs. Edward Dale (Charlotte Lamson) female 53.00
10      1        0                         Artagaveytia, Mr. Ramon   male 71.00
   sibsp parch   ticket     fare   cabin embarked boat body
1      0     0    24160 211.3375      B5        S    2   NA
2      1     2   113781 151.5500 C22 C26        S   11   NA
3      1     2   113781 151.5500 C22 C26        S        NA
4      1     2   113781 151.5500 C22 C26        S       135
5      1     2   113781 151.5500 C22 C26        S        NA
6      0     0    19952  26.5500     E12        S    3   NA
7      1     0    13502  77.9583      D7        S   10   NA
8      0     0   112050   0.0000     A36        S        NA
9      2     0    11769  51.4792    C101        S    D   NA
10     0     0 PC 17609  49.5042                C        22
                         home.dest
1                     St Louis, MO
2  Montreal, PQ / Chesterville, ON
3  Montreal, PQ / Chesterville, ON
4  Montreal, PQ / Chesterville, ON
5  Montreal, PQ / Chesterville, ON
6                     New York, NY
7                       Hudson, NY
8                      Belfast, NI
9              Bayside, Queens, NY
10             Montevideo, Uruguay
```

```r
# column type을 변경
titanic2 <- read_csv("dataset/titanic3.csv", 
                     col_types = "iicfdiicdcfcic")
titanic2
```

```
# A tibble: 1,309 x 14
   pclass survived name  sex     age sibsp parch ticket  fare cabin embarked
    <int>    <int> <chr> <fct> <dbl> <int> <int> <chr>  <dbl> <chr> <fct>   
 1      1        1 Alle~ fema~ 29        0     0 24160  211.  B5    S       
 2      1        1 Alli~ male   0.92     1     2 113781 152.  C22 ~ S       
 3      1        0 Alli~ fema~  2        1     2 113781 152.  C22 ~ S       
 4      1        0 Alli~ male  30        1     2 113781 152.  C22 ~ S       
 5      1        0 Alli~ fema~ 25        1     2 113781 152.  C22 ~ S       
 6      1        1 Ande~ male  48        0     0 19952   26.6 E12   S       
 7      1        1 Andr~ fema~ 63        1     0 13502   78.0 D7    S       
 8      1        0 Andr~ male  39        0     0 112050   0   A36   S       
 9      1        1 Appl~ fema~ 53        2     0 11769   51.5 C101  S       
10      1        0 Arta~ male  71        0     0 PC 17~  49.5 <NA>  C       
# ... with 1,299 more rows, and 3 more variables: boat <chr>, body <int>,
#   home.dest <chr>
```

```r
# 특정 변수만 불러오기
titanic3 <- read_csv("dataset/titanic3.csv", 
                     col_types = cols_only(
                       pclass = col_integer(), 
                       survived = col_integer(), 
                       sex = col_factor(), 
                       age = col_double()
                     ))
titanic3
```

```
# A tibble: 1,309 x 4
   pclass survived sex      age
    <int>    <int> <fct>  <dbl>
 1      1        1 female 29   
 2      1        1 male    0.92
 3      1        0 female  2   
 4      1        0 male   30   
 5      1        0 female 25   
 6      1        1 male   48   
 7      1        1 female 63   
 8      1        0 male   39   
 9      1        1 female 53   
10      1        0 male   71   
# ... with 1,299 more rows
```

```r
# 대용량 데이터셋 읽어올 때 시간 비교
# install.packages("feather") # feather package
require(feather)
```

```
필요한 패키지를 로딩중입니다: feather
```

```r
system.time(pulse <- read.csv("dataset/pulse.csv", header = T))
```

```
 사용자  시스템 elapsed 
  19.97    0.00   19.99 
```

```r
write_feather(pulse, "dataset/pulse.feather")
system.time(pulse <- readRDS("output/pulse.rds"))
```

```
 사용자  시스템 elapsed 
   0.08    0.00    0.08 
```

```r
system.time(pulse <- read_csv("dataset/pulse.csv"))
```

```
Parsed with column specification:
cols(
  .default = col_double()
)
```

```
See spec(...) for full column specifications.
```

```
 사용자  시스템 elapsed 
  14.58    0.01   14.59 
```

```r
system.time(pulse <- read_feather("dataset/pulse.feather"))
```

```
 사용자  시스템 elapsed 
   0.30    0.00    0.29 
```

 \normalsize


### Excel 파일 입출력 {#import-export-excel}

- R에서 기본적으로 제공하는 파일 입출력 함수는 대부분 텍스트 파일(`*.txt`, `*.csv`, `*.tsv`^[tab separated values])을 대상으로 하고 있음
- **readr** 패키지에서도 이러한 원칙은 유지됨
- Excel 파일을 R로 읽어오기(과거 방법) 
   - `*.xls` 또는 `*.xlsx` 파일을 엑셀로 읽은 후 해당 데이터를 위 텍스트 파일 형태로 내보낸 후 해당 파일을 R로 읽어옴
   - **xlsx** 패키지 등을 이용해 엑셀 파일을 직접 읽어올 수 있으나, Java 기반으로 개발된 패키지이기 때문에 Java Runtime Environment를 운영체제에 설치해야만 작동

- 최근 tidyverse 중 하나인 **readxl** 패키지를 이용해 간편하게 R 작업환경에 엑셀 파일을 읽어오는 것이 가능(Hadley Wickham이 개발...)
   - tidyverse의 한 부분임에도 불구하고 tidyverse 패키지 번들에는 포함되어 있지 않기 때문에 별도 설치 필요
   
#### **readxl** 패키지 구성 주요 함수 {#readxl-funs .unnumbered}

- `read_xls()`, `read_xlsx()`, `read_excel`: 엑셀 파일을 읽어오는 함수로 각각 Excel 97 ~ 2003, Excel 2007 이상, 또는 버전 상관 없이 저장된 엑셀 파일에 접근함
- `excel_sheets()`: 엑셀 파일 내 시트 이름 추출 $\rightarrow$ 한 엑셀 파일의 복수 시트에 데이터가 저장되어 있는 경우 활용
- 예시: 2020년 4월 23일 COVID-19 유병률 데이터 ([Our World in Data](https://github.com/owid/covid-19-data/tree/master/public/data))

\footnotesize


```r
read_xlsx(
  path, # Excel 폴더 및 파일 이름
  sheet = NULL, # 불러올 엑셀 시트 이름
                # default = 첫 번째 시트
  col_names = TRUE, # read_csv()의 인수와 동일한 형태 입력
  col_types = NULL  # read_csv()의 인수와 동일한 형태 입력
)
```

 \normalsize



\footnotesize


```r
# 2020년 4월 21일자 COVID-19 국가별 유별률 및 사망률 집계 자료
# dataset/owid-covid-data.xlsx 파일 불러오기 
# install.packages("readxl")
require(readxl)
```

```
필요한 패키지를 로딩중입니다: readxl
```

```r
covid19 <- read_xlsx("dataset/owid-covid-data.xlsx")
covid19
```

```
# A tibble: 12,669 x 16
   iso_code location date  total_cases new_cases total_deaths new_deaths
   <chr>    <chr>    <chr>       <dbl>     <dbl>        <dbl>      <dbl>
 1 ABW      Aruba    2020~           2         2            0          0
 2 ABW      Aruba    2020~           4         2            0          0
 3 ABW      Aruba    2020~          12         8            0          0
 4 ABW      Aruba    2020~          17         5            0          0
 5 ABW      Aruba    2020~          19         2            0          0
 6 ABW      Aruba    2020~          28         9            0          0
 7 ABW      Aruba    2020~          28         0            0          0
 8 ABW      Aruba    2020~          28         0            0          0
 9 ABW      Aruba    2020~          50        22            0          0
10 ABW      Aruba    2020~          55         5            0          0
# ... with 12,659 more rows, and 9 more variables:
#   total_cases_per_million <dbl>, new_cases_per_million <dbl>,
#   total_deaths_per_million <dbl>, new_deaths_per_million <dbl>,
#   total_tests <dbl>, new_tests <dbl>, total_tests_per_thousand <dbl>,
#   new_tests_per_thousand <dbl>, tests_units <chr>
```

```r
# 여러 시트를 동시에 불러올 경우
# dataset/datR4CTDA.xlsx 의 모든 시트 불러오기
path <- "dataset/datR4CTDA.xlsx"
sheet_name <- excel_sheets(path)
dL <- lapply(sheet_name, function(x) read_xlsx(path, sheet = x))
names(dL) <- sheet_name

# Tidyverse 에서는? (맛보기)
path %>% 
  excel_sheets %>% 
  set_names %>% 
  map(~read_xlsx(path = path, sheet = .x)) -> dL2
```

 \normalsize


### tibble 패키지 {#tibble}

- **readr** 또는 **readxl** 패키지에서 제공하는 함수를 이용해 외부 데이터를 읽어온 후, 확인할 때 기존 데이터 프레임과 미묘한 차이점이 있다는 것을 확인
- 프린트된 데이터의 맨 윗 부분을 보면 `A tibble: 데이터 차원` 이 표시된 부분을 볼 수 있음
- `tibble`은 tidyverse 생태계에서 사용되는 데이터 프레임 $\rightarrow$ 데이터 프레임을 조금 더 빠르고 사용하기 쉽게 수정한 버전의 데이터 프레임

#### tibble 생성하기 {#create-tibble .unnumbered}

- 기본 R 함수에서 제공하는 `as.*` 계열 함수 처럼 `as_tibble()` 함수를 통해 기존 일반적인 형태의 데이터 프레임을 tibble 로 변환 가능

\footnotesize


```r
head(iris)
```

```
  Sepal.Length Sepal.Width Petal.Length Petal.Width Species
1          5.1         3.5          1.4         0.2  setosa
2          4.9         3.0          1.4         0.2  setosa
3          4.7         3.2          1.3         0.2  setosa
4          4.6         3.1          1.5         0.2  setosa
5          5.0         3.6          1.4         0.2  setosa
6          5.4         3.9          1.7         0.4  setosa
```

```r
as_tibble(iris)
```

```
# A tibble: 150 x 5
   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
          <dbl>       <dbl>        <dbl>       <dbl> <fct>  
 1          5.1         3.5          1.4         0.2 setosa 
 2          4.9         3            1.4         0.2 setosa 
 3          4.7         3.2          1.3         0.2 setosa 
 4          4.6         3.1          1.5         0.2 setosa 
 5          5           3.6          1.4         0.2 setosa 
 6          5.4         3.9          1.7         0.4 setosa 
 7          4.6         3.4          1.4         0.3 setosa 
 8          5           3.4          1.5         0.2 setosa 
 9          4.4         2.9          1.4         0.2 setosa 
10          4.9         3.1          1.5         0.1 setosa 
# ... with 140 more rows
```

 \normalsize

- 개별 벡터로부터 tibble 생성 가능
- 방금 생성한 변수 참조 가능
- 문자형 변수가 입력된 경우 데이터 프레임과 다르게 별다른 옵션이 없어도 강제로 factor로 형 변환을 하지 않음

\footnotesize


```r
# 벡터로부터 tibble 객체 생성
tibble(x = letters, y = rnorm(26), z = y^2)
```

```
# A tibble: 26 x 3
   x          y      z
   <chr>  <dbl>  <dbl>
 1 a     -0.514 0.265 
 2 b      1.67  2.80  
 3 c     -0.176 0.0309
 4 d     -0.628 0.394 
 5 e      1.68  2.83  
 6 f     -0.428 0.183 
 7 g     -0.721 0.519 
 8 h      0.784 0.615 
 9 i     -0.976 0.953 
10 j     -0.531 0.282 
# ... with 16 more rows
```

```r
# 데이터 프레임으로 위와 동일하게 적용하면?
data.frame(x = letters, y = rnorm(26), z = y^2)
```

```
Error in data.frame(x = letters, y = rnorm(26), z = y^2): 객체 'y'를 찾을 수 없습니다
```

```r
# 벡터의 길이가 다른 경우
# 길이가 1인 벡터는 재사용 가능
tibble(x = 1, y = rep(0:1, each = 4), z = 2)
```

```
# A tibble: 8 x 3
      x     y     z
  <dbl> <int> <dbl>
1     1     0     2
2     1     0     2
3     1     0     2
4     1     0     2
5     1     1     2
6     1     1     2
7     1     1     2
8     1     1     2
```

```r
# 데이터 프레임과 마찬가지로 비정상적 문자를 변수명으로 사용 가능
# 역따옴표(``) 
tibble(`2000` = "year", 
       `:)` = "smile", 
       `:(` = "sad")
```

```
# A tibble: 1 x 3
  `2000` `:)`  `:(` 
  <chr>  <chr> <chr>
1 year   smile sad  
```

 \normalsize

- `tribble()` 함수 사용: transposed (전치된) tibble의 약어로 데이터를 직접 입력 시 유용

\footnotesize


```r
tribble(
   ~x, ~y,   ~z,
  "M", 172,  69,
  "F", 156,  45, 
  "M", 165,  73, 
)
```

```
# A tibble: 3 x 3
  x         y     z
  <chr> <dbl> <dbl>
1 M       172    69
2 F       156    45
3 M       165    73
```

 \normalsize

#### `tibble()`과 `data.frame()`의 차이점 {#diff-tibble-df .unnumbered}

- 가장 큰 차이점은 데이터 처리의 속도 및 데이터의 프린팅 
- tibble이 데이터 프레임 보다 간결하고 많은 정보 확인 가능
- `str()`에서 확인할 수 있는 데이터 유형 확인 가능

\footnotesize


```r
head(iris)
```

```
  Sepal.Length Sepal.Width Petal.Length Petal.Width Species
1          5.1         3.5          1.4         0.2  setosa
2          4.9         3.0          1.4         0.2  setosa
3          4.7         3.2          1.3         0.2  setosa
4          4.6         3.1          1.5         0.2  setosa
5          5.0         3.6          1.4         0.2  setosa
6          5.4         3.9          1.7         0.4  setosa
```

```r
dd <- as_tibble(iris)
dd
```

```
# A tibble: 150 x 5
   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
          <dbl>       <dbl>        <dbl>       <dbl> <fct>  
 1          5.1         3.5          1.4         0.2 setosa 
 2          4.9         3            1.4         0.2 setosa 
 3          4.7         3.2          1.3         0.2 setosa 
 4          4.6         3.1          1.5         0.2 setosa 
 5          5           3.6          1.4         0.2 setosa 
 6          5.4         3.9          1.7         0.4 setosa 
 7          4.6         3.4          1.4         0.3 setosa 
 8          5           3.4          1.5         0.2 setosa 
 9          4.4         2.9          1.4         0.2 setosa 
10          4.9         3.1          1.5         0.1 setosa 
# ... with 140 more rows
```

 \normalsize



<!-- ## `dplyr` 패키지 {#dplyr} -->

<!-- ### `%>%` {#pipe-op} -->

<!-- ### `select()` {#dplyr-select} -->

<!-- ### `filter()` {#dplyr-filter} -->

<!-- ### `arrange()`{#dplyr-arrange} -->

<!-- ### `rename()` {#dplyr-rename} -->

<!-- ### `mutate()` {#dplyr-mutate} -->

<!-- ### `group_by()` {#dplyr-group-by} -->




<!-- ## 데이터 변환 {#data-transform} -->

<!-- ## 반복 계산 {#iteration} -->



