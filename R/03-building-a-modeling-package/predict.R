predict.logistic_regression <- function(object, new_data, type = "prob", ...) {
  processed <- hardhat::forge(new_data, object$blueprint)
  type <- rlang::arg_match(type, valid_predict_types())
  predict_logistic_regression_bridge(type, object, processed$predictors)
}

valid_predict_types <- function() {
  c("prob", "class")
}