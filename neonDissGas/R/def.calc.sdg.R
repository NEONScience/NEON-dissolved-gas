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
  cGas<-8.3144598 #universal gas constant (J K-1 mol-1)
  cKelvin <- 273.15 #Conversion factor from Kelvin to Celsius
  cPresConv <- 0.000001 #Conversion factor from kPA to Pa
  cT0 <- 298.15#Henry's law constant T0
  #Henry's law constants and temperature dependence from Sander (2015) DOI: 10.5194/acp-15-4399-2015
  ckHCO2 <- 0.00033 #mol m-3 Pa
  ckHCH4 <- 0.000014 #mol m-3 Pa
  ckHN2O <- 0.00024 #mol m-3 Pa
  cdHdTCO2 <- 2400 #K
  cdHdTCH4 <- 1900 #K
  cdHdTN2O <- 2700 #K
  
  #####Calculate dissolved gas concentrations
  inputFile$dissolvedCO2 <- NA
  inputFile$dissolvedCO2 <- baro * cPresConv * (volGas*(eqCO2 - airCO2)/(cGas * (waterTemp + cKelvin) * volH2O) 
                        + ckHCO2 * exp(cdHdTCO2*(1/(waterTemp + cKelvin) - 1/cT0))* eqCO2)
  
  inputFile$dissolvedCH4 <- NA
  inputFile$dissolvedCH4 <- baro * cPresConv * (volGas*(eqCH4 - airCH4)/(cGas * (waterTemp + cKelvin) * volH2O) 
                        + ckHCH4 * exp(cdHdTCH4*(1/(waterTemp + cKelvin) - 1/cT0))* eqCH4)
  
  inputFile$dissolvedN2O <- NA
  inputFile$dissolvedN2O <- baro * cPresConv * (volGas*(eqN2O - airN2O)/(cGas * (waterTemp + cKelvin) * volH2O) 
                        + ckHN2O * exp(cdHdTN2O*(1/(waterTemp + cKelvin) - 1/cT0))* eqN2O)
  
  #Round to significant figures
  inputFile$dissolvedCO2 <- signif(inputFile$dissolvedCO2, digits = 3)
  inputFile$dissolvedCH4 <- signif(inputFile$dissolvedCH4, digits = 3)
  inputFile$dissolvedN2O <- signif(inputFile$dissolvedN2O, digits = 3)
  
  return(inputFile)
  
}

