spireUI <- function(id) {
  #TODO: ascension filtering
# clickable sectors in treemap, pull up run details (common cards for the runs where you died to certain enemy, etc.)

  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(
      fileInput(ns('zip_upload'),'Upload your zipped run folder here!'),
      #opt into being included in community stats? i'll keep your run data and include it in the community stats page
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
          #most successful relics per character, which relics correlate with win rate
          nav_panel('Relics'),
          #best cards, most taken cards, least taken cards
          nav_panel('Cards'),
          #win rate over time, cards picked over time, run speed over time (time/floor?)
          #avg floor reached over time
          #how to account for ascension?
          nav_panel('Improvement'),
          nav_panel(
            title = 'Community Stats',
            HTML('Potential Planned Feature!')
            )
        ),
        width = 10
      )
    )
    

    
    
    
)}