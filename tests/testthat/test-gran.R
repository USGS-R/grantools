context("package list is valid")
test_that("package list is valid", {
	granSrcLoc <- './inst/gran_source_list.tsv'
  expect_is(read_src_list(granSrcLoc,granSrcLoc),'data.frame')
})

context("package tags are valid")
test_that("package tags are valid", {
  
	expect_true(check_src_tags())
})

