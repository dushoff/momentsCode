
# On the Distribution of Expected Case Reproductive Number in Compartmental Disease Models

This repository contains all scripts required to reproduce findings in the following manuscript:

>  Aghaeeyan A., Goel T., Roswell M., Weitz J.S., Dushoff J. On the Distribution of Expected Case Reproductive Number in Compartmental Disease Models


## Recreating analysis:

To regenerate the figures, please follow these steps:

1. Install R.

2. Install required R packages in an interactive R session:

    ```R
    install.packages(c("deSolve", "dplyr", "ggplot2", "patchwork",  "purrr", "tidyr", "remotes"))
    ```
    
    Run the following commands to install *shellpipes* package from GitHub:

    ```R
    library(remotes)
    remotes::install_github("dushoff/shellpipes")
    ```
    
3. Clone this repository by running the following command in a terminal on your machine

    ```bash
    git clone git@github.com:dushoff/momentsCode.git
    ```
    
    Then run the following command to go to the root directory of the repo
    
    ```bash
    cd momentsCode
    ```
    

4. Reproduce Figures

    Each figure can be reproduced by running the command listed below 
    from the root directory of your local repo. 


    Figure 1:

    ```bash
    make figs/ExpMoments.Rout 
    ```
    ---

    Figure 2: 
    
    ```bash
    make figs/TruncPlotCombined.Rout
    ```
    
    ---
    
    Figure 3:
    
    ```bash
    make figs/MomentsPlot.Rout
    ```
    
    ---



