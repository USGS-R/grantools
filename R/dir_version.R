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

set_version <- function(version){
  system(sprintf('ln -sfhv /Library/Frameworks/R.framework/Versions/%s /Library/Frameworks/R.framework/Versions/Current', version))
}