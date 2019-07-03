library(readr)

admittance_raw <- read_csv("https://stats.idre.ucla.edu/stat/data/binary.csv")

write_csv(admittance_raw, "data/admittance-raw.csv")
