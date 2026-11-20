library(dplyr)
library(shellpipes)
loadEnvironments()

number_of_infectious_compartments <- 1
res_mat <- res_mat |> filter(cars==number_of_infectious_compartments)
distName <- "Exp"
saveEnvironment()
