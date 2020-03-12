#---------------------------------------------------------------------------------------------------------------------#
# Simple function to create table for descriptive statistics (mean and sd), 2 dimensional table
#---------------------------------------------------------------------------------------------------------------------#
SimpleDescTab <- function(data = data, y = y, header = header, by = by, digits = 2, equalvar = F) {
  require(dplyr)
  require(tidyr)
  require(lazyeval)

  digits <- paste0("%.", digits, "f")
  cellc <- paste0(digits, " ± ", digits)
    # browser()
  y <- as.character(substitute(y)); header <- as.character(substitute(header))
  # summarise_tab <- eval(substitute(summarise(Mean = mean(y, na.rm = T), SD = sd(y, na.rm = T)), 
  #                                  list(y = y)))
  pretab <- data %>% group_by_(.dots = by) %>% 
    summarise_( Mean = interp(~ mean(v), v = as.name(y)), 
                SD   = interp(~ sd(v),   v = as.name(y))) %>% 
    mutate(result = sprintf(cellc, Mean, SD)) %>% 
    select_(.dots = c(by, "result")) %>% ungroup(.) %>% spread_(key_col = header, value_col = "result")
  
  idx <- which(by != header)
  
  ptab <- data %>% group_by_(.dots = by[idx]) %>% 
    do(data.frame(p.value = oneway.test(as.formula(paste0(y, "~", header)), data = ., 
                                        var.equal = equalvar)$p.value))
  
  output <- pretab %>% inner_join(ptab, by = by[idx])
    
  return(output)
  
}