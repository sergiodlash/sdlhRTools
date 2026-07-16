#' Paimio Sanatorium Color Palette
#'
#' This color palette is based on the colors from the Paimio Sanatorium
#' (\url{https://paimiosanatorium.com/}] by architect Alvar Aalto.
#'
#'
#' @include utils.R
#' @export
scale_color_paimio <- function(palette = "full",
                               discrete = TRUE,
                               reverse = FALSE,
                               aesthetics = "color",
                               ...) {
  .scale_color_engine(palette_paimio, palette, discrete, reverse, aesthetics, ...)
}



# Aliases ----------------------------------------------------------------------


#' @rdname scale_color_paimio
#' @export
scale_color_paimio_d <- function(palette = "full",
                                 discrete = TRUE,
                                 reverse = FALSE,
                                 aesthetics = "color",
                                 ...) {
  scale_color_paimio(
    palette = palette,
    discrete = discrete,
    reverse = reverse,
    aesthetics = aesthetics,
    ...
  )
}

#' @rdname scale_color_paimio
#' @export
scale_color_paimio_c <- function(palette = "full",
                                 discrete = FALSE,
                                 reverse = FALSE,
                                 aesthetics = "color",
                                 ...) {
  scale_color_paimio(
    palette = palette,
    discrete = discrete,
    reverse = reverse,
    aesthetics = aesthetics,
    ...
  )
}

#' @rdname scale_color_paimio
#' @export
scale_colour_paimio <- scale_color_paimio

#' @rdname scale_color_paimio
#' @export
scale_colour_paimio_c <- scale_color_paimio_c

#' @rdname scale_color_paimio
#' @export
scale_colour_paimio_d <- scale_color_paimio_d



# Fill --------------------------------------------------------------------



#' @rdname scale_color_paimio
#' @export
scale_fill_paimio <- function(palette = "full",
                              discrete = TRUE,
                              reverse = FALSE,
                              aesthetics = "fill",
                              ...) {
  .scale_fill_engine(palette_paimio, palette, discrete, reverse, aesthetics, ...)
}


#' @rdname scale_color_paimio
#' @export
scale_fill_paimio_d <- function(palette = "full",
                                discrete = TRUE,
                                reverse = FALSE,
                                aesthetics = "fill",
                                ...) {
  scale_fill_paimio(
    palette = palette,
    discrete = discrete,
    reverse = reverse,
    aesthetics = aesthetics,
    ...
  )
}

#' @rdname scale_color_paimio
#' @export
scale_fill_paimio_c <- function(palette = "full",
                                discrete = FALSE,
                                reverse = FALSE,
                                aesthetics = "fill",
                                ...) {
  scale_fill_paimio(
    palette = palette,
    discrete = discrete,
    reverse = reverse,
    aesthetics = aesthetics,
    ...
  )
}




# Palette ----------------------------------------------------------------------



paimio_colors_list <- c(
  `yellow1` = "#E1D059",
  `yellow2` = "#EECE5B",
  `lightOrange` = "#BD7A3B",
  `darkOrange` = "#B6633E",
  `green` = "#548665",
  `paimioBlue` = "#268FA0",
  `greyGreen` = "#B1C1B0",
  `grey` = "#E2E1D0",
  `beige1` = "#CDD1B6",
  `beige2` = "#D4D2B4"
)


#' Extract Paimio colors as Hex Codes
#'
#' Can be used to get the hex code of specific colors from the Paimio Sanatorium
#' color palette.
#' Use `paimio_colors()` to see all available colors.
#'
#' @param ... Names of colors to extract.
#'
#' @return A character vector with color codes.
#'
#' @examples
#' paimio_colors()
#' paimio_colors("paimioBlue", "yellow1")
#'
#' @export
paimio_colors <- function(...) .extract_colors(paimio_colors_list, ...)

paimio_palettes <- list(
  `full` = paimio_colors(),
  `contrast` = paimio_colors("yellow1", "darkOrange", "green", "paimioBlue")
)


#' Paimio Sanatorium color palette
#'
#' @details This function is usually not called directly, but from within
#' [`scale_color_paimio()`][scale_color_paimio].
#'
#' @param palette A string specifying the palette name.
#' @param reverse Logical, whether to reverse the palette.
#' @param ... Additional arguments passed to other functions.
#'
#' @export
palette_paimio <- function(palette = "full", reverse = FALSE, ...) {
  .retrieve_palette(palette, paimio_palettes, reverse = reverse, ...)
}

# helpers moved to R/utils.R (.retrieve_palette, .scale_color_engine, .scale_fill_engine, .extract_colors)
