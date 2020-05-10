library(tidyverse)
library(dplyr)
library(ggplot2)

get_phrase_counts <- function(tweets, phrases, neg_phrases = '') {
  check_for <- paste(phrases, collapse = '|')
  check_against <- paste(neg_phrases, collapse = '|')
  if (check_against == '') {
    phrases <- tweets %>%
      mutate(phrase = grepl(check_for, tolower(full_text))) 
  } else {
    phrases <- tweets %>%
      mutate(
        phrase = grepl(check_for, tolower(full_text))&
          !grepl(check_against, tolower(full_text))
      ) 
  }
  
  phrase_counts <- phrases %>%
    group_by(date) %>%
    summarize(
      n_phrase = sum(phrase),
      prop_phrase = n_phrase / length(phrase)
    ) %>%
    filter(date > as.Date('2020-01-01'))
  
  phrase_counts
}

get_data <- function(phrase, neg_phrase = '', standardized = TRUE) {
  if (!exists('tweets')) {
    tweets <- read.csv('tweets/sample_tweets.csv') %>%
      mutate(
        date = as.Date(date)
      )
  }
  if (!exists('twitter_counts')){
    twitter_counts <- read.csv('twitter_counts.csv') %>%
      select (-file) %>%
      mutate(
        date = as.Date(date)
      ) %>%
      group_by(date) %>%
      summarize(n_tweets = sum(n_tweets)) %>%
      mutate(
        cumulative_n_tweets = cumsum(n_tweets)
      )
  }
  if (!exists('covid_counts')) {
    covid_counts <- read.csv('covid.csv') %>%
      mutate(
        Date = as.Date(Date, format = '%m/%d/%y')
      )
    names(covid_counts) <- c('date','cases','deaths','us_deaths','n_countries')
  }

  data <- merge(twitter_counts, covid_counts, by = 'date', all.x = TRUE, all.y = TRUE)
  phrase_data <- get_phrase_counts(tweets, phrase, neg_phrase)
  data <- merge(data, phrase_data, by = 'date', all.x = TRUE, all.y = TRUE)
  
  if (standardized) {
    max_n_phrase <<- max(data['n_phrase'], na.rm = TRUE)
    total_cases_so_far <<- max(data['cases'], na.rm = TRUE)
    print("standardizing...")
    data <- cbind(
      data['date'], 
      data['n_phrase']/max(data['n_phrase'], na.rm = TRUE), 
      data['cases']/max(data['cases'], na.rm = TRUE)
    )
  }

  data_long <- to_long(data)
  data_long
}

to_long <- function(data) {
  data_long <- data %>% 
    pivot_longer(
      setdiff(names(data), c('date')), 
      names_to = 'var', values_to = 'count'
    )
}

plot_over_time <- function(phrase, neg_phrase = '', sig_dates = FALSE) {
  data <- get_data(phrase, neg_phrase) 
  
  drop = c('us_deaths','deaths','n_tweets','prop_phrase','n_countries')
  
  first_us_case <- as.Date('2020-01-21')
  first_us_death <- as.Date('2020-02-29')
  us_national_emergency <- as.Date('2020-03-13')
  first_us_shelter <- as.Date('2020-03-17')
  
  data <- data %>%
    filter(!(var %in% drop))
  
  p <- ggplot(data, aes(x = date, y = count, color = var, fill = var)) + 
    geom_line() +
    labs(
      title = paste('Phrase:', paste(phrase, collapse = ' or '))
    ) +
    scale_fill_discrete(
      name = '',
      labels = c(
        paste('Cases: as a proportion of total so far', total_cases_so_far),
        paste('COVID tweets containing phrase: as a proportion of max', max_n_phrase)
      )
    ) +
    scale_color_discrete(
      name = '',
      labels = c(
        paste('Cases: as a proportion of total so far', total_cases_so_far),
        paste('COVID tweets containing phrase: as a proportion of max', max_n_phrase)
      )
    ) + 
    theme(
      legend.position = 'top'
    )
  
  if (sig_dates) {
    p <- p + 
      geom_vline(xintercept = first_us_case, color = 'red') +
      geom_vline(xintercept = first_us_death, color = 'red') +
      geom_vline(xintercept = first_us_shelter, color = 'red')
  }
  
  p
}

plot_over_time(c('trump','president','donald'))

plot_over_time(c('joe','biden'))

plot_over_time(c('cdc'))

plot_over_time(c('shelter','home'))

plot_over_time(c('chinese virus'))

plot_over_time(c('democrat'))

plot_over_time(c('republican'))

