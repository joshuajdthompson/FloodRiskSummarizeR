################################################################################
#                   Author: Joshua Thompson
#   O__  ----       Email:  joshuajamesdavidthompson@gmail.com
#  c/ /'_ ---
# (*) \(*) --
# ======================== Script  Information =================================
# PURPOSE: Flood Risk Summarizer for Undeveloped lots in Anne Arundel County
#
# PROJECT INFORMATION:
#   Name: Flood Risk Summarizer for Undeveloped lots in Anne Arundel County
#
# HISTORY:----
#   Date		        Remarks
#	-----------	   ---------------------------------------------------------------
#	 09/02/2022    Created script                                   JThompson (JT)
#===============================  Environment Setup  ===========================
#==========================================================================================


if(!require(shiny)){
  install.packages("shiny")
  library(shiny) #'*1.7.1* <---  shiny version
}

if(!require(gfonts)){
  install.packages("gfonts")
  library(gfonts) #'*0.1.3* <---  gfonts version
}

if(!require(stringr)){
  install.packages("stringr")
  library(stringr) #'*1.4.0* <---  stringr version
}

if(!require(tidyverse)){
  install.packages("tidyverse")
  library(tidyverse) #'*1.3.1* <---  tidyverse version
}

if(!require(magrittr)){
  install.packages("magrittr")
  library(magrittr) #'*2.0.2* <---  magrittr version
}

if(!require(tidyselect)){
  install.packages("tidyselect")
  library(tidyselect) #'*1.1.1* <---  tidyselect version
}

if(!require(wesanderson)){
  install.packages("wesanderson")
  library(wesanderson) #'*0.3.6* <---  wesanderson version
}

if(!require(leaflet)){
  install.packages("leaflet")
  library(leaflet) #'*2.0.4.1* <---  leaflet version
}

if(!require(ggtext)){
  install.packages("ggtext")
  library(ggtext) #'*'0.1.1'* <---  ggtext version
}

if(!require(sf)){
  install.packages("sf")
  library(sf) #'*'1.0.5'* <---  sf version
}

if(!require(sp)){
  install.packages("sp")
  library(sp) #'*'1.4.6'* <---  sp version
}

if(!require(DT)){
  install.packages("DT")
  library(DT) #'*'0.20'* <---  DT version
}

if(!require(rmapshaper)){
  install.packages("rmapshaper")
  library(rmapshaper) #'*'0.4.5'* <---  rmapshaper version
}

if(!require(shinycssloaders)){
  install.packages("shinycssloaders")
  library(shinycssloaders) #'*'1.0.05'* <---  shinycssloaders version
}

if(!require(waiter)){
  install.packages("waiter")
  library(waiter) #'*'0.2.5'* <---  waiter version
}

if(!require(Cairo)){
  install.packages("Cairo")
  library(Cairo) #'*'1.5.14'* <---  Cairo version
}

if(!require(leaflet.extras)){
  install.packages("leaflet.extras")
  library(leaflet.extras) #'*'1.0.0'* <---  leaflet.extras version
}

if(!require(tinytex)){
  install.packages("tinytex")
  library(tinytex) #'*'0.38'* <---  tinytex version
}

if(!require(rmarkdown)){
  install.packages("rmarkdown")
  library(rmarkdown) #'*'2.11'* <---  rmarkdown version
}

if(!require(gfonts)){
  install.packages("gfonts")
  library(gfonts) #'*'0.1.3'* <---  gfonts version
}

if(!require(shinyjs)){
  install.packages("shinyjs")
  library(shinyjs) #'*'2.1.0'* <---  shinyjs version
}

if(!require(shinyalert)){
  install.packages("shinyalert")
  library(shinyalert) #'*'3.0.0'* <---  shinyalert version
}

if(!require(shinyBS)){
  install.packages("shinyBS")
  library(shinyBS) #'*'0.61'* <---  shinyBS version
}

#load geospatial data
load("flood_simp.RData")

# user interface
ui = fluidPage(id = 'fP',
               #palanquin
               use_font("palanquin", "www/css/palanquin.css"),
               useShinyjs(),
               useWaiter(),
               useHostess(),
               waiterShowOnLoad(
                 color = "#9cb6db",
                 hostess_loader(
                   "loader", 
                   preset = "fan",
                   stroke_color = "#16478e",
                   text_color = "black",
                   class = "label-center",
                   center_page = TRUE
                 )
               ),#tags$style("body {background-color:#9ec7b4;}"), 
               
               tags$head(HTML("<title>Flood Risk Summary</title> <link rel='icon' type='image/gif/png' href='logo.png'>"),
                         tags$style(HTML(
                           "
              .nav-tabs {font-size: 18px} 
              .navbar{background-color: #16478e !important; padding-left: 20px; margin-left:-20px; padding-right: 15px; margin-right:-15px;padding-top: 20px; margin-top:-20px;}
              .navbar-default .navbar-brand:hover {color: blue;}
              .navbar { background-color: gray;}
              .navbar-default .navbar-nav > li > a {color:white;}
              .navbar-default .navbar-nav > .active > a,
              .navbar-default .navbar-nav > .active > a:focus,
              .navbar-default .navbar-nav > .active > a:hover {color: white;background-color: #9cb6db;}
              .navbar-default .navbar-nav > li > a:hover {color: #000000;background-color:#9cb6db;text-decoration:underline;}
              .butt{background-color:#505250; color:#FFFFFF; border-color:#080808;}
              .smallbutt{background-color:#505250; color:#FFFFFF; border-color:#080808;height: 30px; width: 30px; border-radius: 50%;}
              .btn-file{background-color:#505250; color:#FFFFFF; border-color:#080808;}
              .form-control.shiny-bound-input {margin-top:7.5px;}
              .irs-bar {width: 100%; height: 25px; background-color: #16478e; border-top: 1px black; border-bottom: 1px black;}
              .irs-bar-edge {background: black; border: 1px black; height: 25px; border-radius: 0px; width: 20px;}
              .irs-line {border: 1px black; height: 25px; border-radius: 0px;}
              .irs-grid-text {color: black; bottom: 17px; z-index: 1;}
              .irs-grid-pol {display: none;}
              .irs-max {color: black;}
              .irs-min {color: black;}
              .irs-single {color:black; background:#6666ff;}
              .irs-slider {color: black; width: 30px; height: 30px; top: 22px;}
              input[type=number] {-moz-appearance:textfield;}
              input[type=number]::{-moz-appearance:textfield;}
              input[type=number]::-webkit-outer-spin-button,input[type=number]::-webkit-inner-spin-button {-webkit-appearance: none;
                    margin: 0;}
              .checkbox {line-height: 30px; margin-bottom: 40px;}
              input[type='checkbox']{width: 30px;height: 30px; line-height: 30px;}
              span {margin-left: 15px;line-height: 30px;}
              "
                         ))),
               titlePanel(
                 fluidRow(style = "background-color:#16478e; padding-top: 20px; margin-top:-20px; padding-bottom: 20px; margin-bottom:-20px",
                          column(9,h4(("Flood Risk Summarizer for Undeveloped Lots Anne Arundel County"),style="font-size:26px;font-style:normal; font-weight: 400; color:#FFFFFF;"),
                                 p("Note: this tool is provided 'as is' without warranty of any kind, either expressed, implied, or statutory.",style="font-size:11.5px;font-style:italic;color:#FFFFFF;"),
                                 p("The user assumes the entire risk as to quality and performance of the data from this tool.",style="font-size:11.5px;font-style:italic;color:#FFFFFF;"),
                                 a(actionButton(inputId = "email1", label = "   Contact ",icon = icon("envelope", lib = "font-awesome"),
                                                style = "background-color:#505250; color:#FFFFFF; border-color:#080808"),href="mailto:pwthom19@aacounty.org")),
                          column(3, tags$a(img(src='BWPR_LogoVersion2.png', align = "right",height = 279*0.6, width = 558*0.6, style="padding: 0px")))
                          #div(style="margin-bottom:10px")
                 )),
               navbarPage("",
                          
                          ##===========================================================================================================================#
                          ##===========================================================================================================================#
                          ## #######################################  Inputs and Map ###################################################################
                          ##===========================================================================================================================#
                          ##===========================================================================================================================#             
                          
                          tabPanel("Query and Map",icon=icon("map"),#,
                                   wellPanel(style = "background-color: #9cb6db; border: 1px solid black; padding-left: 15px; margin-left:-15px; padding-right: 15px; margin-right:-15px; padding-top: 10px; margin-top:-10px",
                                             fluidRow(
                                               column(6,h4(strong("Parameters to Map"),style="font-size:26px;font-style:normal; font-weight: 400; color: black"),br(),
                                                      selectizeInput(inputId = "mapParam", 
                                                                     label = "Parameter To Map (% of Parcel):",
                                                                     choices = c("Parcel Importance Score",
                                                                                 "1 in 2 Year Flood (2022 Scenario)",
                                                                                 "1 in 5 Year Flood (2022 Scenario)",
                                                                                 "1 in 20 Year Flood (2022 Scenario)",
                                                                                 "1 in 100 Year Flood (2022 Scenario)",
                                                                                 "1 in 500 Year Flood (2022 Scenario)",
                                                                                 "1 in 2 Year Flood (2037 Scenario)",
                                                                                 "1 in 5 Year Flood (2037 Scenario)",
                                                                                 "1 in 20 Year Flood (2037 Scenario)",
                                                                                 "1 in 100 Year Flood (2037 Scenario)",
                                                                                 "1 in 500 Year Flood (2037 Scenario)",
                                                                                 "1 in 2 Year Flood (2052 Scenario)",
                                                                                 "1 in 5 Year Flood (2052 Scenario)",
                                                                                 "1 in 20 Year Flood (2052 Scenario)",
                                                                                 "1 in 100 Year Flood (2052 Scenario)",
                                                                                 "1 in 500 Year Flood (2052 Scenario)",
                                                                                 "FEMA Non-Tidal 100-Year Floodplain",
                                                                                 "FEMA Tidal 100-Year Floodplain",
                                                                                 "Height Above Nearest Drainage (<1.8 ft)",
                                                                                 "Height Above Nearest Drainage (<4.1 ft)",
                                                                                 "Steep Slopes + 100 ft Buffer",
                                                                                 "Streams + 100 ft Buffer",
                                                                                 "Wetlands + 100 ft Buffer"
                                                                     ),
                                                                     selected = "Parcel Importance Score",
                                                                     multiple = TRUE, 
                                                                     options = list(maxItems = 1),
                                                                     width = "50%"),
                                                      br(), 
                                                      column(8,h4(strong("Weights for Parameters"),style="font-size:26px;font-style:normal; font-weight: 400; color: black",
                                                                  actionButton("info", "?",class="smallbutt"))),column(4,actionButton("calc", "Refresh Parcel Score",class="butt")),br(),br()
                                                      ,br(),
                                                      column(4,style="padding-left: 15px; margin-left:-15px",
                                                             numericInput("f1in2_2022", "1 in 2 Year Flood (2022 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("f1in5_2022", "1 in 5 Year Flood (2022 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("f1in20_2022", "1 in 20 Year Flood (2022 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("f1in100_2022", "1 in 100 Year Flood (2022 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("f1in500_2022", "1 in 500 Year Flood (2022 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("f1in2_2037", "1 in 2 Year Flood (2037 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("f1in5_2037", "1 in 5 Year Flood (2037 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("f1in20_2037", "1 in 20 Year Flood (2037 Scenario)", width = NULL,value = 0.5,min = 0, max = 1)
                                                      ),
                                                      column(4,style="padding-right: 20px; margin-right:-20px",
                                                             numericInput("f1in100_2037", "1 in 100 Year Flood (2037 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("f1in500_2037", "1 in 500 Year Flood (2037 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("f1in2_2052", "1 in 2 Year Flood (2052 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("f1in5_2052", "1 in 5 Year Flood (2052 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("f1in20_2052", "1 in 20 Year Flood (2052 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("f1in100_2052", "1 in 100 Year Flood (2052 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("f1in500_2052", "1 in 500 Year Flood (2052 Scenario)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("fema_nontid_100", "FEMA Non-Tidal 100-Year Floodplain", width = NULL,value = 0.5,min = 0, max = 1)
                                                      ),
                                                      column(4,style="padding-right: 20px; margin-right:-20px",
                                                             numericInput("fema_tid_100", "FEMA Tidal 100-Year Floodplain", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("hand_1_8", "Height Above Nearest Drainage (<1.8 ft)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("hand_4_1", "Height Above Nearest Drainage (<4.1 ft)", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("slope", "Steep Slopes + 100 ft Buffer", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("streams", "Streams + 100 ft Buffer", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("wetlands", "Wetlands + 100 ft Buffer", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("parcel_size", "Parcel Size", width = NULL,value = 0.5,min = 0, max = 1),
                                                             numericInput("natlandcover", "Natural Landcover", width = NULL,value = 0.5,min = 0, max = 1)
                                                      ),br(), 
                                                      column(9, align = "center", h4(strong("Range of Parcel Scores to Display"),style="font-size:20px;font-style:normal; font-weight: 400; color: black"),
                                                             sliderInput("maprange", "Range:",
                                                                         min = 0, max = 1,
                                                                         value = c(0.75,1))), 
                                                      column(3,align = "center", h4(strong("Select all in Range"),style="font-size:20px;font-style:normal; font-weight: 400; color: black"),
                                                             br(),checkboxInput(inputId="selectallinrange", label="", value = FALSE, width = NULL))
                                               ),
                                               column(6,h4(strong("Map of Undeveloped Lots (click to add to summary table)"),style="font-size:26px;font-style:normal; font-weight: 400; color: black"),
                                                      br(),br(),
                                                      tags$style(type = "text/css", "#map {height: calc(100vh - 250px) !important;}"),
                                                      leafletOutput("map")%>% withSpinner(color="black"), br(),
                                                      selectizeInput(inputId = "selected_locations",
                                                                     label = "Selected Lot(s)",
                                                                     choices = flood_simp$`Tax Account Number`,
                                                                     selected = NULL,
                                                                     multiple = TRUE,
                                                                     options = list(placeholder = "Select Tax Account Number",
                                                                                    maxOptions = 2000))
                                                      ))
                                             
                                   )
                          ),
                          
                          
                          ##===========================================================================================================================#
                          ##===========================================================================================================================#
                          ## #######################################  Selection Summary  ###############################################################
                          ##===========================================================================================================================#
                          ##===========================================================================================================================#              
                          
                          tabPanel("Selection Summary",icon=icon("table"),#,
                                   wellPanel(style = "background-color: #9cb6db; border: 1px solid black; padding-left: 15px; margin-left:-15px; padding-right: 15px; margin-right:-15px; padding-top: 10px; margin-top:-10px",
                                             column(3,br(),downloadButton('downloadres', 'Download Full Table',class = "butt")), br(),br(),
                                             DT::dataTableOutput("selectionresults")
                                   ) # wellpanel
                                   
                          )  
               )
)
