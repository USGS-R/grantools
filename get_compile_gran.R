
library(miniCRAN)
library(devtools)
library(tools)

r_maj_min = substr(paste0(R.Version()$major, '.', R.Version()$minor), 0, 3)

gran_dir = 'GRAN'
src_dir = file.path(gran_dir, 'src', 'contrib')
build_dir = file.path(gran_dir, 'bin', 'windows', 'contrib', r_maj_min)


gran <- c(GRAN="http://owi.usgs.gov")
gran_packages = available.packages(contriburl = contrib.url(gran, type='source'))

makeRepo(gran_packages, path=gran_dir, repos=gran, type="source")


dir.create(build_dir, recursive=TRUE)


for(i in 1:nrow(gran_packages)){
	
	package = paste0(gran_packages[i,'Package'], '_', gran_packages[i,'Version'], '.tar.gz')
	binary = paste0(gran_packages[i,'Package'], '_', gran_packages[i,'Version'], '.zip')
	package_path = file.path(src_dir, package)
	binary_path = file.path('.', binary)
	binary_dest = file.path(build_dir, binary)
	
	cmd = paste0('R CMD INSTALL ', package_path, ' --build')
	
	res = system(cmd)
	
	file.rename(binary_path, binary_dest)
}

#Once done, write PACKAGES file
write_PACKAGES(build_dir, type='win.binary')

## sync with GRAN


