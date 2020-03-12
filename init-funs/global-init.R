#--------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Global initialization
#--------------------------------------------------------------------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Mecasin phase II-a clinical trial initialization
#--------------------------------------------------------------------------------------------------------------------------------------------------------------#

# 0. Initialization ####
# rm(list = ls())
source("init-funs/my_init.R", encoding = "UTF-8")
require(ggthemes)
require(grid); require(gridExtra)
require(GGally)
require(viridis)
require(extrafont)
require(ggpubr)
require(Hmisc)
require(officer)
require(flextable)
require(htmlTable)
require(Gmisc)
require(kableExtra)
# loadfonts(device = "win")

source("init-funs/misc_fun.R", encoding = "UTF-8")
source("init-funs/data_visualization.R", encoding = "UTF-8")
source("init-funs/mydesc_table.R", encoding = "UTF-8")
source("init-funs/table_html_to_word.R", encoding = "UTF-8")
source("init-funs/eda-misc-funs.R", encoding = "UTF-8")

### Outlier detection based on the 3*IQR rule
outlier.to.logic <- function(x, crt = 3) {
  med <- median(x, na.rm=T)
  iqr <- IQR(x, na.rm=T)
  q1=quantile(x, .25, type=6, na.rm=T)
  q3=quantile(x, .75, type=6, na.rm=T)
  
  OU <- q3 + crt*iqr
  OL <- q1 - crt*iqr
  return((x > OU | x < OL))
  # out <- abs((x-median(x, na.rm=T))/mad(x, na.rm=T))
  # return((out > 3))
}
outlier.to.NA <- function(x, crt = 3) {
  med <- median(x, na.rm=T)
  iqr <- IQR(x, na.rm=T)
  q1=quantile(x, .25, type=6, na.rm=T)
  q3=quantile(x, .75, type=6, na.rm=T)
  
  OU <- q3 + crt*iqr
  OL <- q1 - crt*iqr
  x[(x > OU | x < OL)] <- NA
  # out <- abs((x-median(x, na.rm=T))/mad(x, na.rm=T))
  # x[out > 3] <- NA
  return(x)
}

create_label <- function(df, labname) {
  # browser()
  command <- paste0("label(df$", names(labname), ")",
                    "<-labname[['", names(labname), "']]")
  for (i in command) eval(parse(text = i))
  return(df)
}

binomial_deviance <- function(y, yhat) {
  epsilon <- 0.0001
  yhat <- ifelse(yhat < epsilon, epsilon, yhat)
  yhat <- ifelse(yhat > 1 - epsilon, 1 - epsilon, yhat)
  a <- ifelse(y == 0, 0, y * log(y/yhat))
  b <- ifelse(y == 1, 0, (1 - y) * log((1 - y)/(1-yhat)))
  return(2*sum(a+b))
}

# functions to make a clear table
myborder <- function(x, ...) {
  hline_top(x,
            border = fp_border(width = 1.5,
                               color = "black"),
            part = "header") %>%
    hline_bottom(border = fp_border(width = 1.5,
                                    color = "black"),
                 part = "header") %>%
    hline_bottom(border = fp_border(width = 1.5,
                                    color = "black"),
                 part = "body")
  
}
myZebra <- function(x, ...)  {
  theme_zebra(x,
              odd_header = "transparent",
              even_body = "#EFEFEF",
              odd_body = "transparent")
}
std_border = fp_border(color = "black", width = 1)
myFont <- function(x, font = "Times", size = 10, ...) {
  flextable::font(x,
                  fontname = font,
                  part = "all") %>%
    fontsize(size = size, part = "all")
}

mySD <- function(x) sqrt(sum((x - mean(x))^2)/(length(x)))
RMSE <- function(y, yhat) sqrt(mean((y - yhat)^2))


