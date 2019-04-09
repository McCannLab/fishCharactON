library(tidyverse)

ls_data <- list()
for (i in 1:159) {
  print(i)
  tmp <- readLines(paste0("http://www.ontariofishes.ca/fish_detail.php?FID=", i))
  ls_data[[i]] <- cbind(
    tmp[grepl("DataLabel", tmp)] %>% gsub(".*LEFT>", "", .) %>%
      gsub("</TD.*", "", .) %>% `[`(1:38),
    tmp[grepl("DataText", tmp)] %>% gsub(".*RIGHT>", "", .) %>%
      gsub(".*LEFT>", "", .) %>% gsub("<[/]?I>", "", .) %>%
      gsub("<[/]?SUP>", "", .) %>% gsub("</TD.*", "", .) %>% `[`(1:38)
    )
}

df <- ls_data %>% lapply(function(x) x[,2]) %>% do.call(rbind, .) %>%
  as.data.frame

names(df) <- ls_data[[1]][,1]

write.csv(df, "output/ontariofishes.csv")
