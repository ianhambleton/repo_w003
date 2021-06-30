** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    p004-load-ghe-hale-whoregion.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	15-Apr-2021
    //  algorithm task			    Reading the WHO GHE dataset - Life Tables - WHO region

    ** General algorithm set-up
    version 16
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
    log using "`logpath'\p004-load-ghe-hale-whoregion", replace
** HEADER -----------------------------------------------------


** ************************************************************
** 1. LOAD and prepare HALE dataset
** ************************************************************
insheet using "`datapath'\from-who\lifetables\hale-2019-region.csv", clear comma names

** Age (agroup to match the categories used in the LifeTable dataset)
gen agroup = 1 if ghocode=="WHOSIS_000002"
replace agroup = 14 if ghocode=="WHOSIS_000007"
order agroup
drop ghocode ghodisplay ghourl publishstatecode publishstatedisplay publishstateurl
label var agroup "HALE at birth or at age 60"

** Year 
rename yearcode year 
drop yeardisplay yearurl 
order year, after(agroup) 
label var year "HALE available at 2000, 2010, 2015, 2019"

** Region 
rename regioncode region   
drop regiondisplay regionurl worldbankincomegroupcode worldbankincomegroupdisplay worldbankincomegroupurl
label var region "WHO world regions"

** Sex
gen sex = . 
replace sex = 1 if sexcode=="FMLE"
replace sex = 2 if sexcode=="MLE"
replace sex = 3 if sexcode=="BTSX"
label define sex_ 1 "female" 2 "male" 3 "both",modify 
label values sex sex_ 
drop sexcode sexdisplay sexurl 
order sex, after(region) 
label var sex "men (2), women (1), both sexes (3)"

** HALE value
rename numeric metric
drop displayvalue low high stderr stddev comments 
label var metric "HALE value"
order metric, after(sex) 

** GHO CODE
gen ghocode = 100

order region year agroup sex metric 
sort region year agroup sex 

** HALE dataset
label data "WHO GHE 2019: HALE region"
save "`datapath'\from-who\lifetables\who-hale-2019-regions", replace



