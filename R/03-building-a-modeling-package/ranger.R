source("reprex/reprex-in-env.R")

# Top level function
ranger::ranger(formula, data)

ranger <- function(formula, data, ...stuff...) {
  # preprocessing
  
  result <- rangerCpp(...stuff..., data.final, ...stuff...)
  
  # finalize `result` and add the class
  
  result
}