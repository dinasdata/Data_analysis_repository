#library importation
library("tidync")
library("dplyr")
library("ggplot2")
#dataset importation
dataset2 = tidync("/media/dina/f4c07323-3819-4c76-ad53-95f7d45b7ae2/morondava/dataset2.nc")
dataset = tidync("/media/dina/f4c07323-3819-4c76-ad53-95f7d45b7ae2/morondava/dataset.nc")
#temperature data and correction data extraction
modification = dataset%>%hyper_array()
temperature = dataset2%>%hyper_array()
temperature = tibble((temperature$t2m+modification$tp)-273.15)
#plotting temperature
data = data.frame(years = 1961:2024,temperature = temperature)
plot = ggplot(data = data)+
  geom_line(mapping = aes(x = years,y = X.temperature.t2m...modification.tp....273.15))+
  geom_point(mapping = aes(x = years,y = X.temperature.t2m...modification.tp....273.15),color = "blue")+
  geom_smooth(mapping = aes(x = years,y = X.temperature.t2m...modification.tp....273.15))+
  labs(title = "Temperature of September 22 for Morondava (1961-2024)",x = "Years",y = "temperature[°C]")+
  scale_x_continuous(name = "years", breaks = seq(1961,2026,by = 4))

print(plot)
#plotting localization
data_morondava = data.frame(long = 44.3,lat = -20.2,name = "Morondava")
loc = ggplot(data = data_morondava)+
  borders("world",regions = "Madagascar" ,colour = "black") +
  geom_point(mapping = aes(x = long, y = lat), color = "red", size = 6) +
  geom_text(mapping = aes(x = long,y = lat,label = name,vjust  = -1,hjust = -0.05))+
  coord_quickmap()+
  labs(title = "Morondava localization",x = "longitude",y = "latitude")
print(loc)
#descriptive statistics
period_1 = data$X.temperature.t2m...modification.tp....273.15[1:32]
period_2 = data$X.temperature.t2m...modification.tp....273.15[32:64]
mean = mean(data$X.temperature.t2m...modification.tp....273.15)
sdt = sqrt(var(data$X.temperature.t2m...modification.tp....273.15))
p1_mean = mean(period_1)
p1_std = sqrt(var(period_1))
p2_mean = mean(period_2)
p2_std = sqrt(var(period_2))
cat("Mean temperature from 1961 to 2024 :",mean)
max = max(data$X.temperature.t2m...modification.tp....273.15)
min = min(data$X.temperature.t2m...modification.tp....273.15)
cat("Max temperature, observed in 2023 :",max)
cat("Min temperature, observed in 1990:",min)
cat("Standart deviation:",sdt)
cat("Mean temperature from 1961 to 1993:",p1_mean)
cat("Mean temperature from 1993 to 2024:",p2_mean)
#inferential statistics for a non exhaustive sample with significant level = 0.01
u_alpha = 0.01
tou_alpha = 2.33
#getting estimation interval
mean_interval = function(x,y,n){
  A = x - u_alpha*(y/sqrt(n - 1))
  B = x + u_alpha*(y/sqrt(n-1))
  return (c(A,B))
}
cat("Temperature estimation interval:",mean_interval(mean,sdt,length(data$X.temperature.t2m...modification.tp....273.15)))
#searching if the first period is warmer than second period
test = function(x1,x2,sigma1,sigma2,n1,n2){
  T = abs(x1 - x2)/sqrt((sigma1**2/(n1 - 1))+(sigma2**2/(n2 - 1)))
  if (T <= tou_alpha){
    print(T)
    return("The mean temperature of the two periods are the same")
  }
  else{
    print(T)
    return("The temperature of the second period is higher")
  }
}
print(test(p1_mean,p2_mean,p1_std,p2_std,length(period_1),length(period_2)))

