source("database.R") 
source("getRainData.R")
source("getInvertData.R")
require(dplyr)
require(ggplot2)
require(vegan)


shinyServer(function(input, output) {
  
  output$choose_Watershed <- renderUI({
    selectInput("shed", "Watersheds", levels(df$Watershed),
    selected='Bash Bish', multiple=FALSE)
  }) 
  
  output$choose_Project <- renderUI({
    # If missing input, return to avoid error later in function 
    if(is.null(input$shed))
      return() 
    
    # Get the unique projects for a certain watershed
    #if(is.null(uniqueProj))
     # return()
    
    uniqueProj<-droplevels(unique(subset(df, df$Watershed == input$shed, select=Projname)))
    d<-as.character(uniqueProj$Projname)
  
    # Create the select box
    selectInput("projectPicked", "Choose a Project", choices = d)
  }) 
  
  Dataset <- reactive({
    
    # If the dataframe used to create the DataTable
    # happens to contain NA values, they need to
    # be replaced with an empty string. This ensures
    # that the array returned from the datatables
    # underscore method (i.e. the data contained in 
    # input$filtered_table) contains an entry in every
    # cell. Otherwise the ProcessedFilteredData routine 
    # will result in corrupted data
  data <- df
  if (input$projectPicked != ""){
    colDesired=c(5,6,7,8,9,10,11,17,18,21,22,29,30,31,32)
    data <- data[data$Projname == input$projectPicked,colDesired]
    data[is.na(data)] <- ""
    return(data)
    }  
  })
    
  output$table <- renderDataTable({
    if (is.null(input$projectPicked))
      return()
    
#     data <- df
#     if (input$projectPicked != ""){
#       colDesired=c(5,6,7,8,9,10,11,17,18,21,22,29,30,31,32)
#       data <- data[data$Projname == input$projectPicked,colDesired]
#     }

    Dataset()
  }, options = list(sDom = "ilftr", bPaginate = FALSE))
  
  
  

ProcessedFilteredData <- reactive({
  v <- unlist(input$filtered_table)
  # This code assumes that there is an entry for every
  # cell in the table (see note above about replacing
  # NA values with the empty string).
  col_names <- unlist(names(Dataset()))
  n_cols <- length(col_names)
  n_row <- length(v)/n_cols
  m <- matrix(v, ncol = n_cols, byrow = TRUE)
  df <- data.frame(m)
  names(df) <- col_names
  return(df)
})
  
output$downloadData <- downloadHandler(
  filename = function() { 'filtered_data.csv' }, content = function(file) {
    write.csv(ProcessedFilteredData(), file, row.names = FALSE)
  }
    )
    
  
  output$TestText <- renderText({
      "testing 1, 2,3"
  })
  
  output$value2 <- renderPrint({ input$dates })
  
  output$choose_RainStation <- renderUI({
    selectInput("weatherStation", "Choose a Weather Stations", choices=b,
                selected='ASHBURNHAM.NORTH.MA.Us', multiple=FALSE)
  }) 
  
   choosenWeather<- reactive({          #previously I used renderDataTable({
    if(is.null(input$weatherStation))
      return() 
    
    if (is.null(input$dates))
      return()
    
    myData<-rainData
    desCol<-input$weatherStation
    
    c<-match(desCol,names(rainData))
    
    anotherFrame<-select(myData,Date, c)
     
   
    #subsetWeather<-susbsetWeather[Date >= format(input$Date[1]) & Date <= format(input$Date[2]), ]
    #subsetWeather<-filter(subsetWeather, Date >= input$Date[1] & Date <= input$Date[2])
    tempWeatherOut<-anotherFrame[anotherFrame$Date >= format(input$dates[1]) & anotherFrame$Date <= format(input$dates[2]), ]
    
    #if (exists( susbsetWeather))
     #   subsetWeather<-filter(subsetWeather, Date >= format(input$Date[1]) && Date <= format(input$Date[2]))
    
    tempWeatherOut 
    
  })
  
  output$WeatherStationData <- renderDataTable({
    choosenWeather()
  })
  
  
  output$RainPlot <- renderPlot({
      
    
    rainyData<-choosenWeather()
    if (is.null(rainyData))
      return()
    
      #p <-ggplot(choosenWeather(), aes(Date,) + geom_line() ) #labs(x = "Date", y = "Rain-inches"))
      #View(rainyData)
      m<-names(rainyData)
      names(rainyData)[2] <- "Value"
      
      ggplot(rainyData, aes(Date, Value)) + geom_point() + labs(x = "Date", y = "Rainfall (inches)")   
  })
  
  output$DO_Probe_File_Location <- renderText({
    "file:///\\env.govt.state.ma.us\\enterprise\\DEP-Worcester-N-BRP-DWM\\2016 Assessments\\WPP Statewide Data\\DO_Deploy_Data_Processed_2005_2010.xlsm"
  })
  
  output$Invert_Project <- renderUI({
    # If missing input, return to avoid error later in function 
    if(is.null(projects))
      return() 
    
    
    # Create the select box
    selectInput("InvertProject", "Choose a Project", choices = projects)
  }) 
   
  
  getInvertProject<- reactive({          #previously I used renderDataTable({
    if(is.null(input$InvertProject))
      return() 
    
      x <-input$InvertProject
    SQL<-paste("TRANSFORM Sum(Benthic.Individuals) AS SumOfIndividuals SELECT [MA-MasterTaxa].Family,[MA-MasterTaxa].FinalId, [MA-MasterTaxa].FFG, [MA-MasterTaxa].TolVal FROM [MA-MasterTaxa] INNER JOIN ((BenSamp LEFT JOIN [qryTotal Individuals] ON BenSamp.BenSampID = [qryTotal Individuals].BenSampID) INNER JOIN Benthic ON BenSamp.BenSampID = Benthic.BenSampID) ON [MA-MasterTaxa].MATSN = Benthic.MATSN WHERE (((BenSamp.ProjectCode)='",x, "')) OR (((BenSamp.RefPC)='",x,"')) GROUP BY [MA-MasterTaxa].TAXCODE, [MA-MasterTaxa].Phylum, [MA-MasterTaxa].Class, [MA-MasterTaxa].Order, [MA-MasterTaxa].Family, [MA-MasterTaxa].Subfamily, [MA-MasterTaxa].Tribe, [MA-MasterTaxa].Genus, [MA-MasterTaxa].Species, [MA-MasterTaxa].FinalId, [MA-MasterTaxa].FFG, [MA-MasterTaxa].TolVal ORDER BY [MA-MasterTaxa].TAXCODE, [MA-MasterTaxa].Phylum, [MA-MasterTaxa].Class, [MA-MasterTaxa].Order, [MA-MasterTaxa].Family, [MA-MasterTaxa].Subfamily, [MA-MasterTaxa].Tribe, [MA-MasterTaxa].Genus, [MA-MasterTaxa].Species PIVOT [BenSamp.BenSampID] & ' (' & [BenSamp.FieldID] & ')';", sep="")
      df.sql<-sqlQuery(ch2,SQL)
      df.sql
  })
  
  output$InvertTaxaData <- renderTable({
    getInvertProject()
  })
  
  #Braun Blanquet calculation
  BraunBlumquist<-reactive({
        if(is.null(input$InvertProject))
          return() 
        
        localDf<-getInvertProject()
        localDf<-matrixInverts(localDf)   #transpose data frame, put in format for DCA
        
        dca<-decorana(localDf)   # run detrended correspondence analysis, downweight rare speices
        y<-vegemite(localDf, dca, "Braun.Blanquet", zero="-")
        tb <- t(localDf[y$sites, y$species])
        tb
  })
  
  #Plot Detrended Correspondence Analysis
  plotDCA<-reactive({
    if(is.null(input$InvertProject))
      return() 
    
    localDf<-getInvertProject()
    localDf<-matrixInverts(localDf)   #transpose data frame, put in format for DCA
    
    dca<-decorana(localDf)   # run detrended correspondence analysis, downweight rare speices
    par(mar=c(2,2,1,1)+0.1)
    plot(dca, display="sites")
  })
  
  output$InvertBraun<- renderPrint({
     BraunBlumquist()
  })
  
  output$DCA_plot<- renderPlot({
    plotDCA()
  })
  
  #get benthic habitat table for a invertebrate sampling project
  getHabTable<-reactive({
    if(is.null(input$InvertProject))
      return() 
    
    x<-input$InvertProject
    
    SQL2<-paste("TRANSFORM Sum(Habitat.HabValue) AS SumOfHabValue SELECT HabParDesc.Description FROM HabSamp INNER JOIN (HabParDesc INNER JOIN Habitat ON HabParDesc.HabParameter = Habitat.HabParameter) ON HabSamp.HabSampID = Habitat.HabSampID
    WHERE (((HabSamp.ProjectCode)='", x,"'",")) OR (((HabSamp.RefPC)='",x,"')) ", "GROUP BY HabParDesc.Description, HabParDesc.Order ORDER BY HabParDesc.Order PIVOT HabSamp.FieldID;",  sep="")
    
    Habitat.qry<-sqlQuery(ch2,SQL2)
    Habitat.qry 
  })
  
  output$InvertHabitatTable <- renderTable({
    getHabTable()
  })
  
  # get Station Information for Invertebrate Sampling Stations
  getInvertStationTable<-reactive({
    if(is.null(input$InvertProject))
      return() 
    
    x<-input$InvertProject
    
    SQL_StationList<-paste("SELECT BenSamp.FieldID, BenSamp.UNIQUE_ID, GlobalWatershedMA.DRNAREA, Left(StrConv([WBNAME],3),Len([WBNAME])-1) AS Waterbody, qryStaidSarisPalis.DESCRIPTOR, BenSamp.CollDate, GlobalWatershedMA.BSLDEM250, GlobalWatershedMA.M7D10Y, GlobalWatershedMA.AUGD50, GlobalWatershedMA.URBNLCD01, GlobalWatershedMA.IMPNLCD01, BenSamp.ProjectCode, GlobalWatershedMA.PROBPEREN, GlobalWatershedMA.WARNINGMSG FROM GlobalWatershedMA INNER JOIN (qryStaidSarisPalis INNER JOIN BenSamp ON qryStaidSarisPalis.UNIQUE_ID = BenSamp.UNIQUE_ID) ON GlobalWatershedMA.Name = BenSamp.UNIQUE_ID
    GROUP BY BenSamp.FieldID, BenSamp.UNIQUE_ID, BenSamp.BenSampID, GlobalWatershedMA.DRNAREA, Left(StrConv([WBNAME],3),Len([WBNAME])-1), qryStaidSarisPalis.DESCRIPTOR, BenSamp.CollDate, GlobalWatershedMA.BSLDEM250, GlobalWatershedMA.M7D10Y, GlobalWatershedMA.AUGD50, GlobalWatershedMA.URBNLCD01, GlobalWatershedMA.IMPNLCD01, BenSamp.ProjectCode, GlobalWatershedMA.PROBPEREN, GlobalWatershedMA.WARNINGMSG, BenSamp.BenSampID HAVING (((BenSamp.ProjectCode)='", x, "')) ORDER BY BenSamp.BenSampID;", sep="")
    
    
    InvertStationTable.qry<-sqlQuery(ch2,SQL_StationList)
    InvertStationTable.qry<-unique(InvertStationTable.qry)  #get the stations with no repeats
    #rename the columns
    colnames(InvertStationTable.qry)[c(3,7:11,13)]<-c("DrainageArea (square miles)","Mean Basin Slope (percent)","7 Day_10_Year LowFlow (cfs)","August 50 Percent_Duration (cfs)","Urban Land Cover (NLCD_2001) (percent)","Percent Impervious (percent)","Probability Perennial") 
    InvertStationTable.qry$CollDate<-as.character(InvertStationTable.qry$CollDate)          #convert Date to character so it shows up better
    InvertStationTable.qry
  })
  
  output$InvertStationTable <- renderTable({
    getInvertStationTable()
#     options = list(
#                   pageLength = 50,
#                   initComplete = I("function(settings, json){
#                                           new $.fn.dataTable.FixedHeader(this, {
#                                             left:   true,
#                                             right:  true
#                                           } );
#                                         }")
#                     )
  })
  
  
})

