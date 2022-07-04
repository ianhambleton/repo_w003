** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper1-110-population-paho-hia.do
    //  project:				    UN WPP (2019 edition)
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	24-Mar-2022
    //  algorithm task			    Importing the UN WPP data for the Americas

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
    log using "`logpath'\paper1-110-population-gbd-hia", replace
** HEADER -----------------------------------------------------


** ------------------------------------------------------------
** Population data from UN WPP (2019 release)
** 1. Women and Men combined
** ------------------------------------------------------------
** Downloaded from:
** https://population.un.org/wpp/Download/Standard/Population/
**
** FULL FILEPATH: 
** https://ghdx.healthdata.org/record/ihme-data/global-population-forecasts-2017-2100
/// import excel using "`datapath'/paho-hia/IHME_POP_2017_2100_POP_REFERENCE_Y2020M05D01.xlsx", clear sheet("IHME_POP_2017_2100_POP_REFERENC") cellrange(a1:n892417) first
/// keep if location_name=="Dominica" | location_name=="Bermuda" | location_name=="Barbados"
/// save "`datapath'/gbdpop", replace
use "`datapath'/gbdpop", clear
keep if year==2020 | year==2030 | year==2040 | year==2050 | year==2060
collapse (sum) val , by(year location_id location_name age_group_id age_group_name)
** Drop all ages
drop if age_group_id==22
bysort year location_name : egen agetot = sum(val)
bysort year location_name : egen age65t = sum(val) if age_group_id>=18
bysort year location_name : egen age65 = min(age65t)
keep if age_group_id==2
keep location_name year agetot age65
gen prop65 = (age65/agetot) * 100
sort location_name year 
gen ch65 = prop65 - prop65[_n-1] if location_name==location_name[_n-1]
** Table of results
format ch65 prop65 %9.1f 
list location_name year prop65 ch65 , table sepby(location_name) linesize(120)
