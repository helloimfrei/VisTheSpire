spireUI <- function(id) {
  #TODO: basic stats page (win rate, total deaths, total runs, etc)
# most successful items
# most successful cards
# clickable sectors in treemap, pull up run details (common cards for the runs where you died to certain enemy, etc.)

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
      width = 2
    ),
    mainPanel(
      navset_bar(
        title = 'Metrics',
        nav_panel('Run Stats',
        reactableOutput(ns('run_stats')),
        ),
        nav_panel('Deaths',
        sliderInput(ns('top_n'),'Minimum Frequency of Deaths Caused',min = 0,max = 1,value = 0),
        plotlyOutput(ns('death_freq'))),
        nav_panel('Relics'),
        nav_panel('Cards')
      ),
      width = 10
    )

    
    
    
)}