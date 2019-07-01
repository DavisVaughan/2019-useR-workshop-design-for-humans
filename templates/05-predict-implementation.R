# DISCLAIMER: predict.glm uses predict.lm, which uses information from
# the qr decomposition to pivot the columns of X to match that of the
# original qr pivot. We have not carried that information along. A pivot
# only happens with "columns with near-zero 2-norm" which isn't the
# case for any of our examples.

predict_logistic_regression_prob <- function(model, predictors) {
  log_odds <- predict_logistic_regression_link(model, predictors)
  
  family <- stats::binomial()
  
  # solve for p: `log_odds = ln(p / (1 - p))`
  prob_success <- family$linkinv(log_odds)
  prob_failure <- 1 - prob_success
  
  # Reverse the probabilities since `levels` will have failure first
  prob <- cbind(prob_failure, prob_success)
  
  blueprint <- model$blueprint
  
  levels <- levels(blueprint$ptypes$outcomes[[1]])
  
  hardhat::spruce_prob(levels, prob)
}

predict_logistic_regression_class <- function(model, predictors) {
  blueprint <- model$blueprint
  levels <- levels(blueprint$ptypes$outcomes[[1]])
  
  prob_tbl <- predict_logistic_regression_prob(model, predictors)
  prob_failure <- prob_tbl[[1]]
  
  # The first level corresponds to failure in glm()
  pred_class <- ifelse(prob_failure >= .50, levels[1], levels[2])
  pred_class <- factor(pred_class, levels)
  
  hardhat::spruce_class(pred_class)
}

predict_logistic_regression_link <- function(model, predictors) {
  coefficients <- model$coefficients
  
  # log_odds = X'B
  log_odds <- predictors %*% coefficients
  log_odds <- as.vector(log_odds)
  
  log_odds
}
