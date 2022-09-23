#' Server logic for the rapadm app
#'
#' @param input shiny input object
#' @param output shiny output object
#' @param session shiny session object
#'
#' @return A shiny app server object
#' @export

app_server <- function(input, output, session) {

  rapbase::navbarWidgetServer("rapadm-widget", orgName = "RapAdm")

  # Environment
  output$user <- shiny::renderText({
    paste("rapbase::getUserName(session):",
          rapbase::getUserName(session))
  })
  output$group <- shiny::renderText({
    paste("rapbase::getUserGroups(session):",
          rapbase::getUserGroups(session))
  })
  output$resh_id <- shiny::renderText({
    paste("rapbase::getUserReshId(session):",
          rapbase::getUserReshId(session))
  })
  output$role <- shiny::renderText({
    paste("rapbase::getUserRole(session):",
          rapbase::getUserRole(session))
  })
  output$email <- shiny::renderText({
    paste("rapbase::getUserEmail(session):",
          rapbase::getUserEmail(session))
  })
  output$full_name <- shiny::renderText({
    paste("rapbase::getUserFullName(session):",
          rapbase::getUserFullName(session))
  })
  output$phone <- shiny::renderText({
    paste("rapbase::getUserPhone(session):",
          rapbase::getUserPhone(session))
  })
  output$instance <- shiny::renderText({
    Sys.getenv("R_RAP_INSTANCE")
  })
  output$config_path <- shiny::renderText({
    Sys.getenv("R_RAP_CONFIG_PATH")
  })
  output$sp_usergroups <- shiny::renderText({
    paste("Sys.getenv('SHINYPROXY_USERGROUPS'):",
          Sys.getenv("SHINYPROXY_USERGROUPS"))
  })
  output$locale <- shiny::renderText({
    Sys.getlocale()
  })


  # Configuration"
  output$rapbase_config <- shiny::renderText({
    f <- file.path(Sys.getenv("R_RAP_CONFIG_PATH"), "rapbaseConfig.yml")
    if (file.exists(f)) {
      yaml::as.yaml(yaml::read_yaml(f))
    } else {
      "Not found!"
    }
  })


  # Logs
  output$container_log_ui <- shiny::renderUI({
    f <- file.info(
      list.files("/container_logs", full.names = TRUE)
    )
    f <- f %>%
      dplyr::arrange(dplyr::desc(.data$mtime)) %>%
      dplyr::slice_head(n = 50)
    log_file <- rownames(f)
    names(log_file) <- basename(rownames(f))
    shiny::selectInput(
      inputId = "container_log",
      label = "Select a log file:",
      choices = as.list(log_file)
    )
  })

  output$container_log <- shiny::renderText({
    shiny::req(input$container_log)
    raw_text <- readLines(input$container_log)
    paste0(raw_text, collapse = "\n")
  })


  # Usestats
  log <- shiny::reactive({
    rapbase:::readLog(type = input$type, name = "") %>%
      rapbase::logFormat()
  })

  output$download <- shiny::downloadHandler(
    filename = function() {
      basename(
        tempfile(
          pattern = paste0(input$type, "_usestats_"),
          fileext = ".csv"
        )
      )
    },
    content = function(file) {
      if (input$downloadFormat == "xlsx-csv") {
        readr::write_excel_csv2(log(), file)
      } else {
        readr::write_csv2(log(), file)
      }
    }
  )

  output$pivot <- rpivotTable::renderRpivotTable(
    rpivotTable::rpivotTable(
      log(),
      rows = c("group"),
      cols = c("year", "month"),
      rendererName = "Heatmap"
    )
  )

  # Autoreport
  ar <- rapbase::readAutoReportData()

  far <- shiny::reactive({
    shiny::req(input$fpackage, input$ftype, input$fowner, input$forganization)
    far <- ar
    if (input$fpackage != "none") {
      far <- rapbase::filterAutoRep(far, "package", input$fpackage)
    }
    if (input$ftype != "none") {
      far <- rapbase::filterAutoRep(far, "type", input$ftype)
    }
    if (input$fowner != "none") {
      far <- rapbase::filterAutoRep(far, "owner", input$fowner)
    }
    if (input$forganization != "none") {
      far <- rapbase::filterAutoRep(far, "organization", input$forganization)
    }
    far
  })

  output$fpackage <- shiny::renderUI({
    shiny::selectInput(
      "fpackage",
      "- registry:",
      choices = c("none", unique_autoreport(ar, "package"))
    )
  })
  output$ftype <- shiny::renderUI({
    shiny::selectInput(
      "ftype",
      "- type:",
      choices = c("none", unique_autoreport(ar, "type"))
    )
  })
  output$fowner <- shiny::renderUI({
    shiny::selectInput(
      "fowner",
      "- owner:",
      choices = c("none", unique_autoreport(ar, "owner"))
    )
  })
  output$forganization <- shiny::renderUI({
    shiny::selectInput(
      "forganization",
      "- organization:",
      choices = c("none", unique_autoreport(ar, "organization"))
    )
  })

  output$calendar <- shiny::renderPlot({
      plot(calendar_autoreport(far()))
  })

  # filters_package <- c("none", unique_autoreport(ar, "package"))
  # filters_type <- c("none", unique_autoreport(ar, "type"))
  # filters_owner <- c("none", unique_autoreport(ar, "owner"))
  # filters_organization <- c("none", unique_autoreport(ar, "organization"))

  output$autoreport_data <- shiny::renderText({
    yaml::as.yaml(far())
  })

}
