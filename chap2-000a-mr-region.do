** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-000a-mr-region-americas.do
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
    log using "`logpath'\chap2-000a-mr-region", replace
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
                ghecause==1630
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
                    (1630 = 57);
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `afr' , replace

** Americas (AMR)
use "`datapath'\from-who\who-ghe-deaths-001-who2-allcauses", replace
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
                ghecause==1630
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
                    (1630 = 57);
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `amr' , replace

** Eastern Mediterranean (EMR)
use "`datapath'\from-who\who-ghe-deaths-001-who3-allcauses", replace
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
                ghecause==1630
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
                    (1630 = 57);
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `emr' , replace

** Europe (EUR)
use "`datapath'\from-who\who-ghe-deaths-001-who4-allcauses", replace
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
                ghecause==1630
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
                    (1630 = 57);
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `eur' , replace

** South-East Asia (SEAR)
use "`datapath'\from-who\who-ghe-deaths-001-who5-allcauses", replace
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
                ghecause==1630
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
                    (1630 = 57);
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `sear' , replace

** Western Pacific (WPR)
use "`datapath'\from-who\who-ghe-deaths-001-who6-allcauses", replace
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
                ghecause==1630
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
                    (1630 = 57);
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `wpr' , replace

** Join the WHO regions
use `afr', clear 
    append using `amr'
    append using `emr'
    append using `eur'
    append using `sear'
    append using `wpr'
    **save "`datapath'\from-who\chap2_cvd_002", replace

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
, modify;
#delimit cr
label values ghecause ghecause_ 

** Save dataset ready for direct standardization 
tempfile for_mr
save `for_mr' , replace

** Save out a dataset

** 2019, Male, Communicable Disease
forval x = 2000(1)2019 {
    forval y = 1(1)2 {
        * TODO: Change next line for each disease group
        forval z = 1(1)57 {
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
use `f_2000_1_1' , clear

forval x = 2000(1)2019 {
    forval y = 1(1)2 {
        * TODO: Change range of loop for each disease group
        forval z = 1(1)57 {
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
, modify;
#delimit cr
label values ghecause ghecause_ 

** Save the final MR dataset
label data "Crude and Adjusted mortality rates: WHO regions"
save "`datapath'\from-who\chap2_000a_mr_region", replace







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
                ghecause==1630
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
                    (1630 = 57);
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `afr' , replace

** Americas (AMR)
use "`datapath'\from-who\who-ghe-deaths-001-who2-allcauses", replace
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
                ghecause==1630
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
                    (1630 = 57);
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `amr' , replace

** Eastern Mediterranean (EMR)
use "`datapath'\from-who\who-ghe-deaths-001-who3-allcauses", replace
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
                ghecause==1630
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
                    (1630 = 57);
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `emr' , replace

** Europe (EUR)
use "`datapath'\from-who\who-ghe-deaths-001-who4-allcauses", replace
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
                ghecause==1630
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
                    (1630 = 57);
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `eur' , replace

** South-East Asia (SEAR)
use "`datapath'\from-who\who-ghe-deaths-001-who5-allcauses", replace
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
                ghecause==1630
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
                    (1630 = 57);
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `sear' , replace

** Western Pacific (WPR)
use "`datapath'\from-who\who-ghe-deaths-001-who6-allcauses", replace
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
                ghecause==1630
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
                    (1630 = 57);
    #delimit cr
    drop if age<0 
    ** Collapse to WHO regions 
    collapse (sum) dths pop, by(ghecause year who_region sex age)
    save `wpr' , replace

** Join the WHO regions
use `afr', clear 
    append using `amr'
    append using `emr'
    append using `eur'
    append using `sear'
    append using `wpr'
    **save "`datapath'\from-who\chap2_cvd_002", replace

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
, modify;
#delimit cr
label values ghecause ghecause_ 

** Save dataset ready for direct standardization 
tempfile for_mr
save `for_mr' , replace

** Used for Equiplot by age 
** 18 age groups
** save "`datapath'\from-who\chap2_cvd_byage", replace



** 2019, Male, Communicable Disease
forval x = 2000(1)2019 {
        * TODO: Change next line for each disease group
        forval z = 1(1)57 {
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
use `f_2000_1' , clear

forval x = 2000(1)2019 {
        * TODO: Change range of loop for each disease group
        forval z = 1(1)57 {
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
, modify;
#delimit cr
label values ghecause ghecause_ 

** Save the final MR dataset
gen sex = 3
label data "Crude and Adjusted mortality rates: WHO regions"
save "`datapath'\from-who\chap2_000a_mr_region_both", replace




