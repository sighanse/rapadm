#' Client (ui) for the rapadm app
#'
#' @return An shiny app ui object
#' @export

app_ui <- function() {

  #shiny::addResourcePath("rap", system.file("www", package = "rapbase"))
  app_title <- "RapAdm"

  shiny::tagList(
    shiny::navbarPage(
      theme = bslib::bs_theme(
        bootswatch = "flatly"
      ),
      title = app_title,
      windowTitle = app_title,
      id = "tabs",

      shiny::tabPanel(
        "Environment",
        rapbase::navbarWidgetInput("rapadm-widget"),
        h4("Test 'rapbase' functions using the session object:"),
        shiny::textOutput("user"),
        shiny::textOutput("group"),
        shiny::textOutput("resh_id"),
        shiny::textOutput("role"),
        shiny::textOutput("email"),
        shiny::textOutput("full_name"),
        shiny::textOutput("phone"),
        h4("Environment var R_RAP_INSTANCE:"),
        shiny::textOutput("instance"),
        h4("Environmental var R_RAP_CONFIG_PATH:"),
        shiny::textOutput("config_path"),
        h4("Locale settings:"),
        shiny::textOutput("locale")
      ),

      shiny::tabPanel(
        "Configuration",

        shiny::tabsetPanel(
          shiny::tabPanel(
            "rapbaseConfig",
            shiny::verbatimTextOutput("rapbase_config")
          )
        )
      ),

      shiny::tabPanel(
        "Logs",
        shiny::sidebarLayout(
          shiny::sidebarPanel(
            shiny::uiOutput("container_log_ui")
          ),
          shiny::mainPanel(
            shiny::uiOutput("container_log")
          )
        )
      ),

      shiny::tabPanel(
        "Usestats"
      ),

      shiny::tabPanel(
        "Autoreports"
      )

    )
  )
}
