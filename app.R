library(tidyverse)
library(leaflet)
library(shiny)
library(leafpop)
library(shinydashboard)

sta_data <- read_csv("clean_data/sta_data.csv")

# defines the different roles
roles <- unique(sta_data$role)

# Creates the sta icon for points on the map
# sta_icon <- makeIcon(
#   iconUrl = "www/sta_logo.jpg",
#   iconWidth = 20, iconHeight = 20,
#   iconAnchorX = 0, iconAnchorY = 0
# )


# Define UI for application that draws a histogram
ui <- dashboardPage(
  dashboardHeader(title = "Homebrew 2"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Viz", tabName = "viz", icon = icon("jedi-order")),
      menuItem("Map", tabName = "map", icon = icon("dashboard"))
    )
  ),

  dashboardBody(
    tabItems(
      tabItem(tabName = "viz", 
              h1("Nothing here yet")),
      
      tabItem(
        tabName = "map",

        # CSS for adding the style to the absolute panel
        tags$head(includeCSS("styles.css")),

        # CSS for making the map full screen
        tags$style(
          type = "text/css",
          "#map {height: calc(100vh - 80px) !important;}"
        ),

        # the map output
        leafletOutput("map"),

        # The moveable panel with role selection in
        absolutePanel(
          id = "panel",
          h1("STA Roles"),
          top = 500,
          #left = 10,
          draggable = TRUE,
          width = "20%",
          checkboxGroupInput("role_select",
            "Select Roles:",
            choices = roles,
            selected = roles
          ),
          "You can drag me!"
        )
      )
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
      addMarkers(
        lng = ~long,
        lat = ~lat,
        #icon = sta_icon,
        group = "sta_images",
        clusterOptions = T,
        popup = paste(
          "Location:", role_filtered()$location, "<br>",
          "Name:", role_filtered()$name, "<br>",
          "Role:", role_filtered()$role,
          "<div><a target='_blank' href='", role_filtered()$img, "'><img width=100%, height=100% src='", role_filtered()$img, "' ></a></div>"
        )
      )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
