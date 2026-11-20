library(dplyr)
library(patchwork)
library(tidyr)
library(shellpipes)
library(ggplot2);sourceFiles()
loadEnvironments()
startGraphics(width=5, height=2)
# Normalizing the kth raw moment by muRc^k for k>1
res_mat <- res_mat |> mutate(secMom = (totalVRc + muRc^2)/muRc^2
                           , thirdRawRc = thirdRawRc/muRc^3
                           , fouthRawRc = fouthRawRc/muRc^4
                           )
res_mat <- res_mat |>  mutate(B0 = as.factor(B0)) |>
   pivot_longer(cols=c("muRc"
                       ,"secMom"
                       ,"thirdRawRc"
                       ,"fouthRawRc")
                , names_to = "moments"
                , values_to = "moments_values")
moments_hline <- data.frame(moments = factor(c("muRc","secMom"
                       ,"thirdRawRc"
                       ,"fouthRawRc"), levels = c("muRc"
                                                  ,"secMom"
                                                  ,"thirdRawRc"
                                                  ,"fouthRawRc"))
           , hline_value = c(1, 2, 6, 24)) #the first 4 raw moments of ~exp(1)
########## Plotting Mean ################
raw_moments_plot<-(res_mat
                   |> mutate(moments = factor(moments
                                             , levels = c("muRc"
                                                          ,"secMom"
                                                          ,"thirdRawRc"
                                                          ,"fouthRawRc")))
                   |> ggplot()
      + aes(x = B0, y = moments_values)
      +  geom_bar(stat = "identity"
                  , width = barwidth)
      +  geom_hline(data = moments_hline
                    , aes(yintercept = hline_value)
                     , linewidth = linewidth_moments
                    )
      +  facet_wrap( ~ moments
                     , scales = "free_y"
                     , ncol = 4
                     , labeller = labeller(moments = function(x){fct_1(x)}
                                           ,  .default = label_parsed)
                     )
      +  xlab(bquote(R[0]))
      + ylab(NULL)
      
)

print(raw_moments_plot)
distPlot<- assign(distName, raw_moments_plot)
#rdsSave(distPlot)
saveEnvironment()
