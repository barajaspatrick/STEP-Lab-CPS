###############################################################################
###############################################################################

## ENTER PARTICIPANT NUMBER ## EXAMPLE: participant = 12

participant = 12


###############################################################################
###############################################################################

library(lubridate)
library(data.table)
library(dplyr)
library(reshape2)

setwd("~/Documents/STEP_Lab/Clean_Data")
df <- read.csv2("NoldusTimes.csv", sep = ",", header = TRUE)

df <- df %>% filter(ParticipantNum == participant)%>%
        select(IncorrectDet)

df <- df[1,1]
df <- as.character(df)
df1 <- strsplit(df, ",")
df1 <- df1[[1]]

h <- data.frame()
for (i in 1:length(df1)){
        g <- colsplit(df1[i], "-", names = c("startinc", "endinc"))
        h <- rbind(h, g)
}

h <- h[complete.cases(h), ] ## remove rows with NA values
print(h[,1])
print(h[,2])

h$startinc <- ms(h$startinc)
h$endinc <- ms(h$endinc)

###############################################################################
###############################################################################

## subset only nessesary columns

ptdf <- read.csv("./Test_Data/pt12.csv", header = TRUE, skip = 8, na.strings = c("FIT_FAILED",
                                                                                 "FIND_FAILED", "NotAnalyzed"))
ptdf <- ptdf[, c("Video.Time", "Neutral", "Happy", "Sad", "Angry", 
                        "Surprised",  "Scared", "Disgusted", "Contempt")]

## convert 'Video.time' over to period value
ptdf$Video.Time <- ms(ptdf$Video.Time)

## we now have both raw files we need in order to subset correctly detected data. 

for (i in 1:nrow(h)) {
        print(i)
        ptdf <- subset(ptdf, !(h[i, "startinc"] < Video.Time & Video.Time < h[i, "endinc"]))
}   

ptdf <- na.omit(ptdf)


