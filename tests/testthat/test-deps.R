context("dependencies can be sorted out")
test_that("DESCRIPTION results in graph", {
  file <- system.file("DESCRIPTION", package = packageName())
  deps <- makeDepGraphFromDescription(file)
  vertices <- V(deps)
  expect_equal(length(vertices["granbuild"]), 1)
  expect_equal(length(vertices["devtools"]), 1)
  expect_equal(length(vertices["jsonlite"]), 1)
  expect_equal(length(vertices["miniCRAN"]), 1)
  expect_error(vertices["does_not_exist"])
})

test_that("suggests don't need to be included", {
  file <- system.file("DESCRIPTION", package = packageName())
  depsWithoutSuggests <- makeDepGraphFromDescription(file, suggests = FALSE)
  vertices <- V(depsWithoutSuggests)
  expect_equal(length(vertices["granbuild"]), 1)
  expect_equal(length(vertices["miniCRAN"]), 1)
  expect_error(vertices["roxygen2"])
  expect_error(vertices["testthat"])
  expect_error(vertices["knitr"])
})

test_that("dependency graph collapses properly", {
  file <- system.file("DESCRIPTION", package = packageName())
  deps <- makeDepGraphFromDescription(file, suggests = FALSE)
  collapsed <- collapseDepGraph(deps)
  # last one should be this package
  expect_equal(collapsed[[length(collapsed)]], "granbuild")
  # mime comes before httr
  expect_lt(grep("mime", collapsed), grep("httr", collapsed))
})
