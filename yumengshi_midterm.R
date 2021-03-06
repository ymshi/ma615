library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(plotly)
library(ggvis)

#Load data
data<-read.csv("oilgascounty.csv")
dim(data)

data$County_Name<-str_replace_all(data$County_Name, "County", "")
data<-data.frame(subset(data, select = -c(oil_change_group, gas_change_group, oil_gas_change_group)))
for (i in 1:length(state.abb)) 
  {data$Stabr <- str_replace_all(data$Stabr, state.abb[i],state.name[i])}

# check if FIPS and geoid are exactly same
ii=1
while (ii<=ncol(data)) {
 if(sum(sapply(data, identical, data[,ii])*1)>1)
 {data=data[-ii]}
 ii=ii+1
}

#tidy data
oil <- 
  data.frame(subset(data, select = -c(gas2000:gas2011))) %>% 
  gather(Year, oil, oil2000:oil2011)%>%
  mutate(Year = gsub("oil", "", Year))%>%
  arrange(County_Name, Year)
gas <- 
  data.frame(subset(data, select = -c(oil2000:oil2011)))%>%
  gather(Year, gas, gas2000:gas2011)%>%
  mutate(Year = gsub("gas", "", Year))%>%
  arrange(County_Name, Year)
tidydata<-merge(gas,oil)

tidydata$Rural_Urban_Continuum_Code_2013<-factor(tidydata$Rural_Urban_Continuum_Code_2013, levels = c(1:9))
tidydata$Urban_Influence_2013<-factor(tidydata$Urban_Influence_2013, levels = c(1:12))
tidydata$Metro_Nonmetro_2013<-factor(tidydata$Metro_Nonmetro_2013, levels = c(0,1))
tidydata$Metro_Micro_Noncore_2013<-factor(tidydata$Metro_Micro_Noncore_2013, levels = c(0,1,2))
tidydata$Year<-factor(tidydata$Year)
na.omit(tidydata)
tidydata$oil<- as.numeric(tidydata$oil, na.omit(tidydata$oil))
tidydata$gas<- as.numeric(tidydata$gas, na.omit(tidydata$gas))


#plot
# M=0(nonmetro noncore) has the most total oil withdrawal. The total oil withdrawal is decreasing as the location closes to metropolitan
M0 <- na.omit(filter(tidydata,Metro_Micro_Noncore_2013=="0"))
M0 <-sum(M0$oil)
M1 <- na.omit(filter(tidydata,Metro_Micro_Noncore_2013=="1"))
M1 <-sum(M1$oil)
M2 <- na.omit(filter(tidydata,Metro_Micro_Noncore_2013=="2"))
M2<-sum(M2$oil)
M<-data.frame(t((cbind(M0,M1,M2))))
colnames(M)[1]<-'oil'
plot_ly(data = M, x=~c(0,1,2), y=~oil, mode="line")

#histogram 
#The total oil withdrawal over 12 years and the percentage of oil withdrawal for Metro Micro Noncore in each year. Nonmetro Noncore(0) contribute the most withdrawal in each year.
tidydata%>%
  ggvis(~Year, ~oil, fill=~Metro_Micro_Noncore_2013)

#The total oil withdrawal over 12 years and the percentage of gas withdrawal for Metro Micro Noncore in each year. The percentage of gas withdrawal of Metropolitan is decreasing over the 12 years.
tidydata%>%
  ggvis(~Year, ~gas, fill=~Metro_Micro_Noncore_2013)