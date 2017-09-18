##############################################################################################
#' @title Dissolved Gas Concentration Calculations

#' @author 
#' Kaelin M. Cawley \email{kcawley@battelleecology.org} \cr

#' @description This function calculates dissolved CO2, CH4, and N2O concentrations from water samples based on inputs of equilibration conditions and reference and equilibrated air CO2, CH4, and N2O concentrations. If samples were equilibrated with a pure gas that contains no CO2, CH4, or N2O, the concentrations for the reference air ("concentrationCO2Air", "concentrationCH4Air", "concentrationN2OAir") for those gases should be set to 0.

#' @param inputFile Name of the data fram containing the information needed to calculate the dissolved gas concentrations. If the headers are named: "gasVolume", "waterVolume", "barometricPressure", "waterTemp", "concentrationCO2Gas", "concentrationCO2Air", "concentrationCH4Gas", "concentrationCH4Air", "concentrationN2OGas", "concentrationN2OAir", respectively, no other inputs are required. Otherwise, the names of the columns need to be input for the function to work.
#' @param volGas Volume of air equilibrated with water [mL]
#' @param volH2O Volume of water equilibrated with air [mL]
#' @param baro Barometric pressure at the time of equilibration [kPa]
#' @param waterTemp Temperature of the water at the time of equilibration [celsius]
#' @param eqCO2 Concentration of carbon dioxide in the equilibrated gas [ppmv]
#' @param airCO2 Concentration of carbon dioxide in the reference air [ppmv]
#' @param eqCH4 Concentration of methane in the equilibrated gas [ppmv]
#' @param airCH4 Concentration of methane in the reference air [ppmv]
#' @param eqN2O Concentration of nitrous oxide in the equilibrated gas [ppmv]
#' @param airN2O Concentration of nitrous oxide in the reference air [ppmv]

#' @return This function returns dissolved CO2, CH4, and N2O concentrations in surface water [M] appended as additional columns to the input data frame

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
##############################################################################################
def.calc.sdg <- function(
  inputFile,
  volGas = inputFile$gasVolume,
  volH2O = inputFile$waterVolume,
  baro = inputFile$barometricPressure,
  waterTemp = inputFile$waterTemp,
  eqCO2 = inputFile$concentrationCO2Gas,
  airCO2 = inputFile$concentrationCO2Air,
  eqCH4 = inputFile$concentrationCH4Gas,
  airCH4 = inputFile$concentrationCH4Air,
  eqN2O = inputFile$concentrationN2OGas,
  airN2O = inputFile$concentrationN2OAir
) {
  
  if(typeof(inputFile) == "character"){
    inputFile <- read.csv(inputFile)
  }
  
  ##### Constants #####
  cGas<-8.3144598 #universal gas constant (J K-1 mol-1 = L kPa K-1 mol-1)
  cKelvin <- 273.15 #Conversion factor from Kelvin to Celsius
  cPresConv <- 0.000001 # Conversion factor from ppmv to mole fraction.
  cT0 <- 298.15#Henry's law constant T0
  #Henry's law constants and temperature dependence from Sander (2015) DOI: 10.5194/acp-15-4399-2015
  ckHCO2 <- 0.00033 #mol m-3 Pa
  ckHCH4 <- 0.000014 #mol m-3 Pa
  ckHN2O <- 0.00024 #mol m-3 Pa
  cdHdTCO2 <- 2400 #K
  cdHdTCH4 <- 1900 #K
  cdHdTN2O <- 2700 #K
  
  ##### Calculate dissolved gas concentrations #####
  inputFile$dissolvedCO2 <- NA
  inputFile$dissolvedCO2 <- baro * cPresConv * (volGas*(eqCO2 - airCO2)/(cGas * (waterTemp + cKelvin) * volH2O) 
                        + ckHCO2 * exp(cdHdTCO2*(1/(waterTemp + cKelvin) - 1/cT0))* eqCO2)
  
  inputFile$dissolvedCH4 <- NA
  inputFile$dissolvedCH4 <- baro * cPresConv * (volGas*(eqCH4 - airCH4)/(cGas * (waterTemp + cKelvin) * volH2O) 
                        + ckHCH4 * exp(cdHdTCH4*(1/(waterTemp + cKelvin) - 1/cT0))* eqCH4)
  
  inputFile$dissolvedN2O <- NA
  inputFile$dissolvedN2O <- baro * cPresConv * (volGas*(eqN2O - airN2O)/(cGas * (waterTemp + cKelvin) * volH2O) 
                        + ckHN2O * exp(cdHdTN2O*(1/(waterTemp + cKelvin) - 1/cT0))* eqN2O)
  
  ##### Step-by-step Calculation of dissolved gas concentrations for testing #####
  
  # Dissolved gas concentration in the original water samples (dissolvedGas) is
  # calculated from a mass balance of the measured headspace concentration (eqGas), the 
  # calculated concentration in the equilibrated headspace water (eqHeadspaceWaterCO2), 
  # and the volumes of the headspace water and headspace gas, following:
  
  # dissolvedGas  = ((eqGas * volGas) + (eqHeadspaceWaterGas * volH2O) - (sourceGas * volGas)) / volH2O
  
  # Measured headspace concentration should be expressed as mol L-1 for the mass
  # balance calculation and as partial pressure for the equilibrium calculation.
  
  # #Temperature corrected Henry's Law Constant. see 1.f in README.
  # HCO2 <- ckHCO2 * exp(cdHdTCO2 * ((1/(waterTemp+cKelvin)) - (1/cT0)))
  # HCH4 <- ckHCH4 * exp(cdHdTCH4 * ((1/(waterTemp+cKelvin)) - (1/cT0)))
  # HN2O <- ckHN2O * exp(cdHdTN2O * ((1/(waterTemp+cKelvin)) - (1/cT0)))
  # 
  # #Mol of gas in equilibrated water (using Henry's law) See 1.e in README.
  # CO2eqWat <- HCO2 * eqCO2 * cPresConv * baro * (volH2O/1000)
  # CH4eqWat <- HCH4 * eqCH4 * cPresConv * baro * (volH2O/1000)
  # N2OeqWat <- HN2O * eqN2O * cPresConv * baro * (volH2O/1000)
  # 
  # #Mol of gas in equilibrated air (using ideal gas law).  See 1.c in README.
  # CO2eqAir <- (eqCO2 * cPresConv * baro * (volGas/1000))/(cGas * (waterTemp + cKelvin))
  # CH4eqAir <- (eqCH4 * cPresConv * baro * (volGas/1000))/(cGas * (waterTemp + cKelvin))
  # N2OeqAir <- (eqN2O * cPresConv * baro * (volGas/1000))/(cGas * (waterTemp + cKelvin))
  # 
  # #Mol of gas in reference air (using ideal gas law). See 1.d in README.
  # CO2air <- (airCO2 * cPresConv * baro * (volGas/1000))/(cGas * (waterTemp + cKelvin))
  # CH4air <- (airCH4 * cPresConv * baro * (volGas/1000))/(cGas * (waterTemp + cKelvin))
  # N2Oair <- (airN2O * cPresConv * baro * (volGas/1000))/(cGas * (waterTemp + cKelvin))
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

