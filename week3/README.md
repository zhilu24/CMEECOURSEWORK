# PROJECT NAME: BOOTCAMP ASSIGNMENT WEEK 3

## Project Overview: 
This project is all the coursework from week3. It includes two parts:
The first part is introduce the use of R for biological computing. The focus is on building foundational skills in R programming, introducing data structures, control flow, vectorization and reproducible workflows. It also cover debugging, and using R for analysis and modelling.
The second part is focuse on exercises related to data management and visualization in biological data. This project explore key principles like data wrangling, reshaping, and advanced visualization techniques using R and its packages.

## Languages and Tools Used:

### programming Language: 
`R` `bash` `LaTeX`

### Main Tools:
 - R base functions
 - R packages: reshape2, dplyr, ggplot2, tidyverse
 - IDEs: Visual Studio Code

## Installation/Running:
installation: installing the required R package: 
```R
install.packages("") 
```

Running the scripts:
```bash
Rscript
```
```R
source("")
```


## Project Structure and Usage:

### CMEECourseWork/week2

#### -code
#contains 19 practices. 
For first part:

apply1.R: using apply function demonstrate R's built-in vectorised function

apply2.R: using apply to custom vectorized functions

sample.R: an example of vectorization involving lapply and sapply

browse.R: demonstration of browser() function and using breakpoint in script

boilerplate.R: a start script to write R functions

break.R: a scirpt about break statements

control_flow.R: introduction for if, while and for statements

DataWrang.R:  a script to illustrate data-wrangling

next.R: a script to illustrate next functions

preallocate.R: demonstration the perfomance difference between using pre-allocation and dynamic memory allocation

R_conditionals.R: a script about writing functions with conditions

Ricker.R: plots the ricker model

MyScript.R: some fragmented exercises


**TreeHeight.R**:  This R script is designed to process tree data, compute tree heights based on distance and angle measurements. The script loads the input data file `trees.csv` in the `data` directory using the relative path ../data/trees.csv, and save the results as a CSV file named `TreeHts.csv` in the `result` directory using the relative path ../results/TreeHts.csv. The output file includes the origin data columns and a new column `Tree.Height.m`, with the computed heights.

**Florida.R**: This R script is designed to analyze whether Florida is getting warmer over time using statistical methods. Through calculating the correlation coefficient and doing permutation testing. It compares the observed correlation to those obtained from shuffled data to evaluate the significance of the result. The script loads the input data file `KeyWestAnnualMeanTemperature.RDATA` in the `data` directory using the relative path.

**Florida_latex_code.tex**: This LaTeX script titled " Analysis Temperature Trends in Florida" present the result from `Florida.R`. It contains the results based on the analysis of the key west annual mean temperatures and its interpretation and conclusion.
To compile in the bash terminal:
```bash
pdflatex -output- directory=../results Florida_latex_code.tex
```
For second part:

visulization.R - all practices from section of Data management and visualization

**PP_Regress.R**: This R script is designed to preform regression analysis between predator mass and prey mass on subsets of predator.lifestage combined feeding type. The task including generate visualizations of the regression results, and save these as a PDF result. Additionally, the scripts calculates and outputs the regression results including several regression parameters such as slope, intercept, R^2, f-statistics, p-value. The script loads the input data file `EcolArchives-E089-51-D1.csv` in the `code` directory using the relative path, and save the figure result `PP_Regress_Figure.pdf` and regression analysis result `PP_Regress_Results.csv` in the `result` directory using the relative path.
package usages: `dplyr` `ggplot2` `tidyr`


#### -data 
#contains RData and CSV data files used in the R practices.

#### -result
#result files generated after script execution

#### -gitignore
#some unrelated files 


## Author:
Name: Zhilu Zhang
Contact: zhilu.zhang24@imperial.ac.uk