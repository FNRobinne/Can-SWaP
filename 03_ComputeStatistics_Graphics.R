## ---------------------------
##
## Script name: 03_ComputeStatistics_Graphics.R
##
## Purpose: Generate important statistics based on source catchment attributes
##          and create graphics for publication
##
## Author: Dr. François-Nicolas Robinne, Canadian Forest Service
##
## Date Created: 2023-02-28
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
## ---------------------------

## General options -------------------------------------------------------------

options(scipen = 6, digits = 4) # non-scientific notation

## Load libraries --------------------------------------------------------------

library(sf)
library(tidyverse)
library(ggpubr)

## Set working directory -------------------------------------------------------

setwd("C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/02_PROCESSED_DATA")

## Processing ------------------------------------------------------------------

canswap <- st_read("NRCAN/Unnest_Basins/Municipal_Catchments_V1/Can_SWaP_AllLicences_V2_CleanAtt.gpkg")
  
  # Area statistics
  print(median(canswap$AREA * 0.000001)) #In square kilometers
  print(range(canswap$AREA * 0.000001)) #In square kilometers
  
  # Forest statistics (%)
  print(median(canswap$FOR_PC_USE))
  print(mean(canswap$FOR_PC_USE))
  
  # Wetland statistics (%)
  print(mean(canswap$WET_PC_UG2))
  cnt_wet <- canswap %>%
    filter(WET_PC_UG2 > 0)
  print(nrow(cnt_wet))
  
  # Protected area statistics (%)
  print(mean(canswap$PAC_PC_USE))
  cnt_pac <- canswap %>%
    filter(PAC_PC_USE > 0)
  print(nrow(cnt_pac))
  
  # Human footprint statistics (Unitless => 0-100 index)
  print(mean(canswap$HFT_IX_U09))
  print(range(canswap$HFT_IX_U09))
  
  # Boxplots
  # Forest cover
  bxp_for <- ggboxplot(canswap, x = "ORD_STRA", y = "FOR_PC_USE",
                       color = "forestgreen", fill = "yellowgreen", add = "jitter",
                       add.params = list(size = 0.5, jitter = 0.3),
                       xlab = "Strahler order",
                       size = 0.7, width = 0.8) +
    theme_grey() +
    ggtitle("Forest cover (%)") +
    theme(axis.line = element_line(linewidth = 1, colour = "gray30"),
          panel.border = element_rect(color = "gray30", fill = NA, linewidth = 1),
          plot.title = element_text(hjust = 0.5, size = 14, face = "bold", color = "gray30")) +
    font("xy.text", size = 12, face = "bold", color = "gray30") +
    font("xylab", size = 12, face = "bold", color = "gray30") +
    rremove("legend") +
    rremove("ylab")
      
  #bxp_for # Call to visualize the plot if need be
  
  # Wetland
  bxp_wet <- ggboxplot(canswap, x = "ORD_STRA", y = "WET_PC_UG2",
                       color = "darkcyan", fill = "cyan3", add = "jitter",
                       add.params = list(size = 0.5, jitter = 0.3),
                       xlab = "Strahler order",
                       size = 0.7, width = 0.8) +
    theme_grey() +
    ggtitle("Wetland cover (%)") +
    theme(axis.line = element_line(linewidth = 1, colour = "gray30"),
          panel.border = element_rect(color = "gray30", fill = NA, linewidth = 1),
          plot.title = element_text(hjust = 0.5, size = 14, face = "bold", color = "gray30")) +
    font("xy.text", size = 12, face = "bold", color = "gray30") +
    font("xylab", size = 12, face = "bold", color = "gray30") +
    rremove("legend") +
    rremove("ylab")
  
  bxp_wet_2 <- ggpar(bxp_wet, ylim = c(0,100)) # Adjust the y axis to be 0-100
  
  #bxp_wet_2 # Call to visualize the plot if need be
  
  # Protected area
  bxp_pac <- ggboxplot(canswap, x = "ORD_STRA", y = "PAC_PC_USE",
                       color = "gold4", fill = "gold", add = "jitter",
                       add.params = list(size = 0.5, jitter = 0.3),
                       xlab = "Strahler order",
                       size = 0.7, width = 0.8) +
    theme_grey() +
    ggtitle("Protected area (%)") +
    theme(axis.line = element_line(linewidth = 1, colour = "gray30"),
          panel.border = element_rect(color = "gray30", fill = NA, linewidth = 1),
          plot.title = element_text(hjust = 0.5, size = 14, face = "bold", color = "gray30")) +
    font("xy.text", size = 12, face = "bold", color = "gray30") +
    font("xylab", size = 12, face = "bold", color = "gray30") +
    rremove("legend") +
    rremove("ylab")
  
  #bxp_pac # Call to visualize the plot if need be
  
  # Human footprint
  bxp_hft <- ggboxplot(canswap, x = "ORD_STRA", y = "HFT_IX_U09",
                       color = "chocolate4", fill = "chocolate", add = "jitter",
                       add.params = list(size = 0.5, jitter = 0.3),
                       xlab = "Strahler order",
                       size = 0.7, width = 0.8) +
    theme_grey() +
    ggtitle("Human Footprint Index (unitless)") +
    theme(axis.line = element_line(linewidth = 1, colour = "gray30"),
          panel.border = element_rect(color = "gray30", fill = NA, linewidth = 1),
          plot.title = element_text(hjust = 0.5, size = 14, face = "bold", color = "gray30")) +
    font("xy.text", size = 12, face = "bold", color = "gray30") +
    font("xylab", size = 12, face = "bold", color = "gray30") +
    rremove("legend") +
    rremove("ylab")
  
  #bxp_hft # Call to visualize the plot if need be
  
  # Arrange plots and export to png 
  # Figure 3
  png(file = "C:/Users/frobinne/Documents/Professional/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/04_DOCS/Fig3_Boxplots.png",
      width = 600, height = 450)
  ggarrange(bxp_for, bxp_wet_2, bxp_pac, bxp_hft)
  dev.off()
