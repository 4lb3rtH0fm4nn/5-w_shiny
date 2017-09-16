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
#global url-s
urldata="/home/webadmin/R/dtm-test/data/"
urlout="/home/webadmin/R/dtm-test/data/"
#data processing
eventdata<-read.csv(paste0(urldata,"data.csv"), header=T,sep=",")
eventwords<-eventdata[,5:9]
userwordsvector<-paste(eventwords[,1],eventwords[,2],eventwords[,3],eventwords[,4],eventwords[,5])
wmatrix<-as.matrix(userwordsvector)
rownames(wmatrix)<-c(eventdata[,1])
wordscorpus<-Corpus(VectorSource(wmatrix))
wordscorpus<- tm_map(wordscorpus, content_transformer(tolower))
wordscorpus<- tm_map(wordscorpus, removePunctuation)
wordscorpus <- tm_map(wordscorpus, stripWhitespace)
stemmed<-tm_map(wordscorpus, stemDocument)
dtm<-DocumentTermMatrix(wordscorpus)
dtm_m<-as.matrix(dtm)
tdm<-TermDocumentMatrix(wordscorpus)
tdm_m<-as.matrix(tdm)
colnames(tdm) <- c(eventdata[,1])
rownames(dtm)<- c(eventdata[,1])
dtm_stemmed<-DocumentTermMatrix(stemmed)
dtm_stemmed<-as.matrix(dtm_stemmed)
tdm_stemmed<-TermDocumentMatrix(stemmed)
tdm_stemmed<-as.matrix(tdm_stemmed)


#data for wc2
sumv<-as.matrix(sort(rowSums(tdm_m),decreasing=TRUE))
sumv2 <- data.frame(term=rownames(as.matrix(sumv)),frequency=rowSums(as.matrix(sumv))) 
row.names(sumv2)<-NULL

#date for wc2 stemmed
sumv_stemmed<-as.matrix(sort(rowSums(tdm_stemmed),decreasing=TRUE))
sumv2_stemmed <- data.frame(term=rownames(as.matrix(sumv_stemmed)),frequency=rowSums(as.matrix(sumv_stemmed))) 
row.names(sumv2_stemmed )<-NULL

#arules
wordtransactions<-as(dtm_m,"transactions")
capture.output( rules <- apriori(wordtransactions, parameter = list(supp = 1/(dim(eventdata)[1]-1), conf = 0.08, minlen=2)), file='NUL')
options(digits=3)
rules.sorted<-sort(rules, by="confidence", decreasing=TRUE)
subset.matrix <- is.subset(rules.sorted, rules.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- 0
redundant <- colSums(subset.matrix, na.rm=T) >= 1
rules.pruned <- rules[redundant]
rules<-rules.pruned
rules<-sort(rules, by="confidence", decreasing=TRUE)
rulestoviz<-as(rules,"data.frame")


#arules stemmed
wordtransactions<-as(dtm_stemmed,"transactions")
capture.output( rules_stemmed <- apriori(wordtransactions, parameter = list(supp = 1/(dim(eventdata)[1]-1), conf = 1/(dim(eventdata)[1]-1),minlen=2)), file='NUL')
options(digits=3)
rules.sorted_stemmed<-sort(rules_stemmed, by="confidence", decreasing=TRUE)
subset.matrix_stemmed <- is.subset(rules.sorted_stemmed, rules.sorted_stemmed)
subset.matrix_stemmed[lower.tri(subset.matrix_stemmed, diag=T)] <- 0
redundant_stemmed <- colSums(subset.matrix_stemmed, na.rm=T) >= 1
rules_stemmed.pruned <- rules_stemmed[!redundant_stemmed]
rules_stemmed<-rules_stemmed.pruned
rules_stemmed<-sort(rules_stemmed, by="confidence", decreasing=TRUE)
rulestoviz_stemmed<-as(rules_stemmed,"data.frame")


shinyServer(function(input, output) {
  output$width <-renderText({paste0(toString(input$dimension[1]),"px")})
  
  output$height <-renderText({paste0(toString(input$dimension[2]),"px")})
  output$wordcloud2 <- renderWordcloud2({
    p <- switch(input$wc2type,
                "non-stemmed" = sumv2,
                "stemmed" = sumv2_stemmed
    )
    # wordcloud2(sumv2, size=1)
    wordcloud2(p, size=input$size/100)
  })
  

  #output$plotrules<-renderPlot({plot.igraph(graph)})
  output$plotrules2 <- renderPlotly({
    plotly_arules(rules,method="scatterplot", measure = c("confidence", "lift"),shading = "support", max = 1000)
  })
  output$plotrules2_stemmed <- renderPlotly({
    plotly_arules(rules_stemmed,method="scatterplot", measure = c("confidence", "lift"),shading = "support", max = 1000)
  })

})
