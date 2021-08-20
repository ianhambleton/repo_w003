** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-500-diabetes-stats.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Preparing Diabetes mortality and DALY statistics

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
    log using "`logpath'\chap2-500-diabetes-stats", replace
** HEADER -----------------------------------------------------


** Load primary deaths dataset
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
** Restrict to Americas ONLY
keep if region==2000 & sex==3
keep dths year ghecause 
reshape wide dths , i(year) j(ghecause)

** CODES
**    31  "Diabetes"

** DIABETES as percentage of all deaths
gen p31 = (dths31/dths100)*100

**-----------------------------------------------------------
** Diabetes (31)
**-----------------------------------------------------------
** Mortality rates by sex
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
rename mortr arate 
keep if ghecause == 31 & region==2000
drop  ghecause paho_subregion pop_mortr
** 1=men 2=women 3=both
reshape wide arate dths, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = dths1 - dths2 
order year dths* ddiff arate* 
format dths1 %12.1fc
format dths2 %12.1fc
format dths3 %12.1fc
format ddiff %12.1fc

** DALY rates by sex
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
rename dalyr arate
keep if ghecause == 31 & region==2000
drop  ghecause paho_subregion pop_dalyr
** 1=men 2=women 3=both
reshape wide arate daly, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = daly1 - daly2 
order year daly* ddiff arate* 
format daly1 %12.1fc
format daly2 %12.1fc
format daly3 %12.1fc
format ddiff %12.1fc




**-----------------------------------------------------------
** Diabetes (31)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
rename dalyr arate 
keep if ghecause == 31 & region==2000
drop  ghecause paho_subregion pop_dalyr
rename arate drate
tempfile daly 
save `daly', replace
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
rename mortr arate 
keep if ghecause == 31 & region==2000
drop  ghecause paho_subregion pop_mortr
rename arate mrate
merge 1:1 year sex using `daly'
drop _merge
** 1=men 2=women 3=both
reshape wide mrate drate dths daly, i(year) j(sex)
order year mrate* drate* dths* daly* 
** Restrict to 2000 and 2019, and reshape to wide
** drop daly* dths* 
keep if year==2000 | year==2019
gen k=1
reshape wide dths1 dths2 dths3 daly1 daly2 daly3 mrate1 mrate2 mrate3 drate1 drate2 drate3, i(k) j(year)
order k mrate1* mrate2* mrate3* drate1* drate2* drate3* dths1* dths2* dths3* daly1* daly2* daly3*
** percentage improvement
gen mperc1 = ((mrate12019 - mrate12000)/mrate12000) * 100
gen mperc2 = ((mrate22019 - mrate22000)/mrate22000) * 100
gen mperc3 = ((mrate32019 - mrate32000)/mrate32000) * 100
gen dperc1 = ((drate12019 - drate12000)/drate12000) * 100
gen dperc2 = ((drate22019 - drate22000)/drate22000) * 100
gen dperc3 = ((drate32019 - drate32000)/drate32000) * 100
format mperc1 mperc2 mperc3 dperc1 dperc2 dperc3 %9.1f
** death excess (women and men combined)
gen dth_excess = dths12019-dths22019
gen daly_excess = daly12019-daly22019
format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc


