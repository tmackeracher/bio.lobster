#' @export
CPUEModelPlot = function(CPUEModelResult, TempModelling, mdata = NULL, lfa, combined=F,graphic='R', wd=8, ht=11, path=file.path(project.figuredirectory("bio.lobster"),"figures"),lab='',index.pts=T, ...){
	
  if(combined==T){
    M = CPUEModelResult$model
    Alldata = CPUEModelResult$mData
    if(missing(lfa))lfa = unique(Alldata$fAREA)
  }
    

  if(combined==F){
    if(missing(lfa))lfa = names(CPUEModelResult)
    CPUEModelResult = CPUEModelResult[which(names(CPUEModelResult)%in%lfa)]
  }

  pData.list = list()

  if(graphic=='pdf')pdf(file.path( path,paste0("CPUEmodel",lab,".pdf")),width=wd,height=ht)
  if(graphic=='png')png(file.path(path,paste0("CPUEmodel",lab,".png")),width=wd,height=ht,units='in',res=200)
  if(graphic=='R')x11(width=wd,height=ht)

  par(mfrow=c(length(lfa),1),mar=c(0,0,0,0),omi=c(0.5,1,0.5,0.5),las=1)

  for(i in 1:length(lfa)){
    if(combined==F){
      M = CPUEModelResult[[ lfa[i] ]]$model
      Mdata = M$data
    }
    if(combined==T)Mdata = subset(Alldata,fAREA==lfa[i])
    if(!is.null(mdata)) {
      Mdata = mdata
      Mdata$fYEAR = Mdata$SYEAR
      Mdata$fAREA = Mdata$LFA
    }
    Mdata$CPUE = Mdata$WEIGHT_KG/Mdata$NUM_OF_TRAPS
    wt=aggregate(WEIGHT_KG~y,Mdata,FUN=sum)

    MD = subset(Mdata,!duplicated(y))
    MD = MD[order(MD$y),]
    D = median(Mdata$DEPTH)
    Temp = predict(TempModelling$Model, newdata = data.frame(y=MD$y, cos.y=cos(2*pi*MD$y), sin.y=sin(2*pi*MD$y), DEPTH=D, area=lfa[i]), type='response')
    pData=data.frame(DOS=MD$DOS,TEMP= Temp,logTRAPS=log(1), fYEAR=as.factor(MD$SYEAR), fAREA=as.factor(MD$fAREA))
    PM = predict(M, newdata = pData, type = 'response',se.fit=T)


      pData$YEAR = as.numeric(as.character(pData$fYEAR))
      pData$mu = exp(PM$fit)
      pData$ub = exp(PM$fit + 1.96 * PM$se.fit)
      pData$lb = exp(PM$fit - 1.96 * PM$se.fit)
      pData$y = MD$y
      pData$LFA = lfa[i]

      pData = merge(pData,wt,all=T)
      pData = merge(pData,data.frame(y=seq(min(pData$YEAR)-0.6,max(pData$YEAR)+0.6,0.1)),all=T)


    plot(CPUE~y,Mdata,pch=16,cex=0.2,col=rgb(0,0,0,0.1),...)
    lines(mu~y,pData,lwd=2,col='red')
      lines(ub~y,pData,lty=2,col='red')
      lines(lb~y,pData,lty=2,col='red')
      if(index.pts){
        x=1-mean(with(subset(MD,DOS==1),y-year(DATE_FISHED)))
        with(CPUEModelResult[[ lfa[i] ]]$pData,points(YEAR-x,mu,pch=16,col='blue'))
      }
    mtext(paste("LFA",lfa[i]),adj=0.05,line=-5,cex=1.3)

    pData.list[[i]] = pData

   }
   if(graphic!='R')dev.off()

   return(do.call("rbind",pData.list))

 }
