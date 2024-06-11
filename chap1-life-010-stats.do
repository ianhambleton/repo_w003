** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-life-010-stats.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-Apr-2021
    //  algorithm task			    Chapter 1 - Life Expectancy

    ** General algorithm set-up
    version 16
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DATASETS to encrypted SharePoint folder
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap1-life-010-stats", replace
** HEADER -----------------------------------------------------

** ***************************************************************
** PLAN
**
** 1.   Using WHO regions and countries of the Americas.
**      Consider the following:
**      (a) Maps of the Americas with LE-0 in 2000, LE-0 in 2019, Change in LE-0
**      (b) Difference between LE in women and men 
**          - regional - chart with men centred at 0
**          - country - men on x, women on y. Diagonal=equality
**
** NOTE ON LENGTH 
** WorldHealthStats2020 is 26 pages with graphics
** Word count of each chapter:
**
** INTRODUCTION + KEY MESSAGES: 212 + 1145 = 1357
** CHAPTER 1: 368 + 476 + 565 + 235 + 201 
** CHAPTER 2: 392 + 99 + 247 + 178 + 614 + 38 + 172 + 135
** CHAPTER 3: 378 + 421 + 303 + 268 + 458 + 368
** CHAPTER 4: 349 + 176 + 136 + 374 + 204
** CHAPTER 5: 383 + 790 + 659
** ALL CHAPTERS: 8987
** FULL DOCUMENT: 1357 + 8987 = 10,344
** ***************************************************************

** LOAD LE for countries, regions, and globally
use "`datapath'\from-who\lifetables\who-lifetable-2019-all", clear 

** List LE0 for each WHO region, and globally
keep if agroup==1 & ghocode==35 
keep if (region=="GLOBAL" | region=="AFR" | region=="AMR" | region=="EMR" | region=="EUR" |                          ///
        region=="SEAR" | region=="WPR" | region=="WB_LI" | region=="WB_LMI" | region=="WB_UMI" | region=="WB_HI") & cname==""          
tabdisp region year sex , c(metric) format(%9.1f)



