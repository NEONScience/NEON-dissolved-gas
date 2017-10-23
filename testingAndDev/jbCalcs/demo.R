# LIBRARY-----
library(tidyverse)
library(readxl)


# LOAD FUNCTIONS FROM NEON-dissolved-gas PACKAGE------------
# NEON Function for calculating dissolved gas concentration
source("neonDissGas/R/def.calc.sdg.R")


# LOAD DATA---------------
# Load example data directly from package
load("neonDissGas/data/sdgFormatted.Rda")

# Add data for expanded function 
# Define headspace equilibration temperature
sdgFormatted$headspaceTemp <- sdgFormatted$waterTemp + 3 

# Define concentration in headspace source gas
# In neon data 'Air' is headspace source gas
sdgFormatted$concentrationCO2Source <- sdgFormatted$concentrationCO2Air
sdgFormatted$concentrationCH4Source <- sdgFormatted$concentrationCH4Air
sdgFormatted$concentrationN2OSource <- sdgFormatted$concentrationN2OAir

# Define concentration in air
sdgFormatted$concentrationCO2Air <- 405 # global average
sdgFormatted$concentrationCH4Air <- 1.85 # global average
sdgFormatted$concentrationN2OAir <- 0.330 # global average

# I separately calculated the dg concentration using an Excel spreadsheet
# built in 2010.  Load results for comparison here.
xlData <- read_excel("testingAndDev/jbCalcs/Dissolved gas headspace equilibration June 2010 revision.xls",
                      sheet = "rExport", na = "NA")

# Merge data
dissGasData <- cbind(sdgFormatted, xlData)


# FLEXIBILITY OF ARGUMENT NAMES----------------
# this works if df names match function names
dissGasRes1 <- def.calc.sdg(dissGasData) 


# what if df column names don't match names in function?
# no problem, just point the argument to the correct data source.
def.calc.sdg(dissGasData, sourceCO2 = dissGasData$concentrationCO2Air) # does work
foo <- dissGasData
def.calc.sdg(dissGasData, sourceCO2 = foo$concentrationCO2Air) # also works
# can also just be a vector (not df)
foo <- dissGasData$concentrationCO2Air
def.calc.sdg(dissGasData, sourceCO2 = foo) # also works


# MISSING SOURCE GAS DATA----------------------------
# commonly He/N2 may be used as headspace gas.  In such cases, the
# investigator may assume the source gas contains no CO2, CH4, or N2O
# and not provide source gas data in data frame.
# Can we specify values source gas data directly in function call?
dissGasData2 <- select(dissGasData, -concentrationCO2Source) # remove source CO2 data
dissGasRes2 <- def.calc.sdg(dissGasData2) # breaks, missing co2 source
dissGasRes2 <- def.calc.sdg(dissGasData2, sourceCO2 = 0) # this works
dissGasRes2$dissolvedCO2 # Have CO2 results, good



# MISSING AIR DATA----------------------------
# Air concentrations are used for saturation calculations.
# If air concentrations are provided, but include NAs,
# function replaces with global average
dissGasRes1$satCO2 # values for most rows
dissGasData2 <- dissGasData
dissGasData2$concentrationCO2Air[2] <- NA # add NA to row 2
dissGasRes4 <- def.calc.sdg(dissGasData2) 
dissGasRes4$satCO2 # still get value for row 2.  NA replaced w/global mean

# In many instances no air samples were analyzed.  Air data can be provided
# as NAs in dataframe, in which case they will be replaced with global mean,
# as specified in function.  OR the data can be omitted from df and specified in
# function call.
dissGasData3 <- select(dissGasData, -concentrationCO2Air)
dissGasRes5 <- def.calc.sdg(dissGasData3) # this breaks, no air CO2
dissGasRes5 <- def.calc.sdg(dissGasData3, airCO2 = 405) # this works
dissGasRes5$satCO2 # looks good!

# You can't specify air = NA in function
# Code runs, but reports NA for sat values
dissGasRes3 <- def.calc.sdg(select(dissGasData, -concentrationCO2Air, 
                                   -concentrationCH4Air,
                                   -concentrationN2OAir),
                            airCO2 = NA, airCH4 = NA, airN2O = NA) 

# what if air is supplied as NA in df?  Should default to global average.
# Define concentration in air
dissGasData3 <- dissGasData
dissGasData3$concentrationCO2Air <- NA # global average
dissGasData3$concentrationCH4Air <- NA # global average
dissGasData3$concentrationN2OAir <- NA # global average

dissGasRes6 <- def.calc.sdg(dissGasData3) 
dissGasRes6$satCH4  # yes, this worked.

# MISSING HEADSPACE EQUILIBATION TEMPERATURE
# Water body temperature is routinely measured, but the temp of the headspace
# equilibration may not be.  If the headspace temp is provided, but contains
# NAs, the NAs will be replaced with the water body temperature.
# If the headspace temp wasn't measured at all, a column of NAs can be provided
# in the df.  Again, the water body temp will be used.  Alternatively, you can
# specify headspaceTemp = water body temperature in the function call, then 
# you don't need the empty column.



# COMPARE CALCULATION RESULTS-----------
# Neon function vs JB's Excel calcs
# Dissolved CO2
summarise(dissGasRes, # Excel calcs ~7% greater than Neon
          co2Bias = mean(dissolvedCO2.xl / dissolvedCO2, na.rm = TRUE))

ggplot(dissGasRes, aes(dissolvedCO2, dissolvedCO2.xl)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  ylab("Dissolved CO2 derived from JB Excel file (mol l-1)") +
  xlab("Dissolved CO2 derived from Neon function (mol l-1)") +
  ggtitle("Excel calcs ~7% higher than Neon")

# Saturated CO2
summarise(dissGasRes, # Excel calcs ~1% lower than Neon
          co2Bias = mean(satCO2.xl / satCO2, na.rm = TRUE))

ggplot(dissGasRes, aes(satCO2, satCO2.xl)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  ylab("Sat CO2 derived from JB Excel file (mol l-1)") +
  xlab("Sat CO2 derived from Neon function (mol l-1)")

# Dissolved CH4
summarise(dissGasRes, # Excel calcs ~10% greater than Neon
          CH4Bias = mean(dissolvedCH4.xl / dissolvedCH4, na.rm = TRUE))

ggplot(dissGasRes, aes(dissolvedCH4, dissolvedCH4.xl)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  ylab("Dissolved CH4 derived from JB Excel file (mol l-1)") +
  xlab("Dissolved CH4 derived from Neon function (mol l-1)")

# Saturated CH4
summarise(dissGasRes, # Excel calcs ~8% lower than Neon
          CH4Bias = mean(satCH4.xl / satCH4, na.rm = TRUE))

ggplot(dissGasRes, aes(satCH4, satCH4.xl)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  ylab("Sat CH4 derived from JB Excel file (mol l-1)") +
  xlab("Sat CH4 derived from Neon function (mol l-1)")

# TEST IF HEADSPACE TEMP IS NOT PROVIDED-------------------------
sdgFormatted$headspaceTemp <- NA
dissGasRes <- def.calc.sdg(dissGasData) # neon dg calcs
str(dissGasRes) # as expected

# Good, defaults to water body temp if headspace temp not provided.
ggplot(dissGasRes, aes(dissolvedCO2, dissolvedCO2.xl)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  ylab("Dissolved CO2 derived from JB Excel file (mol l-1)") +
  xlab("Dissolved CO2 derived from Neon function (mol l-1)")
