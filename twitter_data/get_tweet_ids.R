library(httr)
library(jsonlite)
library(stringr)
library(dplyr)
library(tidyverse)
library(comprehenr)

count_tweet_ids <- function() {
  req <- GET("https://api.github.com/repos/echen102/COVID-19-TweetIDs/git/trees/master?recursive=1")
  
  filelist <- unlist(lapply(content(req)$tree, "[", "path"), use.names = F)
  filelist <- grep(".txt", filelist, value = TRUE, fixed = TRUE)
  
  if (file.exists("twitter_counts.csv")) {
    data <- read.csv("twitter_counts.csv")
    f <- nrow(data) + 1
    print(paste("Opened existing files,", f, "already counted"))
  } else {
    f = 1
    first = TRUE
  }
  start <- Sys.time()
  while (f < length(filelist)) {
    file <- filelist[f]
    date <- str_extract(file, '2020-[0-9]{2}-[0-9]{2}')
    file_url <- paste(
      "https://raw.githubusercontent.com/",
      "echen102/COVID-19-TweetIDs/master/", 
      file, sep = ''
    )
    
    dat <- GET(file_url)
    tweet_ids <- dat$content %>%
      rawToChar() %>%
      toJSON() %>%
      str_extract_all('[0-9]+') %>%
      unlist()
    
    n_tweets <- length(tweet_ids)
    if (first) {
      data <- data.frame(list(
        'file' = file,
        'date' = date,
        'n_tweets' = n_tweets
      ))
      first <- FALSE
    } else {
      data <- rbind(
        data,
        data.frame(list(
          'file' = file,
          'date' = date,
          'n_tweets' = n_tweets
        ))
      )
    }
    
    if (f%%10 == 0) {
      write.csv(data, 'twitter_counts.csv', row.names=FALSE)
      start <- Sys.time()
      now <- Sys.time()
      print(paste(f, now - start))
    }
    f <- f + 1
  }
}

get_sample_tweet_ids <- function(perc = 0.01) {
  req <- GET("https://api.github.com/repos/echen102/COVID-19-TweetIDs/git/trees/master?recursive=1")
  
  filelist <- unlist(lapply(content(req)$tree, "[", "path"), use.names = F)
  filelist <- grep(".txt", filelist, value = TRUE, fixed = TRUE)
  
  if (file.exists("twitter_ids.RData")) {
    
    data <- readRDS("twitter_ids.RData")
    f <- length(data[!is.na(data)]) + 1
    
  } else {
    
    data <- as.list(setNames(rep(NA, length(filelist)), filelist))
    f <- 1
    
  }
  
  start <- Sys.time()

  while (f <= length(filelist)) {
    file <- filelist[f]
    date <- str_extract(file, '2020-[0-9]{2}-[0-9]{2}')
    file_url <- paste(
      "https://raw.githubusercontent.com/",
      "echen102/COVID-19-TweetIDs/master/", 
      file, sep = ''
    )
    
    dat <- GET(file_url)
    
    tweet_ids <- dat$content %>%
      rawToChar() %>%
      toJSON() %>%
      str_extract_all('[0-9]+') %>%
      unlist()
    
    n_sample <- round(perc*length(tweet_ids))
    if (n_sample == 0) {n_sample <- 1}
    sample_tweet_ids <- sample(
      tweet_ids, 
      n_sample
    )
    
    data[[file]] <- list(
      "date" = date,
      "tweet_ids" = sample_tweet_ids
    )
    
    if (f%%10 == 0) {
      t = round(Sys.time() - start, 2)
      times <<- c(times, t)
      print(paste(f, t))
      start = Sys.time()
    }
    if (f%%100 == 0) {
      saveRDS(data, "twitter_ids.RData")
    }
    f <- f + 1
  }
  saveRDS(data, "twitter_ids.RData")
}

get_sample_tweet_ids()

# write all tweet ids to a text file
to_list(
  for(tweet in tweet_ids) 
    tweet$tweet_ids
) %>%
  unlist() %>%
  paste(collapse = '\n') %>%
  writeLines('tweets.txt')
