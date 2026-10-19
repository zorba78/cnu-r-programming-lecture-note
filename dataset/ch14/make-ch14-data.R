# 14장 기초통계 분석 연습 파일 생성 스크립트
#
#   Rscript dataset/ch14/make-ch14-data.R      (프로젝트 폴더에서 실행)
#
# 만드는 파일
#   sleep-drug.csv  수면제 두 종류(A, B)를 먹었을 때 평소보다 늘어난 수면 시간. 한 행 = 환자 한 명이 약 하나를
#                   먹은 기록 (20행)
#
# 출처와 성격
#   값은 R 의 datasets::sleep (Cushny & Peebles, 1905 의 수면제 자료. Student, 1908 이 인용) 을 그대로 쓴다.
#   바꾼 것은 두 가지다.
#     1. 열 이름을 한국어로 바꾸었다: ID -> 환자번호("P01"~"P10"), group -> 약("A", "B"), extra -> 수면증가
#     2. 약 B 행의 순서를 set.seed(2026) 로 섞었다. 값은 실제 자료이고, **행 순서(약 B 의 기록 순서)는 가상**이다.
#   교육용 연습 파일이다.
#
# 일부러 넣어 둔 함정 (강의노트 14장 8절 "AI와 함께"에서 다룬다)
#   1. 같은 환자 10명이 두 약을 모두 먹었다(대응 표본). 그런데 파일 앞 5줄에는 약 A 행만 보여
#      환자번호가 두 번씩 나온다는 사실이 드러나지 않는다. 자료 구조는 count(환자번호) 로 확인해야 한다.
#   2. 약 B 행(12~21줄)이 환자번호 순서가 아니다. 수면증가[약 == "A"] 와 수면증가[약 == "B"] 를 위치로
#      짝 지어 paired = TRUE 를 주면 다른 환자끼리 짝이 지어지고, 오류도 경고도 나지 않는다.
#      짝은 환자번호(키)로 맞춰야 한다.

out <- "dataset/ch14"
# 프로젝트 폴더에서 실행했는지 확인한다. dataset/ch14 안에서 실행하면 상대 경로가 한 번 더 붙어
# dataset/ch14/dataset/ch14/ 에 사본이 생긴다(14장 노트 검수에서 발견).
if (!dir.exists(out)) stop("프로젝트 폴더에서 실행해야 한다: Rscript dataset/ch14/make-ch14-data.R")


# ---- 1. sleep 의 값을 옮기고 열 이름을 바꾼다 ------------------------------------------

drug <- data.frame(
  환자번호 = sprintf("P%02d", as.integer(datasets::sleep$ID)),
  약 = c("A", "B")[as.integer(datasets::sleep$group)],
  수면증가 = datasets::sleep$extra
)


# ---- 2. 약 A 는 환자번호 순서, 약 B 는 섞은 순서로 ---------------------------------------

drug_a <- drug[drug$약 == "A", ]
drug_b <- drug[drug$약 == "B", ]

set.seed(2026)
o <- sample(10)                    # 9 1 6 5 3 4 7 10 8 2
drug_b <- drug_b[o, ]

sleep_drug <- rbind(drug_a, drug_b)
rownames(sleep_drug) <- NULL

# 문자열과 머리글에 큰따옴표가 붙는다(12장 연습 파일과 같은 형식).
write.csv(sleep_drug, file.path(out, "sleep-drug.csv"), row.names = FALSE, fileEncoding = "UTF-8")


# ---- 3. 정답 값 확인 (설계서 5절의 표와 대조) ------------------------------------------

chk <- read.csv(file.path(out, "sleep-drug.csv"), fileEncoding = "UTF-8")

cat("앞 5줄\n")
writeLines(readLines(file.path(out, "sleep-drug.csv"), n = 5, encoding = "UTF-8"))

cat("\n약 B 의 환자번호 순서:", chk$환자번호[chk$약 == "B"], "\n")
cat("행 수 / 환자 수 / 환자당 행:", nrow(chk), "/", length(unique(chk$환자번호)), "/",
    paste(unique(table(chk$환자번호)), collapse = ","), "\n")
cat("약 A 합계, 평균:", sum(chk$수면증가[chk$약 == "A"]), mean(chk$수면증가[chk$약 == "A"]), "\n")
cat("약 B 합계, 평균:", sum(chk$수면증가[chk$약 == "B"]), mean(chk$수면증가[chk$약 == "B"]), "\n")

# 환자번호로 짝을 맞춘 쌍체 t 검정 (B - A)
a <- chk[chk$약 == "A", ]
b <- chk[chk$약 == "B", ]
b <- b[match(a$환자번호, b$환자번호), ]
key <- t.test(b$수면증가, a$수면증가, paired = TRUE)
cat(sprintf("키로 짝 지은 쌍체 (B - A): t = %.3f, 자유도 %d, p = %.5f, 95%% CI (%.3f, %.3f)\n",
            key$statistic, key$parameter, key$p.value, key$conf.int[1], key$conf.int[2]))

# 파일 순서대로 위치로 짝 지은 쌍체 t 검정 (A - B)
pos <- t.test(chk$수면증가[chk$약 == "A"], chk$수면증가[chk$약 == "B"], paired = TRUE)
cat(sprintf("위치로 짝 지은 쌍체 (A - B): t = %.3f, 자유도 %d, p = %.4f\n",
            pos$statistic, pos$parameter, pos$p.value))

# 독립 이표본
ind <- t.test(수면증가 ~ 약, data = chk, var.equal = TRUE)
wel <- t.test(수면증가 ~ 약, data = chk)
cat(sprintf("독립 이표본 (등분산): t = %.3f, 자유도 %d, p = %.4f\n",
            ind$statistic, ind$parameter, ind$p.value))
cat(sprintf("독립 이표본 (Welch): 자유도 %.2f, p = %.4f\n", wel$parameter, wel$p.value))
