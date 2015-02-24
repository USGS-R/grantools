
## Download specific tagged packages from Github and package them 

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

packages = read.table('gran_source_list.tsv', sep='\t', header=TRUE,stringsAsFactors=FALSE)

unlink(file.path(gran_dir, 'src'), recursive=TRUE)
dir.create(src_dir, recursive = TRUE)
scratch = tempdir()

for(i in 1:nrow(packages)){
	url = paste0('http://github.com/', packages$package[i], '/archive/', packages$tag[i], '.zip')
	download.file(url, destfile = file.path(scratch, 'package.zip'))

	unzip(file.path(scratch, 'package.zip'), exdir=file.path(scratch, packages$package[i]))
	
	pkgdirname = Sys.glob(paste0(scratch, '/', packages$package[i], '/', basename(packages$package[i]), '*'))
	
	if(length(pkgdirname) > 1){
		stop('too many files in downloaded zip, ambiguous build info')
	}
	
	cmd = paste0('R CMD build ', pkgdirname, ' --no-build-vignettes')
	system(cmd)
	
	built_pkg = Sys.glob(paste0(basename(packages$package[i]), '*.tar.gz'))
	
	issuccess = file.rename(built_pkg, file.path(src_dir, basename(built_pkg)))
	
	if(!issuccess){
		stop('Cannot move package', packages$package[i], 'to local GRAN area')
	}
}

write_PACKAGES(src_dir, type='source')


