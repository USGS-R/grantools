#' build GRAN binaries
#' 
#' build binary packages for GRAN from source
#' 
#' @param sync use S3 sync with packages?
#' @param GRAN.dir local directory for GRAN built packages
#' 
#' @import devtools tools
#' @export
dl_build_bin <- function(sync=FALSE, GRAN.dir = '../GRAN'){
	################################################################################
	## These options may need to be edited for your local system
	## we try to infer the rest
	################################################################################
	GRAN.dir = '../GRAN'
	src_dir = file.path(GRAN.dir, 'src', 'contrib')
	################################################################################
	## /options
	################################################################################
	

	
	## You 
	os = Sys.info()['sysname']
	r_maj_min = substr(paste0(R.Version()$major, '.', R.Version()$minor), 0, 3)
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
	
	gran_packages = available.packages(paste0('file:', src_dir), type='source')
	
	
	#kill and create build dir (to eliminate old versions which could hang out)
	unlink(file.path(build_dir), recursive=TRUE)
	dir.create(build_dir, recursive=TRUE)
	
	results = rep(1, nrow(gran_packages))
	
	for(i in 1:nrow(gran_packages)){
		
		package = paste0(gran_packages[i,'Package'], '_', gran_packages[i,'Version'], '.tar.gz')
		binary = paste0(gran_packages[i,'Package'], '_', gran_packages[i,'Version'], build_ext)
		package_path = file.path(src_dir, package)
		binary_path = file.path('.', binary)
		binary_dest = file.path(build_dir, binary)
		
		cmd = paste0('R CMD INSTALL ', package_path, ' --build')
		
		results[i] = system(cmd)
		cat(rep('#',40), '\n')
		cat(gran_packages[i,'Package'],':', results[i], '\n')
		cat(rep('#',40), '\n')
		
		if(results[i] != 0){
			warning(gran_packages[i,'Package'], 'failed while compiling!!')
		}
		
		file.rename(binary_path, binary_dest)
	}
	
	if(any(results!=0)){
		stop('Error in one of the package compiles')
	}
	
	#Once done, write PACKAGES file, use default pkgType for this platform (mac/win)
	write_PACKAGES(build_dir, type=pkg_type)
	
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


