library(sandwich)
library(lmtest)
library(zoo)
library(Matching)
library(plm)
library(plyr)
library(AER)
library(mlogit)
library(lattice)
library(texreg)
library(RColorBrewer)
library(foreign)


# Set working directory 

setwd ("YOUR DIRECTORY")


# FIGURE 1
	###############
	# Note: Figure 1 is constructed from "Figure1_AverageEffects_plot.csv". 
  #       "Figure1_AverageEffects_plot.csv" has to be constructed manual by reformatting "Figure1_AverageEffects.csv",
  #       which is produced in "cp_analysis_paper.do", so that there are three columns: varnames, ate, and se;
  #       where varnames are the index names from Figure 1 in the main paper, ate are the AES results, and se are the standard errors.
	###############


pdf("Figure1.pdf")

out<-read.csv("Figure1_AverageEffects_plot.csv")
labs<-paste(out[,"varname"],sep=",")

par(mar=c(2.5,0,0,0),font=1)	
	# empty plot
	plot(x=c(), y=c(), ylim=c(.5,10.3), xlim=c(-.42, .27), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="")
	lines(x=c(0,0),y=c(-.1,10.3),lty=2,col="black")

# CRIME
	# plot CIs 
	for (i in 1:10) {		
		lines(x=c(out[i,2]-1.96*out[i,3],out[i,2]+1.96*out[i,3]),y=c(11-i,11-i), col="gray", lwd=2)
		#text(labs[i], x=out[i,"ate"],y=7-i+.1, col="black",cex=1) 
	}
	
	# plot point estimates 
	points(x=out[1:10,"ate"],y=10:1, pch=16, col="black",cex=1.25)  
	
	# plot labels
	text(labs[1:10], x=rep(-.44,6),y=10:1, col="black",cex=1.25, pos=4, family = "Times") 
	
	#Axis
	axis(1,labels=c("-.2","-.1", "0",".1", ".2"),at=c(-.2,-.1,0,.1,.2), las=FALSE, tick=TRUE, cex.axis = 1, family = "Times")
	
dev.off()



# FIGURE 2 
	###############
	# Note: Figure 2 is constructed from "Figure2_ATE_crime_plot.csv". 
  #       "Figure2_ATE_crime_plot.csv" has to be constructed manual by reformatting "Figure2_ATE_crime.csv",  
  #       which is produced in "cp_analysis_paper.do", so that there are three columns: varnames, ate, and se; 
  #       where varnames are the index names from Figure 2 in the main paper, ate are the AES results, and se are the standard errors.
	###############

pdf("Figure2.pdf")

out<-read.csv("Figure2_ATE_crime_plot.csv")
labs<-paste(out[,"varname"],sep=",")

par(mar=c(2.5,0,0,0),font=1)	
	# empty plot
	plot(x=c(), y=c(), ylim=c(0,6.3), xlim=c(-.3, .15), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="")
	lines(x=c(0,0),y=c(-.1,6.3),lty=2,col="black")

# CRIME
	# plot CIs 
	for (i in 1:7) {		
		lines(x=c(out[i,2]-1.96*out[i,3],out[i,2]+1.96*out[i,3]),y=c(7-i,7-i), col="gray", lwd=2)
		#text(labs[i], x=out[i,"ate"],y=7-i+.1, col="black",cex=1) 
	}
	
	# plot point estimates 
	points(x=out[1:7,"ate"],y=6:0, pch=16, col="black",cex=1.25)  
	
	# plot labels
	text(labs[1:7], x=rep(-.3,6),y=6:0, col="black",cex=1.25, pos=4, family = "Times") 
	
	#Axis
	axis(1,labels=c("-.1","0",".1"),at=c(-.1,0,.1), las=FALSE, tick=TRUE, cex.axis = 1, family = "Times")
	
dev.off()	
		

		
# FIGURE 3 

	###############
	# Note: Figure 2 is constructed from "Figure2_ATE_crime_plot.csv". 
  #       "Figure2_ATE_crime_plot.csv" has to be constructed manual by reformatting "Figure2_ATE_crime.csv", 
  #       which is produced in "cp_analysis_paper.do", so that there are the following columns: 
	#           varname: variable names from the plot in Figure 3	
	#           ae_cptreat: AES 	
	#           ae_cptreat_se: AES standard error of AES
	#           ae_cptreat_female: AES for females	
	#           ae_cptreat_female_se: standard error of AES for females	
	#           ae_cptreat_not_female: AES for males	
	#           ae_cptreat_not_female_se: standard error of AES for males	
	#           ae_cptreat_minority: AES for minorities	
	#           ae_cptreat_minority_se: standard error of AES for minorities	
	#           ae_cptreat_not_minority: AES for not minority	
	#           ae_cptreat_not_minority_se: standard error of AES for not minority
	#           ae_cptreat_youth: AES for youth
	#           ae_cptreat_youth_se: standard error of AES for youth
	#           ae_cptreat_not_youth: AES for not youth	
	#           ae_cptreat_not_youth_se	: standard error of AES for not youth
	#           ae_cptreat_society: AES for society members	
	#           ae_cptreat_society_se: standard error of AES for society memebrs
	#           ae_cptreat_not_society: AES for non society members
	#           ae_cptreat_not_society_se: standard error of AES for non society members

	###############

pdf("Figure3.pdf")

out<-read.csv("Figure3_HetEffects_plot.csv")
labs<-c("AES","AES (Woman)","AES (Man)","AES (Minority)","AES (Non-minority)","AES (Youth)","AES (Non-youth)","AES (Society)","AES (Non-society)")

par(mfrow=c(2,6) , mar=c(2.5,0,1.25,1),font=1)	
	
	# LABELS
	# empty plot
	plot(x=c(), y=c(), ylim=c(0,8.3), xlim=c(-.3, .3), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="", family = "Times")
	
	# plot labels
	text(labs[1:9], x=rep(-.25,6),y=8:0, col="black",cex=1, pos=4, family = "Times") 
	
	# KNOWLEDGE OF POLICE 
	# empty plot
	plot(x=c(), y=c(), ylim=c(0,8.3), xlim=c(-.3, .3), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="", main="Knowledge of \n police", cex.main=.75, family = "Times")
	lines(x=c(0,0),y=c(-.1,8.3),lty=2,col="black")
	
	# plot CIs 
	n=1
	for (i in seq(2,18,by=2)) {		
		lines(x=c(out[1,i]-1.96*out[1,i+1],out[1,i]+1.96*out[1,i+1]),y=c(9-n,9-n), col="gray", lwd=2)
	n=n+1
	}
	
	# plot point estimates 
	points(x=out[1,seq(2,18,by=2)],y=8:0, pch=16, col="black",cex=1)  
	
	# axis
	axis(1,labels=c("-.15","0",".15"),at=c(-.15,0,.15), las=FALSE, tick=TRUE, cex.axis = 1, family = "Times")
		
	# KNOWLEDGE OF LAW 
	# empty plot
	plot(x=c(), y=c(), ylim=c(0,8.3), xlim=c(-.3, .3), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="", main="Knowledge of \n law", cex.main=.75, family = "Times")
	lines(x=c(0,0),y=c(-.1,8.3),lty=2,col="black")
	
	# plot CIs 
	n=1
	for (i in seq(2,18,by=2)) {		
		lines(x=c(out[2,i]-1.96*out[2,i+1],out[2,i]+1.96*out[2,i+1]),y=c(9-n,9-n), col="gray", lwd=2)
	n=n+1
	}
	
	# plot point estimates 
	points(x=out[2,seq(2,18,by=2)],y=8:0, pch=16, col="black",cex=1)  
	
	# axis
	axis(1,labels=c("-.15","0",".15"),at=c(-.15,0,.15), las=FALSE, tick=TRUE, cex.axis = 1, family = "Times")
	
		
	# PERCEPTIONS OF POLICE 
	# empty plot
	plot(x=c(), y=c(), ylim=c(0,8.3), xlim=c(-.3, .3), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="", main="Perceptions of \n  police", cex.main=.75, family = "Times")
	lines(x=c(0,0),y=c(-.1,8.3),lty=2,col="black")
	
	# plot CIs 
	n=1
	for (i in seq(2,18,by=2)) {		
		lines(x=c(out[3,i]-1.96*out[3,i+1],out[3,i]+1.96*out[3,i+1]),y=c(9-n,9-n), col="gray", lwd=2)
	n=n+1
	}
	
	# plot point estimates 
	points(x=out[3,seq(2,18,by=2)],y=8:0, pch=16, col="black",cex=1)  
	
	# axis
	axis(1,labels=c("-.15","0",".15"),at=c(-.15,0,.15), las=FALSE, tick=TRUE, cex.axis = 1, family = "Times")
	
		
	# PERCEPTIONS OF COURTS 
	# empty plot
	plot(x=c(), y=c(), ylim=c(0,8.3), xlim=c(-.3, .3), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="", main="Perceptions of \n courts", cex.main=.75, family = "Times")
	lines(x=c(0,0),y=c(-.1,8.3),lty=2,col="black")
	
	# plot CIs 
	n=1
	for (i in seq(2,18,by=2)) {		
		lines(x=c(out[4,i]-1.96*out[4,i+1],out[4,i]+1.96*out[4,i+1]),y=c(9-n,9-n), col="gray", lwd=2)
	n=n+1
	}
	
	# plot point estimates 
	points(x=out[4,seq(2,18,by=2)],y=8:0, pch=16, col="black",cex=1)  
	
	# axis
	axis(1,labels=c("-.15","0",".15"),at=c(-.15,0,.15), las=FALSE, tick=TRUE, cex.axis = 1, family = "Times")
	
		
# PERCEPTIONS OF GOVT 
	# empty plot
	plot(x=c(), y=c(), ylim=c(0,8.3), xlim=c(-.3, .3), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="", main="Perceptions of \n government", cex.main=.75, family = "Times")
	lines(x=c(0,0),y=c(-.1,8.3),lty=2,col="black")
	
	# plot CIs 
	n=1
	for (i in seq(2,18,by=2)) {		
		lines(x=c(out[5,i]-1.96*out[5,i+1],out[5,i]+1.96*out[5,i+1]),y=c(9-n,9-n), col="gray", lwd=2)
	n=n+1
	}
	
	# plot point estimates 
	points(x=out[5,seq(2,18,by=2)],y=8:0, pch=16, col="black",cex=1)  
	
	# axis
	axis(1,labels=c("-.15","0",".15"),at=c(-.15,0,.15), las=FALSE, tick=TRUE, cex.axis = 1, family = "Times")
	
	
	
# LABELS SECOND ROW
	# empty plot
	plot(x=c(), y=c(), ylim=c(0,8.3), xlim=c(-.3, .3), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="")
	
	# plot labels
	text(labs[1:9], x=rep(-.25,6),y=8:0, col="black",cex=1, pos=4, family = "Times") 
	
	
# PREFERENCES FOR POLICE
	# empty plot
	plot(x=c(), y=c(), ylim=c(0,8.3), xlim=c(-.3, .3), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="", main="Preferences for \n police", cex.main=.75, family = "Times")
	lines(x=c(0,0),y=c(-.1,8.3),lty=2,col="black")
	
	# plot CIs 
	n=1
	for (i in seq(2,18,by=2)) {		
		lines(x=c(out[6,i]-1.96*out[6,i+1],out[6,i]+1.96*out[6,i+1]),y=c(9-n,9-n), col="gray", lwd=2)
	n=n+1
	}
	
	# plot point estimates 
	points(x=out[6,seq(2,18,by=2)],y=8:0, pch=16, col="black",cex=1)  
	
	# axis
	axis(1,labels=c("-.15","0",".15"),at=c(-.15,0,.15), las=FALSE, tick=TRUE, cex.axis = 1, family = "Times")

	
# SUPPORT FOR TRIAL BY ORDEAL
	# empty plot
	plot(x=c(), y=c(), ylim=c(0,8.3), xlim=c(-.3, .3), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="", main="Support for \n trial by ordeal", cex.main=.75, family = "Times")
	lines(x=c(0,0),y=c(-.1,8.3),lty=2,col="black")
	
	# plot CIs 
	n=1
	for (i in seq(2,18,by=2)) {		
		lines(x=c(out[7,i]-1.96*out[7,i+1],out[7,i]+1.96*out[7,i+1]),y=c(9-n,9-n), col="gray", lwd=2)
	n=n+1
	}
	
	# plot point estimates 
	points(x=out[7,seq(2,18,by=2)],y=8:0, pch=16, col="black",cex=1)  
	
	# axis
	axis(1,labels=c("-.15","0",".15"),at=c(-.15,0,.15), las=FALSE, tick=TRUE, cex.axis = 1, family = "Times")

	
# CRIME VICTIMIZATION
	# empty plot
	plot(x=c(), y=c(), ylim=c(0,8.3), xlim=c(-.3, .3), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="", main="Crime victimization \n (self)", cex.main=.75, family = "Times")
	lines(x=c(0,0),y=c(-.1,8.3),lty=2,col="black")
	
	# plot CIs 
	n=1
	for (i in seq(2,18,by=2)) {		
		lines(x=c(out[8,i]-1.96*out[8,i+1],out[8,i]+1.96*out[8,i+1]),y=c(9-n,9-n), col="gray", lwd=2)
	n=n+1
	}
	
	# plot point estimates 
	points(x=out[8,seq(2,18,by=2)],y=8:0, pch=16, col="black",cex=1)  
	
	# axis
	axis(1,labels=c("-.15","0",".15"),at=c(-.15,0,.15), las=FALSE, tick=TRUE, cex.axis = 1, family = "Times")

	
# PROPERTY RIGHTS
	# empty plot
	plot(x=c(), y=c(), ylim=c(0,8.3), xlim=c(-.3, .3), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="", main="Property rights", cex.main=.75, family = "Times")
	lines(x=c(0,0),y=c(-.1,8.3),lty=2,col="black")
	
	# plot CIs 
	n=1
	for (i in seq(2,18,by=2)) {		
		lines(x=c(out[9,i]-1.96*out[9,i+1],out[9,i]+1.96*out[9,i+1]),y=c(9-n,9-n), col="gray", lwd=2)
	n=n+1
	}
	
	# plot point estimates 
	points(x=out[9,seq(2,18,by=2)],y=8:0, pch=16, col="black",cex=1)  
	
	# axis
	axis(1,labels=c("-.15","0",".15"),at=c(-.15,0,.15), las=FALSE, tick=TRUE, cex.axis = 1, family = "Times")

	
# DONATION TO CWF
	# empty plot
	plot(x=c(), y=c(), ylim=c(0,8.3), xlim=c(-.5, .5), yaxt="n", xaxt="n",frame.plot=FALSE,xlab="", ylab="", main="Donation to CWF", cex.main=.75, family = "Times")
	lines(x=c(0,0),y=c(-.1,8.3),lty=2,col="black")
	
	# plot CIs 
	n=1
	for (i in seq(2,18,by=2)) {		
		lines(x=c(out[10,i]-1.96*out[10,i+1],out[10,i]+1.96*out[10,i+1]),y=c(9-n,9-n), col="gray", lwd=2)
	n=n+1
	}
	
	# plot point estimates 
	points(x=out[10,seq(2,18,by=2)],y=8:0, pch=16, col="black",cex=1)  
	
	# axis
	axis(1,labels=c("-.3","0",".3"),at=c(-.3,0,.3), las=FALSE, tick=TRUE, cex.axis = 1, family = "Times")

	
dev.off()


