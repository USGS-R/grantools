#' build binaries on jenkins
#' 
#' builds GRAN binaries from jenkins machine
#' 
#' @import tools
#' @export
jenkins_build_bin = function(){
	options(repos=c(CRAN="https://cran.rstudio.com", USGS='https://owi.usgs.gov/R'))
	
	################################################################################
	## These options may need to be edited for your local system
	## we try to infer the rest
	################################################################################
	gran_dir = './GRAN'
	src_dir = file.path(gran_dir, 'src', 'contrib')
	################################################################################
	## /options
	################################################################################
	
	r_maj_min = substr(paste0(R.Version()$major, '.', R.Version()$minor), 0, 3)
	os = Sys.info()['sysname']
	
	## You 
	
	if(os == 'Windows'){
		build_ext = '.zip'
		build_dir = file.path(gran_dir, 'bin', 'windows', 'contrib', r_maj_min)
		pkg_type = 'win.binary'
		
	}else if(os == 'Darwin'){
		build_ext = '.tgz'
		build_dir = file.path(gran_dir, 'bin', 'macosx', 'mavericks', 'contrib', r_maj_min)
		pkg_type = 'mac.binary' #can't use getOPtion('pkgType') with mavericks for some reason
		
	}else{
		stop('unrecognized OS type', os)
	}
	
	repos = c(GRAN=paste0("file:",gran_dir), CRAN="http://cran.rstudio.com")

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
		
		all_deps = package_dependencies(gran_packages[i,'Package'], 
																		db=available.packages(
																			type='source', 
																			contriburl=contrib.url(repos, type='source')),
																		recursive=TRUE)
		
		to_install = all_deps[[1]][!all_deps[[1]] %in% as.vector(installed.packages()[,'Package'])]
		
		if(length(to_install) > 0){
			install.packages(to_install, lib='gran_build_libs')
		}
		
		install.packages(gran_packages[i,'Package'], type='source', INSTALL_opts='--build', repos=repos)

		file.rename(binary_path, binary_dest)
	}
	
	write_PACKAGES(build_dir, type=pkg_type)
}

