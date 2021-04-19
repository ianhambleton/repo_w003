** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    p004-load-ghe-life-join.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	15-Apr-2021
    //  algorithm task			    Reading the WHO GHE dataset - Life Tables - Append the datasets

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
    log using "`logpath'\p004-load-ghe-life-join", replace
** HEADER -----------------------------------------------------

** Load global file 
use "`datapath'\from-who\lifetables\who-lifetable-2019-global", replace

local country antigua argentina bahamas barbados belize bolivia brazil canada chile colombia costarica cuba dominicanrepublic ecuador elsalvador grenada guatemala guyana haiti honduras jamaica mexico nicaragua panama paraguay peru stlucia stvincent suriname trinidad uruguay usa venezuela
local whoregion africa americas eastern-mediterranean europe south-east-asia western-pacific wb-low-income wb-low-middle-income wb-upper-middle-income wb-high-income

** Append regional files 
foreach x of local whoregion {
    append using "`datapath'\from-who\lifetables\who-lifetable-2019-`x'"
} 
** Append country files for Americas 
foreach x of local country {
    append using "`datapath'\from-who\lifetables\who-lifetable-2019-`x'"
} 
** Complete Life Table dataset
    label data "WHO GHE 2019: Life Table Global"
    save "`datapath'\from-who\lifetables\who-lifetable-2019-all", replace
 
** *******************************************
** Prepare Life Expectancy datasets
** *******************************************

** DATASET 1. Life expectancy at birth in 2000 and in 2019 
** We also want to ADD iso2c to dataset to help with creating MAP dataset  
use "`datapath'\from-owid\regions", clear
    kountry iso3c, from(iso3c) to(iso2c)
    rename _ISO2C_ iso2c 
    replace iso2c = "BL" if iso3c=="BLM"
    replace iso2c = "MF" if iso3c=="MAF"
    save "`datapath'\from-owid\americas-iso", replace

use "`datapath'\from-who\lifetables\who-lifetable-2019-all", replace
    keep if region=="AMR" 
    keep if agroup==1 
    keep if ghocode==35 
    keep if year==2000 | year==2019 
    rename country iso3c 
    merge m:1 iso3c using "`datapath'\from-owid\americas-iso"
    preserve
        drop _merge
        save "`datapath'\from-who\lifetables\americas-ex0-full", replace
    restore
    drop if _merge==2 
    drop _merge 
    sort region cname year sex agroup ghocode 
    save "`datapath'\from-who\lifetables\americas-ex0", replace

