#' check gran_src_list against current builds to find packages that need updated
#' 
#' checks list of packages for validity
#' @param path character If a path is supplied, function will read that file and check \code{gran_source_list.tsv} against it.
#' Packages/versions in \code{gran_source_list} that are not matched in the supplied file will be returned.  Defaults to \code{NULL}
#' where the entire \code{gran_source_list} is returned.
#' 
#' @export
read_src_list <- function(path = NULL){
	
	new <- read.table(system.file('gran_source_list.tsv',package='granbuild'), sep='\t', header=TRUE,stringsAsFactors=FALSE)
	new$tag <- checkVs(new$tag)#column names case sensitive?
	if(!is.null(path)){
	  currentBuild <- read.table(path, sep='\t', header=TRUE,stringsAsFactors=FALSE)
	  currentBuild$Version <- checkVs(currentBuild$Version)
	  return(findNotMatched(new,currentBuild))
	} else {
	  return(new)
	}
	
  
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

#' checks two data frames and returns rows in 1 that aren't matched in 2
#' from \url{http://www.r-bloggers.com/identifying-records-in-data-frame-a-that-are-not-contained-in-data-frame-b-%E2%80%93-a-comparison/}
#' 
#' @import 
#' 

findNotMatched <- function(x.1,x.2){
  x.1p <- toupper(do.call("paste", x.1))
  x.2p <- toupper(do.call("paste", x.2))
  ret <- x.1[! x.1p %in% x.2p, ]
  return(ret)
}

#' checks if "v" is appended in a column of version numbers, and adds it if it is not
#' @param input character 
#' @import
#' 
checkVs <- function(input){
  noV <- tolower(substr(input,1,1))!="v" 
  input[noV] <- paste0("v",input[noV])
  return(input)
}