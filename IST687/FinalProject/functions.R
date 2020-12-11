
# create NPS calc function
# "NPS determine by -> %promotors - %detractors
# take specific attribute (age,gender, etc)
# returns NPS score for that sub group

nps_score <- function(subgroup,df_subset){
    
    sub_data <- length(which(subgroup == df_subset))
    p <- length(which(airData$recommend_name[which(subgroup == df_subset)] == 'promoter'))
    # create detractors
    d <- length(which(airData$recommend_name[which(subgroup == df_subset)] == 'detractor'))
    #determine overall generic score
    score <-  (p -d)/sub_data
    return(score)
}
# Test function
nps_score(airData$Gender, 'Female')
