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
           box(width = 4,sliderInput("month_size","Select sample size :",min = 1,max = 12,value = 12)))),
          tabItem(tabName = "tab2",fluidRow(valueBoxOutput("dailylymin",width = 4),valueBoxOutput("daylymean",width = 4),valueBoxOutput("dailylymax",width = 4)),
         fluidRow(box(width = 7,title = "daily discharge",plotOutput("daily",height = 40),downloadButton("down3","Download plot")),
         box(width = 5,title = "daily peak discharge",plotOutput("daily_peak",height = 40),downloadButton("down4","Download plot")),
            box(width = 4,sliderInput("day_size","Select sample size :",min = 1,max = 31,value = 15)))
            ),
            tabItem(tabName = "tab3",fluidRow(valueBoxOutput("dischargemin",width = 40),valueBoxOutput("dischargemean",width = 4),valueBoxOutput("dischargemax",width = 4)),
           fluidRow(box(width = 7,title = "Hydrogramm",plotOutput("hydro"),downloadButton("down5","Download plot")),
            box(width = 5,dateRangeInput("period","Select datetime size :",format = "yyyy-mm-dd",start = Sys.Date() - 30,end = Sys.Date()),
            actionButton("refresh","Refresh date",class = "btn - success")),
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
valueBox(width = 3,paste("Min for ",input$month_size," months"),mean(data_min_month()[1:input$month_size]),color = "green")
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
valueBox(width = 5,paste("Mean for",input$month_size," months"),mean(data_mean_month()[1:input$month_size]),)
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
valueBox(width = 4,paste("Max for ",input$month_size," months"),mean(data_max_month()[1:input$month_size]),color = "red")})
datamonth = reactive({
data = data.frame(Date = c("Jan","Feb","March","Apr","May","Jun","July","Aug","Sep","Oct","Nov","Dec"),Values = data_mean_month())
data$Date = factor(data$Date,levels = data$Date)
data2 = data.frame(Date = data$Date[1:input$month_size],Values = data$Values[1:input$month_size])
return(data2)
})
month_plot = reactive({

    ggplot(datamonth())+
    geom_col(mapping = aes(x = Date,y = Values))+
    theme_light()+
    labs(title = "Discharge per month evolution",x = "Months",y = "Discharge")
})
output$monthly = renderPlot({
    req(input$dataset)
    req(input$month_size)
    month_plot()
})
data_peak_month = reactive({
data = data.frame(Date = c("Jan","Feb","March","Apr","May","Jun","July","Aug","Sep","Oct","Nov","Dec"),Values = data_max_month())
data$Date = factor(data$Date,levels = data$Date)
data2 = data.frame(Date = data$Date[1:input$month_size],Values = data$Values[1:input$month_size])
return(data2)
})
peak_month_plot = reactive({
 ggplot(data_peak_month())+
    geom_col(mapping = aes(x = Date,y = Values))+
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

 }
 shinyApp(ui,server)
