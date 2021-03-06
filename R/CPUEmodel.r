#' @export
CPUEmodel=function(mf,CPUE, combined=F,lfa,t=8,d=25){

  require(lme4)
	
  if(missing(lfa))  lfa = ifelse(!is.na(unique(CPUE$subarea)),unique(CPUE$subarea),unique(CPUE$LFA))

  fn.root =  file.path( project.datadirectory('bio.lobster'), "R", "CPUE", "ModelResults")
  dir.create(fn.root,showWarnings = F)
    CPUE = CPUE[order(CPUE$subarea,CPUE$SYEAR),]
    # create factor year
    CPUE$fYEAR=as.factor(CPUE$SYEAR)
    CPUE$fAREA=as.factor(CPUE$subarea)

    # filter out NAs and zero catches
    CPUE = na.omit(CPUE)
    CPUE = subset(CPUE,WEIGHT_KG>0)

    # create log traps
    CPUE$logTRAPS=log(CPUE$NUM_OF_TRAPS)
    CPUE$logWEIGHT=log(CPUE$WEIGHT_KG)
 
    if(combined==F){
     G = glm(mf , offset= logTRAPS, family=gaussian(link='identity'),data = CPUE)
      
      pData=with(G$data,data.frame(fYEAR=sort(unique(fYEAR)),TEMP= t,DOS=d,logTRAPS=log(1)))
      PG = glmCIs(G,pData)
        pData$YEAR = as.numeric(as.character(pData$fYEAR))
        #bias correction
        log.lin.sig <- summary(G)$dispersion/2
        pData$mu = exp(PG$fit_resp+log.lin.sig)
        pData$ub = exp(PG$upr+log.lin.sig)
        pData$lb = exp(PG$lwr+log.lin.sig)
        output = list(model=G,pData=pData,mData=CPUE)
        save( output, file=file.path( fn.root, paste0(lfa,"glm.rdata")), compress=T)
     
    }

    if(combined==T){

      G = lmer(mf, offset= logTRAPS, data = CPUE)

      pData=subset(CPUE,!duplicated(paste(fYEAR,fAREA)),c("fYEAR","fAREA"))
      pData=data.frame(pData,TEMP= mean(CPUE$TEMP),DOS= mean(CPUE$DOS),logTRAPS=log(1))
      PG = glmCIs(G,pData)
    
        pData$YEAR = as.numeric(as.character(pData$fYEAR))
        pData$mu = exp(PG$fit_resp)
        pData$ub = exp(PG$upr)
        pData$lb = exp(PG$lwr)
        output = list(model=G,pData=pData,mData=CPUE)
        save( output, file=file.path( fn.root, "combinedglm.rdata"), compress=T)
    
    }


   
    return(output)
  }
