#' download and build packages w/ deps
#' 
#' Download and build GRAN packages w/ GRAN and CRAN deps
#' 
#' @param GRAN.dir local directory for GRAN built packages
#' @param returnPackageMods logical If \code{TRUE}, a data frame of packages that were downloaded and rebuilt is returned.  
#' @param version character current version building sources for
#' @import httr devtools
#' @export
dl_build_src <- function(version,GRAN.dir = './GRAN', returnPackageMods = TRUE){
	repos=c(CRAN="http://cran.rstudio.com/", USGS='http://owi.usgs.gov/R')
	
	
	################################################################################
	## These options may need to be edited for your local system
	## we try to infer the rest
	################################################################################
	src_dir = file.path(GRAN.dir, 'src', 'contrib')
	################################################################################
	## /options
	################################################################################
	
	##Update all the local packages so we're always working with the latest
	update.packages(ask=FALSE, lib.loc = Sys.getenv('R_LIBS_USER'), repos=repos)
	
	#current packages on GRAN
	currentListPath <- "./granCurrent.tsv"
	packages = read_src_list(currentListPath)
	
	#unlink(file.path(GRAN.dir, 'src'), recursive=TRUE)   #need to delete only updated directories
	#dir.create(src_dir, recursive = TRUE)
	toDelete <-  sub(".*\\/","",packages$package)
	if(dir.exists(file.path(GRAN.dir, 'src'))){
	  system(paste("rm",paste0(paste0(src_dir,"/",toDelete,"*"),collapse=" "))) #delete any existing version of toDelete packages
	}else{
	  dir.create(src_dir, recursive = TRUE)
	}
	
	scratch = tempdir()
	all_deps = data.frame()
	
	for(i in 1:nrow(packages)){
		
		url = paste0('http://github.com/', packages$package[i], '/archive/', packages$tag[i], '.zip')
		
		GET(url, write_disk(file.path(scratch, 'package.zip'), overwrite=TRUE), timeout=600)
		
		unzip(file.path(scratch, 'package.zip'), exdir=file.path(scratch, packages$package[i]))
		
		pkgdirname = Sys.glob(paste0(scratch, '/', packages$package[i], '/', basename(packages$package[i]), '*'))
		
		all_deps = rbind(all_deps, as.data.frame(devtools::dev_package_deps(pkgdirname)))
		
		devtools::install_deps(pkgdirname,type = 'both', repos=repos)
		
		if(length(pkgdirname) > 1){
			stop('too many files in downloaded zip, ambiguous build info')
		}
		
		cmd = paste0('R CMD build ', pkgdirname, ' --no-build-vignettes --no-manual')
		system(cmd)
		write_PACKAGES(getwd(), type='source')
		gran_packages = data.frame(available.packages(paste0('file:', getwd()), type='source'))
		
		built_pkg = Sys.glob(paste0(gran_packages$Package,"_",gran_packages$Version,".tar.gz"))
		
		issuccess = file.rename(built_pkg, file.path(src_dir, basename(built_pkg)))
		
		if(!issuccess){
			stop('Cannot move package', packages$package[i], 'to local GRAN area')
		}
	}
	
	write_PACKAGES(src_dir, type='source')
	
	#now, install any missed packages using the local source directory 
	# this is necessary if more than one package is added to GRAN at a time
	# or GRAN is screwed up for some reason
	missed_pkgs = all_deps$package[!all_deps$package %in% installed.packages()[,1]]
	
	if(length(missed_pkgs) > 0){
		cat('Installing missed packages:', missed_pkgs)
		install.packages(unique(missed_pkgs), type='source', repos=paste0('file:', GRAN.dir))
	}
	
	#write updated build list
	oldList <- read.table(currentListPath, sep='\t', header=TRUE,stringsAsFactors=FALSE)
	for(i in 1:nrow(packages)){ #could be vectorized?
	  oldList[grepl(packages$package[i],oldList$Package),2] <- packages$tag[i]
	}
	updatedList <- oldList
	write.table(updatedList,paste0(src_dir,"/updatedBuildTags_",version,".tsv"), quote = FALSE, row.names = FALSE)
	
	if(returnPackageMods){
	  return(packages)
	}
	
	
}



