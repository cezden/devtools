#' Attempts to install a package directly from github.
#'
#' This function is vectorised so you can install multiple packages in 
#' a single command.
#'
#' @param username Github username
#' @param repo Repo name
#' @param ref Desired git reference. Could be a commit, tag, or branch
#'   name. Defaults to \code{"master"}.
#' @param pull Desired pull request. A pull request refers to a branch,
#'   so you can't specify both \code{branch} and \code{pull}; one of
#'   them must be \code{NULL}.
#' @param subdir subdirectory within repo that contains the R package.
#' @param branch Deprecated. Use \code{ref} instead.
#' @param ... Other arguments passed on to \code{\link{install}}.
#' @export
#' @family package installation
#' @examples
#' \dontrun{
#' install_github("roxygen")
#' }
install_github <- function(repo, username = getOption("github.user"),
  ref = "master", pull = NULL, subdir = NULL, branch = NULL, ...) {

  if (!is.null(branch)) {
    warning("'branch' is deprecated. In the future, please use 'ref' instead.")
    ref <- branch
  }
  if (!xor(is.null(pull), is.null(ref))) {
    stop("Must specify either a ref or a pull request, not both. ",
     "Perhaps you want to use 'ref=NULL'?")
  }
  if(!is.null(pull)) {
    pullinfo <- github_pull_info(repo, username, pull)
    username <- pullinfo$username
    ref <- pullinfo$ref
  }

  message("Installing github repo(s) ", 
    paste(repo, ref, sep = "/", collapse = ", "),
    " from ", 
    paste(username, collapse = ", "))
  name <- paste(username, "-", repo, sep = "")
  
  url <- paste("https://github.com/", username, "/", repo,
    "/zipball/", ref, sep = "")

  install_url(url, paste(repo, ".zip", sep = ""), subdir = subdir, ...)
}

# Retrieve the username and ref for a pull request
github_pull_info <- function(repo, username, pull) {
  host <- "https://api.github.com"
  # GET /repos/:user/:repo/pulls/:number
  path <- paste("repos", username, repo, "pulls", pull, sep = "/")
  r <- GET(host, path = path)
  stop_for_status(r)
  head <- parsed_content(r)$head

  list(repo = head$repo$name, username = head$repo$owner$login,
    ref = head$ref)
}
