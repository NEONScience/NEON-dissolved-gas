##############################################################################################
#' @title Dissolved Gas Data Formatting
#' @export

#' @author
#' Marcela Rodriguez \email{rodriguezm@battelleecology.org} \cr

#' @description This function reads in data from the NEON Dissolved Gas data product to calculate dissolved gas concentrations in surface water. For the best results download the expanded dissolved gas package. No need to unzip the downloaded files, just place them all in the sae directory.
#' @importFrom neonUtilities stackByTable
#' @importFrom utils read.csv

#' @param dataDir User identifies the directory that contains the zipped data

#' @return This function returns one data frame formatted for use with def.calc.sdg.R to actually calculate the concentration of the gases in the surface water sample

#' @references
#' License: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

#' @keywords dissolved gases, methane, CH4, carbon dioxide, CO2, nitrous oxide, N2O, surface water, aquatic, streams, lakes, rivers

#' @examples
#' #where the data .zip file is in the working directory and has the default name,
#' #sdgFormatted = def_format_sdg()
#' #where the data.zip file is in the downloads folder and has default name,
#' #sdgFormatted =
#' #def_format_sdg(dataDir = path.expand("~/Downloads/NEON_dissolved-gases-surfacewater.zip"))
#' #where the data.zip file is in the downloads folder and has a specified name,
#' #sdgFormatted = def_format_sdg(dataDir = path.expand("~/Downloads/non-standard-name.zip"))
#' #Using the example data in this package
#' #dataDirectory = re.sub("\\.zip", "", data_dir) + "/stackedFiles" + "/extdata")
#' #sdgFormatted = def_format_sdg(dataDir = dataDirectory)

#' @seealso def_calc_sdg_conc.py and def_calc_sdg_sat.py for calculating dissolved gas
#' concentrations and percent saturation, respectively

##############################################################################################
import pandas as pd
import os
import os.path
import re
import numpy as np


def def_format_sdg(data_dir=os.getcwd() + '/NEON_dissolved-gases-surfacewater(1).zip'):

    ##### Default values ####
    volH2O = 40 #mL
    volGas = 20 #mL

    #Check if the data is loaded already using loadByProduct
    if 'externalLabData' and 'fieldDataProc' and 'fieldSuperParent' not in locals() or globals():
        #  print("data is not loaded")  # testing code

        # If data is not loaded, stack field and external lab data
        if os.path.isdir(re.sub("\\.zip", "", data_dir)):
            neonUtilities.stackByTable(dpID="DP1.20097.001", filepath=data_dir)

        externalLabData = pd.read_csv(re.sub("\\.zip", "", data_dir) + "/stackedFiles" + "/sdg_externalLabData.csv")
        fieldDataProc = pd.read_csv(re.sub("\\.zip", "", data_dir) + "/stackedFiles" + "/sdg_fieldDataProc.csv")
        fieldSuperParent = pd.read_csv(re.sub("\\.zip", "", data_dir) + "/stackedFiles" + "/sdg_fieldSuperParent.csv")

    #Flag and set default field values
    if fieldDataProc['waterVolumeSyringe'].isna() is True:
        fieldDataProc['volH2OSource'] = 1
    else:
        fieldDataProc['volH2OSource'] = 0

    if fieldDataProc['gasVolumeSyringe'].isna() is True:
        fieldDataProc['volGasSource'] = 1
    else:
        fieldDataProc['volGasSource'] = 0

    if fieldDataProc['waterVolumeSyringe'].isna() is True:
        fieldDataProc['waterVolumeSyringe'] = volH2O

    if fieldDataProc['gasVolumeSyringe'].isna() is True:
        fieldDataProc['gasVolumeSyringe'] = volGas

    outputDFNames = [
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
    ]

    outputDF = pd.DataFrame(index=np.arange(len(fieldDataProc['waterSampleID'])), columns=np.arange(len(outputDFNames)))
    outputDF.columns = outputDFNames

    # Populate the output file with field data
    for k in range(len(outputDF.columns)):
        if outputDF.columns[k] in fieldDataProc.columns:
            outputDF.iloc[:, k] = fieldDataProc.loc[:,fieldDataProc.columns == outputDF.columns[k]]

    outputDF['headspaceTemp'] = fieldDataProc['storageWaterTemp']
    outputDF['barometricPressure'] = fieldDataProc['ptBarometricPressure']
    outputDF['waterVolume'] = fieldDataProc['waterVolumeSyringe']
    outputDF['gasVolume'] = fieldDataProc['gasVolumeSyringe']
    outputDF['stationID'] = fieldDataProc['namedLocation']


    #Populate the output file with external lab data
    for l in range(len(outputDF['waterSampleID'])):
        try:
            outputDF.loc[outputDF.index[[l]], 'concentrationCO2Air'] = externalLabData.loc[externalLabData.loc[:, 'sampleID'] == outputDF.loc[outputDF.index[[l]], 'referenceAirSampleID'].item(), 'concentrationCO2'].item()
            outputDF.loc[outputDF.index[[l]], 'concentrationCO2Gas'] = externalLabData.loc[externalLabData.loc[:, 'sampleID'] == outputDF.loc[outputDF.index[[l]], 'equilibratedAirSampleID'].item(), 'concentrationCO2'].item()

        except Exception:
            pass
        try:
            outputDF.loc[outputDF.index[[l]], 'concentrationCH4Air'] = externalLabData.loc[externalLabData.loc[:, 'sampleID'] == outputDF.loc[outputDF.index[[l]], 'referenceAirSampleID'].item(), 'concentrationCH4'].item()
            outputDF.loc[outputDF.index[[l]], 'concentrationCH4Gas'] = externalLabData.loc[ externalLabData.loc[:, 'sampleID'] == outputDF.loc[outputDF.index[[l]], 'equilibratedAirSampleID'].item(), 'concentrationCH4'].item()

        except Exception:
            pass

        try:
            outputDF.loc[outputDF.index[[l]], 'concentrationN2OAir'] = externalLabData.loc[externalLabData.loc[:, 'sampleID'] == outputDF.loc[outputDF.index[[l]], 'referenceAirSampleID'].item(), 'concentrationN2O'].item()
            outputDF.loc[outputDF.index[[l]], 'concentrationN2OGas'] = externalLabData.loc[externalLabData.loc[:, 'sampleID'] == outputDF.loc[outputDF.index[[l]], 'equilibratedAirSampleID'].item(), 'concentrationN2O'].item()
        except Exception:
            pass

    #Populate the output file with water temperature data for streams
    for m in range(len(outputDF['waterSampleID'])):
        try:
            outputDF.loc[outputDF.index[[m]], 'waterTemp'] = fieldSuperParent.loc[fieldSuperParent.loc[:, 'parentSampleID'] == outputDF.loc[outputDF.index[[m]], 'waterSampleID'].item(), 'waterTemp'].item()
        except Exception:
            pass
        if pd.isna(outputDF['headspaceTemp'][m]) is True:
            try:
                outputDF.loc[outputDF.index[[m]], 'headspaceTemp'] = fieldSuperParent.loc[fieldSuperParent.loc[:, 'parentSampleID'] == outputDF.loc[outputDF.index[[m]], 'waterSampleID'].item(), 'waterTemp'].item()
            except Exception:
                pass

    #Convert values to floats since they default to object
    outputDF['waterTemp'] = outputDF.waterTemp.astype(float)
    outputDF['concentrationCO2Air'] = outputDF.concentrationCO2Air.astype(float)
    outputDF['concentrationCO2Gas'] = outputDF.concentrationCO2Gas.astype(float)
    outputDF['concentrationCH4Air'] = outputDF.concentrationCH4Air.astype(float)
    outputDF['concentrationCH4Gas'] = outputDF.concentrationCH4Gas.astype(float)
    outputDF['concentrationN2OAir'] = outputDF.concentrationN2OAir.astype(float)
    outputDF['concentrationN2OGas'] = outputDF.concentrationN2OGas.astype(float)

    # Flag values below detection (TBD)
    return outputDF
