
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sdlhRTools: Personal package with custom functions for data visualization and analysis.

<!-- badges: start -->

<!-- badges: end -->

The R package *sdlhRTools* aims to collect in a single place auxiliary
functions and customized data visualization tools that I use frequently
when working with R. This package was born with the intention of
personal use, but I try to keep and mantain a consistent and
comprehensive documentation.

This is work continuously changing and under development. I welcome
feedback, contributions and suggestions from users who may find anything
useful here.

# Installation

The development version of this package is available to install from
GitHub.

| Type        | Source | Command                                             |
|-------------|--------|-----------------------------------------------------|
| Development | GitHub | `remotes::install_github("sergiodlash/sdlhRTools")` |

Once the installation is complete, you can load the package in your R
scripts by using:

``` r
library(sdlhRTools)
```

If you encounter any issues or have suggestions, please feel free to
open an issue on the GitHub repository.

# Examples

## Themes

### sdlh

## Color Palettes

### Paimio Sanatorium

Color palette inspired in the Paimio Sanatorium by architect Alvar Aalto
in Finland.

``` r
library(tidyverse)
#> ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
#> ✔ dplyr     1.1.4     ✔ readr     2.1.5
#> ✔ forcats   1.0.0     ✔ stringr   1.5.1
#> ✔ ggplot2   3.5.2     ✔ tibble    3.2.1
#> ✔ lubridate 1.9.4     ✔ tidyr     1.3.1
#> ✔ purrr     1.0.4     
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point() +
  labs(
    title = "Scatter Plot of Sepal Length vs Sepal Width",
    x = "Sepal Length",
    y = "Sepal Width"
  ) +
  scale_color_paimio(palette = "full", reverse = TRUE) +
  theme_sdlh()
```

<img src="man/figures/README-paimio-1.png" width="90%" />

### Ny Carlsberg Glyptotek

Color palette inspired in the Ny Calrsberg Glyptotek in Copenhagen.

``` r
ggplot(iris, aes(x = Species, y = Sepal.Width, fill = Species, color= Species)) +
  geom_violin( linewidth = 0) +
  geom_dotplot(binaxis = 'y', stackdir = 'center', fill = "white", dotsize = 0.8, binwidth = 0.07)+
  labs(
    title = "Violin Plot of Sepal Width by Species",
    x = "Species",
    y = "Sepal Width"
  ) +
  scale_fill_glyptotek()+
  scale_color_glyptotek()+
  theme_sdlh()
```

<img src="man/figures/README-glyptotek-1.png" width="90%" />
