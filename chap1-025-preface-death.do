** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-death-020-count-stats.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-Apr-2021
    //  algorithm task			    Associated statistics - number of deaths

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
    log using "`logpath'\chap1-death-010-count-stats", replace
** HEADER -----------------------------------------------------

** Loading COD dataset for world regions
** Limit to just the wide COD groups and save - as preparation for analytics

** ------------------------------------------------------------
** 10 Communicable, maternal, perinatal and nutritional conditions
** 600 Noncommunicable diseases
** 1510 Injuries
** ------------------------------------------------------------
tempfile afr amr emr eur sear wpr world

** Africa (AFR)
use "`datapath'\from-who\who-ghe-deaths-001-who1", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `afr' , replace

** Americas (AMR)
use "`datapath'\from-who\who-ghe-deaths-001-who2", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `amr' , replace

** Eastern Mediterranean (EMR)
use "`datapath'\from-who\who-ghe-deaths-001-who3", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `emr' , replace

** Europe (EUR)
use "`datapath'\from-who\who-ghe-deaths-001-who4", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `eur' , replace

** South-East Asia (SEAR)
use "`datapath'\from-who\who-ghe-deaths-001-who5", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `sear' , replace

** Western Pacific (WPR)
use "`datapath'\from-who\who-ghe-deaths-001-who6", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    ** Collapse AGE ut of dataset 
    collapse (sum) dths dths_low dths_up pop, by(ghecause year who_region)
    save `wpr' , replace

** GLOBAL
use `afr', clear 
    append using `amr'
    append using `emr'
    append using `eur'
    append using `sear'
    append using `wpr'
    collapse (sum) dths dths_low dths_up pop, by(ghecause year)
    save `world' , replace

** Join the WHO regions
use `afr', clear 
    append using `amr'
    append using `emr'
    append using `eur'
    append using `sear'
    append using `wpr'
    save "`datapath'\from-who\chap1_deaths_001", replace

** Reshape to wide, to have individual variables for each WHO region
drop dths_low dths_up
reshape wide dths pop , i(ghecause year) j(who_region) 
rename dths1 afr_d
rename pop1 afr_p
rename dths2 amr_d
rename pop2 amr_p
rename dths3 emr_d
rename pop3 emr_p
rename dths4 eur_d
rename pop4 eur_p
rename dths5 sear_d
rename pop5 sear_p
rename dths6 wpr_d
rename pop6 wpr_p

egen global_d = rowtotal(afr_d amr_d emr_d eur_d sear_d wpr_d)
egen global_p = rowtotal(afr_p amr_p emr_p eur_p sear_p wpr_p)
format global_d %15.0fc
format global_p %15.0fc
gen afr_perc = (afr_d / global_d) * 100
gen amr_perc = (amr_d / global_d) * 100
gen emr_perc = (emr_d / global_d) * 100
gen eur_perc = (eur_d / global_d) * 100
gen sear_perc = (sear_d / global_d) * 100
gen wpr_perc = (wpr_d / global_d) * 100
note sear_perc: peak in 2004 due to Indian ocean earthquake and tsunami
note amr_perc: peak in 2010 due to 2010 Haiti earthquake

foreach x in afr amr emr eur sear wpr {
    format `x'_p %15.0fc
    format `x'_d %15.0fc
}

** Save a copy of the data for later - when looking at % deaths by broad cause-of-death 
tempfile cod
save `cod' , replace 

** Global deaths in 2000 and 2019 
preserve
    keep if year==2000 | year==2019 
    collapse (sum) global_d, by(year)
    list year global_d
restore


** Save a copy of the data for later - when looking at % deaths by broad cause-of-death 
tempfile cod
save `cod' , replace 

** Global deaths in 2000 and 2019 
preserve
    keep if year==2000 | year==2019 
    collapse (sum) global_d, by(year)
    list year global_d
restore


** Percentage increase in population size by WHO region between 2000 and 2019
preserve
    sort ghecause year
    by ghecause : gen run = _n    
    foreach var in afr amr emr eur sear wpr global {
        order run , after(ghecause) 
        gen `var'_g1 = `var'_p if run == 1
        egen `var'_g2 = min(`var'_g1) 
        gen `var'_g = (`var'_p / `var'_g2) * 100
        order `var'_g1 `var'_g2 `var'_g , after(`var'_p) 
        format `var'_g1 `var'_g2 `var'_g %15.0fc
        drop `var'_g1 `var'_g2
    }
    ** Population growth (between 2000 and 2020)
    set linesize 120
    list year afr_p afr_g amr_p amr_g emr_p emr_g if ghecause==10 & (year==2000 | year==2005 | year==2010 | year==2015 | year==2019)
    list year eur_p eur_g sear_p sear_g wpr_p wpr_g global_p global_g if ghecause==10 & (year==2000 | year==2005 | year==2010 | year==2015 | year==2019)
restore

** Percentage increase in deaths by WHO region between 2000 and 2019
drop *_p
collapse (sum) *_d , by(year)
sort year
    gen run = _n    
    foreach var in afr amr emr eur sear wpr global {
        order run , after(year) 
        gen `var'_g1 = `var'_d if run == 1
        egen `var'_g2 = min(`var'_g1) 
        gen `var'_g = (`var'_d / `var'_g2) * 100
        replace `var'_g = `var'_g - 100 
        order `var'_g1 `var'_g2 `var'_g , after(`var'_d) 
        format `var'_g1 `var'_g2 `var'_g %15.0fc
        drop `var'_g1 `var'_g2
    }
    ** Change in number of deaths (between 2000 and 2020)
    set linesize 120
    list year afr_d afr_g amr_d amr_g emr_d emr_g if (year==2000 | year==2005 | year==2010 | year==2015 | year==2019)
    list year eur_d eur_g sear_d sear_g wpr_d wpr_g global_d global_g  if (year==2000 | year==2005 | year==2010 | year==2015 | year==2019)


** POPULATION SIZE in 2000 and 2020 (PAHO subregions)
** Americas (AMR)
use "`datapath'\from-who\who-ghe-deaths-001-who2", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    keep if ghecause==10
    keep if year==2000 | year==2019
    drop dths dths_low dths_up
    ** Collapse AGE ut of dataset 
    collapse (sum) pop, by(year who_region paho_subregion)
    sort paho_subregion year
    by paho_subregion: gen run = _n    
    order run , after(paho_subregion)
    gen diff = pop - pop[_n-1] if paho_subregion==paho_subregion[_n-1]
    gen diffp = (diff/pop[_n-1]) * 100
    gen diffp1 = ((pop/pop[_n-1]) * 100)  if paho_subregion==paho_subregion[_n-1]
    format pop %15.0fc
    tabdisp paho_subregion year, c(pop) format(%15.0fc)
    tabdisp paho_subregion year, c(diffp1) format(%15.0fc)

** DEATHS SIZE in 2000 and 2020 (PAHO subregions)
** Americas (AMR)
use "`datapath'\from-who\who-ghe-deaths-001-who2", replace
    keep if ghecause==10 | ghecause==600 | ghecause==1510
    drop if age<0 
    keep if year==2000 | year==2019
    drop pop dths_low dths_up
    ** Collapse AGE ut of dataset 
    collapse (sum) dths, by(year who_region paho_subregion)
    sort paho_subregion year
    by paho_subregion: gen run = _n    
    order run , after(paho_subregion)
    gen diff = dths - dths[_n-1] if paho_subregion==paho_subregion[_n-1]
    gen diffp = (diff/dths[_n-1]) * 100
    gen diffp1 = ((dths/dths[_n-1]) * 100)  if paho_subregion==paho_subregion[_n-1]
    format dths %15.0fc
    tabdisp paho_subregion year, c(dths) format(%15.0fc)
    tabdisp paho_subregion year, c(diffp1) format(%15.0fc)

** Percentage change on COD by region
use `cod' , clear
keep ghecause year *_d
keep if year==2000 | year==2019 
reshape wide *_d , i(ghecause) j(year) 
foreach var in afr_d2000 amr_d2000 emr_d2000 eur_d2000 sear_d2000 wpr_d2000 global_d2000 afr_d2019 amr_d2019 emr_d2019 eur_d2019 sear_d2019 wpr_d2019 global_d2019 {
    egen `var's = sum(`var')
    gen `var'p = (`var' / `var's) * 100
    }
keep ghecause *p
order ghecause afr* amr* emr* eur* sear* wpr* global* 
set linesize 150 
list ghecause global* afr* amr*
list ghecause emr* eur*
list ghecause sear* wpr*


** Numbers of communicable disease deaths in ALL world regions
use `cod' , clear
keep ghecause year *_d
keep if year==2000 | year==2019 
reshape wide *_d , i(ghecause) j(year) 
egen sum1a = rowtotal(afr_d2000 sear_d2000)
egen sum1b = rowtotal(amr_d2000 emr_d2000 eur_d2000 wpr_d2000)
egen sum2a = rowtotal(afr_d2019 sear_d2019)
egen sum2b = rowtotal(amr_d2019 emr_d2019 eur_d2019 wpr_d2019)
format sum* %15.0fc
gen ratio1 = sum1a/sum1b
gen ratio2 = sum2a/sum2b
