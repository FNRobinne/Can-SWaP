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
