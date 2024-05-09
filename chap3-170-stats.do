** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap3-170-stats.do
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
    local datapath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap3-170-stats", replace
** HEADER -----------------------------------------------------


** -----------------------------------------------------
** TABLE PART ONE 
** DEATHS METRICS
** -----------------------------------------------------

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

** Mortality Rate statistics first
use "`datapath'\from-who\chap2_000_adjusted", clear
rename mortr arate
rename dalyr drate

keep if sex==3 & (year==2000 | year==2019) & region==2000
keep ghecause year daly dths pop_mortr
rename pop_mortr pop

** The 6 grouped causes
mark groups if ghecause==400 | ghecause==500 | ghecause==600 | ghecause==31 | ghecause==800 | ghecause==900 | ghecause==1000
bysort year groups : egen dtot = sum(dths)
format dths daly pop dtot %15.0fc






/*

drop pop 
keep if ghecause==31 | ghecause>=100
gen k=1
reshape wide daly dths, i(k) j(ghecause)


** -----------------------------------------------------
** Proportion of deaths / DALYs
** -----------------------------------------------------
** % NCDs / % Injuries of ALL-cause
gen p300 = (dths300/dths100) * 100
gen p1000 = (dths1000/dths100) * 100
** % Each grouped cause of ALL-Cause
gen p400 = (dths400/dths100) * 100
gen p500 = (dths500/dths100) * 100
gen p600 = (dths600/dths100) * 100
gen p31 = (dths31/dths100) * 100
gen p800 = (dths800/dths100) * 100
gen p900 = (dths900/dths100) * 100
** % ALL grouped causes of ALL-Cause
gen pgrouped = ( (dths400 + dths500 + dths600 + dths31 + dths800 + dths900 + dths1000) / dths100 ) * 100
gen grouped = dths400 + dths500 + dths600 + dths31 + dths800 + dths900 + dths1000
format grouped %15.1fc

/*
** % NCDs / % Injuries of ALL-cause
gen pd300 = (daly300/daly100) * 100
gen pd1000 = (daly1000/daly100) * 100
** % Each grouped cause of ALL-Cause
gen pd400 = (daly400/daly100) * 100
gen pd500 = (daly500/daly100) * 100
gen pd600 = (daly600/daly100) * 100
gen pd31 = (daly31/daly100) * 100
gen pd800 = (daly800/daly100) * 100
gen pd900 = (daly900/daly100) * 100
** % ALL grouped causes of ALL-Cause
gen pdgrouped = ( (daly400 + daly500 + daly600 + daly31 + daly800 + daly900 + daly1000) / daly100 ) * 100


order p*

