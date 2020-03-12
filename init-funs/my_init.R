## 0.1. Load required packages for data preprocessing ####
require(MASS)
require(reshape2); require(plyr)
require(tidyverse)
require(stringr); require(lubridate)
require(readxl)
require(tidyselect)
require(tidystats)

# 0.2. Initialization ####
# rm(list = ls())
# gc()

## 0.2. Load Functions, make several functions to escape the duplication #####
dselect <- dplyr::select
# source("../../global/misc_fun.R", encoding = "UTF-8")
