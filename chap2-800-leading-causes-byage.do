** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-800-leading-causes-byage.do
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
    local datapath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap2-800-leading-causes-byage", replace
** HEADER -----------------------------------------------------

** DEATHS by AGE
** DATASETS FROM: 
**      chap2-000a-mr-region-groups.do
**      chap2-000a-mr-region.do
tempfile t1 grouped1 
use "`datapath'\from-who\chap2_equiplot_mr_byage_groupeddeath", clear
keep if year==2019 & who_region==2
drop pop  who_region year
rename dths deaths
save `grouped1' , replace

use "`datapath'\from-who\chap2_equiplot_mr_byage", clear
keep if year==2019 & who_region==2  
drop pop who_region year
rename dths deaths
append using `grouped1'

gen age16 = 1       if age18==1
replace age16 = 2   if age18==2
replace age16 = 3   if age18==3
replace age16 = 4   if age18==4
replace age16 = 5   if age18==5
replace age16 = 6   if age18==6
replace age16 = 7   if age18==7
replace age16 = 8   if age18==8
replace age16 = 9   if age18==9
replace age16 = 10  if age18==10
replace age16 = 11  if age18==11
replace age16 = 12  if age18==12
replace age16 = 13  if age18==13
replace age16 = 14  if age18==14
replace age16 = 15  if age18==15
replace age16 = 16  if age18==16 | age18==17 | age18==18
collapse (sum) deaths, by(ghecause age16 agroup)
#delimit ; 
label define age16_     1 "0-4"
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
label values age16 age16_ 
sort ghecause age16
save `t1', replace

** DALY by AGE
** DATASETS FROM: 
**      chap2-000a-daly-region-groups.do
**      chap2-000a-daly-region.do
tempfile grouped2 
use "`datapath'\from-who\chap2_equiplot_daly_byage_groupeddeath", clear
keep if year==2019 & who_region==2
drop pop  who_region year
save `grouped2' , replace

use "`datapath'\from-who\chap2_equiplot_daly_byage", clear
keep if year==2019 & who_region==2 
drop pop who_region year 
append using `grouped2'
rename age18 age16
sort ghecause age16

** Merge and collapse to broad age groups 
merge 1:1 ghecause age16 using `t1' 
drop _merge age16

collapse (sum) daly deaths , by(ghecause agroup)
format deaths daly %15.0fc 
reshape wide daly deaths , i(ghecause) j(agroup)
egen deaths_tot = rowtotal(deaths1 deaths2 deaths3 deaths4 deaths5) 
egen daly_tot = rowtotal(daly1 daly2 daly3 daly4 daly5) 
sort ghecause deaths* daly* 
format deaths* daly* deaths_tot daly_tot %15.0fc 

** Leading causes by BROAD age bands 
keep if ghecause<=100 
gsort -ghecause
global ad1 = deaths1[1]
global ad2 = deaths2[1]
global ad3 = deaths3[1]
global ad4 = deaths4[1]
global ad5 = deaths5[1]

gen pd1 = (deaths1/$ad1) * 100
gen pd2 = (deaths2/$ad2) * 100
gen pd3 = (deaths3/$ad3) * 100
gen pd4 = (deaths4/$ad4) * 100
gen pd5 = (deaths5/$ad5) * 100
drop if ghecause==100
forval x = 1(1)5 { 
    gsort -deaths`x'
    dis "AGE GROUP IS " `x' 
    list ghecause deaths`x' pd`x'
}


