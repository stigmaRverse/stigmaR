# R/stigmaR-package.R

#' @keywords internal
#' @import dplyr
#' @importFrom stats setNames
#' @importFrom utils packageVersion
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "\nPlease cite:",
    "\n  Kim, S. & Todd, N. R. (2027). stigmaR: Enhancing Accessibility,",
    "\n  Reproducibility, and Transparency of Structural Stigma Research.",
    "\n"
  )
}
