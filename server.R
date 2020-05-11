library(shiny)
library(gtrendsR)
library(tidyverse)
library(dplyr)
library(tidyr)
library(grid)

shinyServer(function(input, output) {
  
  search_terms <- eventReactive(input$plotbutton, {
    if (input$search_keyword != ""){
      c("coronavirus", input$search_keyword)
    } else {
      c("coronavirus")
    }
  })
  
  
  output$outPlot <- renderPlot({
    p_gt <- plot_gt(search_terms(), time = "2020-01-21 2020-05-01")
    p_t <- plot_twitter(search_terms())
    grid.newpage()
    grid.draw(rbind(ggplotGrob(p_gt), ggplotGrob(p_t), size = "last"))
  }, height = 500)
  
  twittertrends <- function(keywords) {
    if (!exists('tweets')) {
      tweets <<- read.csv('tweets/sample_tweets.csv') %>%
        mutate(
          date = as.Date(date)
        )
    }
    if (!exists('covid_counts')) {
      covid_counts <<- read.csv('covid.csv') %>%
        mutate(
          Date = as.Date(Date, format = '%m/%d/%y')
        )
    }
    names(covid_counts) <- c('date','cases','deaths','us_deaths','n_countries')
    
    for (keyword in keywords) {
      tweets[[keyword]] = grepl(tolower(keyword), tolower(tweets[['full_text']])) 
    }
    
    tweets <- tweets %>%
      select(keywords, 'date') %>%
      group_by(date) %>%
      summarize_all(mean) %>%
      filter(date > as.Date('2020-01-01')) %>%
      merge(covid_counts %>% select(date, cases), by = 'date')
    
    tweets
  }
  
  
  plot_twitter <- function(terms) {
    terms <- unique(trimws(terms))
    terms <- terms[terms != ""]
    
    twitter_results <- twittertrends(keywords = terms)
    twitter_results$cases <- twitter_results$cases/max(twitter_results$cases, na.rm = TRUE)
    twitter_results <- twitter_results %>% pivot_longer(
      cols = c(terms, 'cases'), names_to = 'keyword', values_to = 'hits'
    )
    
    ggplot(twitter_results, 
           aes(x = date, y = hits, color = keyword)
    ) +
      geom_line(size = 1.5) +
      labs(title = 'Trends in COVID Related Tweets', y = '', x = '') +
      xlim(c(as.Date('2020-01-21'), as.Date('2020-05-06'))) +
      scale_color_manual(values = c("#bf9cf9", "#00ffd8", "#4998d4")) +
      theme_dark() + theme(
        plot.background = element_rect(fill = "#303030"), 
        text = element_text(color = "white"),
        legend.background = element_rect(fill = "#303030"),
        axis.text = element_text(color = "#c2c2c2"),
        legend.title = element_blank(),
        panel.border = element_blank()
      )
  }
  
  plot_gt <- function(terms, time = "today 3-m", geo = "US") {
    terms <- unique(trimws(terms))
    terms <- terms[terms != ""]
    
    gt_results <- gtrends(keyword = terms, time = time, geo = geo)
    
    if (!exists('covid_counts')) {
      covid_counts <<- read.csv('covid.csv') %>%
        mutate(
          Date = as.Date(Date, format = '%m/%d/%y')
        )
    }
    names(covid_counts) <- c('date','cases','deaths','us_deaths','n_countries')
    
    google_data <- gt_results$interest_over_time
    google_data$hits[google_data$hits == "<1"] <- 0
    google_data$hits[is.na(google_data$hits)] <- 0
    google_data$hits <- as.numeric(google_data$hits)
    google_data$date <- as.Date(google_data$date)
    
    google_data <- google_data %>% 
      select(date, hits, keyword) %>%
      mutate(hits = hits/100) %>%
      pivot_wider(names_from = 'keyword', values_from = 'hits') %>%
      merge(covid_counts %>% select(date, cases), all.x = TRUE) %>%
      mutate(cases = cases/max(cases, na.rm=TRUE)) %>%
      pivot_longer(c(terms, 'cases'), names_to = 'keyword', values_to = 'hits')
    
    plot <- google_data %>%
      ggplot(aes(x = date, y = hits, color = keyword)) +
        geom_line(size = 1.5) +
        labs(title = 'Trends in Google Searches', y = '', x = '') +
        xlim(c(as.Date('2020-01-21'), as.Date('2020-05-06'))) +
        scale_color_manual(values = c("#bf9cf9", "#00ffd8", "#4998d4")) +
        theme_dark() + theme(
          plot.background = element_rect(fill = "#303030"), 
          text = element_text(color = "white"),
          legend.background = element_rect(fill = "#303030"),
          axis.text = element_text(color = "#c2c2c2"),
          legend.title = element_blank(),
          panel.border = element_blank()
        )
    
    plot
  }
})