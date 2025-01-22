library(shiny)
library(DT)

# UI-Funktion
stakeholderInputUI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(
        width = 6,
        textInput(ns("name"), "Stakeholder Name", ""),
        sliderInput(ns("interesse"), "Interesse (1-10)", min = 1, max = 10, value = 5),
        sliderInput(ns("einfluss"), "Einfluss (1-10)", min = 1, max = 10, value = 5),
        sliderInput(ns("unterstuetzung"), "Unterstützung (1-10)", min = 1, max = 10, value = 5),
        actionButton(ns("add_stakeholder"), "Hinzufügen", icon = icon("plus")),
        fileInput(ns("file_upload"), "Daten hochladen", accept = ".csv"),
        downloadButton(ns("download_data"), "Daten speichern")
      ),
      column(
        width = 6,
        DTOutput(ns("stakeholder_table")),
        actionButton(ns("delete_selected"), "Ausgewählte löschen", icon = icon("trash"))
      )
    )
  )
}

# Server-Funktion
stakeholderInput <- function(input, output, session, stakeholder_data) {
  ns <- session$ns
  
  # Stakeholder hinzufügen
  observeEvent(input$add_stakeholder, {
    new_row <- data.frame(
      Name = input$name,
      Interesse = input$interesse,
      Einfluss = input$einfluss,
      Unterstützung = input$unterstuetzung,
      stringsAsFactors = FALSE
    )
    stakeholder_data(bind_rows(stakeholder_data(), new_row))
  })
  
  # Tabelle anzeigen
  output$stakeholder_table <- renderDT({
    datatable(stakeholder_data(), selection = "single", editable = FALSE)
  })
  
  # Ausgewählte Zeile löschen
  observeEvent(input$delete_selected, {
    selected <- input$stakeholder_table_rows_selected
    if (length(selected) > 0) {
      stakeholder_data(stakeholder_data()[-selected, ])
    }
  })
  
  # Daten hochladen
  observeEvent(input$file_upload, {
    req(input$file_upload)
    new_data <- read.csv(input$file_upload$datapath, stringsAsFactors = FALSE)
    stakeholder_data(new_data)
  })
  
  # Daten speichern
  output$download_data <- downloadHandler(
    filename = function() {
      paste("stakeholder_data_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(stakeholder_data(), file, row.names = FALSE)
    }
  )
}
