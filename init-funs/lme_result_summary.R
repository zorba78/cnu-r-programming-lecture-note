info <- sessionInfo()
if (!("lme4" %in% info$otherPkgs)) require(lme4)
if (!("lmerTest" %in% info$otherPkgs)) require(lmerTest)
if (!("car" %in% info$otherPkgs)) require(car)
if (!("multcomp" %in% info$otherPkgs)) require(multcomp)

# mm <- lmer(value ~ group*visitnum_f + (1|randid), data = mkwomac_pp)
# summary(mm)
# 
# anova(mm)
# joint_tests(mm)


create_lm_model <- function(formula, # model formula
                            data,  # data frame
                            em_formula, # a formula to perform emmeans()
                            lm_function = c("lm", "lmer"), 
                            contr_method = "trt.vs.ctrl", 
                            adjust = "dunnett", 
                            cld = TRUE, 
                            ...)
{
  # browser()
  cl <- match.call()
  lm_function <- match.arg(lm_function)

  mod_fun <- eval(parse(text = lm_function))
  mod <- mod_fun(formula, data = data)
  
  if (lm_function == "lm") 
    aovtab <- car::Anova(mod, type = "III")
  else
    aovtab <- anova(mod)
  
  em_res <- emmeans(mod, em_formula, data = data)
  contr_em <- contrast(em_res, method = contr_method)
  
  mcp_res <- NULL
  if (cld){
    mcp_res <- cld(em_res, Letters = letters)
    mcp_res <- mcp_res[order(mcp_res[,1]), ]
  }
  
  out <- list(model = mod,
              lm_function = lm_function, 
              aov_tab = aovtab, 
              emmean = em_res, 
              contr  = contr_em, 
              formula = formula, 
              em_formula = em_formula, 
              contr_method = contr_method, 
              mcp_res = mcp_res, 
              adjust = adjust)
}

make_lm_tab <- function(obj, 
                        by, 
                        sig.level = 0.95, 
                        digits = 2, 
                        format = c("html", "word", "latex"), 
                        ...)
{ 
  # browser()
  var_include <- all.vars(obj$formula)
  df_emmean <- summary(obj$emmean)
  df_emmean_test <- test(obj$emmean)
  df_contr <- summary(obj$contr)
  # df_ci_contr <- confint(obj$contr, 
  #                        adjust = obj$adjust, 
  #                        level = sig.level)
  df_ci_contr <- confint(obj$contr)
  
  df_emmean$t.ratio <- df_emmean_test$t.ratio
  df_emmean$p.value <- df_emmean_test$p.value
  
  df_ci_contr$t.ratio <- df_contr$t.ratio
  df_ci_contr$p.value <- df_contr$p.value
  df_contr_out <- df_ci_contr
  
  # df_contr_out <-df_ci_contr %>% 
  #   inner_join(select(df_contr, 1:2, "t.ratio", "p.value"), 
  #              by = c("contrast", by))
  contr.name <- obj$contr@levels$contrast

  group_lev <- eval(parse(text = paste0("obj$contr@levels$", by)))
  n_contr <- length(contr.name)
  n_grp_lev <- length(group_lev)
  n.rgroup <- rep(n_contr, n_grp_lev)
  
  ##############################################
  # Table output data
  ##############################################
  
  blank <- ifelse(format == "html", "<br/>", 
                  ifelse(format == "word", "\n", "\\shortstack "))
  
  tab_emmean <- df_emmean %>% 
    mutate(EMM = paste0(htmlTable::txtRound(emmean, digits = digits),
                          blank, 
                          "(", 
                          htmlTable::txtRound(lower.CL, digits = digits),
                          ", ", 
                          htmlTable::txtRound(upper.CL, digits = digits),
                          ")"), 
           t.ratio = txtRound(t.ratio, digits = 2), 
           p.value = ifelse(p.value < 0.0001, "<0.0001", 
                            txtRound(p.value, digits = 4))) %>% 
    select(1:2, EMM, t.ratio, p.value) %>%
    gather(stat, out, EMM:p.value) %>% 
    mutate(stat = factor(stat, levels = unique(stat))) %>% 
    spread(by, out)
  
  tab_contr <- df_contr_out %>% 
    mutate(MD = paste0(htmlTable::txtRound(estimate, digits = digits),
                       blank, 
                       "(", 
                       htmlTable::txtRound(lower.CL, digits = digits),
                       ", ", 
                       htmlTable::txtRound(upper.CL, digits = digits),
                       ")"), 
           t.ratio = htmlTable::txtRound(t.ratio, digits = 2), 
           p.value = ifelse(p.value < 0.0001, "<0.0001", 
                            txtRound(p.value, digits = 4))) %>% 
    select(1:2, MD, t.ratio, p.value) %>%
    gather(stat, out, MD:p.value) %>% 
    mutate(stat = factor(stat, levels = unique(stat))) %>% 
    spread(by, out)
  
  df_contr_out2 <- df_contr_out
  for (i in 1:length(n.rgroup)) {
    df_contr_out2 <- df_contr_out2 %>% 
      add_row(contrast = NA, 
              .before =  max(cumsum(n.rgroup[1:i])) - n.rgroup[i] + i)
  }
  # df_merge <- data.frame(df_emmean, df_contr_out2)
  
  out <- list(emmean_raw = df_emmean, 
              contr_raw = df_contr_out, 
              # out_merge = df_merge, 
              tab_emmean = tab_emmean, 
              tab_contr = tab_contr)
  return(out)
}

lm_contrast_summary <- function(formula, 
                                data, 
                                em_formula, 
                                lm_function = c("lm", "lmer"), 
                                contr_method = "trt.vs.ctrl", 
                                adjust = "dunnett", 
                                cld = TRUE, 
                                by, 
                                sig.level = 0.95, 
                                digits = 2, 
                                format = c("html", "word", "latex"), 
                                table_out_function = c("kable", "htmlTable", "flextable"), 
                                caption = "test", # table caption
                                fn = "") # footnote
{
  lm_function <- match.arg(lm_function)
  format <- match.arg(format)
  table_out_function <- match.arg(table_out_function)
  
  # browser()
  mod_res <- create_lm_model(formula = formula, 
                             data = data, 
                             em_formula = em_formula, 
                             lm_function = lm_function, 
                             contr_method = contr_method, 
                             adjust = adjust, 
                             cld = cld)
  tab_res <- make_lm_tab(mod_res, 
                         by = by, 
                         sig.level = sig.level, 
                         digits = digits, 
                         format = format)
  
  rgroup_ref <- names(tab_res$emmean_raw)[1]
  group_lev <- eval(parse(text = paste0("levels(mod_res$emmean)$", rgroup_ref)))
  group_lev <- as.character(group_lev)
  by_lev <- eval(parse(text = paste0("mod_res$contr@levels$", by)))
  by_lev <- as.character(by_lev)

  # rgroup <- eval(parse(text = paste0("unique(tab_out$", rgroup_ref, ")")))
  tab_em <- tab_res$tab_emmean %>% 
    as_grouped_data(groups = c(rgroup_ref), 
                    columns = NULL)
  row_idx <- as.numeric(rownames(tab_em))
  tab_ct <- tab_res$tab_contr %>% 
    as_grouped_data(groups = "contrast", 
                    columns = NULL)
  
  tab_em <- tab_em %>% rowid_to_column()
  tab_ct <- tab_ct %>% rowid_to_column()
  tab_ct$rowid <- with(tab_ct, rowid + length(unique(tab_ct$stat)))
  # browser()
  tab_out <- tab_em %>% 
    left_join(tab_ct, by = "rowid") %>% 
    select(-rowid)
  
  tab_out <- tab_out %>% 
    mutate(stat.x = factor(stat.x, 
                           labels = c("MD\n    (95% CI)", 
                                      "p-value", 
                                      "t-value"))) %>% 
    mutate(stat.y = factor(stat.y, 
                           labels = c("MD\n    (95% CI)", 
                                      "p-value", 
                                      "t-value"))) %>%    
    mutate_all(list(~as.character(.))) %>% 
    mutate_all(list(~ifelse(is.na(.), "", .)))
  
  table_function <- eval(parse(text = table_out_function))
  
  if (table_out_function == "flextable") {
    if (format == "latex")
      stop("flextable only supports for creating a table with html and word format.")
    else {
      stat1 <- paste("   ", tab_out$stat.x)
      stat2 <- paste("   ", tab_out$stat.y)
      tab_out$stat.x <- stat1
      tab_out$stat.y <- stat2
      
      table_out <- tab_out
      rownames(table_out) <- row_idx
      # table_out <- as_grouped_data(tab_out, groups = rgroup_ref, columns = NULL)
      colkey <- names(tab_out)
      
      g1.start <- which(names(table_out) == "stat.x")
      g2.start <- which(names(table_out) == "stat.y")
      typology <- data.frame(col_keys = c("sep1", "sep2", colkey), 
                             colB = c(rep(" ", 4), 
                                      rep("Estimated marginal mean", length(by_lev)), 
                                      rep(" ", 2), 
                                      rep("Contrasts", length(by_lev))), 
                             colA = c(rep(" ", 4), 
                                      by_lev, 
                                      rep(" ", 2), 
                                      by_lev), 
                             stringsAsFactors = F)
      output <- table_function(table_out, 
                               col_keys = c(colkey[1:(g2.start-2)], 
                                            "sep1", 
                                            colkey[(g2.start-1):length(colkey)]))
      output <- output %>% 
        set_header_df(mapping = typology, 
                      key = "col_keys") %>% 
        merge_h(part = "header") %>% 
        hline(i = 1, 
              j = c(g1.start:(g2.start-2),
                    (g2.start+1):length(colkey)),  
              part = "header", 
              border = std_border) %>% 
        align(j=c(1:2, g2.start:(g2.start+1)), 
                  align = "left") %>% 
        align(j=g1.start:(g2.start-2), 
              align = "center", 
              part = "all") %>% 
        align(j=(g2.start+2):(length(colkey)+1), 
               align = "center", 
               part = "all") %>% 
        merge_v(j=c(1, g2.start), part = "body") %>% 
        bold(j=c(1, g2.start)) %>% 
        width(j = g2.start-1, width = 0.1) %>% 
        myborder
      
      rnam <- as.numeric(rownames(output$body$dataset))
      
      for (i in 1:length(group_lev)) {
        idx1 <- which(rnam == i)
        output <- output %>% 
          merge_h_range(i = idx1, 
                        j1 = 1, 
                        j2 = g2.start-1) %>% 
          merge_h_range(i = idx1, 
                        j1 = g2.start, 
                        j2 = length(colkey)+1)
      }
      
      output <- output %>% 
        add_footer_row(values = fn, top = FALSE, 
                       colwidths = length(colkey)+1) %>% 
        merge_at(j = 1:(length(colkey)+1), part = "footer") %>% 
        align(align = "left", part = "footer") %>% 
        myFont(size = 9) %>% 
        set_caption(caption) %>% 
        empty_blanks(.)
    }
  }  
  
  result_final <- list(table_data = tab_out, 
                       table_output = output, 
                       model_out = mod_res, 
                       em_out = tab_res)
  return(result_final)
}

# tmpdat <-mkwomac_pp %>%
#   rename(GROUP = group) %>%
#   mutate(visitnum_f = gsub("\n", " ", visitnum_f),
#          visitnum_f = factor(visitnum_f,
#                              levels = unique(visitnum_f)))
# 
# tmp <- lm_contrast_summary(value ~ GROUP*visitnum_f + (1|randid),
#                            data = tmpdat,
#                            em_formula = ~ visitnum_f|GROUP,
#                            lm_function = "lmer",
#                            cld = FALSE,
#                            by = "GROUP",
#                            digits = 1,
#                            format = "word",
#                            table_out_function = "flextable")
# 
# tmp <- create_lm_model(value ~ GROUP*visitnum_f + (1|randid), 
#                        data = tmpdat,
#                        em_formula = ~ visitnum_f|GROUP,
#                        lm_function = "lmer")
# 
# make_lm_tab(tmp, by = "GROUP", format = "word")



