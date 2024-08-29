library(shiny)
library(shinydashboardPlus)
library(shinyFiles)
library(tidyverse)
library(plotly)
library(ggplot2)
library(janitor)
library(extrafont)
library(sysfonts)
library(showtext)
library(reticulate)
library(reactable)
library(bslib)


#use_condaenv('spire')
py_install(c('pandas'))

source_python('spire.py')



