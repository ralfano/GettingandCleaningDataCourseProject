library(data.table)

setwd(".\\my\\Coursera - Data_Science\\3. Data Cleaning\\week2\\getdata-projectfiles-UCI HAR Dataset\\UCI HAR Dataset")

##Read the activities label:
df_activity_labels <- read.table("activity_labels.txt")
##Rename the activity labels table columns:
names(df_activity_labels)[names(df_activity_labels) == "V1"] = "Activity"
names(df_activity_labels)[names(df_activity_labels) == "V2"] = "Activity_Name"

##Read the features
df_features <- read.table("features.txt",stringsAsFactors = FALSE)

##Read the test subset
setwd(".\\test")
df_X_test <- read.table("X_test.txt")
df_Y_test <- read.table("Y_test.txt")
df_subject_test <- read.table("subject_test.txt")

##Read the train subset
setwd("..\\train")
df_X_train <- read.table("X_train.txt")
df_Y_train <- read.table("Y_train.txt")
df_subject_train <- read.table("subject_train.txt")

##transform the datasets into data.table
table.test <- data.table (Activity=df_Y_test,Subject=df_subject_test,df_X_test)
table.train <- data.table (Activity=df_Y_train,Subject=df_subject_train,df_X_train)

##merge the 2 datasets
table.all <- rbind (table.test, table.train)
##Rename the activity field and subject (by default it has .V1 suffix)
setnames(table.all,"Activity.V1", "Activity")
setnames(table.all,"Subject.V1", "Subject")

##join the dataset with the Activity labels table:
table.all.withactivity <- merge (table.all,df_activity_labels,by="Activity")

##Attach to the dataset the name of the measure
for (v in 1:561) setnames(table.all.withactivity, paste("V",v, sep=""), as.character(df_features[v,"V2",drop=FALSE]))

##select only mean and std measures names to keep
df_features.only_mean_and_std <- df_features [grepl("mean\\(\\)",df_features$V2) | grepl("std\\(\\)",df_features$V2),"V2"]

##add to the vector of the columns to keep the Activity_Name and the subject
df_features.only_mean_and_std <- c(df_features.only_mean_and_std, "Activity_Name", "Subject")

table.final <- table.all.withactivity[,as.vector(df_features.only_mean_and_std),with=FALSE]

##Calculate the mean by Activity and Subject
setkey(table.final,Activity_Name)
setkey(table.final,Subject)

table.final.mean <- table.final[,lapply(.SD,mean),by=list(Activity_Name,Subject)]

setwd("..\\")

write.table(table.final.mean,"tidydataset.txt",row.name=FALSE)





