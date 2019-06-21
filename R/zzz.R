library(tidyverse)
library(taxize)
library(rfishbase)

`%m%` <- function(a, b) {
   lapply(a, function(x) which(b == x)) %>% unlist
 }

# simple home made progree bar
cat_pb <- function(i, n) cat("==>", i, "/", n, "    \r")
