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
  
  show_events <- reactive({
    if (input$show_dates == TRUE){
      show_events <- 1
    } else {
      show_events <- 0
    }  
  })
  
  output$dates <- renderUI({
    if (input$show_dates) {
      HTML(paste("","01/21/2020 - First case in the U.S.", 
               "02/29/2020 - First death in the U.S.",
               "03/13/2020 - U.S. declares national emergency",
               "03/17/2020 - First U.S. shelter in place order", sep="<br/>"))
    } else {
      HTML(paste(""))
    }
    
  })
  
  first_us_case <- as.Date('2020-01-21')
  first_us_death <- as.Date('2020-02-29')
  us_national_emergency <- as.Date('2020-03-13')
  first_us_shelter <- as.Date('2020-03-17')
  
  output$outPlot <- renderPlot({
    p_gt <- plot_gt(search_terms(), time = "2020-01-21 2020-05-01")
    p_t <- plot_twitter(search_terms())
    grid.newpage()
    grid.draw(rbind(ggplotGrob(p_gt), ggplotGrob(p_t), size = "last"))
  }, height = 500)
  
  twittertrends <- function(keywords) {
    if (!exists('tweets')) {
      tweets <<- read.csv('sample_tweets.csv') %>%
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
      dplyr::select(keywords, 'date') %>%
      group_by(date) %>%
      summarize_all(mean) %>%
      filter(date > as.Date('2020-01-01')) %>%
      merge(covid_counts %>% dplyr::select(date, cases), by = 'date')
    
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
    
    print(twitter_results)
    
    ggplot(twitter_results, 
           aes(x = date, y = hits, color = keyword)
    ) +
      geom_line(size = 1.5) +
      labs(title = 'Trends in COVID Related Tweets', y = '', x = '') +
      xlim(c(as.Date('2020-01-21'), as.Date('2020-05-06'))) +
      geom_vline(xintercept = first_us_case, color = '#d9d9d9', alpha=show_events()) +
      geom_vline(xintercept = first_us_death, color = '#d9d9d9', alpha=show_events()) +
      geom_vline(xintercept = us_national_emergency, color = '#d9d9d9', alpha=show_events()) +
      geom_vline(xintercept = first_us_shelter, color = '#d9d9d9',alpha=show_events()) +
      scale_color_manual(values = c("#4998d4", "#00ffd8", "#bf9cf9")) +
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
      dplyr::select(date, hits, keyword) %>%
      mutate(hits = hits/100) %>%
      pivot_wider(names_from = 'keyword', values_from = 'hits') %>%
      merge(covid_counts %>% dplyr::select(date, cases), all.x = TRUE) %>%
      mutate(cases = cases/max(cases, na.rm=TRUE)) %>%
      pivot_longer(c(terms, 'cases'), names_to = 'keyword', values_to = 'hits')
    
    plot <- google_data %>%
      ggplot(aes(x = date, y = hits, color = keyword)) +
        geom_line(size = 1.5) +
        labs(title = 'Trends in Google Searches', y = '', x = '') +
        xlim(c(as.Date('2020-01-21'), as.Date('2020-05-06'))) +
        geom_vline(xintercept = first_us_case, color = '#d9d9d9', alpha=show_events()) +
        geom_vline(xintercept = first_us_death, color = '#d9d9d9', alpha=show_events()) +
        geom_vline(xintercept = us_national_emergency, color = '#d9d9d9', alpha=show_events()) +
        geom_vline(xintercept = first_us_shelter, color = '#d9d9d9',alpha=show_events()) +
        scale_color_manual(values = c("#4998d4", "#00ffd8", "#bf9cf9")) +
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