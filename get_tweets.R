library(tidyverse)
library(dplyr)
library(comprehenr)

tweet_ids <- readRDS('twitter_ids.RData')

# write all tweet ids to a text file
to_list(
  for(tweet in tweet_ids) 
  tweet$tweet_ids
) %>%
  unlist() %>%
  paste(collapse = '\n') %>%
  writeLines('tweets/tweets.txt')

# in terminal inside of tweets directory
# twarc hydrate tweets.txt > tweets.jsonl


######################################################
######### Using twitter API, doesn't work ############
######################################################
# library(httr)
# library(jsonlite)
# library(stringr)
# library(httpuv)
# library(rtweet)
# 
# tweet_ids <- readRDS('twitter_ids.RData')
# tweets_info <- fromJSON('tweets/tweets.json')
# 
# api_key <- "vw8SXoSFIxDgk6Tmkq1P876Mc"
# api_secret_key <- "UvVaXVC60JFvqD2kes8uXi3nYFzjkdmEOUwGq8KZIw7b8ic6pu"
# access_token <- "1117924930761318400-JORI1Qj7tKUqAuKfpqi2BFJikN8Iws"
# access_secret <- "C2QDQV9f1qnPakvzyzuMod0a3UtQL0ZYykTBmuRbHdxpb"
# 
# tweet_id = "1219755875407224832"
# req <- GET(
#   paste(
#   "https://api.twitter.com/1.1/statuses/show.json?id=",
#   "1219755875407224832", sep = ''
#   ),
#   add_headers(Authorization = paste("Key:", api_key))
# )
# 
# names(content(req))
# content(req)$errors