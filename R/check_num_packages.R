#check that number of packages on the repo matches gran_source_list.tsv


srcList <- read.table(system.file("gran_source_list.tsv",package = "granbuild"),
                      stringsAsFactors = FALSE, header = TRUE)

onGRAN <- available.packages(contriburl = contrib.url('https://owi.usgs.gov/R'))

if(nrow(onGRAN) != nrow(srcList)){
  error("Number of packages available on GRAN does not match the source list")
}