library(shellpipes)
rpcall("Codes/params.Rout Codes/params.R Codes/RcStat.Rout Codes/RcStat.rda")
#some parameters will be overwritten
B0 <- c(1.5, 3, 8)
steps<-5e3
finTime<-100
y0 <-1e-9
cohortProp <- 0.6
t0 <-0
year <- 60
sigma <- 0
tau <- 2*pi
omega <- c(tau/year) 
alpha <- c(0)
cars <- c(1) #number of compartments
kpas <- c(0)  #the variation in the susceptibility

legendFontSize <- 8; legendTitleFontSize <- 9
xlabelFontSize <- 10; ylabelFontSize <- 10

saveEnvironment()