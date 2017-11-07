
library(devtools)
library(roxygen2)

setwd("C:/Users/kcawley/Documents/GitHub/NEON-dissolved-gas")
setwd("C:/Users/Kaelin/Documents/GitHub/NEON-dissolved-gas")
#setwd("C:/Users/Kaelin/Downloads/dplyr_0.7.4")
#install("dplyr")
install_github("NEONScience/NEON-utilities/neonDataStackR", force = TRUE, dependencies = TRUE)
install("neonDissGas")
library(neonDissGas)

dataDir <- "C:/Users/kcawley/Downloads/NEON_dissolved-gases-surfacewater.zip"
dataDir <- "C:/Users/Kaelin/Downloads/NEON_dissolved-gases-surfacewater.zip"

sdgFormatted <- def.format.sdg(dataDir = dataDir)

sdgDataPlusVals <- def.calc.sdg(inputFile = sdgFormatted)

setwd("C:/Users/kcawley/Documents/GitHub/NEON-dissolved-gas/neonDissGas")
setwd("C:/Users/Kaelin/Documents/GitHub/NEON-dissolved-gas/neonDissGas")
document()
devtools::check()
