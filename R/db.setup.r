#' @export
db.setup=function(){
  
  if(!grepl('64',version$arch)) { #in 32-bit R, only RODBC will work
      print("Defaulting to RODBC as using 32 bit R installation")
      require(RODBC)
      con <<- odbcConnect(oracle.server , uid=oracle.username, pwd=oracle.password, believeNRows=F) # believeNRows=F required for oracle db's
      connect.command<<-function(...) {
        #if(!grepl('64',version$arch)){
          sqlQuery(...)}
        #} 
  }
 
  else {
 
    t=try(library(ROracle), silent=T)   
    
    #if ROracle won't load, default to RODBC'
    if ("try-error" %in% class(t)) {
      stop('You must use  R 32bit with RODBC')
      }
  
    #if ROracle package will load
            else {
            print("Using ROracle for db connections")
            require('ROracle')
            con<<-dbConnect(DBI::dbDriver("Oracle"),username=oracle.username, password=oracle.password, dbname=oracle.server)
            }
         
   connect.command<<-function(...) {
     if ("try-error" %in% class(t)) {
       sqlQuery(...)
     } else {
       dbGetQuery(...)
     } } } }
  

