library(shiny)
library(shinythemes)
library(tidyverse)
library(shinycustomloader)

navbarPage(list(img(src="databuddiesmedium.png"),
            tags$head(
              tags$style(HTML('.navbar-nav > li > a, .navbar-brand {
                            padding-top:0px !important; 
                            padding-bottom:0 !important;
                            height: 150px;
                            }
                           .navbar {min-height:150px !important;}')))),
  # Define UI for application that plots random distributions 
  
  tabPanel(p("Trends", style ="padding-top:50px;font-size:25px"),
           sidebarPanel(
             textInput("search_keyword", h3("Trend search"), 
                       value = ""),
             actionButton("plotbutton", "Plot!"),
             actionButton("addbutton", "Add search term"),
             tags$div(id='inputList')
           ),
           
           mainPanel(
             withLoader(plotOutput("exPlot"), type="image", loader="google.gif"),
             textOutput("test")
           )),
  
  tabPanel(p("About", style ="padding-top:50px;font-size:25px")),
  theme = shinytheme("darkly")
)
