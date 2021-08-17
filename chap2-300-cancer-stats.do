** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-200-cvd-stats.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Preparing CVD mortality rates: PAHO-subregions in the Americas

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
    log using "`logpath'\chap2-200-cvd-stats", replace
** HEADER -----------------------------------------------------

** Use data from Cancer Table (chap2-310-cancer-table)
tempfile death daly 

** DALYs
use "`datapath'\from-who\chap2_cancer_table2", clear
rename crate daly_crate
rename arate daly_arate 
keep if region==2000
drop _merge 
save `daly' , replace 

** DEATHS 
use "`datapath'\from-who\chap2_cancer_table1", clear
rename crate death_crate
rename arate death_arate 
keep if region==2000
drop _merge
save `death' , replace 

** MERGE 
use `death'
merge 1:1 region cod year sex using `daly'
drop dths_exist daly_exist arate_new paho_subregion pop_new _merge

** Add population for the Americas
preserve
    keep if cod==10 & region==2000
    keep cod year sex pop_dths pop_daly
    replace cod=11 
    tempfile allcause_pop allcause_pop1
    save `allcause_pop' , replace
    replace cod=12
    append using `allcause_pop' 
    save `allcause_pop1' , replace
restore
merge 1:1 cod year sex using `allcause_pop1' , replace update
drop _merge

**------------------------------------------------
** BEGIN STATISTICS FOR TEXT
** to accompany the CANCER METRICS TABLE
** 1 "trachea/lung" 
** 2 "breast" 
** 3 "prostate" 
** 4 "colon/rectum" 
** 5 "cervix uteri" 
** 6 "pancreas"
** 7 "lymphomas/myeloma"
** 8 "stomach"
** 9 "liver"
** 10 "leukemia"
** 11 "all cancers"
** 12 "all cause", modif    
** -----------------------------------------------

** Collapse
collapse (sum) dths, by(year cod)
reshape wide dths , i(year) j(cod)
forval x = 1(1)12 {
    format dths`x' %15.1fc
}
** CVD as percentage of all deaths
gen p1100 = (dths11/dths12)*100
/*
** Ischaemic as percentage of CVD and all-deaths
gen p1130a = (dths1130/dths0)*100
gen p1130b = (dths1130/dths1100)*100

** Stroke as percentage of CVD and all-deaths
gen p1140a = (dths1140/dths0)*100
gen p1140b = (dths1140/dths1100)*100

** Hypertensive as percentage of CVD and all-deaths
gen p1120a = (dths1120/dths0)*100
gen p1120b = (dths1120/dths1100)*100

** Cardiomyopathy as percentage of CVD and all-deaths
gen p1150a = (dths1150/dths0)*100
gen p1150b = (dths1150/dths1100)*100

** Rheumatic as percentage of CVD and all-deaths
gen p1110a = (dths1110/dths0)*100
gen p1110b = (dths1110/dths1100)*100





** IHD 
** Mortality rates by sex
use "`datapath'\from-who\chap2_cvd_mr", clear
keep if ghecause == 1130 & region==2000
drop crate aupp alow ase pop region ghecause
replace arate = arate * 100000
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

** STROKE 
** Mortality rates by sex
use "`datapath'\from-who\chap2_cvd_mr", clear
keep if ghecause == 1140 & region==2000
drop crate aupp alow ase pop region ghecause
replace arate = arate * 100000
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

** STROKE 
** DALY rates by sex
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1140 & region==2000
drop crate aupp alow ase pop dths region ghecause
replace arate = arate * 100000
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

** HYPERTENSIVE HEART DISEASE 
** Mortality rates by sex
use "`datapath'\from-who\chap2_cvd_mr", clear
keep if ghecause == 1120 & region==2000
drop crate aupp alow ase pop region ghecause
replace arate = arate * 100000
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

** HYPERTENSIVE HEART DISEASE 
** DALY rates by sex
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1120 & region==2000
drop crate aupp alow ase pop dths region ghecause
replace arate = arate * 100000
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



** CARDIOMYOPATHY etc
** Mortality rates by sex
use "`datapath'\from-who\chap2_cvd_mr", clear
keep if ghecause == 1150 & region==2000
drop crate aupp alow ase pop region ghecause
replace arate = arate * 100000
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

** CARDIOMYOPATHY etc
** DALY rates by sex
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1150 & region==2000
drop crate aupp alow ase pop dths region ghecause
replace arate = arate * 100000
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


** RHD
** Mortality rates by sex
use "`datapath'\from-who\chap2_cvd_mr", clear
keep if ghecause == 1110 & region==2000
drop crate aupp alow ase pop region ghecause
replace arate = arate * 100000
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
/*
** RHD
** DALY rates by sex
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1110 & region==2000
drop crate aupp alow ase pop dths region ghecause
replace arate = arate * 100000
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


/*

** DALY rate by sex
** All CVD 
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1100 & region==2000
drop crate aupp alow ase pop region ghecause
** replace arate = arate * 100000
** 1=men 2=women 3=both
replace arate = arate * 100000
reshape wide arate dths daly, i(year) j(sex)
order year arate* daly* dths*
** Restrict to 2000 and 2019, and reshape to wide
** drop daly* dths* 
keep if year==2000 | year==2019
gen k=1
reshape wide dths1 dths2 dths3 daly1 daly2 daly3 arate1 arate2 arate3 , i(k) j(year)
order k arate1* arate2* arate3* dths1* dths2* dths3* daly1* daly2* daly3*
** percentage improvement
gen perc1 = ((arate12019 - arate12000)/arate12000) * 100
gen perc2 = ((arate22019 - arate22000)/arate22000) * 100
gen perc3 = ((arate32019 - arate32000)/arate32000) * 100
format perc1 perc2 perc3 %9.1f
** death excess (women and men combined)
gen dth_excess = dths12019-dths22019
gen daly_excess = daly12019-daly22019
format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc



** DALY rate by sex
** IHD 
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1130 & region==2000
drop crate aupp alow ase pop region ghecause
** replace arate = arate * 100000
** 1=men 2=women 3=both
replace arate = arate * 100000
reshape wide arate dths daly, i(year) j(sex)
order year arate* daly* dths*
** Restrict to 2000 and 2019, and reshape to wide
** drop daly* dths* 
keep if year==2000 | year==2019
gen k=1
reshape wide dths1 dths2 dths3 daly1 daly2 daly3 arate1 arate2 arate3 , i(k) j(year)
order k arate1* arate2* arate3* dths1* dths2* dths3* daly1* daly2* daly3*
** percentage improvement
gen perc1 = ((arate12019 - arate12000)/arate12000) * 100
gen perc2 = ((arate22019 - arate22000)/arate22000) * 100
gen perc3 = ((arate32019 - arate32000)/arate32000) * 100
format perc1 perc2 perc3 %9.1f
** death excess (women and men combined)
gen dth_excess = dths12019-dths22019
gen daly_excess = daly12019-daly22019
format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc




** DALY rate by sex
** STROKE 
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1140 & region==2000
drop crate aupp alow ase pop region ghecause
** replace arate = arate * 100000
** 1=men 2=women 3=both
replace arate = arate * 100000
reshape wide arate dths daly, i(year) j(sex)
order year arate* daly* dths*
** Restrict to 2000 and 2019, and reshape to wide
** drop daly* dths* 
keep if year==2000 | year==2019
gen k=1
reshape wide dths1 dths2 dths3 daly1 daly2 daly3 arate1 arate2 arate3 , i(k) j(year)
order k arate1* arate2* arate3* dths1* dths2* dths3* daly1* daly2* daly3*
** percentage improvement
gen perc1 = ((arate12019 - arate12000)/arate12000) * 100
gen perc2 = ((arate22019 - arate22000)/arate22000) * 100
gen perc3 = ((arate32019 - arate32000)/arate32000) * 100
format perc1 perc2 perc3 %9.1f
** death excess (women and men combined)
gen dth_excess = dths12019-dths22019
gen daly_excess = daly12019-daly22019
format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc
