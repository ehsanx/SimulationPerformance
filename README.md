# Simulation Performance Measures

## Data Generating Process

Data was generated from a time-dependent process. True parameter was set to -0.7. 

## Estimates to save

One model was fitted and saved 4 estimates from each simulation iteration:

- `est`: parameter estimate from the model
- `est.SE`: SE estimate obtained from the model
- `est.pVal`: p-value estimate obtained from the model
- `est.LowCI`: Lower bound of confidence interval estimate obtained from the model
- `est.HiCI`: Upper bound of confidence interval estimate obtained from the model

The data is saved in the `Data` folder.

## Usage

The functions provided here are general enough to provide necessary simulation performance measures as described in the reference.

`simres <- readRDS("Data/simres.RDS")`
`source("Code/function.R")`
`table4(simResults=simres, `
       `estimate = "est", `
       `estimateSE = "est.SE", `
       `estimateP = "est.pVal", `
       `estimateLowCI = "est.LowCI", `
       `estimateHiCI = "est.HiCI",`
       `trueParam = -0.7, `
       `measures = "all", `
       `confLevel = 0.95)`
       
## Author: 

[Lucy Mosquera](https://github.com/lucymosquera); date: 2020-06-01

## Reference

Morris, T. P., White, I. R., & Crowther, M. J. (2019). [Using simulation studies to evaluate statistical methods.](https://onlinelibrary.wiley.com/doi/10.1002/sim.8086) Statistics in medicine, 38(11), 2074-2102.