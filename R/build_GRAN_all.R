#' build all src and binaries for specified versions of R
#' 
#' builds binaries using \code{\link{dl_build_src}} and \code{\link{build_bin}} for 
#' each of the versions specified with the \code{versions} parameter.
#' 
#' @param versions character vector of R major.minor versions (e.g., '3.2').
#' @importFrom utils compareVersion
#' @examples 
#' \dontrun{
#' build_GRAN_all(c('3.2','3.3'))
#' }
#' @export
build_GRAN_all <- function(versions){
	
	os = Sys.info()['sysname']
	if (os == 'Darwin'){
	  orig.version = dir_version()
	  if(length(versions) > 1 && compareVersion(versions[1], versions[2]) == -1){
	    stop("Currently only building source for 3.3, so 3.3 needs to build first")
	  } 
	  for (version in versions){
		  set_version(version)
	    if(version == "3.2") {
	      system("Rscript -e 'library(granbuild); build_bin()'")
	    } else {
	      system("Rscript -e 'library(granbuild); dl_build_src(); build_bin()'")
	    }
		}
	  #reset version 
	  set_version(orig.version)
	} else {
		message(os, 'not configured for version switching')
	}
  
	
	
	invisible()
}