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
             tabPanel(                "Introduction"),
             
             tabPanel(                "Wordcloud",
                                      
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

             tabPanel("non-stemmed rules plot",
                      sidebarPanel(width=3,
                        sliderInput("in", "Price", min = 0, max = 100,
                                               value = c(25, 40), pre = "$"),
                        radioButtons("rulesplottype", "Stemming",
                                    choices = c("non-stemmed", "stemmed"),
                                    selected = "non-stemmed"),
                        selectInput("rulesx", "X axis",
                                    choices = c("support", "confidence", "lift","order")),
                        selectInput("rulesy", "y axis",
                                    choices = c("support", "confidence", "lift","order"),selected = "confidence"),
                        selectInput("rulesshade", "shading",
                                    choices = c("support", "confidence", "lift","order"),selected = "lift")
                        ),
                      mainPanel(plotlyOutput("plotrules2")
                      )
                      
                      )
  )
)