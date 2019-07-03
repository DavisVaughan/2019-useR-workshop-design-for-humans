#' Fit a `logistic_regression`
#'
#' `logistic_regression()` fits a model.
#'
#' @param x Depending on the context:
#'
#'   * A __data frame__ of predictors.
#'   * A __matrix__ of predictors.
#'   * A __recipe__ specifying a set of preprocessing steps
#'     created from [recipes::recipe()].
#'
#' @param y When `x` is a __data frame__ or __matrix__, `y` is the outcome
#' specified as:
#'
#'   * A __data frame__ with 1 numeric column.
#'   * A __matrix__ with 1 numeric column.
#'   * A numeric __vector__.
#'
#' @param data When a __recipe__ or __formula__ is used, `data` is specified as:
#'
#'   * A __data frame__ containing both the predictors and the outcome.
#'
#' @param formula A formula specifying the outcome terms on the left-hand side,
#' and the predictor terms on the right-hand side.
#'
#' @param ... Not currently used, but required for extensibility.
#'
#' @param intercept A logical for whether or not to add an intercept.
#'
#' @return
#'
#' A `logistic_regression` object.
#'
#' @export
logistic_regression <- function(x, ...) {
  UseMethod("logistic_regression")
}

#' @export
#' @rdname logistic_regression
logistic_regression.default <- function(x, ...) {
  stop("`logistic_regression()` is not defined for a '", class(x)[1], "'.", call. = FALSE)
}

# XY method - data frame

#' @export
#' @rdname logistic_regression
logistic_regression.data.frame <- function(x, y, intercept = TRUE, ...) {
  bp <- hardhat::default_xy_blueprint(intercept = intercept)
  processed <- hardhat::mold(x, y, blueprint = bp)
  logistic_regression_bridge(processed, ...)
}

# XY method - matrix

#' @export
#' @rdname logistic_regression
logistic_regression.matrix <- function(x, y, intercept = TRUE, ...) {
  bp <- hardhat::default_xy_blueprint(intercept = intercept)
  processed <- hardhat::mold(x, y, blueprint = bp)
  logistic_regression_bridge(processed, ...)
}

# Formula method

#' @export
#' @rdname logistic_regression
logistic_regression.formula <- function(formula, data, intercept = TRUE, ...) {
  bp <- hardhat::default_formula_blueprint(intercept = intercept)
  processed <- hardhat::mold(formula, data, blueprint = bp)
  logistic_regression_bridge(processed, ...)
}

# Recipe method

#' @export
#' @rdname logistic_regression
logistic_regression.recipe <- function(x, data, intercept = TRUE, ...) {
  bp <- hardhat::default_recipe_blueprint(intercept = intercept)
  processed <- hardhat::mold(x, data, blueprint = bp)
  logistic_regression_bridge(processed, ...)
}
