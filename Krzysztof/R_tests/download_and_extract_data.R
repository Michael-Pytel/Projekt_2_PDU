massDownload <- function(urls,
                         outdir, 
                         quiet = FALSE, 
                         file_names = NULL, 
                         ext ='.csv.bz2'){
  #this function was written during PDU class
  #returns logical vector showing which files were successfully downloaded
  options(timeout = 300)
  info <- logical(length(urls)) 
  names(info) <- urls
  
  if(!dir.exists(outdir)){
    warning("NOWY katalog zostal stworzony!")
    dir.create(outdir, recursive = TRUE)
  }
  
  if(is.null(file_names) || length(file_names) != length(urls) ){
    file_names <-  1:length(urls)
  }
  
  outputs <- file.path(outdir, paste(file_names, ext, sep = ''))
  
  for( i in 1:length(urls)){
    tryCatch(
      expr = {
        download.file(urls[i], outputs[i], quiet = quiet)
        TRUE
      }, 
      error = function(e) {
        FALSE
      }
    ) -> info[i]
    
  }
  invisible(info)
}

massUnpack <- function(files){
  #work in progress
  invisible()
}

#######
urls <- c("https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/HG7NV7/YGU3TD")
dest <- "~/laby_PDU/Projekt_2_outer/Projekt_2_PDU/Dane"
file_names <- c("2000")
massDownload(urls,dest, file_names = file_names)

?system2
old_wd <- getwd()
getwd()
test_f <- file.path(dest, "2000.csv.bz2")

system2("rm", args = file.path(dest, "2000.csv"))
system2("bzip2", args = sprintf("-d %s", test_f))

