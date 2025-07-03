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
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data\2025"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs\2025"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs\2025"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap2-000z-final-prep", replace
** HEADER -----------------------------------------------------


** -----------------------------------------------------------------------------
** DATASET 01 - Age standardized rates (Mortality + DALY)
** -----------------------------------------------------------------------------
** Import dataset created in --> paper2-2025-004-rate-prep
** Importing --> "`datapath'\ghe-2021-death-daly-rate-002"
** This will be our main dataset. But does not include age-stratification
** CONTAINS
** All causes               (ghecause: 1) 
** Communicable             (ghecause: 2) 
** NCDs                     (ghecause: 3) 
** Injuries                 (ghecause: 4)
**  Unintentional Injuries  (ghecause: 5)
**  Intentional Injuries    (ghecause: 6)
** Injury groups
**                          (ghecause  7. road injury)
**                          (ghecause  8. poisonings)
**                          (ghecause  9. falls)
**                          (ghecause 10. fire and heat)
**                          (ghecause 11. drowning)
**                          (ghecause 12. mechanical forces)
**                          (ghecause 13. natural disasters)
**                          (ghecause 14. self harm)
**                          (ghecause 15. interpersonal violence)
**                          (ghecause 16. collective violence)
** REGIONS 
** AMERICAS                 (region: 44)
** North America            (region: 36)
** Central Americas         (region: 37)
** Andean                   (region: 38)
** Southern Cone            (region: 39)
** Latin Caribbean          (region: 40)
** non Latin Caribbean      (region: 41)
** Brazil                   (region: 6 / 42)
** Mexico                   (region: 23 / 43)
** COUNTRY LEVEL CODES
**        1. Antigua and Barbuda 
**        2. Argentina 
**        3. Bahamas 
**        4. Barbados 
**        5. Bolivia, Plurinational State of 
**        6. Brazil 
**        7. Belize 
**        8. Canada 
**        9. Chile 
**        10. Colombia 
**        11. Costa Rica 
**        12. Cuba 
**        13. Dominica 
**        14. Dominican Republic 
**        15. Ecuador 
**        16. El Salvador 
**        17. Grenada 
**        18. Guatemala 
**        19. Guyana 
**        20. Haiti 
**        21. Honduras 
**        22. Jamaica 
**        23. Mexico 
**        24. Nicaragua 
**        25. Panama 
**        26. Paraguay 
**        27. Peru 
**        28. Saint Kitts and Nevis 
**        29. Saint Lucia 
**        30. Saint Vincent and the Grenadines 
**        31. Suriname 
**        32. Trinidad and Tobago 
**        33. United States of America 
**        34. Uruguay 
**        35. Venezuela, Bolivarian Republic of 
**
** SEX                      (men 1, women 2, both 3)
** -----------------------------------------------------------------------------
use "`datapath'\ghe-2021-death-daly-rate-002", clear
** Variable labelling 
label var ghecause "Grouped cause of mortality / DALYs"
label var region "Unique label for country/sub-region/region (1-44)"
label var paho_subregion " PAHO-defined subregions of the Americas"
label var daly "Estimated count, yrs of illness"
label var dalyr "Estimated DALY rate per 100,000"
label var pop_dalyr "Estimated national population"
label var dths "Estimated count, deaths"
label var mortr "Estimated mortality rate per 100,000"
label var pop_mortr "Estimated national population"

label data "GHE 2000-2021: Mortality and DALY, by sex, country, subregion, region" 
save "`datapath'\dataset01", replace


** -----------------------------------------------------------------------------
** DATASET 02
** -----------------------------------------------------------------------------
** Created in --> paper2-2025-002-deathrate
** DEATH --> "`datapath'\ghe-2021-death-byage", replace
**
** Created in --> paper2-2025-003-dalyrate
** DALYs --> "`datapath'\ghe-2021-daly-byage", replace
**
** These datasets allow us to create age-stratified figures for the Americas as a region

** Deaths 
use "`datapath'\ghe-2021-death-byage", clear
    drop country un_subregion amro 
    sort year ghecause un_region sex agroup age18  
    order year ghecause un_region sex agroup age18  
    rename value dths 
    label var dths "Estimated count, deaths"
    tempfile deaths
    save `deaths', replace

** Disease burden: DALYs (INJURY GROUPS)
use "`datapath'\ghe-2021-daly-byage", clear
    drop country un_subregion amro 
    sort year ghecause un_region sex agroup age18  
    order year ghecause un_region sex agroup age18  
    rename value daly 
    label var daly "Estimated count, yrs of illness"
    tempfile dalys
    save `dalys', replace

** Collapse to region-level 

** Merge deaths and DALYs
use `deaths', replace
merge 1:1 year ghecause iso3n un_region paho_subregion sex agroup age18 using `dalys'
** drop _merge

** Collapse to broad age groups from 18 5-year age groups
** We use this in Figure 2 and Supplement Table 11
** For which we only need the sumamry data for the Americas
preserve
    keep if iso3n==2000
    collapse (sum) dths daly pop , by(year ghecause un_region sex agroup)
    format daly dths pop %19.1fc 

    ** Save age-stratified dataset for Americas region
    label data "GHE Injuries 2000-2021: Mortality and DALY, by age, sex, cause for 35 countries in the Americas" 
    save "`datapath'\dataset02a", replace
restore 

** Dataset for Figures
    keep if iso3n==2000
    collapse (sum) dths daly pop , by(year ghecause un_region sex agroup)
    format daly dths pop %19.1fc 

    ** Save age-stratified dataset for Americas region
    label data "GHE Injuries 2000-2021: Mortality and DALY, by age, sex, cause for 35 countries in the Americas" 
    save "`datapath'\dataset02", replace
