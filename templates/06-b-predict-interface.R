#' Predict from a `logistic_regression`
#'
#' @param object A `logistic_regression` object.
#'
#' @param new_data A data frame of new predictors.
#'
#' @param type A single character. The type of predictions to generate.
#' Valid options are:
#'
#' - `"prob"` for soft probability predictions.
#' - `"class"` for hard predictions with a 50 percent threshold
#'
#' @param ... Not used, but required for extensibility.
#'
#' @return
#'
#' A tibble of predictions. The number of rows in the tibble is guaranteed
#' to be the same as the number of rows in `new_data`.
#'
#' @examples
#' train <- mtcars[1:20,]
#' test <- mtcars[21:32, -1]
#'
#' # Fit
#' mod <- logistic_regression(mpg ~ cyl + log(drat), train)
#'
#' # Predict, with preprocessing
#' predict(mod, test)
#'
#' @export
predict.logistic_regression <- function(object, new_data, type = "prob", ...) {
  forged <- hardhat::forge(new_data, object$blueprint)
  rlang::arg_match(type, valid_predict_types())
  predict_logistic_regression_bridge(type, object, forged$predictors)
}

valid_predict_types <- function() {
  c("prob", "class")
}
