library(tidyverse)
library(leaflet)
library(shiny)
library(shinythemes)

sta_data <- read_csv("clean_data/sta_data.csv")

# defines the different roles
roles <- unique(sta_data$role)

# Creates the sta icon for points on the map
sta_icon <- makeIcon(
    iconUrl = "img/sta_logo.jpg",
    iconWidth = 20, iconHeight = 20,
    iconAnchorX = 0, iconAnchorY = 0)


# Define UI for application that draws a histogram
ui <- bootstrapPage(
    theme = shinytheme("flatly"),
    # CSS for adding the style to the absolute panel
    tags$head(includeCSS("styles.css")),
    
    # CSS for making the map full screen
    tags$style(type = "text/css", "#map {height: calc(110vh - 80px) !important;}"),
    
    # the map output
    leafletOutput("map"),
    
    # The moveable panel with role selection in
    absolutePanel(id = "panel",
        h1("Who is STA?"),
        top = 100, left = 10, draggable = TRUE, width = "20%", #style = "z-index:500; min-width: 300px;",
        checkboxGroupInput("role_select",
                           "Select Roles:",
                           choices = roles,
                           selected = roles),
        "You can drag me!"
    )


)





server <- function(input, output) {
    
    # Create reactive dataset
    role_filtered <- reactive({
        sta_data %>%
            filter(role %in% input$role_select) 
    })
    
    
    # Renders the map
    output$map <- renderLeaflet({
        
        role_filtered() %>% 
            leaflet() %>% 
            addProviderTiles(
                providers$CartoDB.Positron
            ) %>%
            addMarkers(lng = ~long,
                       lat = ~lat,
                       icon = sta_icon,
                       popup = paste("Location:", role_filtered()$location, "<br>",
                                     "Name:", role_filtered()$name, "<br>",
                                     "Role:", role_filtered()$role)
                       )
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
