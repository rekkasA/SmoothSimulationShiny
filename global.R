library(dplyr)

loadFile <- function(
  input,
  fileName
) {
  constant <- input$settingsC
  constant <- gsub("[[:punct:]]", "", constant)
  if (input$type == "Constant") {
    dat <- readRDS(
      file.path(
        "data",
        paste(
          "rct",
          "or", constant,
          "lp", 45,
          "lp2", "00",
          "x", paste(rep("00", 8), collapse = "_"),
          sep = "_"
        ),
        paste(fileName, "rds", sep = ".")
      )
    )
  } else if (input$type == "Line") {
    a <- input$lineSettingsA
    dat <- readRDS(
      file.path(
        "data",
        paste(
          "rct",
          "or", constant,
          "lp", a,
          "lp2", "00",
          "x", paste(rep("00", 8), collapse = "_"),
          sep = "_"
        ),
        paste(fileName, "rds", sep = ".")
      )
    )
  } else {
    b <- input$squareSettingsB
    b <- gsub("[[:punct:]]", "", b)
    dat <- readRDS(
      file.path(
        "data",
        paste(
          "rct",
          "or", constant,
          "lp", 45,
          "lp2", b,
          "x", paste(rep("00", 8), collapse = "_"),
          sep = "_"
        ),
        paste(fileName, "rds", sep = ".")
      )
    )
  }

  return(dat)

}





drawBoxPlot <- function(
  data
) {

  data %>%
    reshape2::melt() %>%
    ggplot2::ggplot(
      ggplot2::aes(x = variable, y = value, fill = variable)
    ) +
    ggplot2::geom_boxplot() +
    ggplot2::theme_bw()
}





plotConstant <- function(
  settingsC
) {
  res <- ggplot2::ggplot() +
    ggplot2::stat_function(
    data = data.frame(x = c(-5, 5)),
    ggplot2::aes(x = x, color = "Constant"),
      fun = l,
      args = list(a = 0, c = log(settingsC))
    )
  return(res)
}





plotLine <- function(
  settingsC,
  lineSettingsA
) {

  a <- lineSettingsA
  slope <- tan(a * pi / 180) - 1

  res <- plotConstant(settingsC) +
    ggplot2::stat_function(
      data = data.frame(x = c(-5, 5)),
      ggplot2::aes(x = x, color = "Linear deviation"),
      fun = l,
      args = list(
        a = slope,
        c = log(settingsC)
      )
    )

  return(res)

}




plotSquare <- function(
  settingsC,
  squareSettingsB
) {

  res <- plotConstant(settingsC) +
    ggplot2::stat_function(
      data = data.frame(x = c(-5, 5)),
      ggplot2::aes(x = x, color = "Square deviation"),
      fun = f,
      args = list(a = 0, b = squareSettingsB, c = log(settingsC))
    )

  return(res)

}

f <- function(
  x, a, b, c
) {
  ret <- b * x^2 + (a + 1) * x + c
  return(ret)
}

l <- function(
  x, a, c
) {
  ret <- (a + 1) * x + c
  return(ret)
}
