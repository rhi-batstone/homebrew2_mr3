library(tidyverse)
library(leaflet)
library(shiny)
library(shinythemes)
library(leafpop)
library(shinydashboard)

sta_data <- read_csv("clean_data/sta_data.csv")

# defines the different roles
roles <- unique(sta_data$role)

# Creates the sta icon for points on the map
sta_icon <- makeIcon(
    iconUrl = "www/sta_logo.jpg",
    iconWidth = 20, iconHeight = 20,
    iconAnchorX = 0, iconAnchorY = 0)


# Define UI for application that draws a histogram
ui <- dashboardPage(
    dashboardHeader(title = "Homebrew 2"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Map", tabName = "dashboard", icon = icon("dashboard")),
            menuItem("Viz", tabName = "widgets", icon = icon("jedi-order"))
        )
    ),
    dashboardBody(
    #theme = shinytheme("flatly"),
    # CSS for adding the style to the absolute panel
    tags$head(includeCSS("styles.css")),
    
    # CSS for making the map full screen
    tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
    
    # the map output
    leafletOutput("map"),
    
    # The moveable panel with role selection in
    absolutePanel(id = "panel",
        h1("STA Roles"),
        bottom = 50, draggable = TRUE, width = "20%", #style = "z-index:500; min-width: 300px;",
        checkboxGroupInput("role_select",
                           "Select Roles:",
                           choices = roles,
                           selected = roles),
        "You can drag me!"
    )

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
                       #stroke = F,
                       #color = "magenta",
                       group = "sta_images",
                       clusterOptions = T,
                       popup = paste("Location:", role_filtered()$location, "<br>",
                                     "Name:", role_filtered()$name, "<br>",
                                     "Role:", role_filtered()$role,
                                     "<div><a target='_blank' href='", role_filtered()$img,"'><img width=100%, height=100% src='", role_filtered()$img,"' ></a></div>"
                                     )
                       )
            
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
