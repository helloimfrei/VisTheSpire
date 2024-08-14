spireUI <- function(id) {
  # plan: tabs for 
  ns <- NS(id)
  tagList(
    sidebarPanel(
      fileInput(ns('zip_upload'),'Upload your zipped run folder here!')
    ),
    mainPanel(
      plotlyOutput(ns('death_freq'))
    )

    
    
    
)}