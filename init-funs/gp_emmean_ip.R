#----------------------------------------------------------------------------------------------------------#
# Functions related to create a interaction plot and mean change plots
# Input data: emmean outcomes
#----------------------------------------------------------------------------------------------------------#

.all.vars = function(expr, retain = c("\\$", "\\[\\[", "\\]\\]", "'", '"'), ...) {
  if (is.null(expr))
    return(character(0))
  if (!inherits(expr, "formula")) {
    expr = try(eval(expr), silent = TRUE)
    if(inherits(expr, "try-error")) {
      return(character(0))
    }
  }
  repl = paste(".Av", seq_along(retain), ".", sep = "")
  for (i in seq_along(retain))
    expr = gsub(retain[i], repl[i], expr)
  subs = switch(length(expr), 1, c(1,2), c(2,1,3))
  vars = all.vars(as.formula(paste(expr[subs], collapse = "")), ...)
  retain = gsub("\\\\", "", retain)
  for (i in seq_along(retain))
    vars = gsub(repl[i], retain[i], vars)
  if(length(vars) == 0) vars = "1"   # no vars ---> intercept
  vars
}

### parse a formula of the form lhs ~ rhs | by into a list
### of variable names in each part
### Returns character(0) for any missing pieces
.parse.by.formula = function(form) {
  allv = .all.vars(form)
  ridx = ifelse(length(form) == 2, 2, 3)
  allrhs = as.character(form)[ridx]
  allrhs = gsub("\\|", "+ .by. +", allrhs) # '|' --> '.by.'
  allrhs = .all.vars(stats::reformulate(allrhs))
  bidx = grep(".by.", allrhs, fixed = TRUE)
  if (length(bidx) == 0) { # no '|' in formula
    by = character(0)
    rhs = allrhs
  }
  else {
    rhs = allrhs[seq_len(bidx[1] - 1)]
    by = setdiff(allrhs, c(rhs, ".by."))
  }
  lhs = setdiff(allv, allrhs)
  list(lhs = lhs, rhs = rhs, by = by)
}

get_axis_range <- function(ggobj, ...) {
  x_range <- ggplot_build(ggobj)$layout$panel_params[[1]]$x.major_source
  y_range <- ggplot_build(ggobj)$layout$panel_params[[1]]$y.major_source
  return(list(x_range = x_range, y_range = y_range))
}

get_val_range <- function(ggobj, ...) {
  x_range <- ggplot_build(ggobj)$layout$panel_params[[1]]$x.range
  y_range <- ggplot_build(ggobj)$layout$panel_params[[1]]$y.range
  return(list(x_range = x_range, y_range = y_range))
}

gp_emmean_plot <- function(obj, 
                         formula, 
                         type = c("interaction", "contrast"), 
                         x_label = NULL, 
                         col = NULL, 
                         linetype = NULL, 
                         xlab = NULL, 
                         ylab = NULL,
                         title = NULL, 
                         legend.name = "Group", 
                         facet.scale = "free_y", 
                         facet.cols = 3, 
                         pos = 0.9, 
                         ...)
{
  
  type <- match.arg(type)
  spec <- .parse.by.formula(formula)
  xvars <- spec$rhs
  tvars <- spec$lhs
  byvar <- spec$by

  if (type == "interaction") {
    yvar <- "emmean"
    dat <- obj$em_out$emmean_raw
  }
  else {
    yvar <- "estimate"
    dat <- obj$em_out$contr_raw
  }
  nm <- names(dat)
  tgts <- c(attr(dat, "estName"), attr(dat, "clNames"))
  subs = c("yvar", "LCL", "UCL")
  for (i in 1:3)
    names(dat)[nm == tgts[i]] <- subs[i] 
  attr(dat, "estName") <- "yvar"

  if (one.trace <- (length(tvars) == 0)) {
    tlab = ""
    tvars = ".single."
    dat$.single. = 1
    my.key = function(tvars) list()
    group_lev <- levels(dat[[byvar]])
  }
  else {
    tlab = paste(tvars, collapse = ":")
    my.key = function(tvars) 
      list(space="right", 
           title = paste(tvars, collapse=" * "), 
           points = TRUE, 
           lines=length(lty) > 1,
           cex.title=1)
    group_lev <- levels(dat[[tvars]])
  }

  tv <- do.call(paste, unname(dat[tvars]))
  n_tv <- length(unique(tv))
  dat$tvar <- factor(tv, levels = unique(tv))
  
  # browser()
  max_grp <- dat$tvar[which(dat$yvar == max(dat$yvar))]
  min_grp <- dat$tvar[which(dat$yvar == min(dat$yvar))]
  
  if (max_grp == min_grp) min_grp <- levels(dat$tvar)[!grepl(min_grp, levels(dat$tvar))]

  if (type == "interaction") {
    if (is.null(x_label))
      xv <- do.call(paste, unname(dat[xvars]))
    else {
      if (n_tv > 1)
        xv <- rep(x_label, times = n_tv)
      else
        xv <- rep(x_label, times = length(unique(dat[[byvar]])))
    }
    
    dat$xvar <- factor(xv, levels = unique(xv))
    dat <- dat[order(dat[[xvars]]), ]
  }
  # browser()
  if (type == "contrast") {
    xv <- do.call(rbind, 
                  str_split(dat[[xvars]], " - "))
    xb <- unique(xv[,2])
    xv <- xv[,1]
    xv2 <- unique(c(xb, xv))
    dat$xvar <- factor(xv, levels = unique(xv))
    dat <- dat[order(dat[[xvars]]), ]
    for (i in 1:length(group_lev)) {
      if (one.trace) {
        dat <- dat %>% 
          add_row(xvar = xb, yvar = 0, 
                  tvar = 1, .single. = 1, 
                  .before = 1)
      } 
      else 
        dat <- dat %>% 
          add_row(xvar = xb, yvar = 0, .before = 1)
    }
    dat$xvar <- factor(dat$xvar, levels = xv2)
    n_lv <- length(xv2)
    if (!one.trace)
      dat$tvar <- factor(rep(unique(tv), times = n_lv), levels = unique(tv))
    else
      dat[[byvar]] <- factor(rep(group_lev, times = length(unique(dat$xvar))), levels = group_lev)
  }

  if (type == "interaction")
    pos <- position_dodge(pos)
  else
    pos <- position_dodge(0)

  if (!one.trace) {
    ggobj <- ggplot(data = dat) + 
      aes_(x = ~ xvar, y = ~yvar, color = ~tvar) + 
      geom_line(aes_(group = ~tvar, 
                   linetype = ~tvar), 
              size = 1, 
              position = pos)
    if (type == "interaction") {
      ggobj <- ggobj + 
        geom_errorbar(aes_(ymin = ~LCL, 
                           ymax = ~UCL), 
                      width = 0, 
                      size = 1, 
                      position = pos)
    } else {
      ggobj <- ggobj + 
        geom_errorbar(aes_(ymin = ~yvar, 
                           ymax = ~UCL), 
                      data = dat[dat$tvar==max_grp, ], 
                      width = 0.04, 
                      size = 1) + 
        geom_errorbar(aes_(ymin = ~LCL, 
                           ymax = ~yvar), 
                      data = dat[dat$tvar==min_grp, ],
                      width = 0.04, 
                      size = 1)
    }
    ggobj <- ggobj + 
      geom_point(size = 6, 
                 shape = 15, 
                 position = pos)
  } else {
    ggobj <- ggplot(data = dat) + 
      aes_(x = ~ xvar, y = ~yvar) + 
    geom_line(aes_(group = ~tvar), 
              size = 1)
    if (type == "interaction") {
      ggobj <- ggobj + 
        geom_errorbar(aes_(ymin = ~LCL, 
                           ymax = ~UCL), 
                      width = 0, 
                      size = 1)
    }  
    ggobj <- ggobj + 
      geom_point(size = 6, 
                 shape = 15)
  }

  range_xy <- get_axis_range(ggobj)
  val_xy <- get_val_range(ggobj)

  x_range <- range_xy$x_range
  y_range <- range_xy$y_range
  
  xval_range <- val_xy$x_range
  yval_range <- val_xy$y_range
  
  ggobj <- ggobj + 
    scale_y_continuous(limits = c(min(yval_range), max(yval_range)), 
                       breaks = y_range)
  
  ggobj <- ggobj + 
    geom_segment(aes_(x = min(x_range), 
                      xend = max(x_range), 
                      y = -Inf, 
                      yend = -Inf), 
                 lwd = 0.5, 
                 colour = "black")
  ggobj <- ggobj + 
    geom_segment(aes_(x = -Inf, 
                      xend = -Inf, 
                      y = min(y_range), 
                      yend = max(y_range)), 
                 lwd = 0.5, 
                 colour = "black")
  
  if (!is.null(linetype))
    ggobj <- ggobj + scale_linetype_manual(name = legend.name, 
                                           values = linetype)
  if (!is.null(col))
    ggobj <- ggobj + scale_color_manual(name = legend.name,
                                        values = col)
  if (!is.null(xlab))
    ggobj <- ggobj + ggplot2::xlab(xlab)
  if (!is.null(ylab))
    ggobj <- ggobj + ggplot2::ylab(ylab)
  if (!is.null(title))
    ggobj <- ggobj + ggtitle(title)
  
  if (length(byvar) > 0) {  # we have by variables 
    # if (length(byvar) > 1) {
    #   byform <- as.formula(paste(" ~ ", byvar[1], paste(byvar[-1], collapse="*")))
    #   ggobj <- ggobj + facet_grid(byform, scale = facet.scale)
    # }
    # else 
      ggobj <- ggobj + facet_wrap(byvar, scale = facet.scale, ncol = facet.cols)
  }
  return(list(graph = ggobj, data = dat))
}



