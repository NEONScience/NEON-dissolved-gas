
sdgData <- neonUtilities::loadByProduct(dpID = "DP1.20097.001",
                                        site = c('COMO','WALK','MART','CARI','KING'),
                                        startdate = "2022-01",
                                        check.size = FALSE)

externalLabData <- sdgData$sdg_externalLabData
fieldDataProc <- sdgData$sdg_fieldDataProc
fieldSuperParent <- sdgData$sdg_fieldSuperParent

# #Add in the L0 data
# names(externalLabData)
# 
# l0Data <- read.table("C:/Users/kcawley/Documents/forHannah/sdg_externalLabData_in/Dissolved_gases_in_surface_water,_Level_0_sdg_externalLabData_in.txt",
#                      header = TRUE)
# l0Data$siteID <- substr(l0Data$sampleID,1,4)
# 
# sitesForHannah <- c('COMO','WALK','MART','CARI','KING')
# dataForHannah <- l0Data[l0Data$siteID %in% sitesForHannah & l0Data$collectDate >= "2022-01-01",] 
# 
# names(dataForHannah)[names(dataForHannah) %in% names(externalLabData)]
# names(externalLabData)[!names(externalLabData) %in% names(dataForHannah)]
# 
# dataForHannah$namedLocation <- dataForHannah$stationID
# 
# externalLabData <- dataForHannah

sdgFormatted <- neonDissGas::def.format.sdg(externalLabData = externalLabData,
                                            fieldDataProc = fieldDataProc,
                                            fieldSuperParent = fieldSuperParent)
sdgConcentrations <- neonDissGas::def.calc.sdg.conc(inputFile = sdgFormatted)
sdgDataPlusSat <- neonDissGas::def.calc.sdg.sat(inputFile = sdgConcentrations)

# write.csv(sdgDataPlusSat,
#           "C:/Users/kcawley/Documents/forHannah/sdg_externalLabData_in/sdgConcentrationsAndSat.csv",
#           row.names = FALSE)
