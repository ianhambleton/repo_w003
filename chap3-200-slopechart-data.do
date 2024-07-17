** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			        chap2-006-initial-slopechart.do
    //  project:				        WHO Global Health Estimates
    //  analysts:				        Ian HAMBLETON
    // 	date last modified	            5-April-2021
    //  algorithm task			        Slopechart example

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
    log using "`logpath'\chap2-006-initial-slopechart", replace
** HEADER -----------------------------------------------------

** Dataset
input risk  caribbean   ca  na  sla tla r_car r_ca    r_na    r_sla   r_tla
1   1   1   3   4   4   1   1   0   0   0
2   2   3   4   2   2   1   1   0   0   0
3   3   2   2   3   1   1   1   1   0   0
4   4   7   1   1   3   0   1   0   1   1
5   5   5   5   5   5   1   1   0   0   0
6   6   6   6   6   6   0   0   0   0   0
7   7   8   7   8   7   1   0   0   0   0
8   8   4   8   7   8   1   1   1   0   0
end

#delimit ; 
label define risk_
                    1 "Glucose"
                    2 "Systolic"
                    3 "BMI"
                    4 "Tobacco"
                    5 "Diet"
                    6 "Alcohol"
                    7 "LDL"
                    8 "kidney", modify;
#delimit cr
label values risk risk_

** Export data for Figure 32
rename ca central_america
rename na north_america 
rename sla southern_la 
rename tla tropical_la 
rename r_car red_caribbean 
rename r_ca red_central_america 
rename r_na red_north_america 
rename r_sla red_southern_la 
rename r_tla red_tropical_la 
export excel "`outputpath'\reports\2024-edits\graphics\chap3_data.xlsx", sheet("figure-32", replace) first(var)

