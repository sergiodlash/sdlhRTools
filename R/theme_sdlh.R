#' Custom theme for ggplot
#'
#' This function applies a custom ggplot2 theme with optimized settings.
#'
#' @return A ggplot2 theme object
#'
#'
#' @examples
#' ggplot(pressure, aes(temperature, pressure)) +
#'   geom_point() +
#'   theme_sdlh()
#'
#' @export
theme_sdlh <- function() {
  theme_minimal() +
    theme(
      text = element_text(size = 10),
      plot.margin = margin(0.3, 0.3, 0, 0.3, "cm"),
      legend.title = element_text(size = 8),
      legend.text = element_text(size = 7),
      legend.position = "bottom",
      legend.justification = c("right", "bottom"),
      legend.background = element_rect(fill = "white", linewidth = 0)
    )
}
