** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-000e-daly-region.do
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
    log using "`logpath'\chap2-000e-daly-region", replace
** HEADER -----------------------------------------------------

** Testing DIRECT STAND from first principles with test dataset

input str5 ageg case lpop rpop  
0-4	  127	   636	    5000	  
5-9	   25	   558	    5500	  
10-14	   18	   609	    5500
15-19	   21	   543	    5500
20-24	   12	   384	    6000
25-29	   27	   594	    6000
30-34	   48	   669	    6500
35-39	   27	   843	    7000
40-44	   29	   660	    7000
45-49	   32	   576	    7000
50-54	   32	   606	    7000
55-59	   34	   522	    6500
60-64	   45	   426	    6000
65-69	   65	   273	    5500
70-74	   38	   300	    5000
75-79	   68	   288	    4000
80-84	   74	   153	    2500
85-89	   82	   123	    1500
90+	   91	   207	    1000	  
end

gen     age19 = 1 if  ageg=="0-4"
replace age19 = 2 if  ageg=="5-9"
replace age19 = 3 if  ageg=="10-14"
replace age19 = 4 if  ageg=="15-19"
replace age19 = 5 if  ageg=="20-24"
replace age19 = 6 if  ageg=="25-29"
replace age19 = 7 if  ageg=="30-34"
replace age19 = 8 if  ageg=="35-39"
replace age19 = 9 if  ageg=="40-44"
replace age19 = 10 if ageg=="45-49"
replace age19 = 11 if ageg=="50-54"
replace age19 = 12 if ageg=="55-59"
replace age19 = 13 if ageg=="60-64"
replace age19 = 14 if ageg=="65-69"
replace age19 = 15 if ageg=="70-74"
replace age19 = 16 if ageg=="75-79"
replace age19 = 17 if ageg=="80-84"
replace age19 = 18 if ageg=="85-89"
replace age19 = 19 if ageg=="90+"
labmask age19, values(ageg)
order age19
drop ageg

** (Ref Pop)/(Local Pop) * (Local Observed Events)
    gen srate1 = rpop / lpop * case 
    egen tsrate1 = sum(srate1)
    egen trpop = sum(rpop)
    egen tlpop = sum(lpop)
    sort age19
    ** Per 10,000
    gen rate = tsrate1 / trpop * 10000

** Method
** DSR: 1 / sum(refpop) * sum(refpop*case/localpop) 
    egen t1a = sum(rpop)
    gen  t1b = 1/t1a
    gen t2a = rpop * case / lpop
    egen t2b = sum(t2a)
    gen dsr = t1b * t2b
    gen dsr10000 = dsr * 10000

** DSR 95%CI
    **  DSR
    gen ci1 = dsr 
    **  Case(lower)
    egen ol1 = sum(case)
    gen ol2 = 1 / (9*ol1)
    gen ol3 = 1.96 / (3 * sqrt(ol1))
    gen ol4 = ol1 * (1- ol2 - ol3)^3
    **  Case(upper)
    egen ou1 = sum(case)
    gen ou2 = 1 / (9*(ou1 + 1))
    gen ou3 = 1.96 / (3 * sqrt(ou1 + 1))
    gen ou4 = (ou1+1) * (1 - ou2 + ou3)^3
    **  Var(DSR)
    gen var1 = rpop^2 * case / lpop^2
    egen var2 = sum(var1)
    egen var3 = sum(rpop)
    gen var4 = var2 / (var3 ^2)
    **  DSR(lower)
    gen cl1 = dsr
    gen cl = cl1 + sqrt(var4/ol1) * (ol4 - ol1)
    **  DSR(upper)
    gen cu = cl1 + sqrt(var4/ol1) * (ou4 - ol1)
    ** Clear intermediate variables
    drop t1a t1b t2a t2b ci1 ol1 ol2 ol3 ol4 ou1 ou2 ou3 ou4 var1 var2 var3 var4 cl1    


clear





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
** For DALY standardization we use 17 groups instead of 18 
** We do this because Guyana estimates. DALY > Population when age 85+ 
recode age18 (18 19 20 21 = 18) 
collapse (sum) spop , by(age18) 
rename spop pop 
tempfile who_std
save `who_std', replace



** women and men combined 

** ------------------------------------------
** Loading DALYs datasets for WHO regions 
** ------------------------------------------

tempfile afr amr emr eur sear wpr world

** Americas (AMR)
use "`datapath'\from-who\who-ghe-daly-001-who2-allcauses", replace
** Collapse from 18 to 17 5 year groups.
** This means 80+ instead of 85+ 
**recode age (75 80 85 = 75) 
collapse (sum) daly daly_low daly_up pop, by(iso3c iso3n iso3 year age sex ghecause un_region un_subregion who_region paho_subregion)
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
    collapse (sum) daly (mean) pop=pop_temp, by(ghecause year who_region sex age iso3c iso3n paho_subregion)
    collapse (sum) daly pop, by(ghecause year who_region sex age)
    save `amr' , replace




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
collapse (sum) daly pop, by(year ghecause who_region age18 agroup)

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
                        16 "75-79"
                        17 "80-84"
                        18 "85+"
                        ;
#delimit cr
label values age18 age18_ 

** drop _merge

** Variable labelling
label var who_region "6 WHO regions"
label var agroup "5 broad age groups: young children, youth, young adult, older adult, elderly"
label var age18 "5-year age groups: 18 groups"
label var daly "Count of all DALYs"
rename pop lpop
label var lpop "PAHO subregional populations" 
format lpop %12.0fc 
** label var spop "WHO Standard population: sums to 1 million"


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
                    1000 "injuries", modify
                    ;
#delimit cr
label values ghecause ghecause_ 

** ------- 7-Apr-2022 new code ends ---------------------- 
** Add the Reference population
    merge m:m age18 using `who_std'
    rename pop rpop
    rename daly case
    drop _merge

** Crude rate
    bysort year ghecause who_region: egen num = sum(case)
    bysort year ghecause who_region: egen denom = sum(lpop)
    gen crude = num / denom

** (Ref Pop)/(Local Pop) * (Local Observed Events)
    gen srate1 = rpop / lpop * case 
    bysort year ghecause who_region: egen tsrate1 = sum(srate1)
    bysort year ghecause who_region: egen trpop = sum(rpop)
    bysort year ghecause who_region: egen tlpop = sum(lpop)
    sort age18
    ** Per 10,000
    gen rate = tsrate1 / trpop

** Method
** DSR: 1 / sum(refpop) * sum(refpop*case/localpop) 
    bysort year ghecause who_region: egen t1a = sum(rpop)
    gen  t1b = 1/t1a
    gen t2a = rpop * case / lpop
    bysort year ghecause who_region: egen t2b = sum(t2a)
    gen dsr = t1b * t2b
    gen dsr10000 = dsr

** DSR 95%CI
    **  DSR
    gen ci1 = dsr 
    **  Case(lower)
    bysort year ghecause who_region: egen ol1 = sum(case)
    gen ol2 = 1 / (9*ol1)
    gen ol3 = 1.96 / (3 * sqrt(ol1))
    gen ol4 = ol1 * (1- ol2 - ol3)^3
    **  Case(upper)
    bysort year ghecause who_region: egen ou1 = sum(case)
    gen ou2 = 1 / (9*(ou1 + 1))
    gen ou3 = 1.96 / (3 * sqrt(ou1 + 1))
    gen ou4 = (ou1+1) * (1 - ou2 + ou3)^3
    **  Var(DSR)
    gen var1 = rpop^2 * case / lpop^2
    bysort year ghecause who_region: egen var2 = sum(var1)
    bysort year ghecause who_region: egen var3 = sum(rpop)
    gen var4 = var2 / (var3 ^2)
    **  DSR(lower)
    gen cl1 = dsr
    gen cl = cl1 + sqrt(var4/ol1) * (ol4 - ol1)
    **  DSR(upper)
    gen cu = cl1 + sqrt(var4/ol1) * (ou4 - ol1)
    ** Clear intermediate variables
    drop t1a t1b t2a t2b ci1 ol1 ol2 ol3 ol4 ou1 ou2 ou3 ou4 var1 var2 var3 var4 cl1 
    
    ** Reformat variables
    rename case daly 
    gen se = .  

** Variable re-naming and dropping unwanted variables
rename crude crate
rename dsr arate
rename cu aupp
rename cl alow 
rename se ase 
rename lpop pop
rename who_region region
keep crate arate aupp alow ase pop year ghecause region 
** ------- new code ends ---------------------- 

** Variable Labelling
label var crate "Crude rate"
label var arate "Adjusted rate"
label var pop "Population of subregion"
label var year "Year of mortality rate"
label var ghecause "Broad causes of death"
label var region "WHO region / PAHO subregion"

** Variable level labelling
* Regions
recode region 1=1000 2=2000 3=3000 4=4000 5=5000 6=6000
#delimit ; 
label define region_    1000 "americas", modify; 
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
                    900  "neurological"
                    1000 "injuries", modify
                    ;
#delimit cr
label values ghecause ghecause_ 

** Save the final MR dataset
gen sex = 3
drop aupp alow ase 
replace pop = pop/1000000
replace arate = arate * 100000
label data "Crude and Adjusted DALYs: WHO regions"
/// save "`datapath'\from-who\chap2_000e_daly_region_groups_both", replace
