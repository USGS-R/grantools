if(!require(plyr)){
	install.packages('plyr')
	library(plyr)
}



################################################################################
##Modify these to appoint to the appropriate areas
################################################################################

#Head of directory structure below which *.R files will be looked for
examine_dir = readline(prompt="Enter root of search path (defuault c:/): ")
if(examine_dir == ""){
	examine_dir = "c:/"
}

#Directory to save the results, please do not add 
out_dir     = readline(prompt="Enter result output directory (default ./): ")
if(out_dir == ""){
	out_dir = "./"
}

out_dir = sub(x=out_dir, pattern='[/|\\]$', replacement='')


################################################################################
################################################################################

namelist = function(l){
	#to_expand = c('for', 'while', 'function')
	
	out = list()
	j = 1
	
	for(i in 1:length(l)){
		if(is.expression(l[[i]]) | is.call(l[[i]])){
			out[[j]] = namelist(l[[i]])
			j = j+1
		}else{
			if(is.name(l[[i]])){
				out[[j]] = as.character(l[[i]])
			  j = j+1
			}
		}
	}
	return(unlist(out))
}


libraries = function(nl){
	libs = c()
	j=1
	for(i in 1:length(nl)){
		if(nl[[i]]=='library' || nl[[i]]=='require'){
			libs[j] = nl[[i+1]]
			j = j+1
		}
	}
	return(libs)
}

user_functions = function(nl){
	funcs = c()
	j=1
	for(i in 1:length(nl)){
		if(nl[[i]]=='function'){
			if(nl[[i-2]] == '<-' || nl[[i-2]] == '='){
				funcs[j] = nl[[i-1]]
				j = j+1
			}
		}
	}
	return(funcs)
}





recursive_parse = function(base_path){
	
	files = dir(base_path, pattern='*\\.[r|R]$', recursive=TRUE)
	
	u_funcs = c()
	libs = c()
	all_names = c()
	
	for(i in 1:length(files)){
		
		tryCatch({
			nl = namelist(parse(paste0(base_path, files[[i]])))
			if(length(nl) > 5){
				u_funcs = c(u_funcs, user_functions(nl))
				libs = c(libs, libraries(nl))
				all_names = c(all_names, nl)
			}
		}, error=function(e){})
		libs
		u_funcs
	}
	return(list(u_funcs, libs, all_names))
}




out      = recursive_parse(examine_dir)

lib_use  = sort(table(out[[2]]), decreasing = TRUE)
ufunc_use = sort(table(out[[1]]), decreasing = TRUE)

lib_use   = data.frame('name'=names(lib_use), count=lib_use)
ufunc_use = data.frame('name'=names(ufunc_use), count=ufunc_use)

#write write
write.table(lib_use, file.path(out_dir, 'R_packages.tsv'), sep='\t', row.names=FALSE, 
						col.names=TRUE)

write.table(ufunc_use, file.path(out_dir, 'R_userfunctions.tsv'), sep='\t', row.names=FALSE, 
						col.names=TRUE)


all_names = sort(table(out[[3]]), decreasing = TRUE)
df_names = data.frame('function'=names(all_names), count=all_names)

#package_function = read.table('usgs_function_info.tsv', header=TRUE)
#func_usage = merge(df_names, package_function)
#func_usage = func_usage[order(func_usage$count, decreasing = TRUE), ]

write.table(df_names, file.path(out_dir, 'all_names.tsv'), sep='\t', row.names=FALSE)

#write.table(ddply(func_usage, 'package', function(df)sum(df$count)), 
#						file.path(out_dir, 'use_per_package.tsv'), 
#						sep='\t', row.name=FALSE)

