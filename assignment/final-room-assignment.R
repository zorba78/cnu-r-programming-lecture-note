#---------------------------------------------------------------------------------------------------------------------------------#
# 기말고사 강의실(실습실) 배정 script
#---------------------------------------------------------------------------------------------------------------------------------#
require(tidyverse)
require(readxl)

student <- read_excel("dataset/StudentList.xls")
n <- nrow(student)
set.seed(20200526)
splt_room <- split(sample(1:n), 1:2)
room <- character(n)
room[splt_room[[1]]] <- "2327"
room[splt_room[[2]]] <- "2431"

student %>%
  mutate(시험장소 = room) -> student

write.table(student, "dataset/room-allocation.txt", sep = "\t", row.names = F)

                 