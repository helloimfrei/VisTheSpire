spireServer <- function(id){
  moduleServer(id,function(input,output,session){

    rv <- reactiveValues()

    observe({
      req(input$zip_upload)
      rv$user_runs <- VisTheSpire(input$zip_upload$datapath)
      rv$deaths <- rv$user_runs$death_freq()
    })

  output$death_freq <- renderPlotly({
    req(rv$deaths)
    req(input$selected_chars)
    fig_list <- list()
    for (character in input$selected_chars) {
      filtered_deaths <- rv$deaths |> 
        filter(character_chosen == character) |>
        arrange(desc(freq)) |>
        head(n = input$top_n)
      fig <- plot_ly(data = filtered_deaths, labels = ~killed_by, values = ~freq, type = 'pie', name = character) 
      fig_list <- append(fig_list, list(fig))
    }
    subplots <- subplot(fig_list)
    subplots
  })





    
    
  })
}
