# Non-life-Insurance-project
## Auto Insurance Pricing with R

This repo covers a non-life insurance assignement for ENSAE courses. The instructions are given [here](https://github.com/Noureddineidir/Non-life-Insurance-project/blob/8018d867cb5fb83720031870876c719ee6952578/consignes/Instruction-Projet.pdf). Data comes from the Third Actuarial Pricing Game. For more information on the data available and the context of the competition, please refer to [this document](https://github.com/Noureddineidir/Non-life-Insurance-project/blob/8018d867cb5fb83720031870876c719ee6952578/consignes/3rdPricingGame.pdf).

The main goal of this project is to calibrate models based on the traditional frequency/severity approach with GLMs. We provide in fine two databases containing the pure premium pricing as well as a commercial pricing (with a surcharge rate).

The repo is organized in folders used at different stages of the project. A brief description of the folders is given below

-----------------------------------------------------------------------------------------
## Code 

This folder contains the code files necessary for the pricing and production of the csv with the two proposed premium : 

* [1_calibr_reg_frequence.R](https://github.com/Noureddineidir/Non-life-Insurance-project/blob/8018d867cb5fb83720031870876c719ee6952578/code/1_calibr_reg_frequence.R) calibrates the final frequency model. 
* [1_calibr_reg_severity.R](https://github.com/Noureddineidir/Non-life-Insurance-project/blob/c66a0b23fbf60704eb9ba898c7fc4c40e8a87b7d/code/1_calibr_reg_severity.R) calibrates the final severity model and function to evaluate model performance.
* [2_pure_premium.R](https://github.com/Noureddineidir/Non-life-Insurance-project/blob/c66a0b23fbf60704eb9ba898c7fc4c40e8a87b7d/code/2_pure_premium.R) provides functions to calculate pure premium based on our two  previous models. 
* [3_bootstrapSimu.R](https://github.com/Noureddineidir/Non-life-Insurance-project/blob/c66a0b23fbf60704eb9ba898c7fc4c40e8a87b7d/code/3_bootstrapSimu.R) provides function to simulate the overall disaster losses of the validation portfolio (year 0). We here use 10 000 simulations. 
* [4_com_premium.R](https://github.com/Noureddineidir/Non-life-Insurance-project/blob/c66a0b23fbf60704eb9ba898c7fc4c40e8a87b7d/code/4_com_premium.R) provides functions to computes quantiles of the overall losses over the scenarios and compute calculations to find the surcharge rate that covers in 95% of the cases.  
* [5_main_code.R](https://github.com/Noureddineidir/Non-life-Insurance-project/blob/c66a0b23fbf60704eb9ba898c7fc4c40e8a87b7d/code/5_main_code.R) call all the previous functions and runs them it order to offer a pure premium as well as the commercial premium (after simulating overall losses and printing plot to find the surcharge rate) and write the results in TARIFPUR.csv and TARIFCOM.csv. 

## Markdown

Before calibrating models, descriptive statistics, features selection and models comparisons were made for both frequency and severity. These studies are available in different files in this folder in R markdown and HTML formats (please note that HTMLs are on first page). 

## Data 
 
The data is a subset of policies used for the Third Actuarial Pricing Game. 

