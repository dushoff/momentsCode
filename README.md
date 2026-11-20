
# On the Distribution of Expected Case Reproductive Number in Compartmental Disease Models

This repository contains all scripts required to reproduce findings in the following manuscript:

>  Aghaeeyan A., Goel T., Roswell M., Weitz J.S., Dushoff J. On the Distribution of Expected Case Reproductive Number in Compartmental Disease Models

This code base should be cited as:

>  Aghaeeyan A., Goel T., Roswell M., Weitz J.S., Dushoff J. On the Distribution of Expected Case Reproductive Number in Compartmental Disease Models

## Software details

The code is written in R v4.5.0. We used libraries  *deSolve*, *dplyr*, *ggplot2*, *patchwork* *purrr*, *tidyr*, *shellpipes*.

*shellpipes* is an R package helps streamline simulations in R using *Makefiles*.
A *Makefile* allows the users to specify which files a target file depends on.
By doing so, changes to the dependent files are automatically tracked, and the target file is regenerated only when any of its dependencies have changed.


## Recreating analysis:

To create the figures, you need to follow these steps:

1. Install R.

2. Install required R packages in an interactive R session:

    ```R
    install.packages(c("deSolve", "dplyr", "ggplot2", "patchwork",  "purrr", "tidyr", "remotes"))
    ```
    
    We install R package *remotes* which faciliates installing *shellpipes* package  from GitHub:

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

    Some scripts hosted in the
    [makestuff repository](https://github.com/dushoff/makestuff) are required
    by the *Makefile*. That's why you might encounter some errors the first time you run a command,
    However, after running the same command once or twice more, the scripts should be 
    downloaded, and the errors should disappear.

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


All figures are reproduced using stored *RData* files in  *slow* directory.
The files in  *slow* directory can be reproduced by
adding *.final* to the end of above commands.
For  example, run the following command in the terminal to rerun the simulations
on which Figure 1 depends  and regenerate Figure 1:

```bash
    make figs/ExpMoments.Rout.final 
```


