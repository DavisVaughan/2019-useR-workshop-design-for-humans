new_logistic_regression <- function(coefficients, blueprint) {
  
  if (!is.numeric(coefficients)) {
    stop("`coefficients` must be numeric.")
  }
  
  if (!rlang::is_named(coefficients)) {
    stop("All `coefficients` must be named.")
  }
  
  hardhat::new_model(
    coefficients = coefficients,
    blueprint = blueprint,
    class = "logistic_regression"
  )
}
