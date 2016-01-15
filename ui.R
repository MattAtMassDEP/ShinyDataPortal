shinyUI(navbarPage("Data Portal",


tabsetPanel(
    tabPanel("Lab Data",
      fluidPage(
          fluidRow(
            HTML('
                    <script type="text/javascript">
                        $(document).ready(function() {
                            $("#downloadData").click(function() {
                                var filtered_table_data = $("#table").find("table").dataTable()._("tr", {"filter":"applied"});

                                Shiny.onInputChange("filtered_table", filtered_table_data);
                            });
                        });
                   </script>
                '),
           column(3, 
                  uiOutput("choose_Watershed")
           ),
           
           column(3, offset=0.5, 
                  uiOutput("choose_Project")
           ),
           
           column(3, offset=0.5,
                  downloadButton('downloadData', 'Download Filtered Data')
           )
         ),#close the first fluid row
         
         hr(),
         
         # Create a new row for the lab data table.
         fluidRow(
           dataTableOutput(outputId="table")
         )
       )    # close the fluidpage  
    ), #close the first tab panel     
    
    #file location:\\env.govt.state.ma.us\enterprise\DEP-Worcester-N-BRP-DWM\2016 Assessments\WPP Statewide Data\DO_Deploy_Data_Processed_2005_2010.xlsm
    tabPanel("DO Probe Data",
             h3("Link to", a("DO Tools", href="file:///\\env.govt.state.ma.us\\enterprise\\DEP-Worcester-N-BRP-DWM\\2016 Assessments\\WPP Statewide Data\\DO_Deploy_Data_Processed_2005_2010.xlsm")),
            br(),
            p("Note the link above doesn't work as the browser is protecting you from accessing local files.  Thanks browser! Copy and paste the link
              below into a new tab and in Internet Explorer it should ask if you want to open.  Yes open it."),
            tags$b(textOutput("DO_Probe_File_Location"))),
    
    tabPanel("Rain Data", 
             br(),
             fluidRow(
               column(3, uiOutput("choose_RainStation"),
                      
             
             
             dateRangeInput("dates", label = h3("Date range"),
                            start  = "2005-06-01",
                            end    = "2005-10-30",)),
    
             column(6, img(src="WeatherStations.jpg", height = 542, width = 855)
                    )
             ),
             hr(),
             fluidRow(column(4, dataTableOutput(outputId="WeatherStationData")),
             (column(5,align="center", plotOutput("RainPlot"))))         
             
    ),
    
    tabPanel("Benthic Taxa Lists",
             br(),
             h4("Benthic Taxa"),
             br(),
             fluidRow(
               column(3, 
                      uiOutput("Invert_Project")
             )),
             fluidRow(column(4, tableOutput(outputId="InvertTaxaData")))
             
             ),
    
    tabPanel("DCA Inverts",
             br(),
             h4("Detrended Correspondence Analysis"),
             br(),
            
             fluidRow(#column(4, textOutput(outputId="InvertBraun")),
                    (column(12, plotOutput(outputId="DCA_plot"))
                      ))
             
            ),
    
    
    tabPanel("Invert Station & Habitat",
             br(),
             h4("Station Table"),
             br(),
             
             fluidRow(column(12, tableOutput(outputId="InvertStationTable"))
             ),
    
             h4("Habitat Table"),
             br(),
             fluidRow(column(12, tableOutput(outputId="InvertHabitatTable"))
               ))
             
    )  #close the tabset
    
   

)  #close navBar
)#close shiny UI
