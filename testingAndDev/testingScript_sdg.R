
#Re-install dataStackR since there may be non-code updates
#Do not use: install_github("NEONScience/NEON-utilities/neonDataStackR", force = TRUE, dependencies = TRUE)
library(devtools)
install_github("NEONScience/NEON-utilities/neonUtilities", force = TRUE, dependencies = TRUE)

library(roxygen2)
setwd("C:/Users/kcawley/Documents/GitHub/NEON-dissolved-gas")
#setwd("C:/Users/Kaelin/Documents/GitHub/NEON-dissolved-gas")
devtools::install("neonDissGas")
library(neonDissGas)

#dataDir <- "C:/Users/kcawley/Desktop/NEON_dissolved-gases-surfacewater.zip"
dataDir <- "C:/Users/kcawley/Downloads/NEON_dissolved-gases-surfacewater.zip"
#dataDir <- "C:/Users/Kaelin/Downloads/NEON_dissolved-gases-surfacewater.zip"

sdgFormatted <- def.format.sdg(dataDir = dataDir)

sdgDataPlusConc <- def.calc.sdg.conc(inputFile = sdgFormatted)
sdgDataPlusSat <- def.calc.sdg.sat(inputFile = sdgDataPlusConc)

setwd("C:/Users/kcawley/Documents/GitHub/NEON-dissolved-gas/neonDissGas")
sdgFormatted <- sdgFormatted[1:25,]
#WRite out new sdgFormatted.rda file
use_data(sdgFormatted,internal = FALSE,overwrite = TRUE)
#setwd("C:/Users/Kaelin/Documents/GitHub/NEON-dissolved-gas/neonDissGas")
devtools::document()
devtools::check()
