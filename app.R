#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(xlsx)
library(readxl)
library(plotly)
library(sf)
library(dplyr)
library(tidygeocoder)
library(leaflet)
library(rgdal)
library(readxl)
library(sp)
library(ggplot2)



Ext_Transit_Trips <- read_excel("C:/Users/JacobFo/OneDrive - City of Durham/MTP Work/Ext_Transit_Trips.xlsx")

trm_node <- readOGR(dsn="C:/Users/JacobFo/OneDrive - City of Durham/MTP Work", 
                    layer="TRMv6_Node",GDAL1_integer64_policy=FALSE, verbose=FALSE )

trm_line <- readOGR(dsn="C:/Users/JacobFo/OneDrive - City of Durham/MTP Work", 
                    layer="TRMv6_Line",GDAL1_integer64_policy=FALSE, verbose=FALSE)

Internal_Nodes <- read_excel("Internal_Nodes.xlsx", 
                             sheet = "total")
Internal_Nodes_coord <- read_excel("Internal_Nodes_coord.xlsx")

list <- c(2861, 2876,2881,2897,2916,2923,2933,2935,2937,2944,2946,2951,2952)

trm_node <-subset(trm_node, ID %in% list)




# Define UI for application that draws a histogram
ui <- fluidPage(leafletOutput("map", width="75%", height="500px"),

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins 
 
     inputPanel (selectInput("id", "External Station: ",
                                    c("2935"="2935",
                                      "2951"="2951",
                                      "2952"="2952")))
            ,

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("map")
        
    
))

# Define server logic required to draw a histogram
server <- function(input, output) {

    
    i_nodes <- reactive ({
            i_nodes <- Internal_Nodes_coord %>%
                filter(ID1==input$id)
        })
 
        output$map <- renderLeaflet( {
            
            
            leaflet() %>%
                addPolylines(data=trm_line, color="black", weight = 1, fill=FALSE,
                             popup = trm_line$ROADNAME) %>%
                addProviderTiles(providers$CartoDB.Positron)%>%
                addCircleMarkers(data=i_nodes(),  
                                 lng=i_nodes()$coords.x1,
                                 lat=i_nodes()$coords.x2,
                                 radius=i_nodes()$trips_2016,
                                 popup=paste("External Station ", i_nodes()$ID1, "<br>", "External Transit Trips: ", i_nodes()$trips_2016))
        })
        
       

}

# Run the application 
shinyApp(ui = ui, server = server)










