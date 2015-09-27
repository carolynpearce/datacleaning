---
title: "Codebook"
author: "carolynpearce"
date: "Sunday, September 27, 2015"
output: html_document
---

The program initially sets all of the file paths.

```{r}
xTrainFilePath <- "./UCI HAR Dataset/train/X_train.txt"
yTrainFilePath <- "./UCI HAR Dataset/train/y_train.txt"
subjectTrainFilePath <- "./UCI HAR Dataset/train/subject_train.txt"
xTestFilePath <- "./UCI HAR Dataset/test/X_test.txt"
yTestFilePath <- "./UCI HAR Dataset/test/y_test.txt"
subjectTestFilePath <- "./UCI HAR Dataset/test/subject_test.txt"
featuresFilePath <- "./UCI HAR Dataset/features.txt"
activityLabelsFilePath <- "./UCI HAR Dataset/activity_labels.txt"
```

Each file is then loaded into a data table. The variables are named to indicate the data that they contain.


```{r}
xTrain <- data.table(read.table(xTrainFilePath))
yTrain <- data.table(read.table(yTrainFilePath))
subjectTrain <- data.table(read.table(subjectTrainFilePath))

xTest <- data.table(read.table(xTestFilePath))
yTest <- data.table(read.table(yTestFilePath))
subjectTest <- data.table(read.table(subjectTestFilePath))

features <- data.table(read.table(featuresFilePath))
activityLabels <- data.table(read.table(activityLabelsFilePath))
```


Next, the program adds columns to xTrain and yTrain. The variable ActivityId is added from yTrain and yTest to xTrain and xTest, respectively, to indicate which activity was being performed for each observation of data. 

The variable VolunteerId is added from subjectTrain and subjectTest to xTrain and xTest, respectively, to match each observation with its subject/volunteer.

```{r}
## get number of rows in each training set. This count is to be used when adding columns to the data sets
trainRowCount <- nrow(xTrain)
testRowCount <- nrow(xTest)

## add a variable indicating whether or not this observation is from the training or test data set
xTrain$TrainOrTest <- rep("Train",trainRowCount)
xTest$TrainOrTest <- rep("Test", testRowCount)

## add activity being performed to each observation of the training and test data sets
xTrain$ActivityId <- yTrain
xTest$ActivityId <- yTest

## add subject/volunteer id to each observation of the training and test data sets
xTrain$VolunteerId <- subjectTrain
xTest$VolunteerId <- subjectTest
```

At this point, there are two primary data tables being used -- one for the training data (xTrain), and one for the test data (xTest). The next step row binds these two data tables together.

```{r}
## row bind the training and test data tables to make one complete table
mergedDt <- rbind(xTrain, xTest)
```

Now, there is one dataset that contains all observations for the test and training data. For each observation, the activiy being performed and subject performing the activity is known.

Only columns that contain mean or std information are going to be used, so this step filters out all of the other columns using a logical vector.

```{r}
## filter out non mean or std columns

## get all of the feature names, cast as character vector
newNames <- as.character(features[,V2])

## use a regular expression to create a logical vector indicating which strings in the newNames 
## contain information about mean or std
logicalVector <- grepl("mean|std|Mean",newNames)

## append 3 TRUE values for the 3 columns added before (TrainOrTest, ActivityId, and VolunteerId)
logicalVector <- append(logicalVector,c(TRUE, TRUE, TRUE))

## subset the merged data set to get only those columns that contain information about mean or std
subsetData <- subset(mergedDt, select = logicalVector)
```

At this point, we have a data table that 1) contains all training and test observations, 2) has activity and subject information available for each observation, and 3) only contains feature variables that are about mean or standard deviation.

Next, substitute the factor levels with more descriptive factor labels for the Activity Variable.

```{r}
# Add activity description
subsetData$ActivityId <- as.factor(subsetData$ActivityId)

## get labels from the activityLabels data table
levels(subsetData$ActivityId) <- as.character(activityLabels[,V2])
```

Then, replace undescriptive header names for the feature variables with the correct feature names

```{r}
logicalVector <- grepl("mean|std|Mean",newNames)
## these are the names of the features that are about mean and std
featureSubset <- subset(newNames, logicalVector)

## get the current undescriptive names of all of the feature variables in the data table
oldNames <- names(subsetData)[1:86]

## replace the old names with the more descriptive feature names
setnames(subsetData, old=oldNames, new=featureSubset)
```

Finally, get the average of each feature grouped by the activity being performed and the volunteer performing that activity.

```{r}
subsetAvg <- select(subsetData,-TrainOrTest) %>% group_by(ActivityId, VolunteerId) %>% summarize_each(c("mean"))
```