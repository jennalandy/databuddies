library(shiny)
library(gtrendsR)

# Define server logic required to generate and plot a random distribution
shinyServer(function(input, output) {
  

  output$exPlot <- renderPlot({
    
    search_terms <- c("tiger king", "coronavirus")
    
    gt_results <- gtrends(keyword = search_terms, time = "today 3-m", geo = "US")
    
    gt_results$interest_over_time$hits[gt_results$interest_over_time$hits == "<1"] <- 0
    gt_results$interest_over_time$hits <- as.numeric(gt_results$interest_over_time$hits)
    
    gt_results %>%
      .$interest_over_time %>%
      ggplot(aes(x = date, y = hits, color = keyword)) +
      geom_line(size = 1.5) -> plot
    
    plot
  })
  
  
})