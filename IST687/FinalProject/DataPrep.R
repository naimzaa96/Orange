# Follow Data Science process: Clean, Prep

# -------------------------------------------------------------------------------------------------- #
#  Part 1: 
# ----------------------------Obtain Clean and Prep AirSurvey Data---------------------------------- #

# From jsonfile, read into R as a dataframe and call it 'airData'
# airsurveyLink = 'https://s3.amazonaws.com/blackboard.learn.xythos.prod/5956621d575cd/11264935?response-cache-control=private%2C%20max-age%3D21600&response-content-disposition=inline%3B%20filename%2A%3DUTF-8%27%27airsurvey.json&response-content-type=application%2Fjson&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20201029T120000Z&X-Amz-SignedHeaders=host&X-Amz-Expires=21600&X-Amz-Credential=AKIAYDKQORRYTKBSBE4S%2F20201029%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=682bf130d2e0d58d8453116e5e8d58712b1be64e406cb791d492ed635806a94e'
# textOutput <- getURL(airsurveyLink) # using the getURL function to request the data from the web and source it to R as text
# airSurveylite <- jsonlite::fromJSON(textOutput) # using the from JSON function to parse through the human readable text and make a data frame
# airSurvey <- data.frame(airSurveylite)

# Load airsurvey Data into R from local directory and rename to airData, convert to data frame
df <-'airsurvey.json'
airData	<- jsonlite::fromJSON(df)
airData <- data.frame(airData)
str(airData)
# Identify missing values
# Data has many columns, We can use the colSums function to count how many missing values there are per column
colSums(is.na(airData))

# The following columns contain null values: 
#                      | Departure.Delay.in.Minutes | Arrival.Delay.in.Minutes  |  Flight.time.in.minutes  |
# # of missing Values:           90                           96                             96            

# If we choose to omit these values, we would be getting rid of about 2% of data (90/5000)
# Generally we should replace NA values with the median, median is not sensititive to outliers
# but because flight time is a known value, we can omit it. However, since those NA values corespond
# to canceled flights which affects likelihood to recommend, we replace NA values with a large departure delay, 
# and create a new column vector that output True if a delay is longer than 30 minutes, otherwise false, and do not
# choose to add departure and arrival delay since it is factored into the new column vecotr.

median(airData$Departure.Delay.in.Minutes,na.rm = TRUE) # median is 0 anyway so itd be the same if we omitted
airData$Departure.Delay.in.Minutes <-  replace_na(airData$Departure.Delay.in.Minutes, 10000)

# Repeat for the other two attriutes
median(airData$Arrival.Delay.in.Minutes,na.rm = TRUE) # median is 0 anyway so itd be the same if we omitted
airData$Arrival.Delay.in.Minutes <-replace_na(airData$Arrival.Delay.in.Minutes, 10000) 

median(airData$Flight.time.in.minutes,na.rm = TRUE) # median is 91
airData$Flight.time.in.minutes <- replace_na(airData$Flight.time.in.minutes, 0)


# --------------------------------------Additional attributes to add------------------------------------- #

# Could potentially be used for later models

# Labeling flights short, medium or long in terms of time; Less than 800 nautical miles, 800-2200 nautical miles, greater than 4000 nautical miles
# referenced from wikipedia
airData <- airData %>% mutate(flight.haul.type = cut(Flight.Distance, breaks = c(0,800,2200, 4000), labels = c("Short", "Medium", "Long")))

# creating new vector that identifies better those that are promotoer, detractors or passive in recommendations
airData <- airData %>% mutate(recommend_name = cut(Likelihood.to.recommend, breaks = c(0,6,8, 11), labels = c("detractor", "passive", "promoter")))
# 7 and 8 are passive --- need to fix

# creating TRUE/FALSE for depature delays longer than 30
# thinking about potential connection flights that may be affected by long departure delays
airData <- airData %>% mutate(departure_delay_long = cut(Departure.Delay.in.Minutes, breaks = c(-1,29,10000), labels = c(FALSE, TRUE)))
airData <- airData %>% mutate(Loyalty_factor = cut(Loyalty, breaks = c(-1,-.26,0,.24,1), labels = c("Not Loyal","Indifferent","Indifferent","Loyal")))

