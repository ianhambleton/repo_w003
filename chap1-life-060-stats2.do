** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-life-060-stats2.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-Apr-2021
    //  algorithm task			    Chapter 1 - Life Expectancy

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
    log using "`logpath'\chap1-life-060-stats2", replace
** HEADER -----------------------------------------------------

** LIFE EXPECTANCY STATISTICS for CHAPTER ONE

** LOAD THE FULL LIFE TABLE DATASET 
use "`datapath'\from-who\lifetables\who-lifetable-2019-all", clear

** -----------------------------------
** SECTION 1.2 (a) 
** Life expectancy at birth 
** -----------------------------------
** BY major WHO region
** By year 
** WOMEN and MEN combined
#delimit ;
	tabdisp year region if 	sex==3
							& ghocode==35 
							& agroup==1
							& (region=="AFR"|region=="AMR"|region=="EMR"|region=="EUR"|region=="SEAR"|region=="WPR"|region=="GLOBAL")
							& country=="", 
							c(metric) format(%9.1f);
#delimit cr 
** WOMEN
#delimit ;
	tabdisp year region if 	sex==1
							& ghocode==35 
							& agroup==1
							& (region=="AFR"|region=="AMR"|region=="EMR"|region=="EUR"|region=="SEAR"|region=="WPR"|region=="GLOBAL")
							& country=="", 
							c(metric) format(%9.1f);
#delimit cr 
** MEN 
#delimit ;
	tabdisp year region if 	sex==2
							& ghocode==35 
							& agroup==1
							& (region=="AFR"|region=="AMR"|region=="EMR"|region=="EUR"|region=="SEAR"|region=="WPR"|region=="GLOBAL")
							& country=="", 
							c(metric) format(%9.1f);
#delimit cr 

** -----------------------------------
** SECTION 1.2 (a) 
** Annual LE increase 
** -----------------------------------
preserve
    keep if ghocode==35 & agroup==1 & country=="" 
    keep if year==2000 | year==2019 
    keep if region =="AFR" | region=="AMR" | region=="EMR" | region=="EUR" | region=="SEAR" | region=="WPR" | region=="GLOBAL" 
    reshape wide metric, i(sex region) j(year)
    gen achange = ((metric2019 - metric2000) / 19)
    gen wchange = ((metric2019 - metric2000) / 19) * 52.1429
    keep if sex==3 
    sort wchange
    tabdisp region sex, c(wchange) format(%9.1f)
restore

** -----------------------------------
** SECTION 1.2 (a) 
** GENDER GAP
** -----------------------------------
preserve
    keep if ghocode==35 & agroup==1 & country=="" & sex<3
    keep if year==2000 | year==2019 
    keep if region =="AFR" | region=="AMR" | region=="EMR" | region=="EUR" | region=="SEAR" | region=="WPR" | region=="GLOBAL" 
    reshape wide metric, i(year region) j(sex)
    gen sdif = metric1 - metric2
    sort region year 
    tabdisp region year, c(sdif) format(%9.1f)
restore

** -----------------------------------
** SECTION 1.2 (a) 
** Regional Healthy Life Expectancy 
** -----------------------------------
use "`datapath'\from-who\lifetables\who-lifetable-2019-all", clear
drop if country!=""
keep if ghocode==35 
keep if region =="AFR" | region=="AMR" | region=="EMR" | region=="EUR" | region=="SEAR" | region=="WPR" | region=="GLOBAL" 
append using "`datapath'\from-who\lifetables\who-hale-2019-regions"
label define ghocode_ 100 "hale",modify 
label values ghocode ghocode_ 
keep if agroup==1
keep if year==2000 | year==2019

reshape wide metric, i(sex region year) j(ghocode)
rename metric35 le 
rename metric100 hale
reshape wide le hale, i(sex region) j(year)
gen led = le2019 - le2000 
gen haled = hale2019 - hale2000 
tabdisp region sex, c(hale2019) format(%9.1f)
tabdisp region sex, c(led) format(%9.1f)
tabdisp region sex, c(haled) format(%9.1f)

gen illhealth = le2019 - hale2019
tabdisp region sex, c(illhealth) format(%9.1f)
gen illhealth_extra = led - haled 
tabdisp region sex, c(illhealth_extra) format(%9.1f)
gen illhealth_perc = ((le2019 - hale2019) / le2019) * 100
tabdisp region sex, c(illhealth_perc) format(%9.1f)


** -----------------------------------
** SECTION 1.2 (intro) 
** # people in the Americas over 70, 80, 90
** -----------------------------------
use "`datapath'\from-who\who-ghe-deaths-americas", clear
keep if ghecause==0
keep if year==2000 | year==2019
drop if age < 0

** Seventy+ indicator
preserve
    gen seventy = .
    replace seventy = 0 if age<=65
    replace seventy = 1 if age>=70
    label var seventy "70+ indicator"
    collapse (sum) pop, by(year sex seventy)
    tabdisp year sex seventy, cellvar(pop) format(%15.0fc)
    collapse (sum) pop, by(year seventy)
    tabdisp year seventy, cellvar(pop) format(%15.0fc)
restore

** Eighty+ indicator
gen eighty = .
replace eighty = 0 if age<=75
replace eighty = 1 if age>=80
label var eighty "80+ indicator"
collapse (sum) pop, by(year sex eighty)
tabdisp year sex eighty, cellvar(pop) format(%15.0fc)
collapse (sum) pop, by(year eighty)
tabdisp year eighty, cellvar(pop) format(%15.0fc)


** -----------------------------------
** SECTION 1.2 (b) 
** Life expectancy at 60 
** -----------------------------------

** LOAD THE FULL LIFE TABLE DATASET 
use "`datapath'\from-who\lifetables\who-lifetable-2019-all", clear

** BY major WHO region
** By year 
** WOMEN and MEN combined
#delimit ;
	tabdisp year region if 	sex==3
							& ghocode==35 
							& agroup==14
							& (region=="AFR"|region=="AMR"|region=="EMR"|region=="EUR"|region=="SEAR"|region=="WPR"|region=="GLOBAL")
							& country=="", 
							c(metric) format(%9.1f);
#delimit cr 
** WOMEN
#delimit ;
	tabdisp year region if 	sex==1
							& ghocode==35 
							& agroup==14
							& (region=="AFR"|region=="AMR"|region=="EMR"|region=="EUR"|region=="SEAR"|region=="WPR"|region=="GLOBAL")
							& country=="", 
							c(metric) format(%9.1f);
#delimit cr 
** MEN 
#delimit ;
	tabdisp year region if 	sex==2
							& ghocode==35 
							& agroup==14
							& (region=="AFR"|region=="AMR"|region=="EMR"|region=="EUR"|region=="SEAR"|region=="WPR"|region=="GLOBAL")
							& country=="", 
							c(metric) format(%9.1f);
#delimit cr 

** -----------------------------------
** SECTION 1.2 (b) 
** Annual LE increase 
** -----------------------------------
preserve
    keep if ghocode==35 & agroup==14 & country=="" 
    keep if year==2000 | year==2019 
    keep if region =="AFR" | region=="AMR" | region=="EMR" | region=="EUR" | region=="SEAR" | region=="WPR" | region=="GLOBAL" 
    reshape wide metric, i(sex region) j(year)
    gen achange = ((metric2019 - metric2000) / 19)
    gen wchange = ((metric2019 - metric2000) / 19) * 52.1429
    keep if sex==3 
    sort wchange
    tabdisp region sex, c(wchange) format(%9.1f)
restore

** -----------------------------------
** SECTION 1.2 (b) 
** GENDER GAP
** -----------------------------------
preserve
    keep if ghocode==35 & agroup==14 & country=="" & sex<3
    keep if year==2000 | year==2019 
    keep if region =="AFR" | region=="AMR" | region=="EMR" | region=="EUR" | region=="SEAR" | region=="WPR" | region=="GLOBAL" 
    reshape wide metric, i(year region) j(sex)
    gen sdif = metric1 - metric2
    sort region year 
    tabdisp region year, c(sdif) format(%9.1f)
restore

** -----------------------------------
** SECTION 1.2 (b) 
** Regional Healthy Life Expectancy 
** -----------------------------------
use "`datapath'\from-who\lifetables\who-lifetable-2019-all", clear
drop if country!=""
keep if ghocode==35 
keep if region =="AFR" | region=="AMR" | region=="EMR" | region=="EUR" | region=="SEAR" | region=="WPR" | region=="GLOBAL" 
append using "`datapath'\from-who\lifetables\who-hale-2019-regions"
label define ghocode_ 100 "hale",modify 
label values ghocode ghocode_ 
keep if agroup==14
keep if year==2000 | year==2019

reshape wide metric, i(sex region year) j(ghocode)
rename metric35 le 
rename metric100 hale
reshape wide le hale, i(sex region) j(year)
gen led = le2019 - le2000 
gen haled = hale2019 - hale2000 
tabdisp region sex, c(hale2019) format(%9.1f)
tabdisp region sex, c(led) format(%9.1f)
tabdisp region sex, c(haled) format(%9.1f)

gen illhealth = le2019 - hale2019
tabdisp region sex, c(illhealth) format(%9.1f)
gen illhealth_extra = led - haled 
tabdisp region sex, c(illhealth_extra) format(%9.1f)
gen illhealth_perc = ((le2019 - hale2019) / le2019) * 100
tabdisp region sex, c(illhealth_perc) format(%9.1f)

