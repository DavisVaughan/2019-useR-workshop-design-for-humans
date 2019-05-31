# often package developers store the call in their model object
# and then print it out in their summary / print methods  
lm_model <- lm(mpg ~ cyl, mtcars)

lm_model

lm_model$call

# normally this is not an issue, but sometimes package _users_
# want to call that modeling function programatically. This often
# means that they use `do.call()`
.f <- mpg ~ cyl
.data <- mtcars
lm_model_do_call <- do.call(lm, list(formula = .f, data = .data))

# essentially, this inlines the `data` in a textual representation in the call
# OH THE HORROR
lm_model_do_call

# note the difference in size!
object.size(lm_model)
object.size(lm_model_do_call)

# here it is
object.size(lm_model_do_call$call)

# if you are a package developer, please don't save the call

# if you are a package user, you can avoid this issue with rlang
library(rlang)

clean_lm_call <- call2("lm", mpg ~ cyl, sym("mtcars"))
clean_lm_call

eval_bare(clean_lm_call)

# or with base R
eval(call("lm", mpg ~ cyl, substitute(mtcars)))

# if you need to control the environment that `mtcars` is evaluated (i.e. looked up)
# in, you can either quo() it to tie the environment to the symbol and use eval_tidy()
# or you can also specify an environment to the `eval_bare()` call for terms to be
# looked up in

# lets use a different data set where we have to control the environment

generate_call_bad <- function() {
  my_data <- mtcars
  call2("lm", mpg ~ cyl, sym("my_data"))
}

generate_call_bad()

# oh no :/
eval_bare(generate_call_bad())

generate_call_good <- function() {
  my_data <- mtcars
  call2("lm", mpg ~ cyl, quo(my_data)) # <- the symbol `my_data` + environment are kept
}

call_good <- generate_call_good()
call_good

# ah there it is, see the `env`ironment?
# that tells us where to look up `my_data`
call_good[[3]]

eval_tidy(generate_call_good())
