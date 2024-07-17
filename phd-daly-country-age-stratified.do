** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    phd-daly-country-age-stratified.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	27-Jun-2024
    //  algorithm task			    Preparing mortality rates: Countries of the Americas

    ** General algorithm set-up
    version 18
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** CHANGE THESE THREE filepaths to match local instance

    ** DATASETS to encrypted SharePoint folder
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\phd-daly-country-age-stratified", replace
** HEADER ----------------------------------------------------- 

** ------------------------------------------
** PART ONE. 
** Load and save 
** the WHO standard population (release 2000)
** ------------------------------------------
input str5 atext spop
"0-4"	88569
"5-9" 86870
"10-14"	85970
"15-19"	84670
"20-24"	82171
"25-29"	79272
"30-34"	76073
"35-39"	71475
"40-44"	65877
"45-49"	60379
"50-54"	53681
"55-59"	45484
"60-64"	37187
"65-69"	29590
"70-74"	22092
"75-79"	15195
"80-84"	9097
"85-89"	4398
"90-94"	1500
"95-99"	400
"100+"	50
end
** Collapse to 18 age groups in 5 year bands, and 85+
** This 18-category age grouping is used to match with WHO Std Pop (above)
gen age21 = 1 if atext=="0-4"
replace age21 = 2 if atext=="5-9"
replace age21 = 3 if atext=="10-14"
replace age21 = 4 if atext=="15-19"
replace age21 = 5 if atext=="20-24"
replace age21 = 6 if atext=="25-29"
replace age21 = 7 if atext=="30-34"
replace age21 = 8 if atext=="35-39"
replace age21 = 9 if atext=="40-44"
replace age21 = 10 if atext=="45-49"
replace age21 = 11 if atext=="50-54"
replace age21 = 12 if atext=="55-59"
replace age21 = 13 if atext=="60-64"
replace age21 = 14 if atext=="65-69"
replace age21 = 15 if atext=="70-74"
replace age21 = 16 if atext=="75-79"
replace age21 = 17 if atext=="80-84"
replace age21 = 18 if atext=="85-89"
replace age21 = 19 if atext=="90-94"
replace age21 = 20 if atext=="95-99"
replace age21 = 21 if atext=="100+"
gen age18 = age21
recode age18 (18 19 20 21 = 18) 
collapse (sum) spop , by(age18) 
rename spop rpop 
tempfile who_std
save `who_std', replace





** ------------------------------------------
** PART TWO
** WOMEN and MEN separately
**
** Loading DEATHS dataset for the Americas only 
** Americas (AMR)

    ** CAUSES OF DEATH and DISABILITY
    ** Can add - see WHO Methods document for dataset codes
    ** https://www.who.int/docs/default-source/gho-documents/global-health-estimates/ghe2019_cod_methods.pdf

    ** GROUPS
    ** 0        ALL CAUSE
    ** 600      NCDs
    ** 1100     Cardiovascular 
    ** 1260     Genitouninary

    ** INDIVIDUAL CAUSES
    ** 1130     Ischaemic heart disease
    ** 1140     Stroke 
    ** 800      Diabetes
    ** 1270     Kidney diseases
    ** 1271     Acute glomerulonephritis
    ** 1272     Chronic kidney disease due to diabetes
    ** 1273     Other chronic kidney disease
** ------------------------------------------

use "`datapath'\from-who\who-ghe-daly-001-who2-allcauses", replace

** Restrict to selected disease categories
    #delimit ;
    keep if     
                /// Grouped causes
                ghecause==0      | 
                ghecause==600    | 
                ghecause==1100   | 
                ghecause==1260   | 
                /// Individual causes
                ghecause==1130   | 
                ghecause==1140   |
                ghecause==800    |
                ghecause==1270   |
                ghecause==1272   |
                ghecause==1273
                ;
    #delimit cr
    ** Recode for mortality rate loop
    #delimit ; 
    recode ghecause 
                    (0 = 1 )
                    (600 = 2 )
                    (1100 = 3 )
                    (1260 = 4 )
                    (1130 = 5 )
                    (1140  = 6 )
                    (800  = 7 )
                    (1270  = 8 )
                    (1272  = 9)
                    (1273  = 10);
    #delimit cr

    keep if who_region==2
    drop if age<0 
    drop daly_low daly_up
    ** Collapse to countries
    collapse (sum) daly pop, by(ghecause year sex age iso3n iso3c paho_subregion)
    ** save "`datapath'\phd\chap2_cvd_001", replace

** BROAD age groups
** 1 Young children --> under-5s
** 2 Youth          --> 5-19
** 3 Young Adults   --> 20-39
** 4 Older Adults   --> 40-64
** 5 The Elderly    --> 65+
gen agroup = 1 if age==0 | age==1 
replace agroup = 2 if age==5 | age==10 | age==15 
replace agroup = 3 if age==20 | age==25 | age==30 | age==35 
replace agroup = 4 if age==40 | age==45 | age==50 | age==55 | age==60  
replace agroup = 5 if age==65 | age==70 | age==75 | age==80 | age==85  
label define agroup_ 1 "young children" 2 "youth" 3 "young adults" 4 "older adults" 5 "elderly" , modify
label values agroup agroup_ 

** 18 age groups
gen age18 = 1 if age==0 | age==1
replace age18 = 2 if age==5
replace age18 = 3 if age==10
replace age18 = 4 if age==15
replace age18 = 5 if age==20
replace age18 = 6 if age==25
replace age18 = 7 if age==30
replace age18 = 8 if age==35
replace age18 = 9 if age==40
replace age18 = 10 if age==45
replace age18 = 11 if age==50
replace age18 = 12 if age==55
replace age18 = 13 if age==60
replace age18 = 14 if age==65
replace age18 = 15 if age==70
replace age18 = 16 if age==75
replace age18 = 17 if age==80
replace age18 = 18 if age==85
collapse (sum) daly pop, by(year ghecause iso3n iso3c paho_subregion sex age18 agroup)
** Join the DEATHS dataset with the WHO STD population
** merge m:m age18 using `who_std'

** Label the age groups
#delimit ; 
label define age18_     1 "0-4"
                        2 "5-9"
                        3 "10-14"
                        4 "15-19"
                        5 "20-24"
                        6 "25-29"
                        7 "30-34"
                        8 "35-39"
                        9 "40-44"
                        10 "45-49"
                        11 "50-54"
                        12 "55-59"
                        13 "60-64"
                        14 "65-69"
                        15 "70-74"
                        16 "75-79"
                        17 "80-84"
                        18 "85+";
#delimit cr
label values age18 age18_ 
** drop _merge

** Variable labelling
label var paho_subregion "8 PAHO subregions of the Americas"
label var agroup "5 broad age groups: young children, youth, young adult, older adult, elderly"
label var age18 "5-year age groups: 18 groups"
label var daly "Count of all daly"
label var pop "PAHO subregional populations" 
format pop %12.0fc 
** label var spop "WHO Standard population: sums to 1 million"

** Looped creation of Mortality Rates
** YEAR (2000 to 2019)
** SEX (1=male, 2=female)
** COD (10=COM, 600=NCD, 1510=INJ)
** recode ghecause 10=10 600=20 1510=30
#delimit ; 
label define ghecause_  
                    1  "All cause"
                    2  "NCDs"
                    3  "Cardiovascular"
                    4  "Genitourinary"
                    5  "Ischaemic heart disease"
                    6  "Stroke"
                    7  "Diabetes"
                    8  "Kidney diseases"
                    9 "CKD due to diabetes"
                    10 "Other CKD"
, modify;
#delimit cr
label values ghecause ghecause_ 


** ------- Mortality Rate code ---------------------- 
** Add the WHO Reference population
    merge m:m age18 using `who_std'
    rename pop lpop
    rename daly case
    drop _merge

** Crude rate
    bysort sex year ghecause iso3n: egen num = sum(case)
    bysort sex year ghecause iso3n: egen denom = sum(lpop)
    gen crude = num / denom

** (Ref Pop)/(Local Pop) * (Local Observed Events)
    gen srate1 = rpop / lpop * case 
    bysort sex year ghecause iso3n: egen tsrate1 = sum(srate1)
    bysort sex year ghecause iso3n: egen trpop = sum(rpop)
    bysort sex year ghecause iso3n: egen tlpop = sum(lpop)
    sort age18
    ** Per 10,000
    gen rate = tsrate1 / trpop

** Method
** DSR: 1 / sum(refpop) * sum(refpop*case/localpop) 
    bysort sex year ghecause iso3n: egen t1a = sum(rpop)
    gen  t1b = 1/t1a
    gen t2a = rpop * case / lpop
    bysort sex year ghecause iso3n: egen t2b = sum(t2a)
    gen dsr = t1b * t2b

** DSR 95%CI
    **  DSR
    gen ci1 = dsr 
    **  Case(lower)
    bysort sex year ghecause iso3n: egen ol1 = sum(case)
    gen ol2 = 1 / (9*ol1)
    gen ol3 = 1.96 / (3 * sqrt(ol1))
    gen ol4 = ol1 * (1- ol2 - ol3)^3
    **  Case(upper)
    bysort sex year ghecause iso3n: egen ou1 = sum(case)
    gen ou2 = 1 / (9*(ou1 + 1))
    gen ou3 = 1.96 / (3 * sqrt(ou1 + 1))
    gen ou4 = (ou1+1) * (1 - ou2 + ou3)^3
    **  Var(DSR)
    gen var1 = rpop^2 * case / lpop^2
    bysort sex year ghecause iso3n: egen var2 = sum(var1)
    bysort sex year ghecause iso3n: egen var3 = sum(rpop)
    gen var4 = var2 / (var3 ^2)
    **  DSR(lower)
    gen cl1 = dsr
    gen cl = cl1 + sqrt(var4/ol1) * (ol4 - ol1)
    **  DSR(upper)
    gen cu = cl1 + sqrt(var4/ol1) * (ou4 - ol1)
    ** Clear intermediate variables
    drop t1a t1b t2a t2b ci1 ol1 ol2 ol3 ol4 ou1 ou2 ou3 ou4 var1 var2 var3 var4 cl1 
    rename case cases 

    ** Collapse out age
    ** collapse (sum) cases lpop (mean) crate=crude arate=dsr aupp=cu alow=cl, by(sex year ghecause iso3n)  

    ** Reformat variables
    ** rename case daly 
    rename lpop pop
    rename crude crate
    rename dsr arate
    rename cu aupp 
    rename cl alow  
    gen ase = .  

    ** Variable re-naming and dropping unwanted variables
    rename iso3n region
    format cases %12.1fc 
    keep cases crate arate aupp alow ase pop sex year ghecause region age18 agroup  
** ------- Mortality rate code ends ---------------------- 


** Variable Labelling
label var cases "daly numbers"
label var crate "Crude rate"
label var arate "Adjusted rate"
label var alow "Lower 95% limit of adjusted rate"
label var aupp "Upper 95% limit of adjusted rate"
label var ase "standard error of adjusted rate"
label var pop "Population of subregion"
label var year "Year of daly rate"
label var sex "Men (1) and Women (2)"
label var ghecause "Broad causes of death"
label var region "WHO region / PAHO subregion"

** Variable level labelling
* Countries
rename region iso3n 
sort iso3n year ghecause 
egen region = group(iso3n) 
#delimit ; 
label define region_   
                    1 "Antigua and Barbuda"
                    2 "Argentina"
                    3 "Bahamas"
                    4 "Barbados"
                    5 "Bolivia"
                    6 "Brazil"
                    7 "Belize"
                    8 "Canada"
                    9 "Chile"
                    10 "Colombia"
                    11 "Costa Rica"
                    12 "Cuba"
                    13 "Dominican Republic"
                    14 "Ecuador"
                    15 "El Salvador"
                    16 "Grenada"
                    17 "Guatemala"
                    18 "Guyana"
                    19 "Haiti"
                    20 "Honduras"
                    21 "Jamaica"
                    22 "Mexico"
                    23 "Nicaragua"
                    24 "Panama"
                    25 "Paraguay"
                    26 "Peru"
                    27 "Saint Lucia"
                    28 "Saint Vincent and the Grenadines"
                    29 "Suriname"
                    30 "Trinidad and Tobago"
                    31 "United States"
                    32 "Uruguay"
                    33 "Venezuela", modify;                     
#delimit cr 
label values region region_ 
* sex
label define sex_ 1 "male" 2 "female" , modify 
label values sex sex_ 
* Cause of death
#delimit ; 
label define ghecause_  
                    1  "All cause"
                    2  "NCDs"
                    3  "Cardiovascular"
                    4  "Genitourinary"
                    5  "Ischaemic heart disease"
                    6  "Stroke"
                    7  "Diabetes"
                    8  "Kidney diseases"
                    9 "CKD due to diabetes"
                    10 "Other CKD", modify;
#delimit cr
label values ghecause ghecause_ 

** Save the final MR dataset
drop ase iso3n 
label data "Crude and Adjusted daly rates: age-stratified"
tempfile file_mf 
save `file_mf' , replace



** ------------------------------------------
** PART THREE. 
** WOMEN and MEN combined 
**
** Loading DEATHS dataset for the Americas only 
** Americas (AMR)

** CAUSES OF DEATH and DISABILITY
** Can add - see WHO Methods document for dataset codes
** https://www.who.int/docs/default-source/gho-documents/global-health-estimates/ghe2019_cod_methods.pdf
** GROUPS
** 0        ALL CAUSE
** 600      NCDs
** 1100     Cardiovascular 
** 1260     Genitouninary
** INDIVIDUAL CAUSES
** 1130     Ischaemic heart disease
** 1140     Stroke 
** 800      Diabetes
** 1270     Kidney diseases
** 1271     Acute glomerulonephritis
** 1272     Chronic kidney disease due to diabetes
** 1273     Other chronic kidney disease
** ------------------------------------------

use "`datapath'\from-who\who-ghe-daly-001-who2-allcauses", replace

** Restrict to selected disease categories
    #delimit ;
    keep if     
                /// Grouped causes
                ghecause==0      | 
                ghecause==600    | 
                ghecause==1100   | 
                ghecause==1260   | 
                /// Individual causes
                ghecause==1130   | 
                ghecause==1140   |
                ghecause==800    |
                ghecause==1270   |
                ghecause==1272   |
                ghecause==1273
                ;
    #delimit cr
    ** Recode for mortality rate loop
    #delimit ; 
    recode ghecause 
                    (0 = 1 )
                    (600 = 2 )
                    (1100 = 3 )
                    (1260 = 4 )
                    (1130 = 5 )
                    (1140  = 6 )
                    (800  = 7 )
                    (1270  = 8 )
                    (1272  = 9)
                    (1273  = 10);
    #delimit cr

    keep if who_region==2
    drop if age<0 
    drop daly_low daly_up
    ** Collapse to countries
    collapse (sum) daly pop, by(ghecause year sex age iso3n iso3c paho_subregion)
    ** save "`datapath'\from-who\chap2_cvd_001", replace

** BROAD age groups
** 1 Young children --> under-5s
** 2 Youth          --> 5-19
** 3 Young Adults   --> 20-39
** 4 Older Adults   --> 40-64
** 5 The Elderly    --> 65+
gen agroup = 1 if age==0 | age==1 
replace agroup = 2 if age==5 | age==10 | age==15 
replace agroup = 3 if age==20 | age==25 | age==30 | age==35 
replace agroup = 4 if age==40 | age==45 | age==50 | age==55 | age==60  
replace agroup = 5 if age==65 | age==70 | age==75 | age==80 | age==85  
label define agroup_ 1 "young children" 2 "youth" 3 "young adults" 4 "older adults" 5 "elderly" , modify
label values agroup agroup_ 

** 18 age groups
gen age18 = 1 if age==0 | age==1
replace age18 = 2 if age==5
replace age18 = 3 if age==10
replace age18 = 4 if age==15
replace age18 = 5 if age==20
replace age18 = 6 if age==25
replace age18 = 7 if age==30
replace age18 = 8 if age==35
replace age18 = 9 if age==40
replace age18 = 10 if age==45
replace age18 = 11 if age==50
replace age18 = 12 if age==55
replace age18 = 13 if age==60
replace age18 = 14 if age==65
replace age18 = 15 if age==70
replace age18 = 16 if age==75
replace age18 = 17 if age==80
replace age18 = 18 if age==85
** Use this collapse to REMOVE SEX as a stratification collapse (sum) dths pop, by(year ghecause iso3n iso3c paho_subregion age18 agroup)

** Join the DEATHS dataset with the WHO STD population
** merge m:m age18 using `who_std'

** Label the age groups
#delimit ; 
label define age18_     1 "0-4"
                        2 "5-9"
                        3 "10-14"
                        4 "15-19"
                        5 "20-24"
                        6 "25-29"
                        7 "30-34"
                        8 "35-39"
                        9 "40-44"
                        10 "45-49"
                        11 "50-54"
                        12 "55-59"
                        13 "60-64"
                        14 "65-69"
                        15 "70-74"
                        16 "75-79"
                        17 "80-84"
                        18 "85+";
#delimit cr
label values age18 age18_ 
** drop _merge

** Variable labelling
label var paho_subregion "8 PAHO subregions of the Americas"
label var agroup "5 broad age groups: young children, youth, young adult, older adult, elderly"
label var age18 "5-year age groups: 18 groups"
label var daly "Count of all daly"
label var pop "PAHO subregional populations" 
format pop %12.0fc 
** label var spop "WHO Standard population: sums to 1 million"


** Looped creation of Mortality Rates
** YEAR (2000 to 2019)
** SEX (1=male, 2=female)
** COD (10=COM, 600=NCD, 1510=INJ)
** recode ghecause 10=10 600=20 1510=30
#delimit ; 
label define ghecause_  
                    1  "All cause"
                    2  "NCDs"
                    3  "Cardiovascular"
                    4  "Genitourinary"
                    5  "Ischaemic heart disease"
                    6  "Stroke"
                    7  "Diabetes"
                    8  "Kidney diseases"
                    9 "CKD due to diabetes"
                    10 "Other CKD"
, modify;
#delimit cr
label values ghecause ghecause_ 

** ------- Mortality rate code  ---------------------- 
** Add the Reference population
    merge m:m age18 using `who_std'
    rename pop lpop
    rename daly case
    drop _merge

** Crude rate
    bysort year ghecause iso3n: egen num = sum(case)
    bysort year ghecause iso3n: egen denom = sum(lpop)
    gen crude = num / denom

** (Ref Pop)/(Local Pop) * (Local Observed Events)
    gen srate1 = rpop / lpop * case 
    bysort year ghecause iso3n: egen tsrate1 = sum(srate1)
    bysort year ghecause iso3n: egen trpop = sum(rpop)
    bysort year ghecause iso3n: egen tlpop = sum(lpop)
    sort age18
    ** Per 10,000
    gen rate = tsrate1 / trpop

** Method
** DSR: 1 / sum(refpop) * sum(refpop*case/localpop) 
    bysort year ghecause iso3n: egen t1a = sum(rpop)
    gen  t1b = 1/t1a
    gen t2a = rpop * case / lpop
    bysort year ghecause iso3n: egen t2b = sum(t2a)
    gen dsr = t1b * t2b

** DSR 95%CI
    **  DSR
    gen ci1 = dsr 
    **  Case(lower)
    bysort year ghecause iso3n: egen ol1 = sum(case)
    gen ol2 = 1 / (9*ol1)
    gen ol3 = 1.96 / (3 * sqrt(ol1))
    gen ol4 = ol1 * (1- ol2 - ol3)^3
    **  Case(upper)
    bysort year ghecause iso3n: egen ou1 = sum(case)
    gen ou2 = 1 / (9*(ou1 + 1))
    gen ou3 = 1.96 / (3 * sqrt(ou1 + 1))
    gen ou4 = (ou1+1) * (1 - ou2 + ou3)^3
    **  Var(DSR)
    gen var1 = rpop^2 * case / lpop^2
    bysort year ghecause iso3n: egen var2 = sum(var1)
    bysort year ghecause iso3n: egen var3 = sum(rpop)
    gen var4 = var2 / (var3 ^2)
    **  DSR(lower)
    gen cl1 = dsr
    gen cl = cl1 + sqrt(var4/ol1) * (ol4 - ol1)
    **  DSR(upper)
    gen cu = cl1 + sqrt(var4/ol1) * (ou4 - ol1)
    ** Clear intermediate variables
    drop t1a t1b t2a t2b ci1 ol1 ol2 ol3 ol4 ou1 ou2 ou3 ou4 var1 var2 var3 var4 cl1 
    rename case cases

    ** Collapse out sex
    collapse (sum) cases lpop (mean) crate=crude arate=dsr aupp=cu alow=cl, by(year ghecause iso3n age18 agroup)  

    ** Reformat variables
    ** rename case daly 
    rename lpop pop 
    gen ase = .  

    ** Variable re-naming and dropping unwanted variables
    format cases %12.1fc
    rename iso3n region
    keep cases crate arate aupp alow ase pop year ghecause region age18 agroup  
** ------- Mortality rate code ends ---------------------- 



** Variable Labelling
label var cases "daly numbers"
label var crate "Crude rate"
label var arate "Adjusted rate"
label var alow "Lower 95% limit of adjusted rate"
label var aupp "Upper 95% limit of adjusted rate"
label var ase "standard error of adjusted rate"
label var pop "Population of subregion"
label var year "Year of daly rate"
label var ghecause "Broad causes of death"
label var region "WHO region / PAHO subregion"

** Variable level labelling
* Countries
rename region iso3n 
sort iso3n year ghecause 
egen region = group(iso3n) 
#delimit ; 
label define region_   
                    1 "Antigua and Barbuda"
                    2 "Argentina"
                    3 "Bahamas"
                    4 "Barbados"
                    5 "Bolivia"
                    6 "Brazil"
                    7 "Belize"
                    8 "Canada"
                    9 "Chile"
                    10 "Colombia"
                    11 "Costa Rica"
                    12 "Cuba"
                    13 "Dominican Republic"
                    14 "Ecuador"
                    15 "El Salvador"
                    16 "Grenada"
                    17 "Guatemala"
                    18 "Guyana"
                    19 "Haiti"
                    20 "Honduras"
                    21 "Jamaica"
                    22 "Mexico"
                    23 "Nicaragua"
                    24 "Panama"
                    25 "Paraguay"
                    26 "Peru"
                    27 "Saint Lucia"
                    28 "Saint Vincent and the Grenadines"
                    29 "Suriname"
                    30 "Trinidad and Tobago"
                    31 "United States"
                    32 "Uruguay"
                    33 "Venezuela", modify;                     
#delimit cr 
label values region region_  
* Cause of death
#delimit ; 
label define ghecause_  
                    1  "All cause"
                    2  "NCDs"
                    3  "Cardiovascular"
                    4  "Genitourinary"
                    5  "Ischaemic heart disease"
                    6  "Stroke"
                    7  "Diabetes"
                    8  "Kidney diseases"
                    9 "CKD due to diabetes"
                    10 "Other CKD", modify;
#delimit cr
label values ghecause ghecause_ 

** Save the final MR dataset
gen sex = 3
drop ase iso3n 
** drop aupp alow ase 
** replace pop = pop/1000000
label data "Crude and Adjusted daly rates: age-stratified"
tempfile file_both 
save `file_both' , replace



** ------------------------------------------
** PART FOUR 
** Join the TWO datasets
** ------------------------------------------
use `file_mf', clear 
append using `file_both'
** use "`datapath'\phd\phd_mr_country", replace
** append using "`datapath'\phd\phd_mr_country_both"
label define sex_ 1 "men" 2 "women" 3 "both", modify
label values sex sex_ 
order region sex year age18 ghecause  
sort region sex year age18 ghecause 

** Rates per 100,000
replace crate = crate * 100000
replace arate = arate * 100000
replace aupp = aupp * 100000
replace alow = alow * 100000

** Metadata
label data "Restricted GHE DALY dataset (2000-2019): created 27-Jun-2024"
label data "Created by Ian Hambleton (27-Jun-2024)"
label data "For details of original dataset see following weblink:"
label data "https://www.who.int/docs/default-source/gho-documents/global-health-estimates/ghe2019_cod_methods.pdf"
** Save datasets
save "`datapath'\phd\phd_daly_country_v1", replace
export excel using "`datapath'\phd\phd_daly_country_v1", sheet(who-ghe-2019-v1) first(var) replace 
