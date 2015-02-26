
library(devtools)
library(tools)

################################################################################
## These options may need to be edited for your local system
## we try to infer the rest
################################################################################
gran_dir = '../GRAN'
src_dir = file.path(gran_dir, 'src', 'contrib')
################################################################################
## /options
################################################################################

r_maj_min = substr(paste0(R.Version()$major, '.', R.Version()$minor), 0, 3)
os = Sys.info()['sysname']

## You 

if(os == 'Windows'){
	build_ext = '.zip'
	s3_path = paste0('s3://owi.usgs.gov/R/bin/windows/contrib/', r_maj_min)
	build_dir = file.path(gran_dir, 'bin', 'windows', 'contrib', r_maj_min)
	pkg_type = 'win.binary'
	
}else if(os == 'Darwin'){
	build_ext = '.tgz'
	s3_path = paste0('s3://owi.usgs.gov/R/bin/macosx/mavericks/contrib/', r_maj_min)
	build_dir = file.path(gran_dir, 'bin', 'macosx', 'mavericks', 'contrib', r_maj_min)
	pkg_type = 'mac.binary' #can't use getOPtion('pkgType') with mavericks for some reason
	
}else{
	stop('unrecognized OS type', os)
}


gran <- c(GRAN="http://owi.usgs.gov/R")
#gran_packages = available.packages(contriburl = contrib.url(gran, type='source'), type='source')
gran_packages = available.packages(paste0('file:', src_dir), type='source')

#unlink(file.path(gran_dir, 'src'), recursive=TRUE)
#makeRepo(gran_packages, path=gran_dir, repos=gran, type="source")


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

system(paste0('aws s3 sync ', src_dir, ' ', s3_path, ' --delete'))

system(paste0('aws s3 sync ', src_dir, ' ', s3_path, ' --delete'))

