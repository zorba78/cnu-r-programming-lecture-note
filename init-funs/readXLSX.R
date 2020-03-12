# -------------------------------------------------------------------------------------------------------------------------------#
# Read Excel File (multi-sheets)
# -------------------------------------------------------------------------------------------------------------------------------#

read.XLSX <- function(path = "rawdata/", ...) {
require(tidyverse); require(readxl)

  DFL1 <- path %>% excel_sheets() %>% 
    purrr::set_names() %>% map(read_excel, path = path)
  
  # command <- paste(names(DFL1), "<- DFL1$", names(DFL1), sep="")
  # for(i in command) eval(parse(text=i))
  return(DFL1)
}