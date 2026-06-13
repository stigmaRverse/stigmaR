# R/stigmaR-package.R

#' @keywords internal
#' @import dplyr
#' @importFrom stats setNames
#' @importFrom utils packageVersion
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

# `composite` and `items` are lazy-loaded package datasets (see R/data.R)
# referenced directly inside stigmaR(), item_stigmaR(), and cust_stigmaR().
# Declare them here so R CMD check doesn't flag them as undefined globals.
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c("composite", "items"))
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "\nPlease cite:",
    "\n  Kim, S. & Todd, N. R. (2027). stigmaR: Enhancing Accessibility,",
    "\n  Reproducibility, and Transparency of Structural Stigma Research.",
    "\n"
  )
}
