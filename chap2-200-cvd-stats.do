** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-200-cvd-stats.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Preparing CVD mortality rates: PAHO-subregions in the Americas

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
    log using "`logpath'\chap2-200-cvd-stats", replace
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
** Loading DEATHS dataset for the Americas only 
** Americas (AMR)
**  1100    Cardiovascular 
**  1110    Rheumatic heart disease I01-I09
**  1120    Hypertensive heart disease I11-I15 
**  1130    Ischaemic heart disease I20-I25 
**  1140    Stroke I60-I69 
**  1150    Cardiomyopathy, myocarditis, endocarditis I30-I33, I38, I40, I42 
**  1160    Other circulatory diseases I00, I26-I28, I34-I37, I44-I51, I70-I99
** ------------------------------------------
use "`datapath'\from-who\who-ghe-deaths-001-who2-allcauses", replace
* TODO: Change restriction for each disease group
keep if ghecause==0 | ghecause==1100 | ghecause==1110 | ghecause==1120 | ghecause==1130 | ghecause==1140 | ghecause==1150 | ghecause==1160
    keep if who_region==2
    drop if age<0 
    drop dths_low dths_up
    ** Collapse from countries to subregions
    collapse (sum) dths pop, by(ghecause year paho_subregion sex age)
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
collapse (sum) dths pop, by(year ghecause paho_subregion sex age18 agroup)

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
label define ghecause_  1100 "cvd" 
                        1110 "rheumatic"
                        1120 "hypertensive" 
                        1130 "ischaemic"
                        1140 "stroke"
                        1150 "cardiomyopathy etc"
                        1160 "other", modify;
#delimit cr
label values ghecause ghecause_ 

** Save dataset ready for direct standardization 
tempfile for_mr
save `for_mr' , replace

** Collapse
collapse (sum) dths pop, by(year ghecause)
drop pop 
reshape wide dths , i(year) j(ghecause)

** CVD as percentage of all deaths
gen p1100 = (dths1100/dths0)*100

** Ischaemic as percentage of CVD and all-deaths
gen p1130a = (dths1130/dths0)*100
gen p1130b = (dths1130/dths1100)*100

** Stroke as percentage of CVD and all-deaths
gen p1140a = (dths1140/dths0)*100
gen p1140b = (dths1140/dths1100)*100

** Hypertensive as percentage of CVD and all-deaths
gen p1120a = (dths1120/dths0)*100
gen p1120b = (dths1120/dths1100)*100

** Cardiomyopathy as percentage of CVD and all-deaths
gen p1150a = (dths1150/dths0)*100
gen p1150b = (dths1150/dths1100)*100

** Rheumatic as percentage of CVD and all-deaths
gen p1110a = (dths1110/dths0)*100
gen p1110b = (dths1110/dths1100)*100





** IHD 
** Mortality rates by sex
use "`datapath'\from-who\chap2_cvd_mr", clear
keep if ghecause == 1130 & region==2000
drop crate aupp alow ase pop region ghecause
replace arate = arate * 100000
** 1=men 2=women 3=both
reshape wide arate dths, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = dths1 - dths2 
order year dths* ddiff arate* 
format dths1 %12.1fc
format dths2 %12.1fc
format dths3 %12.1fc
format ddiff %12.1fc

** STROKE 
** Mortality rates by sex
use "`datapath'\from-who\chap2_cvd_mr", clear
keep if ghecause == 1140 & region==2000
drop crate aupp alow ase pop region ghecause
replace arate = arate * 100000
** 1=men 2=women 3=both
reshape wide arate dths, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = dths1 - dths2 
order year dths* ddiff arate* 
format dths1 %12.1fc
format dths2 %12.1fc
format dths3 %12.1fc
format ddiff %12.1fc

** STROKE 
** DALY rates by sex
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1140 & region==2000
drop crate aupp alow ase pop dths region ghecause
replace arate = arate * 100000
** 1=men 2=women 3=both
reshape wide arate daly, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = daly1 - daly2 
order year daly* ddiff arate* 
format daly1 %12.1fc
format daly2 %12.1fc
format daly3 %12.1fc
format ddiff %12.1fc

** HYPERTENSIVE HEART DISEASE 
** Mortality rates by sex
use "`datapath'\from-who\chap2_cvd_mr", clear
keep if ghecause == 1120 & region==2000
drop crate aupp alow ase pop region ghecause
replace arate = arate * 100000
** 1=men 2=women 3=both
reshape wide arate dths, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = dths1 - dths2 
order year dths* ddiff arate* 
format dths1 %12.1fc
format dths2 %12.1fc
format dths3 %12.1fc
format ddiff %12.1fc

** HYPERTENSIVE HEART DISEASE 
** DALY rates by sex
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1120 & region==2000
drop crate aupp alow ase pop dths region ghecause
replace arate = arate * 100000
** 1=men 2=women 3=both
reshape wide arate daly, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = daly1 - daly2 
order year daly* ddiff arate* 
format daly1 %12.1fc
format daly2 %12.1fc
format daly3 %12.1fc
format ddiff %12.1fc



** CARDIOMYOPATHY etc
** Mortality rates by sex
use "`datapath'\from-who\chap2_cvd_mr", clear
keep if ghecause == 1150 & region==2000
drop crate aupp alow ase pop region ghecause
replace arate = arate * 100000
** 1=men 2=women 3=both
reshape wide arate dths, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = dths1 - dths2 
order year dths* ddiff arate* 
format dths1 %12.1fc
format dths2 %12.1fc
format dths3 %12.1fc
format ddiff %12.1fc

** CARDIOMYOPATHY etc
** DALY rates by sex
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1150 & region==2000
drop crate aupp alow ase pop dths region ghecause
replace arate = arate * 100000
** 1=men 2=women 3=both
reshape wide arate daly, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = daly1 - daly2 
order year daly* ddiff arate* 
format daly1 %12.1fc
format daly2 %12.1fc
format daly3 %12.1fc
format ddiff %12.1fc


** RHD
** Mortality rates by sex
use "`datapath'\from-who\chap2_cvd_mr", clear
keep if ghecause == 1110 & region==2000
drop crate aupp alow ase pop region ghecause
replace arate = arate * 100000
** 1=men 2=women 3=both
reshape wide arate dths, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = dths1 - dths2 
order year dths* ddiff arate* 
format dths1 %12.1fc
format dths2 %12.1fc
format dths3 %12.1fc
format ddiff %12.1fc
/*
** RHD
** DALY rates by sex
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1110 & region==2000
drop crate aupp alow ase pop dths region ghecause
replace arate = arate * 100000
** 1=men 2=women 3=both
reshape wide arate daly, i(year) j(sex)
gen aratio = arate1 / arate2
gen adiff = arate1 - arate2
gen ddiff = daly1 - daly2 
order year daly* ddiff arate* 
format daly1 %12.1fc
format daly2 %12.1fc
format daly3 %12.1fc
format ddiff %12.1fc


/*

** DALY rate by sex
** All CVD 
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1100 & region==2000
drop crate aupp alow ase pop region ghecause
** replace arate = arate * 100000
** 1=men 2=women 3=both
replace arate = arate * 100000
reshape wide arate dths daly, i(year) j(sex)
order year arate* daly* dths*
** Restrict to 2000 and 2019, and reshape to wide
** drop daly* dths* 
keep if year==2000 | year==2019
gen k=1
reshape wide dths1 dths2 dths3 daly1 daly2 daly3 arate1 arate2 arate3 , i(k) j(year)
order k arate1* arate2* arate3* dths1* dths2* dths3* daly1* daly2* daly3*
** percentage improvement
gen perc1 = ((arate12019 - arate12000)/arate12000) * 100
gen perc2 = ((arate22019 - arate22000)/arate22000) * 100
gen perc3 = ((arate32019 - arate32000)/arate32000) * 100
format perc1 perc2 perc3 %9.1f
** death excess (women and men combined)
gen dth_excess = dths12019-dths22019
gen daly_excess = daly12019-daly22019
format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc



** DALY rate by sex
** IHD 
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1130 & region==2000
drop crate aupp alow ase pop region ghecause
** replace arate = arate * 100000
** 1=men 2=women 3=both
replace arate = arate * 100000
reshape wide arate dths daly, i(year) j(sex)
order year arate* daly* dths*
** Restrict to 2000 and 2019, and reshape to wide
** drop daly* dths* 
keep if year==2000 | year==2019
gen k=1
reshape wide dths1 dths2 dths3 daly1 daly2 daly3 arate1 arate2 arate3 , i(k) j(year)
order k arate1* arate2* arate3* dths1* dths2* dths3* daly1* daly2* daly3*
** percentage improvement
gen perc1 = ((arate12019 - arate12000)/arate12000) * 100
gen perc2 = ((arate22019 - arate22000)/arate22000) * 100
gen perc3 = ((arate32019 - arate32000)/arate32000) * 100
format perc1 perc2 perc3 %9.1f
** death excess (women and men combined)
gen dth_excess = dths12019-dths22019
gen daly_excess = daly12019-daly22019
format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc




** DALY rate by sex
** STROKE 
use "`datapath'\from-who\chap2_cvd_daly", clear
keep if ghecause == 1140 & region==2000
drop crate aupp alow ase pop region ghecause
** replace arate = arate * 100000
** 1=men 2=women 3=both
replace arate = arate * 100000
reshape wide arate dths daly, i(year) j(sex)
order year arate* daly* dths*
** Restrict to 2000 and 2019, and reshape to wide
** drop daly* dths* 
keep if year==2000 | year==2019
gen k=1
reshape wide dths1 dths2 dths3 daly1 daly2 daly3 arate1 arate2 arate3 , i(k) j(year)
order k arate1* arate2* arate3* dths1* dths2* dths3* daly1* daly2* daly3*
** percentage improvement
gen perc1 = ((arate12019 - arate12000)/arate12000) * 100
gen perc2 = ((arate22019 - arate22000)/arate22000) * 100
gen perc3 = ((arate32019 - arate32000)/arate32000) * 100
format perc1 perc2 perc3 %9.1f
** death excess (women and men combined)
gen dth_excess = dths12019-dths22019
gen daly_excess = daly12019-daly22019
format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc
