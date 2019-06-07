
# Workshop outline

## Technical bits

  - Need 1 TA

  - 3 hours

  - Plus a 30 minute break

  - 26 people

  - Gitter live chat

  - RStudio Pro instances (30?)

  - Shortlink for materials

  - Slides made in keynote

## General structure

  - Introduction to modeling principles
  - Go over hardhat, with hands on sections
  - Build a modeling R package that implements these “best practices”
      - A mix of slides and hands on work to actually get a working R
        package
      - usethis will come in handy

## Outline

### Introduction deck

Needs RStudio logo

  - Title slide
  - Shortlink to materials
  - Introduce self + Kelly
  - Outline the 3 hours + break (just the time)
  - Outline what we hope to accomplish in the 3 hours
  - Shortlink again
  - Gitter
  - Explain that everything is available
  - 5 minutes to meet each other

### Deck 1 - The big picture

  - Title slide

  - The R modeling ecosystem
    
      - The wild west
      - Lack of standards
          - 2003 BDR -
            <https://developer.r-project.org/model-fitting-functions.html>

  - What makes the R modeling ecosystem painful?
    
      - Show the `predict()` table with all of the different packages /
        ways to get class probs
      - Predictions with a different number of rows as the input
      - “glmnet doesn’t work for me, I work for glmnet”
      - TODO more?

  - What makes a good modeling R package?
    
      - Familiar interfaces
      - Good defaults
      - TODO more?

  - Details laid out in modeling principles guide
    
      - Link to the guide

  - If these principles are good, why isn’t everyone doing it?
    
      - Consider the typical R modeling developer
          - Statistical researcher
          - Not a software engineer
          - Might have an A+ rock solid implementation
          - But UI is $hit
      - Key point: A lack of knowledge and tooling to make good UI
      - Discuss the issue of the package developer not wanting to
        understand all about how `model.matrix()` works
      - Can we:
          - Provide the tooling
          - Lower the amount of knowledge required

  - hardhat - A toolkit for the construction of modeling packages
    
      - Provide opionated rules around creating modeling packages
      - Do the “hard work” around preprocessing user input
          - This otherwise requires special knowledge on the developer’s
            part
              - `model.matrix()`? recipe? formula method? Just make it
                work…
      - Add structure and consistency around the `predict()` method
      - Provide additional tooling for input validation, with expressive
        error messages

  - Who wins? Everyone.
    
      - Developers can focus on their implementations
      - Users can reap the benefits of a good UI

### Deck 2 - hardhat

  - What are the steps in building a modeling package?
      - A low level model fitting function
      - A high level model fitting user interface
      - A model object that you return to the user
      - A `predict()` function
      - Various methods you might implement `coef()`, `summary()`…
      - hardhat has something to offer for all of these
      - Good place for the pictures in the hardhat vignette\!
  - High level interfaces
      - What do I mean by interfaces?
          - Formula, data.frame, matrix, recipes
      - When would I use one over the other?
          - Formula VS XY? (Pull from rstudio conf workshop, drawbacks
            of each)
      - How do I implement one?
          - A crash course on S3
          - `<generic>.<method>()`
          - Historical fun fact - hardcoded allowance for `formula` to
            be the dispatch arg
  - Low level implementation
      - Accepts only the required inputs, in their raw-est form
      - This is where you as the package developer shines
      - Returns a named list of the objects you want in your model
        object
  - Bridging the gap
      - The high level interface should be agnostic to the low level
        implementation
      - You need something that bridges the gap between them
      - This kind of function should accept the preprocessed data, and
        return a model object using a *constructor*.
      - Along the way it can convert your preprocessed data to a lower
        level format
      - And run the implementation function
  - Model constructors
      - What is a constructor?
          - Mention advanced R section on constructors
      - Why are they useful (aka why do I care)?
      - What does my model object need?
          - Consider the generics you want methods for
              - `coef()`?
              - `residuals()`?
              - Your own custom ones?
          - Retain the minimally sufficient set
      - Do *not* store the call.
          - Example with `x <- do.call(lm, list(formula = mpg ~ cyl,
            data = mtcars))`
          - This isn’t a new
                idea\!
              - <https://github.com/topepo/caret/issues/76#issuecomment-63856383>
          - `call-hell.R`
      - Try not to store the `terms` object or the model frame
          - `lm-hell.R`
  - High level `predict()`ion
      - `predict()` generic
      - What should the `type` be?
      - `new_data`
      - Each `type` should have its own implementation
      - Return the correct number of rows
          - Case study of situations where this doesn’t happen
  - Low level predict implementations
      - Classification
          - Might have `"class"` or `"prob"` `type`
          - General advice - separation:
              - `predict_<model_fn>_class()`
              - `predict_<model_fn>_prob()`
  - Bridging the gap 2
      - Like with fitting, it makes sense to separate the high level
        predict interface from the low level implementation functions
      - The bridge function takes the processed `new_data` predictors
        and passes them along to the correct implementation method
      - It also has the *very* important job of enforcing size stability
          - Number of rows in the output should be the same as the input
  - So how does hardhat help?
      - It can set all of this up for you with a call to
        `create_modeling_package()`
  - What else can hardhat help with? (the following sections explain)
      - “A tour of hardhat”
  - Consider: Standardization
      - Different interfaces take data in different ways
      - Your implementation function only cares about the raw predictors
        / outcomes
      - Introducing `mold()`
      - Mold takes data in all of the common interface formats and
        standardizes it
      - As you will also see, it does much more with regards to
        preprocessing
  - Consider: Preprocessing
      - Preprocessing at prediction time on new test data
          - Needs to use the same preprocessing as training data
          - Storing the hardhat blueprint for prediction
      - Introducing `forge()`
          - Using the blueprint that `mold()` returns
          - Handles the standardization of new data to a common format
          - And preprocesses the new data using the same processing done
            on the original data
      - Various preprocessing variations
          - The hardhat `blueprint` object
              - Can tweak defaults
          - Whether or not to automatically include an intercept
              - Case study of earth package
          - Whether or not to automatically expand dummy variables
              - Case study of the ranger package
          - Multivariate outcomes
              - `cbind()` in `lm()`
  - Consider: Validation
      - `forge()` uses the blueprint to do more than just preprocess the
        new data
      - `shrink()`
          - Not enough columns
      - `scream()`
          - Handles all other validation
          - Novel factor levels
          - `vec_cast()` magic
              - New columns
              - Not enough factor levels
              - Lossless conversion, nice automatic character -\> factor
                conversion
  - Consider: Prediction
      - Want to return consistent output
          - A `tibble()` with properly named columns
          - `spruce_*()` functions
      - Want to ensure number of rows of output are the same as input
          - `validate_prediction_size()`

### Deck 3 - Building a modeling package

  - Your new best friends
      - usethis
      - devtools
      - hardhat
  - What are we creating?
      - A logistic regression package
      - Under the hood, we will use `glm()` for the implementation
      - and `predict.glm()` for prediction implementation
  - Getting started
      - Creating a new modeling package requires some boilerplate
      - `hardhat::create_modeling_package()`
      - `devtools::load_all()`
  - What did this do?
      - See `?logistic_regression`
      - See the files in `R/`
  - They should “just work” immediately
      - Run the examples in `?logistic_regression`
      - And `?predict.logistic_regression`
  - What now?
      - We are going to fill in each of the sections of the skeleton,
        utilizing these best practices that we have learned.
  - Stage 1 - Fit implementation
      - Details
          - Using glm.fit(), not glm() because we want to pass x and y
          - x must be a matrix
          - y must be a vector of 0/1 values
          - glm.fit() assumes the first level of the outcome is failure
          - hardhat handles the intercept
          - Return a list of the important components
          - Disclaimer about not returning important information about
            rank/pivot and that for our use cases they won’t matter
      - Practice
          - Raw inputs as matrix / vector
          - “But at least it works\!”
          - Notice no intercept. That isn’t the job of the
            implementation function
  - Stage 2 - Fit bridge - 1
      - Details
          - Takes the output from a call to `mold()` (`processed`)
          - Extract out the predictors `as.matrix(processed$predictors)`
          - Extract out the outcomes `processed$outcomes[[1]]`
          - Pass them on to the implementation function, which returns
            the result
      - Practice
          - Call `mold()` on our data, and pass it in as `processed`
          - Slightly better because `mold()` can handle formula method\!
  - Stage 3 - Fit bridge - 2
      - Details
          - What are we missing? Validation. Constructor.
          - Validation
              - Predictors
                  - Numeric columns in the data frame
              - Outcome
                  - Factor
                  - Binary
                  - Univariate
      - Practice
          - Try to pass in some bad inputs
              - Non factor outcome
              - Non binary factors (iris)
  - Stage 4 - Model constructor
      - Details
          - The implementation function guides what we need here
          - `coefficients`
          - `blueprint`
          - `hardhat::new_model()`
              - Some validation: named `...`, unique names, etc
              - Print method - Hides the blueprint by default
              - In the future this might do more `vctrs::new_sclr()`
                  - `[` method
          - Fit bridge
              - Return a `new_logistic_regression_model()` from the
                bridge
      - Practice
          - Run the same code as before, but now we have an actual model
            object
          - Run `class()` on it
          - See that the blueprint is inside
  - Stage 5 - Fit interface
      - Details
          - Is there anything to do? What are we missing?
              - Intercept\!
          - Show `mold()` documentation and that it uses a default
            blueprint
          - Show the `default_formula_blueprint()` docs
              - Two arguments `intercept` / `indicators`
              - Documentation about what it does when mold / forge are
                called
          - Add a tweaked default blueprint for each method and pass it
            on to `mold()`
          - Add a `intercept = TRUE` argument
          - Document it\!
      - Practice
          - Run the same code as before, but see that we now get an
            intercept in the output
          - Run `mold()` by itself to see the intercept column
  - Stage 6 - Predict implementation - 1
      - Details
          - Normally this is where you would have to do a lot more work
          - We are going to cheat a lot
          - Assume `predictors` is a matrix
          - Remember the format of logistic regression
              - You can use the linear regression prediction function
                `X*beta` to get the “link” function predictions
              - This is `type = "link"` if you ever use `predict.glm()`
          - Implement `predict_logistic_regression_link()`
      - Practice
          - Run `logistic_regression()` and pass the results into the
            link function with `test` data.
          - Compare with `predict(mod_glm, test, type = "link")`
  - Stage 7 - Predict implementation - 2
      - Details
          - From the link function, we get the probabilities
          - We have to “invert” the link function,
            `binomial()$linkinv(pred_link)`
          - This gives us the probability of “success”
          - It’s good practice to return the probabilities for all
            levels so we also return failure
          - We return them both in the order they appear in the model
              - Failure, then Success
          - Important\! The blueprint holds valuable information in the
            `ptypes`
              - `ptypes$outcomes` is the 0-row tibble that was used at
                fit time, so it has all the factor levels\!
          - Pass these on to `spruce_prob()` to return a tidy tibble of
            probabilities
      - Practice
          - Same code as before but call
            `predict_logistic_regression_prob()`
  - Stage 8 - Predict bridge
      - Details
          - `type` is a character string
          - `predictors` here is a data frame (comes from `forge()`)
          - Convert `predictors` to a matrix
              - This is the place to do that. Bridge converts to low
                level types
          - Write small helper function to switch on the type
              - `get_predict_function()`
          - `validate_prediction_size()` as a self check
          - Question: What other types could we have?
      - Practice
          - Use `type = "prob"` and pass in the same data as before to
            the bridge but where `predictors` is `forge()` output
  - Stage 9 - Predict interface
      - Details
          - Update the default `type`
          - Update the valid predict types
          - TODO - Do we need to `@importFrom stats predict`?
      - Practice
          - Call `predict()` on the `mod_logreg` with `test`
  - Stage 10 - Predict implementation - 2
      - Details
          - Add `predict_logistic_regression_class()`
          - Failure is the first column in `prob_tbl`
          - `hardhat::spruce_class()`
          - Add to the bridge
              - `get_predict_function()`
          - Add to the interface
              - `valid_predict_types()`

Stage 11 - Pass CRAN check - `usethis::use_license()` - Update interface
documentation - `predict()` - `logistic_regression()` - What else?

Stage 12 - A note on recipes - Time permitting - Preprocessing with
recipes - Whether or not to use `skip = TRUE`

Stage 13 - Extra methods - Very much time permitting - `coef()` is easy
- `fitted()` is easy - `data` argument as opposed to holding onto the
fitted values - `stats::predict(type = "prob")` to get the fitted values
- `residuals()` if time - Required items - fitted values from `fitted()`
- preprocessed outcome from `forge()` - Two kinds - Pearson - Deviance -
TODO read up more about these - Show formulas for the two kinds -
Disclaimer about the deviance one being a shortcut -
`usethis::use_package("ellipsis")` - `ellipsis::check_dots_used()`
