spireServer <- function(id){
  moduleServer(id,function(input,output,session){
    rv <- reactiveValues()
    observe({
      req(input$zip_upload)
      rv$user_runs <- VisTheSpire(input$zip_upload$datapath)
      rv$deaths <- rv$user_runs$death_freq()
    })
    output$run_stats_silent <- renderReactable({
      req(rv$user_runs)
      reactable(
        rv$user_runs$stat_summary('THE_SILENT'),
        style = list(background = "#233253")
        )
    })
    output$run_stats_watcher <- renderReactable({
      req(rv$user_runs)
      reactable(
        rv$user_runs$stat_summary('WATCHER'),
        style = list(background = "#233253")
        )
    })
    output$run_stats_ironclad <- renderReactable({
      req(rv$user_runs)
      reactable(
        rv$user_runs$stat_summary('IRONCLAD'),
        style = list(background = "#233253")
        )
    })
    output$run_stats_defect <- renderReactable({
      req(rv$user_runs)
      reactable(
        rv$user_runs$stat_summary('DEFECT'),
        style = list(background = "#233253")
        )
    })

    output$death_freq <- renderPlotly({
      req(rv$deaths)
      char_colors <- c(
        'THE_SILENT' = '#2d9958', 
        'WATCHER' = '#9b2dca', 
        'IRONCLAD' = '#c52323', 
        'DEFECT' = '#57a5d6')
      hierarchy_table <- VisTheSpire$make_hierarchy_table(
        rv$deaths,"character_chosen","killed_by","freq"
        ) |>
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
      ) |>
      layout(paper_bgcolor = '#233253')
      fig
    })





    
    
  })
}
