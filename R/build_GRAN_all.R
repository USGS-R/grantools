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
	.Deprecated(new = "shell script inst/mac_build.sh")
	os = Sys.info()['sysname']
	if (os == 'Darwin'){
	  orig.version = dir_version()
	  versions <- versions[order(as.numeric(versions), decreasing = TRUE)]
	  for (i in 1:length(versions)){
		  set_version(versions[i])
	    #only build source for latest version
	    if(i == 1) {
	      system("Rscript -e 'library(granbuild); dl_build_src(); build_bin()'")
	    } else {
	      system("Rscript -e 'library(granbuild);  build_bin()'")
	    }
		}
	  #reset version 
	  set_version(orig.version)
	} else {
		message(os, 'not configured for version switching')
	}
  
	
	
	invisible()
}