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
library(ggplot2)
library(dplyr)
library(scales)
library(ggtext)

## Set working directory -------------------------------------------------------

setwd("C:/Users/frobinne/Documents/PROFESSIONAL/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/")

## Processing ------------------------------------------------------------------

canswap <- st_read("03_ANALYSIS_RESULTS/CAN-SWaP/Unnest_Basins/Municipal_Catchments_V1/Can_SWaP_AllLicences_V2_CleanAtt.gpkg")
  
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
  # COnversion and binning of area
  canswap <- canswap %>%
    mutate(AREA_l10 = log10(AREA)) %>% # Conversion to log scale
    mutate(BINS_CUT = cut(AREA_l10, # Cut in 7 quantiles
                          breaks = c(6,7,8,9,10,11,12,13),
                          include.lowest = F,
                          right = F))
  
  # Forest cover
  bxp_for <- ggboxplot(canswap, x = "BINS_CUT", y = "FOR_PC_USE",
                       color = "forestgreen", fill = "yellowgreen", add = "jitter",
                       add.params = list(size = 0.5, jitter = 0.3),
                       size = 0.7, width = 0.8) +
    theme_grey() +
    ggtitle("Forest cover (%)") +
    theme(axis.line = element_line(linewidth = 1, colour = "gray30"),
          panel.border = element_rect(color = "gray30", fill = NA, linewidth = 1),
          plot.title = element_text(hjust = 0.5, size = 14, face = "bold", color = "gray30"),
          axis.text.x = element_text(angle = 30, hjust = 0.5, vjust = 0.7)) +
    font("y.text", size = 9, face = "bold", color = "gray30") +
    font("x.text", size = 9, face = "bold", color = "gray30") +
    rremove("legend") +
    rremove("ylab") +
    rremove("xlab") +
    scale_x_discrete(labels=c(expression(bold(paste("10"^"6", "-10"^"7"))), 
                              expression(bold(paste("10"^"7", "-10"^"8"))),
                              expression(bold(paste("10"^"8", "-10"^"9"))),
                              expression(bold(paste("10"^"9", "-10"^"10"))),
                              expression(bold(paste("10"^"10", "-10"^"11"))),
                              expression(bold(paste("10"^"11", "-10"^"12"))),
                              expression(bold(paste("10"^"12", "-10"^"13")))))
      
  #bxp_for # Call to visualize the plot if need be

  # Wetland
  bxp_wet <- ggboxplot(canswap, x = "BINS_CUT", y = "WET_PC_UG2",
                       color = "darkcyan", fill = "cyan3", add = "jitter",
                       add.params = list(size = 0.5, jitter = 0.3),
                       size = 0.7, width = 0.8) +
    theme_grey() +
    ggtitle("Wetland cover (%)") +
    theme(axis.line = element_line(linewidth = 1, colour = "gray30"),
          panel.border = element_rect(color = "gray30", fill = NA, linewidth = 1),
          plot.title = element_text(hjust = 0.5, size = 14, face = "bold", color = "gray30"),
          axis.text.x = element_text(angle = 30, hjust = 0.5, vjust = 0.7)) +
    font("xy.text", size = 9, face = "bold", color = "gray30") +
    font("xylab", size = 9, face = "bold", color = "gray30") +
    rremove("legend") +
    rremove("ylab") +
    rremove("xlab") +
    scale_x_discrete(labels=c(expression(bold(paste("10"^"6", "-10"^"7"))), 
                              expression(bold(paste("10"^"7", "-10"^"8"))),
                              expression(bold(paste("10"^"8", "-10"^"9"))),
                              expression(bold(paste("10"^"9", "-10"^"10"))),
                              expression(bold(paste("10"^"10", "-10"^"11"))),
                              expression(bold(paste("10"^"11", "-10"^"12"))),
                              expression(bold(paste("10"^"12", "-10"^"13")))))
  
  bxp_wet_2 <- ggpar(bxp_wet, ylim = c(0,100)) # Adjust the y axis to be 0-100
  #bxp_wet_2 # Call to visualize the plot if need be
  
  # Protected area
  bxp_pac <- ggboxplot(canswap, x = "BINS_CUT", y = "PAC_PC_USE",
                       color = "gold4", fill = "gold", add = "jitter",
                       add.params = list(size = 0.5, jitter = 0.3),
                       size = 0.7, width = 0.8) +
    theme_grey() +
    ggtitle("Protected area (%)") +
    theme(axis.line = element_line(linewidth = 1, colour = "gray30"),
          panel.border = element_rect(color = "gray30", fill = NA, linewidth = 1),
          plot.title = element_text(hjust = 0.5, size = 14, face = "bold", color = "gray30"),
          axis.text.x = element_text(angle = 30, hjust = 0.5, vjust = 0.7)) +
    font("xy.text", size = 9, face = "bold", color = "gray30") +
    font("xylab", size = 9, face = "bold", color = "gray30") +
    rremove("legend") +
    rremove("ylab")+
    rremove("xlab") +
    scale_x_discrete(labels=c(expression(bold(paste("10"^"6", "-10"^"7"))), 
                              expression(bold(paste("10"^"7", "-10"^"8"))),
                              expression(bold(paste("10"^"8", "-10"^"9"))),
                              expression(bold(paste("10"^"9", "-10"^"10"))),
                              expression(bold(paste("10"^"10", "-10"^"11"))),
                              expression(bold(paste("10"^"11", "-10"^"12"))),
                              expression(bold(paste("10"^"12", "-10"^"13")))))
  
  #bxp_pac # Call to visualize the plot if need be
  
  # Human footprint
  bxp_hft <- ggboxplot(canswap, x = "BINS_CUT", y = "HFT_IX_U09",
                       color = "chocolate4", fill = "chocolate", add = "jitter",
                       add.params = list(size = 0.5, jitter = 0.3),
                       size = 0.7, width = 0.8) +
    theme_grey() +
    ggtitle("Human Footprint Index (unitless)") +
    theme(axis.line = element_line(linewidth = 1, colour = "gray30"),
          panel.border = element_rect(color = "gray30", fill = NA, linewidth = 1),
          plot.title = element_text(hjust = 0.5, size = 14, face = "bold", color = "gray30"),
          axis.text.x = element_text(angle = 30, hjust = 0.5, vjust = 0.7)) +
    font("xy.text", size = 9, face = "bold", color = "gray30") +
    font("xylab", size = 9, face = "bold", color = "gray30") +
    rremove("legend") +
    rremove("ylab")+
    rremove("xlab") +
    scale_x_discrete(labels=c(expression(bold(paste("10"^"6", "-10"^"7"))), 
                              expression(bold(paste("10"^"7", "-10"^"8"))),
                              expression(bold(paste("10"^"8", "-10"^"9"))),
                              expression(bold(paste("10"^"9", "-10"^"10"))),
                              expression(bold(paste("10"^"10", "-10"^"11"))),
                              expression(bold(paste("10"^"11", "-10"^"12"))),
                              expression(bold(paste("10"^"12", "-10"^"13")))))
  
  bxp_hft # Call to visualize the plot if need be
  
  # Arrange plots and export to png 
  # Figure 3
  png(file = "C:/Users/frobinne/Documents/PROFESSIONAL/PROJECTS/39_2021_CANADA_F2F_SOURCE2TAP_ACTIVE/04_DOCS/Fig3_Boxplots.png",
      units = 'cm', width = 19, height = 15, res = 350)
  ggarrange(bxp_for, bxp_wet_2, bxp_pac, bxp_hft)
  dev.off()
