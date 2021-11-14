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
use "`datapath'\from-who\chap2_000_mr", clear
** Update RATE for sex-specific cancers
replace arate = arate * 100000 
replace arate_new = arate_new * 100000 
gen arate_final = arate
replace arate_final = arate_new if arate_new<. 
** Update POPULATION for sex-specific cancers
gen pop_final = pop_dths
replace pop_final = pop_new if pop_new<. 
keep year sex ghecause region paho_subregion dths arate_final pop_final 
order year sex ghecause region paho_subregion dths arate_final pop_final 
rename arate_final mortr
rename pop_final pop_mortr
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
gen pop_final = pop_daly
replace pop_final = pop_new if pop_new<. 
keep year sex ghecause region paho_subregion daly arate_final pop_final 
order year sex ghecause region paho_subregion daly arate_final pop_final 
rename arate_final dalyr
rename pop_final pop_dalyr
save "`datapath'\from-who\chap2_000_daly_adjusted", replace

** Join the two datasets
merge 1:1 year sex ghecause region using `t1' 
drop _merge
save "`datapath'\from-who\chap2_000_adjusted", replace




/*
** Proportion of all DALYs due to NCDs and external causes
keep if region==2000
keep if ghecause==100 | ghecause==200 | ghecause==300 | ghecause==1000
keep if sex==3
keep if year==2019
drop dalyr mortr pop_* 
reshape wide daly dths, i(sex) j(ghecause)
gen pdaly = ((daly300 + daly1000)/daly100)*100
gen pdths = ((dths300 + dths1000)/dths100)*100


/// ** Need to add iso3 back into this structure
/// tempfile t1 t2 t3 t4
/// use "`datapath'\from-who\who-ghe-deaths-001-who2-allcauses", replace
/// keep iso3c iso3n 
/// decode iso3n , gen(country)
/// drop iso3n 
/// bysort iso3c : gen runner = _n
/// mark use if runner==1
/// keep if use==1
/// drop runner use 
/// save `t1' , replace
/// 
/// ** Join mortality rate datast with iso3c codes 
/// ** This allows us to subsequently join the World Bank income groups
/// use "`datapath'\from-who\chap2_000_adjusted", clear
/// decode region , gen(country)
/// merge m:1 country using `t1'
/// drop _merge
/// save `t2' , replace
