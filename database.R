
# principal goal of code is to connect to access database with data and extract dataframe of lab data

#load the necessary pacakges
require(RODBC)
require(lubridate)
require(dplyr)

#using the RODBC package load in the datatbase
ch <- odbcConnectAccess2007("N:\\DWM 'toolbox'\\SMART\\WPP_WQData_2005-2012-MLTmod_mr.accdb")

#get a data frame of the lab data
df <- sqlFetch(ch, sqtable = "lab data - main", na.strings = "NA",   as.is = TRUE)

#fix the StartDate (the sampling date) from character into a POSIX format date using package lubridate
df$StartDate <- mdy(df$StartDate)

# make the Projname, Watershed fields into factors
df$Projname<-as.factor(df$Projname)
df$Watershed<-as.factor(df$Watershed)

# make sure that Latitude and Longitude fields that are currently text get converted into numerics
df$Latitude<-as.numeric(df$Latitude)
df$Longitude<-as.numeric(df$Longitude)

close(ch)