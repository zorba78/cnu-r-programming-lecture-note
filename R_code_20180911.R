
###############################################
#   한의학연구원_data analysisi (2018.09.11)  #
#                                             #
###############################################


rm(list = ls())

#  install.packages(c("randomForest","glmnet"))
#  install.packages("ROCR")


library(randomForest)
library(gbm)
library(MASS)
library(glmnet) 
library(xgboost)
library(mlr)
library(dplyr)

library(ROCR)


setwd("I:/SecureUSB_backup_20171207/개인용무_2018/한국한의학연구원/한국한의학연구원_자료/R_analysis_20180911")

source("CVSample.R")  # CV_pr(y,K,type,seed)


#######################################
#    INCLUSION 상관없이               #
#######################################
#######################################
#    Data Setting                     #
#######################################

DM_rawdata <- read.csv("DM.csv", stringsAsFactors = FALSE, header=T)
EEG_rawdata <-read.csv("EEG.csv", stringsAsFactors = FALSE, header=T) 
SP_rawdata <-read.csv("SP.csv", stringsAsFactors = FALSE, header=T) 
SA_rawdata <-read.csv("SA.csv", stringsAsFactors = FALSE, header=T) 

dim(DM_rawdata); dim(EEG_rawdata); dim(SP_rawdata); dim(SA_rawdata)
#[1] 155  15
#[1] 155  24
#[1] 149  17
#[1] 145  12

names(DM_rawdata)
# [1] "USUBJID"   "SUBJID"    "SITEID"    "BIRTH"     "INVDAT"    "AGEF"      "AGEKR"     "SEX"      
# [9] "DSYN"      "EDULEV"    "SYSBP"     "DIABP"     "MMSE"      "GDS"       "INCLUSION"
names(EEG_rawdata)

glimpse(DM_rawdata)

DMEEG <-merge(DM_rawdata, EEG_rawdata, by = "USUBJID", all.x=T )
names(DMEEG)
dim(DMEEG)

DMEEGSP <-merge(DMEEG, SP_rawdata, by = "USUBJID", all.x=T )
names(DMEEGSP)
dim(DMEEGSP)

DMEEGSPSA <-merge(DMEEGSP, SA_rawdata, by = "USUBJID", all.x=T )
names(DMEEGSPSA)
dim(DMEEGSPSA)

##############################################
###########   setting   ######################
##############################################
##############################################



##############################################
#  0. DM 3 var                               #
##############################################

DDDD <- DM_rawdata
DDDD$SEX_adj <- (DDDD$SEX==1)*1
ok <- complete.cases(DDDD$EDULEV)
Data <-DDDD[ok, ]
dim(Data)  # [1] 154  16
glimpse(Data)


markers <-c("AGEF","SEX_adj","EDULEV")
dim(Data)   
 #y ratio [1] 0.3506494



##############################################
#  1.  EEG  7 var                            #
##############################################
names(EEG_rawdata)
Data <- DMEEGSPSA


markers <-c("PEAKMEF", "theta_avg","alpha_avg" ,         
             "beta_avg","gamma_avg","alpha_theta_ratio","diff_alpha_theta_LR" )

dim(Data)   
# y ratio # [1] 0.3483871

##############################################
# 2. SA   4 var                            #
##############################################
names(SA_rawdata)
head(SA_rawdata)
tmp <- SA_rawdata[, 1:2]
names(tmp) <- c("USUBJID","SA_INCYN")
DD <-merge(DMEEGSPSA, tmp, by = "USUBJID", all.x=T )
DDD <-DD[DD$SA_INCYN=="Y", ]
dim(DDD)
glimpse(DDD)
ok <- complete.cases(DDD$USUBJID)

Data <-DDD[ok, ]
dim(Data)
# [1] 144  66
markers <-c("error_percentile" ,"error_weighted_percentile", "diff_odd_bg","error_wp_resptime")

glimpse(Data)
# y ratio # # [1] 0.3263889

##############################################
# 3. EEG All var                             #
##############################################
names(EEG_rawdata)
head(EEG_rawdata)
Data <- DMEEGSPSA
# [1] 155  65

markers <-c("PEAKMEF" ,           
             "PEAKFRQ","PEAKPWR","THETALB","ALPHALB" ,           
            "LBETALB","MBETALB","HBETALB","GAMMALB"  ,          
            "THETARB","ALPHARB","LBETARB","MBETARB"  ,          
            "HBETARB","GAMMARB","theta_avg","alpha_avg" ,         
           "beta_avg","gamma_avg","alpha_theta_ratio" ,  "diff_alpha_theta_LR" )

dim(Data)   
# y ratio # [1] 0.3483871

##############################################
# 4. SA   all var                            #
##############################################
names(SA_rawdata)
head(SA_rawdata)
tmp <- SA_rawdata[, 1:2]
names(tmp) <- c("USUBJID","SA_INCYN")
DD <-merge(DMEEGSPSA, tmp, by = "USUBJID", all.x=T )
DDD <-DD[DD$SA_INCYN=="Y", ]
dim(DDD)
glimpse(DDD)
ok <- complete.cases(DDD$USUBJID)

Data <-DDD[ok, ]
dim(Data)
# [1] 144  66
markers <-c("FRQCRT","FRQERR","RESPTIME"  ,               
            "BKERPMAX","ODERPMAX",
            "error_percentile" ,"error_weighted_percentile", "diff_odd_bg","error_wp_resptime")

glimpse(Data)
# y ratio # # [1] 0.3263889

##############################################
#   5.  SP   all var                         #
##############################################
names(SP_rawdata)
head(SP_rawdata)
tmp <- SP_rawdata[, 1:2]
names(tmp) <- c("USUBJID","SP_INCYN")
DD <-merge(DMEEGSPSA, tmp, by = "USUBJID", all.x=T )
DDD <-DD[DD$SP_INCYN=="Y", ]
dim(DDD)
glimpse(DDD)
ok <- complete.cases(DDD$USUBJID)

Data <-DDD[ok, ]
dim(Data)
# [1] [1] 137  66
markers <-c( "AMPSENS125HZ","AMPSENS250HZ","AMPSENS500HZ", 
             "AMPSENS750HZ","AMPSENS1500HZ", "AMPSENS2000HZ", "AMPSENS3000HZ", "AMPSENS4000HZ" ,"AVGAMPLB" ,    
            "AVGAMPRB","DEVAMP","RSPTIMELB","RSPTIMERB","DEVRSPTIME"  )

glimpse(Data)
# y ratio # # [1] 0.2992701

##############################################
# 6. EEG 7 var + SA 4 var                    #
##############################################
names(SA_rawdata)
head(SA_rawdata)
tmp <- SA_rawdata[, 1:2]
names(tmp) <- c("USUBJID","SA_INCYN")
DD <-merge(DMEEGSPSA, tmp, by = "USUBJID", all.x=T )
DDD <-DD[DD$SA_INCYN=="Y", ]
dim(DDD)
glimpse(DDD)
ok <- complete.cases(DDD$USUBJID)

Data <-DDD[ok, ]
dim(Data)
# [1] 144  66
markers <-c("PEAKMEF", "theta_avg","alpha_avg" ,         
            "beta_avg","gamma_avg","alpha_theta_ratio","diff_alpha_theta_LR",
            "error_percentile" ,"error_weighted_percentile", "diff_odd_bg","error_wp_resptime")

glimpse(Data)
# y ratio # # [1] 0.3263889

##############################################
#   7. EEG all + SA all +  SP   all var      #
##############################################
tmp <- SA_rawdata[, 1:2]
names(tmp) <- c("USUBJID","SA_INCYN")
DD <-merge(DMEEGSPSA, tmp, by = "USUBJID", all.x=T )
DDD <-DD[DD$SA_INCYN=="Y", ]
tmp2 <- SP_rawdata[, 1:2]
names(tmp2) <- c("USUBJID","SP_INCYN")
DDDD <-merge(DDD, tmp2, by = "USUBJID", all.x=T )
DDDD <-DDDD[DDDD$SP_INCYN=="Y", ]
dim(DDD)
glimpse(DDD)


ok <- complete.cases(DDDD$USUBJID)

Data <-DDDD[ok, ]
dim(Data)
# 131  67
markers <-c( "PEAKMEF" ,           
             "PEAKFRQ","PEAKPWR","THETALB","ALPHALB" ,           
             "LBETALB","MBETALB","HBETALB","GAMMALB"  ,          
             "THETARB","ALPHARB","LBETARB","MBETARB"  ,          
             "HBETARB","GAMMARB","theta_avg","alpha_avg" ,         
             "beta_avg","gamma_avg","alpha_theta_ratio" ,  "diff_alpha_theta_LR", 
  "FRQCRT","FRQERR","RESPTIME"  ,               
             "BKERPMAX","ODERPMAX",
             "error_percentile" ,"error_weighted_percentile", "diff_odd_bg","error_wp_resptime", 
  "AMPSENS125HZ","AMPSENS250HZ","AMPSENS500HZ", 
             "AMPSENS750HZ","AMPSENS1500HZ", "AMPSENS2000HZ", "AMPSENS3000HZ", "AMPSENS4000HZ" ,"AVGAMPLB" ,    
             "AVGAMPRB","DEVAMP","RSPTIMELB","RSPTIMERB","DEVRSPTIME"  )

# y ratio # # [1] 0.2900763


##############################################
#  8.  EEG  7 var  + AGEF + SEX + EDULEV     #
##############################################
names(EEG_rawdata)


DDDD <- DMEEGSPSA
DDDD$SEX_adj <- (DDDD$SEX==1)*1
ok <- complete.cases(DDDD$EDULEV)
Data <-DDDD[ok, ]
dim(Data)
glimpse(Data)


markers <-c("AGEF","SEX_adj","EDULEV", "PEAKMEF", "theta_avg","alpha_avg" ,         
            "beta_avg","gamma_avg","alpha_theta_ratio","diff_alpha_theta_LR" )

dim(Data)   
# [1][1] 154  66
#  [1] 0.3506494


##############################################
###########   setting end  ###################
##############################################
##############################################



#################################
y <- (Data$DSYN=="Y")*1   
#################################
sum(y)/dim(Data)[1]

all.data <-Data[,markers]
tmp.XY <- cbind(all.data, y)
XY <-tmp.XY
type<- XY$y


index<-CV_pr(type, K=10, type=c(0,1) , seed=0122)  ### 10 folder  ###


#######################################
#    Define saved name                #
#######################################


## training dataset and test dataset define ##
tr.X<-list()
te.X<-list()
tr.XY<-list()
te.XY<-list()

## variable  importance ##
var.ranf <- list()   
var.gbm <-  list()              

##  result save  ## 
test.result <- list()

## tunning parameter save ##

opt.A <-c() # elstic net
opt.ela.L <-c() # elastic net
opt.B <-c()  # gbm



## coefficient save  ##

coeff.logistic <- list() 
stepcoeff.logistic <- list() 
coeff.elastic <- list()    


## fittig model save ##

fit.logistic <- list()
fit.elastic <- list()
fit.ranf <- list()
fit.gbm <- list()


## test data probability ##

prob.logistic <- list()
prob.elastic <- list()
prob.ranf   <- list()
prob.gbm   <- list()


##  ID ### 

ID <- list()


for(i in 1:10){
  
  
  
  tr.XY[[i]]<-data.frame(XY[index!=i,])
  te.XY[[i]]<-data.frame(XY[index==i,])
  
  te.X[[i]] <- te.XY[[i]][,markers]
  tr.X[[i]] <- tr.XY[[i]][,markers]
  
  test.type<- te.XY[[i]]$y
  traing.type<-tr.XY[[i]]$y
  
  tr.d <- xgb.DMatrix(data = as.matrix(tr.X[[i]]),label = traing.type, missing = NA)
  
  te.d <- xgb.DMatrix(data = as.matrix(te.X[[i]]),label = test.type, missing = NA)
  
  
  ID[[i]] <- Data[index==i,c("USUBJID")]
  
  
  #######################################
  #    logistic2                        #
  #######################################
  
  
  
  fit.logistic[[i]]<-glm(y~ ., family = binomial, tr.XY[[i]]) 
  
  dd <- step(fit.logistic[[i]],direction="forward", steps=500)    
  
  coeff.logistic[[i]] <-summary(fit.logistic[[i]])$coefficients[,1]
  stepmarker <-names(coeff.logistic[[i]])
  
  logistic.X <- t(t(cbind(1,te.X[[i]][,stepmarker[-1]]))* coeff.logistic[[i]])
  
  
  XB.logistic <- rowSums(logistic.X); XB.logistic[XB.logistic>10] <- 10
  
  prob.logistic[[i]] <- exp(XB.logistic)/(exp(XB.logistic)+1)
  
  
  
  
  ############################################################
  ### logistic + elastic net_ Model construction:alpha = AL  #
  ############################################################
  
  AL <- seq(0.1 , 0.9, 0.1)
  
  
  Err.A <- c() 
  Lam   <- c()  
  for(A in AL ){
    
    set.seed(2101522)
    aa<-cv.glmnet(as.matrix(tr.X[[i]]),as.factor(traing.type),family="binomial",alpha=A ,standardize = TRUE,type.measure="mse")
    
    Err.cv <- aa$cvm[which.min(aa$cvm)]
    lamb <-  aa$lambda.min    
    Err.A <- c(Err.A, Err.cv)
    Lam  <- c(Lam, lamb)
    
  }
  
  opt.A[i] <- AL[which.min(Err.A)]
  opt.ela.L[i] <- Lam[which.min(Err.A)]
  
  
  fit.elastic[[i]] <-glmnet(as.matrix(tr.X[[i]]),as.factor(traing.type),family="binomial",alpha=opt.A[i], lambda=opt.ela.L[i]
                            ,standardize = TRUE)
  
  
  ela.beta0<-fit.elastic[[i]]$a0
  coeff.elastic[[i]] <- c(ela.beta0,as.vector(fit.elastic[[i]]$beta))
  names(coeff.elastic[[i]]) <-c("beta0",rownames(fit.elastic[[i]]$beta))        
  prob.elastic[[i]] <- predict(fit.elastic[[i]],as.matrix(te.X[[i]])  ,s=opt.ela.L[i], type="response")        
  
  
  
  
  
  
  
  ####################
  #    rf          ###
  ################### 
  
  
  
  fit.ranf[[i]] <- randomForest(y ~., data=tr.XY[[i]], ntree=500,importance=TRUE ,proximity=TRUE)    
  var.ranf[[i]] <-round(importance(fit.ranf[[i]]), 2)
  prob.ranf[[i]] <-predict(fit.ranf[[i]],te.X[[i]],norm.votes=TRUE, predict.all=FALSE, proximity=T)$predicted     
  
  ccc  <-  var.ranf[[i]] 
  
  
  ##################
  #     gbm       ##
  ##################
  
  
  #   gbm.fit    #
  CV.L <- NULL
  gbm.lam <- exp(seq(log(0.05),log(0.001),length.out=5))
  
  for (L in gbm.lam) { 
    aa <-gbm(y ~., data=tr.XY[[i]],distribution="bernoulli",shrinkage=L ,cv.folds = 5, interaction.depth=2, n.trees=1000,verbose=FALSE)$cv.error
    CV.L <- c(CV.L, tail(aa,n=1))
  }
  opt.B[i] <-gbm.lam[which.min(CV.L)]  #  about 0.002 ~ 0.00x
  fit.gbm[[i]] <- gbm(y ~., data=tr.XY[[i]],distribution="bernoulli",shrinkage=opt.B[i] ,cv.folds = 5,interaction.depth=2,  n.trees=1000,verbose=FALSE)  
  var.gbm[[i]] <-summary.gbm(fit.gbm[[i]], n.trees=1000,plotit=FALSE)
  prob.gbm[[i]] <- predict(fit.gbm[[i]],te.X[[i]]  , type="response", n.trees=1000)
  
  
  
  
  #########################################
  #     test set + estimation value      ##
  #########################################
  
  
  
  #  paste  
  
  te.X[[i]]$prob.logistic <- prob.logistic[[i]]       
  
  te.X[[i]]$prob.elastic <- prob.elastic[[i]]
  
  te.X[[i]]$prob.ranf <- prob.ranf[[i]]
  
  te.X[[i]]$prob.gbm <- prob.gbm[[i]]
  
  
  save.image("analysis_20180911_DM_3.Rdata")   
  
  print(i)
  
  
}




newdata<-rbind(te.X[[1]],te.X[[2]],te.X[[3]],te.X[[4]],te.X[[5]],te.X[[6]],te.X[[7]],te.X[[8]],te.X[[9]],te.X[[10]])


newdata$y <- c(te.XY[[1]]$y,te.XY[[2]]$y,te.XY[[3]]$y,te.XY[[4]]$y,te.XY[[5]]$y ,
               te.XY[[6]]$y,te.XY[[7]]$y,te.XY[[8]]$y,te.XY[[9]]$y,te.XY[[10]]$y)


newID  <- c(ID[[1]],ID[[2]],ID[[3]],ID[[4]],ID[[5]],ID[[6]],ID[[7]],ID[[8]],ID[[9]],ID[[10]])


NewData <- cbind(newID, newdata)



write.table(NewData, "Tr_10fold_DM_3_20180911.csv", sep=",", col.names = NA ,row.names = T)



memory.limit()




##############################################
#  9.  MMSE var creation                     #
##############################################



DMr <- DM_rawdata %>% 
  mutate(SUBJID = factor(SUBJID, levels = unique(SUBJID)), 
         SEX = factor(SEX, levels = 1:2, labels = c("Male", "Female")), 
         DSYN = factor(DSYN, levels = c("N", "Y"))) %>% 
  mutate(AGEGRP = ifelse(AGEF < 60, 1, ifelse(AGEF < 70, 2, ifelse(AGEF < 75, 3, ifelse(AGEF < 80, 4, 5)))), 
         DMTP01 = ifelse(AGEGRP <= 2 & SEX == "Female" & EDULEV <= 3 & MMSE <= 19, 1, 
                         ifelse(AGEGRP <= 2 & SEX == "Female" & EDULEV <= 3 & MMSE >= 20, 2, 
                                ifelse(AGEGRP <= 2 & SEX == "Male" & EDULEV <= 3 & MMSE <= 20, 1, 
                                       ifelse(AGEGRP <= 2 & SEX == "Male" & EDULEV <= 3 & MMSE >= 21, 2, 
                                              ifelse(AGEGRP <= 2 & SEX == "Female" & EDULEV <= 6 & MMSE <= 23, 1, 
                                                     ifelse(AGEGRP <= 2 & SEX == "Female" & EDULEV <= 6 & MMSE >= 24, 2, 
                                                            ifelse(AGEGRP <= 2 & SEX == "Male" & EDULEV <= 6 & MMSE <= 24, 1, 
                                                                   ifelse(AGEGRP <= 2 & SEX == "Male" & EDULEV <= 6 & MMSE >= 25, 2, 
                                                                          ifelse(AGEGRP <= 2 & SEX == "Female" & EDULEV <= 12 & MMSE <= 25, 1, 
                                                                                 ifelse(AGEGRP <= 2 & SEX == "Female" & EDULEV <= 12 & MMSE >= 26, 2, 
                                                                                        ifelse(AGEGRP <= 2 & SEX == "Male" & EDULEV <= 12 & MMSE <= 25, 1, 
                                                                                               ifelse(AGEGRP <= 2 & SEX == "Male" & EDULEV <= 12 & MMSE >= 26, 2, 
                                                                                                      ifelse(AGEGRP <= 2 & SEX == "Female" & EDULEV >= 13 & MMSE <= 26, 1, 
                                                                                                             ifelse(AGEGRP <= 2 & SEX == "Female" & EDULEV >= 13 & MMSE >= 27, 2, 
                                                                                                                    ifelse(AGEGRP <= 2 & SEX == "Male" & EDULEV >= 13 & MMSE <= 26, 1, 
                                                                                                                           ifelse(AGEGRP <= 2 & SEX == "Male" & EDULEV >= 13 & MMSE >= 27, 2, 
                                                                                                                                  ifelse(AGEGRP <= 3 & SEX == "Female" & EDULEV <= 3 & MMSE <= 18, 1, 
                                                                                                                                         ifelse(AGEGRP <= 3 & SEX == "Female" & EDULEV <= 3 & MMSE >= 19, 2, 
                                                                                                                                                ifelse(AGEGRP <= 3 & SEX == "Male" & EDULEV <= 3 & MMSE <= 21, 1, 
                                                                                                                                                       ifelse(AGEGRP <= 3 & SEX == "Male" & EDULEV <= 3 & MMSE >= 22, 2, 
                                                                                                                                                              ifelse(AGEGRP <= 3 & SEX == "Female" & EDULEV <= 6 & MMSE <= 21, 1, 
                                                                                                                                                                     ifelse(AGEGRP <= 3 & SEX == "Female" & EDULEV <= 6 & MMSE >= 22, 2,
                                                                                                                                                                            ifelse(AGEGRP <= 3 & SEX == "Male" & EDULEV <= 6 & MMSE <= 23, 1,
                                                                                                                                                                                   ifelse(AGEGRP <= 3 & SEX == "Male" & EDULEV <= 6 & MMSE >= 24, 2,
                                                                                                                                                                                          ifelse(AGEGRP <= 3 & SEX == "Female" & EDULEV <= 12 & MMSE <= 25, 1,
                                                                                                                                                                                                 ifelse(AGEGRP <= 3 & SEX == "Female" & EDULEV <= 12 & MMSE >= 26, 2,
                                                                                                                                                                                                        ifelse(AGEGRP <= 3 & SEX == "Male" & EDULEV <= 12 & MMSE <= 25, 1,
                                                                                                                                                                                                               ifelse(AGEGRP <= 3 & SEX == "Male" & EDULEV <= 12 & MMSE >= 26, 2,
                                                                                                                                                                                                                      ifelse(AGEGRP <= 3 & SEX == "Female" & EDULEV >= 13 & MMSE <= 26, 1,
                                                                                                                                                                                                                             ifelse(AGEGRP <= 3 & SEX == "Female" & EDULEV >= 13 & MMSE >= 27, 2,
                                                                                                                                                                                                                                    ifelse(AGEGRP <= 3 & SEX == "Male" & EDULEV >= 13 & MMSE <= 26, 1,
                                                                                                                                                                                                                                           ifelse(AGEGRP <= 3 & SEX == "Male" & EDULEV >= 13 & MMSE >= 27, 2,
                                                                                                                                                                                                                                                  ifelse(AGEGRP <= 4 & SEX == "Female" & EDULEV <= 3 & MMSE <= 17, 1,
                                                                                                                                                                                                                                                         ifelse(AGEGRP <= 4 & SEX == "Female" & EDULEV <= 3 & MMSE >= 18, 2,
                                                                                                                                                                                                                                                                ifelse(AGEGRP <= 4 & SEX == "Male" & EDULEV <= 3 & MMSE <= 20, 1,
                                                                                                                                                                                                                                                                       ifelse(AGEGRP <= 4 & SEX == "Male" & EDULEV <= 3 & MMSE >= 21, 2,
                                                                                                                                                                                                                                                                              ifelse(AGEGRP <= 4 & SEX == "Female" & EDULEV <= 6 & MMSE <= 21, 1,
                                                                                                                                                                                                                                                                                     ifelse(AGEGRP <= 4 & SEX == "Female" & EDULEV <= 6 & MMSE >= 22, 2,
                                                                                                                                                                                                                                                                                            ifelse(AGEGRP <= 4 & SEX == "Male" & EDULEV <= 6 & MMSE <= 22, 1,
                                                                                                                                                                                                                                                                                                   ifelse(AGEGRP <= 4 & SEX == "Male" & EDULEV <= 6 & MMSE >= 23, 2,
                                                                                                                                                                                                                                                                                                          ifelse(AGEGRP <= 4 & SEX == "Female" & EDULEV <= 12 & MMSE <= 24, 1,
                                                                                                                                                                                                                                                                                                                 ifelse(AGEGRP <= 4 & SEX == "Female" & EDULEV <= 12 & MMSE >= 25, 2,
                                                                                                                                                                                                                                                                                                                        ifelse(AGEGRP <= 4 & SEX == "Male" & EDULEV <= 12 & MMSE <= 25, 1,
                                                                                                                                                                                                                                                                                                                               ifelse(AGEGRP <= 4 & SEX == "Male" & EDULEV <= 12 & MMSE >= 26, 2, 
                                                                                                                                                                                                                                                                                                                                      ifelse(AGEGRP <= 4 & SEX == "Female" & EDULEV >= 13 & MMSE <= 26, 1,
                                                                                                                                                                                                                                                                                                                                             ifelse(AGEGRP <= 4 & SEX == "Female" & EDULEV >= 13 & MMSE >= 27, 2,
                                                                                                                                                                                                                                                                                                                                                    ifelse(AGEGRP <= 4 & SEX == "Male" & EDULEV >= 13 & MMSE <= 25, 1,
                                                                                                                                                                                                                                                                                                                                                           ifelse(AGEGRP <= 4 & SEX == "Male" & EDULEV >= 13 & MMSE >= 26, 2, NA)))))))))))))))))))))))))))))))))))))))))))))))), 
         DMTP01 = ifelse(is.na(DMTP01) & SEX == "Female" & EDULEV <= 3 & MMSE <= 16, 1, 
                         ifelse(is.na(DMTP01) & SEX == "Female" & EDULEV <= 3 & MMSE <= 17, 2, 
                                ifelse(is.na(DMTP01) & SEX == "Male" & EDULEV <= 3 & MMSE <= 18, 1,
                                       ifelse(is.na(DMTP01) & SEX == "Male" & EDULEV <= 3 & MMSE >= 19, 2,
                                              ifelse(is.na(DMTP01) & SEX == "Female" & EDULEV <= 6 & MMSE <= 20, 1,
                                                     ifelse(is.na(DMTP01) & SEX == "Female" & EDULEV <= 6 & MMSE >= 21, 2,
                                                            ifelse(is.na(DMTP01) & SEX == "Male" & EDULEV <= 6 & MMSE <= 22, 1,
                                                                   ifelse(is.na(DMTP01) & SEX == "Male" & EDULEV <= 6 & MMSE >= 23, 2,
                                                                          ifelse(is.na(DMTP01) & SEX == "Female" & EDULEV <= 12 & MMSE <= 24, 1,
                                                                                 ifelse(is.na(DMTP01) & SEX == "Female" & EDULEV <= 12 & MMSE >= 25, 2,
                                                                                        ifelse(is.na(DMTP01) & SEX == "Male" & EDULEV <= 12 & MMSE <= 24, 1,
                                                                                               ifelse(is.na(DMTP01) & SEX == "Male" & EDULEV <= 12 & MMSE >= 25, 2,
                                                                                                      ifelse(is.na(DMTP01) & SEX == "Female" & EDULEV >= 13 & MMSE <= 27, 1,
                                                                                                             ifelse(is.na(DMTP01) & SEX == "Female" & EDULEV >= 13 & MMSE >= 28, 2,
                                                                                                                    ifelse(is.na(DMTP01) & SEX == "Male" & EDULEV >= 13 & MMSE <= 25, 1,
                                                                                                                           ifelse(is.na(DMTP01) & SEX == "Male" & EDULEV >= 13 & MMSE >= 26, 2, DMTP01)))))))))))))))), 
         DMTP01 = ifelse(is.na(DMTP01), 1, DMTP01), 
         DMTP02 = ifelse(MMSE <= 20, 1, 2), 
         AGEGRP = factor(AGEGRP, levels = 1:5, labels = c("< 60", "< 70", "< 75", "< 80", ">= 80"))) %>% 
  mutate_at(vars(DMTP01, DMTP02), funs(factor(., levels=c(2,1), labels = c("Normal", "Dementia"))))




write.table(DMr, "DMr_DMTP01_DMTP02_20180727.csv", sep=",", col.names = NA ,row.names = T)



###########################################################################################
###########################################################################################
###########################################################################################







#########################################
#     Tr_10fold_DM_3    AUC plot       ##
#########################################



data1 <- read.csv("Tr_10fold_DM_3_20180911.csv", stringsAsFactors = FALSE, header=T)
head(data1)
names(data1)

D1 <- data1[, c(2, 6:10)]

names(D1) <- c("ID","logi_1","ela_1","ranf_1","gbm_1","y1")



pred_logi_1 <- prediction(D1$logi_1, D1$y1)
perf_logi_1 <- performance(pred_logi_1, measure = "tpr", x.measure = "fpr") 
perf_logi_1
pred_ela_1 <- prediction(D1$ela_1, D1$y1)
perf_ela_1 <- performance(pred_ela_1, measure = "tpr", x.measure = "fpr") 

pred_ranf_1 <- prediction(D1$ranf_1, D1$y1)
perf_ranf_1 <- performance(pred_ranf_1, measure = "tpr", x.measure = "fpr") 

pred_gbm_1 <- prediction(D1$gbm_1, D1$y1)
perf_gbm_1 <- performance(pred_gbm_1, measure = "tpr", x.measure = "fpr") 


plot(perf_logi_1, col='black', main="DM 3 ROC Curve",lwd=4)
plot(perf_ela_1, col='blue', add=TRUE,lwd=4)
plot(perf_ranf_1, col='pink', add=TRUE,lwd=4)
plot(perf_gbm_1, col='red', add=TRUE,lwd=4)

abline(0,1)
legend('bottomright', inset=.1,
       legend=c("Logistic","Elastic_Net","Random Forest", "Boosting"),
       col=c('black','blue','pink','red'),lty=1,lwd=4)

performance(pred_logi_1, "auc")@y.values[[1]]
performance(pred_ela_1, "auc")@y.values[[1]]
performance(pred_ranf_1, "auc")@y.values[[1]]
performance(pred_gbm_1, "auc")@y.values[[1]]








#########################################
#     Tr_10fold_EEG_7   AUC plot       ##
#########################################



data1 <- read.csv("Tr_10fold_EEG_7_20180727.csv", stringsAsFactors = FALSE, header=T)
head(data1)
names(data1)

D1 <- data1[, c(2, 10:14)]

names(D1) <- c("ID","logi_1","ela_1","ranf_1","gbm_1","y1")



pred_logi_1 <- prediction(D1$logi_1, D1$y1)
perf_logi_1 <- performance(pred_logi_1, measure = "tpr", x.measure = "fpr") 
perf_logi_1
pred_ela_1 <- prediction(D1$ela_1, D1$y1)
perf_ela_1 <- performance(pred_ela_1, measure = "tpr", x.measure = "fpr") 

pred_ranf_1 <- prediction(D1$ranf_1, D1$y1)
perf_ranf_1 <- performance(pred_ranf_1, measure = "tpr", x.measure = "fpr") 

pred_gbm_1 <- prediction(D1$gbm_1, D1$y1)
perf_gbm_1 <- performance(pred_gbm_1, measure = "tpr", x.measure = "fpr") 


plot(perf_logi_1, col='black', main="EEG 7 ROC Curve",lwd=4)
plot(perf_ela_1, col='blue', add=TRUE,lwd=4)
plot(perf_ranf_1, col='pink', add=TRUE,lwd=4)
plot(perf_gbm_1, col='red', add=TRUE,lwd=4)

abline(0,1)
legend('bottomright', inset=.1,
       legend=c("Logistic","Elastic_Net","Random Forest", "Boosting"),
       col=c('black','blue','pink','red'),lty=1,lwd=4)

performance(pred_logi_1, "auc")@y.values[[1]]
performance(pred_ela_1, "auc")@y.values[[1]]
performance(pred_ranf_1, "auc")@y.values[[1]]
performance(pred_gbm_1, "auc")@y.values[[1]]




#########################################
#     Tr_10fold_SA_4   AUC plot       ##
#########################################



data1 <- read.csv("Tr_10fold_SA_4_20180727.csv", stringsAsFactors = FALSE, header=T)
head(data1)
names(data1)

D1 <- data1[, c(2, 7:11)]

names(D1) <- c("ID","logi_1","ela_1","ranf_1","gbm_1","y1")



pred_logi_1 <- prediction(D1$logi_1, D1$y1)
perf_logi_1 <- performance(pred_logi_1, measure = "tpr", x.measure = "fpr") 

pred_ela_1 <- prediction(D1$ela_1, D1$y1)
perf_ela_1 <- performance(pred_ela_1, measure = "tpr", x.measure = "fpr") 

pred_ranf_1 <- prediction(D1$ranf_1, D1$y1)
perf_ranf_1 <- performance(pred_ranf_1, measure = "tpr", x.measure = "fpr") 

pred_gbm_1 <- prediction(D1$gbm_1, D1$y1)
perf_gbm_1 <- performance(pred_gbm_1, measure = "tpr", x.measure = "fpr") 


plot(perf_logi_1, col='black', main="SA 4 ROC Curve",lwd=4)
plot(perf_ela_1, col='blue', add=TRUE,lwd=4)
plot(perf_ranf_1, col='pink', add=TRUE,lwd=4)
plot(perf_gbm_1, col='red', add=TRUE,lwd=4)

abline(0,1)
legend('bottomright', inset=.1,
       legend=c("Logistic","Elastic_Net","Random Forest", "Boosting"),
       col=c('black','blue','pink','red'),lty=1,lwd=4)

performance(pred_logi_1, "auc")@y.values[[1]]
performance(pred_ela_1, "auc")@y.values[[1]]
performance(pred_ranf_1, "auc")@y.values[[1]]
performance(pred_gbm_1, "auc")@y.values[[1]]


#########################################
#     Tr_10fold_EEG_all   AUC plot       ##
#########################################



data1 <- read.csv("Tr_10fold_EGG_all_20180727.csv", stringsAsFactors = FALSE, header=T)
head(data1)
names(data1)

D1 <- data1[, c(2, 24:28)]

names(D1) <- c("ID","logi_1","ela_1","ranf_1","gbm_1","y1")



pred_logi_1 <- prediction(D1$logi_1, D1$y1)
perf_logi_1 <- performance(pred_logi_1, measure = "tpr", x.measure = "fpr") 

pred_ela_1 <- prediction(D1$ela_1, D1$y1)
perf_ela_1 <- performance(pred_ela_1, measure = "tpr", x.measure = "fpr") 

pred_ranf_1 <- prediction(D1$ranf_1, D1$y1)
perf_ranf_1 <- performance(pred_ranf_1, measure = "tpr", x.measure = "fpr") 

pred_gbm_1 <- prediction(D1$gbm_1, D1$y1)
perf_gbm_1 <- performance(pred_gbm_1, measure = "tpr", x.measure = "fpr") 


plot(perf_logi_1, col='black', main="EEG_all ROC Curve",lwd=4)
plot(perf_ela_1, col='blue', add=TRUE,lwd=4)
plot(perf_ranf_1, col='pink', add=TRUE,lwd=4)
plot(perf_gbm_1, col='red', add=TRUE,lwd=4)

abline(0,1)
legend('bottomright', inset=.1,
       legend=c("Logistic","Elastic_Net","Random Forest", "Boosting"),
       col=c('black','blue','pink','red'),lty=1,lwd=4)

performance(pred_logi_1, "auc")@y.values[[1]]
performance(pred_ela_1, "auc")@y.values[[1]]
performance(pred_ranf_1, "auc")@y.values[[1]]
performance(pred_gbm_1, "auc")@y.values[[1]]



#########################################
#     Tr_10fold_SA_all   AUC plot       ##
#########################################



data1 <- read.csv("Tr_10fold_SA_all_20180727.csv", stringsAsFactors = FALSE, header=T)
head(data1)
names(data1)

D1 <- data1[, c(2, 12:16)]

names(D1) <- c("ID","logi_1","ela_1","ranf_1","gbm_1","y1")



pred_logi_1 <- prediction(D1$logi_1, D1$y1)
perf_logi_1 <- performance(pred_logi_1, measure = "tpr", x.measure = "fpr") 

pred_ela_1 <- prediction(D1$ela_1, D1$y1)
perf_ela_1 <- performance(pred_ela_1, measure = "tpr", x.measure = "fpr") 

pred_ranf_1 <- prediction(D1$ranf_1, D1$y1)
perf_ranf_1 <- performance(pred_ranf_1, measure = "tpr", x.measure = "fpr") 

pred_gbm_1 <- prediction(D1$gbm_1, D1$y1)
perf_gbm_1 <- performance(pred_gbm_1, measure = "tpr", x.measure = "fpr") 


plot(perf_logi_1, col='black', main="SA_all ROC Curve",lwd=4)
plot(perf_ela_1, col='blue', add=TRUE,lwd=4)
plot(perf_ranf_1, col='pink', add=TRUE,lwd=4)
plot(perf_gbm_1, col='red', add=TRUE,lwd=4)

abline(0,1)
legend('bottomright', inset=.1,
       legend=c("Logistic","Elastic_Net","Random Forest", "Boosting"),
       col=c('black','blue','pink','red'),lty=1,lwd=4)

performance(pred_logi_1, "auc")@y.values[[1]]
performance(pred_ela_1, "auc")@y.values[[1]]
performance(pred_ranf_1, "auc")@y.values[[1]]
performance(pred_gbm_1, "auc")@y.values[[1]]


#########################################
#     Tr_10fold_SP_all   AUC plot       ##
#########################################



data1 <- read.csv("Tr_10fold_SP_all_20180727.csv", stringsAsFactors = FALSE, header=T)
head(data1)
names(data1)

D1 <- data1[, c(2, 17:21)]

names(D1) <- c("ID","logi_1","ela_1","ranf_1","gbm_1","y1")



pred_logi_1 <- prediction(D1$logi_1, D1$y1)
perf_logi_1 <- performance(pred_logi_1, measure = "tpr", x.measure = "fpr") 

pred_ela_1 <- prediction(D1$ela_1, D1$y1)
perf_ela_1 <- performance(pred_ela_1, measure = "tpr", x.measure = "fpr") 

pred_ranf_1 <- prediction(D1$ranf_1, D1$y1)
perf_ranf_1 <- performance(pred_ranf_1, measure = "tpr", x.measure = "fpr") 

pred_gbm_1 <- prediction(D1$gbm_1, D1$y1)
perf_gbm_1 <- performance(pred_gbm_1, measure = "tpr", x.measure = "fpr") 


plot(perf_logi_1, col='black', main="SP_all ROC Curve",lwd=4)
plot(perf_ela_1, col='blue', add=TRUE,lwd=4)
plot(perf_ranf_1, col='pink', add=TRUE,lwd=4)
plot(perf_gbm_1, col='red', add=TRUE,lwd=4)

abline(0,1)
legend('bottomright', inset=.1,
       legend=c("Logistic","Elastic_Net","Random Forest", "Boosting"),
       col=c('black','blue','pink','red'),lty=1,lwd=4)

performance(pred_logi_1, "auc")@y.values[[1]]
performance(pred_ela_1, "auc")@y.values[[1]]
performance(pred_ranf_1, "auc")@y.values[[1]]
performance(pred_gbm_1, "auc")@y.values[[1]]



#########################################
#     Tr_10fold_EEGSA_11   AUC plot       ##
#########################################



data1 <- read.csv("Tr_10fold_EEGSA_11_20180727.csv", stringsAsFactors = FALSE, header=T)
head(data1)
names(data1)

D1 <- data1[, c(2, 14:18)]

names(D1) <- c("ID","logi_1","ela_1","ranf_1","gbm_1","y1")



pred_logi_1 <- prediction(D1$logi_1, D1$y1)
perf_logi_1 <- performance(pred_logi_1, measure = "tpr", x.measure = "fpr") 

pred_ela_1 <- prediction(D1$ela_1, D1$y1)
perf_ela_1 <- performance(pred_ela_1, measure = "tpr", x.measure = "fpr") 

pred_ranf_1 <- prediction(D1$ranf_1, D1$y1)
perf_ranf_1 <- performance(pred_ranf_1, measure = "tpr", x.measure = "fpr") 

pred_gbm_1 <- prediction(D1$gbm_1, D1$y1)
perf_gbm_1 <- performance(pred_gbm_1, measure = "tpr", x.measure = "fpr") 


plot(perf_logi_1, col='black', main="EEGSA_11 ROC Curve",lwd=4)
plot(perf_ela_1, col='blue', add=TRUE,lwd=4)
plot(perf_ranf_1, col='pink', add=TRUE,lwd=4)
plot(perf_gbm_1, col='red', add=TRUE,lwd=4)

abline(0,1)
legend('bottomright', inset=.1,
       legend=c("Logistic","Elastic_Net","Random Forest", "Boosting"),
       col=c('black','blue','pink','red'),lty=1,lwd=4)

performance(pred_logi_1, "auc")@y.values[[1]]
performance(pred_ela_1, "auc")@y.values[[1]]
performance(pred_ranf_1, "auc")@y.values[[1]]
performance(pred_gbm_1, "auc")@y.values[[1]]


#########################################
#     Tr_10fold_EEGSASP_all   AUC plot       ##
#########################################



data1 <- read.csv("Tr_10fold_EEGSASP_all_20180727.csv", stringsAsFactors = FALSE, header=T)
head(data1)
names(data1)

D1 <- data1[, c(2, 47:51)]

names(D1) <- c("ID","logi_1","ela_1","ranf_1","gbm_1","y1")



pred_logi_1 <- prediction(D1$logi_1, D1$y1)
perf_logi_1 <- performance(pred_logi_1, measure = "tpr", x.measure = "fpr") 

pred_ela_1 <- prediction(D1$ela_1, D1$y1)
perf_ela_1 <- performance(pred_ela_1, measure = "tpr", x.measure = "fpr") 

pred_ranf_1 <- prediction(D1$ranf_1, D1$y1)
perf_ranf_1 <- performance(pred_ranf_1, measure = "tpr", x.measure = "fpr") 

pred_gbm_1 <- prediction(D1$gbm_1, D1$y1)
perf_gbm_1 <- performance(pred_gbm_1, measure = "tpr", x.measure = "fpr") 


plot(perf_logi_1, col='black', main="EEGSASP_all ROC Curve",lwd=4)
plot(perf_ela_1, col='blue', add=TRUE,lwd=4)
plot(perf_ranf_1, col='pink', add=TRUE,lwd=4)
plot(perf_gbm_1, col='red', add=TRUE,lwd=4)

abline(0,1)
legend('bottomright', inset=.1,
       legend=c("Logistic","Elastic_Net","Random Forest", "Boosting"),
       col=c('black','blue','pink','red'),lty=1,lwd=4)

performance(pred_logi_1, "auc")@y.values[[1]]
performance(pred_ela_1, "auc")@y.values[[1]]
performance(pred_ranf_1, "auc")@y.values[[1]]
performance(pred_gbm_1, "auc")@y.values[[1]]


#########################################
#     Tr_10fold_EEGDM_10   AUC plot       ##
#########################################



data1 <- read.csv("Tr_10fold_EEGDM_10_20180727.csv", stringsAsFactors = FALSE, header=T)
head(data1)
names(data1)

D1 <- data1[, c(2, 13:17)]

names(D1) <- c("ID","logi_1","ela_1","ranf_1","gbm_1","y1")



pred_logi_1 <- prediction(D1$logi_1, D1$y1)
perf_logi_1 <- performance(pred_logi_1, measure = "tpr", x.measure = "fpr") 

pred_ela_1 <- prediction(D1$ela_1, D1$y1)
perf_ela_1 <- performance(pred_ela_1, measure = "tpr", x.measure = "fpr") 

pred_ranf_1 <- prediction(D1$ranf_1, D1$y1)
perf_ranf_1 <- performance(pred_ranf_1, measure = "tpr", x.measure = "fpr") 

pred_gbm_1 <- prediction(D1$gbm_1, D1$y1)
perf_gbm_1 <- performance(pred_gbm_1, measure = "tpr", x.measure = "fpr") 


plot(perf_logi_1, col='black', main="EEGDM_10 ROC Curve",lwd=4)
plot(perf_ela_1, col='blue', add=TRUE,lwd=4)
plot(perf_ranf_1, col='pink', add=TRUE,lwd=4)
plot(perf_gbm_1, col='red', add=TRUE,lwd=4)

abline(0,1)
legend('bottomright', inset=.1,
       legend=c("Logistic","Elastic_Net","Random Forest", "Boosting"),
       col=c('black','blue','pink','red'),lty=1,lwd=4)

performance(pred_logi_1, "auc")@y.values[[1]]
performance(pred_ela_1, "auc")@y.values[[1]]
performance(pred_ranf_1, "auc")@y.values[[1]]
performance(pred_gbm_1, "auc")@y.values[[1]]



#########################################
#     DMr_DMTP01_DMTP02   AUC plot       ##
#########################################



data1 <- read.csv("DMr_DMTP01_DMTP02_20180727.csv", stringsAsFactors = FALSE, header=T)
head(data1)
names(data1)
glimpse(data1)
data1$y <-  (data1$DSYN=="Y")*1
data1$DMP01_adj <- (data1$DMTP01=="Dementia")*1
data1$DMP02_adj <- (data1$DMTP02=="Dementia")*1

D1 <- data1[, c(2, 20:22)]

names(D1) <- c("ID","y1","DMTP01","DMTP02")

a<-table(D1$y1, D1$DMTP01)
a
(a[1,1] + a[2,2])/(a[1,1] + a[2,2]+a[1,2] + a[2,1])
(a[2,2] )/(a[2,2] + a[2,1])
(a[1,1] )/(a[1,1] +a[1,2])

a<-table(D1$y1, D1$DMTP02)
a
(a[1,1] + a[2,2])/(a[1,1] + a[2,2]+a[1,2] + a[2,1])
(a[2,2] )/(a[2,2] + a[2,1])
(a[1,1] )/(a[1,1] +a[1,2])






###########################################################################################
###########################################################################################
###########################################################################################


###########################################################################################
###########################################################################################
###########################################################################################


#########################################
#     ACCURACY                         ##
#########################################




m0 <- read.csv("Tr_10fold_DM_3_20180911.csv", stringsAsFactors = FALSE, header=T) 
m0 <- read.csv("Tr_10fold_EEG_7_20180727.csv", stringsAsFactors = FALSE, header=T)  
m0<- read.csv("Tr_10fold_SA_4_20180727.csv", stringsAsFactors = FALSE, header=T) 
m0<- read.csv("Tr_10fold_EGG_all_20180727.csv", stringsAsFactors = FALSE, header=T) 
m0<- read.csv("Tr_10fold_SA_all_20180727.csv", stringsAsFactors = FALSE, header=T) 
m0<- read.csv("Tr_10fold_SP_all_20180727.csv", stringsAsFactors = FALSE, header=T) 
m0<- read.csv("Tr_10fold_EEGSA_11_20180727.csv", stringsAsFactors = FALSE, header=T) 
m0<- read.csv("Tr_10fold_EEGSASP_all_20180727.csv", stringsAsFactors = FALSE, header=T) 
m0<- read.csv("Tr_10fold_EEGDM_10_20180727.csv", stringsAsFactors = FALSE, header=T) 


AA <- c()

for (k in seq(0.35,0.5, by=0.01)) {
  
  m0$pred.logistic <- (m0$prob.logistic > k )*1
  m0$pred.elastic <- (m0$prob.elastic > k )*1
  m0$pred.ranf <- (m0$prob.ranf > k )*1
  m0$pred.gbm <- (m0$prob.gbm > k )*1
  
  
  a<-table(m0$y, m0$pred.logistic)
  a
  acc.logistic <-(a[1,1] + a[2,2])/(a[1,1] + a[2,2]+a[1,2] + a[2,1])
  sen.logistic <-(a[2,2] )/(a[2,2] + a[2,1])
  spe.logistic <-(a[1,1] )/(a[1,1] +a[1,2])
  
  a<-table(m0$y, m0$pred.elastic)
  a
  acc.elastic <-(a[1,1] + a[2,2])/(a[1,1] + a[2,2]+a[1,2] + a[2,1])
  sen.elastic <-(a[2,2] )/(a[2,2] + a[2,1])
  spe.elastic <-(a[1,1] )/(a[1,1] +a[1,2])
  
  a<-table(m0$y, m0$pred.ranf)
  a
  acc.ranf <-(a[1,1] + a[2,2])/(a[1,1] + a[2,2]+a[1,2] + a[2,1])
  sen.ranf <-(a[2,2] )/(a[2,2] + a[2,1])
  spe.ranf <-(a[1,1] )/(a[1,1] +a[1,2])
  
  a<-table(m0$y, m0$pred.gbm)
  a
  acc.gbm <-(a[1,1] + a[2,2])/(a[1,1] + a[2,2]+a[1,2] + a[2,1])
  sen.gbm <-(a[2,2] )/(a[2,2] + a[2,1])
  spe.gbm <-(a[1,1] )/(a[1,1] +a[1,2])
  
  aa <- c(acc.logistic,sen.logistic,spe.logistic,acc.elastic,sen.elastic,spe.elastic,
          acc.ranf,sen.ranf,spe.ranf,acc.gbm,sen.gbm,spe.gbm)
  
  AA <- rbind(AA,aa )
  
  print(k)
  
}

rownames(AA) <- seq(0.35,0.5, by=0.01)
colnames(AA)<- c("acc.logistic","sen.logistic","spe.logistic","acc.elastic","sen.elastic",
                 "spe.elastic",
                 "acc.ranf","sen.ranf","spe.ranf","acc.gbm","sen.gbm","spe.gbm")
AA


write.table(AA, "Cutoff_EEGDM_10_20180911.csv", sep=",", col.names = NA ,row.names = T)



