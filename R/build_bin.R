#' build GRAN binaries
#' 
#' build binary packages for GRAN from source
#' 
#' @param sync use S3 sync with packages?
#' @param GRAN.dir local directory for GRAN built packages
#' @import devtools tools
#' @export
build_bin <- function(sync=FALSE, GRAN.dir = './GRAN'){
  ################################################################################
  ## These options may need to be edited for your local system
  ## we try to infer the rest
  ################################################################################
  src_dir = file.path(GRAN.dir, 'src', 'contrib')
  ################################################################################
  ## /options
  ################################################################################
  
  ## You 
  os = Sys.info()['sysname']
  r_maj_min = dir_version()
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
  
  #check available packages in bin and src folders and compare
  packages <- checkAvailablePackages(src_dir, build_dir)
  
  if(nrow(packages) > 0){
    toDelete <-  packages$Package
    if(dir.exists(file.path(build_dir))){
      unlink(paste0(build_dir,"/",toDelete,"*")) #delete any existing version of toDelete packages
    }else{
      dir.create(build_dir, recursive = TRUE)
    }
    
    
    results = rep(1, nrow(packages))
    
    for(i in 1:nrow(packages)){
      
      thisPackage = paste0(packages[i,'Package'], '_', packages[i,'Version'], '.tar.gz')
      binary = paste0(packages[i,'Package'], '_', packages[i,'Version'], build_ext)
      package_path = file.path(src_dir, thisPackage)
      binary_path = file.path('.', binary)
      binary_dest = file.path(build_dir, binary)
      
      cmd = paste0('R CMD INSTALL ', package_path, ' --build')
      
      results[i] = system(cmd)
      cat(rep('#',40), '\n')
      cat(packages[i,'Package'],':', results[i], '\n')
      cat(rep('#',40), '\n')
      
      if(results[i] != 0){
        warning(packages[i,'Package'], 'failed while compiling!!')
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
  }else{
    print("bin directory already up to date",quote = FALSE)
  }
  return(build_dir)
}

#' compare available packages in two directories
#' @param src character path to source directory
#' @param bin character path to binary directory
#' @import utils
#' @export

checkAvailablePackages <- function(src,bin){
  if(!file.exists(paste0(src,"/PACKAGES"))){
    stop("PACKAGES does not exist in the src directory")
  }
  srcPack <- as.data.frame(available.packages(paste0('file:',src)), stringsAsFactors = FALSE)
  srcPack <- srcPack[c('Package','Version')]
  if(file.exists(paste0(bin,"/PACKAGES"))){
    binPack <- as.data.frame(available.packages(paste0('file:',bin)), stringsAsFactors = FALSE)
    binPack <- binPack[c('Package','Version')]
    newPack <- findNotMatched(srcPack,binPack)
  }else{
    newPack <- srcPack
  }
  return(newPack) 
}
