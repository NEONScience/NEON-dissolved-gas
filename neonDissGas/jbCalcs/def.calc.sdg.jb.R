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

#' @seealso def.values.sdg.R and def.format.sdg.R for calculating dissolved gas concentrations

#' @export

# changelog and author contributions / copyrights
#   Kaelin M. Cawley (2017-02-14)
#     original creation
##############################################################################################
def.calc.sdg.jb <- function(
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
  cGas<-8.3144598 #universal gas constant (J K-1 mol-1)
  cKelvin <- 273.15 #Conversion factor from Kelvin to Celsius
  cPresConv <- 0.000001 #Conversion factor from kPA to Pa (should this be 1/1000), 1kPA = 1000 PA?
  cT0 <- 298.15#Henry's law constant T0
  #Henry's law constants and temperature dependence from Sander (2015) DOI: 10.5194/acp-15-4399-2015
  ckHCO2 <- 0.00033 #mol m-3 Pa
  ckHCH4 <- 0.000014 #mol m-3 Pa
  ckHN2O <- 0.00024 #mol m-3 Pa
  cdHdTCO2 <- 2400 #K
  cdHdTCH4 <- 1900 #K
  cdHdTN2O <- 2700 #K
  
  #####Calculate dissolved gas concentrations
  # Dissolved gas concentration in the original water samples (dissolvedGas) is
  # calculated from a mass balance of the measured headspace concentration (eqGas), the 
  # calculated concentration in the equilibrated headspace water (eqHeadspaceWaterCO2), 
  # and the volumes of the headspace water and headspace gas, following:
  
  # dissolvedGas  = ((eqGas * volGas) + (eqHeadspaceWaterGas * volH2O)) / volH2O
  
  # Measured headspace concentration should be expressed as mol L- for the mass
  # balance calculation and as partial pressure for the equilibrium calculation.
  
  # Convert headspace concentration from ppmv to mol L-1.  Use ideal gas law assuming
  # measurement made at room temp (25C).  
  eqCO2M <- (eqCO2/(0.082058 * 298.15))*(1/1000000)  # 1/1000000 for unit conversion
  
  # convert from ppmv to partial pressure (Pa)
  eqCO2Pp <- (eqCO2/1000000) * (baro * 1000) # *1000 to go from kPa to PA
  
  
  # Concentration of gas used for headspace equilibrium should be expressed in 
  # mol/l for mass balance calculations.   Use ideal gas law assuming
  # measurement made at room temp (25C).  
  airCO2M <- (airCO2/(0.082058 * 298.15))*(1/1000000) # # 1/1000000 for unit conversion
  
  
  
  # Dissolved gas concentration of equilibrated water used in headspace equilibration (mol L-1).
  # Calculated from measured gas mixing ratio (ppmv), pressure of headspace equilibration
  # system (assumed to be equal to barometric pressure), and temp corrected Henry's
  # Law Solubility Constant.
  eqHeadspaceWaterCO2 <- (ckHCO2 * exp(cdHdTCO2*(1/(waterTemp + cKelvin) - 1/cT0))) * eqCO2Pp * (1/1000) # unit conversion from m3 (from ckHCH4) to L
  
  # Total moles of CO2 in headspace system, minus CO2 from source gas
  tCO2 <- (eqCO2M * (volGas/1000)) + (eqHeadspaceWaterCO2 * (volH2O/1000)) - (airCO2M * (volGas/1000))
  
  # Dissolved gas concentration of original water sample (mol L-1)
  # Total moles CO2 divided by volume of water used in headspace equilibrium
  inputFile$dissolvedCO2Jb <- NA
  inputFile$dissolvedCO2Jb <- tCO2 / (volH2O/1000)


  
  #Round to significant figures
  inputFile$dissolvedCO2 <- signif(inputFile$dissolvedCO2, digits = 3)

  
  return(inputFile)
  
}

