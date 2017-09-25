library(reshape2)

filename <- "UCI_HAR_data.zip"

## Download and unzip the dataset
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Merge the training and the test sets to create one data set.
train <- read.table("UCI HAR Dataset/train/X_train.txt")
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

allData <- rbind(train, test)

# Extract only the measurements on the mean and standard deviation for each measurement.
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])
meanStd <- grep(".*mean.*|.*std.*", features[,2])
meanStd.names <- features[meanStd,2]
meanStd.names = gsub('-mean', 'Mean', meanStd.names)
meanStd.names = gsub('-std', 'Std', meanStd.names)
meanStd.names <- gsub('[-()]', '', meanStd.names)
allData <- allData[c(1,2,meanStd)]

# Use descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names.

activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
colnames(allData) <- c("subject", "activity", meanStd.names)
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

# From the data set in step 4, creates a second, independent tidy data set with the average 
# of each variable for each activity and each subject.
allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

# Write a tidy data file
write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
