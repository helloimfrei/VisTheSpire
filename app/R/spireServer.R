spireServer <- function(id){
  moduleServer(id,function(input,output,session){
    rv <- reactiveValues()
    observe({
      req(input$zip_upload)
      rv$vts <- VisTheSpire(input$zip_upload$datapath)
      rv$deaths <- rv$vts$death_freq()
    })
    output$run_stats_silent <- renderReactable({
      req(rv$vts)
      reactable(
        rv$vts$stat_summary('THE_SILENT'),
        style = list(background = "#233253")
        )
    })
    output$run_stats_watcher <- renderReactable({
      req(rv$vts)
      reactable(
        rv$vts$stat_summary('WATCHER'),
        style = list(background = "#233253")
        )
    })
    output$run_stats_ironclad <- renderReactable({
      req(rv$vts)
      reactable(
        rv$vts$stat_summary('IRONCLAD'),
        style = list(background = "#233253")
        )
    })
    output$run_stats_defect <- renderReactable({
      req(rv$vts)
      reactable(
        rv$vts$stat_summary('DEFECT'),
        style = list(background = "#233253")
        )
    })

#add click event functionality for treemap sectors, pull up most and least common relics and cards for those runs
    output$death_freq <- renderPlotly({
      req(rv$deaths)
      char_colors <- c(
        'THE_SILENT' = '#2d9958', 
        'WATCHER' = '#9b2dca', 
        'IRONCLAD' = '#c52323', 
        'DEFECT' = '#57a5d6')
      rv$hierarchy_table <- VisTheSpire$make_hierarchy_table(
        rv$deaths,"character_chosen","killed_by","freq"
        ) |>
      filter(size > input$top_n | size == 0) |>
      mutate(color = char_colors[child])

      fig <- plot_ly(data = rv$hierarchy_table, 
                    labels = ~child, 
                    parents = ~parent,
                    values = ~size, 
                    type = 'treemap', 
                    textinfo = "text+size",
                    hoverinfo = "size",
                    text = ~pretty_labels,
                    marker = list(colors = ~color),
                    source = "death_freq",
                    customdata = ~child
      ) |>
      layout(paper_bgcolor = '#233253')
      fig
    })

    output$clicked_sector <- renderText({
      rv$clicked_sector <- event_data("plotly_click", source = "death_freq")$customdata
      if(is.null(rv$clicked_sector)){
        return("Click on a sector to get more information!")}
      return(rv$clicked_sector)
      })
    

    output$death_zoom <- renderPlotly({
      req(rv$clicked_sector)
      req(!(rv$clicked_sector %in% c("THE_SILENT","WATCHER","IRONCLAD","DEFECT")))
      fig <- plot_ly(data = rv$hierarchy_table, 
                    labels = ~child, 
                    parents = ~parent,
                    values = ~size, 
                    type = 'treemap', 
                    textinfo = "text+size",
                    hoverinfo = "size",
                    text = ~pretty_labels,
                    marker = list(colors = ~color),
                    source = "death_zoom",
                    customdata = ~child
      ) |>
      layout(paper_bgcolor = '#233253')
      fig
    })

  



    
    
  })
}
