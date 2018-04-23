
allPackages <- installed.packages()
if(!("devtools" %in% allPackages[,"Package"])){
  install.packages("devtools", dependencies = TRUE)
}
library(devtools)
install_github("NEONScience/NEON-utilities/neonUtilities", force = TRUE, dependencies = TRUE)
install_github("NEONScience/NEON-dissolved-gas/neonDissGas", force = TRUE, dependencies = TRUE)
library(neonDissGas)

dataDir <- "C:/Users/kcawley/Desktop/NEON_dissolved-gases-surfacewater.zip"

sdgFormatted <- def.format.sdg(dataDir = dataDir)

sdgDataPlusVals <- def.calc.sdg(inputFile = sdgFormatted)

