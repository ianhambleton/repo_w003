** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    extra-010-probdeath.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Summary graphic of MR change between 2000 and 2019

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
    log using "`logpath'\extra-010-probdeath", replace
** HEADER -----------------------------------------------------

** -----------------------------------------------------
** TEST CALCULATION USING AUSTRIA 2014
** -----------------------------------------------------
        input age deaths pop
        1   86      577713
        2   140     544966
        3   339     618886
        4   719     709478
        5   1360    682921
        6   1980    569842
        7   2939    471089
        8   4248    422748
        end

        ** (y5mx) 5-year age-specific mortality rates
        ** (y5qx) probability of death in each 5-year age group
        gen y5mx = deaths/pop 
        gen y5qx_t1 = (y5mx * 5) / (1 + y5mx)
        gen y5qx = 1 - y5qx_t1
        format y5mx y5qx %15.9fc

        ** Calculate product
        keep age y5qx 
        gen k = 1 
        reshape wide y5qx, i(k) j(age)

        ** Unconditional prob dying between 30 (age=7) and 69 (age=14)
        egen stat1 = rprod(y5qx1 y5qx2 y5qx3 y5qx4 y5qx5 y5qx6 y5qx7 y5qx8)
        gen q7030 = (1 - stat1) * 100



** -----------------------------------------------------
** AMERICAS 2019
** -----------------------------------------------------
** UNCONDITIONAL PROBABILITY OF DEATH 
**      Could repeat this for subregions or for 
**      individual countries by
**      extracting dataset from appropriate 
**      chap2 preparation DO file
** -----------------------------------------------------

** DEATHS by AGE
** DATASETS FROM: 
**      chap2-000a-mr-region-groups.do
**      chap2-000a-mr-region.do
tempfile t1 grouped1 
use "`datapath'\from-who\chap2_equiplot_mr_byage_groupeddeath", clear
keep if year==2019 & who_region==2
drop dths who_region year
save `grouped1' , replace

use "`datapath'\from-who\chap2_equiplot_mr_byage", clear
keep if year==2019 & who_region==2  
drop dths who_region year
append using `grouped1'

collapse (sum) deaths pop, by(ghecause age18 agroup)
sort ghecause age18
save `t1', replace

** 100 all causes
** 200 communicable
** 300 NCD
** 400 CVD
** 500 cancer
** 600 respiratory
** 31 diabetes
** 800 mental
** 900 neurological
** 1000 injuries
#delimit ;
label define ghecause_
                        100  "all causes"
                        200  "communicable"
                        300  "NCD"
                        400  "CVD"
                        500  "cancer"
                        600  "respiratory"
                        700   "diabetes"
                        800  "mental"
                        900  "neurological"
                        1000 "injuries", modify;
#delimit cr 
label values ghecause ghecause_


** Unconditional probability of dying between ageX and ageY
gen f30t69 = 0
replace f30t69 = 1 if age18>=7 & age18<=14
label var f30t69 "Age groups 30 to 69"

** (y5mx) 5-year age-specific mortality rates
** (y5qx) probability of death in each 5-year age group
gen y5mx = deaths/pop 
gen y5qx_t1 = (y5mx * 5) / (1 + y5mx)
gen y5qx = 1 - y5qx_t1
format y5mx y5qx %15.9fc

** Calculate product
keep ghecause age y5qx 
rename age18 age 
reshape wide y5qx, i(ghecause) j(age)

** Unconditional prob dying between BIRTH (age=1) and age 29 (age=6)
egen stat1 = rprod(y5qx1 y5qx2 y5qx3 y5qx4 y5qx5 y5qx6)
gen q25_0 = (1 - stat1) * 100

** Unconditional prob dying between 30 (age=7) and 69 (age=14)
egen stat2 = rprod(y5qx7 y5qx8 y5qx9 y5qx10 y5qx11 y5qx12 y5qx13 y5qx14)
gen q70_30 = (1 - stat2) * 100

** Unconditional prob dying between 70 (age=15) and 85 (age=17)
egen stat3 = rprod(y5qx15 y5qx16 y5qx17)
gen q85_70 = (1 - stat3) * 100

** Unconditional prob dying between 30 (age=7) and 85 (age=17)
egen stat4 = rprod(y5qx7 y5qx8 y5qx9 y5qx10 y5qx11 y5qx12 y5qx13 y5qx14 y5qx15 y5qx16 y5qx17)
gen q85_30 = (1 - stat4) * 100

format q* %9.2fc
keep ghecause q*