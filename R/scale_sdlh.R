#' sdlh color palettes
#'
#' A named list of color palettes, each a named character vector of hex codes.
#' Colors are listed in the order discrete scales use them.
#'
#' * `paimio`: Paimio Sanatorium by architect Alvar Aalto
#'   (\url{https://paimiosanatorium.com/}), 10 colors.
#' * `paimio_contrast`: four high-contrast colors from `paimio`.
#' * `glyptotek`: Ny Carlsberg Glyptotek in Copenhagen, 4 colors.
#'
#' @format A named list of named character vectors.
#'
#' @examples
#' names(sdlh_palettes)
#' sdlh_palettes$paimio
#' sdlh_palettes$paimio[c("paimioBlue", "yellow1")]
#'
#' @export
sdlh_palettes <- list(
  paimio = c(
    yellow1 = "#E1D059",
    yellow2 = "#EECE5B",
    lightOrange = "#BD7A3B",
    darkOrange = "#B6633E",
    green = "#548665",
    paimioBlue = "#268FA0",
    greyGreen = "#B1C1B0",
    grey = "#E2E1D0",
    beige1 = "#CDD1B6",
    beige2 = "#D4D2B4"
  ),
  paimio_contrast = c(
    yellow1 = "#E1D059",
    darkOrange = "#B6633E",
    green = "#548665",
    paimioBlue = "#268FA0"
  ),
  glyptotek = c(
    steelBlue = "#1F2D3A",
    chestnut = "#582D24",
    caramel = "#BD8537",
    sage = "#686C5A"
  )
)


#' Get colors from an sdlh palette
#'
#' Returns `n` colors from one of the [sdlh_palettes]. Discrete palettes use
#' the palette colors as they are, in order. Continuous palettes interpolate
#' between them.
#'
#' @param palette Palette name, one of `names(sdlh_palettes)`.
#' @param n Number of colors. Defaults to all colors in the palette.
#' @param type `"discrete"` (default) or `"continuous"`.
#' @param reverse Logical. If `TRUE`, reverse the color order.
#'
#' @return A character vector of hex codes.
#'
#' @examples
#' sdlh_palette("glyptotek")
#' sdlh_palette("paimio", 3)
#' sdlh_palette("paimio_contrast", 50, type = "continuous")
#'
#' @export
sdlh_palette <- function(palette,
                         n,
                         type = c("discrete", "continuous"),
                         reverse = FALSE) {
  palette <- match.arg(palette, names(sdlh_palettes))
  type <- match.arg(type)
  pal <- unname(sdlh_palettes[[palette]])

  if (reverse) pal <- rev(pal)
  if (missing(n)) n <- length(pal)

  if (type == "continuous") {
    return(grDevices::colorRampPalette(pal)(n))
  }

  if (n > length(pal)) {
    stop(
      sprintf(
        paste(
          "Palette `%s` has %d colors, but %d are needed.",
          "Use a continuous scale or a larger palette."
        ),
        palette, length(pal), n
      ),
      call. = FALSE
    )
  }

  pal[seq_len(n)]
}


#' sdlh color scales for ggplot2
#'
#' Color and fill scales using the [sdlh_palettes]. Use the `_d` scales for
#' discrete data and the `_c` scales for continuous data.
#'
#' @inheritParams sdlh_palette
#' @param ... Other arguments passed to [ggplot2::discrete_scale()] (`_d`) or
#'   [ggplot2::scale_colour_gradientn()] (`_c`), such as `name` or `limits`.
#'
#' @return A ggplot2 scale.
#'
#' @examples
#' library(ggplot2)
#'
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point() +
#'   scale_color_sdlh_d("paimio_contrast")
#'
#' ggplot(faithfuld, aes(waiting, eruptions, fill = density)) +
#'   geom_raster() +
#'   scale_fill_sdlh_c("glyptotek", reverse = TRUE)
#'
#' @name scale_sdlh
NULL

#' @rdname scale_sdlh
#' @export
scale_color_sdlh_d <- function(palette, reverse = FALSE, ...) {
  ggplot2::discrete_scale(
    aesthetics = "colour",
    palette = function(n) sdlh_palette(palette, n, "discrete", reverse),
    ...
  )
}

#' @rdname scale_sdlh
#' @export
scale_color_sdlh_c <- function(palette, reverse = FALSE, ...) {
  ggplot2::scale_colour_gradientn(
    colours = sdlh_palette(palette, 256, "continuous", reverse),
    ...
  )
}

#' @rdname scale_sdlh
#' @export
scale_fill_sdlh_d <- function(palette, reverse = FALSE, ...) {
  ggplot2::discrete_scale(
    aesthetics = "fill",
    palette = function(n) sdlh_palette(palette, n, "discrete", reverse),
    ...
  )
}

#' @rdname scale_sdlh
#' @export
scale_fill_sdlh_c <- function(palette, reverse = FALSE, ...) {
  ggplot2::scale_fill_gradientn(
    colours = sdlh_palette(palette, 256, "continuous", reverse),
    ...
  )
}

#' @rdname scale_sdlh
#' @export
scale_colour_sdlh_d <- scale_color_sdlh_d

#' @rdname scale_sdlh
#' @export
scale_colour_sdlh_c <- scale_color_sdlh_c
