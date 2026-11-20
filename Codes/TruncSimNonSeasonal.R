library(dplyr)
library(purrr)
library(tidyr)
library(deSolve)
library(shellpipes)

loadEnvironments()
VecRelative2tpeak <- c(0.25, 0.75, 1, 1.25)
y0 <-0.005
# number of steps per tpeak
steps <- 2000 
grid<- expand.grid(B0 = B0, Relative2peak = VecRelative2tpeak)
res_mat <- map2_dfr(grid$B0, grid$Relative2peak,
                    function(x,R2peak){
                                    tpeak <- peakAssigner(kpa = kpas
                                              , B0=x
                                              , cars = cars
                                              , finTime=100
                                              , timeStep=0.01
                                              , t0 =t0
                                              , y0 = y0) 
                                    out <- FiniteOutbreak(B0 = x
                                              , cars=cars
                                              , steps=steps*tpeak
                                              , y0=y0
                                              , finTime = R2peak*tpeak
                                              , alpha=alpha
                                              , omega=omega
                                              , kpa=kpas
                                              , sigma=sigma
                                              , t0=t0)
 data.frame(t(c(out
  , portion = RelativeFinalSizeFinder(x, sigma, alpha, omega, y0, cars, kpas, R2peak*tpeak, t0)
  , tpeak = tpeak
))) 
})



straightSim <- map_dfr(B0, function(B0){
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
