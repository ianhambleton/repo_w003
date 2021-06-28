** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-cvd-join.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Preparing CVD mortality rates: Countries of the Americas

    ** General algorithm set-up
    version 17
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DATASETS to encrypted SharePoint folder
    local datapath "X:\OneDrive - The University of the West Indies\Writing\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:\OneDrive - The University of the West Indies\Writing\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "X:\OneDrive - The University of the West Indies\Writing\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap2-cvd-join", replace
** HEADER -----------------------------------------------------

** DEATHS. Countries.
** Append PAHO sub-regions and append WHO regions
use "`datapath'\from-who\chap2_cvd_003", clear
append using "`datapath'\from-who\chap2_cvd_002"
append using "`datapath'\from-who\chap2_cvd_001"
append using "`datapath'\from-who\chap2_cvd_001_both"
append using "`datapath'\from-who\chap2_cvd_002_both"
append using "`datapath'\from-who\chap2_cvd_003_both"
sort year sex ghecause region
label define sex_ 1 "men" 2 "women" 3 "both" , modify
label values sex sex_ 
tempfile mr1 
save `mr1', replace 

** Merge the deaths dataset
tempfile d1 
use "`datapath'\from-who\chap2_cvd_dths", clear
append using "`datapath'\from-who\chap2_cvd_dths_both"

label define sex_ 1 "men" 2 "women" 3 "both" , modify
label values sex sex_ 
keep dths year sex ghecause region 
sort year sex ghecause region 
merge 1:1 year sex ghecause region using `mr1' 
drop _merge 

** Region labelling
#delimit ; 
label define region_   
                    1 "Antigua and Barbuda"
                    2 "Argentina"
                    3 "Bahamas"
                    4 "Barbados"
                    5 "Bolivia"
                    6 "Brazil"
                    7 "Belize"
                    8 "Canada"
                    9 "Chile"
                    10 "Colombia"
                    11 "Costa Rica"
                    12 "Cuba"
                    13 "Dominican Republic"
                    14 "Ecuador"
                    15 "El Salvador"
                    16 "Grenada"
                    17 "Guatemala"
                    18 "Guyana"
                    19 "Haiti"
                    20 "Honduras"
                    21 "Jamaica"
                    22 "Mexico"
                    23 "Nicaragua"
                    24 "Panama"
                    25 "Paraguay"
                    26 "Peru"
                    27 "Saint Lucia"
                    28 "Saint Vincent and the Grenadines"
                    29 "Suriname"
                    30 "Trinidad and Tobago"
                    31 "United States"
                    32 "Uruguay"
                    33 "Venezuela"
                    
                    100 "north america"
                    200 "southern cone"
                    300 "central america"
                    400 "andean" 
                    500 "latin caribbean"
                    600 "non-latin caribbean"
                    700 "brazil"
                    800 "mexico"

                    1000 "africa"
                    2000 "americas"
                    3000 "eastern mediterranean"
                    4000 "europe" 
                    5000 "south-east asia"
                    6000 "western pacific", modify;                      
#delimit cr 
label values region region_ 

** Save the JOINED Mortality Rate file
label data "Crude and Adjusted mortality rates: Countries, PAHO sub-regions, WHO regions"
save "`datapath'\from-who\chap2_cvd_mr", replace
