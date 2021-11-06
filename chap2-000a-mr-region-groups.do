** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-000a-mr-region-groups.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-Apr-2021
    //  algorithm task			    Preparing CVD mortality rates: WHO-regions

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
    log using "`logpath'\chap2-000a-mr-region-groups", replace
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
recode age18 (18 19 20 21 = 18) 
collapse (sum) spop , by(age18) 
rename spop pop 
tempfile who_std
save `who_std', replace




** ------------------------------------------
** Loading DEATHS datasets for WHO regions 
** ------------------------------------------

tempfile afr amr emr eur sear wpr world
** Africa (AFR)
use "`datapath'\from-who\who-ghe-deaths-001-who1-allcauses", replace

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
                    (820 = 800 )
                    (940 = 900 )
                    (1510 = 1000 )
                    ;
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) dths (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `afr' , replace

** Americas (AMR)
use "`datapath'\from-who\who-ghe-deaths-001-who2-allcauses", replace
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
                    (820 = 800 )
                    (940 = 900 )
                    (1510 = 1000 )
                    ;
    #delimit cr

    drop if age<0 
    ** Collapse to WHO regions 
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) dths (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `amr' , replace

** Eastern Mediterranean (EMR)
use "`datapath'\from-who\who-ghe-deaths-001-who3-allcauses", replace
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
                    (820 = 800 )
                    (940 = 900 )
                    (1510 = 1000 )
                    ;
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) dths (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `emr' , replace

** Europe (EUR)
use "`datapath'\from-who\who-ghe-deaths-001-who4-allcauses", replace
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
                    (820 = 800 )
                    (940 = 900 )
                    (1510 = 1000 )
                    ;
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) dths (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `eur' , replace

** South-East Asia (SEAR)
use "`datapath'\from-who\who-ghe-deaths-001-who5-allcauses", replace
* TODO: Change restriction for each disease group
    #delimit ;
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
                    (820 = 800 )
                    (940 = 900 )
                    (1510 = 1000 )
                    ;
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) dths (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `sear' , replace

** Western Pacific (WPR)
use "`datapath'\from-who\who-ghe-deaths-001-who6-allcauses", replace
* TODO: Change restriction for each disease group
    #delimit ;
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
                    (820 = 800 )
                    (940 = 900 )
                    (1510 = 1000 )
                    ;
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) dths (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `wpr' , replace

** Join the WHO regions
use `afr', clear 
    append using `amr'
    append using `emr'
    append using `eur'
    append using `sear'
    append using `wpr'

** -------------------------------------------------------------------
** -------------------------------------------------------------------

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
collapse (sum) dths pop, by(year ghecause who_region sex age18 agroup)

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
label var who_region "6 WHO regions"
label var agroup "5 broad age groups: young children, youth, young adult, older adult, elderly"
label var age18 "5-year age groups: 18 groups"
label var dths "Count of all deaths"
label var pop "PAHO subregional populations" 
format pop %12.0fc 
** label var spop "WHO Standard population: sums to 1 million"

** Direct standardization 
** Two methods (-dstdize- and -distrate-)
gen deaths = round(dths) 
label var deaths "dths round to nearest integer" 
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
                    800  "mental"
                    900  "neurological"
                    1000  "injuries", modify
                    ;
#delimit cr
label values ghecause ghecause_ 

** Save dataset ready for direct standardization 
tempfile for_mr
save `for_mr' , replace

** Use in Chapter 3. Population change
** 18 age groups
save "`datapath'\from-who\chap3_byage_groups_malefemale", replace

** MOrtality rates
forval x = 2000(1)2019 {
    forval y = 1(1)2 {
        * TODO: Change next line for each disease group
        forval z = 100(100)1000 {
            use `for_mr' , clear 
            tempfile results
            keep if year==`x' 
            keep if sex==`y'
            keep if ghecause==`z' 
            dstdize deaths pop age18, by(who_region) using(`who_std')
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
* TODO: Change last number of filename for each disease group
use `f_2000_1_100' , clear

forval x = 2000(1)2019 {
    forval y = 1(1)2 {
        * TODO: Change range of loop for each disease group
        forval z = 100(100)1000 {
            append using `f_`x'_`y'_`z''
        }
    }
}
bysort year sex ghecause : gen region = _n 
* Drop duplicated initial dataset (2000, male, communicable) 
drop if region > 6

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
* Regions
recode region 1=1000 2=2000 3=3000 4=4000 5=5000 6=6000
#delimit ; 
label define region_    1000 "africa"
                        2000 "americas"
                        3000 "eastern mediterranean"
                        4000 "europe" 
                        5000 "south-east asia"
                        6000 "western pacific", modify; 
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
                    800  "mental"
                    900  "neurological"
                    1000  "injuries", modify
                    ;
#delimit cr
label values ghecause ghecause_ 

** Save the final MR dataset
label data "Crude and Adjusted mortality rates: WHO regions"
save "`datapath'\from-who\chap2_000a_mr_region-groups", replace

** List for TABLE 1.3
preserve
    use "`datapath'\from-who\chap2_000a_mr_region-groups", clear
    gen mortr = arate * 100000
    keep if year==2019
    keep if ghecause==100 | ghecause==200 | ghecause==300 | ghecause==1000
    gsort ghecause -sex region 
    list year ghecause sex region mortr, sep(3)
restore




/*


** Repeat for women and men combined 

** ------------------------------------------
** Loading DEATHS datasets for WHO regions 
** ------------------------------------------

tempfile afr amr emr eur sear wpr world
** Africa (AFR)
use "`datapath'\from-who\who-ghe-deaths-001-who1-allcauses", replace

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
                    (820 = 800 )
                    (940 = 900 )
                    (1510 = 1000 )
                    ;
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) dths (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `afr' , replace

** Americas (AMR)
use "`datapath'\from-who\who-ghe-deaths-001-who2-allcauses", replace
* TODO: Change restriction for each disease group
    #delimit ;
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
                    (820 = 800 )
                    (940 = 900 )
                    (1510 = 1000 )
                    ;
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) dths (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `amr' , replace

** Eastern Mediterranean (EMR)
use "`datapath'\from-who\who-ghe-deaths-001-who3-allcauses", replace
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
                    (820 = 800 )
                    (940 = 900 )
                    (1510 = 1000 )
                    ;
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) dths (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `emr' , replace

** Europe (EUR)
use "`datapath'\from-who\who-ghe-deaths-001-who4-allcauses", replace
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
                    (820 = 800 )
                    (940 = 900 )
                    (1510 = 1000 )
                    ;
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) dths (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `eur' , replace

** South-East Asia (SEAR)
use "`datapath'\from-who\who-ghe-deaths-001-who5-allcauses", replace
* TODO: Change restriction for each disease group
    #delimit ;
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
                    (820 = 800 )
                    (940 = 900 )
                    (1510 = 1000 )
                    ;
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) dths (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `sear' , replace

** Western Pacific (WPR)
use "`datapath'\from-who\who-ghe-deaths-001-who6-allcauses", replace
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
                    (820 = 800 )
                    (940 = 900 )
                    (1510 = 1000 )
                    ;
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    ** Ensure we don't double count population for mental health and neurological (820 940)
    replace pop = pop/2 if ghecause==820 | ghecause==940
    ** Ensure we don't double count population for mental health and neurological (820 940)
    rename pop pop_temp 
    collapse (sum) dths (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `wpr' , replace

** Join the WHO regions
use `afr', clear 
    append using `amr'
    append using `emr'
    append using `eur'
    append using `sear'
    append using `wpr'

** -------------------------------------------------------------------
** -------------------------------------------------------------------

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
collapse (sum) dths pop, by(year ghecause who_region age18 agroup)

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
label var who_region "6 WHO regions"
label var agroup "5 broad age groups: young children, youth, young adult, older adult, elderly"
label var age18 "5-year age groups: 18 groups"
label var dths "Count of all deaths"
label var pop "PAHO subregional populations" 
format pop %12.0fc 
** label var spop "WHO Standard population: sums to 1 million"

** Direct standardization 
** Two methods (-dstdize- and -distrate-)
gen deaths = round(dths) 
label var deaths "dths round to nearest integer" 
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
                    800  "mental"
                    900  "neurological"
                    1000  "injuries", modify
                    ;
#delimit cr
label values ghecause ghecause_ 

** Save dataset ready for direct standardization 
tempfile for_mr
save `for_mr' , replace

** Used for Equiplot by age 
** 18 age groups
save "`datapath'\from-who\chap2_equiplot_mr_byage_allcvd", replace
save "`datapath'\from-who\chap2_equiplot_mr_byage_groupeddeath", replace

** Use in Chapter 3. Population change
** 18 age groups
save "`datapath'\from-who\chap3_byage_groups_both", replace

** 2019, Male, Communicable Disease
forval x = 2000(1)2019 {
        * TODO: Change next line for each disease group
        forval z = 100(100)1000 {
            use `for_mr' , clear 
            tempfile results
            keep if year==`x' 
            keep if ghecause==`z' 
            dstdize deaths pop age18, by(who_region) using(`who_std')
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
* TODO: Change last number of filename for each disease group
use `f_2000_100' , clear

forval x = 2000(1)2019 {
        * TODO: Change range of loop for each disease group
        forval z = 100(100)1000 {
            append using `f_`x'_`z''
        }
}
bysort year ghecause : gen region = _n 
* Drop duplicated initial dataset (2000, male, communicable) 
drop if region > 6

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
* Regions
recode region 1=1000 2=2000 3=3000 4=4000 5=5000 6=6000
#delimit ; 
label define region_    1000 "africa"
                        2000 "americas"
                        3000 "eastern mediterranean"
                        4000 "europe" 
                        5000 "south-east asia"
                        6000 "western pacific", modify; 
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
                    800  "mental"
                    900 "neurological"
                    1000  "injuries", modify
                    ;
#delimit cr
label values ghecause ghecause_ 

** Save the final MR dataset
gen sex = 3
label data "Crude and Adjusted mortality rates: WHO regions"
save "`datapath'\from-who\chap2_000a_mr_region_groups_both", replace




