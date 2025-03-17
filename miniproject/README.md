# PROJECT NAME: MINIPROJECT

## Project Overview: 
The miniproject is to find the best fit mathematical models for an empirical dataset. In my report, I compare three commonly used models for bacterial growth: the Logistic, Cubic, and Gompertz models. Model fitting and model selection were done for analysis.

## Languages and Tools Used:
`Shell Scripting (Bash)`: The scripts are written in Bash
`R`: R studio under the version 4.1.2
`LaTeX`

### Main Tools:
 - R base functions
 - R packages: dplyr, ggplot2, minpack.lm, tidyr
 - IDEs: Visual Studio Code
 
## Dependencies/Installation:
## Installation/Running:
installation: installing the required R package: 
```R
install.packages("") 
```

Running the scripts:
```bash
miniproject.sh
```
```R
source("")
```

## Project Structure and Usage:
### Code 

**miniproject_code.R**: This is the R code for the analysis including in the report. 
The input data files include `LogisticGrowthData` in the `data` directory. And it will produce three result plots to the `plot` directory


**miniproject.tex**: A latex document for the report

**miniproject.sh** : a shell script to run the miniproject_code.R and miniproject.tex

**reference.bib** : the bibliography used to generate the references

### Data
-contains LogisticGrowthData.csv and LogisticGrowthMetaData.csv for the analysis

### result
-result files generated after script execution


### gitignore

## Author:
Name: Zhilu Zhang
Contact: zhilu.zhang24@imperial.ac.uk