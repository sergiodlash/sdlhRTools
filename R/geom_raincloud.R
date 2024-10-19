#' Raincloud plot with stats
#'
#' This function creates a custom raincloud plot, which is a combination of a
#' half violin plot and a dotplot.
#' It is useful for visualizing the distribution of data with both density
#' (violin) and individual data points (dotplot).
#'
#' @return A ggplot2 layer
#' @export
#'
#' @import ggplot2
#' @import see
#'
geom_raincloud <- function(mapping = NULL,
                           color_fill = "lightgreen",
                           side = c("left", "right"),
                           violin_linewidth = 0,
                           violin_alpha = 1,
                           nudge_value = 0.05,
                           dotsize = 1,
                           stackratio = 1.4,
                           binwidth = 0.5,
                           quartile_linewidth = 1,
                           fun = median,
                           marker_size = 0.3) {
  side <- match.arg(side)

  nudge_value <- if (side == "left") -nudge_value else nudge_value
  stackdir_value <- if (side == "left") "down" else "up"

  list(
    geom_violinhalf(
      mapping = mapping,
      fill = color_fill,
      linewidth = violin_linewidth,
      alpha = violin_alpha,
      position = position_nudge(nudge_value),
      flip = side == "left"
    ),
    geom_dotplot(
      mapping = mapping,
      fill = scales::alpha("black", 0),
      binaxis = "y",
      dotsize = dotsize,
      stackdir = stackdir_value,
      stackratio = stackratio,
      binwidth = binwidth,
      position = position_nudge(nudge_value)
    ),
    stat_summary(
      mapping = mapping,
      color = color_fill,
      linewidth = quartile_linewidth,
      fun.min = function(z) quantile(z, 0.25),
      fun.max = function(z) quantile(z, 0.75),
      fun = fun,
      size = marker_size,
      position = position_nudge(nudge_value / 2)
    )
  )
}
