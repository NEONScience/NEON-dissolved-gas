# LIBRARY-----
library(tidyverse)
library(readxl)


# LOAD FUNCTIONS FROM NEON-dissolved-gas PACKAGE------------
# NEON Function for calculating dissolved gas concentration
source("neonDissGas/R/def.calc.sdg.R")


# LOAD DATA---------------
# Load my own example data
jbData <- read_excel("testingAndDev/jbCalcs/Dissolved gas headspace equilibration June 2010 revision.xls",
                     sheet = "rExport", na = "NA")



# FLEXIBILITY OF ARGUMENT NAMES----------------
# this works if df names match function names
# If 0's are provided for source gases (i.e. concentrationCO2Air) because He/N2
# was used as headspace gas, the 100% saturation calculation breaks.  Probably 
# should split this calculation into an independent function as kcawley has
# previously suggested.
dissGasRes1 <- def.calc.sdg(jbData) 
select(dissGasRes1, dissolvedCO2, concentrationCO2Air) %>% print(n=100)

# what if df column names don't match names in function?
# it appears columns names must perfectly match those specified in function
jbDataRename <- rename(jbData, CO2InAir = concentrationCO2Air)
def.calc.sdg(jbDataRename)  # this breaks
def.calc.sdg(jbDataRename, sourceCO2 = CO2InAir) # this breaks. 
def.calc.sdg(jbDataRename, sourceCO2 = jbDataRename$CO2InAir) # even this breaks!


# what if column is missing from dataframe?
jbDataMissing <- select(jbData, -concentrationCO2Air)
# no problem, just point the argument to the correct data source.
def.calc.sdg(jbDataMissing) # this breaks
def.calc.sdg(jbDataMissing, sourceCO2 = jbData$concentrationCO2Air) # this breaks!




# COMPARE CALCULATION RESULTS-----------
# Neon function vs JB's Excel calcs
# Dissolved CO2
summarise(dissGasRes, # Excel calcs ~2% greater than Neon
          co2Bias = mean(dissolvedCO2.xl / dissolvedCO2, na.rm = TRUE))

ggplot(dissGasRes, aes(dissolvedCO2, dissolvedCO2.xl)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  ylab("Dissolved CO2 derived from JB Excel file (mol l-1)") +
  xlab("Dissolved CO2 derived from Neon function (mol l-1)") +
  ggtitle("Excel calcs ~2% higher than Neon")

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

