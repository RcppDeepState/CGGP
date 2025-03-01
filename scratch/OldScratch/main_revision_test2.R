rm(list = ls())
source("../R/SGGP_fit_fs.R")
source("../R/SGGP_corr_fs.R")
source("../R/SGGP_create_fs.R")
source("../R/SGGP_append_fs.R")
source("../R/SGGP_pred_fs.R")
source("../R/SGGP_fastcalcassist_fs.R")

borehole <- function(x) {
  rw <- x[, 1] * (0.15 - 0.05) + 0.05
  r <-  x[, 2] * (50000 - 100) + 100
  Tu <- x[, 3] * (115600 - 63070) + 63070
  Hu <- x[, 4] * (1110 - 990) + 990
  Tl <- x[, 5] * (116 - 63.1) + 63.1
  Hl <- x[, 6] * (820 - 700) + 700
  L <-  x[, 7] * (1680 - 1120) + 1120
  Kw <- x[, 8] * (12045 - 9855) + 9855
  
  m1 <- 2 * pi * Tu * (Hu - Hl)
  m2 <- log(r / rw)
  m3 <- 1 + 2 * L * Tu / (m2 * rw ^ 2 * Kw) + Tu / Tl
  
  Yn = m1 / m2 / m3
  return(abs(cbind(Yn,Yn^0.75,Yn^0.5,Yn^1.25)))
 # return(Yn)
}


d = 8
testf<-function (x) {  return(borehole(x))} 

Npred <- 1000
library("lhs")
Xp = randomLHS(Npred, d)
Yp = testf(Xp)

SGGP = SGGPcreate(d,100) #create the design.  it has so many entries because i am sloppy
Y = testf(SGGP$design) #the design is $design, simple enough, right?
SGGP = SGGPfit(SGGP,Y)
SGGPGreedy=SGGPappend(SGGP,200,selectionmethod="TS")
YGreedy = testf(SGGPGreedy$design) #the design is $design, simple enough, right?
SGGPGreedy = SGGPfit(SGGPGreedy,YGreedy)
SGGPGreedy=SGGPappend(SGGPGreedy,200,selectionmethod="TS")
YGreedy = testf(SGGPGreedy$design) #the design is $design, simple enough, right?
SGGPGreedy = SGGPfit(SGGPGreedy,YGreedy)
SGGPGreedy=SGGPappend(SGGPGreedy,200,selectionmethod="TS")
YGreedy = testf(SGGPGreedy$design) #the design is $design, simple enough, right?
SGGPGreedy = SGGPfit(SGGPGreedy,YGreedy)
PredGreedy = SGGPpred(Xp,SGGPGreedy)
mean(abs(Yp-PredGreedy$mean)^2)  #prediction should be much better
mean(abs(Yp-PredGreedy$mean)^2/PredGreedy$var+log(PredGreedy$var)) #score should be much better


SGGPGreedy2=SGGPappend(SGGPGreedy,400,selectionmethod="TS")
YGreedy2 = testf(SGGPGreedy2$design) #the design is $design, simple enough, right?
SGGPGreedy2 = SGGPfit(SGGPGreedy2,YGreedy2)
PredGreedy = SGGPpred(Xp,SGGPGreedy2)
mean(abs(Yp[1,]-PredGreedy$mean[1,])^2)  #prediction should be much better
mean(abs(Yp[1,]-PredGreedy$mean[1,])^2/PredGreedy$var[1,]+log(PredGreedy$var[1,])) #score should be much better


Xs = randomLHS(200, d)
Ys = testf(Xs)
SGGPSupp = SGGPfit(SGGPGreedy,YGreedy,Xs=Xs,Ys=Ys)


PredSupp = SGGPpred(Xp,SGGPSupp)
mean(abs(Yp[1,]-PredSupp$mean[1,])^2)  #prediction should be much better
mean(abs(Yp[1,]-PredSupp$mean[1,])^2/PredSupp$var[1,]+log(PredSupp$var[1,])) #score should be much better

#SGGPSupp =  SGGPsupplement(SGGPGreedy,Xs,Ys)

#PredSupp =  SGGPpred(Xp,SGGPSupp)
#mean(abs(Yp-PredSupp$mean)^2)  #prediction should be much better
#mean(abs(Yp-PredSupp$mean)^2/PredSupp$var+log(PredSupp$var)) #score should be much better


