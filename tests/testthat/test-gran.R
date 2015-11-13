context("package list is valid")
test_that("package list is valid", {
	expect_is(read_src_list(),'data.frame')
})

context("package tags are valid")
test_that("package tags are valid", {
  
	expect_is(read_src_list(),'data.frame')
})

