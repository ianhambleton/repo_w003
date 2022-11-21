** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper1-150-health-table2-version3.do
    //  project:				    UN WPP (2019 edition)
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	22-Jun-2022
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
    log using "`logpath'\paper1-150-health-table2-version3", replace
** HEADER -----------------------------------------------------


** -----------------------------------------------------
** GRAPHICS COLOR SCHEME
** -----------------------------------------------------
    colorpalette ptol, rainbow n(12)  nograph
    local list r(p) 
    ** Mortality Rate
    local mrate `r(p1)'
    ** DALY
    local daly `r(p4)'
    ** Improve and worsen
    local improve `r(p7)'
    local worsen `r(p12)'

    ** generate a local for the D3 color scheme
    colorpalette d3, 20 n(20) nograph
    local list r(p) 
    ** CVD
    local cvd1 `r(p9)'
    local cvd2 `r(p10)'
    ** Cancer 
    local can1 `r(p1)'
    local can2 `r(p2)'
    ** CRD
    local crd1 `r(p5)'
    local crd2 `r(p6)'
    ** Diabetes
    local dia1 `r(p17)'
    local dia2 `r(p18)'
    ** Mental Health
    local men1 `r(p3)'
    local men2 `r(p4)'
    ** External causes
    local inj1 `r(p7)'
    local inj2 `r(p8)'



** -----------------------------------------------------
** TABLE DATA IMPORT
** DEATHS METRICS
** -----------------------------------------------------
** use "`datapath'\from-who\paper1-chap2_000_mr", clear
use "`datapath'\from-who\mortalityrate_12", clear

** Create new GHE CoD order for Table 
** 100  All causes
** 300  NCDs
** 400  CVDs
** 500  Cancer
** 600  Respiratory
**  31  Diabetes
** 800  Mental
** 900  Neurological

gen     cod = 1 if ghecause==100 
replace cod = 2 if ghecause==300
replace cod = 3 if ghecause==400
replace cod = 4 if ghecause==500
replace cod = 5 if ghecause==600
replace cod = 6 if ghecause==700
replace cod = 7 if ghecause==800
replace cod = 8 if ghecause==900
replace cod = 9 if ghecause==50

#delimit ; 
label define cod_   1 "All cause" 
                    2 "NCDs" 
                    3 "CVDs" 
                    4 "Cancer" 
                    5 "Respiratory"
                    6 "Diabetes"
                    7 "Mental"
                    8 "Neurological"
                    9 "Combined NCDs", modify ;
#delimit cr
label values cod cod_ 
keep if cod<=9

** Restrict to Americas in 2000 and 2019
keep if region==2000
keep if year==2000 | year==2019
drop region
format pop %15.0fc
rename pop pop_
rename arate rate 
rename cases count
gen type = 1
tempfile deaths
save `deaths' , replace



** -----------------------------------------------------
** TABLE DATA IMPORT
** DALY METRICS
** -----------------------------------------------------
use "`datapath'\from-who\dalyrate_12", clear

** Create new GHE CoD order for Table 
** 100  All causes
** 300  NCDs
** 400  CVDs
** 500  Cancer
** 600  Respiratory
**  31  Diabetes
** 800  Mental
** 900  Neurological

gen     cod = 1 if ghecause==100 
replace cod = 2 if ghecause==300
replace cod = 3 if ghecause==400
replace cod = 4 if ghecause==500
replace cod = 5 if ghecause==600
replace cod = 6 if ghecause==700
replace cod = 7 if ghecause==800
replace cod = 8 if ghecause==900
replace cod = 9 if ghecause==50

#delimit ; 
label define cod_   1 "All cause" 
                    2 "NCDs" 
                    3 "CVDs" 
                    4 "Cancer" 
                    5 "Respiratory"
                    6 "Diabetes"
                    7 "Mental"
                    8 "Neurological"
                    9 "Combined NCDs", modify ;
#delimit cr
label values cod cod_ 
keep if cod<=9

** Restrict to Americas in 2000 and 2019
keep if region==2000
keep if year==2000 | year==2019
drop region 
format pop %15.0fc
rename pop pop_
rename arate rate 
rename cases count 
gen type = 2
tempfile dalys
save `dalys' , replace




** -----------------------------------------------------
** TABLE DATA IMPORT
** YLL METRICS
** -----------------------------------------------------
use "`datapath'\from-who\yllrate_12", clear

** Create new GHE CoD order for Table 
** 100  All causes
** 300  NCDs
** 400  CVDs
** 500  Cancer
** 600  Respiratory
**  31  Diabetes
** 800  Mental
** 900  Neurological

gen     cod = 1 if ghecause==100 
replace cod = 2 if ghecause==300
replace cod = 3 if ghecause==400
replace cod = 4 if ghecause==500
replace cod = 5 if ghecause==600
replace cod = 6 if ghecause==700
replace cod = 7 if ghecause==800
replace cod = 8 if ghecause==900
replace cod = 9 if ghecause==50

#delimit ; 
label define cod_   1 "All cause" 
                    2 "NCDs" 
                    3 "CVDs" 
                    4 "Cancer" 
                    5 "Respiratory"
                    6 "Diabetes"
                    7 "Mental"
                    8 "Neurological"
                    9 "Combined NCDs", modify ;
#delimit cr
label values cod cod_ 
keep if cod<=9

** Restrict to Americas in 2000 and 2019
keep if region==2000
keep if year==2000 | year==2019
drop region 
format pop %15.0fc
rename pop pop_
rename arate rate 
rename cases count 
gen type = 3
tempfile ylls
save `ylls' , replace



** -----------------------------------------------------
** TABLE DATA IMPORT
** YLDs METRICS
** -----------------------------------------------------
use "`datapath'\from-who\yldrate_12", clear

** Create new GHE CoD order for Table 
** 100  All causes
** 300  NCDs
** 400  CVDs
** 500  Cancer
** 600  Respiratory
**  31  Diabetes
** 800  Mental
** 900  Neurological

gen     cod = 1 if ghecause==100 
replace cod = 2 if ghecause==300
replace cod = 3 if ghecause==400
replace cod = 4 if ghecause==500
replace cod = 5 if ghecause==600
replace cod = 6 if ghecause==700
replace cod = 7 if ghecause==800
replace cod = 8 if ghecause==900
replace cod = 9 if ghecause==50

#delimit ; 
label define cod_   1 "All cause" 
                    2 "NCDs" 
                    3 "CVDs" 
                    4 "Cancer" 
                    5 "Respiratory"
                    6 "Diabetes"
                    7 "Mental"
                    8 "Neurological"
                    9 "Combined NCDs", modify ;
#delimit cr
label values cod cod_ 
keep if cod<=9

** Restrict to Americas in 2000 and 2019
keep if region==2000
keep if year==2000 | year==2019
drop region 
format pop %15.0fc
rename pop pop_
rename arate rate 
rename cases count 
gen type = 4
tempfile ylds
save `ylds' , replace



** Join the DEATHS AND DALYS datasets
use `deaths' , clear 
append using `dalys'
append using `ylls'
append using `ylds'

label define type_ 1 "deaths" 2 "daly" 3 "yll" 4 "yld" , modify 
label values type type_ 
order cod type , after(ghecause)
replace crate = crate * 100000
replace rate = rate * 100000
format count %15.1fc 
format rate %9.1fc 
drop ghecause 


** -----------------------------------------------------
** COLUMN 3
** Outputs: Total Deaths / Total DALYs 
** WOMEN in 2019
** -----------------------------------------------------
** Number of deaths in the Americas in 2000 and 2019 
** by GHE CoD 
** DEATHS.   
preserve 
    keep if type==1 & year==2019 & sex==2
    ** collapse (sum) dths, by(cod)
    tabdisp cod  , cell(count) format(%10.0fc)
    sort cod 

    gen count_int = round(count)
    mkmat cod count_int , matrix(col3a)
    matrix list col3a
    forval x = 1(1)9 {
        global count`x'_3a = col3a[`x',2]
    }
restore
** DALYs.  
preserve 
    keep if type==2 & year==2019 & sex==2
    ** collapse (sum) daly, by(cod)
    tabdisp cod  , cell(count) format(%10.0fc)
    sort cod 
    gen count_int = round(count)
    mkmat cod count_int , matrix(col3b)
    matrix list col3b
    forval x = 1(1)9 {
        global count`x'_3b = col3b[`x',2]
    }
restore
** YLLs.  
preserve 
    keep if type==3 & year==2019 & sex==2
    ** collapse (sum) daly, by(cod)
    tabdisp cod  , cell(count) format(%10.0fc)
    sort cod 
    gen count_int = round(count)
    mkmat cod count_int , matrix(col3c)
    matrix list col3c
    forval x = 1(1)9 {
        global count`x'_3c = col3c[`x',2]
    }
restore
** YLDs.  
preserve 
    keep if type==4 & year==2019 & sex==2
    ** collapse (sum) daly, by(cod)
    tabdisp cod  , cell(count) format(%10.0fc)
    sort cod 
    gen count_int = round(count)
    mkmat cod count_int , matrix(col3d)
    matrix list col3d
    forval x = 1(1)9 {
        global count`x'_3d = col3d[`x',2]
    }
restore



** -----------------------------------------------------
** COLUMN 4
** Outputs: Total Deaths / Total DALYs
** MEN in 2019
** -----------------------------------------------------
** Number of deaths in the Americas in 2000 and 2019 
** by GHE CoD 
preserve 
    keep if type==1 & year==2019 & sex==1
    ** collapse (sum) dths, by(cod)
    tabdisp cod  , cell(count) format(%10.0fc)
    sort cod 

    gen count_int = round(count)
    mkmat cod count_int , matrix(col4a)
    matrix list col4a
    forval x = 1(1)9 {
        global count`x'_4a = col4a[`x',2]
    }
restore
** DALYs. 
preserve 
    keep if type==2 & year==2019 & sex==1
    ** collapse (sum) daly, by(cod)
    tabdisp cod  , cell(count) format(%10.0fc)
    sort cod 
    gen count_int = round(count)
    mkmat cod count_int , matrix(col4b)
    matrix list col4b
    forval x = 1(1)9 {
        global count`x'_4b = col4b[`x',2]
    }
restore
** YLLs. 
preserve 
    keep if type==3 & year==2019 & sex==1
    ** collapse (sum) daly, by(cod)
    tabdisp cod  , cell(count) format(%10.0fc)
    sort cod 
    gen count_int = round(count)
    mkmat cod count_int , matrix(col4c)
    matrix list col4c
    forval x = 1(1)9 {
        global count`x'_4c = col4c[`x',2]
    }
restore
** YLDs.  
preserve 
    keep if type==4 & year==2019 & sex==1
    ** collapse (sum) daly, by(cod)
    tabdisp cod  , cell(count) format(%10.0fc)
    sort cod 
    gen count_int = round(count)
    mkmat cod count_int , matrix(col4d)
    matrix list col4d
    forval x = 1(1)9 {
        global count`x'_4d = col4d[`x',2]
    }
restore

** -----------------------------------------------------
** COLUMN 5
** Outputs: Mortality Rate / DALY rate
** WOMEN in 2019
** -----------------------------------------------------
** Mortality Rate in 2000
preserve
    sort sex cod 
    keep if type==1 & year==2019 & sex==2
    tabdisp cod , cell(rate) format(%6.1fc) 
    sort cod 
    gen rate_int = round(rate, 0.1)
    mkmat cod rate_int , matrix(col5a)
    matrix list col5a
    forval x = 1(1)9 {
        global rate`x'_5a = col5a[`x',2]
    }
restore 
** DALY Rate in 2000
preserve
    sort sex cod 
    keep if type==2 & year==2019 & sex==2
    tabdisp cod , cell(rate) format(%6.1fc) 
    sort cod 
    gen rate_int = round(rate, 0.1)
    mkmat cod rate_int , matrix(col5b)
    matrix list col5b
    forval x = 1(1)9 {
        global rate`x'_5b = col5b[`x',2]
    }
restore 
** YLL Rate in 2000
preserve
    sort sex cod 
    keep if type==3 & year==2019 & sex==2
    tabdisp cod , cell(rate) format(%6.1fc) 
    sort cod 
    gen rate_int = round(rate, 0.1)
    mkmat cod rate_int , matrix(col5c)
    matrix list col5c
    forval x = 1(1)9 {
        global rate`x'_5c = col5c[`x',2]
    }
restore 
** YLD Rate in 2000
preserve
    sort sex cod 
    keep if type==4 & year==2019 & sex==2
    tabdisp cod , cell(rate) format(%6.1fc) 
    sort cod 
    gen rate_int = round(rate, 0.1)
    mkmat cod rate_int , matrix(col5d)
    matrix list col5d
    forval x = 1(1)9 {
        global rate`x'_5d = col5d[`x',2]
    }
restore 



** -----------------------------------------------------
** COLUMN 6
** Outputs: Mortality Rate / DALY rate
** MEN in 2019
** -----------------------------------------------------
** Mortality Rate in 2019
preserve
    sort sex cod 
    keep if type==1 & year==2019 & sex==1
    ** Women and Men combined  
    tabdisp cod , cell(rate) format(%6.1fc) 
    sort cod 
    gen rate_int = round(rate, 0.1)
    mkmat cod rate_int , matrix(col6a)
    matrix list col6a
    forval x = 1(1)9 {
        global rate`x'_6a = col6a[`x',2]
    }
restore 
** DALY Rate in 2019
preserve
    sort sex cod 
    keep if type==2 & year==2019 & sex==1
    ** Women and Men combined  
    tabdisp cod , cell(rate) format(%6.1fc) 
    sort cod 
    gen rate_int = round(rate, 0.1)
    mkmat cod rate_int , matrix(col6b)
    matrix list col6b
    forval x = 1(1)9 {
        global rate`x'_6b = col6b[`x',2]
    }
restore 
** YLL Rate in 2019
preserve
    sort sex cod 
    keep if type==3 & year==2019 & sex==1
    ** Women and Men combined  
    tabdisp cod , cell(rate) format(%6.1fc) 
    sort cod 
    gen rate_int = round(rate, 0.1)
    mkmat cod rate_int , matrix(col6c)
    matrix list col6c
    forval x = 1(1)9 {
        global rate`x'_6c = col6c[`x',2]
    }
restore 
** YLD Rate in 2019
preserve
    sort sex cod 
    keep if type==4 & year==2019 & sex==1
    ** Women and Men combined  
    tabdisp cod , cell(rate) format(%6.1fc) 
    sort cod 
    gen rate_int = round(rate, 0.1)
    mkmat cod rate_int , matrix(col6d)
    matrix list col6d
    forval x = 1(1)9 {
        global rate`x'_6d = col6d[`x',2]
    }
restore 



** -----------------------------------------------------
** COLUMN 7
** Outputs: Change in Rate between 2000 and 2019 
** WOMEN
** -----------------------------------------------------
** DTH: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==1 & sex==2 & (year==2000 | year==2019)
    keep type year cod rate 
    reshape wide rate, i(type cod) j(year)

    ** absolute change
    gen rate_ac = sqrt((rate2000 - rate2019)^2)
    ** percentage change
    gen rate_pc = ( (rate2019 - rate2000) / rate2000 ) * 100
    gen rate_pc_abs = ( (sqrt((rate2019 - rate2000)^2)) / rate2000 ) * 100

    sort cod 
    gen rate_pc_int = round(rate_pc, 0.1)
    mkmat cod rate_pc_int , matrix(col7a)
    matrix list col7a
    forval x = 1(1)9 {
        global pc`x'_7a = col7a[`x',2]
    } 
restore
** DALY: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==2 & sex==2 & (year==2000 | year==2019)
    keep type year cod rate 
    reshape wide rate, i(type cod) j(year)

    ** absolute change
    gen rate_ac = sqrt((rate2000 - rate2019)^2)
    ** percentage change
    gen rate_pc = ( (rate2019 - rate2000) / rate2000 ) * 100
    gen rate_pc_abs = ( (sqrt((rate2019 - rate2000)^2)) / rate2000 ) * 100

    sort cod 
    gen rate_pc_int = round(rate_pc, 0.1)
    mkmat cod rate_pc_int , matrix(col7b)
    matrix list col7b
    forval x = 1(1)9 {
        global pc`x'_7b = col7b[`x',2]
    } 
restore
** YLL: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==3 & sex==2 & (year==2000 | year==2019)
    keep type year cod rate 
    reshape wide rate, i(type cod) j(year)

    ** absolute change
    gen rate_ac = sqrt((rate2000 - rate2019)^2)
    ** percentage change
    gen rate_pc = ( (rate2019 - rate2000) / rate2000 ) * 100
    gen rate_pc_abs = ( (sqrt((rate2019 - rate2000)^2)) / rate2000 ) * 100

    sort cod 
    gen rate_pc_int = round(rate_pc, 0.1)
    mkmat cod rate_pc_int , matrix(col7c)
    matrix list col7c
    forval x = 1(1)9 {
        global pc`x'_7c = col7c[`x',2]
    } 
restore
** YLD: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==4 & sex==2 & (year==2000 | year==2019)
    keep type year cod rate 
    reshape wide rate, i(type cod) j(year)

    ** absolute change
    gen rate_ac = sqrt((rate2000 - rate2019)^2)
    ** percentage change
    gen rate_pc = ( (rate2019 - rate2000) / rate2000 ) * 100
    gen rate_pc_abs = ( (sqrt((rate2019 - rate2000)^2)) / rate2000 ) * 100

    sort cod 
    gen rate_pc_int = round(rate_pc, 0.1)
    mkmat cod rate_pc_int , matrix(col7d)
    matrix list col7d
    forval x = 1(1)9 {
        global pc`x'_7d = col7d[`x',2]
    } 
restore


** -----------------------------------------------------
** COLUMN 8
** Outputs: Change in Number between 2000 and 2019 
** WOMEN
** -----------------------------------------------------
** DTH: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==1 & sex==2 & (year==2000 | year==2019)
    keep type year cod count 
    reshape wide count, i(type cod) j(year)

    ** absolute change
    gen count_ac = sqrt((count2000 - count2019)^2)
    ** percentage change
    gen count_pc = ( (count2019 - count2000) / count2000 ) * 100
    gen count_pc_abs = ( (sqrt((count2019 - count2000)^2)) / count2000 ) * 100

    sort cod 
    gen count_pc_int = round(count_pc, 0.1)
    mkmat cod count_pc_int , matrix(col8a)
    matrix list col8a
    forval x = 1(1)9 {
        global pnum`x'_8a = col8a[`x',2]
    } 
restore
** DALY: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==2 & sex==2 & (year==2000 | year==2019)
    keep type year cod count 
    reshape wide count, i(type cod) j(year)

    ** absolute change
    gen count_ac = sqrt((count2000 - count2019)^2)
    ** percentage change
    gen count_pc = ( (count2019 - count2000) / count2000 ) * 100
    gen count_pc_abs = ( (sqrt((count2019 - count2000)^2)) / count2000 ) * 100

    sort cod 
    gen count_pc_int = round(count_pc, 0.1)
    mkmat cod count_pc_int , matrix(col8b)
    matrix list col8b
    forval x = 1(1)9 {
        global pnum`x'_8b = col8b[`x',2]
    } 
restore
** YLL: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==3 & sex==2 & (year==2000 | year==2019)
    keep type year cod count 
    reshape wide count, i(type cod) j(year)

    ** absolute change
    gen count_ac = sqrt((count2000 - count2019)^2)
    ** percentage change
    gen count_pc = ( (count2019 - count2000) / count2000 ) * 100
    gen count_pc_abs = ( (sqrt((count2019 - count2000)^2)) / count2000 ) * 100

    sort cod 
    gen count_pc_int = round(count_pc, 0.1)
    mkmat cod count_pc_int , matrix(col8c)
    matrix list col8c
    forval x = 1(1)9 {
        global pnum`x'_8c = col8c[`x',2]
    } 
restore
** YLD: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==4 & sex==2 & (year==2000 | year==2019)
    keep type year cod count 
    reshape wide count, i(type cod) j(year)

    ** absolute change
    gen count_ac = sqrt((count2000 - count2019)^2)
    ** percentage change
    gen count_pc = ( (count2019 - count2000) / count2000 ) * 100
    gen count_pc_abs = ( (sqrt((count2019 - count2000)^2)) / count2000 ) * 100

    sort cod 
    gen count_pc_int = round(count_pc, 0.1)
    mkmat cod count_pc_int , matrix(col8d)
    matrix list col8d
    forval x = 1(1)9 {
        global pnum`x'_8d = col8d[`x',2]
    } 
restore



** -----------------------------------------------------
** COLUMN 9
** Outputs: Change in Rate between 2000 and 2019 
** MEN
** -----------------------------------------------------
** DTH: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==1 & sex==1 & (year==2000 | year==2019)
    keep type year cod rate 
    reshape wide rate, i(type cod) j(year)

    ** absolute change
    gen rate_ac = sqrt((rate2000 - rate2019)^2)
    ** percentage change
    gen rate_pc = ( (rate2019 - rate2000) / rate2000 ) * 100
    gen rate_pc_abs = ( (sqrt((rate2019 - rate2000)^2)) / rate2000 ) * 100

    sort cod 
    gen rate_pc_int = round(rate_pc, 0.1)
    mkmat cod rate_pc_int , matrix(col9a)
    matrix list col9a
    forval x = 1(1)9 {
        global pc`x'_9a = col9a[`x',2]
    } 
restore
** DALY: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==2 & sex==1 & (year==2000 | year==2019)
    keep type year cod rate 
    reshape wide rate, i(type cod) j(year)

    ** absolute change
    gen rate_ac = sqrt((rate2000 - rate2019)^2)
    ** percentage change
    gen rate_pc = ( (rate2019 - rate2000) / rate2000 ) * 100
    gen rate_pc_abs = ( (sqrt((rate2019 - rate2000)^2)) / rate2000 ) * 100

    sort cod 
    gen rate_pc_int = round(rate_pc, 0.1)
    mkmat cod rate_pc_int , matrix(col9b)
    matrix list col9b
    forval x = 1(1)9 {
        global pc`x'_9b = col9b[`x',2]
    } 
restore
** YLL: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==3 & sex==1 & (year==2000 | year==2019)
    keep type year cod rate 
    reshape wide rate, i(type cod) j(year)

    ** absolute change
    gen rate_ac = sqrt((rate2000 - rate2019)^2)
    ** percentage change
    gen rate_pc = ( (rate2019 - rate2000) / rate2000 ) * 100
    gen rate_pc_abs = ( (sqrt((rate2019 - rate2000)^2)) / rate2000 ) * 100

    sort cod 
    gen rate_pc_int = round(rate_pc, 0.1)
    mkmat cod rate_pc_int , matrix(col9c)
    matrix list col9c
    forval x = 1(1)9 {
        global pc`x'_9c = col9c[`x',2]
    } 
restore
** YLD: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==4 & sex==1 & (year==2000 | year==2019)
    keep type year cod rate 
    reshape wide rate, i(type cod) j(year)

    ** absolute change
    gen rate_ac = sqrt((rate2000 - rate2019)^2)
    ** percentage change
    gen rate_pc = ( (rate2019 - rate2000) / rate2000 ) * 100
    gen rate_pc_abs = ( (sqrt((rate2019 - rate2000)^2)) / rate2000 ) * 100

    sort cod 
    gen rate_pc_int = round(rate_pc, 0.1)
    mkmat cod rate_pc_int , matrix(col9d)
    matrix list col9d
    forval x = 1(1)9 {
        global pc`x'_9d = col9d[`x',2]
    } 
restore


** -----------------------------------------------------
** COLUMN 10
** Outputs: Change in Number between 2000 and 2019 
** MEN
** -----------------------------------------------------
** DTH: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==1 & sex==1 & (year==2000 | year==2019)
    keep type year cod count 
    reshape wide count, i(type cod) j(year)

    ** absolute change
    gen count_ac = sqrt((count2000 - count2019)^2)
    ** percentage change
    gen count_pc = ( (count2019 - count2000) / count2000 ) * 100
    gen count_pc_abs = ( (sqrt((count2019 - count2000)^2)) / count2000 ) * 100

    sort cod 
    gen count_pc_int = round(count_pc, 0.1)
    mkmat cod count_pc_int , matrix(col10a)
    matrix list col10a
    forval x = 1(1)9 {
        global pnum`x'_10a = col10a[`x',2]
    } 
restore
** DALY: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==2 & sex==1 & (year==2000 | year==2019)
    keep type year cod count 
    reshape wide count, i(type cod) j(year)

    ** absolute change
    gen count_ac = sqrt((count2000 - count2019)^2)
    ** percentage change
    gen count_pc = ( (count2019 - count2000) / count2000 ) * 100
    gen count_pc_abs = ( (sqrt((count2019 - count2000)^2)) / count2000 ) * 100

    sort cod 
    gen count_pc_int = round(count_pc, 0.1)
    mkmat cod count_pc_int , matrix(col10b)
    matrix list col10b
    forval x = 1(1)9 {
        global pnum`x'_10b = col10b[`x',2]
    } 
restore
** YLL: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==3 & sex==1 & (year==2000 | year==2019)
    keep type year cod count 
    reshape wide count, i(type cod) j(year)

    ** absolute change
    gen count_ac = sqrt((count2000 - count2019)^2)
    ** percentage change
    gen count_pc = ( (count2019 - count2000) / count2000 ) * 100
    gen count_pc_abs = ( (sqrt((count2019 - count2000)^2)) / count2000 ) * 100

    sort cod 
    gen count_pc_int = round(count_pc, 0.1)
    mkmat cod count_pc_int , matrix(col10c)
    matrix list col10c
    forval x = 1(1)9 {
        global pnum`x'_10c = col10c[`x',2]
    } 
restore
** YLD: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==4 & sex==1 & (year==2000 | year==2019)
    keep type year cod count 
    reshape wide count, i(type cod) j(year)

    ** absolute change
    gen count_ac = sqrt((count2000 - count2019)^2)
    ** percentage change
    gen count_pc = ( (count2019 - count2000) / count2000 ) * 100
    gen count_pc_abs = ( (sqrt((count2019 - count2000)^2)) / count2000 ) * 100

    sort cod 
    gen count_pc_int = round(count_pc, 0.1)
    mkmat cod count_pc_int , matrix(col10d)
    matrix list col10d
    forval x = 1(1)9 {
        global pnum`x'_10d = col10d[`x',2]
    } 
restore

** -----------------------------------------------------
** WOMEN AND MEN COMBINED
** STATS for RESULTS text 
** -----------------------------------------------------

** Mortality Rate in 2000 and 2019
preserve
    sort sex cod 
    keep if type==1 & sex==3
    tabdisp cod year, cell(rate) format(%6.1fc) 
restore 
** Improvement between 2000 and 2019
** DTH: Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==1 & sex==3 & (year==2000 | year==2019)
    keep type year cod rate year
    reshape wide rate, i(type cod) j(year)
    ** absolute change
    gen rate_ac = sqrt((rate2000 - rate2019)^2)
    ** percentage change
    gen rate_pc = ( (rate2019 - rate2000) / rate2000 ) * 100
    gen rate_pc_abs = ( (sqrt((rate2019 - rate2000)^2)) / rate2000 ) * 100
    tabdisp cod , cell(rate_pc) format(%6.1fc) 
restore

** DALY: Absolute / Relative Change between 2000 and 2019
** DALY Rate in 2000 and 2019
preserve
    sort sex cod 
    keep if type==2 & sex==3
    tabdisp cod year, cell(rate) format(%12.1fc) 
restore 
preserve
    keep if type==2 & sex==3 & (year==2000 | year==2019)
    keep type year cod rate year
    reshape wide rate, i(type cod) j(year)
    ** absolute change
    gen rate_ac = sqrt((rate2000 - rate2019)^2)
    ** percentage change
    gen rate_pc = ( (rate2019 - rate2000) / rate2000 ) * 100
    gen rate_pc_abs = ( (sqrt((rate2019 - rate2000)^2)) / rate2000 ) * 100
    tabdisp cod , cell(rate_pc) format(%12.1fc) 
restore

** DTH: Absolute / Relative Change between 2000 and 2019
** Mortality Rate in 2000 and 2019
preserve
    sort sex cod 
    keep if type==1 & sex==3
    tabdisp cod year, cell(count) format(%15.1fc) 
restore 
preserve
    keep if type==1 & sex==3 & (year==2000 | year==2019)
    keep type year cod count 
    reshape wide count, i(type cod) j(year)

    ** absolute change
    gen count_ac = sqrt((count2000 - count2019)^2)
    ** percentage change
    gen count_pc = ( (count2019 - count2000) / count2000 ) * 100
    gen count_pc_abs = ( (sqrt((count2019 - count2000)^2)) / count2000 ) * 100
    tabdisp cod , cell(count_pc) format(%12.1fc) 
restore
** DALY: Absolute / Relative Change between 2000 and 2019
preserve
    sort sex cod 
    keep if type==2 & sex==3
    tabdisp cod year, cell(count) format(%15.1fc) 
restore 
preserve
    keep if type==2 & sex==3 & (year==2000 | year==2019)
    keep type year cod count 
    reshape wide count, i(type cod) j(year)

    ** absolute change
    gen count_ac = sqrt((count2000 - count2019)^2)
    ** percentage change
    gen count_pc = ( (count2019 - count2000) / count2000 ) * 100
    gen count_pc_abs = ( (sqrt((count2019 - count2000)^2)) / count2000 ) * 100
    tabdisp cod , cell(count_pc) format(%12.1fc) 
restore




** -----------------------------------------------------
** AUTOMATED WORD TABLE FOR REPORT
** -----------------------------------------------------
** matrix twidth = (20, 13, 13, 13, 13, 13, 13)

putdocx begin , pagesize(A4) font(calibri light, 9)
putdocx table t2 = (35 , 10) 

** ----------------------
** Formatting
** ----------------------
putdocx table t2(.,1), width(25%) 

** All cells - vertical centering
putdocx table t2(.,.), valign(center) 

** ROWS 1 and 2 - shading
putdocx table t2(1/2,.), bold border(all, single, "000000") shading("bfbfbf")
/// putdocx table t2(3,.) , shading("e6e6e6")
/// putdocx table t2(12,.) , shading("e6e6e6")

** Line colors
putdocx table t2(3/5,.), bold border(bottom, single, "e6e6e6")
putdocx table t2(7/9,.), bold border(bottom, single, "e6e6e6")
putdocx table t2(11/13,.), bold border(bottom, single, "e6e6e6")
putdocx table t2(15/17,.), bold border(bottom, single, "e6e6e6")
putdocx table t2(19/21,.), bold border(bottom, single, "e6e6e6")
putdocx table t2(23/25,.), bold border(bottom, single, "e6e6e6")
putdocx table t2(27/29,.), bold border(bottom, single, "e6e6e6")
putdocx table t2(31/33,.), bold border(bottom, single, "e6e6e6")

** Merge rows
putdocx table t2(1,3),colspan(2)
putdocx table t2(1,4),colspan(2)
putdocx table t2(1,5),colspan(4)
** ROW 10 as single cell for comments
putdocx table t2(35,1),colspan(9)
putdocx table t2(35,.),halign(left) font(calibri light, 8)
putdocx table t2(35,.),border(left, single, "FFFFFF")
putdocx table t2(35,.),border(right, single, "FFFFFF")
putdocx table t2(35,.),border(bottom, single, "FFFFFF")

** ----------------------
** Row and Column Titles
** ----------------------
putdocx table t2(1,3) = ("Number of events in 2019 "),  font(calibri light,10, "000000")
putdocx table t2(2,3) = ("Women "),              font(calibri light,10, "000000") 
putdocx table t2(2,4) = ("Men "),              font(calibri light,10, "000000") 

putdocx table t2(1,4) = ("Rate per 100,000 in 2019"),   font(calibri light,10, "000000")
putdocx table t2(2,5) = ("Women "),              font(calibri light,10, "000000") 
putdocx table t2(2,6) = ("Men "),              font(calibri light,10, "000000") 

putdocx table t2(1,5) = ("Percent change (2000 - 2019)"),  font(calibri light,10, "000000")
putdocx table t2(2,8) = ("Rate (Women) "),  font(calibri light,10, "000000")
putdocx table t2(2,7) = ("Count (Women)"),  font(calibri light,10, "000000")
putdocx table t2(2,10) = ("Rate (Men) "),  font(calibri light,10, "000000")
putdocx table t2(2,9) = ("Count (Men)"),  font(calibri light,10, "000000")

** ROW headers
putdocx table t2(3,1) = ("CVD "), halign(left) bold
putdocx table t2(7,1) = ("Cancer "), halign(left) bold
putdocx table t2(11,1) = ("Respiratory "), halign(left) bold
putdocx table t2(15,1) = ("Diabetes "), halign(left) bold
putdocx table t2(19,1) = ("Mental Health "), halign(left) bold
putdocx table t2(23,1) = ("Neurological "), halign(left) bold
putdocx table t2(27,1) = ("Combined NCD "), halign(left) bold
putdocx table t2(27,1) = ("1"), halign(left) script(super) append
putdocx table t2(31,1) = ("All NCD "), halign(left) bold
putdocx table t2(31,1) = ("2"), halign(left) script(super) append

putdocx table t2(3,2) = ("Deaths "), halign(left) bold
putdocx table t2(4,2) = ("DALYs "), halign(left) bold
putdocx table t2(5,2) = ("YLLs "), halign(left) bold
putdocx table t2(6,2) = ("YLDs "), halign(left) bold
putdocx table t2(7,2) = ("Deaths "), halign(left) bold
putdocx table t2(8,2) = ("DALYs "), halign(left) bold
putdocx table t2(9,2) = ("YLLs "), halign(left) bold
putdocx table t2(10,2) = ("YLDs "), halign(left) bold
putdocx table t2(11,2) = ("Deaths "), halign(left) bold
putdocx table t2(12,2) = ("DALYs "), halign(left) bold
putdocx table t2(13,2) = ("YLLs "), halign(left) bold
putdocx table t2(14,2) = ("YLDs "), halign(left) bold
putdocx table t2(15,2) = ("Deaths "), halign(left) bold
putdocx table t2(16,2) = ("DALYs "), halign(left) bold
putdocx table t2(17,2) = ("YLLs "), halign(left) bold
putdocx table t2(18,2) = ("YLDs "), halign(left) bold
putdocx table t2(19,2) = ("Deaths "), halign(left) bold
putdocx table t2(20,2) = ("DALYs "), halign(left) bold
putdocx table t2(21,2) = ("YLLs "), halign(left) bold
putdocx table t2(22,2) = ("YLDs "), halign(left) bold
putdocx table t2(23,2) = ("Deaths "), halign(left) bold
putdocx table t2(24,2) = ("DALYs "), halign(left) bold
putdocx table t2(25,2) = ("YLLs "), halign(left) bold
putdocx table t2(26,2) = ("YLDs "), halign(left) bold
putdocx table t2(27,2) = ("Deaths "), halign(left) bold
putdocx table t2(28,2) = ("DALYs "), halign(left) bold
putdocx table t2(29,2) = ("YLLs "), halign(left) bold
putdocx table t2(30,2) = ("YLDs "), halign(left) bold
putdocx table t2(31,2) = ("Deaths "), halign(left) bold
putdocx table t2(32,2) = ("DALYs "), halign(left) bold
putdocx table t2(33,2) = ("YLLs "), halign(left) bold
putdocx table t2(34,2) = ("YLDs "), halign(left) bold


** ----------------------
** DATA
** ----------------------
** COL3. COUNT in WOMEN
putdocx table   t2(3,3) = ("$count3_3a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(4,3) = ("$count3_3b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(5,3) = ("$count3_3c") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(6,3) = ("$count3_3d") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(7,3) = ("$count4_3a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(8,3) = ("$count4_3b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(9,3) = ("$count4_3c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(10,3) = ("$count4_3d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(11,3) = ("$count5_3a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(12,3) = ("$count5_3b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(13,3) = ("$count5_3c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(14,3) = ("$count5_3d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(15,3) = ("$count6_3a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(16,3) = ("$count6_3b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(17,3) = ("$count6_3c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(18,3) = ("$count6_3d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(19,3) = ("$count7_3a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(20,3) = ("$count7_3b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(21,3) = ("$count7_3c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(22,3) = ("$count7_3d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(23,3) = ("$count8_3a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(24,3) = ("$count8_3b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(25,3) = ("$count8_3c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(26,3) = ("$count8_3d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(27,3) = ("$count9_3a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(28,3) = ("$count9_3b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(29,3) = ("$count9_3c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(30,3) = ("$count9_3d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(31,3) = ("$count2_3a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(32,3) = ("$count2_3b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(33,3) = ("$count2_3c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(34,3) = ("$count2_3d") , nformat(%12.0fc) trim halign(right)

** COL4. COUNT in MEN
putdocx table   t2(3,4) = ("$count3_4a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(4,4) = ("$count3_4b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(5,4) = ("$count3_4c") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(6,4) = ("$count3_4d") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(7,4) = ("$count4_4a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(8,4) = ("$count4_4b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(9,4) = ("$count4_4c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(10,4) = ("$count4_4d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(11,4) = ("$count5_4a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(12,4) = ("$count5_4b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(13,4) = ("$count5_4c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(14,4) = ("$count5_4d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(15,4) = ("$count6_4a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(16,4) = ("$count6_4b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(17,4) = ("$count6_4c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(18,4) = ("$count6_4d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(19,4) = ("$count7_4a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(20,4) = ("$count7_4b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(21,4) = ("$count7_4c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(22,4) = ("$count7_4d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(23,4) = ("$count8_4a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(24,4) = ("$count8_4b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(25,4) = ("$count8_4c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(26,4) = ("$count8_4d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(27,4) = ("$count9_4a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(28,4) = ("$count9_4b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(29,4) = ("$count9_4c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(30,4) = ("$count9_4d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(31,4) = ("$count2_4a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(32,4) = ("$count2_4b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(33,4) = ("$count2_4c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(34,4) = ("$count2_4d") , nformat(%12.0fc) trim halign(right)

** COL5: RATE in WOMEN
putdocx table   t2(3,5) = ("$rate3_5a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(4,5) = ("$rate3_5b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(5,5) = ("$rate3_5c") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(6,5) = ("$rate3_5d") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(7,5) = ("$rate4_5a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(8,5) = ("$rate4_5b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(9,5) = ("$rate4_5c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(10,5) = ("$rate4_5d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(11,5) = ("$rate5_5a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(12,5) = ("$rate5_5b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(13,5) = ("$rate5_5c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(14,5) = ("$rate5_5d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(15,5) = ("$rate6_5a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(16,5) = ("$rate6_5b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(17,5) = ("$rate6_5c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(18,5) = ("$rate6_5d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(19,5) = ("$rate7_5a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(20,5) = ("$rate7_5b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(21,5) = ("$rate7_5c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(22,5) = ("$rate7_5d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(23,5) = ("$rate8_5a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(24,5) = ("$rate8_5b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(25,5) = ("$rate8_5c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(26,5) = ("$rate8_5d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(27,5) = ("$rate9_5a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(28,5) = ("$rate9_5b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(29,5) = ("$rate9_5c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(30,5) = ("$rate9_5d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(31,5) = ("$rate2_5a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(32,5) = ("$rate2_5b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(33,5) = ("$rate2_5c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(34,5) = ("$rate2_5d") , nformat(%12.0fc) trim halign(right)


** COL6. RATE in MEN
putdocx table   t2(3,6) = ("$rate3_6a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(4,6) = ("$rate3_6b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(5,6) = ("$rate3_6c") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(6,6) = ("$rate3_6d") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(7,6) = ("$rate4_6a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(8,6) = ("$rate4_6b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(9,6) = ("$rate4_6c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(10,6) = ("$rate4_6d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(11,6) = ("$rate5_6a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(12,6) = ("$rate5_6b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(13,6) = ("$rate5_6c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(14,6) = ("$rate5_6d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(15,6) = ("$rate6_6a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(16,6) = ("$rate6_6b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(17,6) = ("$rate6_6c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(18,6) = ("$rate6_6d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(19,6) = ("$rate7_6a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(20,6) = ("$rate7_6b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(21,6) = ("$rate7_6c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(22,6) = ("$rate7_6d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(23,6) = ("$rate8_6a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(24,6) = ("$rate8_6b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(25,6) = ("$rate8_6c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(26,6) = ("$rate8_6d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(27,6) = ("$rate9_6a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(28,6) = ("$rate9_6b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(29,6) = ("$rate9_6c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(30,6) = ("$rate9_6d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(31,6) = ("$rate2_6a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(32,6) = ("$rate2_6b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(33,6) = ("$rate2_6c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(34,6) = ("$rate2_6d") , nformat(%12.0fc) trim halign(right)

** COL7. WOMEN Percent change in RATE
putdocx table   t2(3,8) = ("$pc3_7a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(4,8) = ("$pc3_7b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(5,8) = ("$pc3_7c") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(6,8) = ("$pc3_7d") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(7,8) = ("$pc4_7a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(8,8) = ("$pc4_7b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(9,8) = ("$pc4_7c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(10,8) = ("$pc4_7d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(11,8) = ("$pc5_7a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(12,8) = ("$pc5_7b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(13,8) = ("$pc5_7c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(14,8) = ("$pc5_7d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(15,8) = ("$pc6_7a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(16,8) = ("$pc6_7b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(17,8) = ("$pc6_7c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(18,8) = ("$pc6_7d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(19,8) = ("$pc7_7a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(20,8) = ("$pc7_7b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(21,8) = ("$pc7_7c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(22,8) = ("$pc7_7d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(23,8) = ("$pc8_7a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(24,8) = ("$pc8_7b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(25,8) = ("$pc8_7c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(26,8) = ("$pc8_7d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(27,8) = ("$pc9_7a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(28,8) = ("$pc9_7b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(29,8) = ("$pc9_7c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(30,8) = ("$pc9_7d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(31,8) = ("$pc2_7a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(32,8) = ("$pc2_7b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(33,8) = ("$pc2_7c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(34,8) = ("$pc2_7d") , nformat(%12.0fc) trim halign(right)

** COL8. Percent change in COUNT
putdocx table   t2(3,7) = ("$pnum3_8a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(4,7) = ("$pnum3_8b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(5,7) = ("$pnum3_8c") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(6,7) = ("$pnum3_8d") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(7,7) = ("$pnum4_8a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(8,7) = ("$pnum4_8b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(9,7) = ("$pnum4_8c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(10,7) = ("$pnum4_8d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(11,7) = ("$pnum5_8a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(12,7) = ("$pnum5_8b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(13,7) = ("$pnum5_8c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(14,7) = ("$pnum5_8d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(15,7) = ("$pnum6_8a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(16,7) = ("$pnum6_8b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(17,7) = ("$pnum6_8c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(18,7) = ("$pnum6_8d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(19,7) = ("$pnum7_8a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(20,7) = ("$pnum7_8b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(21,7) = ("$pnum7_8c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(22,7) = ("$pnum7_8d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(23,7) = ("$pnum8_8a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(24,7) = ("$pnum8_8b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(25,7) = ("$pnum8_8c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(26,7) = ("$pnum8_8d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(27,7) = ("$pnum9_8a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(28,7) = ("$pnum9_8b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(29,7) = ("$pnum9_8c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(30,7) = ("$pnum9_8d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(31,7) = ("$pnum2_8a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(32,7) = ("$pnum2_8b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(33,7) = ("$pnum2_8c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(34,7) = ("$pnum2_8d") , nformat(%12.0fc) trim halign(right)

** COL9. MEN Percent change in RATE
putdocx table   t2(3,10) = ("$pc3_9a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(4,10) = ("$pc3_9b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(5,10) = ("$pc3_9c") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(6,10) = ("$pc3_9d") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(7,10) = ("$pc4_9a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(8,10) = ("$pc4_9b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(9,10) = ("$pc4_9c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(10,10) = ("$pc4_9d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(11,10) = ("$pc5_9a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(12,10) = ("$pc5_9b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(13,10) = ("$pc5_9c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(14,10) = ("$pc5_9d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(15,10) = ("$pc6_9a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(16,10) = ("$pc6_9b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(17,10) = ("$pc6_9c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(18,10) = ("$pc6_9d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(19,10) = ("$pc7_9a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(20,10) = ("$pc7_9b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(21,10) = ("$pc7_9c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(22,10) = ("$pc7_9d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(23,10) = ("$pc8_9a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(24,10) = ("$pc8_9b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(25,10) = ("$pc8_9c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(26,10) = ("$pc8_9d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(27,10) = ("$pc9_9a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(28,10) = ("$pc9_9b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(29,10) = ("$pc9_9c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(30,10) = ("$pc9_9d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(31,10) = ("$pc2_9a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(32,10) = ("$pc2_9b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(33,10) = ("$pc2_9c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(34,10) = ("$pc2_9d") , nformat(%12.0fc) trim halign(right)

** COL10. MEN Percent change in COUNT
putdocx table   t2(3,9) = ("$pnum3_10a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(4,9) = ("$pnum3_10b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(5,9) = ("$pnum3_10c") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(6,9) = ("$pnum3_10d") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(7,9) = ("$pnum4_10a") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(8,9) = ("$pnum4_10b") , nformat(%12.0fc) trim halign(right)
putdocx table   t2(9,9) = ("$pnum4_10c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(10,9) = ("$pnum4_10d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(11,9) = ("$pnum5_10a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(12,9) = ("$pnum5_10b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(13,9) = ("$pnum5_10c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(14,9) = ("$pnum5_10d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(15,9) = ("$pnum6_10a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(16,9) = ("$pnum6_10b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(17,9) = ("$pnum6_10c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(18,9) = ("$pnum6_10d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(19,9) = ("$pnum7_10a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(20,9) = ("$pnum7_10b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(21,9) = ("$pnum7_10c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(22,9) = ("$pnum7_10d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(23,9) = ("$pnum8_10a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(24,9) = ("$pnum8_10b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(25,9) = ("$pnum8_10c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(26,9) = ("$pnum8_10d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(27,9) = ("$pnum9_10a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(28,9) = ("$pnum9_10b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(29,9) = ("$pnum9_10c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(30,9) = ("$pnum9_10d") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(31,9) = ("$pnum2_10a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(32,9) = ("$pnum2_10b") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(33,9) = ("$pnum2_10c") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(34,9) = ("$pnum2_10d") , nformat(%12.0fc) trim halign(right)

** FINAL TABLE NOTES
putdocx table t2(35,1) = ("(1) ") , script(super) font(calibri light, 8)
putdocx table t2(35,1) = ("Combined NCDs, includes the following six groups of conditions: cardiovascular diseases, cancers, chronic respiratory diseases, diabetes, mental and substance-use disorders, neurological conditions.") , append font(calibri light, 8) 

putdocx table t2(35,1) = ("(2) ") , script(super) font(calibri light, 8) append
putdocx table t2(35,1) = ("All NCDs, includes all noncommunicable diseases") , append font(calibri light, 8) 

** Save the Table
putdocx save "`outputpath'/articles/paper-ncd/article-draft/ncd_table2_version3", replace 


