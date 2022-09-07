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

if(!require(shinyjs)){
  install.packages("shinyjs")
  library(shinyjs) #'*2.1.0* <---  shinyjs version
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

if(!require(shinyvalidate)){
  install.packages("shinyvalidate")
  library(shinyvalidate) #'*'0.1.2'* <---  shinyvalidate version
}

if(!require(writexl)){
  install.packages("writexl")
  library(writexl) #'*'1.4.0'* <---  writexl version
}

if(!require(readxl)){
  install.packages("readxl")
  library(readxl) #'*'1.3.1'* <---  readxl version
}

if(!require(shinyalert)){
  install.packages("shinyalert")
  library(shinyalert) #'*'3.0.0'* <---  shinyalert version
}

# load geospatial data 
load("flood_simp.RData")

# functions
scale_01 <- function(x){(x-min(x))/(max(x)-min(x))}

server <- function(input, output, session){
  hostess <- Hostess$new("loader")
  
  Sys.sleep(1)
  
  for(i in 1:10){
    Sys.sleep(runif(1) / 2)
    hostess$set(i * 10)
  }
  waiter_hide()
  
  #===================================================
  # Info
  #=================================================== 
  
  observeEvent(input$info, {
    shinyalert(title = ""," <div>
<p style='font-family:palanquin;font-size:24px;font-style:normal; font-weight: 600;color: #545252;'>General Information
<br></p>
<p style='font-family:palanquin;text-align: justify;' >The undeveloped parcels presented in this tool were identified by an assessed improvement value of $0.  Furthermore, property owned by the United States Government, the State of Maryland, or areas owned by Baltimore Gas & Electric were omitted, as these areas are either unlikely to be developed or are outside Anne Arundel County's jurisdiction. 
<br><br>
Some undeveloped parcels are currently being used as golf courses or quarries, and have a small likelihood of development.   A natural landcover threshold was used to omit these areas, where only those parcels with >=80% natural landcover were retained.  Natural landcover was identified from Anne Arundel County's 2020 landcover data, and defined as the combination of Forested Wetland, Open Wetland, Woods-Coniferous, Woods-Deciduous, and Woods-Mixed.</p> 
<br>
<p style='font-family:palanquin;font-size:24px;font-style:normal; font-weight: 600;color: #545252;'>Parameter Information
<br></p>
<p style='font-family:palanquin;text-align: justify;' >
<b>Parameters:  </b> Parameters used in this tool include flood data, environmental encumbrances such as the presence of wetlands, streams, and steep slopes, parcel size, and natural landcover. All parameters are scaled between 0 and 1.  <br> <br>
Flood data parameters include the percentage of each parcel within First Street Foundation's 2022, 2037, and 2052 scenarios of a 1 in 2 year floodplain, a 1 in 5 year floodplain, a 1 in 20 year floodplain, a 1 in 100 year floodplain, a 1 in 500 year floodplain, in addition to FEMA's non-tidal 100-year floodplain, FEMAs tidal 100-year floodplain, a height above nearest drainage elevation of <1.8 ft, and a height above nearest drainage elevation of <4.1 ft.  <br> <br> 
Wetlands were identified using the Maryland Department of Natural Resources' Wetlands Layer, with a 100-ft buffer delineated around them.  The percentage of each parcel within the wetland polygon and its 100-ft buffer was then calculated.   Streams were identified using Anne Arundel County's stream layer, with segments such concrete channels, storm pipes, shorelines, stormdrains, and culverts excluded.  A 100-ft buffer was delineated around the stream segments, and the percentage of each parcel intersecting with the stream polyline and its 100-ft buffer was then calculated.  Steep slopes were identified as slopes >= 25% and were calculated using the 2020 County LiDAR-derived DEM.  A 100-ft buffer was delineated around the steep sloping areas, and the percentage of each parcel within the steep sloping areas and their 100-ft buffer was then calculated.  <br><br>   
Parcel size was calculated using the geometry of the parcel, and natural landcover was defined as above. <br><br>
<b>Parcel Importance Score:  </b> The Parcel Importance Score is calculated as the weighted sum of all parameters noted above.  By default all parameters are weighted by 0.5 (i.e., parameter value x 0.5).  The user can change these weights to aid decision making, and refresh the results with updated weights by clicking the 'Refresh Parcel Score' button.  For example, if flood data is not of interest, all flood parameters can be set to 0, which will exclude these parameters from the Parcel Importance Score.  Likewise, if flood data is of interest, all flood parameters can be set to 1, which will give these parameters the highest weight when calculating the Parcel Importance Score. </p><br>  
<p style='font-family:palanquin;font-size:24px;font-style:normal; font-weight: 600;color: #545252;'> Filtering Map Display
<br> </p>
<p style='font-family:palanquin;text-align: justify;'>
By default, the map and its legend displays the Parcel Importance Score.  This can be changed using the drop down at the top of the tool.  The symbology and map legend will be updated accordingly.  Please note that updating the parameter weights will not change the raw scores for each parameter.  <br> <br> 
The parcels displayed on the map can also be filtered by the default or updated Parcel Importance Scores using the 'Range of Parcel Scores to Display' slider.  This is intended as a quick visual screen, to assist the user with identifying parcels in a desired Parcel Importance Score range.  By default the range is set to Parcel Importance Score values between 0 and 1 (the full range). </p> <br>  
<p style='font-family:palanquin;font-size:24px;font-style:normal; font-weight: 600;color: #545252;'> Selecting and Summarizing Results
<br></p>
<p style='font-family:palanquin;text-align: justify;'>
The user can select and summarize the results by clicking on each parcel.  This will add the account numbers to the 'Selected Lot(s)' box above the map, the features will turn black, and the summary of the selected parcels will be displayed in the Selection Summary tab.  To deselect the features, the user can either re-click them, or deleted them from the 'Selected Lot(s)' box above the map.  <br><br> 
The tabular summary in the Selection Summary tab includes the Tax Account Number, the Parcel Importance Score, Parcel Area, City, Last Sale Price, Last Sale Date, Assessed Value (both land and any improvements), the delta between the Sale Price and Assessed Value, whether the parcel intersects with a Stream, whether the Parcel is within 100-ft of a stream, and the % of Environmental Encumbrances, defined as the non-overlapping sum of Streams, Wetlands, and Steep Slopes areas, and their 100-ft buffers. <br><br>   
Above the summary table is the 'Download Full Table' button which will download an expanded summary table in a .xlsx format.  In addition to the parameters explained above and the parameters included in the Parcel Importance Score, the expanded table also includes information such as the owner, address, percentage of natural landcover using data from both Anne Arundel County and the Chesapeake Bay Conservancy, the mean slope within the parcel, and the mean flood depth for all scenarios using First Street Foundation's data. </p> "
               , type = "info", showCancelButton = TRUE, closeOnClickOutside = TRUE, size = "l", html = TRUE)
  })
  
  #===================================================
  # Score Calculation
  #===================================================
  
  flood_simp_dat <- eventReactive(input$calc,{
    flood_simp_dat <- flood_simp %>% mutate(SF2022_2_Percent_norm = scale_01(`% 1 in 2 Year Flood [2022 Scenario]`*input$f1in2_2022),
                                            SF2022_5_Percent_norm = scale_01(`% 1 in 5 Year Flood [2022 Scenario]`*input$f1in5_2022),
                                            SF2022_20_Percent_norm = scale_01(`% 1 in 20 Year Flood [2022 Scenario]`*input$f1in20_2022),
                                            SF2022_100_Percent_norm = scale_01(`% 1 in 100 Year Flood [2022 Scenario]`*input$f1in100_2022),
                                            SF2022_500_Percent_norm = scale_01(`% 1 in 500 Year Flood [2022 Scenario]`*input$f1in500_2022),
                                            SF2037_2_Percent_norm = scale_01(`% 1 in 2 Year Flood [2037 Scenario]`*input$f1in2_2037),
                                            SF2037_5_Percent_norm = scale_01(`% 1 in 5 Year Flood [2037 Scenario]`*input$f1in5_2037),
                                            SF2037_20_Percent_norm = scale_01(`% 1 in 20 Year Flood [2037 Scenario]`*input$f1in20_2037),
                                            SF2037_100_Percent_norm = scale_01(`% 1 in 100 Year Flood [2037 Scenario]`*input$f1in100_2037),
                                            SF2037_500_Percent_norm = scale_01(`% 1 in 500 Year Flood [2037 Scenario]`*input$f1in500_2037),
                                            SF2052_2_Percent_norm = scale_01(`% 1 in 2 Year Flood [2052 Scenario]`*input$f1in2_2052),
                                            SF2052_5_Percent_norm = scale_01(`% 1 in 5 Year Flood [2052 Scenario]`*input$f1in5_2052),
                                            SF2052_20_Percent_norm = scale_01(`% 1 in 20 Year Flood [2052 Scenario]`*input$f1in20_2052),
                                            SF2052_100_Percent_norm = scale_01(`% 1 in 100 Year Flood [2052 Scenario]`*input$f1in100_2052),
                                            SF2052_500_Percent_norm = scale_01(`% 1 in 500 Year Flood [2052 Scenario]`*input$f1in500_2052),
                                            FEMANon_SF_Percent_norm = scale_01(`% FEMA Non-Tidal 100-year Floodplain`*input$fema_nontid_100),
                                            FEMATid_SF_Percent_norm = scale_01(`% FEMA Tidal 100-year Floodplain`*input$fema_tid_100),
                                            HAND18SqFt_Percent_norm = scale_01(`% HAND <1.8-ft`*input$hand_1_8),
                                            HAND41SqFt_Percent_norm = scale_01(`% HAND <4.1-ft`*input$hand_4_1),
                                            SlopeBufSF_Percent_norm = scale_01(`% High Slope + 100-ft Buffer`*input$slope),
                                            StrmBuffSF_Percent_norm = scale_01(`% Stream + 100-ft Buffer`*input$streams),
                                            WetBuffSF_Percent_norm  = scale_01(`% Wetland + 100-ft Buffer`*input$wetlands),
                                            ParcelArea_norm = scale_01(scale_01(`Parcel Area (sq ft)`)*input$parcel_size),
                                            NatLandcover_Percent_norm  = scale_01(`% Natural Landcover (AA Co. Data)`*input$natlandcover)) %>% rowwise() %>% mutate(score =round(sum(c(SF2022_2_Percent_norm,
                                                                                                                                                                                       SF2022_5_Percent_norm,
                                                                                                                                                                                       SF2022_20_Percent_norm,
                                                                                                                                                                                       SF2022_100_Percent_norm,
                                                                                                                                                                                       SF2022_500_Percent_norm,
                                                                                                                                                                                       SF2037_2_Percent_norm,
                                                                                                                                                                                       SF2037_5_Percent_norm,
                                                                                                                                                                                       SF2037_20_Percent_norm,
                                                                                                                                                                                       SF2037_100_Percent_norm,
                                                                                                                                                                                       SF2037_500_Percent_norm,
                                                                                                                                                                                       SF2052_2_Percent_norm,
                                                                                                                                                                                       SF2052_5_Percent_norm,
                                                                                                                                                                                       SF2052_20_Percent_norm,
                                                                                                                                                                                       SF2052_100_Percent_norm,
                                                                                                                                                                                       SF2052_500_Percent_norm,
                                                                                                                                                                                       FEMANon_SF_Percent_norm,
                                                                                                                                                                                       FEMATid_SF_Percent_norm,
                                                                                                                                                                                       HAND18SqFt_Percent_norm,
                                                                                                                                                                                       HAND41SqFt_Percent_norm,
                                                                                                                                                                                       SlopeBufSF_Percent_norm,
                                                                                                                                                                                       StrmBuffSF_Percent_norm,
                                                                                                                                                                                       WetBuffSF_Percent_norm,
                                                                                                                                                                                       ParcelArea_norm,
                                                                                                                                                                                       NatLandcover_Percent_norm),na.rm = T),2)) %>%
      ungroup() %>% mutate(`Parcel Importance Score` = round(scale_01(score),2)) %>%
      select(-c(score,
                SF2022_2_Percent_norm,
                SF2022_5_Percent_norm,
                SF2022_20_Percent_norm,
                SF2022_100_Percent_norm,
                SF2022_500_Percent_norm,
                SF2037_2_Percent_norm,
                SF2037_5_Percent_norm,
                SF2037_20_Percent_norm,
                SF2037_100_Percent_norm,
                SF2037_500_Percent_norm,
                SF2052_2_Percent_norm,
                SF2052_5_Percent_norm,
                SF2052_20_Percent_norm,
                SF2052_100_Percent_norm,
                SF2052_500_Percent_norm,
                FEMANon_SF_Percent_norm,
                FEMATid_SF_Percent_norm,
                HAND18SqFt_Percent_norm,
                HAND41SqFt_Percent_norm,
                SlopeBufSF_Percent_norm,
                StrmBuffSF_Percent_norm,
                WetBuffSF_Percent_norm,
                ParcelArea_norm,
                NatLandcover_Percent_norm))
    flood_simp_dat
  }, ignoreNULL = FALSE)
  
  
  #===================================================
  # Map
  #===================================================
  
  filteredData <- reactive({
    #filteredData <- flood_simp[shore_simp$final_score >= input$maprange[1] & flood_simp$final_score <= input$maprange[2],]
    fSimp = flood_simp_dat()
    filteredData <- fSimp %>% filter(`Parcel Importance Score` >= input$maprange[1] & `Parcel Importance Score` <= input$maprange[2])
    #print(filteredData)
    filteredData
  })
  
  #create empty vector to hold all the clicks
  selected_ids <- reactiveValues(ids = vector())
  
  # flood layers map output  
  flood.pal <- colorBin("Blues",0:1,bins = c(0, 0.20, 0.40, 0.60, 0.80, 1))

  # leaflet output (initial)
  output$map <- renderLeaflet({
    datSimp = flood_simp_dat()
    leaflet() %>%
      setView(lng = -76.56, lat = 38.97, zoom = 13) %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE), group = "Stamen Base Map")%>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Esri Imagery") %>%
      addPolygons(data =  datSimp,
                  fillColor = ~flood.pal(`Parcel Importance Score`),
                  fillOpacity = 1,
                  color = "black",
                  stroke = TRUE,
                  weight = 1,
                  layerId = ~`Tax Account Number`,
                  group = "parcels",
                  label = ~`Tax Account Number`,
                  highlightOptions = highlightOptions(color = "white",
                                                      opacity = 1.0,
                                                      weight = 3,
                                                      bringToFront = TRUE)) %>%
      addPolygons(data =  datSimp,
                  fillColor = "black",
                  fillOpacity = 1,
                  weight = 1,
                  color = "black",
                  stroke = TRUE,
                  layerId = ~AccntNo_2,
                  group = ~`Tax Account Number`) %>%
      hideGroup(group = datSimp$`Tax Account Number`)%>%
      addMiniMap(
        tiles = providers$Stamen.TonerLite,
        position = 'topright', 
        width = 200, height = 200,
        toggleDisplay = FALSE,
        aimingRectOptions = list(color = "red", weight = 1, clickable = FALSE),
        zoomLevelOffset=-5) %>%
      addLayersControl(baseGroups = c("Stamen Base Map","Esri Imagery"),
                       options = layersControlOptions(collapsed = FALSE))
  })
  
  #define leaflet proxy for maps
  proxy <- leafletProxy("map")
  
  # update map
  observe({
      if(input$mapParam == "Parcel Importance Score"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`Parcel Importance Score`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`Parcel Importance Score`, opacity = 1, title =  "Parcel Importance Score",
                                                                    position = "bottomleft")
      }else if(input$mapParam == "1 in 2 Year Flood (2022 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 2 Year Flood [2022 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 2 Year Flood [2022 Scenario]`, opacity = 0.7, title =  "% 1 in 2 Year Flood (2022 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 5 Year Flood (2022 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 5 Year Flood [2022 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 5 Year Flood [2022 Scenario]`, opacity = 0.7, title =  "% 1 in 5 Year Flood (2022 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 20 Year Flood (2022 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 20 Year Flood [2022 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 20 Year Flood [2022 Scenario]`, opacity = 0.7, title =  "% 1 in 20 Year Flood (2022 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 100 Year Flood (2022 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 100 Year Flood [2022 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 100 Year Flood [2022 Scenario]`, opacity = 0.7, title =  "% 1 in 100 Year Flood (2022 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 500 Year Flood (2022 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 500 Year Flood [2022 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 500 Year Flood [2022 Scenario]`, opacity = 0.7, title =  "% 1 in 500 Year Flood (2022 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 2 Year Flood (2037 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 2 Year Flood [2037 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 2 Year Flood [2037 Scenario]`, opacity = 0.7, title =  "% 1 in 2 Year Flood (2037 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 5 Year Flood (2037 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 5 Year Flood [2037 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 5 Year Flood [2037 Scenario]`, opacity = 0.7, title =  "% 1 in 5 Year Flood (2037 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 20 Year Flood (2037 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 20 Year Flood [2037 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 20 Year Flood [2037 Scenario]`, opacity = 0.7, title =  "% 1 in 20 Year Flood (2037 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 100 Year Flood (2037 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 100 Year Flood [2037 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 100 Year Flood [2037 Scenario]`, opacity = 0.7, title =  "% 1 in 100 Year Flood (2037 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 500 Year Flood (2037 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 500 Year Flood [2037 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 500 Year Flood [2037 Scenario]`, opacity = 0.7, title =  "% 1 in 500 Year Flood (2037 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 2 Year Flood (2052 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 2 Year Flood [2052 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 2 Year Flood [2052 Scenario]`, opacity = 0.7, title =  "% 1 in 2 Year Flood (2052 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 5 Year Flood (2052 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 5 Year Flood [2052 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 5 Year Flood [2052 Scenario]`, opacity = 0.7, title =  "% 1 in 5 Year Flood (2052 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 20 Year Flood (2052 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 20 Year Flood [2052 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 100 Year Flood [2052 Scenario]`, opacity = 0.7, title =  "% 1 in 100 Year Flood (2052 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 100 Year Flood (2052 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 100 Year Flood [2052 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 100 Year Flood [2052 Scenario]`, opacity = 0.7, title =  "% 1 in 100 Year Flood (2052 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "1 in 500 Year Flood (2052 Scenario)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% 1 in 500 Year Flood [2052 Scenario]`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% 1 in 500 Year Flood [2052 Scenario]`, opacity = 0.7, title =  "% 1 in 500 Year Flood (2052 Scenario)",
                    position = "bottomleft")
      }else if(input$mapParam == "FEMA Non-Tidal 100-Year Floodplain"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% FEMA Non-Tidal 100-year Floodplain`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% FEMA Non-Tidal 100-year Floodplain`, opacity = 0.7, title =  "% FEMA Non-Tidal 100-Year Floodplain",
                    position = "bottomleft")
      }else if(input$mapParam == "FEMA Tidal 100-Year Floodplain"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% FEMA Tidal 100-year Floodplain`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% FEMA Tidal 100-year Floodplain`, opacity = 0.7, title =  "% FEMA Tidal 100-Year Floodplain",
                    position = "bottomleft")
      }else if(input$mapParam == "Height Above Nearest Drainage (<1.8 ft)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% HAND <1.8-ft`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% HAND <1.8-ft`, opacity = 0.7, title =  "% Height Above Nearest Drainage (<1.8 ft)",
                    position = "bottomleft")
      }else if(input$mapParam == "Steep Slopes + 100 ft Buffer"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% High Slope + 100-ft Buffer`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% High Slope + 100-ft Buffer`, opacity = 0.7, title =  "% Steep Slopes + 100 ft Buffer",
                    position = "bottomleft")
      }else if(input$mapParam == "Streams + 100 ft Buffer"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% Stream + 100-ft Buffer`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% Stream + 100-ft Buffer`, opacity = 0.7, title =  "% Streams + 100 ft Buffer",
                    position = "bottomleft")
      }else if(input$mapParam == "Wetlands + 100 ft Buffer"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% Wetland + 100-ft Buffer`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% Wetland + 100-ft Buffer`, opacity = 0.7, title =  "% Wetlands + 100 ft Buffer",
                    position = "bottomleft")
      }else if(input$mapParam == "Height Above Nearest Drainage (<4.1 ft)"){
        proxy %>%
          clearShapes() %>%
          clearControls() %>%
          addPolygons(data =  filteredData(),
                      fillColor = ~flood.pal(`% HAND <4.1-ft`),
                      fillOpacity = 1,
                      color = "black",
                      stroke = TRUE,
                      weight = 1,
                      layerId = ~`Tax Account Number`,
                      group = "parcels",
                      label = ~`Tax Account Number`,
                      highlightOptions = highlightOptions(color = "white",
                                                          opacity = 1.0,
                                                          weight = 3,
                                                          bringToFront = TRUE)) %>%
          addPolygons(data =  filteredData(),
                      fillColor = "black",
                      fillOpacity = 1,
                      weight = 1,
                      color = "black",
                      stroke = TRUE,
                      layerId = ~AccntNo_2,
                      group = ~`Tax Account Number`)%>%
          addLegend(pal = flood.pal, values =filteredData()$`% HAND <4.1-ft`, opacity = 0.7, title =  "% Height Above Nearest Drainage (<4.1 ft)",
                    position = "bottomleft")
      }  
  })
  
  
  #create empty vector to hold all the clicks
  selected <- reactiveValues(groups = vector())
  
  observeEvent(input$map_shape_click, {
    if(input$map_shape_click$group == "parcels"){
      selected$groups <- c(selected$groups, input$map_shape_click$id)
      proxy %>% showGroup(group = input$map_shape_click$id)
    } else {
      selected$groups <- setdiff(selected$groups, input$map_shape_click$group)
      proxy %>% hideGroup(group = input$map_shape_click$group)
    }
    updateSelectizeInput(session,
                         inputId = "selected_locations",
                         label = "Selected Lot(s):",
                         choices = flood_simp_dat() %>% select(`Tax Account Number`),
                         selected = selected$groups,
                         server = FALSE)
  })
  
  
  
  observeEvent(input$selected_locations, {
    removed_via_selectInput <- setdiff(selected$groups, input$selected_locations)
    added_via_selectInput <- setdiff(input$selected_locations, selected$groups)
    
    if(length(removed_via_selectInput) > 0){
      selected$groups <- input$selected_locations
      proxy %>% hideGroup(group = removed_via_selectInput)
    }
    
    if(length(added_via_selectInput) > 0){
      selected$groups <- input$selected_locations
      proxy %>% showGroup(group = added_via_selectInput)
    }
  }, ignoreNULL = FALSE)
  
  selectedLocations <- reactive({
    selectedLocations <- subset(flood_simp_dat(), `Tax Account Number` %in% input$selected_locations)%>%
      select(-c("AccntNo_2")) %>%
      relocate(`Parcel Importance Score`, .after = `Tax Account Number`) %>%
      st_drop_geometry()
    selectedLocations
    
  })
  

  output$selectionresults <- renderDataTable({
    datatable(subset(flood_simp_dat(), `Tax Account Number` %in% input$selected_locations)%>%
                select(c(c("Tax Account Number","Parcel Importance Score","Parcel Area (sq ft)","City","Last Sale Price ($)",
                           "Last Sale Date","Assessed Value ($) [Land and Improvements]","Last Sale Price Minus Assessed Value ($)",
                           "Parcel has Stream?","Parcel within 100-ft of Stream?","% Environmental Encumbrances"))) %>%
                st_drop_geometry(),
              rownames = FALSE,options = list(searching = TRUE))
  })
  
  output$downloadres <- downloadHandler(
    filename = function() {
      paste0('FloodRiskSummarizeR_FullTable_',Sys.Date(),".xlsx")
    }
    ,
    content = function(file) {write_xlsx(selectedLocations(), path = file)}
  )
  
}