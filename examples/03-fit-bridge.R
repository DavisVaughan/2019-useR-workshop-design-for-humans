logistic_regression(mpg ~ ., mtcars)

logistic_regression(Species ~ ., iris)

library(readr)
library(dplyr)
admittance_raw <- read_csv("../2019-useR-workshop-design-for-humans/data/admittance-raw.csv")

admittance <- admittance_raw %>%
  mutate(
    admit = as.factor(admit), 
    rank = as.factor(rank)
  )

logistic_regression(admit ~ ., admittance)

logistic_regression(admit ~ ., admittance, intercept = FALSE)

# interactions
logistic_regression(admit ~ . + gpa:rank, admittance, intercept = FALSE)

# can't remove intercept this way
logistic_regression(admit ~ gpa + 0, admittance)

# can't use global variables
x <- 1
logistic_regression(admit ~ x + gpa, admittance)

# usethis::use_data(admittance)
