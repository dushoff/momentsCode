library(dplyr)
library(purrr)
library(tidyr)
library(deSolve)
library(shellpipes)
library(ggplot2)

loadEnvironments()

steps <- 1e4
finTime <- 150
a <- c(4)
gamma1 <- 0.4 #gamma1 = 0.4 and a = 4 -> mean infectious period =1

grid <- expand.grid(B0=B0, a=a)
res_mat <- as.data.frame(t(mapply(outbreakStatsGen
                                  , a = grid$a
                                  , B0= grid$B0
                                  , MoreArgs = list(finTime=finTime
                                                   , steps=steps
                                                   , y0=y0
                                                   , t0=t0
                                                   , cohortProp=cohortProp
                                                   , gamma1 = gamma1
                                                    ))))

saveEnvironment()
