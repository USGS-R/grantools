
library(miniCRAN)
library(devtools)
library(tools)

r_maj_min = substr(paste0(R.Version()$major, '.', R.Version()$minor), 0, 3)
os = Sys.info()['sysname']

if(os == 'Windows'){
	build_ext = '.zip'
}else if(os == 'Darwin'){
	build_ext = '.tgz'
}else{
	stop('unrecognized OS type', os)
}

gran_dir = '../GRAN'
src_dir = file.path(gran_dir, 'src', 'contrib')
build_dir = file.path(gran_dir, 'bin', 'windows', 'contrib', r_maj_min)


gran <- c(GRAN="http://owi.usgs.gov/R")
gran_packages = available.packages(contriburl = contrib.url(gran, type='source'))

makeRepo(gran_packages, path=gran_dir, repos=gran, type="source")


dir.create(build_dir, recursive=TRUE)


for(i in 1:nrow(gran_packages)){
	
	package = paste0(gran_packages[i,'Package'], '_', gran_packages[i,'Version'], '.tar.gz')
	binary = paste0(gran_packages[i,'Package'], '_', gran_packages[i,'Version'], build_ext)
	package_path = file.path(src_dir, package)
	binary_path = file.path('.', binary)
	binary_dest = file.path(build_dir, binary)
	
	cmd = paste0('R CMD INSTALL ', package_path, ' --build')
	
	res = system(cmd)
	
	file.rename(binary_path, binary_dest)
}

#Once done, write PACKAGES file, use default pkgType for this platform (mac/win)
write_PACKAGES(build_dir, type=getOption('pkgType'))

## sync with GRAN
#email luke

