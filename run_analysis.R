# library
library(dplyr)
library(tidyr)

# Create a data director and download the data
if(!dir.exists("data")) dir.create("data")
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "data/dataset.zip")

# unzip the downloaded file
unzip("data/dataset.zip", exdir = "data")

# load activity and feature labels
activity_labels <- read.delim("data/UCI HAR Dataset/activity_labels.txt", sep=" ", header=F, col.names=c("activity_id", "activity"))
feature_labels <- read.delim("data/UCI HAR Dataset/features.txt", sep=" ", header=F, col.names=c("id", "feature"))

# load train and test data
test_subject <- read.delim("data/UCI HAR Dataset/test/subject_test.txt", header=F, col.names = c("subject"))
test_activity <- read.delim("data/UCI HAR Dataset/test/y_test.txt", header=F, col.names = c("activity_id"))
test_features <- read.fwf("data/UCI HAR Dataset/test/X_test.txt", rep.int(16, 561), col.names = feature_labels$feature)

train_subject <- read.delim("data/UCI HAR Dataset/train/subject_train.txt", header=F, col.names = c("subject"))
train_activity <- read.delim("data/UCI HAR Dataset/train/y_train.txt", header=F, col.names = c("activity_id"))
train_features <- read.fwf("data/UCI HAR Dataset/train/X_train.txt", rep.int(16, 561), col.names = feature_labels$feature)

# combine data
test <- cbind(test_subject, test_activity, test_features)
test <- mutate(test, group = "test", .after = activity_id)

train <- cbind(train_subject, train_activity, train_features)
train <- mutate(train, group = "train", .after = activity_id)

result <- rbind(test, train)

# fix names
n = names(result)
n <- sub("\\.{2,}", ".", n)
n <- sub("\\.$", "", n)

names(result) <- n

# replace activity ids with names
result <- left_join(result, activity_labels)
result <- relocate(result, activity, .after=subject)
result <- mutate(result, activity = tolower(activity))

# removing unnecessary columns
result <- select(result, subject, activity, contains("mean"), contains("std"))

# remove unnecessary variables
rm("test", "train", "test_subject", "test_activity", "test_features",
   "train_subject", "train_activity", "train_features", "activity_labels",
   "feature_labels", "n")

# creating the final dataset
result2 <- result %>% group_by(subject, activity) %>% summarise_each(mean)

# write final dataset to file
write.csv(result2, "tidy.csv")

