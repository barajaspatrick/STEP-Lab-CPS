library(lubridate)
library(data.table)
library(dplyr)
library(reshape2)


participant = 5 ## this is the starting participant

fileList <- list.files("./Test_Data")


##broken: 41, 61, 62, 63, 64
##missing: 54, 57
##for missing files, a blank dummy csv is inserted into the test folder
## 69 not finished writing down time, discard

for (i in 1:length(fileList)) {  
        fileName <- paste("./Test_Data/", fileList[i], sep="")
        print(fileName)
        print(participant)

        setwd("~/Documents/STEP_Lab/Clean_Data")
        df <- read.csv2("NoldusTimes.csv", sep = ",", header = TRUE)
        
        ## select rows based on participant number
        df <- df %>% filter(ParticipantNum == participant)%>%
                select(IncorrectDet)

        df <- df[1,1]
        df <- as.character(df)
        df1 <- strsplit(df, ",")
        df1 <- df1[[1]]
        
        if (length(df1) > 0) {
        
                h <- data.frame()
                for (n in 1:length(df1)){
                        g <- colsplit(df1[n], "-", names = c("startinc", "endinc"))
                        h <- rbind(h, g)
                }
                # print(h)
                
                h <- h[complete.cases(h), ] ## remove rows with NA values
                
                
                if (!is.null(h$startinc) & !is.null(h$endinc)) {
                        
                        h$startinc <- ms(h$startinc)
                        h$endinc <- ms(h$endinc)
                       
                        ## subset only nessesary columns
                        ptdf <- read.csv(fileName, header = TRUE, skip = 8, na.strings = c("FIT_FAILED",
                                "FIND_FAILED", "NotAnalyzed")) 
                        ptdf <- ptdf[, c("Video.Time", "Neutral", "Happy", "Sad", "Angry", 
                                         "Surprised",  "Scared", "Disgusted", "Contempt")] 
                        
                        ## convert 'Video.time' over to period value
                        ptdf$Video.Time <- ms(ptdf$Video.Time) 
                        
                        ## we now have both raw files we need in order to subset correctly detected data. 
                        
                        for (j in 1:nrow(h)){
                                ptdf <- subset(ptdf, !(h[j, "startinc"] < Video.Time & Video.Time < h[j, "endinc"]))
                        }
                        
                }
                
                ptdf <- na.omit(ptdf)
                print(fileList[i])
                write.csv(ptdf, paste("cleaned", fileList[i], sep = "_"))
                
        }
        
        participant <- participant+1
} 

