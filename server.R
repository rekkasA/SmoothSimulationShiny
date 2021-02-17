shiny::shinyServer(
  function(
    input,
    output,
    session
  ) {

    evaluation <- shiny::reactive(
      {
        dat <- loadFile(
          input = input,
          fileName = "evaluation"
        )
        return(dat)
      }
    )

    inputSettings <- shiny::reactive(
      {
        dType <- input$type
        settingsC <- input$settingsC
        lineSettingsA <- input$lineSettingsA
        squareSettingsB <- input$squareSettingsB

        return(
          list(
            type            = dType,
            settingsC       = as.numeric(settingsC),
            lineSettingsA   = as.numeric(lineSettingsA),
            squareSettingsB = as.numeric(squareSettingsB)
          )
        )
      }
    )

    prediction <- shiny::reactive(
      {
        dat <- loadFile(
          input = input,
          fileName = "prediction"
        )
        return(dat)
      }
    )

    output$rmse <- shiny::renderPlot(
      {
        eval <- evaluation()
        rmse <- eval$rmse
        drawBoxPlot(rmse) +
          ggplot2::theme(
            legend.text  = ggplot2::element_text(size = 15),
            legend.title = ggplot2::element_blank(),
            axis.text    = ggplot2::element_text(size = 15),
            axis.title   = ggplot2::element_blank()
          )
      }
    )

    output$discrimination <- shiny::renderPlot(
      {
        eval <- evaluation()
        discrimination <- eval$discrimination
        drawBoxPlot(discrimination) +
          ggplot2::theme(
            legend.text  = ggplot2::element_text(size = 15),
            legend.title = ggplot2::element_blank(),
            axis.text    = ggplot2::element_text(size = 15),
            axis.title   = ggplot2::element_blank()
          )
      }
    )

    output$calibration <- shiny::renderPlot(
      {
        eval <- evaluation()
        calibration <- eval$calibration
        drawBoxPlot(calibration) +
          ggplot2::theme(
            legend.text  = ggplot2::element_text(size = 15),
            legend.title = ggplot2::element_blank(),
            axis.text    = ggplot2::element_text(size = 15),
            axis.title   = ggplot2::element_blank()
          )
      }
    )

    output$riskEvolution <- shiny::renderPlot(
      {
        settings <- inputSettings()

        if (settings$type == "Line") {
          res <- plotLine(
            settingsC = settings$settingsC,
            lineSettingsA = settings$lineSettingsA
          )
        } else if (settings$type == "Square") {
          res <- plotSquare(
            settingsC = settings$settingsC,
            squareSettingsB = settings$squareSettingsB
          )
        } else {
          res <- plotConstant(
            settingsC = settings$settingsC
          )
        }

        res +
          ggplot2::ylab("lp_1") +
          ggplot2::xlab("lp_0") +
          ggplot2::theme_bw() +
          ggplot2::theme(
            legend.title = ggplot2::element_blank(),
            legend.text  = ggplot2::element_text(size = 15),
            axis.title   = ggplot2::element_text(size = 15),
            axis.text    = ggplot2::element_text(size = 15)
          )
      }
    )

    output$predictionEvaluation <- DT::renderDataTable(
      {
        pred <- prediction() %>%
          dplyr::rename("ROC" = "C (ROC)") %>%
          dplyr::select(ROC, Intercept, Slope, Brier)
        roc <- data.frame(
          metric = "AUC",
          median = median(pred$ROC),
          lower  = quantile(pred$ROC, .025),
          upper  = quantile(pred$ROC, .975)
        )
        intercept <- data.frame(
          metric = "Intercept",
          median = median(pred$Intercept),
          lower  = quantile(pred$Intercept, .025),
          upper  = quantile(pred$Intercept, .975)
        )
        slope <- data.frame(
          metric = "Slope",
          median = median(pred$Slope),
          lower  = quantile(pred$Slope, .025),
          upper  = quantile(pred$Slope, .975)
        )
        brier <- data.frame(
          metric = "Brier",
          median = median(pred$Brier),
          lower  = quantile(pred$Brier, .025),
          upper  = quantile(pred$Brier, .975)
        )

        rownames(roc) <- rownames(intercept) <- rownames(slope) <- rownames(brier) <- NULL

        dat <- DT::datatable(
          bind_rows(roc, intercept, slope, brier)
        )

        dat <- DT::formatCurrency(
          table    = dat,
          columns  =  c("median", "lower", "upper"),
          currency = "",
          interval = 3,
          mark     = ",",
          digits   = 3
        )

        return(dat)
      }
    )

  }
)
