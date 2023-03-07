## ---------------------------
##
## Script name: 01_CreateMunicipalCatchments.R
##
## Purpose: Create source water catchment for municipal water supply in Canada
##          Based on location of municipal water licences as they
##          connect to HydroRIVERS/RiverATLAS
##
## Author: Dr. François-Nicolas Robinne, Canadian Forest Service
##
## Date Created: 2022-11-04
##
## Email: francois.robinne@nrcan-rncan.gc.ca
##
## ---------------------------
##
## Notes: This script creates two watersheds layers: 
##          - All water licences
##          - Water licences without data from Indigenous Services Canada (ISC)
##  
##    Beware of file names when running the script with data from the FigShare repo 
##    
##    We strongly recommend reading the data descriptor for best use of the data
##    and reuse of this script.
##
## ---------------------------

## General options -------------------------------------------------------------

options(scipen = 6, digits = 4) # non-scientific notation

## Load libraries --------------------------------------------------------------

library(whitebox)
  wbt_init(exe_path = 'C:/Users/frobinne/Documents/WhiteboxTools/WBT/whitebox_tools.exe')
library(sf)
library(tidyverse)

## Set working directory -------------------------------------------------------
  
setwd("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA")
  
## Processing ------------------------------------------------------------------
  
                    #################################
                    ########## All basins ###########
                    #################################
 
   # Compute raster basins
  outlets <- "HYDROLAB_MCGILL/Intakes_WGS84_RiverAtlas_Segments_With_Licence_V4.shp"
  d8_ptr <- "HYDROLAB_MCGILL/hyd_na_ar_dir_merge_15s.tif"
  output_basins <- "NRCAN/Unnest_Basins/Municipal_Catchments_V1/All_Licences/Unnest_Basins.tif"
  
  wbt_unnest_basins(d8_pntr = d8_ptr, 
                    pour_pts = outlets, 
                    output = output_basins,
                    esri_pntr = T,
                    verbose_mode = T,
                    compress_rasters = T)
 
  # Convert raster basins to polygons
  ws_tif <- list.files("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins/Municipal_Catchments_V1/All_Licences",
                       pattern = ".tif$")
  for(i in ws_tif){
    tif <- i
    ws <- paste0(i,".shp")
    wbt_raster_to_vector_polygons(input = tif,
                                  output = ws,
                                  wd = "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins/Municipal_Catchments_V1/All_Licences",
                                  verbose_mode = T)
  }

  # Merge catchment polygons
  file_list <- list.files("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins/Municipal_Catchments_V1/All_Licences",
                          pattern = "*shp", full.names = TRUE)
  
  shapefile_list <- lapply(file_list, read_sf)
  
  can_catch <- sf::st_as_sf(data.table::rbindlist(shapefile_list)) %>%
    select(-FID)
  
  # Write output
  st_write(can_catch, 
          "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can-SWaP_AllLicences_V2.gpkg")
  
  
                ###############################################
                ########## Licenced basins (no ISC) ###########
                ###############################################
  
  # Compute raster basins
  outlets_ISC <- "HYDROLAB_MCGILL/Intakes_WGS84_RiverAtlas_Segments_With_Licence_V4_NoISC.shp"
  d8_ptr <- "HYDROLAB_MCGILL/hyd_na_ar_dir_merge_15s.tif"
  output_basins_ISC <- "NRCAN/Unnest_Basins/Municipal_Catchments_V1/No_ISC/Unnest_Basins.tif"
  
  wbt_unnest_basins(d8_pntr = d8_ptr, 
                    pour_pts = outlets_ISC, 
                    output = output_basins_ISC,
                    esri_pntr = T,
                    verbose_mode = T,
                    compress_rasters = T)
  
  # Convert raster basins to polygons
  ws_tif <- list.files("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins/Municipal_Catchments_V1/No_ISC",
                       pattern = ".tif$")
  for(i in ws_tif){
    tif <- i
    ws <- paste0(i,".shp")
    wbt_raster_to_vector_polygons(input = tif,
                                  output = ws,
                                  wd = "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins/Municipal_Catchments_V1/No_ISC",
                                  verbose_mode = T)
  }
  
  # Merge catchment polygons
  file_list <- list.files("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins/Municipal_Catchments_V1/No_ISC",
                          pattern = "*shp", full.names = TRUE)
  
  shapefile_list <- lapply(file_list, read_sf)
  
  can_catch_ISC <- sf::st_as_sf(data.table::rbindlist(shapefile_list)) %>%
    select(-FID)
  
  # reproject polygon layer
  can_catch_ISC_3979 <- st_transform(can_catch_ISC, crs = 3979)
  # Write output
  st_write(can_catch_ISC_3979, 
           "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can-SWaP_AllLicences_V2_NoISC.gpkg",
           delete_dsn = T)
  