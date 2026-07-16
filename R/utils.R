## Internal utility helpers

#' Internal: retrieve a palette function from a named list
#'
#' This helper replaces external heavy dependencies for simple string
#' formatting and warnings. It's internal only and not exported.
#' @noRd
.retrieve_palette <- function(palette, palette_list, reverse = FALSE, ...) {
  names_available <- names(palette_list)

  if (!palette %in% names_available) {
    # format available names as `a`, `b` or `c`
    if (length(names_available) == 1) {
      names_msg <- paste0("`", names_available, "`")
    } else {
      last <- paste0("`", names_available[length(names_available)], "`")
      if (length(names_available) > 2) {
        first_part <- paste0("`", names_available[-length(names_available)], "`", collapse = ", ")
        names_msg <- paste0(first_part, " or ", last)
      } else {
        names_msg <- paste0("`", names_available[1], "` or ", last)
      }
    }

    warning(
      sprintf(
        "Palette name not available. `palette` must be one of %s. Using default palette now.",
        names_msg
      ),
      call. = FALSE
    )

    palette <- 1
  }

  pal <- palette_list[[palette]]

  if (isTRUE(reverse)) pal <- rev(pal)

  grDevices::colorRampPalette(pal, ...)
}

#' Internal: shared implementation behind `glyptotek_colors()`, `paimio_colors()`, etc.
#' @noRd
.extract_colors <- function(colors_list, ...) {
  cols <- c(...)
  if (is.null(cols)) return(colors_list)
  colors_list[cols]
}

#' Internal: shared engine behind the `scale_color_*()` family
#' @noRd
.scale_color_engine <- function(palette_fn, palette, discrete, reverse, aesthetics, ...) {
  pal <- palette_fn(palette = palette, reverse = reverse)

  if (discrete) {
    ggplot2::discrete_scale(aesthetics = aesthetics, palette = pal, ...)
  } else {
    ggplot2::scale_color_gradientn(colours = pal(256), aesthetics = aesthetics)
  }
}

#' Internal: shared engine behind the `scale_fill_*()` family
#' @noRd
.scale_fill_engine <- function(palette_fn, palette, discrete, reverse, aesthetics, ...) {
  pal <- palette_fn(palette = palette, reverse = reverse)

  if (discrete) {
    ggplot2::discrete_scale(aesthetics = aesthetics, palette = pal, ...)
  } else {
    ggplot2::scale_fill_gradientn(colours = pal(256), aesthetics = aesthetics, ...)
  }
}
