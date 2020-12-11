# interesting things to note

# Can subset specific Airline partners 
SEairData <- airData[which(airData$Partner.Name == 'Southeast Airlines Co.'),]

# summary statistics of shopping
summary(airData$Shopping.Amount.at.Airport)
# Mean    3rd Qu.  Max. 
# 27.09   30.00  540.00 

# identify number of flights leaving a particular state
sort(table(airData$Origin.State),decreasing = TRUE)

#identify number of flights arriving at a particular state
sort(table(airData$Destination.State),decreasing = TRUE)

# Most active to least active airline partner
sort(table((airData$Partner.Name)),decreasing = TRUE)

#-------------------------------------------Graphs---------------------------------------#
# Merge Attribute data and Likelihood Data

# see missing values : sum(is.na(x))
# replace missing mean 
# mydata$mean<- ifelse(is.na(mydata$mean), mydata$median, mydata$mean

#Exploring Age
min(airData$Age)
max(airData$Age)
hist(airData$Age, main = 'Ages of the Customers',xlab = 'Ages',border = 'black',col = 'lightblue',xlim = c(15,90),ylim = c(0,300),las = 1,breaks = 40,xaxt='n')
axis(side=1, at=seq(0,100, 1), labels=seq(0,100, 1))

#Drawing line trial
df = table(airData$Age)
df = data.frame(df)
lines(df$Var1, df$Freq)

#Airline Status Pie Chart
table(airData$Airline.Status)
ggplot(airData, aes(x="", y="", fill=Airline.Status)) + geom_bar(stat="identity", width=1) + coord_polar(theta = "y", start = 0) + scale_fill_manual(values = c("lightblue","gold", "lightgreen", "grey"))

#Gender percentage
prop.table(table(airData$Gender))

#Price sensitivity bar plot
table(airData$Price.Sensitivity)
counts <- table(airData$Price.Sensitivity)
barplot(counts, main="Price Sensitivity", xlab="Scale", border = 'black', col = 'lightblue',ylim = c(0,4000))

#Price sensitivity alternative chart
Cnt = data.frame(counts)
plot(Cnt$Var1, Cnt$Freq)
lines(Cnt$Var1, Cnt$Freq)

#Number of flights per year all
table(airData$Year.of.First.Flight)
counts <- table(airData$Year.of.First.Flight)
Cnt = data.frame(counts)
plot(Cnt$Var1, Cnt$Freq)
lines(Cnt$Var1, Cnt$Freq)

#Number flights per each partner
FLpartner <- airData[c(18,8)]
DFFL = data.frame(aggregate(FLpartner$Flights.Per.Year, by=list(Category=FLpartner$Partner.Name), FUN=sum))
df2 <- DFFL[order(DFFL$x),]

#Names of the partners could not be written below the bars.
barplot(df2$x, main="Price Sensitivity", xlab="Scale", border = 'black', col = 'lightblue', ylim = c(0,23000))
max(df2$x)

#Which partners got recommended
Rec_partner <- airData[c(18,27)]
Rec2 = data.frame(aggregate(Rec_partner$Likelihood.to.recommend, by=list(Category=Rec_partner$Partner.Name), FUN= "mean"))
Rec3 <- Rec2[order(Rec2$x),]
Rec4 <- Rec3 %>% mutate(recommend_name = cut(x, breaks = c(0,7,8, 11), labels = c("detractor", "passive", "promoter")))
Rec4 <- Rec4 + airData %>% group_by(Partner.Name) %>% summarize(LtR = mean(Likelihood.to.recommend), n = n()) %>% arrange(LtR)
Rec4
?boxplot

# testing boxplot function
boxplot(Likelihood.to.recommend ~ Gender, data = airData)
boxplot(Likelihood.to.recommend ~ Type.of.Travel, data = airData)
boxplot(Likelihood.to.recommend ~ Airline.Status + Type.of.Travel, data = airData)

# preference towards ggplot to add aesthetics

# Boxplots for relevant attribues vs Likelihood to recommend
ggplot(airData) + theme(text = element_text(size=40)) +
    geom_boxplot(aes(x = Gender, y = Likelihood.to.recommend, fill = factor(Gender))) + ggtitle("LtR vs Gender")
ggplot(airData) + theme(text = element_text(size=30)) +
    geom_boxplot(aes(x = Type.of.Travel, y = Likelihood.to.recommend, fill = factor(Type.of.Travel))) + ggtitle("LtR vs Type of Travel")
ggplot(airData) + theme(text = element_text(size=40)) +
    geom_boxplot(aes(x = Class, y = Likelihood.to.recommend, fill = factor(Class))) + ggtitle("LtR vs Class")

ggplot(airData) + theme(text = element_text(size=40)) +
    geom_boxplot(aes(x = Price.Sensitivity, y = Likelihood.to.recommend,fill = factor(Price.Sensitivity), group = Price.Sensitivity)) + ggtitle("LtR vs Price Sensitivity")

ggplot(airData) + theme(text = element_text(size=30)) +
    geom_boxplot(aes(x = departure_delay_long, y = Likelihood.to.recommend,fill = factor(departure_delay_long), group = departure_delay_long)) + ggtitle("LtR vs Departure_Delay_Long")

ggplot(airData) + theme(text = element_text(size=40)) +
    geom_boxplot(aes(x = Flight.cancelled, y = Likelihood.to.recommend,fill = factor(Flight.cancelled))) + ggtitle("LtR vs Flight Cancelled")

ggplot(airData) + theme(text = element_text(size=30)) +
    geom_boxplot(aes(x = flight.haul.type, y = Likelihood.to.recommend,fill = factor(flight.haul.type))) + ggtitle("LtR vs Flight Cancelled")

ggplot(airData) + theme(text = element_text(size=30)) +
    geom_boxplot(aes(x = Airline.Status, y = Likelihood.to.recommend,fill = factor(Airline.Status))) + ggtitle("LtR vs Flight Cancelled")

# Need 
?map_data
# ----------------------
# Create map to display LtR per state
# Create map to identify airport locations (Origin city only)
library(usmap)
airData$Origin.State <- tolower(airData$Origin.State)
?map_data
us = map_data('world', c('usa', 'puerto rico'))
us$subregion <- tolower(us$subregion)
us$region <- tolower(us$region)
?expand_limits
# Show distribution of airports across the US
airMap <- ggplot(airData)
us.map <- airMap + 
    geom_map(data = us, map = us, aes(map_id = region, group = group),fill = 'gray', colour = 'black') +
    expand_limits(x= c(-190,-65), y= us$lat) +
    coord_map(projection = "mercator")+
    borders('state')
# Notice PR as a territory
us.map + 
    geom_point(data = airData, aes(x = olong, y = olat),colour = 'purple', size = 3)
us.map
 # See Shiny app at the end of R Script for additional maps
