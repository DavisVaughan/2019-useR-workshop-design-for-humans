
# Workshop outline

## Technical bits

  - Need 1 TA
  - 3 hours
  - Plus a 30 minute break
  - 26 people

## Bigger picture

  - Discuss the modeling principles guide

  - Why does this package exist?
    
      - Discuss common pitfalls
      - Case studies of common issues
          - Particularly painful packages
      - Case studies of good implementations?

## hardhat specific ideas

  - Discuss the issue of the package developer not wanting to understand
    all about how `model.matrix()` works

  - Preprocessing at prediction time on new test data
    
      - Storing the hardhat blueprint for prediction

  - Validation
    
      - New columns
      - Not enough columns
      - Novel factor levels
      - Not enough factor levels
      - Lossless conversion, nice automatic character -\> factor
        conversion

  - Standardizing prediction output

  - Various preprocessing tricks
    
      - Whether or not to automatically include an intercept
          - Case study of earth package
      - Whether or not to automatically expand dummy variables
          - Case study of the ranger package
      - Multivariate outcomes
          - `cbind()` in `lm()`

  - Preprocessing with recipes
    
      - Whether or not to use `skip = TRUE`

## Implementing a package that uses hardhat

  - Model constructors
      - Why are they useful?
      - What should they do?
  - Bare bones of S3
      - Why is it useful?
      - How does it work `<generic>.<method>()`
      - A simple non-modeling example
  - User facing function with interfaces for:
      - data frame
      - matrix
      - formula
          - Historical fun fact - hardcoded allowance for `formula` to
            be the dispatch arg
      - recipe
  - Separation of the interface from the implementation
      - `linear_regression()` vs `linear_regression_impl()`
  - Modeling bridge function
      - Receives processed `mold()` data
      - Calls the implementation function
      - Returns a new instance of our model class
  - Prediction
      - Always returns the same class of output (tibble)
      - Standardize on `type`
      - Standardized column names
      - Always return the same number of rows as the input (NA value
        issues)
          - Case study of situations where this doesn’t happen
  - Prediction bridge function
      - Convert `forge()`d predictors to implementation ready type
        (matrix)
      - Switch on the `type` and dispatch to the prediction
        implementation function
          - Ensure the implementation function called `spruce_()`
      - Call `validate_prediction_size()` at some point
