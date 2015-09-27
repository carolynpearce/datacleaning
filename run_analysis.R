
## list file paths
xTrainFilePath <- "./UCI HAR Dataset/train/X_train.txt"
yTrainFilePath <- "./UCI HAR Dataset/train/y_train.txt"
subjectTrainFilePath <- "./UCI HAR Dataset/train/subject_train.txt"

xTestFilePath <- "./UCI HAR Dataset/test/X_test.txt"
yTestFilePath <- "./UCI HAR Dataset/test/y_test.txt"
subjectTestFilePath <- "./UCI HAR Dataset/test/subject_test.txt"

featuresFilePath <- "./UCI HAR Dataset/features.txt"
activityLabelsFilePath <- "./UCI HAR Dataset/activity_labels.txt"

## read all data
xTrain <- data.table(read.table(xTrainFilePath))
yTrain <- data.table(read.table(yTrainFilePath))
subjectTrain <- data.table(read.table(subjectTrainFilePath))

xTest <- data.table(read.table(xTestFilePath))
yTest <- data.table(read.table(yTestFilePath))
subjectTest <- data.table(read.table(subjectTestFilePath))

features <- data.table(read.table(featuresFilePath))
activityLabels <- data.table(read.table(activityLabelsFilePath))


## check out the dimensions
dim(xTrain)
dim(yTrain)
dim(subjectTrain)

dim(xTest)
dim(yTest)
dim(subjectTest)

## bind columns to xTrain and xTest indicating test or train
trainRowCount <- nrow(xTrain)
testRowCount <- nrow(xTest)

xTrain$TrainOrTest <- rep("Train",trainRowCount)
xTest$TrainOrTest <- rep("Test", testRowCount)

xTrain$ActivityId <- yTrain
xTest$ActivityId <- yTest

xTrain$VolunteerId <- subjectTrain
xTest$VolunteerId <- subjectTest

## combine two datasets

mergedDt <- rbind(xTrain, xTest)
dim(mergedDt)

## filter out non mean or std columns
newNames <- as.character(features[,V2])
logicalVector <- grepl("mean|std|Mean",newNames)
logicalVector <- append(logicalVector,c(TRUE, TRUE, TRUE))
subsetData <- subset(mergedDt, select = logicalVector)

# Add activity description
subsetData$ActivityId <- as.factor(subsetData$ActivityId)
levels(subsetData$ActivityId) <- as.character(activityLabels[,V2])


## Add descriptive Variable names
logicalVector <- grepl("mean|std|Mean",newNames)
featureSubset <- subset(newNames, logicalVector)

oldNames <- names(subsetData)[1:86]

setnames(subsetData, old=oldNames, new=featureSubset)
head(subsetData)


subsetAvg <- select(subsetData,-TrainOrTest) %>% group_by(ActivityId, VolunteerId) %>% summarize_each(c("mean"))
