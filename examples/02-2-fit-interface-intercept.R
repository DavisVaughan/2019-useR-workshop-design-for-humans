library(dplyr)
library(recipes)

# With `intercept`s
logistic_regression(mpg ~ ., mtcars)

logistic_regression(mpg ~ ., mtcars, intercept = FALSE)

# recipes
rec <- recipe(mpg ~ ., mtcars) %>%
  step_intercept()

logistic_regression(rec, mtcars)
