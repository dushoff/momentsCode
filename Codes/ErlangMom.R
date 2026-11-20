library(dplyr)
library(shellpipes)
loadEnvironments()

number_of_infectious_compartments <- 2
res_mat <- res_mat |> filter(cars==number_of_infectious_compartments)

distName <- "IHR"

saveEnvironment()
