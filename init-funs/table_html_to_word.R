table_html_to_word <- function(obj, ...) {
  # browser()
  require(officer)
  require(flextable)
  
  myborder <- function(x, ...) hline_top(x, border = fp_border(width = 1.5, color = "black"), part = "header") %>% 
    hline_bottom(border = fp_border(width = 1.5, color = "black"), part = "header") %>% 
    hline_bottom(border = fp_border(width = 1.5, color = "black"), part = "body") %>% 
    bold(part = "header")
  myZebra <- function(x, ...)  theme_zebra(x, odd_header = "transparent", even_body = "#EFEFEF", odd_body = "transparent")
  myFont <- function(x, font = "Times", size = 10, ...) flextable::font(x, fontname = font, part = "all") %>% 
    fontsize(size = size, part = "all") 
  
  tdf <- obj$table_data
  header <- colnames(tdf)
  header <- gsub("<br/>", "\n", header)
  tdf <- gsub("<br/>", "\n", tdf)
  colnames(tdf) <- header
  
  tdf <- gsub("&chi;", "\\\\chi", tdf)
  tdf <- gsub("<sup>", "\\^\\(", tdf)
  tdf <- gsub("</sup>", "\\)", tdf)
  tdf <- gsub("<sub>", "_\\(", tdf)
  tdf <- gsub("</sub>", "\\)", tdf)
  
  varlab <- obj$rgroup
  n.rgroup <- obj$n.rgroup
  tdf_out <- data.frame(var  = rep(varlab, n.rgroup), 
                        stat = paste0("    ", rownames(tdf)), 
                        tdf, 
                        row.names = NULL, 
                        check.names = F, 
                        stringsAsFactors = F)
  tdf_out <- as_grouped_data(tdf_out, groups = "var", columns =NULL)
  colkey <- names(tdf_out)
  g.start <- 3; g.end <- NCOL(tdf_out) - 1
  typology <- data.frame(col_keys = colkey, 
                         colA = c(" ", " ", colkey[g.start:length(colkey)]), 
                         stringsAsFactors = F)
  
  out <- regulartable(tdf_out, col_keys = colkey) %>% 
    set_header_df(mapping = typology, key = "col_keys") %>% 
    myFont %>%
    align(j = 1:2, align = "left") %>% 
    align(j = g.start:g.end, align = "center", part = "all") %>% 
    align(j = length(colkey), align = "center", part = "header") %>% 
    merge_v(j = 1, part = "body") %>% 
    # valign(j = 1, valign = 'top') %>% 
    bold(j = 1) %>% 
    myborder

  rnam <- as.numeric(rownames(out$body$dataset))
  
  for (i in 1:length(obj$rgroup)) {
    idx <- which(rnam == i)
    out <- out %>% 
      merge_h_range(i = idx, j1 = 1, j2 = NCOL(tdf_out))
  }
  
  return(out)
  
}
