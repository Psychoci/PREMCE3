# PREMCE data pilot 3
Description of the folder and files

## Analysis_files
Folder containing scripts used to analyse the data
### 01. analysis_day1.R
Analysis and data reduction for day 1
### 02.analysis_day2-contingencies.R
Analysis of the statistical learning task at day2
### 02.analysis_day2-recog.R
Analysis of the recognition memory test at day 2
### 02.analysis_day2-recog2.R
Analysis of the recognition memory test at day 2 - trying to set an individual change point 
### 03.analysisRL.R
Analysis of the reinforcement learning data
### 04.modelcomparison.R
Comparison of the diffrent RL models. 

## Computational model
Functions related to the computational model
### BICcompute.R
Function that computes the BIC for each participant. 
### fit_Bayesian.R
Function that find the best fit parameters for the Bayesian model
### fit_RescorlaWagner_feedb.R
Function that find the best fit parameters for a RW model that updates the values according to the feedback that participants receive
### fit_RescorlaWagner_obsALL.R
Function that find the best fit parameters for a RW model that updates all the value depending on the feedback
### lik_Bayesian.R
Function that find the likelihood for the Bayesian model
### lik_RescorlaWagner_feedb.R
Function that find the likelihood a RW model that updates the values according to the feedback that participants receive
### lik_RescorlaWagner_obsALL.R
Function that find the likelihood for a RW model that updates all the value depending on the feedback
### Parameter.estimation.bayesian.R
script that estimates parameter for each participant using the bayesian model
### Parameter.estimation_feedb.R
script that estimates parameter for each participant using the RW feedback model
### Parameter.estimation_obsALL.R
script that estimates parameter for each participant using the RW obsALL model
### SearchGlobal.R
function that iterates the fit function several times to avoid local minima. 
### softmax.R
Function that computes the softmax distribution for RL models

## data_files
Folder with the data files

## data_files_clean
Folder with the data files cleaned

## helper_functions
Functions used by the several scripts

## output_files
Files generated by the scripts

## raw_files
raw output from pavlovia

## testing
Files used for testing


### BayesianModel.odp
Description of the Bayesian model

### Presentation_Behav.odp
Prsentation slides with summaries from previous pilots

### Presentation.odp
Presentation slides starting from the pilot 3 setup
