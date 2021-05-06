---
output: html_document
editor_options: 
  chunk_output_type: console
---
\mainmatter




# R 외부 데이터 입출력


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



## **텍스트 파일 입출력** {#text-import-export}


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

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["Subject"],"name":[1],"type":["int"],"align":["right"]},{"label":["TRT"],"name":[2],"type":["chr"],"align":["left"]},{"label":["DBP1"],"name":[3],"type":["int"],"align":["right"]},{"label":["DBP2"],"name":[4],"type":["int"],"align":["right"]},{"label":["DBP3"],"name":[5],"type":["int"],"align":["right"]},{"label":["DBP4"],"name":[6],"type":["int"],"align":["right"]},{"label":["DBP5"],"name":[7],"type":["int"],"align":["right"]},{"label":["Age"],"name":[8],"type":["int"],"align":["right"]},{"label":["Sex"],"name":[9],"type":["chr"],"align":["left"]}],"data":[{"1":"1","2":"A","3":"114","4":"115","5":"113","6":"109","7":"105","8":"43","9":"F","_rn_":"1"},{"1":"2","2":"A","3":"116","4":"113","5":"112","6":"103","7":"101","8":"51","9":"M","_rn_":"2"},{"1":"3","2":"A","3":"119","4":"115","5":"113","6":"104","7":"98","8":"48","9":"F","_rn_":"3"},{"1":"4","2":"A","3":"115","4":"113","5":"112","6":"109","7":"101","8":"42","9":"F","_rn_":"4"},{"1":"5","2":"A","3":"116","4":"112","5":"107","6":"104","7":"105","8":"49","9":"M","_rn_":"5"},{"1":"6","2":"A","3":"117","4":"112","5":"113","6":"104","7":"102","8":"47","9":"M","_rn_":"6"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

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
 $ location: chr  "Buckingham" "Buckingham" "Buckingham" "Buckingham" ...
 $ age     : int  46 29 58 67 64 34 30 37 45 55 ...
 $ gender  : chr  "female" "female" "female" "male" ...
 $ height  : int  62 64 61 67 68 71 69 59 69 63 ...
 $ weight  : int  121 218 256 119 183 190 191 170 166 202 ...
 $ frame   : chr  "medium" "large" "large" "large" ...
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

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["id"],"name":[1],"type":["int"],"align":["right"]},{"label":["chol"],"name":[2],"type":["int"],"align":["right"]},{"label":["stab.glu"],"name":[3],"type":["int"],"align":["right"]},{"label":["hdl"],"name":[4],"type":["int"],"align":["right"]},{"label":["ratio"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["glyhb"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["location"],"name":[7],"type":["chr"],"align":["left"]},{"label":["age"],"name":[8],"type":["int"],"align":["right"]},{"label":["gender"],"name":[9],"type":["chr"],"align":["left"]},{"label":["height"],"name":[10],"type":["int"],"align":["right"]},{"label":["weight"],"name":[11],"type":["int"],"align":["right"]},{"label":["frame"],"name":[12],"type":["chr"],"align":["left"]},{"label":["bp.1s"],"name":[13],"type":["int"],"align":["right"]},{"label":["bp.1d"],"name":[14],"type":["int"],"align":["right"]},{"label":["bp.2s"],"name":[15],"type":["int"],"align":["right"]},{"label":["bp.2d"],"name":[16],"type":["int"],"align":["right"]},{"label":["waist"],"name":[17],"type":["int"],"align":["right"]},{"label":["hip"],"name":[18],"type":["int"],"align":["right"]},{"label":["time.ppn"],"name":[19],"type":["int"],"align":["right"]}],"data":[{"1":"1000","2":"203","3":"82","4":"56","5":"3.6","6":"4.31","7":"Buckingham","8":"46","9":"female","10":"62","11":"121","12":"medium","13":"118","14":"59","15":"NA","16":"NA","17":"29","18":"38","19":"720","_rn_":"1"},{"1":"1001","2":"165","3":"97","4":"24","5":"6.9","6":"4.44","7":"Buckingham","8":"29","9":"female","10":"64","11":"218","12":"large","13":"112","14":"68","15":"NA","16":"NA","17":"46","18":"48","19":"360","_rn_":"2"},{"1":"1002","2":"228","3":"92","4":"37","5":"6.2","6":"4.64","7":"Buckingham","8":"58","9":"female","10":"61","11":"256","12":"large","13":"190","14":"92","15":"185","16":"92","17":"49","18":"57","19":"180","_rn_":"3"},{"1":"1003","2":"78","3":"93","4":"12","5":"6.5","6":"4.63","7":"Buckingham","8":"67","9":"male","10":"67","11":"119","12":"large","13":"110","14":"50","15":"NA","16":"NA","17":"33","18":"38","19":"480","_rn_":"4"},{"1":"1005","2":"249","3":"90","4":"28","5":"8.9","6":"7.72","7":"Buckingham","8":"64","9":"male","10":"68","11":"183","12":"medium","13":"138","14":"80","15":"NA","16":"NA","17":"44","18":"41","19":"300","_rn_":"5"},{"1":"1008","2":"248","3":"94","4":"69","5":"3.6","6":"4.81","7":"Buckingham","8":"34","9":"male","10":"71","11":"190","12":"large","13":"132","14":"86","15":"NA","16":"NA","17":"36","18":"42","19":"195","_rn_":"6"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

 \normalsize


\footnotesize


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

# CP949로 읽어오기
herb <- read.table("dataset/herb_dic_sample.txt", sep = "\t", 
                   header = TRUE, 
                   encoding = "CP949", 
                   stringsAsFactors = FALSE)
head(herb)
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

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["AGE"],"name":[1],"type":["int"],"align":["right"]},{"label":["SEX"],"name":[2],"type":["int"],"align":["right"]},{"label":["SMOKSTAT"],"name":[3],"type":["int"],"align":["right"]},{"label":["QUETELET"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["VITUSE"],"name":[5],"type":["int"],"align":["right"]},{"label":["CALORIES"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["FAT"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["FIBER"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["ALCOHOL"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["CHOLESTEROL"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["BETADIET"],"name":[11],"type":["int"],"align":["right"]},{"label":["RETDIET"],"name":[12],"type":["int"],"align":["right"]},{"label":["BETAPLASMA"],"name":[13],"type":["int"],"align":["right"]},{"label":["RETPLASMA"],"name":[14],"type":["int"],"align":["right"]}],"data":[{"1":"64","2":"2","3":"2","4":"21.48380","5":"1","6":"1298.8","7":"57.0","8":"6.3","9":"0.0","10":"170.3","11":"1945","12":"890","13":"200","14":"915","_rn_":"1"},{"1":"76","2":"2","3":"1","4":"23.87631","5":"1","6":"1032.5","7":"50.1","8":"15.8","9":"0.0","10":"75.8","11":"2653","12":"451","13":"124","14":"727","_rn_":"2"},{"1":"38","2":"2","3":"2","4":"20.01080","5":"2","6":"2372.3","7":"83.6","8":"19.1","9":"14.1","10":"257.9","11":"6321","12":"660","13":"328","14":"721","_rn_":"3"},{"1":"40","2":"2","3":"2","4":"25.14062","5":"3","6":"2449.5","7":"97.5","8":"26.5","9":"0.5","10":"332.6","11":"1061","12":"864","13":"153","14":"615","_rn_":"4"},{"1":"72","2":"2","3":"1","4":"20.98504","5":"1","6":"1952.1","7":"82.6","8":"16.2","9":"0.0","10":"170.8","11":"2863","12":"1209","13":"92","14":"799","_rn_":"5"},{"1":"40","2":"2","3":"2","4":"27.52136","5":"3","6":"1366.9","7":"56.0","8":"9.6","9":"1.3","10":"154.6","11":"1729","12":"1439","13":"148","14":"654","_rn_":"6"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

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


## R 바이너리(binary) 파일 입출력 {#binary-import-export}

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
 [5] "diab"           "hook_output"    "input1"         "input2"        
 [9] "plasma"         "varname"       
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
 [5] "diab"           "hook_output"    "input1"         "input2"        
 [9] "plasma"         "varname"       
```

```r
# dnp, plasma 데이터만 output 폴더에 sub_obj.Rdata로 저장
save(dbp, plasma, file = "output/sub_obj.Rdata")
rm(list = c("dbp", "plasma"))
ls()
```

```
[1] "codebook"       "dbp2"           "def.chunk.hook" "diab"          
[5] "hook_output"    "input1"         "input2"         "varname"       
```

```r
# sub_obj.Rdata 파일 불러오기
load("output/sub_obj.Rdata")
ls()
```

```
 [1] "codebook"       "dbp"            "dbp2"           "def.chunk.hook"
 [5] "diab"           "hook_output"    "input1"         "input2"        
 [9] "plasma"         "varname"       
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
  4.611   0.024   4.637 
```

```r
# saveRDS()함수를 이용해 output/pulse.rds 파일로 저장
saveRDS(pulse, "output/pulse.rds")
rm(pulse); ls()
```

```
 [1] "codebook"       "dbp"            "dbp2"           "def.chunk.hook"
 [5] "diab"           "hook_output"    "input1"         "input2"        
 [9] "plasma"         "varname"       
```

```r
system.time(pulse <- readRDS("output/pulse.rds"))
```

```
 사용자  시스템 elapsed 
  0.079   0.000   0.078 
```

 \normalsize



## Excel 파일 입출력 {#import-export-excel}

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
covid19 <- read_xlsx("dataset/covid-19-dataset/owid-covid-data.xlsx")
covid19
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
  </script>
</div>

```r
# 여러 시트를 동시에 불러올 경우
# dataset/datR4CTDA.xlsx 의 모든 시트 불러오기
path <- "dataset/datR4CTDA.xlsx"
sheet_name <- excel_sheets(path)
dL <- lapply(sheet_name, function(x) read_xlsx(path, sheet = x))
names(dL) <- sheet_name
```

 \normalsize


