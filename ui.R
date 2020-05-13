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
             withLoader(plotOutput("outPlot"), type="html", loader="loader3")
           )),
  
  # About panel
  tabPanel(p("About", style ="padding-top:55px;font-size:25px"),
           sidebarLayout(
           sidebarPanel(img(src="grouppic.png", style="padding:10px", height = "100%", width = "100%", align = 'center')),
           mainPanel(
             h1("About the App"),
             h5("This app can be used to investigate how 
                                          social media trends and Google searches have been affected by COVID-19, specifically 
                                          in the context of the spread of COVID-19 in the U.S. We used the Google trends
                                          and Twitter APIs to look at these trends 
                                          from the introduction of COVID-19 to the U.S. on January 21, 2020 to the present. 
                                           "),
             h1("How to Use"),
             h5("Press the \"Plot!\" button to start plotting. To add terms to the graph, type it in 
                                           the \"Trend Search\" box and press the \"Plot!\" button.
                                            When no trend search is inputted,
                                           the graph will show the Google and Twitter trends for \"coronavirus\" along with
                                           the trend line for number of cases. The \"Show Important Dates\" checkbox graphs
                                            markers for dates that could give context to some of the trends."),
             h1("About the Data Buddies"),
             h5("We are a team of fourth year students at Cal Poly.
                                           Our team consists of statistics major Markelle Kelly, 
                                           software engineering major Luke Reckard, 
                                           statistics major Jenna Landy, 
                                           and statistics major Ashley Jacobson. ")
             ))),
  theme = shinytheme("darkly")
)
