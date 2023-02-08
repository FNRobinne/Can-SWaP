## ---------------------------
##
## Script name: 01_CreateMunicipalCatchments.R
##
## Purpose: Create source water catchment for municipal water supply in Canada
##          Based on location of municipal water licences (intakes) as they
##          connect to HydroRivers
##
## Author: Dr. François-Nicolas Robinne, Canadian Forest Service
##
## Date Created: 2022-11-04
##
## Email: francois.robinne@nrcan-rncan.gc.ca
##
## ---------------------------
##
## Notes: 
##   
##
## ---------------------------

## General options -------------------------------------------------------------

options(scipen = 6, digits = 4) # non-scientific notation
memory.limit(30000000)     # increase memory allowance

## Load libraries --------------------------------------------------------------
library(whitebox)
  wbt_init()
library(sf)
library(tidyverse)

## Set working directory -------------------------------------------------------
  setwd("C:/Users/frobinne/Documents/Professionel/45_2022_CANADA_FOREST_CHANGE_MUNICIPAL_CATCHMENTS_ACTIVE/02_PROCESSED_DATA")

## Processing ------------------------------------------------------------------
  
                        ### DEM conditioning ###
  
  # Burning is applied as new segments were added to Hydrosheds
  # Burn Updated Hydrorivers into Hydrosheds 30s (~450m resolution)
  # streams <- "HYDROSHEDS/HydroRivers_v10_just_Can_whole_edited.shp"
  dem <- "HYDROSHEDS/hyd_na_ar_merge.tif"
  output_burn <- "HYDROSHEDS/hyd_burn.tif"
  

  wbt_fill_burn(dem = dem,
                streams = streams,
                output = output_burn,
                #wd = "C:/Users/frobinne/OneDrive - NRCan RNCan/Documents/Professionel/PROJECTS/45_2022_CANADA_FOREST_CHANGE_MUNICIPAL_CATCHMENTS_ACTIVE/02_PROCESSED_DATA/HYDROSHEDS/HUC5_WhiteboxTest",
                verbose_mode = T)
  
  # Fill depressions
  dem_burn <- output_burn
  output_fill <- "HYDROSHEDS/hyd_fill.tif"
  
  wbt_breach_depressions_least_cost(dem = dem,
                                    output = output_fill,
                                    dist = 10,
                                    fill = T,
                                    verbose_mode = T)

                      ### Watershed delineation ###
  
  # Flow direction
  dem_fill <- output_fill
  output_d8 <- "HYDROSHEDS/FlowAcc_D8.tif"
  
  wbt_d8_pointer(dem = dem_fill, 
                 output = output_d8)
  
  # Compute basins
  outlets <- "NRCAN/Can_Mun_Surf_Intakes_Lakes&streams_snapped_on_hyrv.shp"
  d8_ptr <- "HYDROSHEDS/hyd_na_ar_dir_merge_15s.tif"
  output_basins <- "NRCAN/Unnest_Basins/Unnest_Basins.tif"
  
  wbt_unnest_basins(d8_pntr = d8_ptr, 
                    pour_pts = outlets, 
                    output = output_basins,
                    esri_pntr = T,
                    verbose_mode = T,
                    compress_rasters = T)
  
                    ### export basins to polygons ###
 
  # Convert basins to polygons
  ws_tif <- list.files("C:/Users/frobinne/Documents/Professionel/45_2022_CANADA_FOREST_CHANGE_MUNICIPAL_CATCHMENTS_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins",
                       pattern = ".tif$")
  for(i in ws_tif){
    tif <- i
    ws <- paste0(i,".shp")
    wbt_raster_to_vector_polygons(input = tif,
                                  output = ws,
                                  wd = "C:/Users/frobinne/Documents/Professionel/45_2022_CANADA_FOREST_CHANGE_MUNICIPAL_CATCHMENTS_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins",
                                  verbose_mode = T)
  }

  # Merge catchment polygons
  file_list <- list.files("C:/Users/frobinne/Documents/Professionel/45_2022_CANADA_FOREST_CHANGE_MUNICIPAL_CATCHMENTS_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins",
                          pattern = "*shp", full.names = TRUE)
  
  shapefile_list <- lapply(file_list, read_sf)
  
  can_catch <- sf::st_as_sf(data.table::rbindlist(shapefile_list)) %>%
    select(-FID)
  
  # Write output
  st_write(can_catch, 
          "C:/Users/frobinne/Documents/Professionel/45_2022_CANADA_FOREST_CHANGE_MUNICIPAL_CATCHMENTS_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins/Canada_municipal_catchments.gpkg")
  