## ---------------------------
##
## Script name: 04_PrepareFinalLayers.R
##
## Purpose: Doing minor cosmetic changes for delivery of final layers
##
## Author: Dr. François-Nicolas Robinne, Canadian Forest Service
##
## Date Created: 2023-03-06
##
## Email: francois.robinne@nrcan-rncan.gc.ca
##
## ---------------------------
##
## Notes: 
##
##    Beware of file names when running the script with data from the FigShare repo 
##
##    We strongly recommend reading the data descriptor for best use of the data
##    and reuse of this script, as well as HydroATLAS documentation
##
##   
## ---------------------------

## General options -------------------------------------------------------------

options(scipen = 6, digits = 4) # non-scientific notation

## Load libraries --------------------------------------------------------------

library(sf)
library(tidyverse)

## Set working directory -------------------------------------------------------

setwd("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA")

## Processing ------------------------------------------------------------------

  # Read data
  Intakes <- st_read("HYDROLAB_MCGILL/Intakes_RiverAtlas_Segments_With_Licence_V5.gpkg")
  Intakes_NoISC <- st_read("HYDROLAB_MCGILL/Intakes_RiverAtlas_Segments_With_Licence_V5_NoISC.gpkg")
  Confluences <- st_read("HYDROLAB_MCGILL/Intakes_RiverAtlas_Segments_With_Licence_Confluence_V1.gpkg")
  CanSwap <- st_read("NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can_SWaP_AllLicences_V2_CleanAtt.gpkg")
  CanSwap_NoISC <- st_read("NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can_SWaP_NoISCLicences_V2_CleanAtt.gpkg")

  # Clean-Up data and attributes for versions to be published
  # All intakes
  Intakes_NSD <- Intakes %>%
    select(-c(angle, distance, vertex_pos, vertex_index, vertex_part, vertex_part_index, YR_VOL_M3_count)) %>%
    mutate(DIS_M3_TYR = dis_m3_pyr * 31540000) %>% # total per year, based on discharge on M3 per second
    select(-dis_m3_pyr) %>%
    rename(WET_PC_UG2 = wet_pc_ug2,
           FOR_PC_USE = for_pc_use,
           PAC_PC_USE = pac_pc_use,
           HFT_IX_U09 = hft_ix_u09,
           INT_M3_YR = YR_VOL_M3_sum,
           JUR_NAME = PRENAME)
  
  # All intakes in WGS84
  Intakes_WGS84_NSD <- Intakes_NSD %>%
    st_transform(crs = 'EPSG:4326')
  
  # No ISC intakes (only licenced ones)
  Intakes_NoISC_NSD <- Intakes_NoISC %>%
    select(-c(angle, distance, vertex_pos, vertex_index, vertex_part, vertex_part_index, YR_VOL_M3_count)) %>%
    mutate(DIS_M3_TYR = dis_m3_pyr * 31540000) %>% # total per year, based on discharge on M3 per second
    select(-dis_m3_pyr) %>%
    rename(WET_PC_UG2 = wet_pc_ug2,
           FOR_PC_USE = for_pc_use,
           PAC_PC_USE = pac_pc_use,
           HFT_IX_U09 = hft_ix_u09,
           INT_M3_YR = YR_VOL_M3_sum,
           JUR_NAME = PRENAME)
  
  # No ISC intakes (only licenced ones) in WGS84
  Intakes_WGS84_NoISC_NSD <- Intakes_NoISC_NSD %>%
    st_transform(crs = 'EPSG:4326')
  
  # Confluences
  Confluences_NSD <- Confluences %>%
    rename(LENGTH_KM = LENGTH_KM.x,
           ORD_STRA = ORD_STRA.x,
           INT_M3_YR = YR_VOL_M3_sum,
           JUR_NAME = PRENAME)
  
  # Can-SWaP polygons (i.e., Catchments)
  CanSwap_NSD <- CanSwap %>%
    select(-YR_VOL_M3_count) %>%
    relocate(DIS_M3_TYR, .before = INT_M3_YR)
  
  # Can-SWaP polygons (i.e., Catchments), No ISC (only licenced ones)
  CanSwap_NoISC_NSD <- CanSwap_NoISC %>%
    select(-YR_VOL_M3_count) %>%
    relocate(DIS_M3_TYR, .before = INT_M3_YR)

  # Write final data
  st_write(Intakes_NSD, 
           "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/04_DOCS/SUBMISSION/DATASETS_FIGSHARE/Intakes_HydroRivers_Segments_With_Licence.gpkg",
           delete_dsn = T)
  st_write(Intakes_NoISC_NSD,
           "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/04_DOCS/SUBMISSION/DATASETS_FIGSHARE/Intakes_HydroRivers_Segments_With_Licence_NoISC.gpkg",
           delete_dsn = T)
  st_write(Intakes_WGS84_NSD,
           "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/04_DOCS/SUBMISSION/DATASETS_FIGSHARE/Intakes_HydroRivers_Segments_With_Licence_WGS84.gpkg",
           delete_dsn = T)
  st_write(Intakes_WGS84_NoISC_NSD,
           "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/04_DOCS/SUBMISSION/DATASETS_FIGSHARE/Intakes_HydroRivers_Segments_With_Licence_NoISC_WGS84.gpkg",
           delete_dsn = T)
  st_write(Confluences_NSD,
           "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/04_DOCS/SUBMISSION/DATASETS_FIGSHARE/Intakes_HydroRivers_Segments_With_Licence_Confluence.gpkg",
           delete_dsn = T)
  st_write(CanSwap_NSD,
           "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/04_DOCS/SUBMISSION/DATASETS_FIGSHARE/can-SWaP_AllLicences.gpkg",
           delete_dsn = T)
  st_write(CanSwap_NSD,
           "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/04_DOCS/SUBMISSION/DATASETS_FIGSHARE/can-SWaP_NoISCLicences.gpkg",
           delete_dsn = T)