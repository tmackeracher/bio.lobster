#' @export
 CLF<-function(LFdat,bins=seq(0,220,5),yrs,ID="CLF",vers=1,format='tall',est.den=F){

    if(format=="tall"){
        names(LFdat)[1:2]<-c('YEAR','LENGTH')
        if(missing(yrs))yrs<-sort(unique(LFdat$YEAR))


        # additional columns may be included to produce seperate CLFs
        LFdat<-na.omit(LFdat)
        nc<-ncol(LFdat)
        LFdat$ID<-ID
        if(nc>2){
            LFdat$ID<-paste0(names(LFdat)[3],LFdat[,3])
            if(nc>3){
                for(i in 4:nc) LFdat$ID<-paste0(LFdat$ID,paste0(names(LFdat)[i],LFdat[,i]))    
            }
        }
    }        

    CLF<-list()
    IDs<-sort(unique(LFdat$ID))
    if(vers==1){
        for(i in 1:length(IDs)){
            CLF[[i]]<-t(sapply(yrs,function(y){with(subset(LFdat,YEAR==y&ID==IDs[i]&LENGTH>=min(bins)&LENGTH<max(bins)),hist(LENGTH,breaks=bins,plot=F)$count)}))
        }
        names(CLF)<-IDs
    }
    if(vers==2){
        for(i in 1:length(yrs)){


           #browser()
            
            if(est.den==T&&nrow(subset(LFdat,YEAR==yrs[i]))>0){
                CLF[[i]]<-t(sapply(IDs,function(y){with(subset(LFdat,ID==y&YEAR==yrs[i]&LENGTH>=min(bins)&LENGTH<max(bins)),density(LENGTH,bw=1,n=length(bins)-1,from=min(bins)+diff(bins)[1]/2,to=max(bins)-diff(bins)[1]/2)$y)}))
                if(format=="wide")CLF[[i]]<-t(sapply(IDs,function(y){with(subset(LFdat,ID==y&YEAR==yrs[i]&LENGTH>=min(bins)&LENGTH<max(bins)),density(LENGTH,bw=1,n=length(bins)-1,from=min(bins)+diff(bins)[1]/2,to=max(bins)-diff(bins)[1]/2)$y)}))
            }
            if(est.den==F||nrow(subset(LFdat,YEAR==yrs[i]))==0){
                CLF[[i]]<-t(sapply(IDs,function(y){with(subset(LFdat,ID==y&YEAR==yrs[i]&LENGTH>=min(bins)&LENGTH<max(bins)),hist(LENGTH,breaks=bins,plot=F)$count)}))
                if(format=="wide")CLF[[i]]<-t(sapply(IDs,function(y){with(subset(LFdat,ID==y&YEAR==yrs[i]&LENGTH>=min(bins)&LENGTH<max(bins)),hist(LENGTH,breaks=bins,plot=F)$count)}))
            }
        }
        names(CLF)<-yrs
    }

    return(CLF)
}

