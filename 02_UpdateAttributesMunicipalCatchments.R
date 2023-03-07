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
##    Beware of file names when running the script with data from the FigShare repo 
##    
##    We strongly recommend reading the data descriptor for best use of the data
##    and reuse of this script.
##
## ---------------------------

## General options -------------------------------------------------------------

options(scipen = 6, digits = 4) # non-scientific notation

## Load libraries --------------------------------------------------------------

library(sf)
library(tidyverse)
library(qgisprocess)

## Set working directory -------------------------------------------------------

setwd("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA")

## Processing ------------------------------------------------------------------

                      #################################
                      ########## All basins ###########
                      #################################
  
  # Create attribute tables with QGis fid for attribute join
  qgis_run_algorithm("native:savefeatures",
                   INPUT = "HYDROLAB_MCGILL/Intakes_RiverAtlas_Segments_With_Licence_V5.gpkg",
                   OUTPUT = "HYDROLAB_MCGILL/Intakes_RiverAtlas_Segments_With_Licence_V5.csv")  
  
  # Load data
  can_catch <- st_read("NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can-SWaP_AllLicences_V2.gpkg")
  catch_att <- read_csv("HYDROLAB_MCGILL/Intakes_RiverAtlas_Segments_With_Licence_V5.csv")
  intakes <- st_read("HYDROLAB_MCGILL/Intakes_RiverAtlas_Segments_With_Licence_V5.gpkg")
  
  # Update attributes
  catch_att_volyr <- catch_att %>%
    mutate(DIS_M3_TYR = dis_m3_pyr * 31540000) %>%
    select(-c(dis_m3_pyr, vertex_index, vertex_pos, vertex_part, vertex_part_index,
           distance, angle)) %>%
    rename(WET_PC_UG2 = wet_pc_ug2,
           FOR_PC_USE = for_pc_use,
           PAC_PC_USE = pac_pc_use,
           HFT_IX_U09 = hft_ix_u09,
           INT_M3_YR = YR_VOL_M3_sum,
           JUR_NAME = PRENAME)
  
  # Join attributes to catchment layer
  can_swap <- inner_join(can_catch, catch_att_volyr, join_by(VALUE == fid))
  
  # Identify confluences
  conf <- right_join(can_catch, catch_att_volyr, join_by(VALUE == fid)) %>%
    add_count(geom) %>%
    filter(n > 1) %>%
    st_drop_geometry()
  conf_points <- right_join(intakes, conf, by = c("HYRIV_ID" = "HYRIV_ID", "YR_VOL_M3_sum" = "INT_M3_YR")) %>%
    select(HYRIV_ID, LENGTH_KM.x, ORD_STRA.x, YR_VOL_M3_sum, PRENAME)
  
  # Reproject output
  # WGS84 to Lambert Canada
  can_swap_3979 <- st_transform(can_swap, crs = 3979)
  can_swap_3979$AREA <- st_area(can_swap_3979)
  
  # Write output
  st_write(can_swap_3979, 
           "NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can_SWaP_AllLicences_V2_CleanAtt.gpkg",
           delete_dsn = T)
  st_write(conf_points,
           "HYDROLAB_MCGILL/Intakes_RiverAtlas_Segments_With_Licence_Confluence_V1.gpkg")

  
                  ############################################
                  ########## No ISC licence basins ###########
                  ############################################
 
  # Create attribute tables with QGis fid for attribute join 
  qgis_run_algorithm("native:savefeatures",
                     INPUT = "HYDROLAB_MCGILL/Intakes_RiverAtlas_Segments_With_Licence_V5_NoISC.gpkg",
                     OUTPUT = "HYDROLAB_MCGILL/Intakes_RiverAtlas_Segments_With_Licence_V5_NoISC.csv")  
  
  # Load data
  can_catch_ISC <- st_read("NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can-SWaP_AllLicences_V2_NoISC.gpkg")
  catch_att_ISC <- read_csv("HYDROLAB_MCGILL/Intakes_RiverAtlas_Segments_With_Licence_V5_NoISC.csv")
  
  # Update attributes
  catch_att_ISC_volyr <- catch_att_ISC %>%
    mutate(DIS_M3_TYR = dis_m3_pyr * 31540000) %>%
    select(-c(dis_m3_pyr, vertex_index, vertex_pos, vertex_part, vertex_part_index,
              distance, angle)) %>%
    rename(WET_PC_UG2 = wet_pc_ug2,
           FOR_PC_USE = for_pc_use,
           PAC_PC_USE = pac_pc_use,
           HFT_IX_U09 = hft_ix_u09,
           INT_M3_YR = YR_VOL_M3_sum,
           JUR_NAME = PRENAME)
  
  # Join attributes to catchment layer
  can_swap_ISC <- inner_join(can_catch_ISC, catch_att_ISC_volyr, join_by(VALUE == fid))
  
  # Reproject output
  can_swap_ISC_3979 <- st_transform(can_swap_ISC, crs = 3979)
  can_swap_ISC_3979$AREA <- st_area(can_swap_ISC_3979)
  
  # Write output
  st_write(can_swap_ISC_3979, 
           "NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can_SWaP_NoISCLicences_V2_CleanAtt.gpkg",
           delete_dsn = T)