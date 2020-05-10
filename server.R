library(shiny)
library(gtrendsR)
library(tidyverse)

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
  
  
  
  output$exPlot <- renderPlot({
    plot_gt(search_terms$dList)
  })
  
  plot_gt <- function(terms, time = "today 3-m", geo = "US") {
    terms <- unique(trimws(terms))
    terms <- terms[terms != ""]
    
    gt_results <- gtrends(keyword = terms, time = time, geo = geo)
    
    gt_results$interest_over_time$hits[gt_results$interest_over_time$hits == "<1"] <- 0
    gt_results$interest_over_time$hits <- as.numeric(gt_results$interest_over_time$hits)
    
    gt_results %>%
      .$interest_over_time %>%
      ggplot(aes(x = date, y = hits, color = keyword)) +
      geom_line(size = 1.5) -> plot
    
    plot
  }
  
  
})