predictors <- as.matrix(mtcars[,c("mpg", "disp", "hp")])
outcome <- mtcars$vs

logistic_regression_impl(predictors, outcome)
