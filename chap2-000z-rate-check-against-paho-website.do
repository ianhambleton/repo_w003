** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-000z-rate-check-against-paho-website.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	19-August-2021
    //  algorithm task			    Final datasets for general use

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
    log using "`logpath'\chap2-000z-rate-check-against-paho-website", replace
** HEADER -----------------------------------------------------

** Checking my calculated rates against rates as seen on PAHO portal
** https://www.paho.org/en/noncommunicable-diseases-and-mental-health/noncommunicable-diseases-and-mental-health-data-43
use "`datapath'\from-who\chap2_000_adjusted", clear

** Keep the same data from my dataset
tempfile ncd2019
keep if ghecause==300
keep if year==2019
keep if region<100 | region==2000
keep if sex==3
gsort -sex -mortr
merge m:1 region using "`datapath'\from-who\iso3c_merge"
drop _merge
save `ncd2019', replace

** Load the PAHO portal data
import excel using "`datapath'\from-who\Map_Full_Data_data", clear first
rename Iso3 iso3c 
rename Value mr_paho
keep iso3c mr_paho
merge 1:m iso3c using `ncd2019'
order mortr, after(mr_paho)

gen mr_diff = mr_paho - mortr
order mr_diff, after(mortr)
sort mr_diff
