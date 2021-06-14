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
** 1. LOAD and prepare ISO country metadata
** ************************************************************
tempfile iso3 
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
drop cname 
label var cname_std "Country name"
label var iso3c "UN M49 iso3 text country code"
label var iso3n "UN M49 iso3 numeric country code"
label data "UN country and region file, with M49 iso3 codes: Mar 2021" 

** Attach UN M49 region codes to the text regions
gen un_region = .
replace un_region = 2 if un_broad=="Africa" 
replace un_region = 19 if un_broad=="Americas" 
replace un_region = 142 if un_broad=="Asia" 
replace un_region = 150 if un_broad=="Europe" 
replace un_region = 9 if un_broad=="Oceania" 
labmask un_region, values(un_broad)
drop un_broad

** Attach UN M49 sub-region codes to text sub-regions
gen un_subregion = .
** Africa sub-regions
replace un_subregion = 15 if un_det=="Northern Africa"
replace un_subregion = 14 if un_det=="Eastern Africa"
replace un_subregion = 17 if un_det=="Middle Africa"
replace un_subregion = 18 if un_det=="Southern Africa"
replace un_subregion = 11 if un_det=="Western Africa"
** Americas sub-regions 
replace un_subregion = 29 if un_det=="Caribbean"
replace un_subregion = 13 if un_det=="Central America"
replace un_subregion = 5 if un_det=="South America"
replace un_subregion = 21 if un_det=="Northern America"
** Asia sub-regions 
replace un_subregion = 143 if un_det=="Central Asia"
replace un_subregion = 30 if un_det=="Eastern Asia"
replace un_subregion = 35 if un_det=="South-Eastern Asia"
replace un_subregion = 34 if un_det=="Southern Asia"
replace un_subregion = 145 if un_det=="Western Asia"
** Europe sub-regions 
replace un_subregion = 151 if un_det=="Eastern Europe"
replace un_subregion = 154 if un_det=="Northern Europe"
replace un_subregion = 39 if un_det=="Southern Europe"
replace un_subregion = 155 if un_det=="Western Europe"
** Oceania sub-regions 
replace un_subregion = 53 if un_det=="Australia and New Zealand"
replace un_subregion = 54 if un_det=="Melanesia"
replace un_subregion = 57 if un_det=="Micronesia"
replace un_subregion = 61 if un_det=="Polynesia"
**labmask un_subregion, values(un_det)
**drop un_det
** Attach UN M49 sub-region codes to text sub-regions
labmask iso3n, values(cname_std)
drop cname_std
save `iso3', replace 
sort iso3c 
save "`datapath'\from-un\un-iso3", replace


** ************************************************************
** 2. LOAD WHO REGIONS and MERGE with UN REGIONS
** ************************************************************
tempfile who 
insheet using "`datapath'\from-owid\who-regions.csv", clear comma names
**drop entity
rename code iso3c
drop year
rename whoregion who_region
save `who', replace 
sort iso3c 
save "`datapath'\from-owid\who-iso3", replace
merge 1:1 iso3c using `iso3'

** Code WHO region 
rename who_region whoname
gen who_region = .
replace who_region = 1 if whoname == "Africa"
replace who_region = 2 if whoname == "Americas"
replace who_region = 3 if whoname == "Eastern Mediterranean"
replace who_region = 4 if whoname == "Europe"
replace who_region = 5 if whoname == "South-East Asia"
replace who_region = 6 if whoname == "Western Pacific"
labmask who_region, values(whoname) 
order who_region, after(iso3n)

** Fixing missng entry the from older UN file
* South Sudan 
replace iso3n=729 if iso3c=="SSD"
replace un_region = 2 if iso3c=="SSD"
replace un_subregion = 14 if iso3c=="SSD"
replace un_det = "Eastern Africa" if iso3c=="SSD" 
labmask un_subregion, values(un_det)
drop un_det whoname entity _merge 

* Adding minor territories to the WHO regional classification
replace who_region = 1 if un_region == 2     /* africa */
replace who_region = 2 if un_region == 19     /* americas */
* Oceania 
replace who_region = 6 if iso3c=="ASM"
replace who_region = 6 if iso3c=="GUM"
replace who_region = 6 if iso3c=="NCL"
replace who_region = 6 if iso3c=="PYF"
replace who_region = 6 if iso3c=="WLF"
* Europe
replace who_region = 4 if iso3c=="FRO"
replace who_region = 4 if iso3c=="GIB"
replace who_region = 4 if iso3c=="LIE"
replace who_region = 4 if iso3c=="VAT"
* China/Hong Kong/Macau
replace who_region = 6 if iso3c=="HKG"
replace who_region = 6 if iso3c=="MAC"
* Palestine
replace who_region = 3 if iso3c=="PSE"

* create PAHO sub-regions (AMERICAS only of course)
* Source: https://www.paho.org/hq/index.php?option=com_content&view=article&id=97:2008-regional-subregional-centers-institutes-programs&Itemid=1110&lang=en
gen paho_subregion = . 
* north america
replace paho_subregion = 1 if iso3c=="CAN"
replace paho_subregion = 1 if iso3c=="BMU"
replace paho_subregion = 1 if iso3c=="USA"
* central america
replace paho_subregion = 2 if iso3c=="BLZ"
replace paho_subregion = 2 if iso3c=="CRI"
replace paho_subregion = 2 if iso3c=="GTM"
replace paho_subregion = 2 if iso3c=="HND"
replace paho_subregion = 2 if iso3c=="NIC"
replace paho_subregion = 2 if iso3c=="PAN"
replace paho_subregion = 2 if iso3c=="SLV"
* Andean area 
replace paho_subregion = 3 if iso3c=="BOL"
replace paho_subregion = 3 if iso3c=="COL"
replace paho_subregion = 3 if iso3c=="ECU"
replace paho_subregion = 3 if iso3c=="PER"
replace paho_subregion = 3 if iso3c=="VEN"
* Southern Cone 
replace paho_subregion = 4 if iso3c=="ARG"
replace paho_subregion = 4 if iso3c=="CHL"
replace paho_subregion = 4 if iso3c=="PRY"
replace paho_subregion = 4 if iso3c=="URY"
* Latin Caribbean
replace paho_subregion = 5 if iso3c=="CUB"
replace paho_subregion = 5 if iso3c=="DOM"
replace paho_subregion = 5 if iso3c=="HTI"
replace paho_subregion = 5 if iso3c=="PRI"
* Non-Latin Caribbean
replace paho_subregion = 6 if iso3c=="AIA"
replace paho_subregion = 6 if iso3c=="ATG"
replace paho_subregion = 6 if iso3c=="ABW"
replace paho_subregion = 6 if iso3c=="BHS"
replace paho_subregion = 6 if iso3c=="BRB"
replace paho_subregion = 6 if iso3c=="CYM"
replace paho_subregion = 6 if iso3c=="DMA"
replace paho_subregion = 6 if iso3c=="GRD"
replace paho_subregion = 6 if iso3c=="GLP"
replace paho_subregion = 6 if iso3c=="GUF"
replace paho_subregion = 6 if iso3c=="GUY"
replace paho_subregion = 6 if iso3c=="JAM"
replace paho_subregion = 6 if iso3c=="MTQ"
replace paho_subregion = 6 if iso3c=="MSR"
replace paho_subregion = 6 if iso3c=="ANT"
replace paho_subregion = 6 if iso3c=="KNA"
replace paho_subregion = 6 if iso3c=="LCA"
replace paho_subregion = 6 if iso3c=="VCT"
replace paho_subregion = 6 if iso3c=="SUR"
replace paho_subregion = 6 if iso3c=="TCA"
replace paho_subregion = 6 if iso3c=="TTO"
replace paho_subregion = 6 if iso3c=="VGB"

* Mexico & Brazil as separate sub-regions
replace paho_subregion = 7 if iso3c=="BRA"
replace paho_subregion = 8 if iso3c=="MEX"

#delimit ; 
label define paho_subregion_    1 "north america"
                                2 "central american isthmus"
                                3 "andean area"
                                4 "southern cone"
                                5 "latin caribbean"
                                6 "non-latin caribbean"
                                7 "brazil" 
                                8 "mexico";
#delimit cr 
label values paho_subregion paho_subregion_ 

** FINAL REGIONS DATASET 
save "`datapath'\from-owid\regions", replace


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


** ************************************************************
** 3. ADDING GHE BURDEN DATASET METADATA 
** ************************************************************
** Variable-level labelling 
label var iso3c "UN M49 iso3 text country codes"
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
** labmask ghecause, values(causename)

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

** ************************************************************
** 4. Save the FULL DATASET
** ************************************************************
label data "WHO GHE 2019: Disease Burden Metrics, all countries, all years"
save "`datapath'\from-who\who-ghe-burden-001", replace


** ************************************************************
** 5. Save DATA SUBSETS
** ************************************************************
** use "`datapath'\from-who\who-ghe-burden-001", clear

** YLL dataset
preserve
    keep iso3c year age sex pop ghecause causename yll*
    label data "WHO GHE 2019: Years of Life Lost, all countries, all years"
    save "`datapath'\from-who\who-ghe-yll-001", replace
restore 
preserve
    keep iso3c year age sex pop ghecause yll*
    label data "WHO GHE 2019: Years of Life Lost, all countries, all years"
    save "`datapath'\from-who\who-ghe-yll-002", replace
restore 
** YLD dataset
preserve
    keep iso3c year age sex pop ghecause causename yld*
    label data "WHO GHE 2019: Years Lost to Disability, all countries, all years"
    save "`datapath'\from-who\who-ghe-yld-001", replace
restore 
** DALY dataset
preserve
    keep iso3c year age sex pop ghecause causename daly*
    label data "WHO GHE 2019: Disability Adjusted Life Years, all countries, all years"
    save "`datapath'\from-who\who-ghe-daly-001", replace
restore 
** Deaths dataset
preserve
    keep iso3c year age sex pop ghecause causename dths*
    label data "WHO GHE 2019: Deaths, all countries, all years"
    save "`datapath'\from-who\who-ghe-deaths-001", replace
restore 
