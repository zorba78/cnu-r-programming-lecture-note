#1F0699

#AB0707

#000000


gp_density <- function(data, x = x, fill = fill, alpha = alpha, 
                       col_fill = col_fill,
                       col_line = col_line, 
                       facet_formula = facet_formula, 
                       xlab = NULL, title = NULL, ...) {
  require(ggplot2)
  require(ggthemes)
  # browser()
  xname <- substitute(x)
  filln <- substitute(fill)
  
  aes.dens <- eval(substitute(aes(x = x, fill = fill), 
                              list(x = xname, 
                                   fill = filln)))
  gp <- ggplot(data = data) + 
    geom_density(aes.dens, alpha = alpha, 
                 colour = col_line, size = 0, adjust = 1.5) + 
    scale_fill_manual(values = col_fill)
  
  if (!is.null(facet_formula))
    gp <- gp + facet_grid(facet_formula, as.table = T, scales = "free_y")
  
  gp <- gp + 
    labs(x = xlab, title = title, y = NULL) + 
    theme_bw(base_size = 15) + 
    theme(plot.background = element_blank(), 
          panel.grid.minor = element_blank(), 
          panel.grid.major = element_blank())
  return(gp)
} 


gp_myviolin <- function(data, x, y, fill, col, group, 
                        col_fill, col_colour, 
                        alpha_dot, alpha_violin, 
                        facet_formula = NULL, 
                        width_violin,
                        width_jitter, 
                        dotsize, 
                        xlab = NULL, ylab = NULL, 
                        title = NULL, 
                        dotplot = FALSE, 
                        mean_sd = TRUE,
                        mean_line = TRUE, 
                        col_meanrange, 
                        col_meanline, 
                        base_size = 10, 
                        total = TRUE, ...) {
  require(ggplot2)
  require(ggthemes)
  
  # browser()
  xname <- substitute(x)
  yname <- substitute(y)
  fill_name <- substitute(fill)
  col_name <- substitute(col)
  group_name <- substitute(group)
  
  if (!is.null(facet_formula))
    if (!is.formula(facet_formula))
      stop("Facet formula (the rows on the LHS and the columns on the RHS) is required.")
  
  aes_map   <- eval(substitute(aes(x = x, y = y), 
                               list(x = xname, y = yname)))
  aes_fill  <- eval(substitute(aes(fill = fill), 
                               list(fill = fill_name)))
  aes_col   <- eval(substitute(aes(colour = colour), 
                               list(colour = col_name)))
  aes_group <- eval(substitute(aes(group = group, colour = colour), 
                               list(group = group_name,
                                    colour = col_name)))
  
  if (fill_name == col_name)
    legend_fill_name <- legend_col_name <- firstup(as.character(col_name))
  else {
    legend_fill_name <- firstup(as.character(fill_name))
    legend_col_name <- firstup(as.character(col_name))
  }
  
  gp <- ggplot(data = data) + aes_map
  
  if (dotplot)
    gp <- gp + 
    geom_dotplot(aes_fill,
                 binaxis = "y", stackdir = "center",
                 dotsize = dotsize,
                 binwidth = 1,
                 alpha = alpha_dot,
                 colour = "white")
  else
    gp <- gp + 
    geom_jitter(aes_col, 
                alpha = alpha_dot, 
                shape = 16, 
                # position = position_jitter(0.1)
                width = width_jitter, 
                size = dotsize)
  
  gp <- gp + geom_violin(aes_fill, 
                         trim = FALSE, 
                         width = width_violin, 
                         alpha = alpha_violin)
  
  if (mean_sd) 
    gp <- gp + 
    stat_summary(aes_col, 
                 fun.data = mean_sdl, 
                 geom = "pointrange", 
                 size = 0.4, shape = 15, colour = col_meanrange)
  
  if (mean_line)
    gp <- gp + stat_summary(aes_group, 
                            fun.y = "mean", 
                            geom = "line", 
                            linetype = "solid", 
                            size = 0.7, colour = col_meanline)
  
  gp <- gp + 
    scale_fill_manual(  name = legend_fill_name, 
                        values = col_fill) + 
    scale_colour_manual(name = legend_col_name, 
                        values = col_colour)
  
  if (!is.null(facet_formula))
    gp <- gp + facet_grid(facet_formula, margins = total)
  
  gp <- gp +   
    theme_bw(base_size = base_size) + 
    labs(x = xlab, 
         y = ylab, 
         title = title) + 
    theme(text = element_text(face = "bold"), 
          axis.ticks.x = element_blank())
  
  return(gp)
}

firstup <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  return(x)
}


# gp_myviolin(tmp, x = age_tgrp, y = value, 
#             fill = sex, col = sex, group = sex, 
#             col_fill = c("blue", "red", "black"), 
#             col_colour = c("blue", "red", "black"), 
#             alpha_dot = 0.3, 
#             alpha_violin = 0.2, 
#             dotsize = 0.9, 
#             # binwidth = 0.6, 
#             facet_formula = sex ~ intrvwr, 
#             width_violin = 0.7, 
#             title = unique(tmp$label_bia1))
