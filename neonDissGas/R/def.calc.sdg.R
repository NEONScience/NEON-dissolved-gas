##############################################################################################
#' @title Dissolved Gas Concentration Calculations

#' @author 
#' Kaelin M. Cawley \email{kcawley@battelleecology.org} \cr

#' @description This function calculates dissolved CO2, CH4, and N2O concentrations from water samples based on inputs of equilibration conditions and reference and equilibrated air CO2, CH4, and N2O concentrations. If samples were equilibrated with a pure gas that contains no CO2, CH4, or N2O, the concentrations for the reference air ("concentrationCO2Air", "concentrationCH4Air", "concentrationN2OAir") for those gases should be set to 0.

#' @param inputFile Name of the data fram containing the information needed to calculate the dissolved gas concentrations. If the headers are named: "gasVolume", "waterVolume", "barometricPressure", "waterTemp", "concentrationCO2Gas", "concentrationCO2Air", "concentrationCH4Gas", "concentrationCH4Air", "concentrationN2OGas", "concentrationN2OAir", respectively, no other inputs are required. Otherwise, the names of the columns need to be input for the function to work.
#' @param volGas Volume of air equilibrated with water [mL]
#' @param volH2O Volume of water equilibrated with air [mL]
#' @param baro Barometric pressure at the time of equilibration [kPa]
#' @param waterTemp Temperature of the waterbody when sampled [celsius]
#' @param headspaceTemp Temperature of the water sample during the headspace equilibration [celsius]
#' @param eqCO2 Concentration of carbon dioxide in the equilibrated gas [ppmv]
#' @param airCO2 Concentration of carbon dioxide in atmosphere [ppmv]
#' @param sourceCO2 Concentration of carbon dioxide in headspace source gas [ppmv]
#' @param eqCH4 Concentration of methane in the equilibrated gas [ppmv]
#' @param airCH4 Concentration of methane in atmosphere [ppmv]
#' @param sourceCH4 Concentration methane in headspace source gas [ppmv]
#' @param eqN2O Concentration of nitrous oxide in the equilibrated gas [ppmv]
#' @param airN2O Concentration of nitrous oxide in atmosphere [ppmv]
#' @param sourceN2O Concentration of nitrous oxide in headspace source gas [ppmv]

#' @return This function returns dissolved CO2, CH4, and N2O concentrations in surface water [M] based on headspace equilibration data.
#'   Function also returns dissolved 100% saturation concentrations  [M] of CO2, CH4, and N2O in surface waters.
#'   Outputs are appended as additional columns to the input data frame

#' @references
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

#' @keywords dissolved gases, methane, CH4, carbon dioxide, CO2, nitrous oxide, N2O, surface water, aquatic, streams, lakes, rivers

#' @examples
#' #where the data frame "sdgFormatted" is already read in
#' sdgDataPlusVals <- def.calc.sdg(inputFile = sdgFormatted)
#' #where the data is read in from a file in the working directory (also works with a full path)
#' sdgDataPlusVals <- def.calc.sdg(inputFile = 
#' system.file("extdata", "sdgTestData.csv", package = "neonDissGas"))

#' @seealso def.format.sdg.R for formatting dissolved gas data downloaded from NEON

#' @export

# changelog and author contributions / copyrights
#   Kaelin M. Cawley (2017-02-14)
#     original creation
#   Kaelin M. Cawley (2017-09-14)
#     updated with step-by-step calculations in communication with Jake Beaulieu
#   Kaelin M. Cawley & Jake Beaulieu (2017-09-28)
#     updated with revised 
##############################################################################################
def.calc.sdg <- function(
  inputFile,
  volGas = inputFile$gasVolume,
  volH2O = inputFile$waterVolume,
  baro = inputFile$barometricPressure,
  waterTemp = inputFile$waterTemp,
  headspaceTemp = ifelse(is.na(inputFile$headspaceTemp), # if headspace temp not recorded, use water temp
                  inputFile$waterTemp,
                  inputFile$headspaceTemp),
  eqCO2 = inputFile$concentrationCO2Gas,
  airCO2 = ifelse(is.na(inputFile$concentrationCO2Air), # use global average if not measured
                  405, # https://www.esrl.noaa.gov/gmd/ccgg/trends/global.html
                  inputFile$concentrationCO2Air),
  sourceCO2 = inputFile$concentrationCO2Source,
  eqCH4 = inputFile$concentrationCH4Gas,
  airCH4 = ifelse(is.na(inputFile$concentrationCH4Air), # use global average if not measured
                  1.85, #https://www.esrl.noaa.gov/gmd/ccgg/trends_ch4/
                  inputFile$concentrationCH4Air),
  sourceCH4 = inputFile$concentrationCH4Source,
  eqN2O = inputFile$concentrationN2OGas,
  airN2O = ifelse(is.na(inputFile$concentrationN2OAir), # use global average if not measured
                  0.330, #https://www.esrl.noaa.gov/gmd/hats/combined/N2O.html
                  inputFile$concentrationN2OAir),
  sourceN2O = inputFile$concentrationN2OSource
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
  
  ##### Calculate dissolved gas concentration in original water sample #####
  inputFile$dissolvedCO2 <- NA
  inputFile$dissolvedCO2 <- baro * cPresConv * (volGas*(eqCO2 - sourceCO2)/(cGas * (headspaceTemp + cKelvin) * volH2O) 
                        + ckHCO2 * exp(cdHdTCO2*(1/(headspaceTemp + cKelvin) - 1/cT0))* eqCO2)
  
  inputFile$dissolvedCH4 <- NA
  inputFile$dissolvedCH4 <- baro * cPresConv * (volGas*(eqCH4 - sourceCH4)/(cGas * (headspaceTemp + cKelvin) * volH2O) 
                        + ckHCH4 * exp(cdHdTCH4*(1/(headspaceTemp + cKelvin) - 1/cT0))* eqCH4)
  
  inputFile$dissolvedN2O <- NA
  inputFile$dissolvedN2O <- baro * cPresConv * (volGas*(eqN2O - sourceN2O)/(cGas * (headspaceTemp + cKelvin) * volH2O) 
                        + ckHN2O * exp(cdHdTN2O*(1/(headspaceTemp + cKelvin) - 1/cT0))* eqN2O)

  
  ##### Calculate dissolved gas concentration at 100% saturation ##### 
  
  # 100% saturation occurs when the dissolved gas concentration is in equilibrium
  # with the atmosphere.
  inputFile$satCO2 <- (ckHCO2 * exp(cdHdTCO2*(1/(waterTemp + cKelvin) - 1/cT0))) * airCO2 * baro * cPresConv
  inputFile$satCH4 <- (ckHCH4 * exp(cdHdTCH4*(1/(waterTemp + cKelvin) - 1/cT0))) * airCH4 * baro * cPresConv  
  inputFile$satN2O <- (ckHN2O * exp(cdHdTN2O*(1/(waterTemp + cKelvin) - 1/cT0))) * airN2O * baro * cPresConv
  
  
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
  # CO2air <- (airCO2 * cPresConv * baro * (volGas/1000))/(cGas * (headspaceTemp + cKelvin))
  # CH4air <- (airCH4 * cPresConv * baro * (volGas/1000))/(cGas * (headspaceTemp + cKelvin))
  # N2Oair <- (airN2O * cPresConv * baro * (volGas/1000))/(cGas * (headspaceTemp + cKelvin))
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

