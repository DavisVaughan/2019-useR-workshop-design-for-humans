source("reprex/reprex-in-env.R")

new_secret <- function(x = double()) {
  stopifnot(is.double(x))
  
  structure(
    x,
    class = "secret"
  )
}

new_secret(55)

new_secret <- function(x = double(), 
                       name = character()) {
  stopifnot(is.double(x))
  stopifnot(is.character(name))
  
  structure(
    x,
    name = name,
    class = "secret"
  )
}

new_secret(55, "bob")

new_secret <- function(x = double(), 
                       name = character(), 
                       ..., 
                       class = character()) {
  stopifnot(is.double(x))
  stopifnot(is.character(name))
  
  structure(
    x,
    name = name,
    ...,
    class = c(class, "secret")
  )
}

new_secret(55, "bob", class = "super-secret")
