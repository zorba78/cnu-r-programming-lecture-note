#----------------------------------------------------------------------------------------------------------------------------#
# Misc function for exploratory data analysis for EEG data 
#----------------------------------------------------------------------------------------------------------------------------#

gp_stat_range <- function(data, 
                          x = x, 
                          y = y, 
                          y.min = y.min, 
                          y.max = y.max, 
                          col = col, 
                          group = group,
                          col_colour = NULL, 
                          alpha, 
                          facet_formula = NULL, 
                          facet_scale = "free_y", 
                          xlab = NULL, 
                          ylab = NULL, 
                          title = NULL, 
                          base_size = 15, 
                          position = 0.5)
{
  require(ggplot2)
  require(ggthemes)
  # browser()
  xname <- substitute(x)
  yname <- substitute(y)
  ymin_name <- substitute(y.min)
  ymax_name <- substitute(y.max)
  col_name <- substitute(col)
  group_name <- substitute(group)
  
  dat <- data
  if (!is.null(facet_formula))
    if (!is.formula(facet_formula))
      stop("Facet formula (the rows on the LHS and the columns on the RHS) is required.")
  
  aes_map   <- eval(substitute(aes(x = x, y = y), 
                               list(x = xname, y = yname)))
  aes_col   <- eval(substitute(aes(colour = colour), 
                               list(colour = col_name)))
  aes_group <- eval(substitute(aes(group = group, colour = colour), 
                               list(group = group_name,
                                    colour = col_name)))

  legend_col_name <- firstup(as.character(col_name))

  gp <- ggplot(data = dat) + 
    aes_map + 
    geom_point(aes_col, size = 5, 
               position = position_dodge(position)) + 
    scale_x_discrete(labels = function(x) str_wrap(x, width = 10))
  
  gp <- gp + 
    scale_color_manual(name = legend_col_name, 
                       values = col_colour) + 
    geom_hline(yintercept = 0, 
               size = 0.5, 
               linetype = "dashed", 
               color = "red")
  
  if (!is.null(facet_formula))
    gp <- gp + facet_grid(facet_formula, scales = facet_scale) 
  
  n_group <- length(unique(dat[[group_name]]))
  group_lev <- levels(dat[[group_name]])
  x_lev <- levels(dat[[xname]])
  n_xlev <- length(x_lev)

  # generate multiplication factor for the alignment 
  if ((n_group %% 2) == 0) {
    multfac <- c(rep(-1, n_group/2), rep(1, n_group/2))
  } else {
    multfac <- c(rep(-1, (n_group-1)/2), 0, rep(1, (n_group-1)/2))
  }
  idx_mat <- expand.grid(1:n_xlev, 1:n_group)  
    
  for (i in 1:ncol(idx_mat)) {
    idx_mat[,i] <- rep(c(1:n_xlev), each = n_group) + multfac[i]*position/n_xlev
  }
  
  ymin <- enquo(ymin_name)
  ymax <- enquo(ymax_name)
  dat$x_seg <- c(matrix(apply(idx_mat, 1, c), byrow = T))
  
  # browser()
  # geom segment for-loop 시 data에 dependent 하기 때문에 x,y가 objective dataset에 존재해야함. 
  for (i in 1:n_group) { 
    gp <- gp +
      geom_segment(aes(x = x_seg,
                       xend = x_seg,
                       y = !!ymin,
                       yend = !!ymax),
                   data = dat %>%
                     filter(!!enquo(group_name) == group_lev[i]),
                   lwd = 12,
                   alpha = alpha,
                   color = col_colour[i])
  }
  for (i in 1:n_group) {
    gp <- gp + 
      geom_text(aes(x = x_seg, 
                    y = !!sym(yname), 
                    label = sprintf("%.3f", !!sym(yname))), 
                data = dat %>% filter((!!enquo(group_name)) == group_lev[i]), 
                vjust = 2, 
                hjust = 0, 
                size = 5, 
                colour = col_colour[i], 
                fontface = "bold"
                )
  }

  # filter((!!sym(group_name)) == group_lev[i]),   
  gp <- gp + 
    labs(x = xlab, y = ylab) + 
    ggtitle(title) + 
    ggthemes::theme_tufte(base_size = base_size, 
                          base_family = "sans") + 
    theme(text = element_text(face = "bold", size = 15), 
          axis.text.x  = element_text(face="bold",  
                                      size=14,  
                                      colour="black"), 
          axis.text.y  = element_text(face="bold",  
                                      size=14,  
                                      colour="black"),
          title = element_text(size = 18), 
          axis.ticks.x = element_blank(),
          strip.text.x = element_text(size=20, 
                                      face="bold", 
                                      hjust=0),
          legend.text =  element_text(face = "bold"),
          legend.title = element_text(face = "bold"), 
          legend.position = "bottom")
  return(gp)
}

# gp_scatter <- 