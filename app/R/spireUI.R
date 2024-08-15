spireUI <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarPanel(
      fileInput(ns('zip_upload'),'Upload your zipped run folder here!'),
      checkboxGroupInput(ns('selected_chars'), 
      label = 'Select characters to display',
      choices = list(
        'The Silent'='THE_SILENT',
        'Watcher'='WATCHER',
        'Ironclad'='IRONCLAD',
        'Defect'='DEFECT'
      ),
      selected = NULL
      ),
      sliderInput(ns('top_n'),'Top N Death Causes',min = 1,max = 10,value = 5)
    ),
    mainPanel(
      navset_bar(
        title = 'Metrics',
        nav_panel('Deaths',plotlyOutput(ns('death_freq'))),
        nav_panel('Items',plotlyOutput(ns('items')))
      )

    )

    
    
    
)}