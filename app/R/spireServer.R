spireServer <- function(id){
  moduleServer(id,function(input,output,session){
    volumes <- getVolumes()
    shinyDirChoose(input,'dir_upload',roots = c(home = '~'), filetypes = c('','json','run'))
    
    rv <- reactiveValues()
    observe({
      rv$dirname <- parseDirPath(volumes, input$dir_upload)
    })
    
    
    
  })
}