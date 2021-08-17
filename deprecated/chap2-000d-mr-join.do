** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-100d-mr-join.do
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
    log using "`logpath'\chap2-100d-mr-join", replace
** HEADER -----------------------------------------------------

tempfile region_f region_m subregion_f subregion_m country_f country_m  

** ----------------------------------------------------
** SAVE datasets for sex-specific cancers
**
**  14  Breast
**  15  Cervix uteri cancer
**  16  Corpus uteri cancer
**  17  Ovary cancer
**  18  Prostate
**  19  Testicular
** ----------------------------------------------------

** REGION
** Female cancers -> bring in the female rates
use "`datapath'\from-who\chap2_000a_mr_region", clear
    keep if sex==2 & (ghecause>=14 & ghecause<=17) 
    rename arate arate_new
    rename pop pop_new 
    keep arate_new pop_new year ghecause region
    save `region_f', replace
** Male cancer -> bring in the male rates
use "`datapath'\from-who\chap2_000a_mr_region", clear
    keep if sex==1 & (ghecause>=18 & ghecause<=19) 
    rename arate arate_new
    rename pop pop_new 
    keep arate_new pop_new year ghecause region
    save `region_m', replace

** SUBREGION
** Female cancers -> bring in the female rates
use "`datapath'\from-who\chap2_000b_mr_subregion", clear
    keep if sex==2 & (ghecause>=14 & ghecause<=17) 
    rename arate arate_new
    rename pop pop_new 
    keep arate_new pop_new year ghecause region
    save `subregion_f', replace
** Male cancer -> bring in the male rates
use "`datapath'\from-who\chap2_000b_mr_subregion", clear
    keep if sex==1 & (ghecause>=18 & ghecause<=19) 
    rename arate arate_new
    rename pop pop_new 
    keep arate_new pop_new year ghecause region
    save `subregion_m', replace

** COUNTRY
** Female cancers -> bring in the female rates
use "`datapath'\from-who\chap2_000c_mr_country", clear
    keep if sex==2 & (ghecause>=14 & ghecause<=17) 
    rename arate arate_new
    rename pop pop_new 
    keep arate_new pop_new year ghecause region
    save `country_f', replace
** Male cancer -> bring in the male rates
use "`datapath'\from-who\chap2_000c_mr_country", clear
    keep if sex==1 & (ghecause>=18 & ghecause<=19) 
    rename arate arate_new
    rename pop pop_new 
    keep arate_new pop_new year ghecause region
    save `country_m', replace


** REGION
** Replace selected cancers with sex-specific rates
use "`datapath'\from-who\chap2_000a_mr_region_both" , clear
merge 1:1 year ghecause region using `region_f'
drop _merge
merge 1:1 year ghecause region using `region_m' , update replace
drop _merge
save "`datapath'\from-who\chap2_000a_mr_region_both_updated" , replace

** SUBREGION
** Replace selected cancers with sex-specific rates
use "`datapath'\from-who\chap2_000b_mr_subregion_both" , clear
merge 1:1 year ghecause region using `subregion_f'
drop _merge
merge 1:1 year ghecause region using `subregion_m' , update replace
drop _merge
save "`datapath'\from-who\chap2_000b_mr_subregion_both_updated" , replace

** COUNTRY
** Replace selected cancers with sex-specific rates
use "`datapath'\from-who\chap2_000c_mr_country_both" , clear
merge 1:1 year ghecause region using `country_f'
drop _merge
merge 1:1 year ghecause region using `country_m' , update replace
drop _merge
save "`datapath'\from-who\chap2_000c_mr_country_both_updated" , replace


** DEATHS. Countries.
** Append PAHO sub-regions and append WHO regions
use          "`datapath'\from-who\chap2_000a_mr_region", clear
append using "`datapath'\from-who\chap2_000b_mr_subregion"
append using "`datapath'\from-who\chap2_000c_mr_country"
append using "`datapath'\from-who\chap2_000a_mr_region_both_updated"
append using "`datapath'\from-who\chap2_000b_mr_subregion_both_updated"
append using "`datapath'\from-who\chap2_000c_mr_country_both_updated"
sort year sex ghecause region
label define sex_ 1 "men" 2 "women" 3 "both" , modify
label values sex sex_ 
tempfile mr1 
save `mr1', replace 


** Merge the deaths dataset
tempfile d1 
use "`datapath'\from-who\chap2_000d_dths", clear
append using "`datapath'\from-who\chap2_000d_dths_both"
rename pop pop_dths 
label define sex_ 1 "men" 2 "women" 3 "both" , modify
label values sex sex_ 
keep year ghecause sex region paho_subregion dths pop_dths
sort year sex ghecause region 
merge 1:1 year sex ghecause region using `mr1' 

rename _merge dths_exist
recode dths_exist 3=1 2=0 
label define dths_exist_ 1 "yes" 0 "no"
label values dths_exist dths_exist_


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
order year sex ghecause region paho_subregion dths pop_dths dths_exist crate arate arate_new pop_new 
sort year sex ghecause region
keep year sex ghecause region paho_subregion dths pop_dths dths_exist crate arate arate_new pop_new 
label data "Crude and Adjusted mortality rates: Countries, PAHO sub-regions, WHO regions"
save "`datapath'\from-who\chap2_000_mr", replace
