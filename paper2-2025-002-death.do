** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-2025-002-death.do
    //  project:				    WHO Global Health Estimates 2021
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-JUN-2025
    //  algorithm task			    Reading the WHO GHE 2021 dataset: DEATH data

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
    log using "`logpath'\paper2-2025-002-death", replace
** HEADER -----------------------------------------------------

    
** ************************************************************
** LOAD and prepare GHE 2021 death data
** ************************************************************
import delimited using "`datapath'\AMR-GHE-2021\AMR_GHE_2021_Deaths.csv", clear rowrange(1:1000000)
** import delimited using "`datapath'\AMR-GHE-2021\AMR_GHE_2021_Deaths.csv", clear 

** There are some special category age groups that we delete 
drop if agegroup=="1-4 years"
drop if agegroup=="<1 year"
drop if agegroup=="25-49 years"
drop if agegroup=="Age-standardized"
drop if agegroup=="All ages"

** Restrict immediately to just injury categories + (major others)
** ------------------------------------
** (1) 0  All cause 
** (2) 10 Communicable
** (3) 600 NCDs 
** ------------------------------------
** (4) 1510 III. Injuries 
** (5) 1520 A. Unintentional injuries 
**     (7) 1530 1. Road injury
**     (8) 1540 2. Poisonings 
**     (9) 1550 3. Falls 
**     (10) 1560 4. Fire, heat and hot substances 
**     (11) 1570 5. Drowning 
**     (12) 1575 6. Exposure to mechanical forces 
**     (13) 1580 7. Natural disasters 
**     (--) 1590 8. Other unintentional injuries 
** (6) 1600 B. Intentional injuries 
**     (14) 1610 1. Self-harm 
**     (15) 1620 2. Interpersonal violence 
**     (16) 1630 3. Collective violence and legal intervention 
** ------------------------------------
    #delimit ;
    keep if     causeid==0      |
                causeid==10     |
                causeid==600    |

                causeid==1510   |
                causeid==1520   |
                causeid==1530   |                
                causeid==1540   |                
                causeid==1550   |                
                causeid==1560   |                
                causeid==1570   |                
                causeid==1575   |                
                causeid==1580   |            

                causeid==1600   |
                causeid==1610   |                
                causeid==1620   |                
                causeid==1630
                ;
    #delimit cr
    ** Recode for mortality rate loop
    #delimit ; 
    recode causeid 
                    (0 = 1 )
                    (10 = 2 )
                    (600 = 3 )
                    (1510 = 4)
                    (1520 = 5)
                    (1600 = 6)
                    (1530 = 7)
                    (1540 = 8)
                    (1550 = 9)
                    (1560 = 10)
                    (1570 = 11)
                    (1575 = 12)
                    (1580 = 13)
                    (1610 = 14)
                    (1620 = 15)
                    (1630 = 16);
    #delimit cr

** ISO3 (text) 
rename iso3 iso3c 
label var iso3 "Country ISO3 code (text)"
** Identifies the data as deaths 
drop measure_name_en
rename locationname country

** AGE 
** Create numeric values for age groups 
gen age = 1 if agegroup=="0-4 years"
replace age = 2 if agegroup=="5-9 years" 
replace age = 3 if agegroup=="10-14 years" 
replace age = 4 if agegroup=="15-19 years" 
replace age = 5 if agegroup=="20-24 years" 
replace age = 6 if agegroup=="25-29 years" 
replace age = 7 if agegroup=="30-34 years" 
replace age = 8 if agegroup=="35-39 years" 
replace age = 9 if agegroup=="40-44 years" 
replace age = 10 if agegroup=="45-49 years" 
replace age = 11 if agegroup=="50-54 years" 
replace age = 12 if agegroup=="55-59 years" 
replace age = 13 if agegroup=="60-64 years" 
replace age = 14 if agegroup=="65-69 years" 
replace age = 15 if agegroup=="70-74 years" 
replace age = 16 if agegroup=="75-79 years" 
replace age = 17 if agegroup=="80-84 years" 
replace age = 18 if agegroup=="85+ years" 

#delimit ; 
label define age_   1 "0-4 yrs"
                    2 "5-9 yrs"
                    3 "10-14 yrs"
                    4 "15-19 yrs"
                    5 "20-24 yrs"
                    6 "25-29 yrs"
                    7 "30-34 yrs"
                    8 "35-39 yrs"
                    9 "40-44 yrs"
                    10 "45-49 yrs"
                    11 "50-54 yrs"
                    12 "55-59 yrs"
                    13 "60-64 yrs"
                    14 "65-69 yrs"
                    15 "70-74 yrs"
                    16 "75-79 yrs"
                    17 "80-84 yrs"
                    18 "85+ yrs"; 
#delimit cr 
label values age age_ 
** drop agegroup 
label var age "Age in 18 groups"
label var country "Country name" 
label var year "Year of measurement"
order iso3c country year age 

** SEX
rename sex temp1 
gen sex = 1 if temp1=="Male"
replace sex = 2 if temp1=="Female"
replace sex = 3 if temp1=="Both sexes"
label var sex "Sex categories"
label define sex_ 1 "male" 2 "female" 3 "both"
label values sex sex_ 
drop temp1
order sex, after(age)

** METRIC 
** Count or crude rate
gen metric = 1 if metric_name_en=="Number"
replace metric = 2 if metric_name_en=="Rate"
label define metric_ 1 "number" 2 "rate"
label values metric metric_ 
label var metric "Metric (number or crude rate)" 
order metric, after(sex)
drop metric_name_en 

** CAUSE OF DEATH
** cause level 
** 0 =  All causes
** 1 =  I  (Communicable)
**      II  (NCDs)
**      III (Injuries)
**      IV  (NCDs)
** 2 = 2nd level disease groups
** 3 = 3rd level disease groups
** 4 = 4th level disease groups
rename causelevel clevel 
label var clevel "Cause level: 0-4"
** Cause ID code 
rename causeid cid  
label var cid "Cause numeric identifier"
** Cause ID Label 
rename cause_id_label clabel   
label var clabel "Cause identifier label"
** Cause name 
rename causename_eng cname    
label var cname "Text description of cause category"

** Leading cause of death - new variable for 2021 
** (not sure we'll use this, but preparing for completeness)
rename leading_code leadc 
label var leadc "Leading cause of death categories" 
labmask leadc, values(leadingcategory)
drop leadingcategory

** AMRO subregions 
**  ANR = Andean area
**  CAI = Central America and Latin Caribbean
**  NAR = North American Region
**  NLC = Non-Latin Caribbean
**  SCR = Southern Cone Region
gen amro=1 if amrosubregions=="ANR"
replace amro=2 if amrosubregions=="CAI"
replace amro=3 if amrosubregions=="NAR"
replace amro=4 if amrosubregions=="NLC"
replace amro=5 if amrosubregions=="SCR"
label define amro_ 1 "anr" 2 "cai" 3 "nar" 4 "nlc" 5 "scr"
label values amro amro_ 
drop amrosubregions
order amro, after(country)
label var amro "AMRO subregions"

** Deaths
label var value "Point estimate" 
label var value_low "Uncertainty lower bound" 
label var value_up "Uncertainty upper bound" 

** Drop unwanted sub-regions from the dataset - we will connect our own PAHO sub-regions
drop if iso3c=="LMIC" | iso3c=="UMIC" | iso3c=="HIC"  
drop if iso3c=="ANR" | iso3c=="CAI" | iso3c=="NAR" | iso3c=="NLC" | iso3c=="SCR" | iso3c=="AMRO" | iso3c=="LAC"

** Drop crude rates.
drop if metric==2 
drop metric 

** Drop the uncertainty parameters and "leading causes" indicator for now 
drop value_low value_up leadc 

** Save the FULL DATASET
label data "WHO GHE 2024: Deaths, 2000-2021, individual countries"
tempfile ghe01 
save `ghe01', replace


** ************************************************************
** LOAD and prepare ISO country metadata
** ************************************************************

tempfile iso3 
insheet using "`datapath'\iso3.csv", clear comma names
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
labmask un_subregion, values(un_det)
drop un_det
** Attach UN M49 sub-region codes to text sub-regions
** labmask iso3n, values(cname_std)
drop cname_std
save `iso3', replace 
sort iso3c 
keep if un_region==19 
drop un_region 

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

** Only keep the countries also in the GHE dataset 
#delimit ; 
drop if iso3c=="ABW" |
        iso3c=="AIA" |
        iso3c=="ANT" |
        iso3c=="BMU" |
        iso3c=="CYM" |
        iso3c=="GLP" |
        iso3c=="GUF" |
        iso3c=="MSR" |
        iso3c=="MTQ" |
        iso3c=="PRI" |
        iso3c=="TCA" |
        iso3c=="VGB" |
        iso3c=="BLM" |
        iso3c=="FLK" |
        iso3c=="GRL" |
        iso3c=="MAF" |
        iso3c=="SPM" |
        iso3c=="VIR";
#delimit cr 

** Save the regions dataset
sort paho_subregion iso3c 
save "`datapath'\regions", replace


** JOIN FINAL DEATHS DATASET with ADDITIONAL REGIONS INFORMATION 
use `ghe01', clear 
merge m:1 iso3c using  "`datapath'\regions"
drop if _merge==2 
drop _merge 
order iso3c iso3n country year age sex cid value amro un_subregion paho_subregion clevel clabel cname 


** ADD POPULATION COLUMN
** Comes from UN-WPP 2024 dataset 
** Prepared in --> paper2-2025-001.do 
merge m:1 iso3c year sex age using "`datapath'/un-wpp-2024"
order pop, after(country)
drop _merge 
gen un_region = 19 
label define un_region_ 19 "Americas" 
label values un_region un_region_ 
 label var un_region "The Americas. M49 classification"
label var un_subregion "Sub-regions of the Americas. M49 classification" 
label var paho_subregion "Sub-regions of the Americas. Defined by PAAHO"

** Label iso3n
labmask iso3n, values(country) 

** Save the FULL DATASET of counts.
sort year country sex age cid 
label data "WHO GHE 2021: Deaths, 2000-2021, individual countries, extra region information"
save "`datapath'\ghe-2021-Deaths-001", replace
