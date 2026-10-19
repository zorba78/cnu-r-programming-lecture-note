# Gapminder 2015년 거품 그림 코드 요청 (13장 "AI와 함께")

- 모델: Claude Sonnet 5.5 (복구한 student-ai 기록의 표기)
- 날짜: 2026-10-16
- 호출 방법: Claude student-ai 워커가 도구 없이 한 번에 응답한 기존 기록을 복구했다. Codex는 재호출하지 않고 원문을 이관했다.
- 쓰인 곳: `13-data-visualization.qmd`의 @sec-ai-visualization. 생성 코드는 파일 경로 네 곳에 `dataset/ch12/` 만 덧붙여 한 청크로 실행한다(12장 방식, 2026-10-17 변경).
- 복구 원본: `/home/user/.claude/jobs/5f9e4386/tmp/ai-13-gapminder-bubble-2015.md`

## 학생 요청 (프롬프트 전문)

````text
통계 수업 과제로 Gapminder 자료를 가지고 그림을 그리려고 해. R tidyverse(ggplot2)를 쓸 거고 파일은 네 개야.

1) gapminder-population.csv : 나라별 연도별 인구 (2000~2020년)
"geo","name","year","population"
"afg","Afghanistan",2000,20779957
"afg","Afghanistan",2001,21606992
"afg","Afghanistan",2002,22600774
"afg","Afghanistan",2003,23680871

2) gapminder-gdp.csv : 나라별 연도별 GDP (구매력평가 기준, 2011년 불변 국제달러)
"geo","name","year","gdp_total"
"afg","Afghanistan",2000,14265982427
"afg","Afghanistan",2001,13965937903
"afg","Afghanistan",2002,22967932809
"afg","Afghanistan",2003,24996520016

3) gapminder-life-expectancy.csv : 나라별 연도별 기대수명
"geo","name","year","life_expectancy"
"afg","Afghanistan",2000,54.63
"afg","Afghanistan",2001,54.76
"afg","Afghanistan",2002,55.65
"afg","Afghanistan",2003,56.36

4) gapminder-regions.csv : 나라별 지역 구분
"iso","country","region"
"AFG","Afghanistan","Southern Asia"
"ALB","Albania","Southern Europe"
"DZA","Algeria","Northern Africa"
"ASM","American Samoa","Polynesia Oceania"

2015년 자료로 거품 그림을 그리고 싶어. 나라 하나가 점 하나이고, x축은 1인당 GDP(로그 축), y축은 기대수명이야. 점 크기는 인구에 비례하게 하고, 색은 대륙으로 구분해 줘. 대륙은 아프리카, 아메리카, 아시아, 유럽, 오세아니아 다섯 개야. 코드 짜 줘.
````

## 응답 (원문 그대로)

````markdown
네 개 파일을 합쳐서 2015년 거품 그림을 그리는 코드야. 주의할 점이 두 가지 있어.

- `gapminder-regions.csv`의 `region`은 "Southern Asia", "Polynesia Oceania" 같은 세부 지역이야. 아프리카, 아메리카, 아시아, 유럽, 오세아니아 다섯 대륙이 아니라서 직접 묶어야 해.
- 나라 코드는 앞의 세 파일에서는 소문자(`afg`), regions 파일에서는 대문자(`AFG`)야. 나라 이름은 파일마다 다르게 적혀 있을 수 있어서 이름이 아니라 코드로 합쳐야 해.

```r
library(tidyverse)
library(scales)

# 1. 자료 읽기
pop    <- read_csv("gapminder-population.csv")
gdp    <- read_csv("gapminder-gdp.csv")
life   <- read_csv("gapminder-life-expectancy.csv")
region <- read_csv("gapminder-regions.csv")

# 2. 세부 지역 -> 5개 대륙으로 묶기
region <- region %>%
  mutate(
    continent = case_when(
      str_detect(region, "Oceania|Australia|Melanesia|Micronesia|Polynesia") ~ "오세아니아",
      str_detect(region, "Africa")                                           ~ "아프리카",
      str_detect(region, "America|Caribbean")                                ~ "아메리카",
      str_detect(region, "Europe")                                           ~ "유럽",
      str_detect(region, "Asia")                                             ~ "아시아",
      TRUE                                                                   ~ NA_character_
    ),
    geo = str_to_lower(iso)   # 다른 파일의 geo(소문자)와 맞추기
  ) %>%
  select(geo, continent)

# 분류되지 않은 지역이 있는지 확인 (NA가 나오면 case_when 규칙을 보완)
region %>% count(continent)

# 3. 2015년 자료만 뽑아서 합치기
df <- pop %>%
  filter(year == 2015) %>%
  select(geo, name, population) %>%
  left_join(gdp  %>% filter(year == 2015) %>% select(geo, gdp_total),       by = "geo") %>%
  left_join(life %>% filter(year == 2015) %>% select(geo, life_expectancy), by = "geo") %>%
  left_join(region, by = "geo") %>%
  mutate(
    gdp_per_capita = gdp_total / population,   # 1인당 GDP
    continent = factor(continent,
                       levels = c("아프리카", "아메리카", "아시아", "유럽", "오세아니아"))
  )

# 합치는 과정에서 빠진 나라 확인
df %>% filter(if_any(c(gdp_per_capita, life_expectancy, continent), is.na))

df <- df %>% drop_na(gdp_per_capita, life_expectancy, continent)

# 4. 거품 그림
ggplot(df, aes(x = gdp_per_capita, y = life_expectancy,
               size = population, fill = continent)) +
  geom_point(shape = 21, color = "white", alpha = 0.8) +
  scale_x_log10(labels = label_dollar(accuracy = 1),
                breaks = c(1000, 2000, 4000, 8000, 16000, 32000, 64000)) +
  scale_size_area(max_size = 20,                    # 면적이 인구에 비례
                  breaks = c(1e7, 1e8, 5e8, 1e9),
                  labels = label_number(scale_cut = cut_short_scale()),
                  name = "인구") +
  scale_fill_brewer(palette = "Set1", name = "대륙") +
  guides(fill = guide_legend(override.aes = list(size = 5))) +
  labs(
    title    = "1인당 GDP와 기대수명 (2015년)",
    subtitle = "점 하나는 나라 하나, 점의 면적은 인구에 비례",
    x = "1인당 GDP (PPP, 2011년 불변 국제달러, 로그 축)",
    y = "기대수명 (세)",
    caption = "자료: Gapminder"
  ) +
  theme_minimal(base_size = 13)
```

코드에서 짚어 둘 부분은 다음과 같아.

- **점 크기**: `scale_size_area()`를 쓰면 점의 면적이 인구에 비례해. 기본값인 `scale_size()`는 크기를 임의로 늘려서 인구가 큰 나라가 실제보다 작거나 크게 보일 수 있어서 이 그림에는 맞지 않아.
- **`shape = 21`**: 테두리가 있는 점이라 `fill`로 색을 주고 흰 테두리를 둘렀어. 점이 겹쳐도 구분이 잘 돼.
- **점 그리는 순서**: 중국과 인도 같은 큰 점이 작은 점을 덮을 수 있어. 그러면 `df <- df %>% arrange(desc(population))`을 그리기 전에 넣어서 큰 점부터 그리게 해.
- **`count(continent)`**: 이 확인은 꼭 해 봐. 내가 regions 파일의 모든 `region` 값을 본 것은 아니라서, `NA`가 나오면 그 지역명을 `case_when`에 추가해야 해. 지역명은 `region %>% distinct(region)`으로 볼 수 있어.
- **합치고 남은 결측치**: 파일마다 들어 있는 나라가 조금씩 달라서 `drop_na()` 앞에서 빠지는 나라가 몇 개 나올 수 있어. 어떤 나라가 빠지는지 확인해서 과제 설명에 적어 두면 좋아.
````
