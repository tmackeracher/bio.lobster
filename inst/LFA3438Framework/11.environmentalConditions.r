#environmental conditions

#AMO capture from web
options(stringsAsFactors=F)

url <- "http://www.esrl.noaa.gov/psd/data/correlation//amon.us.long.data"
a = readLines(url,skip=1)
k = length(a)
a = a[-c(1,(k-4):k)]
g = length(a)

a = matrix(scan(url,skip=1,nlines=g),nrow=g,ncol=13,byrow=T)
p = rowMeans(a[115:163,2:13])
fn = file.path(project.figuredirectory('bio.lobster'))
png(file=file.path(fn,'AMO.png'),units='in',width=15,height=12,pointsize=18, res=300,type='cairo')
plot(1970:2018,p,type='h',ylab='AMO anomaly',xlab='Year')
dev.off()
aa = data.frame(yr=1856:2015,amo=p)
write.csv(aa,file=file.path(project.datadirectory('bio.lobster'),'analysis','indicators','amo.csv'))

#NAO

u = 'ftp://ftp.cpc.ncep.noaa.gov/cwlinks/norm.daily.nao.index.b500101.current.ascii'
l =readLines(u)
e = sapply(strsplit(l, split=" "), function(x) rbind(x))
e = lapply(e,function(x) { a = which(x==""); x[-a]})
e = Filter(length,e)
f = as.data.frame(do.call(rbind,e))

names(f) = c('yr','mon','d','nao')
f = toNums(f,c('yr','mon','d','nao'))
f = f[-which.max(f$nao),]

 u = 'https://www.ncdc.noaa.gov/teleconnections/nao/data.csv'
 l = read.csv(u,header=T)
 l = as.data.frame(l[-1,])
 l$yr = c(rep(1950:2015, each=12),rep(2016,11))
names(l)[1] <- 'NAO'
l$NAO = as.numeric(l$NAO)
a = aggregate(NAO~yr,data=l,FUN=mean)
###not really worth including seasonal changes not quite the same for annual


#temperature trends from the surveys

require(bio.survey)
require(bio.lobster)
p = bio.lobster::load.environment()
p$libs = NULL
p1 = p
fp = file.path(project.datadirectory('bio.lobster'),"analysis")
la()
load_all('~/git/bio.survey/')

fp1 = file.path(project.datadirectory('bio.lobster'),"analysis","LFA34-38")
fpf1 = file.path(project.figuredirectory('bio.lobster'),"LFA3438Framework2019")

load_all('~/git/bio.survey/')
load_all('~/git/bio.groundfish/')
la()

stratifiedAnalysesTemperature = function( p=p1, survey,lfa, fpf = fpf1, fp = fp1){

if(survey=='NEFSC'){

      p$reweight.strata = F #this subsets 
      p$years.to.estimate = c(1969:2018)
      p$length.based = T
      p$size.class= c(50,300)
      p$by.sex = F
      p$sex = c(1,2) # male female berried c(1,2,3)
      p$bootstrapped.ci=T
      p$strata.files.return=F
      p$strata.efficiencies=F
      p$clusters = c( rep( "localhost", 7) )
  
      

# Spring survey All stations including adjacent
                        p$season =c('spring')# p$series =c('spring');p$series =c('fall')
                        p$define.by.polygons = T
                        p$lobster.subunits=F
                        p$area = lfa
                        p$temperature=T
                      p = make.list(list(yrs=p$years.to.estimate),Y=p)
                    
                        aout= nefsc.analysis(DS='stratified.estimates.redo',p=p,save=F)      
       write.csv(aout,file=file.path(fp,'indicators',paste(lfa,'NEFSC.Spring.Temperature.csv',sep="")))
          
        #Figure
                              p$add.reference.lines = F
                              p$time.series.start.year = p$years.to.estimate[1]
                              p$time.series.end.year = p$years.to.estimate[length(p$years.to.estimate)]
                              p$metric = 'temperature' #weights
                              p$measure = 'stratified.mean' #'stratified.total'
                              p$figure.title = ""
                              p$reference.measure = 'median' # mean, geomean
                              p$file.name = file.path('LFA3438Framework2019',paste(lfa,'NEFSCSpringTemperature.png',sep=""))
                              p$ylim = c(4,12)
                          p$y.maximum = NULL # NULL # if ymax is too high for one year
                        p$show.truncated.numbers = F #if using ymax and want to show the numbers that are cut off as values on figure

                                p$legend = FALSE
                                p$running.median = T
                                p$running.length = 3
                                p$running.mean = F #can only have rmedian or rmean
                               p$error.polygon=F
                              p$error.bars=T


                       ref.out=   figure.stratified.analysis(x=aout,out.dir = 'bio.lobster', p=p)
 #### fall
         p$season =c('fall')# p$series =c('spring');p$series =c('fall')

	                        aout= nefsc.analysis(DS='stratified.estimates.redo',p=p,save=F)
       write.csv(aout,file=file.path(fp,'indicators',paste(lfa,'NEFSC.Fall.Temperature.csv',sep="")))

            
                            p$file.name = file.path('LFA3438Framework2019',paste(lfa,'NEFSCFallTemperature.png',sep=""))
                            ref.out=   figure.stratified.analysis(x=aout,out.dir = 'bio.lobster', p=p)
 }
if(survey=='DFO'){
 ###dfo
    p$series =c('summer')# p$series =c('georges');p$series =c('fall')
      p$define.by.polygons = T
      p$lobster.subunits=F
      p$area = lfa
      p$years.to.estimate = c(2005)
      p$length.based = F
      p$by.sex = F
      p$bootstrapped.ci=T
      p$strata.files.return=F
      p$vessel.correction.fixed=1.2
      p$strat = NULL
      p$clusters = c( rep( "localhost", 7) )
      p$strata.efficiencies = F
      p = make.list(list(yrs=p$years.to.estimate),Y=p)
      p$temperature=T
      p$reweight.strata = F #this subsets 
      require(bio.groundfish)
      la()
      aout= dfo.rv.analysis(DS='stratified.estimates.redo',p=p,save=F)
   write.csv(aout,file=file.path(fp,'indicators',paste(lfa,'DFO.Temperature.csv',sep="")))
      
                                   p$add.reference.lines = F
                              p$time.series.start.year = p$years.to.estimate[1]
                              p$time.series.end.year = p$years.to.estimate[length(p$years.to.estimate)]
                              p$metric = 'temperature' #weights
                              p$measure = 'stratified.mean' #'stratified.total'
                              p$figure.title = ""
                              p$reference.measure = 'median' # mean, geomean
                            p$file.name = file.path('LFA3438Framework2019',paste(lfa,'DFOTemperature.png',sep=""))
                          p$y.maximum = NULL # NULL # if ymax is too high for one year
                        p$show.truncated.numbers = F #if using ymax and want to show the numbers that are cut off as values on figure
        p$ylim = c(4,12)
                     
                                p$legend = FALSE
                                p$running.median = T
                                p$running.length = 3
                                p$running.mean = F #can only have rmedian or rmean
                               p$error.polygon=F
                              p$error.bars=T


                       ref.out=   figure.stratified.analysis(x=aout,out.dir = 'bio.lobster', p=p)
       }
     }



stratifiedAnalysesTemperature(survey='NEFSC',lfa='LFA34')
stratifiedAnalysesTemperature(survey='DFO',lfa='LFA34')
stratifiedAnalysesTemperature(survey='DFO',lfa='LFA35')
stratifiedAnalysesTemperature(survey='DFO',lfa='LFA36')
stratifiedAnalysesTemperature(survey='NEFSC',lfa='LFA38')
stratifiedAnalysesTemperature(survey='DFO',lfa='LFA38')
stratifiedAnalysesTemperature(survey='DFO',lfa='LFA35-38')
