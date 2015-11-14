#' check gran_src_list
#' 
#' checks list of packages for validity
#' 
#' 
#' @export
read_src_list <- function(){
	
	return(read.table(system.file('gran_source_list.tsv',package='granbuild'), sep='\t', header=TRUE,stringsAsFactors=FALSE))
	
}

#' check gran_src_tags
#' 
#' checks package tags for validity
#' 
#' 
#' @export
check_src_tags <- function(){
	
	packages = read_src_list()
	
	for(i in 1:nrow(packages)){
		url <- paste0('http://github.com/', packages$package[i], '/archive/', packages$tag[i], '.zip')
		r <- HEAD(url)
		if (r$status_code != 200)
			stop(url,'returned status code',r$status_code)
	}
	return(TRUE)
}