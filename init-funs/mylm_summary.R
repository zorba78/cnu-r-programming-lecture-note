my.lm_summary <- function(formula, data, summarise_by, adjust = "bonferonni", output = "html", ...)
{
  require(emmeans)
  require(car)
  browser()
  cl <- match.call()
  mf <- match.call(expand.dots = F)
  m <- match(c("formula", "data"), names(mf), 0L)
  mf <- mf[c(1L, m)]
  
  mf$drop.unused.levels <- TRUE
  mf[[1L]] <- quote(stats::model.frame)
  mf <- eval(mf, parent.frame())
  mt <- attr(mf, "terms")
  y <- model.response(mf, "numeric"); N <- length(y)
  bylev <-  with(mf, levels(eval(summarise_by[[2]])))
  bychar <- as.character(summarise_by[[2]])
  
  m0 <- lm(mt, data = mf); aovTab <- Anova(m0, type = "III")
  
  aovTab <- aovTab %>% mutate(term = row.names(.)) %>% 
    select(term, `Sum Sq`:`Pr(>F)`)
  names(aovTab)[1] <- " "
  
  emm0 <- emmeans(m0, eval(substitute(summarise_by)), data = mf)
  semm0 <- summary(emm0); temm0 <- test(emm0)
  semm0$p.value <- temm0$p.value
  
  cont.emm0 <- contrast(emm0, method = "trt.vs.ctrl", adjust = adjust); 
  cont.emm0s <- summary(cont.emm0)
  emm0.CI <- confint(cont.emm0, level = .95)
  emm0.CI <- cbind(emm0.CI, cont.emm0s[, 5:6])
  
  marginTab <- data.frame(semm0, emm0.CI); 
  degf <- unique(marginTab$df)
  
  marginTab.a <- marginTab %>%  
    mutate(p.sig1 = sprintf("%.4f", p.value)) %>%
    mutate(withind = sprintf("%.2f\n(%.2f, %.2f)", emmean, lower.CL, upper.CL)) %>% 
    select(c(bychar, "withind", "p.sig1"))
  marginTab.b <- marginTab %>% 
    mutate(p.sig2 = sprintf("%.4f", p.value.1)) %>%
    mutate(btwd = sprintf("%.2f\n(%.2f, %.2f)", estimate, lower.CL.1, upper.CL.1), 
           ESb = abs(2*t.ratio/sqrt(N))*sqrt(N/degf), 
           ESbc = sprintf("%.2f", ESb)) %>%
    select(c("contrast", "btwd", "p.sig2", "ESbc"))
  
}

#########################
# TEST
#########################

tmpdat <- dm %>% 
  select(usubjid, armcd) %>% 
  inner_join(vas_w, by = "usubjid") %>% 
  mutate(vas_diff = vas4 - vas2)

my.lm_summary(vas_diff ~ vas2 + armcd, data = tmpdat, summarise_by = ~ armcd)
