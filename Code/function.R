# author: Lucy Mosquera
# date: 2020-06-01

suppressWarnings(suppressPackageStartupMessages(library(tidyverse)))
suppressWarnings(suppressPackageStartupMessages(library(tidyselect)))
table4 <- function(simResults, estimate, estimateSE = NA, estimateP = NA, estimateLowCI = NA, estimateHiCI = NA,
                   trueParam, measures = "all", confLevel = 0.95){
  if (length(measures) == 1){
    if (measures == "all"){
      measures <- c("mean", "SD", "convergence", "bias", "empiricalSE", "meanSquaredError", "modelSE",
                    "power", "coverage", "unbiasedCoverage", "confIntLength")
    }
  }
  properties <- setNames(rep(list(NA), 2 * length(measures)), 
                         paste(rep(measures, 2), c(rep("estimate", length(measures)),
                                                   rep("SE" , length(measures))), sep = "-"))
  
  if (is_tibble(simResults)){
    simResults <- as.data.frame(simResults)
  }
  ## Replace any infinite values with NA 
  simResults <- do.call(data.frame,lapply(simResults, function(x) replace(x, is.infinite(x),NA)))
  
  nSim <- sum(! is.na(simResults[, estimate]))
  # Mean
  if ("mean" %in% measures){
    properties["mean-estimate"] <- mean(simResults[, estimate], na.rm = TRUE)
  }
  # SD
  if ("SD" %in% measures){
    properties["SD-estimate"] <- sd(simResults[, estimate], na.rm = TRUE)
  }
  # Convergence
  if ("convergence" %in% measures){
    # Proportion of estimates that are not equal to NA/NaN (counts Inf as a successful estimate)
    properties["convergence-estimate"] <- sum(! is.na(simResults[, estimate])) / nrow(simResults)
  }
  # Bias
  if ("bias" %in% measures){
    properties["bias-estimate"] <-  mean(simResults[, estimate] - trueParam, na.rm = TRUE) 
    properties["bias-SE"] <- sqrt(sum((simResults[, estimate] - mean(simResults[, estimate]))^2, na.rm = TRUE) / (nSim * (nSim - 1)))
  }
  # Empirical SE
  if ("empiricalSE" %in% measures){
    properties["empiricalSE-estimate"] <- sqrt(sum((simResults[, estimate] - 
                                                      mean(simResults[, estimate], na.rm = TRUE))^2, na.rm = TRUE) /
                                                 (nSim - 1))
    properties["empiricalSE-SE"] <- properties[["empiricalSE-estimate"]] / sqrt(2 * (nSim - 1))
  }
  # Mean squared error
  if ("meanSquaredError" %in% measures){
    properties["meanSquaredError-estimate"] <- sqrt(sum((simResults[, estimate] - trueParam)^2, na.rm = TRUE) /
                                                      (nSim))
    properties["meanSquaredError-SE"] <- sqrt(sum(((simResults[, estimate] - trueParam)^2 -
                                                     properties[["meanSquaredError-estimate"]])^2, na.rm = TRUE) / 
                                                (nSim * (nSim - 1)))
  }
  # Model SE
  if ("modelSE" %in% measures & ! is.na(estimateSE)){
    properties["modelSE-estimate"] <- sqrt(sum(simResults[, estimateSE]^2, na.rm = TRUE) / nSim)
    properties["modelSE-SE"] <- sum((simResults[, estimateSE]^2 - properties[["modelSE-estimate"]])^2, 
                                    na.rm = TRUE) / (nSim - 1) 
  }
  # Power
  if ("power" %in% measures & ! is.na(estimateP)){
    properties["power-estimate"] <- sum((simResults[, estimateP] < 0.05), na.rm = TRUE) / nSim
    properties["power-SE"] <- sqrt((properties[["power-estimate"]] * (1 - properties[["power-estimate"]])) / nSim)
  }
  # Coverage
  if ("coverage" %in% measures & ! is.na(estimateLowCI) & ! is.na(estimateHiCI)){
    properties["coverage-estimate"] <- sum((simResults[, estimateLowCI] <= trueParam) &
                                             (simResults[, estimateHiCI] >= trueParam),
                                           na.rm = TRUE) / nSim
    properties["coverage-SE"] <- sqrt(((properties[["coverage-estimate"]] * 
                                          (1 - properties[["coverage-estimate"]])) / nSim))
  }
  # Bias Adjusted Coverage
  if ("unbiasedCoverage" %in% measures & ! is.na(estimateLowCI) & ! is.na(estimateHiCI)){
    properties["unbiasedCoverage-estimate"] <- sum((simResults[, estimateLowCI] <= mean(simResults[,estimate], na.rm = TRUE)) &
                                                     (simResults[, estimateHiCI] >= mean(simResults[,estimate], na.rm = TRUE)),
                                                   na.rm = TRUE) / nSim
    properties["unbiasedCoverage-SE"] <- sqrt(((properties[["unbiasedCoverage-estimate"]] * 
                                                  (1 - properties[["unbiasedCoverage-estimate"]])) / nSim))
  }
  # Conf int length
  if ("confIntLength" %in% measures & ! is.na(estimateSE)){
    critValue <- qnorm((1 - confLevel)/ 2, mean = 0, sd = 1, lower.tail = FALSE)
    properties["confIntLength-estimate"] <- mean(simResults[, estimateSE] * 2 * critValue, na.rm = TRUE)
    properties["confIntLength-SE"] <- sd(simResults[, estimateSE] * 2 * critValue, na.rm = TRUE)
  }
  return(properties)
}

