require(dplyr)
require(lubridate)
rainData<-read.csv('P:\\Shiny\\rainData.csv', header=TRUE) #load the rain data
b<-colnames(rainData[,-1])
rainData$Date<-mdy(rainData$Date)
head(rainData)


#rainDataStaions<-read.csv('P:\\Shiny\\rainDataStations.csv', header=TRUE) #load the rainfall stations data
