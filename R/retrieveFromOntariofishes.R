source("R/zzz.R")

## 1- Webscrapping http://www.ontariofishes.ca
ls_data <- list()
n <- 159
for (i in 1:n) {
  cat_pb(i, n)
  tmp <- readLines(paste0("http://www.ontariofishes.ca/fish_detail.php?FID=", i))
  ls_data[[i]] <- cbind(
    tmp[grepl("DataLabel", tmp)] %>% gsub(".*LEFT>", "", .) %>%
      gsub("</TD.*", "", .) %>% `[`(1:38),
    tmp[grepl("DataText", tmp)] %>% gsub(".*RIGHT>", "", .) %>%
      gsub(".*LEFT>", "", .) %>% gsub("<[/]?I>", "", .) %>%
      gsub("<[/]?SUP>", "", .) %>% gsub("</TD.*", "", .) %>% `[`(1:38)
    )
}

## 2- Clean up
df <- ls_data %>%
  lapply(function(x) x[,2]) %>%
  do.call(rbind, .) %>%
  as.data.frame(stringsAsFactors = FALSE)

## Columns names
names(df) <- gsub(ls_data[[1]][,1], pattern = " ", replacement = "_") %>%
  gsub(pattern = "\\(", replacement = "") %>%
  gsub(pattern = "\\)", replacement = "") %>%
  gsub(pattern = "&deg;C", replacement = "Celsius")

## I only use the common term for families and retrieve the classification
## from taxize
df$Family <- strsplit(df$Family, " - ") %>% lapply(function(x) x[2]) %>% unlist
names(df)


## 3- Retrieve classification form itis database
res <- list()
df0 <- data.frame(
  class = NA, order = NA, family = NA, genus = NA, species = NA
)
## A couple of tsn need to be updated (valid names but wrong tsn...)
## Catostomus commersonii; tsn => 553273
## Chrosomus eos ; tsn => 913993
## Chrosomus neogaeus ; tsn => 913995
## Coregonus artedi;  tsn => 623384
## Coregonus hoyi => 623394
## Coregonus nigripinnis => 623395
## Coregonus nipigon => Coregonus artedi; tsn => 623384
## Labidesthes sicculus; tsn => 166016
## Lethenteron appendix; tsn => 914061
## Lepomis gulosus; tsn => 168138 (invalid=>Chaenobryttus gulosis)
## Moxostoma duquesnei (name invalid) => Moxostoma duquesnii; tsn => 553274
## Prosopium coulterii; tsn => 553389
df$Species_TSN2 <- df$Species_TSN

wsp <- function(x) unlist(lapply(x, function(y) which(df$Species == y)))

nm <- c("Catostomus commersonii", "Chrosomus eos", "Chrosomus neogaeus",
"Coregonus artedi", "Coregonus hoyi",  "Coregonus nigripinnis", "Coregonus nipigon",
"Labidesthes sicculus", "Lethenteron appendix", "Lepomis gulosus",
"Moxostoma duquesnei", "Prosopium coulterii")

tsn <- c(553273, 913993, 913995, 623384, 623394, 623395, 623384, 166016, 914061, 168138, 553274, 553389)
df$Species_TSN2[wsp(nm)] <- tsn

nm <- c("class", "order", "family", "genus", "species")
for (i in 1:nrow(df)) {
  cat_pb(i, nrow(df))
  res[[i]] <- df0
  if (df$Species_TSN2[i] != "not applicable") {
    tmp <- classification(df$Species_TSN2[i], db = "itis")
    id <- nm %m% tmp[[1]]$rank
    res[[i]][1,] <- tmp[[1]]$name[id]
  }
}
cat("\n")
##
info_itis <- do.call(rbind, res)
names(info_itis) <- paste0(names(info_itis), "_itis")
out <- cbind(df, info_itis)
names(out)[1] <- "Common_Family"
write.csv(out[c(2:5, 1, 6:44)], "output/ontariofishes_raw.csv")
