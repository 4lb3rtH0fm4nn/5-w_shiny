library(shiny)
library(tm)
library(party)
library(SnowballC)
library(wordcloud)
library(cluster)
library(plyr)
library(wordcloud2)
library(arules)
library(arulesViz)
library(gridExtra)
library(grid)
library(plotly)
library(igraph)
shinyUI(
  navbarPage("Five words analytics",
              
             tabPanel(
                "Wordcloud",
                      tags$head(tags$script('
                                                      var dimension = [0, 0];
                                                      $(document).on("shiny:connected", function(e) {
                                                      dimension[0] = window.innerWidth;
                                                      dimension[1] = window.innerHeight;
                                                      Shiny.onInputChange("dimension", dimension);
                                                      });
                                                      $(window).resize(function(e) {
                                                      dimension[0] = window.innerWidth;
                                                      dimension[1] = window.innerHeight;
                                                      Shiny.onInputChange("dimension", dimension);
                                                      });
                                                      ')),
                radioButtons("wc2type", "Wordcloud type",
                             choices = c("non-stemmed", "stemmed"),
                             selected = "non-stemmed"),
                numericInput('size', 'Size of wordcloud', 100),
               wordcloud2Output('wordcloud2')
             ),
             tabPanel("asd",
               sidebarPanel(sliderInput("priceInput", "Price", min = 0, max = 100,
                                        value = c(25, 40), pre = "$"),
                            radioButtons("typeInput", "Product type",
                                         choices = c("BEER", "REFRESHMENT", "SPIRITS", "WINE"),
                                         selected = "WINE"),
                            selectInput("countryInput", "Country",
                                        choices = c("CANADA", "FRANCE", "ITALY"))),
               mainPanel(verbatimTextOutput("height"),
                         br(),
                         br(),
                         tableOutput("results")
               )
                      
                      
                      ),
             tabPanel("Component 3",
                      plotlyOutput("plotrules2")
                      
                      
                      ),
             tabPanel("Component 4",
                      plotlyOutput("plotrules2_stemmed")
                      
                      
             )
  )
)