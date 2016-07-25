#' build GRAN binaries
#' 
#' build binary packages for GRAN from source
#' 
#' @param sync use S3 sync with packages?
#' @param GRAN.dir local directory for GRAN built packages
#' @param packages list of packages to build 
#' @import devtools tools
#' @export
dl_build_bin <- function(packages, sync=FALSE, GRAN.dir = './GRAN'){
	################################################################################
	## These options may need to be edited for your local system
	## we try to infer the rest
	################################################################################
	src_dir = file.path(GRAN.dir, 'src', 'contrib')
	################################################################################
	## /options
	################################################################################
  packages$package <- sub(".*\\/","",packages$package) #remove repo and slash from package name
  packages$tag <- substring(packages$tag,2)

	
	## You 
	os = Sys.info()['sysname']
	r_maj_min = dir_version()
	if(os == 'Windows'){
		build_ext = '.zip'
		s3_path = paste0('s3://owi.usgs.gov/R/bin/windows/contrib/', r_maj_min)
		build_dir = file.path(GRAN.dir, 'bin', 'windows', 'contrib', r_maj_min)
		pkg_type = 'win.binary'

	}else if(os == 'Darwin'){
		build_ext = '.tgz'
		s3_path = paste0('s3://owi.usgs.gov/R/bin/macosx/mavericks/contrib/', r_maj_min)
		build_dir = file.path(GRAN.dir, 'bin', 'macosx', 'mavericks', 'contrib', r_maj_min)
		pkg_type = 'mac.binary' #can't use getOPtion('pkgType') with mavericks for some reason
		
	}else{
		stop('unrecognized OS type', os)
	}
	
	#gran_packages = available.packages(paste0('file:', src_dir), type='source')
	colnames(packages) <- c("Package","Version")
	
	#kill old versions or create directory
	#unlink(file.path(build_dir), recursive=TRUE)
	#dir.create(build_dir, recursive=TRUE)
	toDelete <-  sub(".*\\/","",packages$package)
	if(dir.exists(file.path(build_dir))){
	  system(paste("rm",paste0(paste0(build_dir,"/",toDelete,"*"),collapse=" "))) #delete any existing version of toDelete packages
	}else{
	  dir.create(src_dir, recursive = TRUE)
	}
	
	
	results = rep(1, nrow(packages))
	
	for(i in 1:nrow(packages)){
		
		thisPackage = paste0(packages[i,'Package'], '_', packages[i,'Version'], '.tar.gz')
		binary = paste0(packages[i,'Package'], '_', packages[i,'Version'], build_ext)
		package_path = file.path(src_dir, thisPackage)
		binary_path = file.path('.', binary)
		binary_dest = file.path(build_dir, binary)
		
		cmd = paste0('R CMD INSTALL ', package_path, ' --build')
		
		results[i] = system(cmd)
		cat(rep('#',40), '\n')
		cat(packages[i,'Package'],':', results[i], '\n')
		cat(rep('#',40), '\n')
		
		if(results[i] != 0){
			warning(packages[i,'Package'], 'failed while compiling!!')
		}
		
		file.rename(binary_path, binary_dest)
	}
	
	if(any(results!=0)){
		stop('Error in one of the package compiles')
	}
	
	#Once done, write PACKAGES file, use default pkgType for this platform (mac/win)
	currentListPath <- "./granCurrent.tsv"
	write_PACKAGES(build_dir, type=pkg_type)
	oldList <- read.table(currentListPath, sep='\t', header=TRUE,stringsAsFactors=FALSE)
	for(i in 1:nrow(packages)){ #could be vectorized?
	  oldList[grepl(packages$Package[i],oldList$Package),2] <- packages$Version[i]
	}
	updatedList <- oldList
	write.table(updatedList,paste0(build_dir,"/updatedBuildTags.tsv"), quote = FALSE, row.names = FALSE)
	
	
	## sync with GRAN
	#email luke
	# TODO: Implement S3 sync
	#Delete src directory
	if (sync){
		system(paste0('aws s3 sync ', src_dir, ' ', s3_path, ' --delete'))
		
		system(paste0('aws s3 sync ', src_dir, ' ', s3_path, ' --delete'))
	}

	
	return(build_dir)

}


