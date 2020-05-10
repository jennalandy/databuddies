library(shiny)
library(gtrendsR)
library(tidyverse)
library(dplyr)
library(patchwork)

shinyServer(function(input, output) {
  
  
  observeEvent(input$addbutton, {
    nr <- input$addbutton
    id <- paste0("input",input$addbutton)
    insertUI(
      selector = '#inputList',
      ui=div(
        id = paste0("newInput",nr),
        textInput(
          inputId = id,
          label = "Input"
        ),
        actionButton(paste0('removeBtn',nr), 'Remove')
      )
    )
    observeEvent(input[[paste0('removeBtn',nr)]],{
      shiny::removeUI(
        selector = paste0("#newInput",nr)
      )
    })
    
  })
  
  search_terms <- reactiveValues()
  observe({
    if (input$plotbutton == 0) {
      search_terms$dList <- c("coronavirus")
    }
    if(input$plotbutton > 0){
      search_terms$dList <- unique(c(isolate(search_terms$dList), isolate(input$search_keyword)))
    }
  })
  
  
  
  output$outPlot <- renderPlot({
    p_gt <- plot_gt(search_terms$dList)
    p_t <- plot_twitter(search_terms$dList)
    p_gt/p_t
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
      labs(title = 'Trends in COVID Related Tweets') +
      xlim(c(as.Date('2020-01-21'), as.Date('2020-05-06')))
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
        labs(title = 'Trends in Google Searches') +
        xlim(c(as.Date('2020-01-21'), as.Date('2020-05-06')))
    
    plot
  }
})