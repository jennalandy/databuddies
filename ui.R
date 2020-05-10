library(shiny)
library(shinythemes)
library(tidyverse)

fluidPage(
  theme = shinytheme("darkly"),
  # Define UI for application that plots random distributions 
  pageWithSidebar(
    
    # Application title
    headerPanel("Data Buddies Fuck Shit Up"),
    
    # Sidebar with a slider input for number of observations
    sidebarPanel(
      textInput("search_keyword", h3("Trend search"), 
                value = ""),
      actionButton("button", "Search")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("exPlot")
    )
  )
)
