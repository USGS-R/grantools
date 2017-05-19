#' checkNumbers
#' 
#' check that number of packages on the repo matches gran_source_list.tsv
#' 
#' @export
checkNumbers <- function(){
  srcList <- read.table(system.file("gran_source_list.tsv",package = "granbuild"),
                        stringsAsFactors = FALSE, header = TRUE)
  
  onGRAN <- available.packages(contriburl = contrib.url('https://owi.usgs.gov/R'))
  
  if(nrow(onGRAN) != nrow(srcList)){
    stop("Number of packages available on GRAN does not match the source list")
  }
  
  onGRAN.win <- readLines('https://owi.usgs.gov/R/bin/windows/contrib/3.4/PACKAGES')
  onGRAN.win <- length(grep(pattern = "Package: ", onGRAN.win, fixed = TRUE))
  
  if(onGRAN.win != nrow(srcList)){
    stop("Number of Windows 3.4 packages available on GRAN does not match the source list")
  }
  
  onGRAN.win <- readLines('https://owi.usgs.gov/R/bin/windows/contrib/3.3/PACKAGES')
  onGRAN.win <- length(grep(pattern = "Package: ", onGRAN.win, fixed = TRUE))
  
  if(onGRAN.win != nrow(srcList)){
    stop("Number of Windows 3.3 packages available on GRAN does not match the source list")
  }
  
}