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
## Notes: This script creates three watersheds layers: 
##          - All water licences
##          - Water licences without data from Indigenous Services Canada (ISC)
##          - Water licences from ISC only
##
##   We strongly recommend reading the data descriptor for best use of the data
##    and reuse of this script.
##
## ---------------------------

## General options -------------------------------------------------------------

options(scipen = 6, digits = 4) # non-scientific notation
memory.limit(30000000)     # increase memory allowance

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
  outlets <- "HYDROLAB_MCGILL/Pourpoints_WGS84_RiverAtlas_Segments_With_Licence_V2.shp"
  d8_ptr <- "HYDROSHEDS/hyd_na_ar_dir_merge_15s.tif"
  output_basins <- "NRCAN/Unnest_Basins/Unnest_Basins.tif"
  
  wbt_unnest_basins(d8_pntr = d8_ptr, 
                    pour_pts = outlets, 
                    output = output_basins,
                    esri_pntr = T,
                    verbose_mode = T,
                    compress_rasters = T)
 
  # Convert raster basins to polygons
  ws_tif <- list.files("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins",
                       pattern = ".tif$")
  for(i in ws_tif){
    tif <- i
    ws <- paste0(i,".shp")
    wbt_raster_to_vector_polygons(input = tif,
                                  output = ws,
                                  wd = "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins",
                                  verbose_mode = T)
  }

  # Merge catchment polygons
  file_list <- list.files("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins",
                          pattern = "*shp", full.names = TRUE)
  
  shapefile_list <- lapply(file_list, read_sf)
  
  can_catch <- sf::st_as_sf(data.table::rbindlist(shapefile_list)) %>%
    select(-FID)
  
  # Write output
  st_write(can_catch, 
          "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can-SWaP_AllLicences_V1.gpkg")
  
  
                ###############################################
                ########## Licenced basins (no ISC) ###########
                ###############################################
  
  # Compute raster basins
  outlets <- "HYDROLAB_MCGILL/Pourpoints_WGS84_RiverAtlas_Segments_With_Licence_V2.shp"
  d8_ptr <- "HYDROSHEDS/hyd_na_ar_dir_merge_15s.tif"
  output_basins <- "NRCAN/Unnest_Basins/Unnest_Basins.tif"
  
  wbt_unnest_basins(d8_pntr = d8_ptr, 
                    pour_pts = outlets, 
                    output = output_basins,
                    esri_pntr = T,
                    verbose_mode = T,
                    compress_rasters = T)
  
  # Convert raster basins to polygons
  ws_tif <- list.files("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins",
                       pattern = ".tif$")
  for(i in ws_tif){
    tif <- i
    ws <- paste0(i,".shp")
    wbt_raster_to_vector_polygons(input = tif,
                                  output = ws,
                                  wd = "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins",
                                  verbose_mode = T)
  }
  
  # Merge catchment polygons
  file_list <- list.files("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins",
                          pattern = "*shp", full.names = TRUE)
  
  shapefile_list <- lapply(file_list, read_sf)
  
  can_catch <- sf::st_as_sf(data.table::rbindlist(shapefile_list)) %>%
    select(-FID)
  
  # reproject polygon layer
  can_catch_3979 <- st_transform(can_catch, crs = 3979)
  # Write output
  st_write(can_catch, 
           "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can-SWaP_AllLicences_V1.gpkg",
           delete_dsn = T)
  
  
  
                        #################################
                        ########## ISC basins ###########
                        #################################
  
  # Compute raster basins
  outlets <- "HYDROLAB_MCGILL/Pourpoints_WGS84_RiverAtlas_Segments_With_Licence_V2.shp"
  d8_ptr <- "HYDROSHEDS/hyd_na_ar_dir_merge_15s.tif"
  output_basins <- "NRCAN/Unnest_Basins/Unnest_Basins.tif"
  
  wbt_unnest_basins(d8_pntr = d8_ptr, 
                    pour_pts = outlets, 
                    output = output_basins,
                    esri_pntr = T,
                    verbose_mode = T,
                    compress_rasters = T)
  
  # Convert raster basins to polygons
  ws_tif <- list.files("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins",
                       pattern = ".tif$")
  for(i in ws_tif){
    tif <- i
    ws <- paste0(i,".shp")
    wbt_raster_to_vector_polygons(input = tif,
                                  output = ws,
                                  wd = "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins",
                                  verbose_mode = T)
  }
  
  # Merge catchment polygons
  file_list <- list.files("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins",
                          pattern = "*shp", full.names = TRUE)
  
  shapefile_list <- lapply(file_list, read_sf)
  
  can_catch <- sf::st_as_sf(data.table::rbindlist(shapefile_list)) %>%
    select(-FID)
  
  # Write output
  st_write(can_catch, 
           "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA/NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can-SWaP_AllLicences_V1.gpkg")
  