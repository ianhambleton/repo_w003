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

local country antigua argentina bahamas barbados belize bolivia brazil canada chile colombia costarica cuba dominicanrepublic ecuador elsalvador grenada guatemala guyana haiti honduras jamaica mexico nicaragua panama paraguay peru stlucia stvincent suriname trinidad uruguay usa 
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
 
