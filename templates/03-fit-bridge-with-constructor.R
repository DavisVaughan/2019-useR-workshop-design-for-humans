#' Fit bridge
#'
#' @details
#'
#' The bridge connects the high level interface methods with the low level
#' implementation.
#'
#' Pass through other objects to the implementation function as required.
#'
#' @param processed
#'
#' @keywords internal
logistic_regression_bridge <- function(processed) {
  
  # Validate and process predictors
  predictors <- processed$predictors
  hardhat::validate_predictors_are_numeric(predictors)
  predictors <- as.matrix(predictors)
  
  # Validate and process outcomes
  outcome <- processed$outcomes
  hardhat::validate_outcomes_are_factors(outcome)
  hardhat::validate_outcomes_are_binary(outcome)
  hardhat::validate_outcomes_is_univariate(outcome)
  outcome <- outcome[[1]]
  
  # Fit the model
  fit <- logistic_regression_impl(predictors, outcome)
  
  # Constructor stuff
  new_logistic_regression(
    coefficients = fit$coefficients,
    blueprint = processed$blueprint
  )
}
