#' Borrows from makeDepGraph but works on package not yet built
#'
#' @param file DESCRIPTION file path
#' @param suggests include suggests
#' @param enhances include enhances
#' @param includeBasePkgs include base packges
#' @importFrom igraph make_empty_graph vertex edge
#' @importFrom miniCRAN makeDepGraph
#' @export
makeDepGraphFromDescription <- function(file, suggests = TRUE, enhances = FALSE, includeBasePkgs = FALSE) {
  depends <- NULL

  desc <- read.dcf(file)
  if (nrow(desc) == 1) {
    desc <- as.list(desc[1,])
  } else {
    stop("Invalid DESCRIPTION")
  }

  for (import in c("Imports", "Depends", "LinkingTo")) {
    depends <- rbind(depends, parse_deps(desc[[import]]))
  }
  if (suggests) {
    depends <- rbind(depends, parse_deps(desc[["Suggests"]]))
  }
  if (enhances) {
    depends <- rbind(depends, parse_deps(desc[["Enhances"]]))
  }

  pkgName <- desc[["Package"]]
  depGraph <- make_empty_graph() + vertex(pkgName)
  excludes <- c("R")
  # TODO deal with version issues?
  for (package in depends[["name"]]) {
    if (!package %in% excludes) {
      # TODO check here and recursively call this function if package is in gran list
      pkgGraph <- makeDepGraph(package, suggests = suggests,
                               enhances = enhances, includeBasePkgs = includeBasePkgs)
      depGraph <- depGraph + pkgGraph + edge(pkgName, package)
    }
  }
  return(depGraph)
}

#' Collapse dependency graph into list ordered from outside inward
#'
#' @param graph igraph object to collapse
#' @return list representing order in which to install dependencies
#' @importFrom igraph V degree delete_vertices
#' @export
collapseDepGraph <- function(graph) {
  depList <- list()
  # nodes with no "in" edges mean not depending on anything in graph
  leaves <- V(graph)[degree(graph, mode = "in") == 0]
  while (length(leaves) > 0) {
    depList <- append(depList, names(leaves))
    graph <- delete_vertices(graph, leaves)
    leaves <- V(graph)[degree(graph, mode = "in") == 0]
  }
  return(depList)
}

