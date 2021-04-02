** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    p001-ghe-burden.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	31-MAr-2021
    //  algorithm task			    Reading the WHO GHE dataset - disease burden, YLL and DALY

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
    log using "`logpath'\p001-ghe-burden", replace
** HEADER -----------------------------------------------------

** ************************************************************
** 1. SET UP Frame Structure
** We do this to break up the large WHO dataset
** for computational efficiency
** ************************************************************
frame create iso 
frame create africa 
frame create americas 
frame create asia
frame create europe 
frame create oceania 

tempfile iso3 

** ************************************************************
** 1. LOAD and prepare ISO country metadata
** ************************************************************
insheet using "`datapath'\from-un\iso3.csv", clear comma names
rename iso3 iso3c
drop v3
** generate country groupings 
** Add broad UN groupings 
kountry iso3c, from(iso3c) geo(un)
drop NAMES_STD
rename GEO un_broad
label var un_broad "UN broad regions" 
** Add detailed UN groupings 
kountry iso3c, from(iso3c) geo(undet)
rename GEO un_det 
label var un_det "UN detailed regions" 
rename NAMES_STD cname_std
** Add UN 3-digit numerics (ISO3)
kountry iso3c, from(iso3c) to(iso3n)
rename _ISO3N_ iso3n 
order cname cname_std iso3c iso3n un_broad un_det

** Drop some unwanted minor territories
#delimit ; 
drop if     iso3c=="ALA" |  /// Aland islands 
            iso3c=="ATA" |  /// Antartica
            iso3c=="ATF" |  /// French Southern Territories
            iso3c=="BVT" |  /// Bouvet Island
            iso3c=="CCK" |  /// Cocos Islands

            iso3c=="CXR" |  /// Christmas Island
            iso3c=="GGY" |  /// Guernsey
            iso3c=="HMD" |  /// Heard Island / MacDonald Islands
            iso3c=="IMN" |  /// Isle of Man
            iso3c=="IOT" |  /// British Indian Ocean Territory
            iso3c=="JEY" |  /// Jersey
            iso3c=="MNP" |  /// Northern Mariana Islands
            iso3c=="NFK" |  /// Norfolk Island
            iso3c=="PCN" |  /// Pitcairn
            iso3c=="SGS" |  /// South Georgia

            iso3c=="SJM" |  /// Svarlbad
            iso3c=="TKL" |  /// Tokelau
            iso3c=="UMI" ;  /// US Minor Outlying Islands
#delimit cr 

** St Bartholemy (keep as part of Caribbean)
replace un_broad = "Americas" if iso3c=="BLM"
replace un_det = "Caribbean" if iso3c=="BLM"
replace cname_std = cname if iso3c=="BLM"
replace iso3n = 652 if iso3c=="BLM"

** St Martin (French Part) (Keep as part of Caribbean)
replace un_broad = "Americas" if iso3c=="MAF"
replace un_det = "Caribbean" if iso3c=="MAF"
replace cname_std = cname if iso3c=="MAF"
replace iso3n = 663 if iso3c=="MAF"

** Montenegro (New state in 2006 - needs update to -kountry- Stata code)
replace un_broad = "Europe" if iso3c=="MNE"
replace un_det = "Southern Europe" if iso3c=="MNE"
replace cname_std = cname if iso3c=="MNE"
replace iso3n = 499 if iso3c=="MNE"

save `iso3', replace 
frame change iso 
frame 



** ************************************************************
** 2. LOAD GHE BURDEN DATASET
** ************************************************************
** LOAD the WHO dta file - Global Health Estimates, Disease burden
** Downloaded from:
** DROPBOX locations: https://www.dropbox.com/s/8q4a9o7aavhrw6w/dths_yld_daly.dta?dl=0
** The location is probably temporary...
** Location forwarded to me in email from Roberta Caixeta (PAHO)
** Email received Tue 30th march 2021
**
** Original send from WHO contact:
** ------------------------------------------------------------
** -----Original Message-----
** From: CAO, Bochen <caob@who.int>
** Sent: Tuesday, March 30, 2021 11:01 AM
** To: Hennis, Dr. Anselm (WDC) <hennisa@paho.org>
** Cc: Caixeta, Dra. Roberta (WDC) <caixetro@paho.org>; ASMA, Samira <asmas@who.int>; BOUCHER, Philippe Jean-Pierre (fleap) <boucherp@who.int>; BRILLANTES, Zoe <brillantesz@who.int>; HO, Jessica Chi Ying <hoj@who.int>; Garcia Saiso, Dr. Sebastian (WDC) <garciasseb@paho.org>
** Subject: RE: [EXT] GHE AMRO analyses udpate Mar30
**  
** Dear Anselm,
**  
** Please find the link for deaths only https://nam12.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwww.dropbox.com%2Fs%2Fop2n5lvwlv707pe%2Fdths_19age.dta%3Fdl%3D0&amp;data=04%7C01%7Ccaixetro%40paho.org%7Cfacc6beab1c44a07b5c108d8f38cd318%7Ce610e79c2ec04e0f8a141e4b101519f7%7C0%7C0%7C637527133459921415%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C1000&amp;sdata=o2UBWYQl1bSGkqNdWUx4CoRIv%2B07znbH4vr%2FpTrCn3g%3D&amp;reserved=0
** and the full dataset with burden https://nam12.safelinks.protection.outlook.com/?url=https%3A%2F%2Fwww.dropbox.com%2Fs%2F8q4a9o7aavhrw6w%2Fdths_yld_daly.dta%3Fdl%3D0&amp;data=04%7C01%7Ccaixetro%40paho.org%7Cfacc6beab1c44a07b5c108d8f38cd318%7Ce610e79c2ec04e0f8a141e4b101519f7%7C0%7C0%7C637527133459921415%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C1000&amp;sdata=SPqhwVcc2SBfwh2fKeefrGHwLpTKFg1Af7SpnnUw4ZM%3D&amp;reserved=0
** Kindly note in the burden file there are overlapping age groups for ages under 1 (0 = under 1, .1 = 0-28 days, .11 = 1-11months…)
** 
** Happy to have a call to discuss should you have any questions, in any case.
**  
** Best,
** Bochen
** ------------------------------------------------------------

**    WHO GHE 2019. Disease burden
**    We Load an initial 100 rows while the dataset is documented 
use "`datapath'\from-who\dths_yld_daly", clear 
rename iso3 iso3c 
** use in 1/100000 using "`datapath'\from-who\dths_yld_daly", clear 
merge m:1 iso3c using `iso3' 
order iso3c cname 
drop _merge 



** ************************************************************
** 3. ADDING DATASET METADATA 
** ************************************************************
** Variable-level labelling 
label var iso3c "UN M49 iso3 text country codes"
label var iso3n "UN M49 iso3 numeric country codes"
label var cname "Country name" 
label var year "Year from 2000 to 2019" 

** Age categories
** NOTE from WHO (Bochen BAO)
** "Kindly note in the burden file there are overlapping age groups for ages under 1 (0 = under 1, .1 = 0-28 days, .11 = 1-11months…)"
label var age "Age categories"
recode age (0.1 = -2) (0.11 = -1) 
#delimit ; 
label define age_   -2 "0-28 days (neonatal)"
                    -1 "1-11 months (postneonatal)"
                    0 "Under 1 yr"
                    1 "1-4 yrs"
                    5 "5-9 yrs"
                    10 "10-14 yrs"
                    15 "15-19 yrs"
                    20 "20-24 yrs"
                    25 "25-29 yrs"
                    30 "30-34 yrs"
                    35 "35-39 yrs"
                    40 "40-44 yrs"
                    45 "45-49 yrs"
                    50 "50-54 yrs"
                    55 "55-59 yrs"
                    60 "60-64 yrs"
                    65 "65-69 yrs"
                    70 "70-74 yrs"
                    75 "75-79 yrs"
                    80 "80-84 yrs"
                    85 "85+ yrs"; 
#delimit cr 
label values age age_ 

** SEX (for confirmation) 
**! Categories for confirmation 
label var sex "Sex categories"
label define sex_ 1 "male" 2 "female" 
label values sex sex_ 

** Population 
label var pop "Age and sex-specific population (UN WPP estimates)"
order pop, after(sex)

** GHE cause categories 
label var ghecause "GHE cause categories" 
label var causename "Text description of GHE cause category" 
order causename, after(ghecause)

** Years of Life lost (YLL)
label var yll "Years of Life Lost (YLL) point estimate" 
label var yll_low "YLL uncertainty lower bound" 
label var yll_up "YLL uncertainty upper bound" 

** Years of Life lost (YLD)
label var yld "Years Lost to Disability (YLD) point estimate" 
label var yld_low "YLD uncertainty lower bound" 
label var yld_up "YLD uncertainty upper bound" 

** Disability Adjusted Life Years (DALY)
label var daly "Disability Adjusted Life Years (DALY) point estimate" 
label var daly_low "DALY uncertainty lower bound" 
label var daly_up "DALY uncertainty upper bound" 

** Deaths
label var dths "Deaths point estimate" 
label var dths_low "Deaths uncertainty lower bound" 
label var dths_up "Deaths uncertainty upper bound" 

** Country name 
drop cname 
label var cname_std "Country name" 
rename un_broad un_region 
rename un_det un_subregion 
label var un_region "United Nations region" 
label var un_subregion "United Nations sub-region" 
order iso3n cname_std un_region un_subregion, after(iso3c)

** ************************************************************
** 4. Save the resulting datasets
** ************************************************************
save "`datapath'\from-who\who-ghe-burden-001", replace

** YLL dataset
preserve
    keep iso3c iso3n canem_std un_region un_subregion year age sex pop ghecause causename yll*
    save "`datapath'\from-who\who-ghe-yll-001", replace
restore 
** YLD dataset
preserve
    keep iso3c iso3n canem_std un_region un_subregion year age sex pop ghecause causename yld*
    save "`datapath'\from-who\who-ghe-yld-001", replace
restore 
** DALY dataset
preserve
    keep iso3c iso3n canem_std un_region un_subregion year age sex pop ghecause causename daly*
    save "`datapath'\from-who\who-ghe-daly-001", replace
restore 
** Deaths dataset
preserve
    keep iso3c iso3n canem_std un_region un_subregion year age sex pop ghecause causename dths*
    save "`datapath'\from-who\who-ghe-deaths-001", replace
restore 
