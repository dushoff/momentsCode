library(deSolve)
library(shellpipes)
rpcall("Codes/RcStat.Rout Codes/RcStat.R")

loadEnvironments()




## m for moment; these two functions integrate across the infectors from a given cohort
mderivs <- function(time, vars, parms){
  Bt<- parms$plist$B0*exp(parms$plist$alpha*sin(parms$plist$omega*time))
  Sp<-parms$flist$sfun(time) #fraction of susceptible
	Ri <- Bt*Sp^(parms$plist$kpa +1)
	dens <- with(parms$plist,
	             cars^cars*(time - T0)^(cars-1)*exp(-cars*(time - T0))/factorial(cars-1))
	return(with(c(parms, vars), list(c(
	    Ri
		, dens
		, Rc*dens
		, Rc*Rc*dens
		, Rc*Rc*Rc*dens
		, Rc*Rc*Rc*Rc*dens
	))))
}

mderivsHR <- function(time, vars, parms){
  Bt<- parms$plist$B0*exp(parms$plist$alpha*sin(parms$plist$omega*time))
  Sp<-parms$flist$sfun(time) #fraction of susceptible
	Ri <- Bt*Sp^(parms$plist$kpa +1)
	dens <- with(parms$plist,
		gamma1*p1*exp(-gamma1*(time - T0)) 
		+ gamma2*(1.0-p1)*exp(-gamma2*(time - T0))
		 )
	return(with(c(parms, vars), list(c(
	    Ri
		, dens
		, Rc*dens
		, Rc*Rc*dens
		, Rc*Rc*Rc*dens
		, Rc*Rc*Rc*Rc*dens
	))))
}
cMoments <- function(time, sfun, T0, cars, omega, alpha, kpa, B0){
	mom <- as.data.frame(ode(
		y=c(Rc=0, cumden=0, Rctot=0, RcSS=0, RcSSS=0, RcS4 = 0)
		, func=mderivs
		, times=time
		, parms=list(
			plist=list(T0=T0, cars=cars, omega=omega, alpha=alpha, kpa = kpa, B0=B0)
			, flist=list(sfun=sfun)
		)
	))
	return(mom)
}
cMomentsHR <- function(time, sfun, T0, omega, alpha, kpa, B0, gamma1, gamma2, p1){
	mom <- as.data.frame(ode(
		y=c(Rc=0, cumden=0, Rctot=0, RcSS=0, RcSSS=0, RcS4=0)
		, func=mderivsHR
		, times=time
		, parms=list(
			plist=list(T0=T0, omega=omega, alpha=alpha, kpa = kpa, B0=B0
								 , gamma1=gamma1, gamma2=gamma2, p1=p1)
			, flist=list(sfun=sfun)
		)
	))
	return(mom)
}
cCalc <- function(time, cohort, sfun, tol=1e-4, cars, omega, B0, alpha, kpa){
    Bcohort<-B0*exp(alpha*sin(omega*cohort))
    Ri <- Bcohort*sfun(cohort)^(kpa + 1)
    sTime <- time[time>=cohort]
    mom <- cMoments(sTime, sfun, T0=cohort, cars=cars, omega=omega,
                    alpha=alpha, kpa=kpa, B0=B0)
    with(mom[nrow(mom), ], {
      stopifnot(abs(cumden-1)<tol) 
      Rctot=Rctot/cumden
      RcSS=RcSS/cumden
      RcSSS=RcSSS/cumden
      RcS4=RcS4/cumden
      return(list(
        cohort=cohort, 
        Ri = Ri, Rc=Rctot, varRc=(RcSS-Rctot^2), RcSS =RcSS,
        RcSSS = RcSSS, RcS4=RcS4
      ))
    })
}

cCalcHR <- function(time, cohort, sfun, tol=1e-4, omega, B0, alpha
		, kpa, gamma1, gamma2, p1){
    Bcohort<-B0*exp(alpha*sin(omega*cohort))
    Ri <- Bcohort*sfun(cohort)^(kpa + 1)
    sTime <- time[time>=cohort]
    mom <- cMomentsHR(sTime, sfun, T0=cohort, omega=omega,
                    alpha=alpha, kpa=kpa, B0=B0, gamma1=gamma1, gamma2=gamma2
		, p1=p1)
    with(mom[nrow(mom), ], {
      stopifnot(abs(cumden-1)<tol) 
      Rctot=Rctot/cumden
      RcSS=RcSS/cumden
      RcSSS=RcSSS/cumden
      RcS4=RcS4/cumden
      return(list(
        cohort=cohort, Ri = Ri, Rc=Rctot, varRc=(RcSS-Rctot^2), RcSS =RcSS,
        RcSSS = RcSSS, RcS4=RcS4
      ))
    })
}

cohortStats <- function(kpa = 0
                        , omega = 0
                        , B0 = 1
                        , alpha = 0
                        , sdat = NULL
                        , maxCohort = NULL
                        , cohortProp=0.6
                        , dfun = boxcar
                        , cars = 1
                        , ...){
  sfun <- approxfun(sdat$time, sdat$x, rule=2)
  cohorts <- with(sdat, time[time<=maxCohort])
  return(as.data.frame(t(
    sapply(cohorts, function(c) cCalc(sdat$time, cohort=c, sfun=sfun, tol=1e-4,
                                      cars=cars,
                                      omega = omega,
                                      B0 = B0,
                                      alpha = alpha,
                                      kpa = kpa
    ))
  )))
}

cohortStatsHR <- function(kpa = 0
                        , omega = 0
                        , B0 = 1
                        , alpha = 0
                        , sdat = NULL
                        , maxCohort = NULL
                        , gamma1 = 0
			, gamma2 = 0
			, p1 = 0
                        , ...){
  sfun <- approxfun(sdat$time, sdat$x, rule=2)
  cohorts <- with(sdat, time[time<=maxCohort])
  return(as.data.frame(t(
    sapply(cohorts, function(c) cCalcHR(sdat$time,cohort=c, sfun=sfun, tol=1e-4,
                                      omega = omega,
                                      B0 = B0,
                                      alpha = alpha,
                                      kpa = kpa,
                                      gamma1 = gamma1,
                                      gamma2 = gamma2,
                                      p1 = p1
    ))
  )))
}

outbreakStats <- function(kpa = 0
                          , omega=0
                          , B0=1
                          , alpha = 0
                          #  , tmult=6
                          , cohortProp=0.6
                          , steps=300
                          , dfun = boxcar
                          , cars = 1
                          , sigma = 0
                          , finTime = 365
                          , y0 = 1e-9
                          , t0 = 0){
  mySim<- sim(kpa = kpa, omega=omega, B0=B0, alpha=alpha, timeStep=finTime/steps,
              finTime=finTime, dfun=dfun, cars=cars, sigma=sigma, y0 =y0, t0=t0
  )
  with(mySim, {
    maxCohort <- t0 + cohortProp*finTime
    ifun <- approxfun(time, y*x^(kpa + 1), rule=2)
    #ifun <- approxfun(time, inc, rule=2)
    cStats <- cohortStats(kpa = kpa, omega = omega, B0 = B0, alpha=alpha,
                          sdat=mySim,
                          maxCohort=maxCohort, 
                          cars=cars)
    rcfun <- approxfun(cStats$cohort, cStats$Rc, rule=2)
    rifun <- approxfun(cStats$cohort, cStats$Ri, rule=2)
    varrcfun <- approxfun(cStats$cohort, cStats$varRc, rule=2)
    wssfun <- approxfun(cStats$cohort, cStats$RcSS, rule = 2)
    wsssfun <- approxfun(cStats$cohort, cStats$RcSSS, rule = 2)
    ws4fun <- approxfun(cStats$cohort, cStats$RcS4, rule = 2)
    mom <- as.data.frame(ode(
      y=c(finS=0, mu=0, SS=0, V=0, w = 0, checkV = 0, 
          Ri = 0, muRi = 0, SSRi = 0, SSRiTime=0, SSS=0, S4 = 0,
          SStime = 0, mutime=0,
          ttime=0, withinTime=0, betweenTime=0, SSSRi = 0, S4Ri=0)
      , func=oderivs
      , times=unlist(cStats$cohort)
      , parms=list( B0 = B0, alpha=alpha, omega=omega,
                    ifun=ifun, rcfun=rcfun, varrcfun=varrcfun,
                    wssfun = wssfun, rifun=rifun, 
                    wsssfun = wsssfun, ws4fun = ws4fun))
    )
    
    with(mom[nrow(mom), ], {
      SStime <- SStime/ttime
      mutime <- mutime/ttime
      totalVtime <- SStime - mutime^2
      withinTime <- withinTime/ttime
      betweenTime <- betweenTime/ttime -mutime^2
      muRiTime<-Ri/ttime
      SSRiTime <- SSRiTime/ttime - muRiTime^2
      mu <- mu/finS
      SS <- SS/finS
      w <- w/finS
      checkV <- (checkV/finS)
      within <- (V/finS)
      between <- (SS-mu^2)
      total = within + between
      otherCheck = (w-mu^2)
      Finalsize <- finS
      muRi <- muRi/finS
      SSRi <- SSRi/finS
      SSSRi <- SSSRi/finS
      S4Ri <- S4Ri/finS
      thirdRc <- SSS/finS
      fourthRc <- S4/finS
      totalVRi <- SSRi - muRi^2
      return(c(  stepSize=steps
                 , B0 = B0
                 , alpha = alpha
                 , sigma = sigma
                 , omega = omega
                 , cars = cars
                 , kpa = kpa
                 , Finalsize=Finalsize
                 , muRc=mu
                 , within=within
                 , checkWithin = checkV
                 , between=between
                 , withinSS = w
                 , totalVRc = total
                 , totalVRc_simplified = otherCheck
                 , totalKRc=total/mu^2
                 , thirdRawRc = thirdRc 
                 , fouthRawRc = fourthRc 
                 , totalVRi=totalVRi
                 , thirdRawRi = SSSRi
                 ,fourthRawRi = S4Ri
                 , muRi = muRi
                 , muRiTime = muRiTime
                 , totalVtimeRi = SSRiTime
                 , totalVtime = totalVtime
                 , withinTime = withinTime
                 , betweenTime = betweenTime
      ))
    })
  })
}

oderivs <- function(time, vars, parms){
  Bt<-parms$B0*exp(parms$alpha*sin(parms$omega*(time)))
  inc <- Bt*parms$ifun(time)
  #inc <- parms$ifun(time)
  Rc <- parms$rcfun(time)
  Ri <- parms$rifun(time)
  varRc <- parms$varrcfun(time)
  wss <- parms$wssfun(time)
  wsss <- parms$wsssfun(time)
  ws4 <- parms$ws4fun(time)
  return(list(c(  
    inc #finS
    ,inc*Rc #mu
    ,inc*Rc*Rc #RSS
    ,inc*varRc #V
    ,inc*wss #w
    ,inc*(wss - Rc^2) #checkV
    ,Ri #Ri
    ,inc*Ri #muRi
    ,inc*Ri*Ri #SSRi
    , Ri*Ri
    ,inc*wsss #SSS
    ,inc*ws4 #S4
    ,wss #timeRSS
    ,Rc #timeRc
    ,1 #time
    ,varRc #timeWithin
    ,Rc*Rc #time between
    , inc*Ri*Ri*Ri #SSSRi
    , inc*Ri*Ri*Ri*Ri #S4Ri
  )))
}



boxcar <- function(time, vars, parms){
  with(as.list(c(vars, parms)), {
    yvec <- (unlist(mget(paste0("y", 1:cars))))
    y <- sum(yvec)
    ydots <- numeric(cars)
    Bt<- B0*exp(alpha*sin(omega*time))
    xdot <- -Bt*y*x^(kpa+1) + sigma*r
    ydots[[1]] <- Bt*y*x^(kpa+1) - cars*yvec[[1]]
    cumdot <- Bt*y*x^(kpa+1)
    Rcdot <- Bt*x^(kpa+1)
    if (cars > 1) {
      ydots[2:cars] <- cars * (yvec[1:(cars - 1)] - yvec[2:cars])
    }
    rdot <- cars*yvec[[cars]] - sigma*r
    out <- c(xdot, ydots, rdot, cumdot, Rcdot)
    names(out) <- c("xdot", paste0("y", 1:cars, "dot"), "rdot", "cumdot", "Rcdot")
    return(list(out))
  }
  )
}

sim <- function(kpa = 0, B0=1,  cars = 1, finTime=365,
                timeStep=0.1, dfun=boxcar, alpha=0, omega=0, sigma=0, t0 =0, 
                y0 = 1e-9){
  x0 <- 1-y0
  r0 <- 0
  cum0 <- 0
  Rc0 <- 0
  if(cars>1){infc <- c(y0, rep(0,cars-1))}else{infc<-y0}
  names(infc) <- paste0("y", 1:cars)
  y_init <- c(x = x0, infc, r=r0, cum = cum0, Rc = Rc0)
  timePoints<- seq(from=0, to=t0 + finTime, by=timeStep)
  print(paste0("min",min(timePoints),"max",max(timePoints)))
  sim <- as.data.frame(ode(
    y = y_init
    , func=dfun
    , times=timePoints
    , parms=list(omega=omega, B0=B0, alpha = alpha,  cars = cars,
                 kpa = kpa, sigma=sigma)
    ,rtol = 1e-10
    ,atol = 1e-12
  ))
  sim <- sim[sim$time >=t0,]
  return(within(sim, {
    if (cars>1){
      y <- rowSums(as.data.frame(mget(paste0("y", 1:cars))))
    }
    else{
      y <- y1
    }
    inc <- c(NA, diff(cum))/timeStep
    cohortSize <- c(diff(cum), NA)
    mid_time <- c(NA, (head(time, -1) + tail(time, -1)) / 2)
    Ri <- B0*exp(alpha*sin(omega*time))*x^(kpa + 1)
    
  }))
}

cohortStatsRcPlot <- function(kpa = 0
                              , omega=0
                              , B0=1
                              , alpha = 0
                              , cohortProp=0.6
                              , steps=300
                              , dfun = boxcar
                              , cars = 1
                              , sigma = 0
                              , finTime = 365
                              , y0 = 1e-9
                              , t0 = 0
                              
){
  sdat<- sim(kpa = kpa, omega=omega, B0=B0, alpha=alpha, timeStep=finTime/steps,
             finTime=finTime, dfun=dfun, cars=cars, sigma=sigma, y0=y0, t0=t0
  )
  sfun <- approxfun(sdat$time, sdat$x, rule=2)
  maxCohort <- t0 + cohortProp * finTime
  cohorts <- with(sdat, time[time<=maxCohort])
  idx<-which.max(sdat$inc)
  tpeak <- sdat[idx,"time"]
  return(as.data.frame(t(
    sapply(cohorts, function(c) {
      cohortSize <- sdat[sdat$time ==c, "cohortSize"]
      return(c(cCalc(sdat$time, cohort=c, sfun=sfun, 
                                      tol=1e-4,
                                      cars=cars,
                                      omega = omega,
                                      B0 = B0,
                                      alpha = alpha,
                                      kpa = kpa),
                                      cohortSize = cohortSize,
                                      tpeak = tpeak
    )
      )
    }
    )
  )))
}

simwrap <- function(kpa = 0, B0=1,  cars = 1, finTime=365,
                    timeStep=0.1, dfun=boxcar, alpha=0, omega=0, sigma=0, y0 =1e-9,
                    t0 = 0){
  sdat<-sim(kpa = kpa, B0 =B0, cars=cars, finTime=finTime, timeStep = timeStep,
            dfun=dfun, alpha=alpha, omega=omega, sigma = sigma, y0=y0, t0=t0)
  return(
    list(
      sdat = sdat, finTime = finTime
    )
  )
}



FinitecMoments <- function(time, sfun, T0, cars, omega, alpha, kpa, B0){
	mom <- as.data.frame(ode(
		y=c(Rc=0, cumden=0, Rctot=0, RcSS=0, RcSSS=0, RcS4 = 0)
		, func=mderivs
		, times=time
		, parms=list(
			plist=list(T0=T0, cars=cars, omega=omega, alpha=alpha, kpa = kpa, B0=B0)
			, flist=list(sfun=sfun)
		)
	))
	return(mom)
}
FinitecCalc <- function(time, cohort, sfun, tol=1e-4, cars, omega, B0, alpha, kpa){
    Bcohort<-B0*exp(alpha*sin(omega*cohort))
    sTime <- time[time>=cohort]
    mom <- FinitecMoments(sTime, sfun, T0=cohort, cars=cars, omega=omega,
                    alpha=alpha, kpa=kpa, B0=B0)
    with(mom[nrow(mom), ], {
     # stopifnot(abs(cumden-1)<tol) 
      Rctot=Rctot
      RcSS=RcSS
      RcSSS=RcSSS
      RcS4=RcS4
      return(list(
        cohort=cohort,  Rc=Rctot, varRc=(RcSS/cumden-Rctot^2/(cumden^2)), RcSS =RcSS,
        RcSSS = RcSSS, RcS4=RcS4, cumden = cumden
      ))
    })
}

FinitecohortStats <- function(kpa = 0
                        , omega = 0
                        , B0 = 1
                        , alpha = 0
                        , sdat = NULL
                        , maxCohort = NULL
                        , cohortProp=0.6
                        , dfun = boxcar
                        , cars = 1
                        , ...){
  sfun <- approxfun(sdat$time, sdat$x, rule=2)
  cohorts <- with(sdat, time[time<=maxCohort])
  return(as.data.frame(t(
    sapply(cohorts, function(c) FinitecCalc(sdat$time, cohort=c, sfun=sfun, tol=1e-4,
                                      cars=cars,
                                      omega = omega,
                                      B0 = B0,
                                      alpha = alpha,
                                      kpa = kpa
    ))
  )))
}
FiniteOutbreak <- function(kpa = 0
                          , omega=0
                          , B0=1
                          , alpha = 0
                          #  , tmult=6
                          , cohortProp=0.6
                          , steps=300
                          , dfun = boxcar
                          , cars = 1
                          , sigma = 0
                          , finTime = 365
                          , y0 = 1e-9
                          , t0 = 0){
  mySim <- sim(kpa = kpa, omega=omega, B0=B0, alpha=alpha, timeStep=finTime/steps,
              finTime=finTime, dfun=dfun, cars=cars, sigma=sigma, y0 =y0, t0=t0
  )
  with(mySim, {
    maxCohort <- t0 + finTime - 3*finTime/steps
    ifun <- approxfun(time, y*x^(kpa + 1), rule=2)
    cStats <- FinitecohortStats(kpa = kpa, omega = omega, B0 = B0, alpha=alpha,
                          sdat=mySim,
                          maxCohort=maxCohort, 
                          cars=cars)
    rcfun <- approxfun(cStats$cohort, cStats$Rc, rule=2)
    wssfun <- approxfun(cStats$cohort, cStats$RcSS, rule = 2)
    wsssfun <- approxfun(cStats$cohort, cStats$RcSSS, rule = 2)
    ws4fun <- approxfun(cStats$cohort, cStats$RcS4, rule = 2)
    cohortFracFun <- approxfun(cStats$cohort, cStats$cumden, rule = 2)

    mom <- as.data.frame(ode(
      y=c(finS=0, mu=0, SS=0, w = 0, checkV = 0, 
           SSS=0, S4 = 0)
      , func=FiniteODE
      , times=unlist(cStats$cohort)
      , parms=list( B0 = B0, alpha=alpha, omega=omega,
                    ifun=ifun, rcfun=rcfun, 
                    cohortFracFun = cohortFracFun,
                    wssfun = wssfun, 
                    wsssfun = wsssfun, ws4fun = ws4fun)
      )
    )
    
    with(mom[nrow(mom), ], {
      mu <- mu/finS
      SS <- SS/finS
      w <- w/finS
      checkV <- (checkV/finS)
      within <- checkV
      between <- (SS-mu^2)
      total = within + between
      otherCheck = (w-mu^2)
      Finalsize <- finS
      thirdRc <- SSS/finS
      fourthRc <- S4/finS
      return(c(  stepSize=steps
                 , B0 = B0
                 , alpha = alpha
                 , sigma = sigma
                 , omega = omega
                 , cars = cars
                 , kpa = kpa
		 , finTime = finTime
                 , Finalsize=Finalsize
                 , muRc=mu
                 , within=within
                 , between=between
                 , withinSS = w
                 , totalVRc = total
                 , totalVRc_simplified = otherCheck
                 , totalKRc=total/mu^2
                 , thirdRawRc = thirdRc 
                 , fouthRawRc = fourthRc 
      ))
    })
  })
}

FiniteODE <- function(time, vars, parms){
  Bt<-parms$B0*exp(parms$alpha*sin(parms$omega*(time)))
  Rc <- parms$rcfun(time)
  wss <- parms$wssfun(time)
  wsss <- parms$wsssfun(time)
  ws4 <- parms$ws4fun(time)
  cohortFrac <- parms$cohortFracFun(time)
  inc <- ifelse(cohortFrac >0, Bt*parms$ifun(time), 0 )
  return(list(c(  
    inc*cohortFrac #finS
    ,inc*Rc #mu
    ,inc*Rc*Rc/cohortFrac #RSS
    ,inc*wss #w
    ,inc*(wss - Rc^2/cohortFrac) #checkV
    ,inc*wsss #SSS
    ,inc*ws4 #S4
  )))
}


finTimeFinder<-function(B0 = 1.5, sigma = 0, alpha = 0, omega = 0, y0 = 1e-9
			, cars = 1, kpa = 0, portions = NULL){
	
    SIRsim<- sim(kpa = kpa, omega=omega, B0=B0, alpha=alpha
                       , timeStep=1e-2
                       , finTime=50, cars=cars, sigma=sigma
                       , y0 =y0, t0=0)
		idx<-which.max(SIRsim$cum)
		mySim<-SIRsim[1:idx,]
	share <- mySim$cum / (mySim$cum + y0)
	idx <- vapply(portions, function(i){tail(which(abs(share - i)<0.01),1)}, integer(1))
	cat("diff", share[idx])
	stopifnot(all(idx>0))
	time_vec <- mySim$time[idx]
	cat("\ntime:", time_vec)
  return(time_vec)
}

RelativeFinalSizeFinder<-function(B0 = 1.5, sigma = 0, alpha = 0
				, omega = 0, y0 = 1e-9
				, cars = 1, kpa = 0, finTime = 50, t0=0){
	
SIRsim<- sim(kpa=kpa, omega=omega, B0=B0, alpha=alpha
			, timeStep=1e-2
			, finTime=finTime, cars=cars, sigma=sigma
			, y0 =y0, t0=t0)
idx<-which.max(SIRsim$cum)
maxCum<-SIRsim[idx,"cum"]
share <- maxCum/ (maxCum + y0)
}

generalizedBoxCar <- function(time, vars, parms){
  with(as.list(c(vars, parms)), {
    Bt<- B0*exp(alpha*sin(omega*time))
    y <- y1 + y2
		xdot <- -Bt*y*x^(kpa + 1) + sigma*r
    y1dot <- p1*Bt*y*x^(kpa + 1) - gamma1*y1
    y2dot <- (1-p1)*Bt*y*x^(kpa +1) - gamma2*y2
    ydots <- c(y1dot, y2dot)
    rdot <- gamma1*y1 + gamma2*y2 - sigma*r
    cumdot <- Bt*y*x^(kpa + 1)
    out <- c(xdot, ydots, rdot, cumdot)
    return(list(out))
  }
  )
}
outbreakStatsGen <- function(kpa = 0
                          , omega=0
                          , B0=1
                          , alpha = 0
                          , cohortProp=0.6
                          , steps=300
                          , dfun = generalizedBoxCar
                          , cars = 1
                          , sigma = 0
                          , finTime = 365
                          , y0 = 1e-9
                          , t0 = 0
                          , gamma1 = 1
			  , gamma2 =NULL
			  , p1 = NULL
                          , a = 1
                             ){
	if(is.null(gamma2)){gamma2<-a*gamma1}
	if(is.null(p1)){p1 <- 1/(a+1)}
  mySim<- simG(B0=B0, timeStep=finTime/steps,
              finTime=finTime, dfun=dfun, y0 =y0, t0=t0,
              gamma1=gamma1, gamma2=gamma2, p1=p1,
              kpa=kpa, omega=omega, alpha=alpha
  )
  with(mySim, {
    maxCohort <- t0 + cohortProp*finTime
    ifun <- approxfun(time, y*x^(kpa + 1), rule=2)
    cStats <- cohortStatsHR(kpa = kpa, omega = omega, B0 = B0, alpha=alpha,
                          sdat=mySim,
                          maxCohort=maxCohort, 
                          gamma1 = gamma1, gamma2 = gamma2, p1 = p1)
    rcfun <- approxfun(cStats$cohort, cStats$Rc, rule=2)
    varrcfun <- approxfun(cStats$cohort, cStats$varRc, rule=2)
    wssfun <- approxfun(cStats$cohort, cStats$RcSS, rule = 2)
    wsssfun <- approxfun(cStats$cohort, cStats$RcSSS, rule = 2)
    ws4fun <- approxfun(cStats$cohort, cStats$RcS4, rule = 2)
    mom <- as.data.frame(ode(
      y=c(finS=0, mu=0, SS=0, V=0, w = 0, checkV = 0
          ,SSS=0, S4 = 0
         )
      , func=oderivsGen
      , times=unlist(cStats$cohort)
      , parms=list( B0 = B0, alpha=alpha, omega=omega,
                    ifun=ifun, rcfun=rcfun, varrcfun=varrcfun,
                    wssfun = wssfun,
                    wsssfun = wsssfun, ws4fun = ws4fun))
    )
    
    with(mom[nrow(mom), ], {
      mu <- mu/finS
      SS <- SS/finS
      w <- w/finS
      checkV <- (checkV/finS)
      within <- (V/finS)
      between <- (SS-mu^2)
      total = within + between
      otherCheck = (w-mu^2)
      Finalsize <- finS
      thirdRc <- SSS/finS
      fourthRc <- S4/finS
      return(c(  stepSize=steps
                 , B0 = B0
                 , alpha = alpha
                 , sigma = sigma
                 , omega = omega
                 , cars = cars
                 , kpa = kpa
                 , a = a
                 , gamma1 = gamma1
                 , gamma2 = gamma2
                 , p1 = p1
                 , Finalsize=Finalsize
                 , muRc=mu
                 , within=within
                 , checkWithin = checkV
                 , between=between
                 , withinSS = w
                 , totalVRc = total
                 , totalVRc_simplified = otherCheck
                 , totalKRc=total/mu^2
                 , thirdRawRc = thirdRc 
                 , fouthRawRc = fourthRc
      ))
    })
  })
}
# B0=B0, timeStep=finTime/steps,
           #   finTime=finTime, dfun=dfun, y0 =y0, t0=t0
simG <- function(B0=1, finTime=365,
                timeStep=0.1, dfun=generalizedBoxCar,	t0 =0, 
                y0 = 1e-9, gamma1 = 1, gamma2=1, p1=1,
                kpa=0, omega=0, alpha=0){
  x0 <- 1-y0
  r0 <- 0
  cum0 <- 0
  infc<-c(p1*y0, (1.0-p1)*y0)
  names(infc) <- paste0("y", 1:2)
  y_init <- c(x = x0, infc, r=r0, cum = cum0)
  timePoints<- seq(from=0, to=t0 + finTime, by=timeStep)
  sim <- as.data.frame(ode(
    y = y_init
    , func=dfun
    , times=timePoints
    , parms=list(B0=B0, gamma1=gamma1, gamma2=gamma2, p1=p1,
                 kpa=kpa, omega=omega, alpha=alpha)
  ))
  sim <- sim[sim$time >=t0,]
  return(within(sim, {
	y <- y1 + y2
    mid_time <- c(NA, (head(time, -1) + tail(time, -1)) / 2)
		inc      <- c(NA, diff(cum))/timeStep
    cohortSize <- c(diff(cum), NA)
  }))
}

oderivsGen <- function(time, vars, parms){
  Bt<-parms$B0*exp(parms$alpha*sin(parms$omega*(time)))
  inc <- Bt*parms$ifun(time)
  Rc <- parms$rcfun(time)
  varRc <- parms$varrcfun(time)
  wss <- parms$wssfun(time)
  wsss <- parms$wsssfun(time)
  ws4 <- parms$ws4fun(time)
  return(list(c(   
    inc #finS
    ,inc*Rc #mu
    ,inc*Rc*Rc #RSS
    ,inc*varRc #V
    ,inc*wss #w
    ,inc*(wss - Rc^2) #checkV
    ,inc*wsss #SSS
    ,inc*ws4 #S4

  )))
}

peakAssigner<-function(kpa = 0, B0=1,  cars = 1, finTime=365,
timeStep=0.1, dfun=boxcar, alpha=0, omega=0, sigma=0, t0 =0, 
y0 = 1e-9){
  SIRsim<-sim(kpa = kpa, B0= B0,  cars = cars, finTime=finTime,
              timeStep=timeStep, dfun=dfun, alpha=alpha, omega=omega,
              sigma=sigma, t0 =t0,  y0 = y0)
idx<-which.max(SIRsim$inc)
return(SIRsim[idx,"time"])
}
saveEnvironment()
