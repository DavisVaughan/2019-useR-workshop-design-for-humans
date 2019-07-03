library(dplyr)
library(recipes)

# formula method
logistic_regression(mpg ~ ., mtcars)

logistic_regression(mpg ~ ., mtcars, intercept = FALSE)

# robustness on `y`
logistic_regression(mtcars, "x")

# recipes
rec <- recipe(Sepal.Length ~ Species + Sepal.Width, iris) %>%
  step_dummy(Species) %>%
  step_log(Sepal.Width)

logistic_regression(rec, iris)

# recipes
rec_intercept <- recipe(mpg ~ ., mtcars) %>%
  step_intercept()

logistic_regression(rec_intercept, mtcars)
