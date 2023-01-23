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



** -----------------------------------
** MORTALITY COUNTS
** -----------------------------------

** REGIONAL. SEX-SPECIFIC
use  "`datapath'\from-who\deaths1", replace
    merge 1:1 year sex ghecause age18 using "`datapath'\from-who\deaths1_lo"
    drop _merge
    merge 1:1 year sex ghecause age18 using "`datapath'\from-who\deaths1_hi"
    order dths dths_lo dths_hi, after(pop)
    drop _merge
    save "`datapath'\from-who\deaths1_ci", replace
    
** REGIONAL. SEX-COMBINED
use  "`datapath'\from-who\deaths2", replace
    merge 1:1 year ghecause age18 using "`datapath'\from-who\deaths2_lo"
    drop _merge
    merge 1:1 year ghecause age18 using "`datapath'\from-who\deaths2_hi"
    order dths dths_lo dths_hi, after(pop)
    drop _merge
    save "`datapath'\from-who\deaths2_ci", replace
/*
** COUNTRY. SEX-SPECIFIC
use  "`datapath'\from-who\deaths3", replace
    merge 1:1 year sex ghecause iso3n age18 using "`datapath'\from-who\deaths3_lo"
    drop _merge
    merge 1:1 year sex ghecause iso3n age18 using "`datapath'\from-who\deaths3_hi"
    order dths dths_lo dths_hi, after(pop)
    drop _merge
    save "`datapath'\from-who\deaths3_ci", replace
    
** COUNTRY. SEX-COMBINED
use  "`datapath'\from-who\deaths4", replace
    merge 1:1 year ghecause iso3n age18 using "`datapath'\from-who\deaths4_lo"
    drop _merge
    merge 1:1 year ghecause iso3n age18 using "`datapath'\from-who\deaths4_hi"
    order dths dths_lo dths_hi, after(pop)
    drop _merge
    save "`datapath'\from-who\deaths4_ci", replace




** -----------------------------------
** DALY COUNTS
** -----------------------------------

** REGIONAL. SEX-SPECIFIC
use  "`datapath'\from-who\daly1", replace
    merge 1:1 year sex ghecause age18 using "`datapath'\from-who\daly1_lo"
    drop _merge
    merge 1:1 year sex ghecause age18 using "`datapath'\from-who\daly1_hi"
    order daly daly_lo daly_hi, after(pop)
    drop _merge
    save "`datapath'\from-who\daly1_ci", replace
    
** REGIONAL. SEX-COMBINED
use  "`datapath'\from-who\daly2", replace
    merge 1:1 year ghecause age18 using "`datapath'\from-who\daly2_lo"
    drop _merge
    merge 1:1 year ghecause age18 using "`datapath'\from-who\daly2_hi"
    order daly daly_lo daly_hi, after(pop)
    drop _merge
    save "`datapath'\from-who\daly2_ci", replace

** COUNTRY. SEX-SPECIFIC
use  "`datapath'\from-who\daly3", replace
    merge 1:1 year sex ghecause iso3n age18 using "`datapath'\from-who\daly3_lo"
    drop _merge
    merge 1:1 year sex ghecause iso3n age18 using "`datapath'\from-who\daly3_hi"
    order daly daly_lo daly_hi, after(pop)
    drop _merge
    save "`datapath'\from-who\daly3_ci", replace
    
** COUNTRY. SEX-COMBINED
use  "`datapath'\from-who\daly4", replace
    merge 1:1 year ghecause iso3n age18 using "`datapath'\from-who\daly4_lo"
    drop _merge
    merge 1:1 year ghecause iso3n age18 using "`datapath'\from-who\daly4_hi"
    order daly daly_lo daly_hi, after(pop)
    drop _merge
    save "`datapath'\from-who\daly4_ci", replace




** -----------------------------------
** MORTALITY RATES
** -----------------------------------

** REGIONAL. SEX-SPECIFIC and SEX-COMBINED
use  "`datapath'\from-who\mortalityrate_12", replace
    merge 1:1 year sex ghecause using "`datapath'\from-who\mortalityrate_12_lo"
    drop _merge
    merge 1:1 year sex ghecause using "`datapath'\from-who\mortalityrate_12_hi"
    order cases cases_lo cases_hi crate crate_lo crate_hi arate arate_lo arate_hi, after(pop)
    drop _merge
    save "`datapath'\from-who\mortalityrate_12_ci", replace


** -----------------------------------
** DALY RATES
** -----------------------------------

** REGIONAL. SEX-SPECIFIC and SEX-COMBINED
use  "`datapath'\from-who\dalyrate_12", replace
    merge 1:1 year sex ghecause using "`datapath'\from-who\dalyrate_12_lo"
    drop _merge
    merge 1:1 year sex ghecause using "`datapath'\from-who\dalyrate_12_hi"
    order cases cases_lo cases_hi crate crate_lo crate_hi arate arate_lo arate_hi, after(pop)
    drop _merge
    save "`datapath'\from-who\dalyrate_12_ci", replace
