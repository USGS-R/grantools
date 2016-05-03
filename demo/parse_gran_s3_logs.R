
library(geocode)
library(stringr)
library(dplyr)

##Parse logs

log_dir = 'd:/logs'

logfiles = Sys.glob(paste0(log_dir, '/*'))

all_logs = data.frame()

all_dfs = lapply(logfiles, function(fname){
							tmp = data.frame()
							tryCatch({
								tmp = read.table(fname, sep=' ', stringsAsFactors=FALSE)
							}, error = function(e){})
							return(tmp)
})

all_cols = lapply(all_dfs, ncol)
all_dfs = all_dfs[all_cols == 19]

all_logs = as.data.frame(data.table::rbindlist(all_dfs, fill=TRUE))

all_logs = na.omit(all_logs[,paste0('V', 1:19)])

names(all_logs) = c('owner', 'bucket', 'time', 'time2', 'ip', 'requester', 'requestid', 
										'operation', 'key', 'requesturi', 'httpstatus', 'errorcode', 
										'bytessent', 'objsize', 'totaltime', 'turnaroundtime', 'referrer',
										'user-agent', 'versionid')



link_ips = data.frame(ip = unique(all_logs$ip))

link_ips = geocode.ips(link_ips$ip)


#all_logs$country = geocode.ips.country(all_logs$ip)$country


filter_packages = function(df){
	
	
	all_get_r = df[df$operation == 'WEBSITE.GET.OBJECT' &
											 	grepl(pattern='R/.*' , df$key), ]
	
	
	#grab !PACKAGES and just .zip or .tar.gz or .tgz file downloads
	all_get_r = all_get_r[!grepl('(PACKAGES\\.gz)|(PACKAGES)', all_get_r$key) &
													grepl('(.*\\.zip)|(.*\\.tar\\.gz)|(.*\\.tgz)', all_get_r$key), ]
	
	return(all_get_r)
	
}

just_packages = filter_packages(all_logs)
#just_packages$country = geocode.ips.country(just_packages$ip)$country
	
extract_package_names = function(keys){
	
  names =	str_match(basename(keys), '(.*)_.*\\.((tar\\.gz)|tgz|zip)')
  
	return(names[,2])
}

just_packages$packagename = extract_package_names(just_packages$key)

write.csv(just_packages, '~/gran_dl_stats.csv', row.names=FALSE)

package_summary = group_by(just_packages, packagename) %>% 
									summarise(dl_count = length(packagename)) %>% 
									arrange(desc(dl_count))

write.csv(package_summary, '~/gran_package_dl_stats.csv', row.names=FALSE)

beepr::beep(sound=2)
beepr::beep(sound=2)
beepr::beep(sound=2)
