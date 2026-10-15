#' Ny Carlsberg Glyptotek Color Palette
#'
#' This color palette is based on the colors from the walls of the Ny Calrsberg
#' Glyptotek in Copenhagen, Denmark.
#'
#' @include utils.R
#' @export
scale_color_glyptotek <- function(palette = "full",
                               discrete = TRUE,
                               reverse = FALSE,
                               aesthetics = "color",
                               ...) {
  .scale_color_engine(palette_glyptotek, palette, discrete, reverse, aesthetics, ...)
}



# Aliases ----------------------------------------------------------------------


#' @rdname scale_color_glyptotek
#' @export
scale_color_glyptotek_d <- function(palette = "full",
                                 discrete = TRUE,
                                 reverse = FALSE,
                                 aesthetics = "color",
                                 ...) {
  scale_color_glyptotek(
    palette = palette,
    discrete = discrete,
    reverse = reverse,
    aesthetics = aesthetics,
    ...
  )
}

#' @rdname scale_color_glyptotek
#' @export
scale_color_glyptotek_c <- function(palette = "full",
                                 discrete = FALSE,
                                 reverse = FALSE,
                                 aesthetics = "color",
                                 ...) {
  scale_color_glyptotek(
    palette = palette,
    discrete = discrete,
    reverse = reverse,
    aesthetics = aesthetics,
    ...
  )
}

#' @rdname scale_color_glyptotek
#' @export
scale_colour_glyptotek <- scale_color_glyptotek

#' @rdname scale_color_glyptotek
#' @export
scale_colour_glyptotek_c <- scale_color_glyptotek_c

#' @rdname scale_color_glyptotek
#' @export
scale_colour_glyptotek_d <- scale_color_glyptotek_d



# Fill --------------------------------------------------------------------



#' @rdname scale_color_glyptotek
#' @export
scale_fill_glyptotek <- function(palette = "full",
                              discrete = TRUE,
                              reverse = FALSE,
                              aesthetics = "fill",
                              ...) {
  .scale_fill_engine(palette_glyptotek, palette, discrete, reverse, aesthetics, ...)
}


#' @rdname scale_color_glyptotek
#' @export
scale_fill_glyptotek_d <- function(palette = "full",
                                discrete = TRUE,
                                reverse = FALSE,
                                aesthetics = "fill",
                                ...) {
  scale_fill_glyptotek(
    palette = palette,
    discrete = discrete,
    reverse = reverse,
    aesthetics = aesthetics,
    ...
  )
}

#' @rdname scale_color_glyptotek
#' @export
scale_fill_glyptotek_c <- function(palette = "full",
                                discrete = FALSE,
                                reverse = FALSE,
                                aesthetics = "fill",
                                ...) {
  scale_fill_glyptotek(
    palette = palette,
    discrete = discrete,
    reverse = reverse,
    aesthetics = aesthetics,
    ...
  )
}




# Palette ----------------------------------------------------------------------



glyptotek_colors_list <- c(
  `steelBlue`= "#1F2D3A",
  `chestnut` = "#582D24",
  `caramel` = "#BD8537",
  `sage` = "#686C5A"
)


#' Extract Glyptotek colors as Hex Codes
#'
#' Can be used to get the hex code of specific colors from the Ny Calrsberg
#' Glyptotek color palette.
#' Use `glyptotek_colors()` to see all available colors.
#'
#' @param ... Names of colors to extract.
#'
#' @return A character vector with color codes.
#'
#' @examples
#' glyptotek_colors()
#' glyptotek_colors("glyptotekBlue", "yellow1")
#'
#' @export
glyptotek_colors <- function(...) .extract_colors(glyptotek_colors_list, ...)

glyptotek_palettes <- list(
  `full` = glyptotek_colors()
)


#' Ny Carlsberg Glyptotek color palette
#'
#' @details This function is usually not called directly, but from within
#' [`scale_color_glyptotek()`][scale_color_glyptotek].
#'
#' @param palette A string specifying the palette name.
#' @param reverse Logical, whether to reverse the palette.
#' @param ... Additional arguments passed to other functions.
#'
#' @export
palette_glyptotek <- function(palette = "full", reverse = FALSE, ...) {
  .retrieve_palette(palette, glyptotek_palettes, reverse = reverse, ...)
}

# helpers moved to R/utils.R (.retrieve_palette, .scale_color_engine, .scale_fill_engine, .extract_colors)
