#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# 1. File input nibo.
# Parameters: 
# 2. Output: 
#   Input data table
#   Feature importance picture
#   Model comparison with baseline.

library(shiny)
library(data.table)
library(DT)
library(glmnet)
library(ggplot2)

source("dataset-processing.R")

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Calculation of Feature Importance"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      fileInput("inputfile", "Choose Preprocessed CSV File", accept = ".csv"),
      checkboxInput("header", "Header", TRUE),
      selectInput(
        'target',
        label = 'Choose the target variable :',
        choices = list()
      )
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      label = 'Applying cv.glmnet',
      dataTableOutput("inputs"),
      plotOutput("variableimportance")
    )
  )
)


# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  data.dt <- reactive({ 
    print("called data.dt")
    file <- input$inputfile
    ext <- tools::file_ext(file$datapath)
    
    req(file)
    validate(need(ext == "csv", "Only CSV files are acceptable at the moment"))
    
    data <- read.csv(file$datapath, header = input$header)
    data.dt <- data.table(data)
    
    data.dt
  })
  
  observe({
    print("called target")
    req(data.dt)
    cols <- colnames(data.dt())
    updateSelectInput(session, "target",
                    choices = cols)
  })
  
  output$inputs <- DT::renderDataTable(
    DT::datatable(
      data.dt(),
      options = list(
        pageLength = 10
      )
    )
  )
  
  output$variableimportance <- renderPlot({
    print("called renderplot")
    target.col <- input$target
    req(target.col)
    req(data.dt)
    get.feature.importance.plot(data.dt(), target.col)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

