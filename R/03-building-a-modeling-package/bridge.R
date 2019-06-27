source("reprex/reprex-in-env.R")

deep_learnr_bridge <- function(processed, ...) {
  
  # Validate and process predictors
  predictors <- processed$predictors
  hardhat::validate_predictors_are_numeric(predictors)
  predictors <- as.matrix(predictors)
  
  # Validate and process outcomes
  outcome <- processed$outcomes
  hardhat::validate_outcomes_is_univariate(outcome)
  outcome <- outcome[[1]]
  
  # Fit the model
  fit <- deep_learnr_impl(predictors, outcome, ...)
  
  # constructor stuff
}
