# ------------------------------------- Linear Modeling ---------------------------------#

# A. All relevant variables
a100 <- subset(airData, select = -c(olong,olat,dlat,dlong, Destination.State,Origin.State,Orgin.City, Destination.City,Flight.date, Partner.Code, recommend_name))
lmET <- lm(formula = Likelihood.to.recommend ~ ., data = a100)
summary(lmET) # Note: Adjusted R-Squared = 0.4072

summary(lm(formula = Likelihood.to.recommend ~ Type.of.Travel, data = a100)) # Type.of.Travel having the most influence

# B. Statistically Significant attributes only
# Airline.Status, Age, Gender, Price.Sensitivity, Years.of.First.Fight, Type.of.Travel, Shopping.Amount.at.Airport, Total.Freq.Flyer.Accts, Class, Day.of.Month, Partner.Name, Flight.time.in.minutes, departure_delay_long  
lmStatSig <- lm(formula = Likelihood.to.recommend ~ Airline.Status + Age + Gender + 
                    Price.Sensitivity + Year.of.First.Flight + Type.of.Travel +
                    Shopping.Amount.at.Airport + Total.Freq.Flyer.Accts + Class + 
                    Day.of.Month + Partner.Name + Flight.time.in.minutes + departure_delay_long, data = a100)
summary(lmStatSig) # Note: Adjusted R-Squared = 0.4064, Actually went down! Makes sense because only one in the partner names was stat sig

# C. Stat significant, and coefficient larger or equal to 0.1
# Airline.Status + Gender + Price.Sensitivity + Type.of.Travel + Class + Partner.Name + departure_delay_long
lmStatSigCoeff <- lm(formula = Likelihood.to.recommend ~Airline.Status + Gender + 
                         Price.Sensitivity + Type.of.Travel + Class + Partner.Name + departure_delay_long, data = a100)
summary(lmStatSigCoeff) # Adjusted R-squared = 0.4012
# The variables in the final linear model have comparable adjusted R-Square with all relevant variables model
# only 40% of the variability can be explained with our data

# ---------------------------------Apriori --------------------------------------------#
library(arules)
library(arulesViz)

# Remove attributes that wouldnt make sense to include
a <- subset(airData, select = -c(olong,olat,dlat,dlong, Flight.Distance, Flight.time.in.minutes, Departure.Delay.in.Minutes,Arrival.Delay.in.Minutes,
                                 Destination.City, Destination.State,Origin.State, Orgin.City, Year.of.First.Flight, Loyalty, Flight.date))
# transform subset into factors
a <- data.frame(lapply(a, as.factor))
str(a)
a$Airline.Status <- as.factor(a$Airline.Status)
a$Gender <- as.factor(a$Gender)
a$Type.of.Travel <- as.factor(a$Type.of.Travel)
a$Class <- as.factor(a$Class)
colSums(is.na(a))

# Apriori with all relevant attributes
ap100 <- subset(airData, select = -c(olong,olat,dlat,dlong, Destination.State,Origin.State,Orgin.City, Destination.City,Flight.date, Partner.Code, Likelihood.to.recommend))
ap100 <- data.frame(lapply(ap100, as.factor))
rules1 <- apriori(ap100,
                  parameter=list(supp=0.1, conf=0.5), 
                  control=list(verbose=F), # Report progress set to false
                  appearance=list(default = "lhs" ,rhs=("recommend_name=detractor")))

length(rules1) #20 rules for supp = 0.1, conf = 0.5
inspectDT(rules1)
# {Airline.Status=Blue,Gender=Female,Type.of.Travel=Personal Travel} --- 60% of the time with a frequency of 503 counts


# Subset statistically significant attributes
apStatSig <- subset(airData, select = c(Airline.Status, Age, Gender, Price.Sensitivity, Year.of.First.Flight, Type.of.Travel, 
                                      Shopping.Amount.at.Airport, Total.Freq.Flyer.Accts, Class, Day.of.Month, 
                                      Partner.Name, Flight.time.in.minutes, departure_delay_long, recommend_name))
apStatSig <- data.frame(lapply(apStatSig, as.factor))
str(apStatSig)
rules2 <- apriori(apStatSig,
                  parameter=list(supp=0.1, conf=0.5), 
                  control=list(verbose=F), # Report progress set to false
                  appearance=list(default = "lhs" ,rhs=("recommend_name=detractor")))
length(rules2) # 8 rules in total for detractor
inspectDT(rules2)

# Now for promoter apriori
# Apriori with all relevant attributes
ap100 <- subset(airData, select = -c(olong,olat,dlat,dlong, Destination.State,Origin.State,Orgin.City, Destination.City,Flight.date, Partner.Code, Likelihood.to.recommend))
ap100 <- data.frame(lapply(ap100, as.factor))
rules1 <- apriori(ap100,
                  parameter=list(supp=0.1, conf=0.5), 
                  control=list(verbose=F), # Report progress set to false
                  appearance=list(default = "lhs" ,rhs=("recommend_name=promoter")))

length(rules1) #684 rules for supp = 0.1, conf = 0.5
inspectDT(rules1)
# {Airline.Status=Blue,Gender=Female,Type.of.Travel=Personal Travel} --- 60% of the time with a frequency of 503 counts


# Subset statistically significant attributes
apStatSig <- subset(airData, select = c(Airline.Status, Age, Gender, Price.Sensitivity, Year.of.First.Flight, Type.of.Travel, 
                                        Shopping.Amount.at.Airport, Total.Freq.Flyer.Accts, Class, Day.of.Month, 
                                        Partner.Name, Flight.time.in.minutes, departure_delay_long, recommend_name))
apStatSig <- data.frame(lapply(apStatSig, as.factor))
str(apStatSig)
rules2 <- apriori(apStatSig,
                  parameter=list(supp=0.1, conf=0.5), 
                  control=list(verbose=F), # Report progress set to false
                  appearance=list(default = "lhs" ,rhs=("recommend_name=promoter")))
length(rules2) # 96 rules in total for detractor
inspectDT(rules2) 
# {Gender=Male,Price.Sensitivity=1,Type.of.Travel=Business travel,departure_delay_long=1} with greater than 70% confidence

# ------------------------Support Vector Machines --------------------# 
library(kernlab)
library(e1071)
# Subset only statistically significant variables
svmAir <- subset(airData, select = c(Airline.Status, Gender, Price.Sensitivity, Year.of.First.Flight, Type.of.Travel, 
                                    Shopping.Amount.at.Airport, Class, 
                                    Flight.time.in.minutes, departure_delay_long, recommend_name))
#isolate only promoters and detractors
svmAir <- svmAir[svmAir$recommend_name == "promoter" | svmAir$recommend_name == "detractor",]
svmAir <- droplevels(svmAir) # drops unused factor levels
levels(svmAir$recommend_name) # detractor = 1, promoter = 2

# Creating Training and test sets
trainList <- createDataPartition(y=svmAir$recommend_name,p=.60,list=FALSE) 
trainSet <- svmAir[trainList,] # 2124 observations, 60% of svmAir data
testSet <- svmAir[-trainList,] # 1415 observations, 40% of svmAir data

hardModel <- ksvm(recommend_name~., data = trainSet, kernel= "rbfdot", kpar = "automatic", C = 5, cross = 3, prob.model = TRUE)

hardModel
hardModelPred <- predict(hardModel,testSet, type = "response")

results <- table(hardModelPred,testSet$recommend_name)
results
# Error Rate:
1-sum(diag(results))/sum(results) #0.081
confusionMatrix(hardModelPred, testSet$recommend_name) 



# Subset only statistically significant variables
svmAir <- airData
svmAir <- subset(svmAir, select = c(Airline.Status, Gender, Price.Sensitivity, Year.of.First.Flight, Type.of.Travel, 
                                     Shopping.Amount.at.Airport, Total.Freq.Flyer.Accts, Class, 
                                     Flight.time.in.minutes, departure_delay_long, recommend_name))

softModel <- ksvm(recommend_name~., data = trainSet, kernel= "rbfdot", kpar = "automatic", C = 1, cross = 3, prob.model = TRUE)

softModel
softModelPred <- predict(softModel,testSet, type = "response")

softResults <- table(softModelPred,testSet$recommend_name)
# passive is still considered a factor level so we need to drop it in our results table
softResults
# Error Rate:
1-sum(diag(softResults))/sum(softResults) #0.081
confusionMatrix(softModelPred, testSet$recommend_name) # exact same results but with more information


# Svm- binary classification, now including passive passengers coupled with detractors and non-promoters
svmAir <- airData
svmAir$promoter_dummy <- ifelse(svmAir$recommend_name == "promoter", "promoter", "non-promoter")
svmAir <- subset(svmAir, select = c(Airline.Status, Gender, Price.Sensitivity, Year.of.First.Flight, Type.of.Travel, 
                                    Shopping.Amount.at.Airport, Total.Freq.Flyer.Accts, Class, 
                                    Flight.time.in.minutes, departure_delay_long, promoter_dummy))
svmAir <- data.frame(lapply(svmAir, as.factor))
svmAir <- svmAir[svmAir$promoter_dummy == "promoter" | svmAir$promoter_dummy == "non-promoter",] 
levels(svmAir$promoter_dummy) #check levels

# Due to the amount of attributes in our data set, partition 60% of the data to train
# Allows the model to learn the diverse segments that predict detractors from promoters
trainList <- createDataPartition(y=svmAir$promoter_dummy,p=.60,list=FALSE) 
trainSet <- svmAir[trainList,] # 2124 observations, 60% of svmAir data
testSet <- svmAir[-trainList,] # 1415 observations, 40% of svmAir data

?ksvm
hardModel <- ksvm(promoter_dummy~., data = trainSet, kernel= "rbfdot", kpar = "automatic", C = 5, cross = 3, prob.model = TRUE)

hardModel
hardModelPred <- predict(hardModel,testSet, type = "response")

results <- table(hardModelPred,testSet$promoter_dummy)
results
# Error Rate:
1-sum(diag(results))/sum(results) #0.081
confusionMatrix(hardModelPred, testSet$promoter_dummy) # exact same results but with more information

#-----
softModel <- ksvm(promoter_dummy~., data = trainSet, kernel= "rbfdot", kpar = "automatic", C = 1, cross = 3, prob.model = TRUE)

softModel
softModelPred <- predict(softModel,testSet, type = "response")

softResults <- table(softModelPred,testSet$promoter_dummy)
softResults
# Error Rate:
1-sum(diag(softResults))/sum(softResults) #0.081
confusionMatrix(softModelPred, testSet$promoter_dummy) # exact same results but with more information
