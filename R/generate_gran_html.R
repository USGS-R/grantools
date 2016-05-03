#' @title Generate GRAN package index and html sites
#' 
#' @description 
#' There are many ways to do this:
#' 1. \url{http://watson.nci.nih.gov/bioc_mirror/packages/release/bioc/vignettes/biocViews/inst/doc/createReposHtml.pdf}|
#' 2. https://github.com/hadley/staticdocs
#' 3. Rd2HTML (maybe?)
#' 4. install.packages('biocViews', repos = c('http://bioconductor.org/packages/release/bioc', 'http://cran.rstudio.com'))
#' 
#' 
#' @import biocViews
#' 
#' @export
generate_gran_html = function(GRAN.dir='./GRAN'){
	
	contribPaths <- c(source="src/contrib",
		win64.binary="bin/windows/contrib/3.2",
		mac.binary.mavericks="bin/macosx/mavericks/contrib/3.2")
	
	extractVignettes(GRAN.dir, contribPaths["source"])
	genReposControlFiles(GRAN.dir, contribPaths)
	
	writeRepositoryHtml(GRAN.dir, title='GRAN')
	
	
}

