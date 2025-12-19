# Dashboard app for discharge monitoring 
# Code written by ANDRIANAMBININTSOA Dina Larry Ismael 
#library importation
library("ggplot2")
library("readxl")
library("dplyr")
library("lubridate")
library("writexl")
library("shiny")
library("shinydashboard")
#UI creation
ui = dashboardPage(
    dashboardHeader(title = "Discharge analysis dashboard"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Upload files",icon = icon("upload"),fileInput("dataset","Enter here your file:",accept = c(".xlsx",".xls",".csv"))),
            menuItem("Monthly discharge",tabName = "tab1",icon = icon("chart-bar")),
            menuItem("Daily discharge",tabName = "tab2",icon = icon("chart-bar")),
            menuItem("Hydrogramm per day",tabName = "tab3",icon = icon("chart-line"))
        )
    ),
    dashboardBody(
        tabItems(
           tabItem(tabName = "tab1", fluidRow(valueBoxOutput("monthlymin",width = 4),valueBoxOutput("monthlymean",width = 4),valueBoxOutput("monthlymax",width = 4)),
           fluidRow(box(width = 7,title = "Monthly discharge",plotOutput("monthly",height = 40),actionButton("down1","Download plot",class = "btn-primary")),
           box(width = 5,title = "Monthly peak discharge",plotOutput("monthly_peak",height = 40),actionButton("down2","Download plot",class = "btn-primary")),
           box(width = 4,sliderInput("month_size","Select sample size :",min = 1,max = 12,value = 12)))
           ),
           tabItem(tabName = "tab2",fluidRow(valueBoxOutput("dailylymin",width = 4),valueBoxOutput("daylymean",width = 4),valueBoxOutput("dailylymax",width = 4)),
           fluidRow(box(width = 7,title = "daily discharge",plotOutput("daily",height = 40),actionButton("down3","Download plot",class = "btn-primary")),
           box(width = 5,title = "daily peak discharge",plotOutput("daily_peak",height = 40),actionButton("down4","Download plot",class = "btn-primary")),
           box(width = 4,sliderInput("day_size","Select sample size :",min = 1,max = 31,value = 15)))
           ),
           tabItem(tabName = "tab3",fluidRow(valueBoxOutput("dischargemin",width = 40),valueBoxOutput("dischargemean",width = 4),valueBoxOutput("dischargemax",width = 4)),
           fluidRow(box(width = 7,title = "Hydrogramm",plotOutput("hydro"),actionButton("down5","Download plot",class = "btn-primary")),
           box(width = 5,dateRangeInput("period","Select datetime size :",format = "yyyy-mm-dd",start = Sys.Date() - 30,end = Sys.Date()),
           actionButton("refresh","Refresh date",class = "btn - success")),
           infoBoxOutput("peak",width = 4),
           ))
           ), 
        )
    )
   

server = function(input,output){

}
shinyApp(ui,server)