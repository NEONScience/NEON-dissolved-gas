# Wrapper script as an example of using the Python scripts for SDG data analysis.
# Note - the function imports require importing the Python packages numpy and pandas,
# and will fail without them.

from def_format_sdg import def_format_sdg
from def_calc_sdg_conc import def_calc_sdg_conc
from def_calc_sdg_sat import def_calc_sdg_sat


import pandas

# This is the path to the parent directory of the 'stackedFiles' directory that 
# contains the 'stacked' .csv files
# (after the .zip archive of the SDG data has been downloaded from the 
# NEON data portal and 'stacked' using the stackByTable function of the 
# neonUtilities package in R. For more information and links for tutorials
# in using the neonUtilities package, please see the README file in the GitHub
# repository where these Python scripts are located.
input_path = "~/Downloads/NEON_dissolved-gases-surfacewater__3/"

sdg_data = def_format_sdg(data_dir = input_path)

print("Finished importing the stacked tables")
print("The first 5 lines of the sdg_data DataFrame are:")
print(sdg_data.head())

sdg_calc = def_calc_sdg_conc(sdg_data)

print("Finished calculating the gas concentrations")
print("The first 5 lines of the sdg_calc DataFrame are:")
print(sdg_calc.head())

sdg_sat = def_calc_sdg_sat(sdg_calc)

print("Finished adding the percent saturation values to the calculated gas concentrations")
print("The first 5 lines of the sdg_sat DataFrame are:")
print(sdg_sat.head())


