source("reprex/reprex-in-env.R")

deep_learnr <- function(x, ...) {
  UseMethod("deep_learnr")
}

deep_learnr.matrix <- function(x, y, ...) {
  # matrix method
}

deep_learnr.data.frame <- function(x, y, ...) {
  # data frame method
}

deep_learnr.recipe <- function(x, data, ...) {
  # recipe method
}

deep_learnr.formula <- function(formula, data, ...) {
  # formula method
}