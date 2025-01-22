library(shiny)
library(tidyverse)
library(DT)
library(shinydashboard)
library(rmarkdown)

# Module laden
source("modules/stakeholder_input.R")
source("modules/stakeholder_visualization.R")

# UI ----
ui <- dashboardPage(
  dashboardHeader(title = "Stakeholder Analyse"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Stakeholder Eingabe", tabName = "input_tab", icon = icon("edit")),
      menuItem("Analyse & Visualisierung", tabName = "visualization_tab", icon = icon("chart-bar"))
    )
  ),
  dashboardBody(
    tabItems(
      # Tab: Eingabe
      tabItem(
        tabName = "input_tab",
        stakeholderInputUI("stakeholder_input_module")
      ),
      # Tab: Visualisierung
      tabItem(
        tabName = "visualization_tab",
        stakeholderVisualizationUI("stakeholder_visualization_module")
      )
    )
  )
)

# Server ----
server <- function(input, output, session) {
  # Reactive Werte für Stakeholder-Daten
  stakeholder_data <- reactiveVal(data.frame(
    Name = character(),
    Interesse = numeric(),
    Einfluss = numeric(),
    Unterstützung = numeric(),
    stringsAsFactors = FALSE
  ))
  
  # Modul: Stakeholder Eingabe
  callModule(stakeholderInput, "stakeholder_input_module", stakeholder_data)
  
  # Modul: Stakeholder Visualisierung
  callModule(stakeholderVisualization, "stakeholder_visualization_module", stakeholder_data)
}

# App starten
shinyApp(ui, server)
