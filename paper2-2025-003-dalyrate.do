** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-2025-002-dalyrate.do
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
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data\2025"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs\2025"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs\2025"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\cpaper2-2025-002-dalyrate", replace
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
rename spop rpop 
tempfile who_std
save `who_std', replace


** ------------------------------------------
** Loading INJURY DALYs
** ------------------------------------------
use "`datapath'\ghe-2021-daly-001", replace

** The CID groups
rename cid ghecause 
labmask ghecause, values(cname) 
drop cname clabel clevel agegroup 

** NOT USED FOR COUNTRY LEVEL 
** Collapse from countries to subregions. 665,280
** collapse (sum) value pop, by(ghecause year sex age iso3n iso3c paho_subregion)

** BROAD age groups
** 1 Young children --> under-5s
** 2 Youth          --> 5-19
** 3 Young Adults   --> 20-39
** 4 Older Adults   --> 40-64
** 5 The Elderly    --> 65+
gen agroup = 1 if age==1 
replace agroup = 2 if age==2 | age==3 | age==4 
replace agroup = 3 if age==5 | age==6 | age==7 | age==8 
replace agroup = 4 if age==9 | age==10 | age==11 | age==12 | age==13  
replace agroup = 5 if age==14 | age==15 | age==16 | age==17 | age==18  
label define agroup_ 1 "young children" 2 "youth" 3 "young adults" 4 "older adults" 5 "elderly" , modify
label values agroup agroup_ 

** Join the ILLNESS dataset with the WHO STD population
** merge m:1 age using `who_std'
** drop _merge

** Variable labelling
label var agroup "5 broad age groups: young children, youth, young adult, older adult, elderly"
** label var rpop "WHO Standard population: sums to 1 million"
format pop %12.0fc 
rename age age18 

** Labelling ghecause 
#delimit ; 
label define ghecause_  
                1 "All cause" 
                2 "Communicable"
                3 "NCDs" 
                4 "Injuries" 
                5 "Unintentional injuries" 
                6 "Intentional injuries" 
                7 "Road injury"
                8 "Poisonings" 
                9 "Falls" 
                10 "Fire and heat" 
                11 "Drowning" 
                12 "Mechanical forces" 
                13 "Natural disasters" 
                14 "Self-harm"
                15 "Interpersonal violence"
                16 "Collective violence", modify;
#delimit cr
label values ghecause ghecause_ 
tempfile mr_country 
save `mr_country', replace 


** Append sub-regional and regional blocks to the country values

** CREATE SUB-REGIONAL DATASET
use `mr_country', replace 
collapse (sum) value pop , by(year sex ghecause age18 agroup un_region paho_subregion)
** Add iso3n >1000 for the PAHO subregions
gen iso3n = 1000 if paho_subregion==1
replace iso3n = 1100 if paho_subregion==2
replace iso3n = 1200 if paho_subregion==3
replace iso3n = 1300 if paho_subregion==4
replace iso3n = 1400 if paho_subregion==5
replace iso3n = 1500 if paho_subregion==6
replace iso3n = 1600 if paho_subregion==7
replace iso3n = 1700 if paho_subregion==8
decode paho_subregion, gen(subregion_label) 
labmask iso3n , values(subregion_label)
drop subregion_label 
tempfile mr_subregion
save `mr_subregion', replace 

** CREATE REGIONAL and SUB-REGIONAL DATASETS to append to COUNTRY dataset
use `mr_country', replace 
collapse (sum) value pop , by(year sex ghecause age18 agroup un_region)
** Add iso3n >2000 for the PAHO region of the Americas
gen iso3n = 2000 if un_region==19
tempfile mr_region
save `mr_region', replace 

use `mr_country', replace 
append using `mr_subregion'
append using `mr_region'
** Label the remaining subregional and regional iso3n categories
#delimit ; 
label define iso3n  1000 "North America"
                    1100 "Central America"
                    1200 "Andean"
                    1300 "Southern Cone"
                    1400 "Latin Caribbean"
                    1500 "non Latin Caribbean"
                    1600 "Brazil"
                    1700 "Mexico"
                    2000 "Americas", modify;
#delimit cr 
label values iso3n iso3n 

** This becomes `dataset2' in --> paper2-2025-005-datasets.do
** DEATHS in 18 age groups
save "`datapath'\ghe-2021-daly-byage", replace
/*

** -------------------------------------------------------
** AGE-STANDARDIZED RATES
** 7-Apr-2022 new rate code 
** -------------------------------------------------------
    merge m:m age18 using `who_std'
    rename pop lpop
    rename value case
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

    ** Collapse out the local population
    collapse (sum) cases lpop (mean) crate=crude arate=dsr aupp=cu alow=cl, by(sex year ghecause iso3n paho_subregion)  

    ** Reformat variables
    ** rename case daly 
    rename lpop pop 
    gen ase = .  

    ** Variable re-naming and dropping unwanted variables
    rename iso3n region
    format cases %12.1fc 
    keep cases crate arate aupp alow ase pop sex year ghecause region paho_subregion
** ------- new code ends ---------------------- 

** Variable Labelling
label var cases "DALY numbers"
label var crate "Crude rate"
label var arate "Adjusted rate"
label var alow "Lower 95% limit of adjusted rate"
label var aupp "Upper 95% limit of adjusted rate"
label var ase "standard error of adjusted rate"
label var pop "Population of subregion"
label var year "Year of mortality rate"
label var sex "Men (1) and Women (2)"
label var ghecause "Broad causes of DALYs"
label var region "WHO region / PAHO subregion"

** Variable level labelling
* Countries
rename region iso3n 
sort iso3n year ghecause 
egen region = group(iso3n) 

** Label the new region variable 
decode iso3n, gen(region_label) 
labmask region, values(region_label) 


** Save the final MR dataset
drop ase region_label
** replace pop = pop/1000000
order region 

label data "Crude and Adjusted DALY rates: Countries, PAHO sub-regions, region"
save "`datapath'\ghe-2021-daly-rate-001", replace



