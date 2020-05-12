library(shiny)
library(shinythemes)
library(tidyverse)
library(shinycustomloader)

# Navbar header with image
navbarPage(list(img(src="databuddiesmedium.png"),
            tags$head(
              tags$style(HTML('.navbar-nav > li > a, .navbar-brand {
                            padding-top:0px !important; 
                            padding-bottom:0 !important;
                            height: 150px;
                            }
                           .navbar {min-height:150px !important;}')))),
  
  # Trends panel
  tabPanel(p("Trends", style ="padding-top:55px;font-size:25px"),
           
           sidebarPanel(
             textInput("search_keyword", h3("Trend search"), 
                       value = ""),
             checkboxInput('show_dates', "Show Important Dates", value = FALSE, width='100%'),
             actionButton("plotbutton", "Plot!"),
             #actionButton("addbutton", "Add search term"),
             tags$div(id='inputList'),
             htmlOutput('dates')
           ),
           
           mainPanel(
             # Loads panel with gif
             withLoader(plotOutput("outPlot"), type="html", loader="loader3"),
             textOutput("test")
           )),
  
  # About panel
  tabPanel(p("About", style ="padding-top:55px;font-size:25px"),
           mainPanel(
             img(src="grouppic.png", style="padding:50px"))),
  theme = shinytheme("darkly")
)
