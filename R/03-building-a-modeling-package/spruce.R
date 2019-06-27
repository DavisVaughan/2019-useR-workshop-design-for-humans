source("reprex/reprex-in-env.R")

library(hardhat)

# From the blueprint
# levels(model$blueprint$ptypes$outcomes[[1]])
pred_levels <- c("a", "b")

# You compute this
pred_matrix <- matrix(1:6, ncol = 2)

spruce_prob(pred_levels, pred_matrix)
