## ---------------------------
##
## Script name: 02_UpdatedAttributesMunicipalCatchments.R
##
## Purpose: Update Can-SWaP catchment attributes based on water licence data and
##          RiverATLAS
##
## Author: Dr. François-Nicolas Robinne, Canadian Forest Service
##
## Date Created: 2023-02-21
##
## Email: francois.robinne@nrcan-rncan.gc.ca
##
## ---------------------------
##
## Notes: 
##
##   We strongly recommend reading the data descriptor for best use of the data
##    and reuse of this script.
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

                      #################################
                      ########## All basins ###########
                      #################################
  
  # Load data
  can_catch <- st_read("NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can-SWaP_AllLicences_V0.gpkg")
  catch_att <- read_csv("HYDROLAB_MCGILL/Pourpoints_RiverAtlas_Segments_With_Licence_V3.csv")
  
  # Update attributes
  catch_att_volyr <- catch_att %>%
    mutate(TOT_DIS_M3 = dis_m3_pyr * 31540000) %>%
    select(-c(dis_m3_pyr, vertex_index, vertex_pos, vertex_part, vertex_part_index,
           distance, angle)) %>%
    rename(WET_PC_UG2 = wet_pc_ug2,
           FOR_PC_USE = for_pc_use,
           PAC_PC_USE = pac_pc_use,
           HFT_IX_U09 = hft_ix_u09,
           ALL_VOL_M3 = YR_VOL_M3_sum)
  
  # Join attributes to catchment layer
  can_swap <- inner_join(can_catch, catch_att_volyr, join_by(VALUE == fid))
  
  # Reproject output
  can_swap_3979 <- st_transform(can_swap, crs = 3979)
  can_swap_3979$AREA <- st_area(can_swap_3979)
  
  # Write output
  st_write(can_swap_3979, 
           "NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can_SWaP_AllLicences_V1.gpkg",
           delete_dsn = T)
