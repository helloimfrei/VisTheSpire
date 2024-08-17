spireUI <- function(id) {
  #TODO: basic stats page (win rate, total deaths, total runs, etc)
  #win rate over time
# most successful items
# most successful cards
# clickable sectors in treemap, pull up run details (common cards for the runs where you died to certain enemy, etc.)

  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
      fileInput(ns('zip_upload'),'Upload your zipped run folder here!'),
      downloadButton(ns('download_data'),'Download All Run Data As CSV'),
      width = 2
    ),
      mainPanel(
        navset_bar(
          title = 'Metrics',
          nav_panel('Run Stats',
          fluidRow(
            column(3,reactableOutput(ns('run_stats_silent'))),
            column(3,reactableOutput(ns('run_stats_watcher'))),
            column(3,reactableOutput(ns('run_stats_ironclad'))),
            column(3,reactableOutput(ns('run_stats_defect')))
          )
          ),
          nav_panel('Deaths',
          sliderInput(ns('top_n'),'Minimum Frequency of Deaths Caused',min = 0,max = 1,value = 0),
          plotlyOutput(ns('death_freq')),
          textOutput(ns('clicked_sector')),
          plotlyOutput(ns('death_zoom'))
          ),
          nav_panel('Relics'),
          nav_panel('Cards'),
          nav_panel('Improvement'),
        ),
        width = 10
      )
    )
    

    
    
    
)}