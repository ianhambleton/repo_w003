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



** Mortality rate 
use "`datapath'\from-who\paper1-chap2_000_mr", clear
** Update RATE for sex-specific cancers
replace arate = arate * 100000 
** replace arate_new = arate_new * 100000 
** gen arate_final = arate
** replace arate_final = arate_new if arate_new<. 
** Update POPULATION for sex-specific cancers
/*rename cases dths
gen pop_final = pop
replace pop_final = pop_new if pop_new<. 
keep year sex ghecause region paho_subregion dths arate_final pop_final 
order year sex ghecause region paho_subregion dths arate_final pop_final 
rename arate_final mortr
rename pop_final pop_mortr
format pop_mortr %15.1fc
save "`datapath'\from-who\chap2_000_mr_adjusted", replace
tempfile t1
save `t1', replace

** DALY rate 
use "`datapath'\from-who\chap2_000_daly", clear
** Update RATE for sex-specific cancers
replace arate = arate * 100000 
replace arate_new = arate_new * 100000 
gen arate_final = arate
replace arate_final = arate_new if arate_new<. 
** Update POPULATION for sex-specific cancers
rename cases daly
gen pop_final = pop
replace pop_final = pop_new if pop_new<. 
keep year sex ghecause region paho_subregion daly arate_final pop_final 
order year sex ghecause region paho_subregion daly arate_final pop_final 
rename arate_final dalyr
rename pop_final pop_dalyr
format pop_dalyr %15.1fc
save "`datapath'\from-who\chap2_000_daly_adjusted", replace

** Join the two datasets
merge 1:1 year sex ghecause region using `t1' 
drop _merge
save "`datapath'\from-who\chap2_000_adjusted", replace



