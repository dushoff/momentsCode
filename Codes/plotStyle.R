## legend guides parameters
xpos <- 0.85; ypos <- 0.25
stdvShape <- 8; muRcShape <- 19
kwithShape <- 0; kbetShape <- 17
legendFontSize <- 8; legendTitleFontSize <- 9
xlabelFontSize <- 12; ylabelFontSize <- 12
linewidth = 0.8; linetype = "dashed"; alpha = 0.3
barwidth = 0.25
linewidth_moments <- 0.1
theme_set(theme_bw() + theme(
  plot.background = element_blank(),
  panel.grid = element_blank(),
  axis.title.x = element_text(size = xlabelFontSize),
  axis.title.y = element_text(size = ylabelFontSize)
))
update_geom_defaults("line", list(
  linewidth = 1     
))
update_geom_defaults("vline", list(
  linewidth = 0.5
  ,linetype = "dotted"
))
update_geom_defaults("hline", list(
  linewidth = 0.5
  ,linetype = "dotted"
))
update_geom_defaults("point", list(
  size = 1.5
))
scale_colour_discrete <- function(...) {
  ggplot2::scale_colour_viridis_d(option = "D", ...)
}

scale_fill_discrete <- function(...) {
  ggplot2::scale_fill_viridis_d(option = "D", ...)
}

fct_1 <- function(x){
   sapply(x, function(x){
      x <- as.character(x)
      ifelse(x=="muRc"
             ,paste0("mu")
             ,ifelse(x=="secMom"
                     , paste0('C[2]')
                     , ifelse(x=="thirdRawRc"
                            , paste0('C[3]')
                            , ifelse(x=="fouthRawRc"
                            , paste0('C[4]')
                            , print("f")
                            )
                            )
                     )
             )
   })
}
