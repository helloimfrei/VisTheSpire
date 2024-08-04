spireUI <- function(id) {
  ns <- NS(id)
  tagList(
    sidebarPanel(
      shinyDirButton(ns('dir_upload'),'Select Save File Directory',title = 'test')
    ),
    mainPanel(
      
    )

    
    
    
)}