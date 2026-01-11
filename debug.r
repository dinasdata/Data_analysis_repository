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
            box(width = 5,dateRangeInput("period","Select datetime size :",format = "yyyy-mm-dd ",start = Sys.Date() - 30,end = Sys.Date()),
            actionButton("refresh","Refresh date")),
            box(width = 5,selectInput("color3","Select color",choices = c("#054726ff","#068096ff","#a30707ff")))
            
         
     )
     ))))
server = function(input, output, session) {

  # ---- CONSTANTS ----
  MONTH_SHEETS = c(
    "Janv_02","Fév_02","Mars_02","Avril_02","Mai_02","Juin_02",
    "Juil_02","Août_02","Sept_02","Oct_02","Nov_02","Déc_02"
  )

  MONTH_LABELS = c("Jan","Feb","Mar","Apr","May","Jun",
                    "Jul","Aug","Sep","Oct","Nov","Dec")

  # ---- LOAD DATA ONCE ----
  raw_data = reactive({
    req(input$dataset)

    sheets = lapply(MONTH_SHEETS, function(s) {
      read_excel(input$dataset$datapath, sheet = s)
    })

    names(sheets) = MONTH_SHEETS
    sheets
  })

  # ---- MERGED HOURLY DATA ----
  hourly_data = reactive({
    bind_rows(raw_data())
  })

  # ---- MONTHLY SUMMARY ----
  monthly_summary = reactive({
    raw_data() |>
      bind_rows(.id = "Sheet") |>
      mutate(Month = factor(MONTH_LABELS[match(Sheet, MONTH_SHEETS)],
                             levels = MONTH_LABELS)) |>
      group_by(Month) |>
      summarise(
        min = min(Débit, na.rm = TRUE),
        mean = mean(Débit, na.rm = TRUE),
        max = max(Débit, na.rm = TRUE),
        .groups = "drop"
      )
  })

  # ---- MONTHLY VALUE BOXES ----
  output$monthlymin = renderValueBox({
    m = monthly_summary()[1:input$month_size, ]
    valueBox(mean(m$min), "Monthly minimum", color = "green",icon = icon("water"))
  })

  output$monthlymean = renderValueBox({
    m = monthly_summary()[1:input$month_size, ]
    valueBox(mean(m$mean), "Monthly mean",icon = icon("water"))
  })

  output$monthlymax = renderValueBox({
    m = monthly_summary()[1:input$month_size, ]
    valueBox(mean(m$max), "Monthly maximum", color = "red",icon = icon("water"))
  })

  # ---- MONTHLY PLOTS ----
  output$monthly = renderPlot({
    ggplot(monthly_summary()[1:input$month_size, ]) +
      geom_col(aes(Month, mean), fill = input$color) +
      theme_light() +
      labs(title = "Mean Monthly Discharge", y = "Discharge")
  })

  output$monthly_peak = renderPlot({
    ggplot(monthly_summary()[1:input$month_size, ]) +
      geom_col(aes(Month, max), fill = input$color) +
      theme_light() +
      labs(title = "Peak Monthly Discharge", y = "Peak Discharge")
  })

  # ---- DAILY SUMMARY ----
  daily_summary = reactive({
    req(input$selected_month)

    raw_data()[[input$selected_month]] |>
      mutate(Day = day(Date)) |>
      group_by(Day) |>
      summarise(
        min = min(Débit, na.rm = TRUE),
        mean = mean(Débit, na.rm = TRUE),
        max = max(Débit, na.rm = TRUE),
        .groups = "drop"
      )
  })

  # ---- DAILY VALUE BOXES ----
  output$dailymin = renderValueBox({
    d = daily_summary()
    row = d[which.min(d$min), ]
    valueBox(row$min, paste("Min on day", row$Day), color = "green",icon = icon("water"))
  })

  output$daylymean = renderValueBox({
    valueBox(mean(daily_summary()$mean), "Monthly mean discharge",icon = icon("water"))
  })

  output$dailymax = renderValueBox({
    d = daily_summary()
    row = d[which.max(d$max), ]
    valueBox(row$max, paste("Max on day", row$Day), color = "red",icon = icon("water"))
  })

  # ---- DAILY PLOT ----
  output$daily = renderPlot({
    ggplot(daily_summary()) +
      geom_col(aes(Day, mean), fill = input$color2) +
      theme_light() +
      labs(title = "Daily Mean Discharge", y = "Discharge")
  })

  # ---- FILTERED HOURLY DATA ----
  hourly_filtered = reactive({
    req(input$period)
    hourly_data() |>
      filter(Date >= input$period[1],
             Date <= input$period[2])
  })

  # ---- HYDROGRAM ----
  output$hydro = renderPlot({
    ggplot(hourly_filtered()) +
      geom_line(aes(Date, Débit), color = input$color3) +
       geom_point(aes(Date, Débit), color = input$color3) +
      theme_light() +
      labs(title = "Hydrogram", y = "Discharge")
  })

  # ---- HYDRO VALUE BOXES ----
  output$dischargemin = renderValueBox({
    d = hourly_filtered()
    row = d[which.min(d$Débit), ]
    valueBox(row$Débit, paste("Min at", row$Date), color = "green",icon = icon("water"))
  })

  output$dischargemean = renderValueBox({
    valueBox(mean(hourly_filtered()$Débit), "Mean discharge",icon = icon("water"))
  })

  output$dischargemax = renderValueBox({
    d = hourly_filtered()
    row = d[which.max(d$Débit), ]
    valueBox(row$Débit, paste("Max at", row$Date), color = "red",icon = icon("water"))
  })
# ---- DOWNLOADS ----
output$down1 = downloadHandler(
  filename = function() "monthly_mean.png",
  content = function(file) {
    ggsave(file, plot = last_plot(), width = 8, height = 5)
  }
)

output$down2 = downloadHandler(
  filename = function() "monthly_peak.png",
  content = function(file) {
    ggsave(file, plot = last_plot(), width = 8, height = 5)
  }
)

output$down3 = downloadHandler(
  filename = function() "daily.png",
  content = function(file) {
    ggsave(file, plot = last_plot(), width = 8, height = 5)
  }
)

output$down5 = downloadHandler(
  filename = function() "hydrogram.png",
  content = function(file) {
    ggsave(file, plot = last_plot(), width = 8, height = 5)
  }
)
observeEvent(input$refresh,{
    updateDateRangeInput(inputId = "period",start = hourly_data()$Date[2],end = hourly_data()$Date[31],label = "Select datetime size:")})

}
shinyApp(ui,server)