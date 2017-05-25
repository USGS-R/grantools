#!/bin/bash

#do everything build_GRAN_all does for the mac build, then sync w/AWS

Rscript -e 'library(granbuild); build_GRAN_all(c('3.4', '3.3'))'

aws s3 sync ~/Documents/R/grantools/GRAN/bin/macosx/mavericks/contrib s3://owi-usgs-gov/R/bin/macosx/mavericks/contrib --delete --profile chsprod
aws s3 sync ~/Documents/R/grantools/GRAN/bin/macosx/el-capitan/contrib s3://owi-usgs-gov/R/bin/macosx/el-capitan/contrib --delete --profile chsprod

