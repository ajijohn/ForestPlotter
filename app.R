if(!require("ForestPlot"))
  devtools::install_github("sgraham9319/ForestPlot")
library(shinydashboard)
library(shiny)
library(ForestPlot)
library(dplyr)

# The list of valid books
plots <<- list("TO04" = "TO04",
               "AV06" = "AV06", 
               "AB08"="AB08",
               "AE10" = "AE10")
load("Data/mapping.rda")
load("Data/tree.rda")

body <- dashboardBody(
  fluidRow(
    box(
      title = "Size Distribution", width = 6, status = "primary",
      "...",
      plotOutput("plot")
    ),
    box(
      status = "warning", width = 6, title = "Stand Map",
      "...",
      plotOutput("standplot")
    )
  ),
  
  fluidRow(
    column(width = 4,

           box(
             width = NULL, background = "black",
             "",
             sliderInput("bins", "Number of bins:", 1, 10, 2)
           )
    ),
    
    column(width = 4,

           box(
             title = "Forest plots", width = NULL, background = "light-blue",
             selectInput("selection", "Choose a Plot:",
                         choices = plots)
           )
    ),
    
    column(width = 4,

           box(
             title = "...", width = NULL, background = "maroon",
             "..."
           )
    )
  )
)

# We'll save it in a variable `ui` so that we can preview it in the console
ui <- dashboardPage( skin = "green",
  dashboardHeader(title = "Forest Plotter"),
  dashboardSidebar(  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Widgets", icon = icon("th"), tabName = "widgets",
             badgeLabel = "new", badgeColor = "green")
  )
  ),
  body
)

# Define server logic required to draw a histogram
server <- function(input, output, session) 
{
  terms <- reactive({
    # Change when the "update" button is pressed...
    input$update
    # ...but not for anything else
    isolate({
      withProgress({
        setProgress(message = "Processing plot...")
      })
    })
  })
  
  
  output$plot <- renderPlot({
    size_dist(size_data = tree, stands = input$selection,bin_size = input$bins)
  })
  
  output$standplot <- renderPlot({
  # Isolate mapping and tree data for one stand
  one_stand_map <- mapping %>%
    filter(stand_id == input$selection)
  one_stand_tree <- tree %>%
    filter(stand_id == input$selection)
  
  # Create stand map
  stand_map(one_stand_map, one_stand_tree, c(50, 100), c(50, 100))
  })
  
}
# Preview the UI in the console
shinyApp(ui = ui, server = server)