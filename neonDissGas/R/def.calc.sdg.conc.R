##############################################################################################
#' @title Dissolved Gas Concentration Calculations

#' @author 
#' Kaelin M. Cawley \email{kcawley@battelleecology.org} \cr

#' @description This function calculates dissolved CO2, CH4, and N2O concentrations from 
#' water samples based on inputs of equilibration conditions and reference and equilibrated 
#' air CO2, CH4, and N2O concentrations. If samples were equilibrated with a pure gas that 
#' contains no CO2, CH4, or N2O, the concentrations for the reference air 
#' ("concentrationCO2Air", "concentrationCH4Air", "concentrationN2OAir") for those gases 
#' should be set to 0.

#' @param inputFile Name of the data frame containing the information needed to calculate the 
#' dissolved gas concentrations. If the headers are named: "gasVolume", "waterVolume", 
#' "barometricPressure", "waterTemp", "concentrationCO2Gas", "concentrationCO2Air", 
#' "concentrationCH4Gas", "concentrationCH4Air", "concentrationN2OGas", "concentrationN2OAir", 
#' respectively, no other inputs are required. Otherwise, the names of the columns containing 
#' the data must be specified.
#' @param volGas Column name containing the data for volume of air equilibrated with 
#' water (mL) [string]
#' @param volH2O Column name containing the data for volume of water equilibrated with 
#' air (mL) [string]
#' @param baro Column name containing the data for barometric pressure at the time of 
#' equilibration (kPa) [string]
#' @param waterTemp Column name containing the data for temperature of the waterbody when 
#' sampled (celsius) [string]
#' @param headspaceTemp Column name containing the data for temperature of the water sample 
#' during the headspace equilibration (celsius) [string]
#' @param eqCO2 Column name containing the data for concentration of carbon dioxide in the 
#' equilibrated gas (ppmv) [string]
#' @param sourceCO2 Column name containing the data for concentration of carbon dioxide in 
#' headspace source gas (ppmv) [string]
#' @param eqCH4 Column name containing the data for concentration of methane in the 
#' equilibrated gas (ppmv) [string]
#' @param sourceCH4 Column name containing the data for concentration methane in headspace 
#' source gas (ppmv) [string]
#' @param eqN2O Column name containing the data for concentration of nitrous oxide in the 
#' equilibrated gas (ppmv) [string]
#' @param sourceN2O Column name containing the data for concentration of nitrous oxide in 
#' headspace source gas (ppmv) [string]

#' @return This function returns dissolved CO2, CH4, and N2O concentrations in surface water 
#' [M] based on headspace equilibration data. Function also returns dissolved 100% saturation 
#' concentrations  [M] of CO2, CH4, and N2O in surface waters. Outputs are appended as 
#' additional columns to the input data frame

#' @references
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

#' @keywords dissolved gases, methane, CH4, carbon dioxide, CO2, nitrous oxide, N2O, 
#' surface water, aquatic, streams, lakes, rivers

#' @examples
#' #where the data frame "sdgFormatted" is already read in
#' #sdgDataPlusVals <- def.calc.sdg.conc(inputFile = sdgFormatted)
#' #where the data is read in from a file in the working directory (also works with a full path)
#' #sdgDataPlusVals <- def.calc.sdg.conc(inputFile = 
#' #system.file("extdata", "sdgTestData.csv", package = "neonDissGas"))

#' @seealso def.format.sdg.R for formatting dissolved gas data downloaded from NEON

#' @export

# changelog and author contributions / copyrights
#   Kaelin M. Cawley (2017-02-14)
#     original creation
#   Kaelin M. Cawley (2017-09-14)
#     updated with step-by-step calculations in communication with Jake Beaulieu
#   Kaelin M. Cawley & Jake Beaulieu (2017-09-28)
#     updated with percent saturation calculation
#   Kaelin M. Cawley (2018-04-23)
#     updated with string values for column names so that users can specify dataframe columns
#     removed saturation to be its own function and renamed this one as the calc function
##############################################################################################
def.calc.sdg.conc <- function(
  inputFile,
  volGas = "gasVolume",
  volH2O = "waterVolume",
  baro = "barometricPressure",
  waterTemp = "waterTemp",
  headspaceTemp = "headspaceTemp",
  eqCO2 = "concentrationCO2Gas",
  sourceCO2 = "concentrationCO2Air",
  eqCH4 = "concentrationCH4Gas",
  sourceCH4 = "concentrationCH4Air",
  eqN2O = "concentrationN2OGas",
  sourceN2O = "concentrationN2OAir"
) {
  
  if(typeof(inputFile) == "character"){
    inputFile <- read.csv(inputFile)
  }
  
  ##### Constants #####
  cGas<-8.3144598 #universal gas constant (J K-1 mol-1)
  cKelvin <- 273.15 #Conversion factor from Kelvin to Celsius
  cPresConv <- 0.000001 # Constant to convert mixing ratio from umol/mol (ppmv) to mol/mol. Unit conversions from kPa to Pa, m^3 to L, cancel out.
  cT0 <- 298.15#Henry's law constant T0
  #Henry's law constants and temperature dependence from Sander (2015) DOI: 10.5194/acp-15-4399-2015
  ckHCO2 <- 0.00033 #mol m-3 Pa, range: 0.00031 - 0.00045
  ckHCH4 <- 0.000014 #mol m-3 Pa, range: 0.0000096 - 0.000092
  ckHN2O <- 0.00024 #mol m-3 Pa, range: 0.00018 - 0.00025
  cdHdTCO2 <- 2400 #K, range: 2300 - 2600
  cdHdTCH4 <- 1900 #K, range: 1400-2400
  cdHdTN2O <- 2700 #K, range: 2600 - 3600
  
  ##### Populate mean global values for reference air where it isn't reported #####
  inputFile[,sourceCO2] = ifelse(is.na(inputFile[,sourceCO2]),# if reported as NA
                                 405, # use global mean https://www.esrl.noaa.gov/gmd/ccgg/trends/global.html
                                 inputFile[,sourceCO2])
  
  inputFile[,sourceCH4] = ifelse(is.na(inputFile[,sourceCH4]), # use global average if not measured
                                 1.85, #https://www.esrl.noaa.gov/gmd/ccgg/trends_ch4/
                                 inputFile[,sourceCH4])
  
  inputFile[,sourceN2O] = ifelse(is.na(inputFile[,sourceN2O]), # use global average if not measured
                                 0.330, #https://www.esrl.noaa.gov/gmd/hats/combined/N2O.html
                                 inputFile[,sourceN2O])
  
  ##### Calculate dissolved gas concentration in original water sample #####
  inputFile$dissolvedCO2 <- NA
  inputFile$dissolvedCO2 <- inputFile[,baro] * cPresConv * 
    (inputFile[,volGas]*(inputFile[,eqCO2] - inputFile[,sourceCO2])/(cGas * (inputFile[,headspaceTemp] + cKelvin) * inputFile[,volH2O]) + 
       ckHCO2 * exp(cdHdTCO2*(1/(inputFile[,headspaceTemp] + cKelvin) - 1/cT0))* inputFile[,eqCO2])
  
  inputFile$dissolvedCH4 <- NA
  inputFile$dissolvedCH4 <- inputFile[,baro] * cPresConv * 
    (inputFile[,volGas]*(inputFile[,eqCH4] - inputFile[,sourceCH4])/(cGas * (inputFile[,headspaceTemp] + cKelvin) * inputFile[,volH2O]) + 
       ckHCH4 * exp(cdHdTCH4*(1/(inputFile[,headspaceTemp] + cKelvin) - 1/cT0))* inputFile[,eqCH4])
  
  inputFile$dissolvedN2O <- NA
  inputFile$dissolvedN2O <- inputFile[,baro] * cPresConv * 
    (inputFile[,volGas]*(inputFile[,eqN2O] - inputFile[,sourceN2O])/(cGas * (inputFile[,headspaceTemp] + cKelvin) * inputFile[,volH2O]) + 
       ckHN2O * exp(cdHdTN2O*(1/(inputFile[,headspaceTemp] + cKelvin) - 1/cT0))* inputFile[,eqN2O])
  
  ##### Step-by-step Calculation of dissolved gas concentrations for testing #####
  
  # Dissolved gas concentration in the original water samples (dissolvedGas) is
  # calculated from a mass balance of the measured headspace concentration (eqGas), the 
  # calculated concentration in the equilibrated headspace water (eqHeadspaceWaterCO2), 
  # and the volumes of the headspace water and headspace gas, following:
  
  # dissolvedGas  = ((eqGas * volGas) + (eqHeadspaceWaterGas * volH2O) - (sourceGas * volGas)) / volH2O
  
  # Measured headspace concentration should be expressed as mol L- for the mass
  # balance calculation and as partial pressure for the equilibrium calculation.
  
  # #Temperature corrected Henry's Law Constant
  # HCO2 <- ckHCO2 * exp(cdHdTCO2 * ((1/(headspaceTemp+cKelvin)) - (1/cT0)))
  # HCH4 <- ckHCH4 * exp(cdHdTCH4 * ((1/(headspaceTemp+cKelvin)) - (1/cT0)))
  # HN2O <- ckHN2O * exp(cdHdTN2O * ((1/(headspaceTemp+cKelvin)) - (1/cT0)))
  # 
  # #Mol of gas in equilibrated water (using Henry's law)
  # CO2eqWat <- HCO2 * eqCO2 * cPresConv * baro * (volH2O/1000)
  # CH4eqWat <- HCH4 * eqCH4 * cPresConv * baro * (volH2O/1000)
  # N2OeqWat <- HN2O * eqN2O * cPresConv * baro * (volH2O/1000)
  # 
  # #Mol of gas in equilibrated air (using ideal gas law)
  # CO2eqAir <- (eqCO2 * cPresConv * baro * (volGas/1000))/(cGas * (headspaceTemp + cKelvin))
  # CH4eqAir <- (eqCH4 * cPresConv * baro * (volGas/1000))/(cGas * (headspaceTemp + cKelvin))
  # N2OeqAir <- (eqN2O * cPresConv * baro * (volGas/1000))/(cGas * (headspaceTemp + cKelvin))
  # 
  # #Mol of gas in source gas (using ideal gas law)
  # CO2air <- (inputFile[,sourceCO2] * cPresConv * baro * (volGas/1000))/(cGas * (headspaceTemp + cKelvin))
  # CH4air <- (inputFile[,sourceCH4] * cPresConv * baro * (volGas/1000))/(cGas * (headspaceTemp + cKelvin))
  # N2Oair <- (inputFile[,sourceN2O] * cPresConv * baro * (volGas/1000))/(cGas * (headspaceTemp + cKelvin))
  # 
  # #Total mol of gas is sum of equilibrated water and equilibrated air
  # CO2tot <- CO2eqWat + CO2eqAir
  # CH4tot <- CH4eqWat + CH4eqAir
  # N2Otot <- N2OeqWat + N2OeqAir
  # 
  # #Total mol of gas minus reference air mol gas to get water mol gas before equilibration
  # CO2wat <- CO2tot - CO2air
  # CH4wat <- CH4tot - CH4air
  # N2Owat <- N2Otot - N2Oair
  # 
  # #Concentration is mol of gas divided by volume of water
  # inputFile$dissolvedCO2 <- CO2wat/(volH2O/1000)
  # inputFile$dissolvedCH4 <- CH4wat/(volH2O/1000)
  # inputFile$dissolvedN2O <- N2Owat/(volH2O/1000)
  
  #Round to significant figures
  inputFile$dissolvedCO2 <- signif(inputFile$dissolvedCO2, digits = 3)
  inputFile$dissolvedCH4 <- signif(inputFile$dissolvedCH4, digits = 3)
  inputFile$dissolvedN2O <- signif(inputFile$dissolvedN2O, digits = 3)
  
  return(inputFile)
  
}

