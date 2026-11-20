library(dplyr)
library(purrr)
library(tidyr)
library(deSolve)
library(shellpipes)

loadEnvironments()
VecfinTime <- c(10, 25, 100, 300)
y0 <- 0.005
sigma <- 0.01
alpha <- 1
steps <- 50
t0 <- 0


grid<- expand.grid(B0 = B0, finTime = VecfinTime)
res_mat_seasonal <- map2_dfr(grid$B0, grid$finTime,
                    function(x,finT){out<-FiniteOutbreak(B0 = x
                                              ,cars=cars
                                              ,steps=steps*finT
                                              ,y0=y0
                                              ,finTime = finT
                                              ,alpha=alpha
                                              ,omega=omega
                                              ,kpa=kpas
                                              ,sigma=sigma
                                              ,t0=t0)
   data.frame(t(c(out, 
                  portion = RelativeFinalSizeFinder(x, sigma, alpha, omega, y0, cars, kpas, finT, t0)
))) 
})


straightSim_seasonal <- map_dfr(B0, function(B0){
  return(data.frame(sim( B0=B0,
                        cars = cars,
                        t0 = t0,
                        finTime=500,
                        y0 = y0,
			sigma = sigma,
			omega = omega,
			alpha = alpha,
			timeStep = 0.01,
			kpa = kpas
  ), B0 = B0))
}
)
saveEnvironment()
