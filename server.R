library(shiny)
library(gtrendsR)

# Define server logic required to generate and plot a random distribution
shinyServer(function(input, output) {
  
  
  search_terms <- eventReactive(input$button, {
    if (input$search_keyword != ""){
      c("coronavirus", input$search_keyword)
    } else {
      c("coronavirus")
    }
  }, ignoreNULL = F)
  
  output$exPlot <- renderPlot({
    plot_gt(search_terms())
  })
  
  plot_gt <- function(terms, time = "today 3-m", geo = "US") {
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