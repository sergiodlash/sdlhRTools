#' Half violin + histogram geom for ggplot2
#'
#' `geom_violinhist()` creates a combined visualization that draws a half violin
#' plot on one side of each group and a density-scaled histogram on the opposite
#' side. This allows for simultaneous display of smooth density estimation
#' (violin) and binned distribution (histogram) for the same data.
#'
#' @param data A data frame. If `NULL` (the default), data is inherited from
#'   the plot data as specified in `ggplot()`.
#' @param mapping Set of aesthetic mappings created by `aes()`. If `NULL`
#'   (the default), mappings are inherited from the plot mapping. Requires
#'   `x` (grouping variable) and `y` (continuous variable) aesthetics.
#' @param side Which side to draw the violin on: `"right"` (default) or `"left"`.
#'   The histogram is drawn on the opposite side.
#' @param fill Fill color for the violin. If `NULL` (default), inherits from
#'   the aesthetic mapping `aes(fill = ...)`. Set to a specific color to
#'   override mapping.
#' @param violin_alpha Transparency level for the violin (0 = fully transparent,
#'   1 = fully opaque). Default is 1.
#' @param violin_linewidth Line width for the violin outline. Default is 0
#'   (no outline).
#' @param nudge_value Horizontal offset to visually separate violin and histogram.
#'   Default is 0 (no separation). Positive values increase separation.
#' @param bins Number of histogram bins. Default is 7. Ignored if `binwidth`
#'   is specified.
#' @param binwidth Width of histogram bins. If specified, overrides `bins`.
#'   Default is `NULL`.
#' @param width Maximum horizontal extent of the histogram bars in x-axis units.
#'   Default is 0.4.
#' @param normalize Logical. If `TRUE`, histogram bar widths are scaled so the
#'   tallest bar reaches `width`. If `FALSE` (default), bar widths are
#'   proportional to density × `width` without normalization.
#' @param hist_fill Fill color for histogram bars. If `NULL` (default), inherits
#'   from the aesthetic mapping `aes(fill = ...)`. If no mapping exists,
#'   defaults to "grey20".
#' @param hist_alpha Transparency level for histogram bars. Default is 0.4.
#' @param hist_color Outline color for histogram bars. Default is `NA` (no outline).
#' @param ... Additional arguments passed to the violin layer (e.g., other
#'   parameters accepted by `see::geom_violinhalf()`).
#'
#' @return A list of two ggplot2 layers: the half-violin layer and the
#'   histogram layer.
#'
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' # Basic usage with default settings (violin on right, histogram on left)
#' ggplot(iris, aes(x = Species, y = Sepal.Width)) +
#'   geom_violinhist()
#'
#' # With fill aesthetic mapping
#' ggplot(iris, aes(x = Species, y = Sepal.Width, fill = Species)) +
#'   geom_violinhist()
#'
#' # Customize histogram bins and separation
#' ggplot(iris, aes(x = Species, y = Sepal.Width)) +
#'   geom_violinhist(bins = 10, nudge_value = 0.05)
#'
#' # Normalized histogram (tallest bar reaches full width)
#' ggplot(iris, aes(x = Species, y = Sepal.Width)) +
#'   geom_violinhist(normalize = TRUE)
#'
#' # Violin on left, histogram on right
#' ggplot(iris, aes(x = Species, y = Sepal.Width)) +
#'   geom_violinhist(side = "left")
geom_violinhist <- function(data = NULL,
                            mapping = NULL,
                            side = c("right", "left"),
                            fill = NULL,
                            violin_alpha = 1,
                            violin_linewidth = 0,
                            nudge_value = 0,
                            # histogram params
                            bins = 7,
                            binwidth = NULL,
                            width = 0.4,
                            normalize = FALSE,
                            hist_fill = NULL,
                            hist_alpha = 0.4,
                            hist_color = NA,
                            hist_side_flip = FALSE,
                            hist_linewidth = 0,
                            ...) {
  side <- match.arg(side)

  # Determine nudge direction based on which side the violin is drawn
  # Negative nudge for left-side violin, positive for right-side violin
  nudge_value <- if (side == "left") - abs(nudge_value) else abs(nudge_value)

  # Build half-violin layer using see::geom_violinhalf
  # Only pass fill parameter if explicitly provided by user, otherwise inherit from mapping
  violin_args <- list(
    data = data,
    mapping = mapping,
    linewidth = violin_linewidth,
    alpha = violin_alpha,
    position = position_nudge(nudge_value),
    flip = side == "left"
  )
  if (!is.null(fill)) violin_args$fill <- fill

  # Merge additional arguments passed via ... into violin layer
  extra_args <- list(...)
  if (length(extra_args)) violin_args <- c(violin_args, extra_args)

  violin_layer <- do.call(see::geom_violinhalf, violin_args)

  # Custom ggproto Stat for computing histogram bins and returning rectangle coordinates
  # This stat processes each group independently to create density-based histogram bars
  StatViolinhist <- ggplot2::ggproto(
    "StatViolinhist",
    ggplot2::Stat,
    required_aes = c("x", "y"),
  compute_group = function(data, scales, bins = 7, binwidth = NULL, width = 0.4, normalize = FALSE, side = "right", fill = NULL, alpha = 0.4, colour = NA, nudge = 0) {
      y <- data$y
      x_center <- unique(data$x)
      if (length(x_center) > 1) x_center <- mean(x_center)

      # Apply horizontal nudge to histogram position (opposite direction from violin)
      x_center <- x_center + nudge

      # Compute histogram breaks based on binwidth or number of bins
      if (!is.null(binwidth) && is.finite(binwidth) && binwidth > 0) {
        # Use specified binwidth: round start/end to binwidth multiples to ensure
        # breaks span the full data range
        y_min <- min(y, na.rm = TRUE)
        y_max <- max(y, na.rm = TRUE)
        start <- floor(y_min / binwidth) * binwidth
        end <- ceiling(y_max / binwidth) * binwidth

        # Handle edge case where all values are identical
        if (start == end) {
          start <- y_min - binwidth
          end <- y_max + binwidth
        }

        breaks <- seq(start, end, by = binwidth)

        # Fallback if breaks computation fails
        if (length(breaks) < 2) breaks <- pretty(range(y, na.rm = TRUE), n = bins)
      } else {
        # Use number of bins: let hist() determine optimal breaks
        h <- hist(y, plot = FALSE, breaks = bins)
        breaks <- h$breaks
      }

      # Compute histogram with determined breaks
      h <- hist(y, breaks = breaks, plot = FALSE)
      counts <- h$counts
      mids <- h$mids
      binwidths <- diff(h$breaks)

      # Calculate density per bin: counts / (total_points × binwidth)
      # This gives a probability density (area under histogram = 1)
      npts <- sum(counts)
      bin_density <- counts / (npts * binwidths)

      # Convert density to bar widths (in x-axis units)
      # If normalize=TRUE: scale so maximum bar reaches full width
      # If normalize=FALSE: use raw density × width (bars proportional to density)
      if (all(bin_density == 0)) {
        # No data: all bars have zero width
        width_vals <- rep(0, length(bin_density))
      } else if (isTRUE(normalize)) {
        # Normalized: scale to [0, width] range
        width_vals <- (bin_density / max(bin_density, na.rm = TRUE)) * width
      } else {
        # Raw density scaling: bars directly proportional to density
        width_vals <- bin_density * width
      }

      # Determine horizontal direction for histogram bars
      # If violin is on left, histogram extends right (positive)
      # If violin is on right, histogram extends left (negative)
      sign <- if (side == "left") 1 else -1

      # Determine fill color with precedence: explicit param > aesthetic mapping > default grey
      if (!is.null(fill)) {
        # Use explicitly provided fill color
        used_fill <- fill
      } else if ("fill" %in% names(data)) {
        # Inherit from aesthetic mapping (take first value, assumed constant per group)
        used_fill <- rep(data$fill[1], length(bin_density))
      } else {
        # Default to grey when no fill specified
        used_fill <- rep("grey20", length(bin_density))
      }

      # Return data frame with rectangle coordinates for GeomRect
      # Each row represents one histogram bar
      df <- data.frame(
        xmin = x_center,                          # Starting x position (group center)
        xmax = x_center + sign * width_vals,      # Ending x position (extends by bar width)
        ymin = h$breaks[-length(h$breaks)],       # Lower edge of each bin
        ymax = h$breaks[-1],                      # Upper edge of each bin
        y = mids,                                 # Bin midpoint (for potential reference)
        count = counts,                           # Raw count per bin
        density = bin_density,                    # Density value per bin
        fill = used_fill,                         # Fill color
        alpha = alpha,                            # Transparency
        colour = colour                           # Border color
      )

      df
    }
  )


  # Only pass fill parameter if explicitly provided by user, otherwise inherit from mapping
  hist_params <- list(
    bins = bins,
    binwidth = binwidth,
    width = width,
    linewidth = hist_linewidth,
    normalize = normalize,
    side = side,
    nudge = - nudge_value,        # Opposite direction from violin
    alpha = hist_alpha,
    colour = hist_color,
    na.rm = TRUE
  )
  if (!is.null(hist_fill)) hist_params$fill <- hist_fill
  if (hist_side_flip) {
    hist_params$nudge <- - hist_params$nudge
    hist_params$side <- if (side == "left") "right" else "left"
  }

  # Create histogram layer using the custom stat and GeomRect
  # Histogram is nudged in opposite direction from violin for visual separation
  hist_layer <- ggplot2::layer(
    stat = StatViolinhist,
    data = data,
    mapping = mapping,
    geom = ggplot2::GeomRect,
    position = "identity",
    inherit.aes = TRUE,
    params = hist_params
  )

  # Return both layers as a list (ggplot2 will combine them)
  list(violin_layer, hist_layer)
}
