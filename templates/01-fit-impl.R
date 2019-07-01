#' Low level logistic regression implementation
#' 
#' @details 
#' 
#' - Using `glm.fit()`, not `glm()` because we want to pass x and y
#' - x must be a matrix
#' - y must be a vector of 0/1 values
#' - `glm.fit()` assumes the first level of the outcome is failure
#' - hardhat handles the intercept
#' 
#' @param predictors A numeric matrix of predictors.
#' @param outcome A vector of 0/1 values, or a binary factor.
#' 
#' @importFrom stats glm.fit
#' @importFrom stats binomial
#' 
#' @keywords internal
logistic_regression_impl <- function(predictors, outcome) {
  
  # Fit the model
  fit <- stats::glm.fit(
    x = predictors,
    y = outcome,
    family = stats::binomial(),
    intercept = FALSE
  )
  
  # Return the model elements back as a named list
  list(
    coefficients = fit$coefficients
  )
}
