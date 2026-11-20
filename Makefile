## This is momentsCode

current: target
-include target.mk
Ignore = target.mk

vim_session:
	bash -ic "vmt"

## -include makestuff/perl.def

######################################################################

Ignore += parent.mk

figures: figs/ExpMoments.Rout.pdf figs/TruncPlotCombined.Rout.pdf figs/MomentsPlot.Rout.pdf

######################################################################

Sources += $(wildcard Codes/*.R)
autopipeR = defined

Ignore += figs
Makefile: | figs
figs:
	$(mkdir)

## Base functions and parameters
## Codes/RcStat.Rout: Codes/RcStat.R
## Codes/params.Rout: Codes/params.R

## Slow simulations: slow/ is tracked; slowtarget/ is local
## Use make <target>.final to remake slow things
Sources += $(wildcard slow/*)
slowtarget/ErlangMomentsSim.Rout: Codes/ErlangMomentsSim.R Codes/params.rda Codes/RcStat.rda
	$(pipeR)
slowtarget/MomentsSimGenDHR.Rout: Codes/MomentsSimGenDHR.R Codes/params.rda Codes/RcStat.rda
	$(pipeR)
slowtarget/TruncSimSeasonal.Rout: Codes/TruncSim.R Codes/params.rda Codes/RcStat.rda
	$(pipeR)
slowtarget/TruncSimNonSeasonal.Rout: Codes/TruncSimNonSeasonal.R Codes/params.rda Codes/RcStat.rda
	$(pipeR)

## Moments
Codes/ExpMom.Rout: Codes/ExpMom.R slow/ErlangMomentsSim.rda
	$(pipeR)
Codes/ErlangMom.Rout: Codes/ErlangMom.R slow/ErlangMomentsSim.rda
	$(pipeR)
Codes/DHRMom.Rout: Codes/DHRMom.R slow/MomentsSimGenDHR.rda
	$(pipeR)

figs/ExpMoments.Rout:  Codes/MomentsPlot.R Codes/plotStyle.R  Codes/ExpMom.rda
	$(pipeR)
figs/ErlangMoments.Rout: Codes/MomentsPlot.R Codes/plotStyle.R Codes/ErlangMom.rda
	$(pipeR)
figs/DHRMoments.Rout:  Codes/MomentsPlot.R Codes/plotStyle.R Codes/DHRMom.rda
	$(pipeR)
figs/MomentsPlot.Rout: Codes/HR_MomentsPlot.R Codes/plotStyle.R figs/ErlangMoments.rda figs/DHRMoments.rda
	$(pipeR)

## Truncation
figs/TruncPlotCombined.Rout: Codes/PlotTruncSeasonalAndNonSeasonal.R Codes/plotStyle.R slow/TruncSimNonSeasonal.rda slow/TruncSimSeasonal.rda
	$(pipeR)

######################################################################

collaborators: tapangoel1994.invite mikeroswell.invite Aznlfr.invite
future: sjbeckett.invite


### Makestuff

Sources += Makefile

Ignore += makestuff
msrepo = https://github.com/dushoff

## ln -s ../makestuff . ## Do this first if you want a linked makestuff
Ignore += makestuff*.stamp
Makefile: makestuff00.stamp
makestuff%.stamp: | makestuff
	- $(RM) makestuff*.stamp
	cd makestuff && $(MAKE) pull
	touch $@
makestuff:
	git clone --depth 1 $(msrepo)/makestuff

-include makestuff/os.mk

-include makestuff/pipeR.mk
-include makestuff/slowtarget.mk

-include makestuff/git.mk
-include makestuff/visual.mk
