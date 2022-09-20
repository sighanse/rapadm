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
  output$user <- renderText({
    paste("rapbase::getUserName(session):",
          rapbase::getUserName(session))
  })
  output$group <- renderText({
    paste("rapbase::getUserGroups(session):",
          rapbase::getUserGroups(session))
  })
  output$resh_id <- renderText({
    paste("rapbase::getUserReshId(session):",
          rapbase::getUserReshId(session))
  })
  output$role <- renderText({
    paste("rapbase::getUserRole(session):",
          rapbase::getUserRole(session))
  })
  output$email <- renderText({
    paste("rapbase::getUserEmail(session):",
          rapbase::getUserEmail(session))
  })
  output$full_name <- renderText({
    paste("rapbase::getUserFullName(session):",
          rapbase::getUserFullName(session))
  })
  output$phone <- renderText({
    paste("rapbase::getUserPhone(session):",
          rapbase::getUserPhone(session))
  })
  output$instance <- renderText({
    Sys.getenv("R_RAP_INSTANCE")
  })
  output$config_path <- renderText({
    Sys.getenv("R_RAP_CONFIG_PATH")
  })
  output$locale <- renderText({
    Sys.getlocale()
  })


  output$rapbase_config <- shiny::renderText({
    f <- file.path(Sys.getenv("R_RAP_CONFIG_PATH"), "rapbaseConfig.yml")
    if (file.exists(f)) {
      yaml::as.yaml(yaml::read_yaml(f))
    } else {
      "Not found!"
    }
  })


  output$container_log_ui <- shiny::renderUI({
    f <- file.info(
      list.files("/var/log", full.names = TRUE)
    )
    f <- f %>%
      dplyr::arrange(desc(mtime)) %>%
      dplyr::slice_head(n = 50)
    log_file <- rownames(f)
    names(log_file) <- basename(rownames(f))
    log_file <- log_file[names(log_file) != "access.log"]
    shiny::selectInput(
      inputId = "container_log",
      label = "Select a log file:",
      choices = as.list(log_file)
    )
  })

  output$container_log <- shiny::renderUI({
    shiny::req(input$container_log)
    raw_text <- readLines(input$container_log)
    split_text <- stringi::stri_split(raw_text, regex = "\\n")
    print(class(split_text))
    lapply(split_text, shiny::p)
  })





}
