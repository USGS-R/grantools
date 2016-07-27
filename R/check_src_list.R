#' Checks for package file to exist in one location - if it does, it compares it to a known file and
#' returns the packages that need to be updated.  Otherwise it returns the entire known list.
#' @param checkPath character File path to the build list, generally either in src/contrib or bin/...
#' @param defaultPath character path to file to compare checkPath to, or use if checkPath does not exist
#' @import utils
#' @export
read_src_list <- function(checkPath, defaultPath){
	
	new <- read.table(defaultPath, sep='\t', header=TRUE,stringsAsFactors=FALSE)
	new$tag <- checkVs(new$tag)
	if(file.exists(checkPath)){
	  currentBuild <- read.table(checkPath, sep='\t', header=TRUE,stringsAsFactors=FALSE)
	  currentBuild$tag <- checkVs(currentBuild$tag)
	  newTaggedVersions <- findNotMatched(new,currentBuild)
	  
	  print("New packages to build:")
	  print(newTaggedVersions)
	  return(newTaggedVersions)
	  
	} else {
	  print("New packages to build:")
	  print(new)
	  return(new)
	}
}

#' check gran_src_tags
#' 
#' checks package tags for validity
#' 
#' @importFrom httr HEAD
#' @export
check_src_tags <- function(){
	
	packages = read_src_list(defaultPath = './inst/gran_source_list.tsv', checkPath = 'notApath')
	
	for(i in 1:nrow(packages)){
		url <- paste0('http://github.com/', packages$package[i], '/archive/', packages$tag[i], '.zip')
		r <- HEAD(url)
		if (r$status_code != 200)
			stop(url,'returned status code',r$status_code)
	}
	return(TRUE)
}

#' checks two data frames and returns rows in 1 that aren't matched in 2
#' modified from \url{http://www.r-bloggers.com/identifying-records-in-data-frame-a-that-are-not-contained-in-data-frame-b-%E2%80%93-a-comparison/}
#' 
findNotMatched <- function(x.1,x.2){
  #remove repo and slash from package name
  x.1p <- sub(".*\\/","",toupper(do.call("paste", x.1)))
  x.2p <- sub(".*\\/","",toupper(do.call("paste", x.2)))
  ret <- x.1[! x.1p %in% x.2p, ]
  return(ret)
}

#' checks if "v" is appended in a column of version numbers, and adds it if it is not
#' @param input character 
#' 
checkVs <- function(input){
  noV <- tolower(substr(input,1,1))!="v" 
  input[noV] <- paste0("v",input[noV])
  return(input)
}

