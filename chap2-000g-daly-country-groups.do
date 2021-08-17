** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-000g-daly-country.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Preparing CVD mortality rates: Countries of the Americas

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
    log using "`logpath'\chap2-000g-daly-country", replace
** HEADER -----------------------------------------------------



** ------------------------------------------
** Load and save the WHO standard population
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
** For DALY standardization we use 16 groups instead of 18 
** We do this because Guyana estimates. DALY > Population when age 85+ 
recode age18 (16 17 18 19 20 21 = 16) 
collapse (sum) spop , by(age18) 
rename spop pop 
tempfile who_std
save `who_std', replace





** ------------------------------------------
** Loading DALYs dataset for the Americas only 
** Americas (AMR)
**  1100    Cardiovascular 
**  1110    Rheumatic heart disease I01-I09
**  1120    Hypertensive heart disease I11-I15 
**  1130    Ischaemic heart disease I20-I25 
**  1140    Stroke I60-I69 
**  1150    Cardiomyopathy, myocarditis, endocarditis I30-I33, I38, I40, I42 
**  1160    Other circulatory diseases I00, I26-I28, I34-I37, I44-I51, I70-I99
** ------------------------------------------
use "`datapath'\from-who\who-ghe-daly-001-who2-allcauses", replace
** Collapse from 18 to 17 5 year groups.
** This means 80+ instead of 85+ 
recode age (75 80 85 = 75) 
collapse (sum) daly daly_low daly_up pop, by(iso3c iso3n iso3 year age sex ghecause un_region un_subregion who_region paho_subregion)

** DALY to zero for Haiti in 2010 for natural disasters.
** The earthquale meant that DALY > POP, causing problems for the algorithms
** which expects DALY < POP
replace daly = 0 if iso3n==332 & year==2010 & ghecause==1510

* TODO: Change restriction for each disease group
   #delimit ;
    keep if     
                /// MAJOR DISEASE GROUPS
                ghecause==0     |
                ghecause==10    |
                ghecause==600   |
                ghecause==1100  |
                ghecause==610   | 
                ghecause==1170  | 
                ghecause==800   | 
                ghecause==820   |
                ghecause==940   |
                ghecause==1510 
                ;
    #delimit cr
    ** Recode for mortality rate loop
    #delimit ; 
    recode ghecause 
                    (0 = 100 )
                    (10 = 200 )
                    (600 = 300 )
                    (1100 = 400 )
                    (610  = 500 )
                    (1170 = 600 )
                    (800  = 700 )
                    (820 940 = 800 )
                    (1510 = 900 )
                    ;
    #delimit cr
    keep if who_region==2
    drop if age<0 
    drop daly_low daly_up
    ** Collapse from countries to subregions
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) daly (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
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
* TODO: This collapse only now down to country-level (instead of subregion level)
collapse (sum) daly pop, by(year ghecause iso3n iso3c paho_subregion sex age18 agroup)

** Join the DALYs dataset with the WHO STD population
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
                        16 "75+";
#delimit cr
label values age18 age18_ 
** drop _merge

** Variable labelling
label var paho_subregion "8 PAHO subregions of the Americas"
label var agroup "5 broad age groups: young children, youth, young adult, older adult, elderly"
label var age18 "5-year age groups: 18 groups"
label var daly "Count of all dalys"
label var pop "PAHO subregional populations" 
format pop %12.0fc 
** label var spop "WHO Standard population: sums to 1 million"

** Direct standardization 
** Two methods (-dstdize- and -distrate-)
rename daly dalyt 
gen daly = round(dalyt) 
label var daly "dalys round to nearest integer" 
replace pop = round(pop) 


** Looped creation of Mortality Rates
** YEAR (2000 to 2019)
** SEX (1=male, 2=female)
** COD (10=COM, 600=NCD, 1510=INJ)
** recode ghecause 10=10 600=20 1510=30
* TODO: Change labelling for each disease group
#delimit ; 
label define ghecause_  
                    100  "all causes"
                    200  "communicable"
                    300  "NCD"
                    400  "CVD"
                    500  "cancer"
                    600  "respiratory"
                    700  "diabetes"
                    800  "mental/neurological"
                    900  "injuries", modify
                    ;
#delimit cr
label values ghecause ghecause_ 

** Temporary Removal of "Natural Disaster" DALY values for Haiti in 2010
preserve
    keep if iso3n==332 & year==2010 & ghecause==54
    save "`datapath'\from-who\chap2_000g_daly_country_haiti_natural_disaster_groups", replace
restore

** Save dataset ready for direct standardization 
drop if ghecause<400
tempfile for_mr
save `for_mr' , replace

** Standardised MR values
forval x = 2000(1)2019 {
    forval y = 1(1)2 {
        * TODO: Change loop range for each disease group
        forval z = 400(100)900 {
            dis "YEAR = " `x'
            dis "SEX = " `y'
            dis "CAUSE = " `z' 
            use `for_mr' , clear 
            tempfile results
            keep if year==`x' 
            keep if sex==`y'
            keep if ghecause==`z' 
            * TODO: This loop is by country for each year/sex/disease group
            dstdize daly pop age18, by(iso3n) using(`who_std')
            matrix m`x'_`y'_`z' = r(crude) \ r(adj) \r(ub_adj) \ r(lb_adj) \  r(se) \ r(Nobs)
            matrix m`x'_`y'_`z' = m`x'_`y'_`z''
            svmat double m`x'_`y'_`z', name(col)
            keep  Crude Adjusted Right Left Se Nobs
            keep if Crude < .
            gen year = `x' 
            gen sex = `y'
            gen ghecause = `z'
            tempfile f_`x'_`y'_`z'
            save `f_`x'_`y'_`z'' , replace
        }    
    }
}

use `f_2000_1_400' , clear

forval x = 2000(1)2019 {
    forval y = 1(1)2 {
        * TODO: Change loop range for each disease group
        forval z = 400(100)900 {
            append using `f_`x'_`y'_`z''
        }
    }
}
bysort year sex ghecause : gen region = _n 
* Drop duplicated initial dataset (2000, male, communicable) 
* TODO: This value is above 33 and 33 is the number of countries in LAC region
drop if region > 33

** Variable re-naming
rename Crude crate
rename Adjusted arate
rename Right aupp
rename Left alow 
rename Se ase 
rename Nobs pop

** Variable Labelling
label var crate "Crude rate"
label var arate "Adjusted rate"
label var alow "Lower 95% limit of adjusted rate"
label var aupp "Upper 95% limit of adjusted rate"
label var ase "standard error of adjusted rate"
label var pop "Population of subregion"
label var year "Year of mortality rate"
label var sex "Men (1) and Women (2)"
label var ghecause "Broad causes of death"
label var region "WHO region / PAHO subregion"

** Variable level labelling
* Countries

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
* TODO: Change labelling for each disease group
#delimit ; 
label define ghecause_  
                    100  "all causes"
                    200  "communicable"
                    300  "NCD"
                    400  "CVD"
                    500  "cancer"
                    600  "respiratory"
                    700  "diabetes"
                    800  "mental/neurological"
                    900  "injuries", modify
                    ;
#delimit cr
label values ghecause ghecause_ 

** Save the final MR dataset
label data "Crude and Adjusted DALYs: PAHO sub-regions"
save "`datapath'\from-who\chap2_000g_daly_country_groups", replace




** Repeat for women and men combined 


** ------------------------------------------
** Loading DALYs dataset for the Americas only 
** Americas (AMR)
**  1100    Cardiovascular 
**  1110    Rheumatic heart disease I01-I09
**  1120    Hypertensive heart disease I11-I15 
**  1130    Ischaemic heart disease I20-I25 
**  1140    Stroke I60-I69 
**  1150    Cardiomyopathy, myocarditis, endocarditis I30-I33, I38, I40, I42 
**  1160    Other circulatory diseases I00, I26-I28, I34-I37, I44-I51, I70-I99
** ------------------------------------------
use "`datapath'\from-who\who-ghe-daly-001-who2-allcauses", replace
** Collapse from 18 to 17 5 year groups.
** This means 80+ instead of 85+ 
recode age (75 80 85 = 75) 
collapse (sum) daly daly_low daly_up pop, by(iso3c iso3n iso3 year age sex ghecause un_region un_subregion who_region paho_subregion)

** DALY to zero for Haiti in 2010 for natural disasters.
** The earthquale meant that DALY > POP, causing problems for the algorithms
** which expects DALY < POP
replace daly = 0 if iso3n==332 & year==2010 & ghecause==1510

* TODO: Change restriction for each disease group
   #delimit ;
    keep if     
                /// MAJOR DISEASE GROUPS
                ghecause==0     |
                ghecause==10    |
                ghecause==600   |
                ghecause==1100  |
                ghecause==610   | 
                ghecause==1170  | 
                ghecause==800   | 
                ghecause==820   |
                ghecause==940   |
                ghecause==1510 
                ;
    #delimit cr
    ** Recode for mortality rate loop
    #delimit ; 
    recode ghecause 
                    (0 = 100 )
                    (10 = 200 )
                    (600 = 300 )
                    (1100 = 400 )
                    (610  = 500 )
                    (1170 = 600 )
                    (800  = 700 )
                    (820 940 = 800 )
                    (1510 = 900 )
                    ;
    #delimit cr
    keep if who_region==2
    drop if age<0 
    drop daly_low daly_up
    ** Collapse from countries to subregions
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) daly (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
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
* TODO: This collapse only now down to country-level (instead of subregion level)
collapse (sum) daly pop, by(year ghecause iso3n iso3c paho_subregion age18 agroup)

** Join the DALYs dataset with the WHO STD population
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
                        16 "75+";
#delimit cr
label values age18 age18_ 
** drop _merge

** Variable labelling
label var paho_subregion "8 PAHO subregions of the Americas"
label var agroup "5 broad age groups: young children, youth, young adult, older adult, elderly"
label var age18 "5-year age groups: 18 groups"
label var daly "Count of all DALYs"
label var pop "PAHO subregional populations" 
format pop %12.0fc 
** label var spop "WHO Standard population: sums to 1 million"

** Direct standardization 
** Two methods (-dstdize- and -distrate-)
rename daly dalyt 
gen daly = round(dalyt) 
label var daly "daly round to nearest integer" 
replace pop = round(pop) 


** Looped creation of Mortality Rates
** YEAR (2000 to 2019)
** SEX (1=male, 2=female)
** COD (10=COM, 600=NCD, 1510=INJ)
** recode ghecause 10=10 600=20 1510=30
* TODO: Change labelling for each disease group
#delimit ; 
label define ghecause_  
                    100  "all causes"
                    200  "communicable"
                    300  "NCD"
                    400  "CVD"
                    500  "cancer"
                    600  "respiratory"
                    700  "diabetes"
                    800  "mental/neurological"
                    900  "injuries", modify
                    ;
#delimit cr
label values ghecause ghecause_ 


** Temporary Removal of "Natural Disaster" DALY values for Haiti in 2010
preserve
    keep if iso3n==332 & year==2010 & ghecause==54
    save "`datapath'\from-who\chap2_000g_daly_country_haiti_natural_disaster", replace
restore

** Save dataset ready for direct standardization 
drop if ghecause<400
tempfile for_mr
save `for_mr' , replace

** Standardised MR values
forval x = 2000(1)2019 {
        * TODO: Change loop range for each disease group
        forval z = 400(100)900 {
            use `for_mr' , clear 
            tempfile results
            keep if year==`x' 
            keep if ghecause==`z' 
            * TODO: This loop is by country for each year/sex/disease group
            dstdize daly pop age18, by(iso3n) using(`who_std')
            matrix m`x'_`z' = r(crude) \ r(adj) \r(ub_adj) \ r(lb_adj) \  r(se) \ r(Nobs)
            matrix m`x'_`z' = m`x'_`z''
            svmat double m`x'_`z', name(col)
            keep  Crude Adjusted Right Left Se Nobs
            keep if Crude < .
            gen year = `x' 
            gen ghecause = `z'
            tempfile f_`x'_`z'
            save `f_`x'_`z'' , replace
        }    
}

use `f_2000_400' , clear

forval x = 2000(1)2019 {
        * TODO: Change loop range for each disease group
        forval z = 400(100)900 {
            append using `f_`x'_`z''
        }
}
bysort year ghecause : gen region = _n 
* Drop duplicated initial dataset (2000, male, communicable) 
* TODO: This value is above 33 and 33 is the number of countries in LAC region
drop if region > 33

** Variable re-naming
rename Crude crate
rename Adjusted arate
rename Right aupp
rename Left alow 
rename Se ase 
rename Nobs pop

** Variable Labelling
label var crate "Crude rate"
label var arate "Adjusted rate"
label var alow "Lower 95% limit of adjusted rate"
label var aupp "Upper 95% limit of adjusted rate"
label var ase "standard error of adjusted rate"
label var pop "Population of subregion"
label var year "Year of mortality rate"
label var ghecause "Broad causes of death"
label var region "WHO region / PAHO subregion"

** Variable level labelling
* Countries

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
* TODO: Change labelling for each disease group
#delimit ; 
label define ghecause_  
                    100  "all causes"
                    200  "communicable"
                    300  "NCD"
                    400  "CVD"
                    500  "cancer"
                    600  "respiratory"
                    700  "diabetes"
                    800  "mental/neurological"
                    900  "injuries", modify
                    ;
#delimit cr
label values ghecause ghecause_ 

** Save the final MR dataset
gen sex = 3
label data "Crude and Adjusted DALYs: PAHO sub-regions"
save "`datapath'\from-who\chap2_000g_daly_country_groups_both", replace
