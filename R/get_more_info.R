source("R/zzz.R")

df <- read.csv("output/ontariofishes_raw.csv")
gg <- validate_names(df$species_itis)

# gg[df$species_itis != gg]
# df$species_itis[df$species_itis != gg]

## Retrieve info 
species(gg)
ecology(gg)
