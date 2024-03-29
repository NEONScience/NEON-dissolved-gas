##############################################################################################
#' @title Dissolved Gas Data Formatting
#' @export

#' @author 
#' Kaelin M. Cawley \email{kcawley@battelleecology.org} \cr

#' @description This function reads in data from the NEON Dissolved Gas data product to calculate dissolved gas concentrations in surface water. For the best results download the expanded dissolved gas package. No need to unzip the downloaded files, just place them all in the smae directory.

#' @param externalLabData Data frame containing external lab data for NEON
#' @param fieldDataProc Data frame containing field processing data for NEON
#' @param fieldSuperParent Data frame containing field collection data for NEON

#' @return This function returns one data frame formatted for use with def.calc.sdg.R to actually calculate the concentration of the gases in the surface water sample

#' @references
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

#' @keywords dissolved gases, methane, CH4, carbon dioxide, CO2, nitrous oxide, N2O, surface water, aquatic, streams, lakes, rivers

#' @examples
#' \dontrun{TBD}

#' @seealso def.calc.sdg.conc.R and def.calc.sdg.sat.R for calculating dissolved gas 
#' concentrations and percent saturation, respectively

# changelog and author contributions / copyrights
#   Kaelin M. Cawley (2017-02-14)
#     original creation
#   Kaelin M. Cawley (2018-04-23)
#     Update to use revised stackByTable function that is part of neonUtilities package
#   Kaelin M. Cawley (2020-01-27)
#     Update to work with loadByProduct in latest release of neonUtilities
#   Kaelin M. Cawley (2022-07-30)
#     Updated to be a little more agnostic to download process and not require neonUtilities
##############################################################################################
def.format.sdg <- function(
    externalLabData = NA,
    fieldDataProc = NA,
    fieldSuperParent = NA
) {
  
  #Check if the data is loaded already using loadByProduct
  if(all(is.na(externalLabData)) | all(is.na(fieldDataProc)) | all(is.na(fieldSuperParent))){
    print("externalLabData, fieldDataProd, and fieldSuperParent data tables are required to proceed.")
  }
  
  ##### Default values #####
  volH2O <- 40 #mL
  volGas <- 20 #mL
  
  #Flag and set default field values
  fieldDataProc$volH2OSource <- ifelse(is.na(fieldDataProc$waterVolumeSyringe),1,0)
  fieldDataProc$volGasSource <- ifelse(is.na(fieldDataProc$gasVolumeSyringe),1,0)
  fieldDataProc$waterVolumeSyringe[is.na(fieldDataProc$waterVolumeSyringe)] <- volH2O
  fieldDataProc$gasVolumeSyringe[is.na(fieldDataProc$gasVolumeSyringe)] <- volGas
  
  outputDFNames <- c(
    'waterSampleID',
    'referenceAirSampleID',
    'equilibratedAirSampleID',
    'collectDate',
    'processedDate',
    'stationID',
    'barometricPressure',
    'headspaceTemp',
    'waterTemp',
    'concentrationCO2Air',
    'concentrationCO2Gas',
    'concentrationCH4Air',
    'concentrationCH4Gas',
    'concentrationN2OAir',
    'concentrationN2OGas',
    'waterVolume',
    'gasVolume',
    #'CO2BelowDetection',
    #'CH4BelowDetection',
    #'N2OBelowDetection',
    'volH2OSource',
    'volGasSource'
  )
  outputDF <- data.frame(matrix(data=NA, ncol=length(outputDFNames), nrow=length(fieldDataProc$waterSampleID)))
  names(outputDF) <- outputDFNames
  
  #Populate the output file with field data
  for(k in 1:length(names(outputDF))){
    if(names(outputDF)[k] %in% names(fieldDataProc)){
      outputDF[,k] <- fieldDataProc[,names(fieldDataProc) == names(outputDF)[k]]
    }
    outputDF$headspaceTemp <- fieldDataProc$storageWaterTemp
    outputDF$barometricPressure <- ifelse(!is.na(fieldDataProc$ptBarometricPressure), fieldDataProc$ptBarometricPressure, fieldDataProc$procBarometricPressure)
    outputDF$waterVolume <- fieldDataProc$waterVolumeSyringe
    outputDF$gasVolume <- fieldDataProc$gasVolumeSyringe
    outputDF$stationID <- fieldDataProc$namedLocation
  }
  
  #Populate the output file with external lab data
  for(l in 1:length(outputDF$waterSampleID)){
    try({
      outputDF$concentrationCO2Air[l] <- externalLabData$concentrationCO2[externalLabData$sampleID == outputDF$referenceAirSampleID[l]]
      outputDF$concentrationCO2Gas[l] <- externalLabData$concentrationCO2[externalLabData$sampleID == outputDF$equilibratedAirSampleID[l]]
    }, silent = T)
    try({
      outputDF$concentrationCH4Air[l] <- externalLabData$concentrationCH4[externalLabData$sampleID == outputDF$referenceAirSampleID[l]]
      outputDF$concentrationCH4Gas[l] <- externalLabData$concentrationCH4[externalLabData$sampleID == outputDF$equilibratedAirSampleID[l]]
    }, silent = T)
    try({
      outputDF$concentrationN2OAir[l] <- externalLabData$concentrationN2O[externalLabData$sampleID == outputDF$referenceAirSampleID[l]]
      outputDF$concentrationN2OGas[l] <- externalLabData$concentrationN2O[externalLabData$sampleID == outputDF$equilibratedAirSampleID[l]]
    }, silent = T)
  }
  
  #Populate the output file with water temperature data for streams
  for(m in 1:length(outputDF$waterSampleID)){
    try(outputDF$waterTemp[m] <- fieldSuperParent$waterTemp[fieldSuperParent$parentSampleID == outputDF$waterSampleID[m]],silent = T)
    if(is.na(outputDF$headspaceTemp[m])){
      try(
        outputDF$headspaceTemp[m] <- fieldSuperParent$waterTemp[fieldSuperParent$parentSampleID == outputDF$waterSampleID[m]],
        silent = T)
    }
  }
  
  #Flag values below detection (TBD)

  return(outputDF)
}

