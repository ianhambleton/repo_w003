** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-2025-004-rate-prep.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	21-June-2024
    //  algorithm task			    Final rate datasets for general use

    ** General algorithm set-up
    version 18
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
    log using "`logpath'\paper2-2025-004-rate-prep", replace
** HEADER -----------------------------------------------------


** Mortality rate 
use "`datapath'\ghe-2021-death-rate-001", clear
** Update RATE to per 100,000
replace arate = arate * 100000 
gen arate_final = arate
rename cases dths
gen pop_final = pop
keep year sex ghecause region paho_subregion dths arate_final pop_final 
order year sex ghecause region paho_subregion dths arate_final pop_final 
rename arate_final mortr
rename pop_final pop_mortr
format pop_mortr %15.1fc
save "`datapath'\ghe-2021-death-rate-002", replace
tempfile t1
save `t1', replace

** DALY rate 
use "`datapath'\ghe-2021-daly-rate-001", clear
** Update RATE for sex-specific cancers
replace arate = arate * 100000 
gen arate_final = arate
rename cases daly
gen pop_final = pop
keep year sex ghecause region paho_subregion daly arate_final pop_final 
order year sex ghecause region paho_subregion daly arate_final pop_final 
rename arate_final dalyr
rename pop_final pop_dalyr
format pop_dalyr %15.1fc
save "`datapath'\ghe-2021-daly-rate-002", replace

** Join the two datasets
merge 1:1 year sex ghecause region using `t1' 
drop _merge
** WAS --> save "`datapath'\paper2-inj\paper2_chap2_000_adjusted", replace
save "`datapath'\ghe-2021-death-daly-rate-002", replace
