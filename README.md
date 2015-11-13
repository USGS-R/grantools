# grantools
Tools for the Geological survey R Archive Network

### installing older versions of R from source OSX:
download tar.gz:  
e.g., https://cran.r-project.org/src/base/R-3/R-3.0.3.tar.gz  
`$ cd /Library/Frameworks/R.framework/Versions/3.0/Resources/`  
`$ ./configure --with-x=no`  
`$ make install`  
`$ make check`  

OR
`$ pkgutil --forget org.r-project.R.mavericks.fw.pkg` after the pkg install for https://cran.r-project.org/bin/macosx/old/

then use `RSwitch` to select versions for binary builds

##Disclaimer
This software is in the public domain because it contains materials that originally came from the U.S. Geological Survey, an agency of the United States Department of Interior. For more information, see the [official USGS copyright policy](http://www.usgs.gov/visual-id/credit_usgs.html#copyright/ "official USGS copyright policy")

Although this software program has been used by the U.S. Geological Survey (USGS), no warranty, expressed or implied, is made by the USGS or the U.S. Government as to the accuracy and functioning of the program and related program material nor shall the fact of distribution constitute any such warranty, and no responsibility is assumed by the USGS in connection therewith.

This software is provided "AS IS."

 [
    ![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)
  ](http://creativecommons.org/publicdomain/zero/1.0/)

