#' Half violin + histogram geom for ggplot2
#'
#' `geom_violinhist()` draws a half violin on one side of the group and a
#' histogram of the same data on the other side. This is a lightweight
#' first implementation (skeleton) that returns a half-violin layer and a
#' placeholder for the histogram. We'll iterate on the histogram implementation
#' in small steps so the behavior matches your intended visual.
#'
#' @param data, mapping Standard ggplot2 layer arguments (see `ggplot2::layer`).
#'   Mapping is expected to map `y` to the numeric variable and `x` to the
#'   grouping/factor variable (same convention as `geom_violin`).
#' @param side Which side to draw the violin on: `"left"` or `"right"`.
#' @param fill Fill color for the violin.
#' @param violin_alpha Violin alpha value.
#' @param violin_linewidth Violin line width.
#' @param nudge_value Horizontal nudge to separate the two halves.
#' @param ... Additional arguments passed to the underlying layers.
#'
#' @return A list of ggplot2 layers.
#' @export
#' @examples
#' # Intended usage (works once you have data mapping):
#' # ggplot(df, aes(x = group, y = value)) +
#' #   geom_violinhist()
geom_violinhist <- function(data = NULL,
                            mapping = NULL,
                            side = c("left", "right"),
                            fill = "lightblue",
                            violin_alpha = 1,
                            violin_linewidth = 0,
                            nudge_value = 0,
                            # histogram params
                            bins = 30,
                            binwidth = NULL,
                            width = 0.4,
                            hist_fill = "grey20",
                            hist_alpha = 0.4,
                            hist_color = NA,
                            ...) {
  side <- match.arg(side)

  # direction for nudge (no nudge by default)
  nudge_value <- if (side == "left") - abs(nudge_value) else abs(nudge_value)

  # Half violin layer
  violin_layer <- see::geom_violinhalf(
    data = data,
    mapping = mapping,
    fill = fill,
    linewidth = violin_linewidth,
    alpha = violin_alpha,
    position = position_nudge(nudge_value),
    flip = side == "left",
    ...
  )

 # Stat that computes per-group histogram bins and returns rectangle data
  StatViolinhist <- ggplot2::ggproto(
    "StatViolinhist",
    ggplot2::Stat,
    required_aes = c("x", "y"),
    compute_group = function(data, scales, bins = 30, binwidth = NULL, width = 0.4, side = "right", fill = "grey20", alpha = 0.4, colour = NA, nudge = 0) {
      y <- data$y
      x_center <- unique(data$x)
      if (length(x_center) > 1) x_center <- mean(x_center)
      # apply histogram nudge (passed as param); moves histogram away/towards center
      x_center <- x_center + nudge

      # compute histogram
      if (!is.null(binwidth)) {
        breaks <- seq(min(y, na.rm = TRUE), max(y, na.rm = TRUE), by = binwidth)
        if (length(breaks) < 2) breaks <- pretty(range(y, na.rm = TRUE), n = bins)
      } else {
        h <- hist(y, plot = FALSE, breaks = bins)
        breaks <- h$breaks
      }

    h <- hist(y, breaks = breaks, plot = FALSE)
    counts <- h$counts
    mids <- h$mids
    binwidths <- diff(h$breaks)

      # density per bin: counts / (n * binwidth)
      npts <- sum(counts)
      bin_density <- counts / (npts * binwidths)

      # normalize densities to max and scale to requested width
      if (all(bin_density == 0)) {
        width_vals <- rep(0, length(bin_density))
      } else {
        width_vals <- (bin_density / max(bin_density, na.rm = TRUE)) * width
      }

  # Draw histogram on the other side of the violin
  sign <- if (side == "left") 1 else - 1

      df <- data.frame(
        xmin = x_center,
        xmax = x_center + sign * width_vals,
        ymin = h$breaks[-length(h$breaks)],
        ymax = h$breaks[-1],
        y = mids,
        count = counts,
        density = bin_density,
        fill = fill,
        alpha = alpha,
        colour = colour
      )

      df
    }
  )

  # Histogram layer
  hist_layer <- ggplot2::layer(
    stat = StatViolinhist,
    data = data,
    mapping = mapping,
    geom = ggplot2::GeomRect,
    position = "identity",
    inherit.aes = TRUE,
    params = list(
      bins = bins,
      binwidth = binwidth,
      width = width,
      side = side,
      nudge = - nudge_value,
      fill = hist_fill,
      alpha = hist_alpha,
      colour = hist_color,
      na.rm = TRUE
    )
  )

  list(violin_layer, hist_layer)
}