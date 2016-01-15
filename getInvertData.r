require(RODBC)
benthicDBpath<-"N:/DWM 'toolbox'/Benthic_techMemo/MAbenthosFinalMR.mdb"
ch2<-odbcConnectAccess2007(benthicDBpath)

tblBenSamp<-sqlFetch(ch2, "BenSamp")
projects<-unique(tblBenSamp$ProjectCode)
projects<-as.character(projects)

matrixInverts<-function(df) {
df.sql.t<-t(df)
df.sql.t<-df.sql.t[-c(1,3,4),]     #remove unwanted rows
colnames(df.sql.t) <- df.sql.t[1,]   #use first row for column names
df.sql.t<-df.sql.t[-(1),]             #first row no longer needed remove
df.sql.t[is.na(df.sql.t)] <- 0      #if cell is equal to NA replace with zero
mode(df.sql.t)<-"numeric"         #currently character matrix convert to numeric
df.sql.t
}