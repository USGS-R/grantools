
##Parse logs

log_dir = 'd:/logs'

logfiles = Sys.glob(paste0(log_dir, '/*'))

all_logs = data.frame()

for(i in 1:length(logfiles)){
	tryCatch({
		tmp = read.table(logfiles[i], sep=' ', stringsAsFactors=FALSE)
		all_logs = rbind(all_logs, tmp)
	}, error = function(e){})
	
}


names(all_logs) = c('owner', 'bucket', 'time', 'time2', 'ip', 'requester', 'requestid', 
										'operation', 'key', 'requesturi', 'httpstatus', 'errorcode', 
										'bytessent', 'objsize', 'totaltime', 'turnaroundtime', 'referrer',
										'user-agent', 'versionid')


library(geocode)
library(stringr)
all_logs$country = geocode.ips.country(all_logs$ip)$country


filter_packages = function(df){
	
	
	all_get_r = all_logs[all_logs$operation == 'WEBSITE.GET.OBJECT' &
											 	grepl(pattern='R/.*' , all_gets$key), ]
	
	
	#grab !PACKAGES and just .zip or .tar.gz or .tgz file downloads
	all_get_r = all_get_r[!grepl('(PACKAGES\\.gz)|(PACKAGES)', all_get_r$key) &
													grepl('(.*\\.zip)|(.*\\.tar\\.gz)|(.*\\.tgz)', all_get_r$key), ]
	
	return(all_get_r)
	
}

just_packages = filter_packages(all_logs)

	
extract_package_names = function(keys){
	
  names =	str_match(basename(keys), '(.*)_.*\\.((tar\\.gz)|tgz|zip)')
  
	return(names[,2])
}

just_packages$packagename = extract_package_names(just_packages$key)



