spireServer <- function(id){
  moduleServer(id,function(input,output,session){

    rv <- reactiveValues()

    observe({
      req(input$zip_upload)
      rv$user_runs <- VisTheSpire(input$zip_upload$datapath)
      rv$deaths <- py_to_r(rv$user_runs$death_freq())
      print(str(rv$deaths))
    })

  output$death_freq <- renderPlotly({
    req(rv$deaths)
    fig <- plot_ly(data = rv$deaths, labels = ~killed_by, values = ~freq, type = 'pie')
    fig
  })





    
    
  })
}