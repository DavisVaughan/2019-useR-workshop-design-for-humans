library(rsample)
library(tibble)

set.seed(123)

split <- initial_split(admittance)
train <- training(split)
test <- testing(split)

model <- logistic_regression(admit ~ log(gre), train)

# preprocesses predictors
predict(model, test)

# validation of all kinds
predict(model, mtcars)

predict(model, tibble(gre = "hi"))