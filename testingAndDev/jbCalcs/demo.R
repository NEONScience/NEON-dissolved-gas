# LIBRARY-----
library(tidyverse)
library(readxl)




# LOAD FUNCTIONS FROM NEON-dissolved-gas PACKAGE------------

# NEON Function for calculating dissolved gas concentration
source("neonDissGas/R/def.calc.sdg.R")

# Modified NEON function for calculating dissolved gas concentration
source("neonDissGas/jbCalcs/def.calc.sdg.jb.R")

# Function for loading and formatting data from NEON database
source("neonDissGas/R/def.format.sdg.R")



# LOAD DATA---------------
# This function calls a function from the 'neonDataStackR' package, which
# I don't have.  Function fails.
def.format.sdg(dataDir = paste0(getwd(),"/NEON_dissolved-gases-surfacewater.zip"))

if(file.exists('C:/Users/kcawley/Documents/GitHub/NEON-dissolved-gas')){
  setwd("C:/Users/kcawley/Documents/GitHub/NEON-dissolved-gas")
}


# Load example data directly from package
load("neonDissGas/data/sdgFormatted.Rda")



# DISSOLVED GAS CALCULATIONS----------------
# Calculate dg- NEON
sdgFormattedNeon <- def.calc.sdg(sdgFormatted) # neon dg calcs

# Calculate dg- Beaulieu function
sdgFormattedJb <- def.calc.sdg.jb(sdgFormatted) # neon dg calcs

# I separately calculated the dg concentration using an Excel spreadsheet
# built in 2010.  Load results for comparison here.
xlCalcs <- read_excel("neonDissGas/jbCalcs/Dissolved gas headspace equilibration June 2010 revision.xls",
                      sheet = "rExport", na = "NA")

# Merge data
dissCalcs <- cbind(sdgFormattedNeon, 
                   select(sdgFormattedJb, dissolvedCO2Jb),
                   xlCalcs)

# COMPARE CALCULATION RESULTS-----------
# Neon function vs JB's modified function
# Good correspondence
ggplot(dissCalcs, aes(dissolvedCO2, dissolvedCO2Jb)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  ylab("Dissolved CO2 derived from JB function (mol l-1)") +
  xlab("Dissolved CO2 derived from Neon function (mol l-1)")

# Neon function vs JB's Excel calcs
summarise(dissCalcs, # Excel calcs ~7% greater than Neon
          co2Bias = mean(dissolvedCO2.xl / dissolvedCO2, na.rm = TRUE))

ggplot(dissCalcs, aes(dissolvedCO2, dissolvedCO2.xl)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  ylab("Dissolved CO2 derived from JB Excel file (mol l-1)") +
  xlab("Dissolved CO2 derived from Neon function (mol l-1)") +
  ggtitle("Excel calcs ~7% higher than Neon")
