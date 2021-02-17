shiny::shinyUI(
  shinydashboardPlus::dashboardPagePlus(
    skin                 = "black",
    title                = "Simulations",
    sidebar_fullCollapse = TRUE,
    shinydashboard::dashboardHeader(
      title = "Simulations"
    ),
    shinydashboard::dashboardSidebar(
      shinydashboard::sidebarMenu(
        id = "menu1",
        shinydashboard::menuItem(
          tabName = "settings",
          text    = "Settings",
          icon    = icon("cogs")
        ),
        shinydashboard::menuItem(
          tabName = "results",
          text    = "Simulation results",
          icon    = icon("poll")
        ),
        shinydashboard::menuItem(
          tabName = "prediction",
          text    = "Prediction",
          icon    = icon("dice-six")
        )
      ),
      shinydashboard::sidebarMenu(
        id = "menu2",
        shiny::selectInput(
          inputId  = "study",
          label    = "Study type",
          choices  = "RCT",
          selected = "RCT"
        ),
        shiny::selectInput(
          inputId = "type",
          label   = "Type of benefit evolution",
          choices = c(
            "Constant",
            "Line",
            "Square"
          ),
          selected = "Constant"
        ),
        shiny::selectInput(
          inputId  = "settingsC",
          label    = "Settings: c",
          choices  = c(0.5, 0.8),
          selected = 0.5
        ),
        shiny::conditionalPanel(
          condition = "input.type == 'Line'",
          shiny::selectInput(
            inputId  = "lineSettingsA",
            label    = "Settings: a (degrees)",
            choices  = c(25, 35),
            selected = 35
          )
        ),
        shiny::conditionalPanel(
          condition = "input.type == 'Square'",
          shiny::selectInput(
            inputId  = "squareSettingsB",
            label    = "Settings: b",
            choices  = c(-0.1, -0.2, -0.5),
            selected = -.1
          )
        )
      )
    ),
    shinydashboard::dashboardBody(
      shinydashboard::tabItems(
        shinydashboard::tabItem(
          tabName = "settings",
          shiny::plotOutput(
            "riskEvolution",
            height = "600px"
          )
        ),
        shinydashboard::tabItem(
          tabName = "results",
          shiny::tabsetPanel(
            id = "resultsPanel",
            shiny::tabPanel(
              title = "RMSE",
              shiny::plotOutput(
                "rmse",
                height = "600px"
              )
            ),
            shiny::tabPanel(
              title = "Discrimination",
              shiny::plotOutput(
                "discrimination",
                height = "600px"
              )
            ),
            shiny::tabPanel(
              title = "Calibration",
              shiny::plotOutput(
                "calibration",
                height = "600px"
              )
            )
          )
        ),
        shinydashboard::tabItem(
          tabName = "results"
        ),
        shinydashboard::tabItem(
          tabName = "prediction",
          DT::dataTableOutput("predictionEvaluation")
        )
      )
    )
  )
)
