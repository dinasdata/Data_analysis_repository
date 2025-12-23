 library("writexl")
 library("shiny")
 library("shinydashboard")
library("dplyr")
library("ggplot2")
library("readxl")
library("lubridate")

 #UI creation  
 ui = dashboardPage(
     dashboardHeader(title = "Discharge analysis dashboard"),
     dashboardSidebar(
        sidebarMenu(
            menuItem("Upload file",fileInput("dataset","Upload here a dataset",accept = c(".xls",".xlsx",".csv"))),
            menuItem("Discharge Summary",tabName = "tab1",icon = icon("chart-bar")),
            menuItem("Discharge per Month",tabName = "tab2",icon = icon("chart-bar")),
            menuItem("Hydrogramm per day",tabName = "tab3",icon = icon("chart-line"))
        )
     ),
     dashboardBody(
         tabItems(
            tabItem(tabName = "tab1", fluidRow(valueBoxOutput("monthlymin",width = 4),valueBoxOutput("monthlymean",width = 4),valueBoxOutput("monthlymax",width = 4)),
          fluidRow(box(width = 7,title = "Monthly discharge",plotOutput("monthly",height = 200),downloadButton("down1","Download plot")),
           box(width = 5,title = "Monthly peak discharge",plotOutput("monthly_peak",height = 200),downloadButton("down2","Download plot")),
           box(width = 4,sliderInput("month_size","Select sample size :",min = 1,max = 12,value = 12)),
           box(width = 4,selectInput("color","Select color",choices = c("#054726ff","#068096ff","#a30707ff"))))),
          tabItem(tabName = "tab2",fluidRow(valueBoxOutput("dailymin",width = 4),valueBoxOutput("daylymean",width = 4),valueBoxOutput("dailymax",width = 4)),
         fluidRow(box(width = 7,title = "daily discharge",plotOutput("daily",height = 300),downloadButton("down3","Download plot")),
         box(width = 5,title = "Month",selectInput("selected_month","Select the sheet name of the month :",choices = c("Janv_02","Fév_02","Mars_02","Avril_02","Mai_02","Juin_02","Juil_02","Août_02","Sept_02","Oct_02","Nov_02","Déc_02"))),
         box(title = "Color",width = 4,selectInput("color2","Select color",choices = c("#054726ff","#068096ff","#a30707ff") )),
         ),
            ),
            tabItem(tabName = "tab3",fluidRow(valueBoxOutput("dischargemin",width = 4),valueBoxOutput("dischargemean",width = 4),valueBoxOutput("dischargemax",width = 4)),
           fluidRow(box(width = 7,title = "Hydrogramm",plotOutput("hydro"),downloadButton("down5","Download plot")),
            box(width = 5,dateRangeInput("period","Select datetime size :",format = "yyyy-mm-dd",start = Sys.Date() - 30,end = Sys.Date()),
            actionButton("refresh","Refresh date",class = "btn - success")),
            box(title = "Color",width = 4,selectInput("color2","Select color",choices = c("#054726ff","#068096ff","#a30707ff"), )),
            infoBoxOutput("peak",width = 4),)))
         
     )
     )
server = function(input,output){
sheets = reactive({sheets = c("Janv_02","Fév_02","Mars_02","Avril_02","Mai_02","Juin_02","Juil_02","Août_02","Sept_02","Oct_02","Nov_02","Déc_02")
return(sheets)})
data_min_month = reactive({

min_discharge = c(rep(0,12))
for (i in 1:length(sheets())){
data = read_excel(input$dataset$datapath,sheet = sheets()[i])
selected = data%>%
group_by(month(Date))%>%
summarize(Débit = min(Débit))
min_discharge[i] = selected$Débit}
return(min_discharge)})
output$monthlymin = renderValueBox({
req(input$dataset)
valueBox(width = 3,subtitle = paste("Min for ",input$month_size," months"),value = mean(data_min_month()[1:input$month_size]),color = "green",icon = icon("table"))
})
data_mean_month = reactive({

mean_discharge = c(rep(0,12))
for (i in 1:length(sheets())){
data = read_excel(input$dataset$datapath,sheet = sheets()[i])
selected = data%>%
group_by(month(Date))%>%
summarize(Débit = mean(Débit))
mean_discharge[i] = selected$Débit}
return(mean_discharge)})
output$monthlymean = renderValueBox({
req(input$dataset)
valueBox(width = 5,subtitle = paste("Mean for",input$month_size," months"),value = mean(data_mean_month()[1:input$month_size]),icon = icon("table"))
})
data_max_month = reactive({
 
max_discharge = c(rep(0,12))
for (i in 1:length(sheets())){
data = read_excel(input$dataset$datapath,sheet = sheets()[i])
selected = data%>%
group_by(month(Date))%>%
summarize(Débit = max(Débit))
max_discharge[i] = selected$Débit}
return(max_discharge)})
output$monthlymax = renderValueBox({
req(input$dataset)
valueBox(width = 4,subtitle = paste("Max for ",input$month_size," months"),value = mean(data_max_month()[1:input$month_size]),color = "red",icon = icon("table"))})
months = reactive({
    data = c("Jan","Feb","March","Apr","May","Jun","July","Aug","Sep","Oct","Nov","Dec")
})
datamonth = reactive({
data = data.frame(Date = months() ,Values = data_mean_month())
data$Date = factor(data$Date,levels = data$Date)
data2 = data.frame(Date = data$Date[1:input$month_size],Values = data$Values[1:input$month_size])
return(data2)
})
month_plot = reactive({

    ggplot(datamonth())+
    geom_col(mapping = aes(x = Date,y = Values),fill = input$color)+
    theme_light()+
    labs(title = "Discharge per month evolution",x = "Months",y = "Discharge")
})
output$monthly = renderPlot({
    req(input$dataset)
    req(input$month_size)
    req(input$color)
    month_plot()
})
data_peak_month = reactive({
data = data.frame(Date = months(),Values = data_max_month())
data$Date = factor(data$Date,levels = data$Date)
data2 = data.frame(Date = data$Date[1:input$month_size],Values = data$Values[1:input$month_size])
return(data2)
})
peak_month_plot = reactive({
 ggplot(data_peak_month())+
    geom_col(mapping = aes(x = Date,y = Values),fill = input$color)+
    theme_light()+
    labs(title = "Peak Discharge per month evolution",x = "Months",y = "Peak Discharge")
})
output$monthly_peak = renderPlot({
    req(input$dataset)
    req(input$month_size)
    peak_month_plot()
})
output$down1 = downloadHandler(
    filename = function(){
        "plot.png"},
    content = function(file){
        ggsave(filename = file,width = 700,height = 500,plot = peak_month_plot())

    }
)
day_month = reactive({
    data = read_excel(input$dataset$datapath,sheet = input$selected_month)
    data = data%>%
    group_by(day(Date))%>%
    summarize(Debit_mean = mean(Débit),Debit_max = max(Débit),Debit_min = min(Débit))
    names(data)[names(data) == "day(Date)"] = "Day"
    return(data)
})

output$daylymean = renderValueBox({
    req(input$dataset)
    valueBox(width = 4,subtitle = "Mean discharge of the month",value = mean(day_month()$Debit_mean),icon = icon("table"))
})
daily_plot = reactive({
    ggplot(data = day_month())+
    geom_col(mapping = aes(x = Day,y = Debit_mean),fill = input$color2)+
    labs(title = "discharge per day for the month",x = "Day",y = "Month")+
    theme_light()
})
output$daily = renderPlot({
    req(input$dataset)
    req(input$color2)
    daily_plot()
})
dmin = reactive({
    day_month()%>%
    filter(Debit_min == min(Debit_min))
})
dmax = reactive({
    day_month()%>%
    filter(Debit_max == max(Debit_max))
})
output$dailymin = renderValueBox({
    valueBox(width = 4,subtitle = paste("Min discharge located on day ",as.integer(mean(dmin()$Day))),value = mean(dmin()$Debit_min),icon = icon("table"),color = "green")
})
output$dailymax = renderValueBox({
    valueBox(width = 4,subtitle = paste("Max discharge located on day ",as.integer(mean(dmax()$Day))),value = mean(dmax()$Debit_max),icon = icon("table"),color = "red")
})
hourly_data = reactive({
df0 = data.frame(Date = ymd_hms("2001-12-31 23:59:59"),Hauteur = c(0),Débit = c(0))
for (i in 1:length(sheets())){
df = read_excel(input$dataset$datapath,sheet = sheets()[i])
df0 = rbind(df0,df)  }
df0 = df0%>%
filter(Date <= input$period$star)
return(df0)
})

}
 shinyApp(ui,server)
