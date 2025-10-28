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
