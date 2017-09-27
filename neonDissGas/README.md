NEON Dissolved Gas
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- ****** Description ****** -->
This package is for calculating dissolved gas concentrations in surfac water samples from reference air and water equilibrated gas samples.

<!-- ****** Usage ****** -->
Usage
-----

The functions in this package have the following purpose: (1) to format downloaded data, and (2) to calculate dissolved gas concentrations in surface water (mol L-1) from reference air and equilibrated air (ppmv) concentrations. See help files for individual functions for details. The general flow of using this package is:

1.  download data from the NEON data portal, into location "myDataPath"
2.  sdg\_data &lt;- def.format.sdg(dataDir = "myDataPath"), returns a data frame called sdg\_data
3.  sdg\_calc &lt;- def.calc.sdg(sdg\_data), returns a data frame called sdg\_calc with molar concentrations appended as columns

<!-- ****** Calculation Summary ****** -->
Calculation Summary
-------------------

The concentration of gas<sub>i</sub> dissolved in the original water sample (mol L<sup>-1</sup>) is calculated from a mass balance of the measured headspace mixing ratio of gas<sub>i</sub> (ppmv), the calculated concentration in the equilibrated headspace water, and the volumes of the headspace water and headspace gas. The calculations also require the pressure of the headspace equilibration (assumed to be equal to barometric pressure during sampling), the temperature of the headspace equilibration (assumed to be equal to the water temperature), the universal gas constant (R), and the Henry's Law Solubility Constant corrected to the temperature of the headspace equilibration system (assumed to be equal to the water temperature).

The following applies to gas<sub>i</sub>, where gas<sub>i</sub> is equal to CH<sub>4</sub>, N<sub>2</sub>O, or CO<sub>2</sub>:

1.  The gas constant, R, equals 8.3144598 L kPa K<sup>-1</sup> mol<sup>-1</sup>

2.  The dissolved gas concentration in the original water sample is calculated from a mass balance of the headspace equilibration system:

<img src="logo.png" width="300px" />

where

-   C<sub>gas<sub>i</sub></sub>water is the concentration of gas<sub>i</sub> dissolved in the original water sample

1.  mol<sub>gas<sub>i</sub></sub>air<sub>eq</sub> is calculated from the Ideal Gas Law n = <sup>PV</sup>⁄<sub>RT</sub>. In htis equation, P = partial pressure of gas<sub>i</sub> adn T is the temperature of the headspace equilibration system (assumed to be equal to water temperature).

2.  mol<sub>gas<sub>i</sub></sub>air is calculated from the Ideal Gas Law, as above:

3.  mol<sub>gas<sub>i</sub></sub>wat<sub>eq</sub> is calculated from Henry's Law and the colume of water used int he headspace equilibration. Henry's Law states that the concentration of gas<sub>i</sub> dissolved in a water sample is equal to the product of the partial pressure of gas<sub>i</sub> in the overlyiung atmosphere (i.e., the headspace gas) and the Henry's Law Solubility Constant for gas<sub>i</sub> at the temperature of the water, H(T).

4.  Sander (2015) provides a compilation of Henry's Law Solubility Constants standardized to 298.15 K. This standardized Henry's Law Solubility COnstant (H<sup>Θ</sup>) can be converted to the temperature of the headspace equilibration H(T) following:

5.  The full equation for calculating the concentration of gas<sub>i</sub> dissolved in the original water is:

<!-- ****** Acknowledgements ****** -->
Credits & Acknowledgements
--------------------------

<!-- HTML tags to produce image, resize, add hyperlink. -->
<!-- ONLY WORKS WITH HTML or GITHUB documents -->
<a href="http://www.neonscience.org/"> <img src="logo.png" width="300px" /> </a>

<!-- Acknowledgements text -->
The National Ecological Observatory Network is a project solely funded by the National Science Foundation and managed under cooperative agreement by Battelle. Any opinions, findings, and conclusions or recommendations expressed in this material are those of the author(s) and do not necessarily reflect the views of the National Science Foundation.

<!-- ****** License ****** -->
License
-------

GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007

<!-- ****** Disclaimer ****** -->
Disclaimer
----------

*Information and documents contained within this pachage are available as-is. Codes or documents, or their use, may not be supported or maintained under any program or service and may not be compatible with data currently available from the NEON Data Portal.*
