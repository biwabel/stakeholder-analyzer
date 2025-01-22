library(shiny)
library(ggplot2)

# UI-Funktion
stakeholderVisualizationUI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(
        width = 4,
        selectInput(
          ns("x_axis"),
          "X-Achse",
          choices = c("Interesse", "Einfluss", "Unterstützung"),
          selected = "Interesse"
        ),
        selectInput(
          ns("y_axis"),
          "Y-Achse",
          choices = c("Interesse", "Einfluss", "Unterstützung"),
          selected = "Einfluss"
        ),
        checkboxInput(ns("color_by_name"), "Nach Name färben", value = TRUE),
        downloadButton(ns("download_report"), "Bericht herunterladen")
      ),
      column(
        width = 8,
        plotOutput(ns("scatter_plot")),
        plotOutput(ns("heatmap"))
      )
    )
  )
}

# Server-Funktion
stakeholderVisualization <- function(input, output, session, stakeholder_data) {
  ns <- session$ns
  
  # Streudiagramm
  output$scatter_plot <- renderPlot({
    req(stakeholder_data())
    data <- stakeholder_data()
    
    ggplot(data, aes_string(
      x = input$x_axis,
      y = input$y_axis,
      color = ifelse(input$color_by_name, "Name", NULL)
    )) +
      geom_point(size = 4) +
      labs(
        x = input$x_axis,
        y = input$y_axis,
        title = "Stakeholder Analyse"
      ) +
      theme_minimal()
  })
  
  # Heatmap
  output$heatmap <- renderPlot({
    req(stakeholder_data())
    data <- stakeholder_data()
    
    ggplot(data, aes(x = Name, y = 1)) +
      geom_tile(aes(fill = Interesse), color = "white") +
      scale_fill_gradient(low = "white", high = "blue") +
      labs(title = "Interesse-Übersicht", x = "Stakeholder", y = NULL) +
      theme_minimal() +
      theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
  })
  
  # Bericht herunterladen
  output$download_report <- downloadHandler(
    filename = function() {
      paste("stakeholder_report_", Sys.Date(), ".pdf", sep = "")
    },
    content = function(file) {
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
      
      rmarkdown::render(
        tempReport,
        output_file = file,
        params = list(data = stakeholder_data()),
        envir = new.env(parent = globalenv())
      )
    }
  )
}
