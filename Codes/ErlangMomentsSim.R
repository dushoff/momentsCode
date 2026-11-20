library(dplyr)
library(purrr)
library(tidyr)
library(deSolve)
library(shellpipes)

loadEnvironments()

omega <- c(0) 
alpha<- c(0)
steps<- 1e4
cars <- c(1,2,4) #number of compartments
sigma<-0
grid <- expand.grid(B0=B0, cars=cars)
res_mat <- as.data.frame(t(mapply(outbreakStats
				, B0=grid$B0
				, cars=grid$cars,
                                  MoreArgs = list(alpha=alpha
							, omega=omega
							, sigma=sigma
							, kpa=kpas
							, finTime=finTime
							, steps=steps
							, y0=y0
							, t0=t0))))

saveEnvironment()
