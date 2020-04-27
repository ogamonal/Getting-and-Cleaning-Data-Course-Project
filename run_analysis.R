
# 1 - Downloading the zip file
CurrentDirectory <- getwd()
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
DataFileName <- "./UCI HAR Dataset.zip"
download.file(fileURL,destfile = DataFileName)

# 2 - Unzip the file
unzip(zipfile = DataFileName)
DataDirectory <- "./UCI HAR Dataset/"

# 3 - Reading Activity Labels and Features
library(data.table)
txtactivityLabels <- fread(file.path(DataDirectory, "activity_labels.txt"),
                        col.names = c("NumberActivity", "LabelActivity"))
txtfeatures <- fread(file.path(DataDirectory, "features.txt")
                  , col.names = c("Position", "featureNames"))

# 4 - Extract only the measurements on the mean and standard deviation for each measurement.
FinalFeatures <- grep("(mean|std)\\(\\)", txtfeatures[, featureNames])
meanstdev <- txtfeatures[FinalFeatures, featureNames]
meanstdev <- gsub('[()]', '', meanstdev)

# 5 - Read training sets
trainingset <- fread(file.path(DataDirectory, "train/X_train.txt"))[, FinalFeatures, with = FALSE]
data.table::setnames(trainingset, colnames(trainingset), meanstdev)
trainActivities <- fread(file.path(DataDirectory, "train/Y_train.txt")
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path(DataDirectory, "train/subject_train.txt"), col.names = c("VolunteerNumber"))
trainingset <- cbind(trainSubjects, trainActivities, trainingset)

# 6 - Read testing sets
testingset <- fread(file.path(DataDirectory, "test/X_test.txt"))[, FinalFeatures, with = FALSE]
data.table::setnames(testingset, colnames(testingset), meanstdev)
testActivities <- fread(file.path(DataDirectory, "test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(DataDirectory, "test/subject_test.txt")
                      , col.names = c("VolunteerNumber"))
testingset <- cbind(testSubjects, testActivities, testingset)

# 7 - Merge the training and the test sets to create one data set.
mergeddatasets <- rbind(trainingset, testingset)

#  - Uses descriptive activity names to name the activities in the data set
# 8 - Appropriately labels the data set with descriptive variable names.
mergeddatasets[["Activity"]] <- factor(mergeddatasets[, Activity]
                                 , levels = activityLabels[["NumberActivity"]]
                                 , labels = activityLabels[["LabelActivity"]])

mergeddatasets[["VolunteerNumber"]] <- as.factor(mergeddatasets[, VolunteerNumber])
mergeddatasets <- reshape2::melt(data = mergeddatasets, id = c("VolunteerNumber", "Activity"))
mergeddatasets <- reshape2::dcast(data = mergeddatasets, VolunteerNumber + Activity ~ variable, fun.aggregate = mean)

# 9 - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
write.table(x = mergeddatasets, file = "tidyData.txt", sep = ",", row.names = FALSE)

