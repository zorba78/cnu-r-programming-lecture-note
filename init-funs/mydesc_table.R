# required.packages <- c("tidyverse", "Gmisc", "Hmisc", "htmlTable", "kableExtra")

# 위 패키지가 설치되어 있지 않으면 자동 인스톨
# for (pkg in required.packages) {
#   if (pkg %in% rownames(installed.packages()) == FALSE)
#   {install.packages(pkg)}
#   if (pkg %in% row.names(.packages()) == FALSE)
#   {require(pkg, character.only = T)}
# }


getT1Stat <- function(data, by, varname, digits = 0, 
                      add_total_col = TRUE,
                      html = TRUE, 
                      cont_fun = mydescribe_continuous) {
  # browser()
  y <- data[[varname]]
  x <- data[[by]]
  out <- getDescriptionStatsBy(y,
                              x,
                              add_total_col = TRUE,
                              show_all_values = TRUE,
                              continuous_fn = cont_fun, 
                              hrzl_prop = FALSE,
                              statistics = FALSE,
                              html = html,
                              digits = digits)   
}

get_pval_ttest <- function(x, by) {
  out <- t.test(x ~ by)
  out$p.value
}


mydescribe_continuous <- function(x, html = TRUE, digits = 1, digits.nonzero = NA, 
                                 number_first = TRUE, iqr = iqr, median_summ = median_summ, 
                                 useNA = c("ifany", "no", "always"), useNA.digits = digits, 
                                 percentage_sign = TRUE, plusmin_str, language = "en", 
                                 ...) {
  # browser()
  dot_args <- list(...)
  useNA <- match.arg(useNA)
  
  if (iqr) range_quantiles <- c(1/4, 3/4) 
  else range_quantiles <- c(0, 1)
  mednam <- ifelse(iqr, "Median [IQR]", "Median [range]")
  blank <- ifelse(html, "<br/>", "\\shortstack{")
  if(missing(plusmin_str)) 
    if (html) 
      plusmin_str <- "±"
    else 
      plusmin_str <- "$\\pm$" 
  
  ret1 <- c(sprintf("%s (%s%s)", 
                    txtRound(mean(x, na.rm = T), digits = digits, 
                             digits.nonzero = digits.nonzero), 
                    plusmin_str,
                    txtRound(sd(x, na.rm = T), digits = digits, 
                              digits.nonzero = digits.nonzero)))
  if (median_summ) {
    ret2 <- sprintf("%s%s[%s - %s]",
                    txtRound(median(x, na.rm = T), 
                             digits = digits, 
                             digits.nonzero = digits.nonzero), 
                    blank, 
                    txtRound(quantile(x, probs = range_quantiles[1], na.rm = T), 
                             digits = digits, 
                             digits.nonzero = digits.nonzero), 
                    txtRound(quantile(x, probs = range_quantiles[2], na.rm = T), 
                             digits = digits, 
                             digits.nonzero = digits.nonzero))
    if (!html) ret2 <- paste0(ret2, "}")
  }
  else 
    ret2 <- NULL
  
  ret <- rbind(ret1, ret2); rownames(ret) <- NULL
  if (length(ret) == 1) ret <- c(ret)
  
  if (useNA %in% c("ifany", "always") & sum(is.na(x)) > 0) {
    ret <- rbind(ret, 
                 descGetMissing(x = x, html = html, 
                                number_first = number_first, 
                                percentage_sign = percentage_sign, 
                                language = language, 
                                useNA.digits = useNA.digits, 
                                digits.nonzero = digits.nonzero, 
                                dot_args = dot_args))
    if (median_summ) 
      rownames(ret) <- c("Mean (SD)", mednam, "Missing")
    else 
      rownames(ret) <- c("Mean (SD)", "Missing")
  }
  else if (useNA == "always") {
    if (percentage_sign) 
      percentage_sign <- ifelse(html, "%", "\\%")
    else if (is.character(percentage_sign) == FALSE)
      percentage_sign <- ""
    empty <- sprintf(ifelse(number_first, "0 (0%s)", "0%s 0"), 
                     percentage_sign)
    ret <- rbind(ret, empty)
    
    if (median_summ) 
      rownames(ret) <- c("Mean (SD)", mednam, "Missing")
    else 
      rownames(ret) <- c("Mean (SD)", "Missing")
  }
  else {
    if (median_summ) {
      rownames(ret) <- c("Mean (SD)", mednam)

    }
    else {
      names(ret) <- "Mean (SD)"
    }
      
  }
  return(ret)
}

mydesc_table <- function(data, by, varname, digits = 2, html = TRUE, 
                         digits.nonzero = NA, 
                         total_only = FALSE, 
                         subgroup_only = FALSE, 
                         iqr = TRUE, 
                         median_summ = TRUE, 
                         cld = FALSE, # multiple comparison results 
                         caption, table_out_function = "kable", 
                         ...) 
{
  # browser()
  dots <- list(...)
  N <- NROW(data); P <- NCOL(data)

  out <- list()
  rgroup <- n.rgroup <- c()
  n_head <- as.numeric(with(data, eval(parse(text = paste0("table(", by, ")")))))
  n_head <- c(N, n_head)
  mydescribe_continuous_wrap <- function(...) mydescribe_continuous(..., iqr = iqr, median_summ = median_summ)
  
  for (varn in varname) {
    x <- data[[varn]]  
    digit <- digits
    if (is.factor(x)) digit <- 0
    summ_stat <- getT1Stat(data, by, varn, 
                           digits = digit, 
                           html = html, 
                           cont_fun = mydescribe_continuous_wrap)
    
    if (is.factor(x)) {
      # browser()
      test <- chisq.test(table(x, data[[by]]))
      test_crit <- sum(test$expected < 5)/prod(dim(test$expected))
      
      if (test_crit >= 0.2) {
        test <- fisher.test(table(x, data[[by]]), simulate.p.value = T)
        test_name <- "FE-test"
      } else{
        test_name <- ifelse(html,"&chi;<sup>2</sup>", "$\\chi^{2}$")
        test_sub <- ifelse(html, sprintf("<sub>df=%d</sub>", test$parameter), 
                           sprintf("_{%d}", test$parameter))
        test_name <- paste0(test_sub, test_name , "=", 
                            sprintf("%.1f", test$statistic))
      }
    }
    else {
      # browser()
      ngroup <- NCOL(summ_stat) - 1
      if (nrow(data) > 5000) {
        norm.crit <- 0
      } else{
        norm.test <- data %>% 
          select(by, varn) %>% 
          group_by(.dots = by) %>% 
          do(data.frame(p.value = shapiro.test(.[[varn]])$p.value))
        norm.test <- norm.test$p.value
        norm.crit <- sum(norm.test < 0.05)
      }
      
      fmla_chr <- paste0(varn, " ~ ", by)
      
      if (sum(n_head[-1]) == length(n_head[-1])) norm.crit <- 0
      
      if (norm.crit == 0) {
        test_name0 <- ifelse(ngroup > 2, "F", "t")
        oneway.test.wrap <- function(...) oneway.test(..., var.equal = var_equal)
        t.test.wrap <- function(...) t.test(..., var.equal = var_equal)
        test_fun <- ifelse(ngroup > 2, 
                           "oneway.test.wrap", 
                           "t.test.wrap")
        
        if (ngroup >2) equal.var <- eval(parse(text = paste0("car::leveneTest(", fmla_chr, ", data)")))
        else equal.var <- eval(parse(text = paste0("var.test(", fmla_chr, ", data)")))
        var_equal <- TRUE
        pval.var <- ifelse(ngroup > 2, equal.var$`Pr(>F)`, equal.var$p.value)
        if (pval.var < 0.05) var_equal <- FALSE
        
      } else {
        test_name0 <- ifelse(ngroup > 2, 
                            "KW-test", "W")
        test_fun <- ifelse(ngroup > 2, 
                           "kruskal.test", 
                           "wilcox.test")
      }
      
      test <- eval(parse(text = paste0(test_fun, "(", fmla_chr, ", data)")))
      
      if(ngroup > 2 & cld) {
        if (norm.crit == 0) {
          m <- lm(as.formula(fmla_chr), data = data)
          emm_m <- emmeans::emmeans(m, as.formula(paste0("~", by)))
          mcp_res <- emmeans::cld(emm_m, Letters = letters)
          mcp_res <- mcp_res[order(mcp_res[,1]), ]
          summ_update <- paste(summ_stat[1, 2:ncol(summ_stat)], mcp_res$.group)
          summ_stat[1, 2:ncol(summ_stat)] <- summ_update
        } else {
          summ_stat <- summ_stat
        }
      }

      if (html) 
        test_name <- ifelse(test_name0 == "F", 
                           sprintf("F<sub>%.1f, %.1f</sub>", 
                                   test$parameter[1], 
                                   test$parameter[2]), 
                    ifelse(test_name0 == "t", 
                           sprintf("t<sub>%.1f</sub>", 
                                   test$parameter), 
                    ifelse(test_name0 == "KW-test", 
                           sprintf("KW &chi;<sup>2</sup><sub>%d</sub>", 
                                   test$parameter), 
                           "W")))
      else
        test_name <- ifelse(test_name0 == "F", 
                           sprintf("F_{%.1f, %.1f}", 
                                   test$parameter[1], test$parameter[2]), 
                    ifelse(test_name0 == "t", 
                           sprintf("t_{%.1f}", test$parameter), 
                    ifelse(test_name0 == "KW-test", 
                           sprintf("$\\chi^{2}_{%d}$", 
                                   test$parameter), 
                           "W")))
      test_name <- paste0(test_name, "=", sprintf("%.1f", test$statistic))
    }
    if (!html) test_name <- sprintf("$%s$", test_name)
    pval <- ifelse(test$p.value < 0.000001, "< .000001", sprintf("= %.4f", test$p.value))
    test_stat <- paste0(test_name, ", p ", pval)
    
    results <- cbind(summ_stat, c(test_stat, rep("", NROW(summ_stat)-1)))
    
    if (html) 
      col_n <- paste(colnames(summ_stat), "<br/>", 
                     "(n=", n_head, ")", sep = "")
    else
      col_n <- paste("\\shortstack{", colnames(summ_stat), "\\", 
                     "(n=", n_head, ")", sep = "")
    
    colnames(results) <- c(col_n, "Test Statistic")
    
    list_name <- ifelse(Hmisc::label(data[[varn]]) == "", 
                        varn, Hmisc::label(data[[varn]]))
    rgroup <- c(rgroup, list_name)
    n.rgroup <- c(n.rgroup, NROW(summ_stat))
    out[[list_name]] <- results
  }
  # browser()
  if (sum(rgroup == "") == length(rgroup)) rgroup <- varname
  
  table_out <- do.call(rbind, out)
  if (total_only & !subgroup_only) 
    table_out <- table_out[, 1, drop = F]
  else if (subgroup_only & !total_only)
    table_out <- table_out[, 2:NCOL(table_out)]
  else if (total_only & subgroup_only)
    stop("At least summary statistics for total or subgroup must be chosen.")
  else
    table_out <- table_out
  
  align_str <- ifelse(total_only, 
                      "c", 
                      paste(c(rep("c", NCOL(table_out))), collapse = ""))
  table_function <- eval(parse(text = table_out_function))
  format <- ifelse(html, "html", "latex") 
  
  if(table_out_function == "kable") {
    output <- table_function(table_out, format = format, align = align_str,  
                             escape = FALSE, booktabs = TRUE, caption = caption) 
    if (format == "html")  
      output <- output %>% 
        kable_styling(bootstrap_options = c("condensed", "striped"), 
                     position = "center", font_size = 11)
    else
      output <- output %>% 
      kable_styling(latex_options = c("striped", "hold_position", "repeat_header"), 
                    position = "center", font_size = 8)
    
      for (i in 1:length(rgroup)) {
        output <- output %>% 
          pack_rows(rgroup[i], 
                    start_row = max(cumsum(n.rgroup[1:i])) - n.rgroup[i] + 1,
                    end_row = max(cumsum(n.rgroup[1:i])), 
                    indent = TRUE, escape = FALSE)
      }
  }    
  
  if (table_out_function == "htmlTable") {
    if (format == "html")
      output <- table_function(table_out, 
                              align = align_str, 
                              rgroup = rgroup, n.rgroup = n.rgroup, 
                              col.rgroup = c("none", "#F7F7F7"),
                              rowlabel = "", 
                              caption = caption, 
                              css.cell = "font-size: 0.9em;", 
                              ctable = TRUE)
    else stop("The function htmlTable only support for creating a table with html format.")
  }
      
    result_final <- list(table_data = table_out, 
                         rgroup = rgroup, 
                         n.rgroup = n.rgroup, 
                         table_output = output)
    return(result_final)

}

# mydesc_table(dm3, by = "sex", varname = varname, caption = "Demographic characteristics", table_out_function = "htmlTable")
# 
# 
# pair_comb <- combn(levels(data[[by]]), 2)
# pair_pval <- rep(NA, ncol(pair_comb))
# for (i in 1:ncol(pair_comb)) {
#   pgroup <- pair_comb[,i]
#   id <- rep(NA, nrow(data))
#   for (j in 1:length(pgroup)) {
#     idx <- which(data[[by]] == pgroup[j])
#     id[idx] <- idx
#   }
#   id <- id[complete.cases(id)]
#   x <- data[[by]][id]; x <- droplevels(x)
#   y <- data[[varn]][id]
#   wt_res <- wilcox.test(y ~ x)
#   pval <- wt_res$p.value
#   pair_pval[i] <- pval
# }
# pair_pval <- p.adjust(pair_pval, method = "fdr")
# mean_val <- gsub("\\s*\\([^\\)]+\\)", "", summ_stat[1, ])
# mean_val <- as.numeric(mean_val[-1])

