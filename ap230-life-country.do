** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    ap230-life-country.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	15-Apr-2021
    //  algorithm task			    Reading the WHO GHE dataset - Life Tables - Country-level data

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
    log using "`logpath'\ap230-life-country", replace
** HEADER -----------------------------------------------------


** ************************************************************
** 1. LOAD and prepare Life Table metadata
**! NOTE - Dominica available for downlaod but dataset is empty
**! NOTE - St.Kitts available for downlaod but dataset is empty
** ************************************************************
local country antigua argentina bahamas barbados belize bolivia brazil canada chile colombia costarica cuba dominicanrepublic ecuador elsalvador grenada guatemala guyana haiti honduras jamaica mexico nicaragua panama paraguay peru stlucia stvincent suriname trinidad uruguay usa venezuela

foreach x of local country {
    
    insheet using "`datapath'\from-who\lifetables\lifetable-2019-country-`x'.csv", clear comma names

    ** GHO metric code
    rename ghocode temp1 
    gen ghocode = . 
    replace ghocode = 29 if temp1 == "LIFE_0000000029"
    replace ghocode = 30 if temp1 == "LIFE_0000000030"
    replace ghocode = 31 if temp1 == "LIFE_0000000031"
    replace ghocode = 32 if temp1 == "LIFE_0000000032"
    replace ghocode = 33 if temp1 == "LIFE_0000000033"
    replace ghocode = 34 if temp1 == "LIFE_0000000034"
    replace ghocode = 35 if temp1 == "LIFE_0000000035"
    #delimit ;
    label define ghocode_   29 "nMx"
                            30 "nqx"
                            31 "lx"
                            32 "ndx"
                            33 "nLx"
                            34 "Tx"
                            35 "ex", modify;
    #delimit cr 
    label values ghocode ghocode_ 
    label var ghocode "GHO lifetable metric code. See -notes- for details."
    notes ghocode: 29 = nMx - age-specific death rate between ages x and x+n
    notes ghocode: 29 details at https://www.who.int/data/gho/indicator-metadata-registry/imr-details/29
    notes ghocode: 30 = nqx - probability of dying between ages x and x+n
    notes ghocode: 30 details at https://www.who.int/data/gho/indicator-metadata-registry/imr-details/30
    notes ghocode: 31 = lx - number of people left alive at age x
    notes ghocode: 31 details at https://www.who.int/data/gho/indicator-metadata-registry/imr-details/31
    notes ghocode: 32 = ndx - number of people dying between ages x and x+n
    notes ghocode: 32 details at https://www.who.int/data/gho/indicator-metadata-registry/imr-details/32
    notes ghocode: 33 = nLx - person-years lived between ages x and x+n
    notes ghocode: 33 details at https://www.who.int/data/gho/indicator-metadata-registry/imr-details/33
    notes ghocode: 34 = Tx - person-years lived above age x
    notes ghocode: 34 details at https://www.who.int/data/gho/indicator-metadata-registry/imr-details/34
    notes ghocode: 35 = ex - expectation of life at age x
    notes ghocode: 35 details at https://www.who.int/data/gho/indicator-metadata-registry/imr-details/35
    drop ghodisplay ghourl publishstatecode publishstatedisplay publishstateurl yeardisplay yearurl temp1


    ** Year
    rename yearcode year 
    label var year "Life table year"


    ** Country
    rename countrycode country 
    rename countrydisplay cname 
    drop countryurl
    label var country "country iso3 alphanumeric code"
    label var cname "country full name"

    ** Region
    rename regioncode region 
    label var region "Region"
    drop regiondisplay regionurl 


    ** World Bank region
    rename worldbankincomegroupcode wbregion 
    label var wbregion "World bank income group"
    drop worldbankincomegroupdisplay worldbankincomegroupurl


    ** Age groups 
    gen agroup = . 
    replace agroup = 1 if agegroupcode == "AGELT1"
    replace agroup = 2 if agegroupcode == "AGE1-4"
    replace agroup = 3 if agegroupcode == "AGE5-9"
    replace agroup = 4 if agegroupcode == "AGE10-14"
    replace agroup = 5 if agegroupcode == "AGE15-19"
    replace agroup = 6 if agegroupcode == "AGE20-24"
    replace agroup = 7 if agegroupcode == "AGE25-29"
    replace agroup = 8 if agegroupcode == "AGE30-34"
    replace agroup = 9 if agegroupcode == "AGE35-39"
    replace agroup = 10 if agegroupcode == "AGE40-44"
    replace agroup = 11 if agegroupcode == "AGE45-49"
    replace agroup = 12 if agegroupcode == "AGE50-54"
    replace agroup = 13 if agegroupcode == "AGE55-59"
    replace agroup = 14 if agegroupcode == "AGE60-64"
    replace agroup = 15 if agegroupcode == "AGE65-69"
    replace agroup = 16 if agegroupcode == "AGE70-74"
    replace agroup = 17 if agegroupcode == "AGE75-79"
    replace agroup = 18 if agegroupcode == "AGE80-84"
    replace agroup = 19 if agegroupcode == "AGE85PLUS"
    #delimit ; 
    label define agroup_ 1 "age < 1"
                        2 "age 1-4"
                        3 "age 5-9"
                        4 "age 10-14"
                        5 "age 15-19"
                        6 "age 20-24"
                        7 "age 25-29"
                        8 "age 30-34"
                        9 "age 35-39"
                        10 "age 40-44"
                        11 "age 45-49"
                        12 "age 50-54"
                        13 "age 55-59"
                        14 "age 60-64"
                        15 "age 65-69"
                        16 "age 70-74"
                        17 "age 75-79"
                        18 "age 80-84"
                        19 "age 85+", modify;
    #delimit cr 
    label values agroup agroup_
    drop agegroupdisplay agegroupurl agegroupcode
    label var agroup "Age groups in 5 year bands (19 groups)"

    ** SEX 
    gen sex = . 
    replace sex = 1 if sexcode=="FMLE"
    replace sex = 2 if sexcode=="MLE"
    replace sex = 3 if sexcode=="BTSX"
    label define sex_ 1 "female" 2 "male" 3 "both",modify 
    label values sex sex_ 
    drop sexcode sexdisplay sexurl 
    label var sex "Sex. 1=female, 2=male, 3=both"

    ** METRIC 
    rename displayvalue metric 
    drop numeric low high stderr stddev comments
    order year country cname region wbregion agroup sex ghocode 
    gsort year sex agroup ghocode
    label var metric "Life table value"

** Life Table dataset
    label data "WHO GHE 2019: Life Table Global"
    save "`datapath'\from-who\lifetables\who-lifetable-2019-`x'", replace
} 
