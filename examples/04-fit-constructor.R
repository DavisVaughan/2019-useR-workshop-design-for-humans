logistic_regression(admit ~ ., admittance)

model <- logistic_regression(admit ~ ., admittance)

names(model)

model$coefficients
model$blueprint

attributes(model)