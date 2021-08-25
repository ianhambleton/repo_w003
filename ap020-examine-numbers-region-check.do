** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    ap020-examine-numbers-region-check.do
    //  project:				        WHO Global Health Estimates
    //  analysts:				        Ian HAMBLETON
    // 	date last modified	    2-April-2021
    //  algorithm task			    Further data preparation, and splitting of data into regional datasets

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
    log using "`logpath'\ap020-examine-numbers-region-check", replace
** HEADER -----------------------------------------------------

** AFRICA (WHO region 1)
use "`datapath'\from-who\who-ghe-deaths-001-who1", replace
keep if ghecause==0
keep if year==2000
drop if age<0
collapse (sum) dths pop, by(iso3c iso3n)
** Create text variable for country 
decode iso3n, gen(country) 
replace country = "South Sudan" if iso3c=="SSD"
sort country


** Eastern Mediterranean
use "`datapath'\from-who\who-ghe-deaths-001-who3", replace
keep if ghecause==0
keep if year==2000
drop if age<0
collapse (sum) dths pop, by(iso3c iso3n)
** Create text variable for country 
decode iso3n, gen(country) 
sort country

** Eastern Mediterranean
use "`datapath'\from-who\who-ghe-deaths-001-who2-allcauses", replace
bysort iso3n : gen un1 = _n 
gen un2 = 1 if un1==1
sort paho_subregion iso3n 
list iso3n paho_subregion if un2==1

