library(shiny)

shinyUI(pageWithSidebar(
  
  headerPanel("Data Buddies Fuck Shit Up"),
  
  sidebarPanel(
    textInput("search_keyword", h3("Trend search"), 
              value = ""),
    actionButton("plotbutton", "Plot!"),
    actionButton("addbutton", "Add search term"),
    tags$div(id='inputList')
  ),
  
  mainPanel(
    plotOutput("gPlot"),
    plotOutput("tPlot"),
    textOutput("test")
  )
))