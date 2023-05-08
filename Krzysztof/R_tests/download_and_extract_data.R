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

massUnpack_bzip2 <- function(files, ext = '.csv.bz2'){
  #files: a character vector of files' names, 
  #returns logical vector (TRUE if file was extracted successfully)
  
  info <- logical(length(files))
  names(info) <- files
  
  for( i in 1:length(files)){
    tryCatch(
      expr = {
        system2("bzip2", args = sprintf("-d %s", paste(files[i], ext, sep='')))
        TRUE
      }, 
      error = function(e) {
        FALSE
      }
    ) -> info[i]
  }
  invisible(info)
}

#TESTS- production
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



#############
urls_test2 <- c("https://pl.wikipedia.org/wiki/Madryt",
                "https://pl.wikipedia.org/wiki/Warszawa")

file_names <- c("Madryt", "Warszawa")

massDownload(urls_test2,dest,file_names = file_names, ext = ".html")

file_names <- file.path(dest, file_names) 
massUnpack_bzip2(file_names, ".html.bz2")

airports <- c("https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/HG7NV7/XTPZZY")
mass###to do

rm(list = ls())

#FINAL VERSION 1.1
###########################################
#
library('data.table')

#Download first frame, then do numbers_of_flights_daily, save result as df%year%, 
# and remove frame from memory
#then repeat instructions with the second frame

#Please read INFO

###Params
num_of_flights_daily <- function(dataFrame){
  #Uses data.table package
  #returns a data.table with grouped rows by month and day values
  
  result <- as.data.table(dataFrame)[,.("Count" = .N), 
                                     keyby = .(Month, DayofMonth)]
}

data_directory <- "~/laby_PDU/Projekt_2_outer/Projekt_2_PDU/Dane"
urls_frames <- c("https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/HG7NV7/YGU3TD",
                 "https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/HG7NV7/CI5CEM")
names_frames <- c("2000", "2001")


###Main
#INFO
#Uses UNIX (bash) commands

#Only "execute function" part is modifiable

#You may comment "download" and "extract" sections 
##if you have already downloaded data

#WARNING this function deletes used files
##You should comment/delete "delete files" section if you want to save your files

files <- file.path(data_directory, names_frames)

for(i in 1:length(urls_frames)){
  cat(paste("i = ", i,"\n", sep = ""))
#  #download
#  massDownload(urls_frames[i],
#                 outdir = data_directory, 
#                 file_names = names_frames[i])
#  cat("Download complete\n")
#    
#  #extract
#  massUnpack_bzip2(files[i])
#  cat('Extract complete\n')
  
  
  #create variable
  df_name <- paste("df_", names_frames[i], sep = "")
  assign(df_name, read.csv(paste(files[i], ".csv", sep="")))
  
  #execute function
  assign(df_name, num_of_flights_daily(get(df_name)))
  cat('Analysis complete\n')
  
  
#  #delete file
#  system2("rm", args = paste(files[i], ".csv", sep=""))
  
  #clean memory
  gc() # free unused memory
  
  cat('Cleaning complete\n')
}
rm(df_2001)
