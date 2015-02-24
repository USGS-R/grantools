

#The text to be added to an .Rprofile file
repo_text = 'options(repos=c(getOption(\'repos\'), USGS=\'http://owi.usgs.gov/R\'))\n'



#Check to see if they already have USGS repo setup
if(any(names(getOption('repos')) %in% 'USGS')){
	stop('You already have USGS:GRAN setup as a repository, skipping...')
}

#if not, find architecture and add accordingly
os = Sys.info()['sysname']

create_append_text = function(fpath, text, append){
	
	write(text, fpath, append=append)
	
}

##DO FOR WINDOWS
if(os == 'Windows'){
	
	rprofile_path = file.path(Sys.getenv("HOME"), '.Rprofile')
	if(file.exists(rprofile_path)){
		create_append_text(rprofile_path, repo_text, append=TRUE)
	}else{
		create_append_text(rprofile_path, repo_text, append=FALSE)
	}

##DO FOR OS X
}else if(os == 'Darwin'){	
	
	rprofile_path = file.path(Sys.getenv("HOME"), '.Rprofile')
	if(file.exists(rprofile_path)){
		create_append_text(rprofile_path, repo_text, append=TRUE)
	}else{
		create_append_text(rprofile_path, repo_text, append=FALSE)
	}
	
#Stop for all else
}else{
	stop('Sorry, unable to automatically add GRAN on ', os)
}


warning('Your Rprofile has been updated to include GRAN.\nPlease restart R for changes to take effect.')

