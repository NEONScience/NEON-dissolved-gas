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


# DISSOLVED GAS CALCULATIONS----------------
# Calculate dg- NEON
dissGasRes <- def.calc.sdg(dissGasData) # neon dg calcs
str(dissGasRes) # as expected



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
