spireServer <- function(id){
  moduleServer(id,function(input,output,session){
    rv <- reactiveValues()
    observe({
      req(input$zip_upload)
      rv$vts <- VisTheSpire(input$zip_upload$datapath)
      rv$deaths <- rv$vts$death_freq()
    })
#Download Data
    output$download_data <- downloadHandler(
      filename = function() {
        paste0('runs-',Sys.Date(),'.csv')
      },
      content = function(file) {
        write.csv(rv$vts$str_runs, file)
      }
    )

#Summary Stats
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


#Deaths
    char_colors <- c(
      'THE_SILENT' = '#2d9958', 
      'WATCHER' = '#9b2dca', 
      'IRONCLAD' = '#c52323', 
      'DEFECT' = '#57a5d6')
    #add click event functionality for treemap sectors, pull up most and least common relics and cards for those runs
    output$death_freq <- renderPlotly({
      req(rv$deaths)
      rv$hierarchy_table <- VisTheSpire$make_hierarchy_table(
        rv$deaths,"character_chosen","killed_by","freq"
        ) |>
      filter(size > input$top_n | size == 0) |>
      mutate(color = char_colors[child])

      fig <- plot_ly(
        data = rv$hierarchy_table, 
        labels = ~child, 
        parents = ~parent,
        values = ~size, 
        type = 'treemap', 
        textinfo = "text+size",
        hoverinfo = "size",
        text = ~pretty_labels,
        textfont = list(color = "#fcdc0f"),
        hoverlabel = list(bgcolor = "#fcdc0f"),
        marker = list(
          colors = ~color,
          textfont = list(color = "#fcdc0f")),
        source = "death_freq",
        customdata = ~child
      ) |>
        layout(
          paper_bgcolor = '#233253',  
          plot_bgcolor = '#233253'
        )
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
      rv$clicked_freqs <- rv$vts$items_at_event(click = rv$clicked_sector,item_type ="relics",event_type = "killed_by")
    

      fig <- plot_ly(
        data = rv$clicked_freqs, 
        type = 'bar',
        x = rv$clicked_freqs[,1],
        y = ~size,
        textfont = list(color = "#fcdc0f"),
        marker = list(color = rep(char_colors[strsplit(rv$clicked_sector, '\\+')[[1]][2]], nrow(rv$clicked_freqs)))
      ) |>
        layout(
          paper_bgcolor = '#233253',  
          plot_bgcolor = '#233253',
          font = list(color = '#fcdc0f'),  
          title = list(
            font = list(color = '#fcdc0f')  
          ),
          xaxis = list(
            title = list(
              font = list(color = '#fcdc0f') 
            ),
            tickfont = list(color = '#fcdc0f')  
          ),
          yaxis = list(
            title = list(
              font = list(color = '#fcdc0f')  
            ),
            tickfont = list(color = '#fcdc0f')  
          ),
          legend = list(
            font = list(color = '#fcdc0f')  
          )
        )
      fig
    })
#Relics

#Cards

#Improvement
  



    
    
  })
}
