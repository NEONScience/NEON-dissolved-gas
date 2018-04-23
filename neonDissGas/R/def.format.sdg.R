##############################################################################################
#' @title Dissolved Gas Data Formatting
#' @export

#' @author 
#' Kaelin M. Cawley \email{kcawley@battelleecology.org} \cr

#' @description This function reads in data from the NEON Dissolved Gas data product to calculate dissolved gas concentrations in surface water. For the best results download the expanded dissolved gas package. No need to unzip the downloaded files, just place them all in the smae directory.
#' @importFrom neonUtilities stackByTable
#' @importFrom utils read.csv

#' @param dataDir User identifies the directory that contains the zipped data

#' @return This function returns one data frame formatted for use with def.calc.sdg.R to actually calculate the concentration of the gases in the surface water sample

#' @references
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

#' @keywords dissolved gases, methane, CH4, carbon dioxide, CO2, nitrous oxide, N2O, surface water, aquatic, streams, lakes, rivers

#' @examples
#' #where the data .zip file is in the working directory and has the default name, 
#' #sdgFormatted <- def.format.sdg()
#' #where the data.zip file is in the downloads folder and has default name, 
#' #sdgFormatted <- 
#' #def.format.sdg(dataDir = path.expand("~/Downloads/NEON_dissolved-gases-surfacewater.zip"))
#' #where the data.zip file is in the downloads folder and has a specified name,
#' #sdgFormatted <- def.format.sdg(dataDir = path.expand("~/Downloads/non-standard-name.zip"))
#' #Using the example data in this package
#' #dataDirectory <- paste(path.package("neonDissGas"),"inst\\extdata", sep = "\\")
#' #sdgFormatted <- def.format.sdg(dataDir = dataDirectory)

#' @seealso def.calc.sdg.conc.R and def.calc.sdg.sat.R for calculating dissolved gas 
#' concentrations and percent saturation, respectively

# changelog and author contributions / copyrights
#   Kaelin M. Cawley (2017-02-14)
#     original creation
#   Kaelin M. Cawley (2018-04-23)
#     Update to use revised stackByTable function that is part of neonUtilities package
##############################################################################################
def.format.sdg <- function(
  dataDir = paste0(getwd(),"/NEON_dissolved-gases-surfacewater.zip")
) {
  
  ##### Default values #####
  volH2O <- 40 #mL
  volGas <- 20 #mL
  
  #Stack field and external lab data
  if(!dir.exists(substr(dataDir, 1, (nchar(dataDir)-4)))){
    stackByTable(dpID = "DP1.20097.001", filepath = dataDir)
  }
  
  externalLabData <- read.csv(paste(gsub("\\.zip","",dataDir),"stackedFiles","sdg_externalLabData.csv", sep = "/"), stringsAsFactors = F)
  fieldDataProc <- read.csv(paste(gsub("\\.zip","",dataDir),"stackedFiles","sdg_fieldDataProc.csv", sep = "/"), stringsAsFactors = F)
  fieldSuperParent <- read.csv(paste(gsub("\\.zip","",dataDir),"stackedFiles","sdg_fieldSuperParent.csv", sep = "/"), stringsAsFactors = F)
  
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
    outputDF$barometricPressure <- fieldDataProc$ptBarometricPressure
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

