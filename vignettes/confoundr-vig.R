## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- eval = FALSE, include = FALSE--------------------------------------
#  ##########################
#  ##LOAD DATA AND PACKAGES##
#  ##########################
#  
#  #NOTE THAT THIS CODE REQUIRES R VERSION 3.1.2 OR HIGHER
#  
#  library(magrittr) #last tested on magrittr v1.5
#  library(tidyr)    #last tested on tidyr v0.6.0
#  library(dplyr)    #last tested on dplyr v0.5.0
#  library(ggplot2)  #last tested on ggplot2 v2.1.0
#  library(grid)     #this comes with base R
#  library(gridExtra)#last tested on gridExtra v2.0.1
#  library(scales)   #last tested on ggplot2 v0.4.0
#  library(Rmpfr)    #last tested on Rmpfr v0.6-0
#  library(broom)    #last tested on broom v0.4.1
#  library(confoundr)
#  library(readr)
#  path = "../data"
#  #for mac use one slash
#  fname = file.path(path, "example_sml.csv")
#  indata.small <- readr::read_csv(fname)
#  #indata.large <- read.csv(paste(path,"example_lrg.csv",sep=""))
#  
#  #####################################################################
#  ##Example: Diagnostic 3 for a time-varying exposure without censoring
#  #####################################################################
#  
#  #PRELIMINARY STEP: MAKE EXPOSURE HISTORY
#  mydata <- indata.small
#  mydata.history <- makehistory.one(input=mydata,id = "id", exposure="a",name.history="h",times=c(0,1,2))
#  
#  #STEP 1: RESTRUCTURE THE DATA
#  mydata.long <- lengthen(
#    input=mydata.history,
#    diagnostic=3,
#    censoring="no",
#    id="id",
#    times.exposure=c(0,1,2),
#    times.covariate=c(0,1,2),
#    exposure="a",
#    temporal.covariate=c("l","m","o"),
#    static.covariate=c("n","p"),
#    history="h",
#    weight.exposure="wax"
#  )
#  
#  #example of how to remove relative covariate history
#  mydata.long.omit <- omit.history(input=mydata.long,
#    omission="relative",
#    covariate.name=c("l","m","o"),
#    distance=1
#    )
#  
#  #STEP 2: CREATE BALANCE TABLE
#  mytable <- balance (
#  input=mydata.long.omit,
#  diagnostic	=3,
#  approach="weight",
#  censoring="no",
#  scope="all",
#  times.exposure=c(0,1,2),
#  times.covariate=c(0,1,2),
#  exposure="a",
#  history="h",
#  weight.exposure="wax",
#  sort.order= c("l","m","o","n","p")
#  )
#  
#  #STEP 3: PLOT BALANCE METRIC
#  myplot <- makeplot (
#  input=mytable,	
#  diagnostic	=3,
#  approach="weight",
#  scope="all",
#  metric="SMD"
#  )
#  #The following formatting arguments for makeplot() are optional (defaults shown).
#  
#  #label.exposure="A",							#exposure label
#  #label.covariate="C",							#covariate label
#  #lbound=-1,									    	#lower bound for x-axis
#  #ubound=1,										  	#upper bound for x-axis
#  #ratio=2,										    	#plot aspect ratio
#  #text.axis.title=8,								#title font size
#  #text.axis.y=6.5,									#y-axis (covariate names) font size
#  #text.axis.x=6.5,									#x-axis font size	
#  #text.strip.y=10,									#row panel label font size
#  #text.strip.x=10,									#column panel label font size
#  #point.size=.75,									#dot size
#  #zeroline.size=.1,								#thickness of zero line on x-axis
#  #refline.size=.1,									#thickness of reference line on x-axis
#  #refline.limit.a=-.25,						#location for reference line 1 on x-axis
#  #refline.limit.b=0.25,						#location for reference line 2 on x-axis
#  #panel.margin.size=.75,						#space between panels
#  #axis.title="Mean Difference",    #or "Standardized Mean Difference" (x-axis title)
#  #label.width=15									  #width of panel label text (before wrapping text)
#  
#  #STEP 4: SAVE BALANCE TABLE AND PLOT
#  #write.csv(mytable,paste(path,"mytable.csv",sep=""))
#  #ggsave(filename=paste(path,"myplot.pdf",sep=""))
#  
#  
#  
#  #################################################
#  ##Example of Regression Approach for Diagnostic 1
#  #################################################
#  
#  library(broom) #need for tidy()
#  
#  #create balance dataset
#  mydata.long <- lengthen(input=mydata,
#    diagnostic=1,
#    censoring="no",
#    id="id",
#    times.exposure=c(0,1,2),
#    times.covariate=c(0,1,2),
#    exposure="a",
#    temporal.covariate=c("l","m","n","o","p"),
#    history="h"
#  )
#  
#  ##MAKE BALANCE TABLE USING REGRESSION##
#  
#  #create balance table
#  mydata.long.reg <- mutate(mydata.long,time=time.exposure,distance=time.exposure-time.covariate,history=h)
#  output <- mydata.long.reg %>%
#    group_by(name.cov) %>% #note, you can include other stratifying variables here or in the model
#      filter(time.exposure>=time.covariate) %>%
#        do(tidy(lm(formula=value.cov~a+time+distance+history,.))) %>% #same model form used for every covariate
#          filter(term=="a1") %>% ungroup()
#  
#  table.reg <- output %>%
#                 select(name.cov,estimate) %>%
#                   rename_("D"="estimate")
#  
#  print(table.reg)
#  #write.csv(table.reg,paste(path,"table_regression.csv"))
#  #NOTE: This code applies the same model parameterization for each covariate (relying on a strong assumption).
#  
#  ### COMPARE THAT TO A DIRECT CALCULATION & STANDARDIZATION ###
#  
#  table.std <- balance(input=mydata.long,
#    diagnostic=1,
#    approach="none",
#    censoring="no",
#    scope="average",
#    average.over="distance",
#    times.exposure=c(0,1,2),
#    times.covariate=c(0,1,2),
#    exposure="a",
#    history="h"
#  )
#  
#  print(table.std)
#  #write.csv(table.std,paste(path,"table_standardization.csv"))
#  

