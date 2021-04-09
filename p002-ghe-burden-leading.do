** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			        p002-ghe-burden-leading.do
    //  project:				        WHO Global Health Estimates
    //  analysts:				        Ian HAMBLETON
    // 	date last modified	            2-April-2021
    //  algorithm task			        Further data preparation, and splitting of data into regional datasets

    ** General algorithm set-up
    version 16
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
    log using "`logpath'\p002-ghe-burden-leading", replace
** HEADER -----------------------------------------------------

** set segmentsize allocates memory for data in units of segmentsize. 
** Smaller values of segmentsize can result in more efficient use of available memory 
** but require Stata to jump around more. 
** Our largest output file is *africa.dta, which is approx 70 megabytes, 
** so I have changed the segmentsize to 100 megabytes.
set segmentsize 100m    // Default is 32m

** ************************************************************
** 1. SET UP Frame Structure
** We do this to break up the large WHO dataset
** for computational efficiency
** ************************************************************
frame create iso3 
frame create yll 
frame create yld 
frame create daly 
frame create deaths 

** UN regions frame
frame change iso3 
use "`datapath'\from-owid\regions", clear

** Want random sub-sample to test algorithm outputs:
**  use "`datapath'\from-who\who-ghe-yll-001", clear
**  sample 1 
**  save "`datapath'\from-who\who-ghe-yll-001-1p", replace
**
**  use "`datapath'\from-who\who-ghe-yld-001", clear
**  sample 1 
**  save "`datapath'\from-who\who-ghe-yld-001-1p", replace 


** **********************************************************
** 2.   Load the BURDEN metrics files (yll, yld, daly, dths). 
**      Restrict mortality categories 
**      and save external files: by METRIC and by UN-REGION
** **********************************************************
** foreach var in yll yld daly deaths { 
foreach var in daly { 
    frame change `var'
    use "`datapath'\from-who\who-ghe-`var'-001", clear

    ** restrict to WHO Americas (who_regions==2) 
    frame copy `var' `var'_who2 
    frame change `var'_who2 
    frlink m:1 iso3c, frame(iso3)
    keep if frval(iso3, who_region)==2 
    frget iso3n un_region un_subregion who_region paho_subregion, from(iso3)
    labmask ghecause, values(causename)
    drop causename
    label data "WHO GHE 2019: `var', WHO Americas, all years, All conditions"
    save "`datapath'\from-who\who-ghe-`var'-002-who2", replace
}

