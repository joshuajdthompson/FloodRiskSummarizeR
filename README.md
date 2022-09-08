# General Information

The shiny app can be accessed [here](https://jjdthompson.shinyapps.io/FloodRiskSummarizeR/).

The undeveloped parcels presented in this tool were identified by an assessed improvement value of \$0. Furthermore, property owned by the United States Government, the State of Maryland, or areas owned by Baltimore Gas & Electric were omitted, as these areas are either unlikely to be developed or are outside Anne Arundel County's jurisdiction.

Some undeveloped parcels are currently being used as golf courses or quarries, and have a small likelihood of development. A natural landcover threshold was used to omit these areas, where only those parcels with \>=80% natural landcover were retained. Natural landcover was identified from Anne Arundel County's 2020 landcover data, and defined as the combination of Forested Wetland, Open Wetland, Woods-Coniferous, Woods-Deciduous, and Woods-Mixed.

# Parameter Information

**Parameters:** Parameters used in this tool include flood data, environmental encumbrances such as the presence of wetlands, streams, and steep slopes, parcel size, and natural landcover. All parameters are scaled between 0 and 1.

Flood data parameters include the percentage of each parcel within First Street Foundation's 2022, 2037, and 2052 scenarios of a 1 in 2 year floodplain, a 1 in 5 year floodplain, a 1 in 20 year floodplain, a 1 in 100 year floodplain, a 1 in 500 year floodplain, in addition to FEMA's non-tidal 100-year floodplain, FEMAs tidal 100-year floodplain, a height above nearest drainage elevation of \<1.8 ft, and a height above nearest drainage elevation of \<4.1 ft.

Wetlands were identified using the Maryland Department of Natural Resources' Wetlands Layer, with a 100-ft buffer delineated around them. The percentage of each parcel within the wetland polygon and its 100-ft buffer was then calculated. Streams were identified using Anne Arundel County's stream layer, with segments such concrete channels, storm pipes, shorelines, stormdrains, and culverts excluded. A 100-ft buffer was delineated around the stream segments, and the percentage of each parcel intersecting with the stream polyline and its 100-ft buffer was then calculated. Steep slopes were identified as slopes \>= 25% and were calculated using the 2020 County LiDAR-derived DEM. A 100-ft buffer was delineated around the steep sloping areas, and the percentage of each parcel within the steep sloping areas and their 100-ft buffer was then calculated.

Parcel size was calculated using the geometry of the parcel, and natural landcover was defined as above.

**Parcel Importance Score:** The Parcel Importance Score is calculated as the weighted sum of all parameters noted above. By default all parameters are weighted by 0.5 (i.e., parameter value x 0.5). The user can change these weights to aid decision making, and refresh the results with updated weights by clicking the 'Refresh Parcel Score' button. For example, if flood data is not of interest, all flood parameters can be set to 0, which will exclude these parameters from the Parcel Importance Score. Likewise, if flood data is of interest, all flood parameters can be set to 1, which will give these parameters the highest weight when calculating the Parcel Importance Score.

![alt text](https://github.com/joshuajdthompson/FloodRiskSummarizeR/blob/main/FloodSummarizeRRefreshScores.gif?raw=true)

# Filtering Map Display

By default, the map and its legend displays the Parcel Importance Score. This can be changed using the drop down at the top of the tool. The symbology and map legend will be updated accordingly. Please note that updating the parameter weights will not change the raw scores for each parameter.

The parcels displayed on the map can also be filtered by the default or updated Parcel Importance Scores using the 'Range of Parcel Scores to Display' slider. This is intended as a quick visual screen, to assist the user with identifying parcels in a desired Parcel Importance Score range. By default the range is set to Parcel Importance Score values between 0 and 1 (the full range).

![alt text](https://github.com/joshuajdthompson/FloodRiskSummarizeR/blob/main/FloodSummarizeRFilterLayers.gif?raw=true)

# Selecting and Summarizing Results

The user can select and summarize the results by clicking on each parcel. This will add the account numbers to the 'Selected Lot(s)' box above the map, the features will turn black, and the summary of the selected parcels will be displayed in the Selection Summary tab. To deselect the features, the user can either re-click them, or deleted them from the 'Selected Lot(s)' box above the map.

The tabular summary in the Selection Summary tab includes the Tax Account Number, the Parcel Importance Score, Parcel Area, City, Last Sale Price, Last Sale Date, Assessed Value (both land and any improvements), the delta between the Sale Price and Assessed Value, whether the parcel intersects with a Stream, whether the Parcel is within 100-ft of a stream, and the % of Environmental Encumbrances, defined as the non-overlapping sum of Streams, Wetlands, and Steep Slopes areas, and their 100-ft buffers.

![alt text](https://github.com/joshuajdthompson/FloodRiskSummarizeR/blob/main/FloodSummarizeRSelectSummary.gif?raw=true)

Above the summary table is the 'Download Full Table' button which will download an expanded summary table in a .xlsx format. In addition to the parameters explained above and the parameters included in the Parcel Importance Score, the expanded table also includes information such as the owner, address, percentage of natural landcover using data from both Anne Arundel County and the Chesapeake Bay Conservancy, the mean slope within the parcel, and the mean flood depth for all scenarios using First Street Foundation's data.
