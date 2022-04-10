** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-000d-daly-AFR.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Preparing DALY numbers: WHO-regions

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
    log using "`logpath'\chap2-000d-daly-AFR", replace
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
use "`datapath'\from-who\who-ghe-daly-001-who1-allcauses", replace

* TODO: Change restriction for each disease group
    #delimit ;
    keep if     
                /// CVD causes
                ghecause==1110    | 
                ghecause==1120  | 
                ghecause==1130  | 
                ghecause==1140  | 
                ghecause==1150  | 
                /// Cancer causes
                ghecause==620  | 
                ghecause==630 |
                ghecause==640 |
                ghecause==650   |
                ghecause==660   |
                ghecause==670   |
                ghecause==680   |
                ghecause==690   |
                ghecause==700   |
                ghecause==710   |
                ghecause==720   |
                ghecause==730   |
                ghecause==740   |
                ghecause==742   |
                ghecause==745   |
                ghecause==750   |
                ghecause==751   |
                ghecause==752   |
                ghecause==753   |
                ghecause==754   |
                ghecause==755   |
                ghecause==760   |
                ghecause==770   |
                /// CHRONIC RESPIRATORY DISEASES
                ghecause==1180   |
                ghecause==1190   |                
                /// DIABETES
                ghecause==800   |                
                /// MENTAL HEALTH / NEUROLOGICAL 
                ghecause==830   |                
                ghecause==840   |                
                ghecause==850   |                
                ghecause==860   |                
                ghecause==870   |                
                ghecause==880   |                
                ghecause==890   |                
                ghecause==900   |                
                ghecause==910   |                
                ghecause==920   |
                ghecause==950    |                
                ghecause==960    |                
                ghecause==970    |                
                ghecause==980    |                
                ghecause==990    |                
                ghecause==1000   |                
                /// EXTERNAL CAUSES
                ghecause==1530   |                
                ghecause==1540   |                
                ghecause==1550   |                
                ghecause==1560   |                
                ghecause==1570   |                
                ghecause==1575   |                
                ghecause==1580   |            
                ghecause==1610   |                
                ghecause==1620   |                
                ghecause==1630   |
                /// BROAD causes (EXCEPT DIABETES)
                ghecause==0     |
                ghecause==10    |
                ghecause==600   |
                ghecause==1100  |
                ghecause==610   | 
                ghecause==1170  | 
                ghecause==820   |
                ghecause==940   |
                ghecause==1510 
                ;
    #delimit cr
    ** Recode for mortality rate loop
    #delimit ; 
    recode ghecause 
                    (1110 = 1 )
                    (1120 = 2 )
                    (1130 = 3 )
                    (1140 = 4 )
                    (1150 = 5 )
                    (620  = 6 )
                    (630  = 7 )
                    (640  = 8 )
                    (650  = 9 )
                    (660  = 10)
                    (670  = 11)
                    (680  = 12)
                    (690  = 13)
                    (700  = 14)
                    (710  = 15)
                    (720  = 16)
                    (730  = 17)
                    (740  = 18)
                    (742  = 19)
                    (745  = 20)
                    (750  = 21)
                    (751  = 22)
                    (752  = 23)
                    (753  = 24)
                    (754  = 25)
                    (755  = 26)
                    (760  = 27)
                    (770  = 28)
                    (1180 = 29)
                    (1190 = 30)
                    (800  = 31)
                    (830  = 32)
                    (840  = 33)
                    (850  = 34)
                    (860  = 35)
                    (870  = 36)
                    (880  = 37)
                    (890  = 38)
                    (900  = 39)
                    (910  = 40)
                    (920  = 41)
                    (950  = 42)
                    (960  = 43)
                    (970  = 44)
                    (980  = 45)
                    (990  = 46)
                    (1000 = 47)
                    (1530 = 48)
                    (1540 = 49)
                    (1550 = 50)
                    (1560 = 51)
                    (1570 = 52)
                    (1575 = 53)
                    (1580 = 54)
                    (1610 = 55)
                    (1620 = 56)
                    (1630 = 57)
                    /// BROAD causes
                    (0 = 100 )
                    (10 = 200 )
                    (600 = 300 )
                    (1100 = 400 )
                    (610  = 500 )
                    (1170 = 600 )
                    (820 = 800 )
                    (940 = 900 )
                    (1510 = 1000 );

    #delimit cr
    **keep if who_region==2
    drop if age<0 
    drop daly_low daly_up
    ** Collapse from countries to subregions
    collapse (sum) daly pop, by(ghecause year iso3n iso3c who_region sex age)

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
collapse (sum) daly pop, by(year ghecause iso3n iso3c who_region sex age18 agroup)

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
label var agroup "5 broad age groups: young children, youth, young adult, older adult, elderly"
label var age18 "5-year age groups: 18 groups"
label var daly "Disability Adjusted Life Years"
label var pop "regional populations" 
format pop %12.0fc 

** Direct standardization 
** Two methods (-dstdize- and -distrate-)
** gen daly = round(daly) 
** label var daly "DALY round to nearest integer" 
replace pop = round(pop) 


** Looped creation of Mortality Rates
** YEAR (2000 to 2019)
** SEX (1=male, 2=female)
** COD (10=COM, 600=NCD, 1510=INJ)
** recode ghecause 10=10 600=20 1510=30
* TODO: Change labelling for each disease group
#delimit ; 
label define ghecause_  
                    1  "Rheumatic heart disease"
                    2  "Hypertensive heart disease"
                    3  "Ischaemic heart disease"
                    4  "Stroke"
                    5  "Cardiomyopathy etc"
                    6  "Mouth and oropharynx cancers"
                    7  "Oesophagus cancer"
                    8  "Stomach cancer"
                    9  "Colon/rectum cancers"
                    10 "Liver cancer"
                    11 "Pancreas cancer"
                    12 "Trachea, bronchus, lung cancers"
                    13 "Melanoma and other skin cancers"
                    14 "Breast cancer"
                    15 "Cervix uteri cancer"
                    16 "Corpus uteri cancer"
                    17 "Ovary cancer"
                    18 "Prostate cancer"
                    19 "Testicular cancer"
                    20 "Kidney, renal pelvis, ureter cancer"
                    21 "Bladder cancer"
                    22 "Brain and nervous system cancers"
                    23 "Gallbladder, biliary tract cancer"
                    24 "Larynx cancer"
                    25 "Thyroid cancer"
                    26 "Mesothelioma"
                    27 "Lymphomas, multiple myeloma"
                    28 "Leukaemia"
                    29 "Chronic obstructive pulmonary disease"
                    30 "Asthma"
                    31 "Diabetes"
                    32 "Depressive disorders" 
                    33 "Bipolar disorder" 
                    34 "Schizophrenia" 
                    35 "Alcohol use disorders" 
                    36 "Drug use disorders" 
                    37 "Anxiety disorders" 
                    38 "Eating disorders" 
                    39 "Autism and Asperger syndrome" 
                    40 "Childhood behavioural disorders" 
                    41 "Idiopathic intellectual disability" 
                    42 "Alzheimer disease and other dementias"
                    43 "Parkinson disease"
                    44 "Epilepsy"
                    45 "Multiple sclerosis"
                    46 "Migraine"
                    47 "Non-migraine headache"
                    48 "Road injury"
                    49 "Poisonings" 
                    50 "Falls" 
                    51 "Fire and heat" 
                    52 "Drowning" 
                    53 "Mechanical forces" 
                    54 "Natural disasters" 
                    55 "Self-harm"
                    56 "Interpersonal violence"
                    57 "Collective violence"
                    100  "all causes"
                    200  "communicable"
                    300  "NCD"
                    400  "CVD"
                    500  "cancer"
                    600  "respiratory"
                    700  "diabetes"
                    800  "mental" 
                    900  "neurological"
                    1000 "injuries"
, modify;
#delimit cr
label values ghecause ghecause_ 

** Save dataset ready for direct standardization 
tempfile for_mr
save `for_mr' , replace


tempfile daly1 daly2 daly3 

** Collapse to region-level DALYs
** Collapse out age
preserve
    collapse (sum) daly pop, by(year ghecause who_region sex)
    egen region = group(who_region)  
    ** Variable level labelling
    *! change region code
    recode region 1=1000 
    * subregions
    #delimit ; 
    label define region_    100 "north america"
                            200 "central america"
                            300 "andean"
                            400 "southern cone" 
                            500 "latin caribbean"
                            600 "non-latin caribbean"
                            700 "brazil"
                            800 "mexico"
                            1000 "africa"
                            2000 "americas"
                            3000 "eastern mediterranean"
                            4000 "europe" 
                            5000 "south-east asia"
                            6000 "western pacific", modify;                     
    #delimit cr 
    label values region region_ 
    ** Variable Labelling
    label var region "WHO region "
    save `daly1', replace
restore

use `daly1', clear 

** Region labelling
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
                    33 "Venezuela"
                    
                    100 "north america"
                    200 "central america"
                    300 "andean"
                    400 "southern cone" 
                    500 "latin caribbean"
                    600 "non-latin caribbean"
                    700 "brazil"
                    800 "mexico"
                    1000 "africa"
                    2000 "americas"
                    3000 "eastern mediterranean"
                    4000 "europe" 
                    5000 "south-east asia"
                    6000 "western pacific", modify;                      
#delimit cr 
label values region region_ 

** Save the final DALY dataset
label data "DALYs : Countries, WHO regions"
save "`datapath'\from-who\chap2_000h_daly_AFR", replace

** Save the final DALY dataset - collapsed over SEX
collapse (sum) daly pop , by(who_region region year ghecause) 
gen sex = 3 
label data "DALYs : Countries, WHO regions"
save "`datapath'\from-who\chap2_000h_daly_both_AFR", replace
