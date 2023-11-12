library(shiny)
library(tidyquant)
library(dplyr)
library(plotly)
library(TTR)  # For Bollinger Bands calculation

# Define UI
ui <- fluidPage(
    titlePanel("Stock Price Visualization with Bollinger Bands"),
    sidebarLayout(
        sidebarPanel(
            textInput("stockSymbol", "Enter Stock Symbol", value = "AAPL"),
            dateRangeInput("dateRange", "Date Range",
                           start = Sys.Date() - 365, end = Sys.Date()),
            numericInput("n", "SMA Period", value = 20)
        ),
        mainPanel(
            plotlyOutput("stockPlot")
        )
    )
)

# Define Server Logic
server <- function(input, output) {
    output$stockPlot <- renderPlotly({
        symbol <- input$stockSymbol
        dates <- input$dateRange
        n <- input$n

        stock_data <- tq_get(symbol, from = dates[1], to = dates[2]) %>%
                      select(date, adjusted)

        # Calculate Bollinger Bands
        bands <- BBands(stock_data$adjusted, n = n, sd = 2)

        # Combine data
        stock_data <- cbind(stock_data, bands)

        # Plot with Plotly
        p <- plot_ly(x = ~stock_data$date, y = ~stock_data$adjusted, type = 'scatter', mode = 'lines', name = 'Adjusted') %>%
            add_lines(x = ~stock_data$date, y = ~stock_data$dn, name = 'Lower Band', line = list(dash = 'dash')) %>%
            add_lines(x = ~stock_data$date, y = ~stock_data$mavg, name = 'SMA', line = list(dash = 'dot')) %>%
            add_lines(x = ~stock_data$date, y = ~stock_data$up, name = 'Upper Band', line = list(dash = 'dash')) %>%
            layout(title = paste("Stock Prices with Bollinger Bands for", symbol),
                   xaxis = list(title = "Date"),
                   yaxis = list(title = "Price"))

        return(p)
    })
}

# Run the App
shinyApp(ui = ui, server = server)
