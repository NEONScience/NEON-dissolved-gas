
library(devtools)
library(roxygen2)

setwd("C:/Users/kcawley/Documents/GitHub/NEON-dissolved-gas")
install("neonDissGas")
library(neonDissGas)

dataDir <- "C:/Users/kcawley/Downloads/NEON_dissolved-gases-surfacewater.zip"

sdgFormatted <- def.format.sdg(dataDir = dataDir)

sdgDataPlusVals <- def.calc.sdg(inputFile = sdgFormatted)

setwd("C:/Users/kcawley/Documents/GitHub/NEON-dissolved-gas/neonDissGas")
document()
devtools::check()
