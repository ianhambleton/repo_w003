** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    ap020-ghe-burden-byregion.do
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
    log using "`logpath'\ap020-ghe-burden-byregion", replace
** HEADER -----------------------------------------------------

** set segmentsize allocates memory for data in units of segmentsize. 
** Smaller values of segmentsize can result in more efficient use of available memory 
** but require Stata to jump around more. 
** Our largest output file is *africa.dta, which is approx 70 megabytes, 
** so I have changed the segmentsize to 100 megabytes.
set segmentsize 100m    // Default is 32m

** ************************************************************
** 1. SET UP Frame Structure
** We do this to break up the large WHO dataset
** for computational efficiency
** ************************************************************
frame create iso3 
frame create yll 
frame create yld 
frame create daly 
frame create deaths 

** UN regions frame
frame change iso3 
use "`datapath'\from-owid\regions", clear

** Want random sub-sample to test algorithm outputs:
**  use "`datapath'\from-who\who-ghe-yll-001", clear
**  sample 1 
**  save "`datapath'\from-who\who-ghe-yll-001-1p", replace
**
**  use "`datapath'\from-who\who-ghe-yld-001", clear
**  sample 1 
**  save "`datapath'\from-who\who-ghe-yld-001-1p", replace 


** **********************************************************
** 2.   Load the BURDEN metrics files (yll, yld, daly, dths). 
**      Restrict mortality categories 
**      and save external files: by METRIC and by UN-REGION
** **********************************************************
** foreach var in yll yld daly deaths { 
foreach var in deaths { 
    frame change `var'
    use "`datapath'\from-who\who-ghe-`var'-001", clear
    #delimit ;
    keep if ghecause==0  |       /// All causes
            ghecause==10 |       /// Communicable, maternal, perinatal, nutritional
            ghecause==600 |      /// Noncommunicable diseases
            ghecause==1510     /// Injuries
            ;
    #delimit cr

    ** restrict to UN Africa (iso3n==2) 
    frame copy `var' `var'_africa 
    frame change `var'_africa 
    frlink m:1 iso3c, frame(iso3)
    keep if frval(iso3, un_region)==2 
    frget iso3n un_region un_subregion who_region paho_subregion, from(iso3)
    labmask ghecause, values(causename)
    drop causename
    label data "WHO GHE 2019: `var', Africa, all years"
    save "`datapath'\from-who\who-ghe-`var'-001-africa", replace
}
/*

    ** restrict to UN Americas (iso3n==19) 
    frame copy `var' `var'_americas 
    frame change `var'_americas 
    frlink m:1 iso3c, frame(iso3)
    keep if frval(iso3, un_region)==19 
    frget iso3n un_region un_subregion who_region paho_subregion, from(iso3)
    labmask ghecause, values(causename)
    drop causename
    label data "WHO GHE 2019: `var', Americas, all years"
    save "`datapath'\from-who\who-ghe-`var'-001-americas", replace

    ** restrict to UN Asia (iso3n==142) 
    frame copy `var' `var'_asia 
    frame change `var'_asia 
    frlink m:1 iso3c, frame(iso3)
    keep if frval(iso3, un_region)==142 
    frget iso3n un_region un_subregion who_region paho_subregion, from(iso3)
    labmask ghecause, values(causename)
    drop causename
    label data "WHO GHE 2019: `var', Asia, all years"
    save "`datapath'\from-who\who-ghe-`var'-001-asia", replace

    ** restrict to UN Europe (iso3n==150) 
    frame copy `var' `var'_europe 
    frame change `var'_europe 
    frlink m:1 iso3c, frame(iso3)
    keep if frval(iso3, un_region)==150 
    frget iso3n un_region un_subregion who_region paho_subregion, from(iso3)
    labmask ghecause, values(causename)
    drop causename
    label data "WHO GHE 2019: `var', Europe, all years"
    save "`datapath'\from-who\who-ghe-`var'-001-europe", replace

    ** restrict to UN Oceania (iso3n==9) 
    frame copy `var' `var'_oceania 
    frame change `var'_oceania 
    frlink m:1 iso3c, frame(iso3)
    keep if frval(iso3, un_region)==9 
    frget iso3n un_region un_subregion who_region paho_subregion, from(iso3)
    labmask ghecause, values(causename)
    drop causename
    label data "WHO GHE 2019: `var', Oceania, all years"
    save "`datapath'\from-who\who-ghe-`var'-001-oceania", replace

    ** restrict to WHO Africa (who_regions==1) 
    frame copy `var' `var'_who1 
    frame change `var'_who1 
    frlink m:1 iso3c, frame(iso3)
    keep if frval(iso3, who_region)==1 
    frget iso3n un_region un_subregion who_region paho_subregion, from(iso3)
    labmask ghecause, values(causename)
    drop causename
    label data "WHO GHE 2019: `var', WHO Africa, all years"
    save "`datapath'\from-who\who-ghe-`var'-001-who1", replace

    ** restrict to WHO Americas (who_regions==2) 
    frame copy `var' `var'_who2 
    frame change `var'_who2 
    frlink m:1 iso3c, frame(iso3)
    keep if frval(iso3, who_region)==2 
    frget iso3n un_region un_subregion who_region paho_subregion, from(iso3)
    labmask ghecause, values(causename)
    drop causename
    label data "WHO GHE 2019: `var', WHO Americas, all years"
    save "`datapath'\from-who\who-ghe-`var'-001-who2", replace

    ** restrict to WHO Eastern Mediterranean (who_regions==3) 
    frame copy `var' `var'_who3 
    frame change `var'_who3 
    frlink m:1 iso3c, frame(iso3)
    keep if frval(iso3, who_region)==3 
    frget iso3n un_region un_subregion who_region paho_subregion, from(iso3)
    labmask ghecause, values(causename)
    drop causename
    label data "WHO GHE 2019: `var', WHO Eastern Mediterranean, all years"
    save "`datapath'\from-who\who-ghe-`var'-001-who3", replace

    ** restrict to WHO Europe (who_regions==4) 
    frame copy `var' `var'_who4 
    frame change `var'_who4 
    frlink m:1 iso3c, frame(iso3)
    keep if frval(iso3, who_region)==4 
    frget iso3n un_region un_subregion who_region paho_subregion, from(iso3)
    labmask ghecause, values(causename)
    drop causename
    label data "WHO GHE 2019: `var', WHO Europe, all years"
    save "`datapath'\from-who\who-ghe-`var'-001-who4", replace

    ** restrict to WHO South-East Asia (who_regions==5) 
    frame copy `var' `var'_who5 
    frame change `var'_who5
    frlink m:1 iso3c, frame(iso3)
    keep if frval(iso3, who_region)==5 
    frget iso3n un_region un_subregion who_region paho_subregion, from(iso3)
    labmask ghecause, values(causename)
    drop causename
    label data "WHO GHE 2019: `var', WHO South-East Asia, all years"
    save "`datapath'\from-who\who-ghe-`var'-001-who5", replace

    ** restrict to WHO Western Pacific (who_regions==6) 
    frame copy `var' `var'_who6 
    frame change `var'_who6 
    frlink m:1 iso3c, frame(iso3)
    keep if frval(iso3, who_region)==6 
    frget iso3n un_region un_subregion who_region paho_subregion, from(iso3)
    labmask ghecause, values(causename)
    drop causename
    label data "WHO GHE 2019: `var', WHO Western Pacific, all years"
    save "`datapath'\from-who\who-ghe-`var'-001-who6", replace

}

