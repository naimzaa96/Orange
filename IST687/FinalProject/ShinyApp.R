# Shiny app to alleviate repetition of map creation

# for UI, allow for dropdown menu that subsets relevant column vectors

ui <- fluidRow(
    selectInput("variable1", "Choose a subset :",
                list("Gender" = list("male", "female"))),
    plotOutput("plot1"),
    selectInput("variable2", "Choose a subset :",
                list("Type.of.Travel" = list("business travel","mileage tickets" ,"personal travel"))),
    plotOutput("plot2"),
    selectInput("variable3", "Choose a subset :",
                list("Class" = list("eco", "eco plus", "business"))),
    plotOutput("plot3"),
    selectInput("variable4", "Choose a subset :",
                list("Airline.Status" = list("blue", "silver", "gold","platinum"))),
    plotOutput("plot4"),
)

#create the interactive ggmaps

server <- function(input, output) {
    dfAirline <- airClean()
    
    us <- map_data("state")
    
    output$plot1 <- renderPlot(
        ggplot(us) +
            geom_map(data = us, map = us, aes(map_id = region, group = group), fill = 'lightgray', colour = 'black') +
            geom_map(data = subset(dfAirline, Gender == input$variable1), map = us, aes(map_id = Origin.State,fill= Likelihood.to.recommend)) +
            scale_fill_gradientn(na.value = 'black', colours = c('orange','yellow','green')) +
            expand_limits(x = us$long, y = us$lat) +
            guides(fill=guide_legend(title='Likelihood.to.recommend')) +
            coord_map(projection = 'mercator') +
            ggtitle("Gender Heat Map"))
    
    output$plot2 <- renderPlot(
        ggplot(us) +
            geom_map(data = us, map = us, aes(map_id = region, group = group), fill = 'lightgray', colour = 'black') +
            geom_map(data = subset(dfAirline, Type.of.Travel == input$variable2), map = us, aes(map_id = Origin.State,fill= Likelihood.to.recommend)) +
            scale_fill_gradientn(na.value = 'black', colours = c('orange','yellow','green')) +
            expand_limits(x = us$long, y = us$lat) +
            guides(fill=guide_legend(title='Likelihood.to.recommend')) +
            coord_map(projection = 'mercator') +
            ggtitle("Type of Travel Heat Map"))
    
    output$plot3 <- renderPlot(
        ggplot(us) +
            geom_map(data = us, map = us, aes(map_id = region, group = group), fill = 'lightgray', colour = 'black') +
            geom_map(data = subset(dfAirline, Class == input$variable3), map = us, aes(map_id = Origin.State,fill= Likelihood.to.recommend)) +
            scale_fill_gradientn(na.value = 'black', colours = c('orange','yellow','green')) +
            expand_limits(x = us$long, y = us$lat) +
            guides(fill=guide_legend(title='Likelihood.to.recommend')) +
            coord_map(projection = 'mercator') +
            ggtitle("Class Heat Map"))
    output$plot4 <- renderPlot(
        ggplot(us) +
            geom_map(data = us, map = us, aes(map_id = region, group = group), fill = 'lightgray', colour = 'black') +
            geom_map(data = subset(dfAirline, Airline.Status == input$variable4), map = us, aes(map_id = Origin.State,fill= Likelihood.to.recommend)) +
            scale_fill_gradientn(na.value = 'black', colours = c('orange','yellow','green')) +
            expand_limits(x = us$long, y = us$lat) +
            guides(fill=guide_legend(title='Likelihood.to.recommend')) +
            coord_map(projection = 'mercator') +
            ggtitle("Class Heat Map"))
}

#read in prepare air data set
airClean <- function() {
    
    df <-'airsurvey.json'
    airData	<- jsonlite::fromJSON(df)
    airData <- data.frame(airData)    
    
    #do the basic cleanup
    airData$Departure.Delay.in.Minutes <-  
        replace_na(airData$Departure.Delay.in.Minutes, median(airData$Departure.Delay.in.Minutes,na.rm = TRUE))
    airData$Arrival.Delay.in.Minutes <-
        replace_na(airData$Arrival.Delay.in.Minutes, median(airData$Arrival.Delay.in.Minutes,na.rm = TRUE)) 
    airData$Flight.time.in.minutes <- 
        replace_na(airData$Flight.time.in.minutes, median(airData$Flight.time.in.minutes,na.rm = TRUE))
    
    # lowercase
    airData$Origin.State <- tolower(airData$Origin.State)
    airData$Airline.Status <- tolower(airData$Airline.Status)
    airData$Type.of.Travel <- tolower(airData$Type.of.Travel)
    airData$Gender <- tolower(airData$Gender)
    airData$Class <- tolower(airData$Class)
    airData$Partner.Name <- tolower(airData$Partner.Name)
    
    return(airData)
}

# Run the application
shinyApp(ui = ui, server = server)
