library(dplyr)
library(reshape2)

if (!file.exists("./Project")) {
        dir.create("./Project")
}

if(!file.exists("./Project/raw_data.zip")) {
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, "./Project/raw_data.zip", mode = "wb")
        unzip("./Project/raw_data.zip", exdir = "./Project")
}

# 1. part
X_train_path <- file("./Project/UCI HAR Dataset/train/X_train.txt")
X_test_path <- file("./Project/UCI HAR Dataset/test/X_test.txt")
y_train_path <- file("./Project/UCI HAR Dataset/train/y_train.txt")
y_test_path <- file("./Project/UCI HAR Dataset/test/y_test.txt")
subject_train_path <- file("./Project/UCI HAR Dataset/train/subject_train.txt")
subject_test_path <- file("./Project/UCI HAR Dataset/test/subject_test.txt")
features_path <- file("./Project/UCI HAR Dataset/features.txt")

features <- read.table(features_path)
train <- cbind(read.table(subject_train_path), read.table(y_train_path), read.table(X_train_path))
test <- cbind(read.table(subject_test_path), read.table(y_test_path), read.table(X_test_path))
names(train) <- c("subject", "activity", as.character(features[, 2]))
names(test) <- c("subject", "activity", as.character(features[, 2]))
dataset <- tbl_df(rbind(train, test))

# 2. part
mean_std <- grep("mean()|std()", names(dataset), value = T)
mean_std <- c("subject", "activity", mean_std)
dataset <- dataset[, !duplicated(colnames(dataset))]
ex_dataset <- select(dataset, one_of(mean_std)) 

# 3. part
activities_path <- file("./Project/UCI HAR Dataset/activity_labels.txt")
activities <- read.table(activities_path)
ex_dataset <- data.frame(ex_dataset)
ex_dataset[, "activity"] <- factor(ex_dataset[, "activity"], levels = activities[, 1], labels = activities[, 2])

# 4. part
names(ex_dataset) <- gsub("^t", "time", names(ex_dataset))
names(ex_dataset) <- gsub("^f", "frequency", names(ex_dataset))
names(ex_dataset) <- gsub("Acc", "Accelerometer", names(ex_dataset))
names(ex_dataset) <- gsub("Gyro", "Gyroscope", names(ex_dataset))
names(ex_dataset) <- gsub("Mag", "Magnitude", names(ex_dataset))
names(ex_dataset) <- gsub("BodyBody", "Body", names(ex_dataset))

# 5.part
tidy_ds <- melt(ex_dataset, id = c("subject", "activity"))
tidy_ds <- dcast(tidy_ds, subject + activity ~ variable, mean)

write.table(tidy_ds, "./Project/tidy_dataset.txt", row.names = F)
