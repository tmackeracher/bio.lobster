require(bio.survey)
require(bio.lobster)
require(bio.groundfish)
la()
p = bio.lobster::load.environment()
p$libs = NULL
ff = "LFA35-38Assessment"
fp1 = file.path(project.datadirectory('bio.lobster'),"analysis",ff)
fpf1 = file.path(project.figuredirectory('bio.lobster'),ff)
dir.create(fpf1,showWarnings=F)
dir.create(fp1,showWarnings=F)
p1 = p
p1$yrs = 1970:2019




stratifiedAnalysesBerried = function(p=p1, survey,lfa, fpf = fpf1, fp = fp1,f=ff,wd=10,ht=8){
      p$series =c('summer')# p$series =c('georges');p$series =c('fall')
      p$define.by.polygons = T
      p$lobster.subunits=F
      p$area = lfa
      p$years.to.estimate = p$yrs
      p$length.based = F
      p$by.sex = T
      p$sex = c(3)
      p$bootstrapped.ci=T
      p$strata.files.return=F
      p$vessel.correction.fixed=1.2
      p$strat = NULL
      p$clusters = c( rep( "localhost", 7) )
      p$strata.efficiencies = F
      p = make.list(list(yrs=p$years.to.estimate),Y=p)
      p$reweight.strata = T #this subsets 
  

      aout= dfo.rv.analysis(DS='stratified.estimates.redo',p=p)
      write.csv(aout,file=file.path(fpf, paste(lfa,'DFOBerried.csv')))

                              p$add.reference.lines = F
                              p$time.series.start.year = p$years.to.estimate[1]
                              p$time.series.end.year = p$years.to.estimate[length(p$years.to.estimate)]
                              p$metric = 'numbers' #weights
                              p$measure = 'stratified.mean' #'stratified.total'
                              p$figure.title = ""
                              p$reference.measure = 'median' # mean, geomean
                              p$file.name = p$file.name = file.path(f,paste(lfa,'DFOrestratifiednumbersBerried.png',sep=""))
                              p$y.maximum = NULL # NULL # if ymax is too high for one year
                              p$show.truncated.numbers = F #if using ymax and want to show the numbers that are cut off as values on figure
                                p$legend = FALSE
                                p$running.median = T
                                p$running.length = 3
                                p$running.mean = F #can only have rmedian or rmean
                               p$error.polygon=F
                              p$error.bars=T

                       ref.out=   figure.stratified.analysis(x=aout,out.dir = 'bio.lobster', p=p,wd=wd,ht=ht)
     }

stratifiedAnalysesBerried(survey='DFO',lfa='LFA35-38')
