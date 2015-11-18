#' @export
build_GRAN_all <- function(versions){
	
	os = Sys.info()['sysname']
	if (os == 'Darwin'){
		for (version in versions){
			system(sprintf('ln -sfhv /Library/Frameworks/R.framework/Versions/%s /Library/Frameworks/R.framework/Versions/Current', version))
			system("Rscript -e 'library(granbuild);dl_build_src();dl_build_bin()'")
		}
	} else {
		message(os, 'not configured for version switching')
	}

	invisible()
}