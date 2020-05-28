#!/bin/bash

#do everything build_GRAN_all does for the mac build, then sync w/AWS
#run this from the main package directory, not from ./inst!

pointer=/Library/Frameworks/R.framework/Versions/Current
versions=(3.6 4.0)
origVersion=$(readlink $pointer)
for ver in ${versions[@]}
do
	ln -sfhv $ver $pointer #change version

	R CMD INSTALL --no-multiarch --with-keep.source .	

	#only build source for first version
	if [ $ver == ${versions[0]} ]
	then
		Rscript -e 'library(granbuild); dl_build_src(); build_bin()'
	else
		Rscript -e 'library(granbuild); build_bin()'
	fi
done

ln -sfhv $origVersion $pointer  #reset to original version

#push to S3
aws s3 sync ~/Documents/R/grantools/GRAN/bin/macosx/contrib s3://owi-usgs-gov/R/bin/macosx/contrib --delete --profile chsprod
aws s3 sync ~/Documents/R/grantools/GRAN/bin/macosx/el-capitan/contrib s3://owi-usgs-gov/R/bin/macosx/el-capitan/contrib --delete --profile chsprod

