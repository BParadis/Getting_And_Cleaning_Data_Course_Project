# download and unzip the dataset:
if(!file.exists("./data")){dir.create("./data")}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL,destfile="./data/Dataset.zip")
unzip(zipfile="./data/Dataset.zip",exdir="./data")
path_rf <- file.path("./data" , "UCI HAR Dataset")
files <- list.files(path_rf, recursive = TRUE)

# read the activity data
ActivityTest <- read.table(file.path(path_rf, "test", "Y_test.txt"), header = FALSE)
ActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"), header = FALSE)

# read the features data
FeaturesTest <- read.table(file.path(path_rf, "test", "X_test.txt"), header = FALSE)
FeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"), header = FALSE)
FeaturesNames <- read.table(file.path(path_rf, "features.txt"), header = FALSE)

# read the subject data
SubjectTest <- read.table(file.path(path_rf, "test", "subject_test.txt"), header = FALSE)
SubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"), header = FALSE)

# merge the data tables by rows
DataActivity <- rbind(ActivityTest, ActivityTrain)
DataFeatures <- rbind(FeaturesTest, FeaturesTrain)
DataSubject <- rbind(SubjectTest, SubjectTrain)

# set names to the variables
names(DataActivity) <- c("activity")
names(DataSubject) <- c("subject")
names(DataFeatures) <- FeaturesNames$V2

# merge the columes to get the data frame
DataCombine <- cbind(DataSubject, DataActivity)
Data <- cbind(DataFeatures, DataCombine)

# subset name of features by measurements on the mean and standard deviation
subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]

# subset the data frame by names of Features
SelNames <- c(as.character(subFeaturesNames), "subject", "activity")
Data <- subset(Data, select = SelNames)

# read descriptive activity names from "activity_labels.txt"
ActivityLabels <- read.table(file.path(path_rf, "activity_labels.txt"), header = FALSE)

# include activity variables into the dataset
Data$activity <- factor(Data$activity);
Data$activity <- factor(Data$activity, labels = as.character(ActivityLabels$V2))

# using the README.txt included with the dataset, appropriately lable the data with descriptive variable names
names(Data) <- gsub("^t", "time", names(Data))
names(Data) <- gsub("^f", "frequency", names(Data))
names(Data) <- gsub("Acc", "Accelerometer", names(Data))
names(Data) <- gsub("Gyro", "Gyroscope", names(Data))
names(Data) <- gsub("Mag", "Magnitude", names(Data))
names(Data) <- gsub("BodyBody", "Body", names(Data))

# make a new tidy data set
NewData <- aggregate(. ~subject + activity, Data, mean)
NewData <- NewData[order(NewData$subject, NewData$activity),]

# write the new table
write.table(NewData, file = "newtidydata.txt", row.name = FALSE)

