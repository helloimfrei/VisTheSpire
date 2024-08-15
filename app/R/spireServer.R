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
    
    rv$filtered_deaths <- rv$deaths |> 
    filter(character_chosen %in% input$selected_chars) 


  char_colors <- c('THE_SILENT' = '#2d9958', 'WATCHER' = '#9b2dca', 'IRONCLAD' = '#c52323', 'DEFECT' = '#57a5d6')

    hierarchy_table <- VisTheSpire$make_hierarchy_table(rv$filtered_deaths,"character_chosen","killed_by","freq") |>
    filter(size > input$top_n | size == 0) |>
    mutate(color = char_colors[child])



    fig <- plot_ly(data = hierarchy_table, 
                  labels = ~child, 
                  parents = ~parent,
                  values = ~size, 
                  type = 'treemap', 
                  textinfo = "text+size",
                  text = ~pretty_labels,
                  marker = list(colors = ~color)
    )
    
    fig
  })





    
    
  })
}
