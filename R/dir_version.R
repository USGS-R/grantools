#' get directory version of R
#' 
#' Version of R as major.minor for current. As character.
#' 
#' @examples 
#' dir_version()
#' @export
dir_version <- function(){
  return(substr(paste0(R.Version()$major, '.', R.Version()$minor), 0, 3))
  
}


#' set directory version of R
#' 
#' Set version of R as major.minor for current. As character.
#' 
#' @param version the major.minor version to use
#' 
#' @examples 
#' \dontrun{
#' dir_version()
#' set_version('3.3')
#' }
#' @export
set_version <- function(version){
	
	os = Sys.info()['sysname']
	if (os == 'Darwin'){
		current.pointer <- '/Library/Frameworks/R.framework/Versions/Current'
		set.dir <- sprintf('/Library/Frameworks/R.framework/Versions/%s', version)
		if (dir.exists(set.dir))
			system(sprintf('ln -sfhv %s %s', set.dir, current.pointer))
		else 
			warning(set.dir, ' does not exist.', call. = FALSE)
	} else {
		message('os ', os, ' is not currently supported')
	}
}