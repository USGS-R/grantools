# grantools
Tools for the Geological survey R Archive Network

## adding a package to GRAN

see requirements for packages here: http://owi.usgs.gov/R/gran.html

If package requirements are met, including your package passing checks, existing on github, and being maintained by a usgs.gov email address, you can add a package to GRAN using the following instructions:

#### Tag a stable release of your package on github:  
![adding a tag to github](inst/tagging_GRAN.png)

#### Fork this repository: 
![fork GRAN](inst/fork_GRAN.png)
 
#### Add a pointer to your package in [inst/gran_src_list.tsv](https://github.com/USGS-R/grantools/blob/master/gran_source_list.tsv) 
![change source list](inst/change_src_list.png)

#### Create a pull request of your change:  
![pull request](inst/pr_GRAN.png)

#### Wait to be notified of any needed changes, or hear about success



## using grantools to build GRAN

#### building locally  
From R with the `grantools` package built locally:  
```r
library(grantools)
dl_build_src()
dl_build_bin()
```

#### building from jenkins  
with `grantools` installed:  
```r
library(grantools)
dl_build_src()
jenkins_build_src()
```

##Disclaimer
This software is in the public domain because it contains materials that originally came from the U.S. Geological Survey, an agency of the United States Department of Interior. For more information, see the [official USGS copyright policy](http://www.usgs.gov/visual-id/credit_usgs.html#copyright/ "official USGS copyright policy")

Although this software program has been used by the U.S. Geological Survey (USGS), no warranty, expressed or implied, is made by the USGS or the U.S. Government as to the accuracy and functioning of the program and related program material nor shall the fact of distribution constitute any such warranty, and no responsibility is assumed by the USGS in connection therewith.

This software is provided "AS IS."

 [
    ![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)
  ](http://creativecommons.org/publicdomain/zero/1.0/)

