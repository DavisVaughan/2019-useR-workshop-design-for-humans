predict_logistic_regression_bridge <- function(type, model, predictors) {
  predictors <- as.matrix(predictors)
  
  predict_function <- get_predict_function(type)
  predictions <- predict_function(model, predictors)
  
  hardhat::validate_prediction_size(predictions, predictors)
  
  predictions
}

get_predict_function <- function(type) {
  switch(
    type,
    class = predict_logistic_regression_class,
    prob = predict_logistic_regression_prob
  )
}
