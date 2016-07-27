context("package list is valid")
test_that("package list is valid", {
	granSrcLoc <- system.file('gran_source_list.tsv',package = 'granbuild')
  expect_is(read_src_list(granSrcLoc,granSrcLoc),'data.frame')
})

context("package tags are valid")
test_that("package tags are valid", {
  
	expect_true(check_src_tags())
})

