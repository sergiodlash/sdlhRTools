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
#' @param bins Number of histogram bins, spanning the full range of the y
#'   scale. Default is 7. Ignored if `binwidth` is specified. Bins are shared
#'   by all groups, so bars line up across groups, as in
#'   [ggplot2::geom_histogram()].
#' @param binwidth Width of histogram bins. If specified, overrides `bins`.
#'   Bin edges are multiples of `binwidth`, which gives round, easy-to-read
#'   edges. Default is `NULL`.
#' @param width Maximum horizontal extent of the histogram bars in x-axis units.
#'   Default is 0.4.
#' @param scale How to scale groups relative to each other, applied to both the
#'   violin and the histogram (same options as [ggplot2::geom_violin()]):
#'   * `"area"` (default): every group has the same area, regardless of how
#'     many observations it has. The tallest bar in the panel reaches `width`.
#'   * `"count"`: areas are proportional to the number of observations, so
#'     smaller groups are drawn smaller. Bars are proportional to bin counts.
#'   * `"width"`: each group is scaled independently so its own peak reaches
#'     the maximum width.
#' @param violin_scale,hist_scale Override `scale` for only the violin or only
#'   the histogram. If `NULL` (default), they follow `scale`.
#' @param hist_fill Fill color for histogram bars. If `NULL` (default), inherits
#'   from the aesthetic mapping `aes(fill = ...)`. If no mapping exists,
#'   defaults to "grey20".
#' @param hist_alpha Transparency level for histogram bars. Default is 0.4.
#' @param hist_color Outline color for histogram bars. Default is `NA` (no outline).
#' @param hist_side_flip Logical. If `TRUE`, the histogram is drawn on the same
#'   side as the violin, not the opposite side. Default is `FALSE`.
#' @param hist_linewidth Line width for the histogram bar outlines, used
#'   together with `hist_color`. Default is 0.
#' @param show.legend Logical. Should the layers be included in the legend?
#'   `NA` (default) includes them if any aesthetics are mapped, `FALSE` never
#'   includes them and `TRUE` always does. Applied to both the violin and the
#'   histogram.
#' @param inherit.aes If `FALSE`, overrides the default aesthetics rather than
#'   combining with them. Applied to both the violin and the histogram.
#' @param ...Additional arguments passed to the violin layer (e.g., other
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
#' # Per-group scaling (each group's peak reaches full width)
#' ggplot(iris, aes(x = Species, y = Sepal.Width)) +
#'   geom_violinhist(scale = "width")
#'
#' # Scale by number of observations (groups with more data are larger)
#' ggplot(mtcars, aes(x = factor(cyl), y = mpg)) +
#'   geom_violinhist(scale = "count")
#'
#' # Different scaling for each half
#' ggplot(mtcars, aes(x = factor(cyl), y = mpg)) +
#'   geom_violinhist(scale = "count", hist_scale = "area")
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
                            scale = c("area", "count", "width"),
                            violin_scale = NULL,
                            hist_scale = NULL,
                            # histogram params
                            bins = 7,
                            binwidth = NULL,
                            width = 0.4,
                            hist_fill = NULL,
                            hist_alpha = 0.4,
                            hist_color = NA,
                            hist_side_flip = FALSE,
                            hist_linewidth = 0,
                            # layer params, shared by both halves
                            show.legend = NA,
                            inherit.aes = TRUE,
                            ...) {
  side <- match.arg(side)

  # Each half follows `scale` unless overridden individually
  scale_options <- c("area", "count", "width")
  scale <- match.arg(scale)
  violin_scale <- match.arg(if (is.null(violin_scale)) scale else violin_scale, scale_options)
  hist_scale <- match.arg(if (is.null(hist_scale)) scale else hist_scale, scale_options)

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
    position = ggplot2::position_nudge(nudge_value),
    flip = side == "left",
    scale = violin_scale,
    show.legend = show.legend,
    inherit.aes = inherit.aes
  )
  if (!is.null(fill)) violin_args$fill <- fill

  # Merge additional arguments passed via ... into violin layer
  extra_args <- list(...)
  if (length(extra_args)) violin_args <- c(violin_args, extra_args)

  violin_layer <- do.call(see::geom_violinhalf, violin_args)

  # Only pass fill parameter if explicitly provided by user, otherwise inherit from mapping
  hist_params <- list(
    bins = bins,
    binwidth = binwidth,
    width = width,
    linewidth = hist_linewidth,
    hist_scale = hist_scale,
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
    geom = GeomViolinhistRect,
    position = "identity",
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = hist_params
  )

  # Return both layers as a list (ggplot2 will combine them)
  list(violin_layer, hist_layer)
}

# Custom ggproto Stat for computing histogram bins and returning rectangle
# coordinates. Defined once at module scope (not inside geom_violinhist())
# since ggproto objects are meant to be built once and reused, not
# reconstructed on every call. This stat processes each group independently
# to create density-based histogram bars.
StatViolinhist <- ggplot2::ggproto(
  "StatViolinhist",
  ggplot2::Stat,
  required_aes = c("x", "y"),
  # bins and binwidth are consumed by compute_panel(), not compute_group().
  # ggplot2 only keeps compute_group() arguments when compute_panel() has
  # `...`, so add them explicitly or they are dropped before compute_panel()
  parameters = function(self, extra = FALSE) {
    c(ggplot2::ggproto_parent(ggplot2::Stat, self)$parameters(extra), "bins", "binwidth")
  },
  # Compute one set of breaks over the full y-scale range and share it across
  # all groups, so bins line up between groups (and between facets with fixed
  # scales), as in ggplot2::geom_histogram().
  # Then run compute_group() per group, and for hist_scale = "area" or "count"
  # rescale all bars against the panel-wide maximum so the tallest bar reaches
  # `width`. This makes bar widths independent of the units of y while keeping
  # groups comparable, like the violin's scale argument. hist_scale = "width"
  # is already handled per group in compute_group().
  compute_panel = function(self, data, scales, width = 0.4, hist_scale = "area", side = "right",
                           bins = 7, binwidth = NULL, ...) {
    breaks <- .violinhist_breaks(scales$y$dimension(), bins, binwidth)

    df <- ggplot2::ggproto_parent(ggplot2::Stat, self)$compute_panel(
      data, scales, width = width, hist_scale = hist_scale, side = side,
      breaks = breaks, ...
    )
    if (hist_scale == "width" || nrow(df) == 0) return(df)

    # "area": bars proportional to density (every group has the same area)
    # "count": bars proportional to bin counts (area grows with group size)
    value <- if (hist_scale == "count") df$count else df$density
    max_value <- max(value, na.rm = TRUE)
    if (is.finite(max_value) && max_value > 0) {
      sign <- if (side == "left") 1 else -1
      df$xmax <- df$xmin + sign * (value / max_value) * width
    }
    df
  },
  compute_group =function(data, scales, breaks, width = 0.4, hist_scale = "area", side = "right", nudge = 0) {
    y <- data$y
    x_center <- unique(data$x)
    if (length(x_center) > 1) x_center <- mean(x_center)

    # Apply horizontal nudge to histogram position (opposite direction from violin)
    x_center <- x_center + nudge

    # Compute histogram with the panel-wide breaks from compute_panel()
    h <- graphics::hist(y, breaks = breaks, plot = FALSE)
    counts <- h$counts
    mids <- h$mids
    binwidths <- diff(h$breaks)

    # Calculate density per bin: counts / (total_points × binwidth)
    # This gives a probability density (area under histogram = 1)
    npts <- sum(counts)
    bin_density <- counts / (npts * binwidths)

    # Convert density to bar widths (in x-axis units)
    # If hist_scale="width": scale so this group's maximum bar reaches full width
    # Otherwise: use raw density × width here; compute_panel() then rescales
    # against the panel-wide maximum density or count
    if (all(bin_density == 0)) {
      # No data: all bars have zero width
      width_vals <- rep(0, length(bin_density))
    } else if (hist_scale == "width") {
      # Per-group: scale to [0, width] range
      width_vals <- (bin_density / max(bin_density, na.rm = TRUE)) * width
    } else {
      # Raw density scaling: bars directly proportional to density
      width_vals <- bin_density * width
    }

    # Determine horizontal direction for histogram bars
    # If violin is on left, histogram extends right (positive)
    # If violin is on right, histogram extends left (negative)
    sign <- if (side == "left") 1 else -1

    # Return data frame with rectangle coordinates for GeomRect
    # Each row represents one histogram bar. Fill, alpha and colour must not be
    # set here: hist_fill/hist_alpha/hist_color are applied by ggplot2 as fixed
    # aesthetics, a mapped fill is carried over from the group data, and the
    # grey default comes from GeomViolinhistRect. A colour written here would
    # be trained by the fill scale and show up as an extra legend entry
    # whenever fill is mapped and hist_fill is set
    df <- data.frame(
      xmin = x_center,                          # Starting x position (group center)
      xmax = x_center + sign * width_vals,      # Ending x position (extends by bar width)
      ymin = h$breaks[-length(h$breaks)],       # Lower edge of each bin
      ymax = h$breaks[-1],                      # Upper edge of each bin
      y = mids,                                 # Bin midpoint (for potential reference)
      count = counts,                           # Raw count per bin
      density = bin_density                     # Density value per bin
    )

    # Drop empty bins: shared breaks span the whole y range, so groups get
    # empty bins outside their own range, which would otherwise be drawn as
    # zero-width rectangles (visible as a line when hist_color is set)
    df[df$count > 0, , drop = FALSE]
  }
)

# GeomRect with a dark grey default fill for the histogram bars, used when
# fill is neither mapped nor set with hist_fill
GeomViolinhistRect <- ggplot2::ggproto(
  "GeomViolinhistRect",
  ggplot2::GeomRect,
  default_aes = local({
    default_aes <- ggplot2::GeomRect$default_aes
    default_aes$fill <- "grey20"
    default_aes
  })
)

# Histogram breaks over the y-scale range: edges at multiples of `binwidth` if
# given, otherwise exactly `bins` equal-width bins
.violinhist_breaks <- function(range, bins, binwidth) {
  if (!is.null(binwidth) && is.finite(binwidth) && binwidth > 0) {
    start <- floor(range[1] / binwidth) * binwidth
    end <- ceiling(range[2] / binwidth) * binwidth

    # Handle edge case where all values are identical
    if (start == end) {
      start <- start - binwidth
      end <- end + binwidth
    }

    # Build from an integer count, not seq(by = ), so floating-point error
    # can't drop the last break below the data maximum
    n <- round((end - start) / binwidth)
    return(start + binwidth * (0:n))
  }

  # Handle edge case where all values are identical
  if (range[1] == range[2]) range <- range + c(-0.5, 0.5)
  seq(range[1], range[2], length.out = bins + 1)
}
