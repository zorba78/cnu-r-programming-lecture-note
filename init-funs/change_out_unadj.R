#--------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# RCT-out-table with effect size based on unadjusted results (univariate case)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------#

change_out_unadj <- function(formula, data, group, reflev = "Placebo", digits = 2, format = c("html", "word", "latex"), ...)
{ 
  out <- list()
  cl <- match.call()
  mf <- match.call(expand.dots = F)
  m <- match(c("formula", "data"), names(mf), 0L)
  mf <- mf[c(1L, m)]
  mf$drop.unused.levels <- TRUE
  mf[[1L]] <- quote(stats::model.frame)
  mf <- eval(mf, parent.frame())
  mt <- attr(mf, "terms")
  y <- model.response(mf, "numeric"); N <- length(y)
  n.group <- as.numeric(table(data[[group]]))
  
  # normality check
  nlev <- length(levels(data[[group]]))
  varn <- as.character(formula[[2]])
  norm.test <- data %>% 
    select(group, varn) %>% 
    group_by(.dots = group) %>% 
    do(data.frame(p.value = shapiro.test(.[[varn]])$p.value))
  norm.test <- norm.test$p.value
  norm.crit <- sum(norm.test < 0.05)
  
  # browser()
  # check homogenity of variances 
  # If unequal variances among groups, calculate weights and perform weighted least squares
  varn_sym <- sym(varn)
  fmla_group <- update(formula, as.formula(paste("~",group)))
  varTest <- car::leveneTest(fmla_group, data = mf)
  var_equal <- varTest$`Pr(>F)`[1] > 0.05
  weight <- mf %>% 
    group_by(.dots = group) %>% 
    summarise(w = 1/var(!!varn_sym))
  w <- rep(weight$w, n.group)
  mf$w <- w
  m0 <- lm(formula, data = mf)
  # if (var_equal)
  #   m0 <- lm(formula, data = mf)
  # else
  #   m0 <- lm(formula, data = mf, weights = w)
  
  # browser()
  # Estimated marginal means 
  emm0 <- emmeans(m0, as.formula(paste0("~", group)), data = mf)
  s_emm0 <- summary(emm0)
  contr0 <- contrast(emm0, "trt.vs.ctrl", data = mf)
  s_contr0 <- summary(contr0)
  ci95d <- confint(contr0, level = .95)
  
  # calculate effect size between a pair of two groups
  pair_n <- combn(n.group, 2)
  pair_lev <- combn(levels(mf[[group]]), 2)
  idx <- c()
  for (i in 1:2) {
    a <- which(pair_lev[i, ] == reflev)
    idx <- c(idx, a)
  }
  ni <- pair_n[, idx]
  pair_lev2 <- as.matrix(pair_lev[, idx])
  
  if (sum(ncol(ni)) == 0) {
    n_bar <- sum(ni)/2
    n_h <- 2*prod(ni)/sum(ni)
  }
  else {
    n_bar <- apply(ni, 2, function(x) sum(x)/2)
    n_h <- apply(ni, 2, function(x) 2*prod(x)/(sum(x)))
  }
    
  ESb <- with(s_contr0, abs((2*t.ratio/sqrt(df))*sqrt(n_bar/n_h)))
  
  # browser()
  if (norm.crit == 0) {
    p_value <- s_contr0$p.value
  } else {
    p_value <- rep(NA, ncol(pair_lev2))
    for (i in 1:ncol(pair_lev2)) {
      pgroup <- pair_lev2[, i]
      id <- rep(NA, N)
      for (j in 1:length(pgroup)) {
        idx <- which(mf[[group]] == pgroup[j])
        id[idx] <- idx
      }
      id <- id[complete.cases(id)]
      xx <- mf[[group]][id]; xx <- droplevels(xx)
      yy <- mf[[varn]][id]
      pval <- wilcox.test(yy ~ xx)$p.value
      p_value[i] <- pval
    }
    p_value <- p.adjust(p_value, method = "bonferroni")
  }
  
  if (length(formula[[3]]) > 1) {
    p_value <- s_contr0$p.value
  }
  
  # browser()
  ## output setting
  bdelta_char <- ifelse(format == "html", "&delta;&#772;", 
                 ifelse(format == "word", "\\delta\\bar", 
                        "$\\bar\\delta$"))
  pm_char <- ifelse(format == "html", "&plusmn;", 
             ifelse(format == "word", "±", "$\\pm$"))
  bDelta_char <- ifelse(format == "html", "&Delta;&#772;", 
                 ifelse(format == "word", "\\Delta\\bar", "$\\bar\\Delta$"))
  bGamma_char <- ifelse(format == "html", "&Gamma;&#772;", 
                 ifelse(format == "word", "\\Gamma\\bar", "$\\bar\\Gamma$"))
  ci_char <- ifelse(format == "latex", "95 \\% CI", "95 % CI")
  star_char <- ifelse(format == "html", "*", 
                 ifelse(format == "word", "*", "$^*$"))
  pval_char <- ifelse(norm.crit == 0, "p-value", 
                      paste0("p-value", star_char))
  blank <- ifelse(format == "html", "<br/>", 
           ifelse(format == "word", "\n", "\\shortstack "))
  
  row_name_1 <- c(bdelta_char, 
                  ci_char, 
                  "Median", 
                  "[min, max]")
  row_name_2 <- c(bDelta_char, 
                  ci_char, 
                  pval_char, 
                  bGamma_char)
  
  header1 <- paste0(levels(mf[[group]]), 
                    blank, 
                    "(n=", 
                    n.group, ")")
  # browser()
  if (sum(ncol(ni)) == 0) {
    id <- which(pair_lev2 != reflev)
    header2 <- paste(pair_lev2[id], reflev, sep = " - ")
  } else {
    header2 <- apply(pair_lev2, 2, function(x) paste(x[2], reflev, sep = " - ")) 
  }
  ## create table
  ds_out <- mf %>% 
    group_by(.dots = group) %>% 
    summarise(SD = sd(!!varn_sym, na.rm = T), 
              Med = median(!!varn_sym, na.rm = T), 
              Min = min(!!varn_sym, na.rm = T), 
              Max = max(!!varn_sym, na.rm = T))
  sd_out <- ds_out$SD
  
  bdelta <- sprintf("%s (%s%s)", 
                    txtRound(s_emm0$emmean, digits = digits), 
                    pm_char, 
                    txtRound(sd_out, digits = digits)) # within mean difference
  ci_95w <- sprintf("(%s, %s)", 
                    txtRound(s_emm0$lower.CL, digits = digits), 
                    txtRound(s_emm0$upper.CL, digits = digits))
  med_w <- sprintf("%s", 
                   txtRound(ds_out$Med, digits = digits))
  minmax_w <- sprintf("[%s, %s]",
                   txtRound(ds_out$Min, digits = digits), 
                   txtRound(ds_out$Max, digits = digits))
  bDelta <- sprintf("%s", 
                    txtRound(s_contr0$estimate, digits = digits))
  ci_95d <- sprintf("(%s, %s)", 
                    txtRound(ci95d$lower.CL, digits = digits), 
                    txtRound(ci95d$upper.CL, digits = digits))
  p_value_d <- txtRound(p_value, digits = 4)
  bGamma <- sprintf("%s", 
                    txtRound(ESb, digits = 3))
  
  varlab <- ifelse(label(data[[varn]]) == "", varn, label(data[[varn]]))
  out_1 <- data.frame(rbind(bdelta, ci_95w, med_w, minmax_w), row.names = NULL)
  names(out_1) <- header1
  out_2 <- data.frame(rbind(bDelta, ci_95d, p_value_d, bGamma), row.names = NULL)
  names(out_2) <- header2
  
  # browser()
  result <- data.frame(`Statistic 1` = row_name_1,
                       out_1,
                       `Statistic 2` = row_name_2,
                       out_2,
                       check.names = F)
  out <- list(rgroup =varlab, 
              result=result, 
              n.rgroup = nrow(result), 
              weighted = var_equal, 
              data = mf, 
              model = m0, 
              em_mean = emm0, 
              contr_mod = contr0, 
              effect_size_group = ESb)
  return(out)
}

table_change_unadj <- function(formula, 
                               data, outcomes, group, 
                               reflev = "Placebo", 
                               digits = 2, 
                               format = c("html", "word", "latex"), 
                               table_out_function = c("kable", "htmlTable", "flextable"), 
                               caption = "test", 
                               fn = "",
                               ...)
{

  info <- sessionInfo()
  if (!("tidyverse" %in% info$otherPkgs)) require(tidyverse)
  if (!("Hmisc" %in% info$otherPkgs)) require(Hmisc)
  if (!("emmeans" %in% info$otherPkgs)) require(emmeans)
  if (!("kableExtra" %in% info$otherPkgs)) require(kableExtra)
  if (!("htmlTable" %in% info$otherPkgs)) require(htmlTable)
  if (!("officer" %in% info$otherPkgs)) require(officer)
  if (!("flextable" %in% info$otherPkgs)) require(flextable)
  nlev <- nlevels(data[[group]])
  
  # browser()
  fmla_str <- paste(outcomes, paste(as.character(formula), collapse = " "))
  format <- match.arg(format)
  # browser()
  table_out <- sapply(fmla_str, function(fm) {
    fm <- as.formula(fm)
    out <- change_out_unadj(fm, data = data, group = group, 
                            reflev =reflev, digits = digits, 
                            format = format)
    })
  rgroup <- do.call(c, table_out[1, ])
  n.rgroup <- do.call(c, table_out[3, ])
  weight <- do.call(c, table_out[4, ])
  out_tmp <- table_out
  table_out <- data.frame(do.call(rbind, table_out[2, ]), 
                          row.names = NULL, 
                          stringsAsFactors = F, 
                          check.names = F)

  align_str <- paste(c(rep("c", NCOL(table_out))), collapse = "")
  table_function <- eval(parse(text = table_out_function))
  # browser()
  if (table_out_function == "kable") {
    output <- table_function(table_out, format = format, align = align_str,  
                             escape = FALSE, booktabs = TRUE, caption = caption) 
    if (format == "html") 
      output <- output %>% 
        kable_styling(bootstrap_options = c("condensed", "bordered"), 
                      position = "center", font_size = 11)
    else if (format == "latex")
      output <- output %>% 
        kable_styling(latex_options = c("striped", "hold_position", "repeat_header"), 
                      position = "center", font_size = 8)
    else stop("kable does not support for creating a table in the word document format!!")
    
    for (i in 1:length(rgroup)) {
      output <- output %>% 
        pack_rows(rgroup[i], 
                  start_row = max(cumsum(n.rgroup[1:i])) - n.rgroup[i] + 1,
                  end_row = max(cumsum(n.rgroup[1:i])), 
                  indent = TRUE, escape = FALSE)
    }
    
    output <- output %>% 
      add_header_above(c("Mean Changes within Group" = nlev+1, "Group difference" = nlev)) %>% 
      footnote(general = fn, 
               symbol = c("Obtained based on Wilcoxon's rank sum test."), 
               escape = F)
  }
  
  if (table_out_function == "htmlTable") {
    n_align_str <- nchar(align_str)
    str_sub(align_str, nlev+2, nlev+1) <- "||"
    table_out_m <- as.matrix(table_out)
    rownames(table_out_m) <- table_out_m[,1]
    table_out_m <- table_out_m[,-1]
    if (format == "html")
      output <- table_function(table_out_m, 
                               align = align_str, 
                               # rnames = FALSE, 
                               cgroup = c("Mean Changes within Group", "Group Difference"), 
                               n.cgroup = c(nlev, nlev),
                               rgroup = rgroup, 
                               n.rgroup = n.rgroup, 
                               col.rgroup = c("none", "#F7F7F7"),
                               rowlabel = "", 
                               caption = caption, 
                               css.cell = "font-size: 0.9em;", 
                               ctable = TRUE, 
                               tfoot = fn)
    else stop("The function htmlTable only support for creating a table with html format.")
    
  }
  
  if (table_out_function == "flextable") {
    if (format == "latex")
      stop("flextable only supports for creating a table with html and word format.")
    else {
      # browser()
      stat1 <- as.character(table_out[,1])
      stat1 <- paste("   ", stat1)
      table_out[,1] <- stat1
      table_out <- data.frame(var = rep(rgroup, n.rgroup), 
                              table_out, 
                              check.names = F, 
                              stringsAsFactors = F)
      if (length(outcomes) > 1)
        table_out <- as_grouped_data(table_out, groups = "var", columns = NULL)
      colkey <- names(table_out)
      g1.start <- which(names(table_out) == "Statistic 1")
      g2.start <- which(names(table_out) == "Statistic 2")
      typology <- data.frame(col_keys = c("sep1", colkey), 
                             colB = c(" ", " ", rep(c("Mean change within a group", 
                                                      "Group difference of mean change"), 
                                                    c(nlev+1, nlev))), 
                             colA = c(" ", " ", colkey[g1.start:length(colkey)]), 
                             stringsAsFactors = F) 
      output <- table_function(table_out, col_keys = c(colkey[1:(g2.start-1)], 
                                                    "sep1", 
                                                    colkey[(g2.start):length(colkey)])) %>% 
        set_header_df(mapping = typology, key = "col_keys") %>% 
        merge_h(part = "header") %>% 
        hline(i = 1, j = c(g1.start:(g2.start-1)), 
              part = "header", border = std_border) %>% 
        hline(i = 1, j = c((g2.start+1):(ncol(table_out)+1)), 
              part = "header", border = std_border) %>% 
        align(j = 1:2, align = "left") %>% 
        align(j = g2.start, align = "left") %>% 
        align(j = g1.start:(g2.start-1), align = "center", part = "all") %>% 
        align(j = g2.start:(ncol(table_out)+1), align = "center", part = "all") %>% 
        merge_v(j = 1, part = "body") %>% 
        bold(j = 1) %>% 
        width(j = g2.start, width = 0.1) %>% 
        myborder %>% 
        empty_blanks(.)
      
      rnam <- as.numeric(rownames(output$body$dataset))
      
      if (length(outcomes) > 1) {
        for (i in 1:length(rgroup)) {
          idx <- which(rnam == i)
          output <- output %>% 
            merge_h_range(i = idx, j1 = 1, j2 = NCOL(table_out)+1)
        }
      }
      
      output <- output %>% 
        add_footer(var = fn) %>% 
        merge_at(j = 1:(ncol(table_out)+1), part = "footer") %>% 
        align(align = "left", part = "footer") %>% 
        myFont(size = 9) %>% 
        set_caption(caption)
      
    }
  }
  
  result_final <- list(table_data = table_out, 
                       rgroup = rgroup, 
                       n.rgroup = n.rgroup, 
                       table_output = output, 
                       model = out_tmp[6,], 
                       em_mean = out_tmp[7,], 
                       contr_mod = out_tmp[8,], 
                       effect_size_group = out_tmp[9,],
                       data = out_tmp[5,])
  
  return(result_final)
}
