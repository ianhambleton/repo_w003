** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-000z-final-prep.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	19-August-2021
    //  algorithm task			    Final datasets for general use

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
    log using "`logpath'\chap2-000z-final-prep", replace
** HEADER -----------------------------------------------------



** -----------------------------------------------------------------------------
** DATASET 01
** -----------------------------------------------------------------------------
** Created in --> paper2-chap2-000z-final-prep
** This will be our main dataset. But does not include age-stratification
** CONTAINS
** Injuries                 (ghecause: 1000)
**  Unintentional Injuries  (ghecause: 1100)
**  Intentional Injuries    (ghecause: 1200)
** Region                   (region: 2000)
** Subregions               (region: 100-800 for the 8 PAHO subregions)
** Countries                (region: 1-33 for the 33 included countries in the Americas)
** Injury groups
**                          (ghecause 48. road injury)
**                          (ghecause 49. poisonings)
**                          (ghecause 50. falls)
**                          (ghecause 51. fire and heat)
**                          (ghecause 52. drowning)
**                          (ghecause 53. mechanical forces)
**                          (ghecause 54. natural disasters)
**                          (ghecause 55. self harm)
**                          (ghecause 56. interpersonal violence)
**                          (ghecause 57. collective violence)
** Sex                      (men 1, women 2, both 3)
** -----------------------------------------------------------------------------
use "`datapath'\paper2-inj\paper2_chap2_000_adjusted", clear
label data "GHE Injuries 2000-2019: Mortality and DALY, by sex, country, subregion, region" 
save "`datapath'\paper2-inj\dataset01", replace


** -----------------------------------------------------------------------------
** DATASET 02
** -----------------------------------------------------------------------------
** Created in --> paper2-chap2-000a-mr-region-groups / paper2-chap2-000a-daly-region-groups 
** These datasets allow us to create age-stratified figures for the Americas as a region

** Deaths
use "`datapath'\paper2-inj\paper2_deaths_groups_byage_bysex", clear
    append using "`datapath'\paper2-inj\paper2_deaths_groups_byage"
    replace sex = 3 if sex==.
    label define sex_ 1 "men" 2 "women" 3 "both",modify
    label values sex sex_ 
    sort year ghecause who_region sex agroup age18  
    tempfile deaths
    save `deaths', replace

** Disease burden: DALYs
use "`datapath'\paper2-inj\paper2_daly_groups_byage_bysex", clear
    append using "`datapath'\paper2-inj\paper2_daly_groups_byage"
    replace sex = 3 if sex==.
    label define sex_ 1 "men" 2 "women" 3 "both",modify
    label values sex sex_ 
    sort year ghecause who_region sex agroup age18  
    tempfile dalys
    save `dalys', replace

** Merge deaths and DALYs
use `deaths', replace
merge 1:1 year ghecause who_region sex agroup age18 using `dalys'
drop _merge

** Labelling
#delimit ;
label define who_region_    1 "africa"
                        2 "americas"
                        3 "eastern mediterranean"
                        4 "europe" 
                        5 "south-east asia"
                        6 "western pacific"
                        7 "world", modify; 
#delimit cr
label values who_region who_region_

** Collapse to broad age groups from 18 5-year age groups
collapse (sum) dths daly pop , by(ghecause who_region sex agroup)
format daly dths pop %19.1fc 

** Save age-stratified dataset for Americas region
label data "GHE Injuries 2000-2019: Mortality and DALY, by age, sex, cause, for Americas region" 
save "`datapath'\paper2-inj\dataset02", replace
