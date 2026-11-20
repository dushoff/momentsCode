library(shellpipes)
loadEnvironments()

library(dplyr)
library(patchwork)
library(tidyr)
library(deSolve)
library(purrr)
startGraphics(width=6, height=4)

library(ggplot2); sourceFiles()
#cohortXlabel <- bquote("[0,"~t[f]~"]"~"infections"~"/"~"total"~"infections"~"("~"t<"~t[f]~")")
cohortXlabel <- bquote("initial infectious cohort size"/~"(0,"~t[f]~"]"~"infections")
# minimum distance between consecutive labels
distThr <- 0.02
res_mat_total <- bind_rows(res_mat_seasonal |> filter(finTime %in% c(10, 100, 300)), res_mat)
print(res_mat_total |> filter(B0 == 1.5))
print(res_mat_total |> filter(B0 == 3))
print(res_mat_total |> filter(B0 == 8))
res_mutated <- (res_mat_total
		|> mutate( B0 = as.factor(B0)
			, alpha = as.factor(alpha)
			, stdv = sqrt(totalVRc_simplified)
		        , Kr = totalVRc_simplified/muRc^2
                        , inv_portion = (1/portion - 1)
                        )
)
############ kappa ##################
x_keep <- unique(res_mutated$inv_portion)
x <- sort(x_keep)
x_keep <- x[1]

for (i in seq_along(x)[-1]) {
  if (x[i] - tail(x_keep, 1) >= distThr) {
    x_keep <- c(x_keep, x[i])
  }
}

xmin <- min(x_keep)
kappaPlot<-(ggplot(res_mutated)
           + geom_point(aes(inv_portion, Kr, color = B0, shape = alpha
            ))
	   + geom_line(aes(inv_portion, Kr, color = B0, linetype = alpha
            ))  
          + scale_x_continuous(
             trans = "log",
             breaks = function(x) {
             sort(unique(scales::breaks_log()(x)))
                           },
             labels = function(x) sprintf("%.2g", x)
             )
         + scale_linetype_discrete(
				name = "Model",
				labels = c("SIR", "SIRS")
				) +
	scale_shape_discrete(
				name = "Model",
				labels = c("SIR", "SIRS")
				)
         + geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.7)
         #  + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
		+ labs( color = bquote(R[0])
				, x = cohortXlabel
                                , y = bquote("dispersion ("~kappa~")"))
						
)#
print(kappaPlot)
