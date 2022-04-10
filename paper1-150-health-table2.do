** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper1-150-health-table2.do
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
    log using "`logpath'\paper1-150-health-table2", replace
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
** TABLE PART ONE 
** DEATHS METRICS
** -----------------------------------------------------
use "`datapath'\from-who\paper1-chap2_000_mr", clear

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
** TABLE PART TWO 
** DALY METRICS
** -----------------------------------------------------
use "`datapath'\from-who\paper1-chap2_000_daly", clear

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

** Join the DEATHS AND DALYS datasets
use `deaths' , clear 
append using `dalys'
label define type_ 1 "deaths" 2 "daly" , modify 
label values type type_ 
order cod type , after(ghecause)
replace crate = crate * 100000
replace rate = rate * 100000
format count %15.1fc 
format rate %9.1fc 
drop ghecause 



** -----------------------------------------------------
** COLUMN 2
** Outputs: Total Deaths / Total DALYs 
** in 2000
** -----------------------------------------------------
** Number of deaths in the Americas in 2000 and 2019 
** by GHE CoD 
** Women and men combined 
preserve 
    keep if type==1 & year==2000 & sex==3
    ** collapse (sum) dths, by(cod)
    tabdisp cod  , cell(count) format(%10.0fc)
    sort cod 

    gen count_int = round(count)
    mkmat cod count_int , matrix(col2a)
    matrix list col2a
    forval x = 1(1)9 {
        global count`x'_2a = col2a[`x',2]
    }
restore

** DALYs. Women and men combined 
preserve 
    keep if type==2 & year==2000 & sex==3
    ** collapse (sum) daly, by(cod)
    tabdisp cod  , cell(count) format(%10.0fc)
    sort cod 
    gen count_int = round(count)
    mkmat cod count_int , matrix(col2b)
    matrix list col2b
    forval x = 1(1)9 {
        global count`x'_2b = col2b[`x',2]
    }
restore



** -----------------------------------------------------
** COLUMN 3
** Outputs: Total Deaths / Total DALYs
** in 2019
** -----------------------------------------------------
** Number of deaths in the Americas in 2000 and 2019 
** by GHE CoD 
** Women and men combined 
preserve 
    keep if type==1 & year==2019 & sex==3
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

** DALYs. Women and men combined 
preserve 
    keep if type==2 & year==2019 & sex==3
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


** -----------------------------------------------------
** COLUMN 4
** Outputs: Mortality Rate / DALY rate
** 2000
** -----------------------------------------------------
** Mortality Rate in 2000
preserve
    sort sex cod 
    keep if type==1 & year==2000 & sex==3
    ** Women and Men combined  
    tabdisp cod , cell(rate) format(%6.1fc) 
    sort cod 
    gen rate_int = round(rate, 0.1)
    mkmat cod rate_int , matrix(col4a)
    matrix list col4a
    forval x = 1(1)9 {
        global rate`x'_4a = col4a[`x',2]
    }
restore 
** DALY Rate in 2000
preserve
    sort sex cod 
    keep if type==2 & year==2000 & sex==3
    ** Women and Men combined  
    tabdisp cod , cell(rate) format(%6.1fc) 
    sort cod 
    gen rate_int = round(rate, 0.1)
    mkmat cod rate_int , matrix(col4b)
    matrix list col4b
    forval x = 1(1)9 {
        global rate`x'_4b = col4b[`x',2]
    }
restore 

** -----------------------------------------------------
** COLUMN 5
** Outputs: Mortality Rate / DALY rate
** 2019
** -----------------------------------------------------
** Mortality Rate in 2019
preserve
    sort sex cod 
    keep if type==1 & year==2019 & sex==3
    ** Women and Men combined  
    tabdisp cod , cell(rate) format(%6.1fc) 
    sort cod 
    gen rate_int = round(rate, 0.1)
    mkmat cod rate_int , matrix(col5a)
    matrix list col5a
    forval x = 1(1)9 {
        global rate`x'_5a = col5a[`x',2]
    }
restore 
** DALY Rate in 2019
preserve
    sort sex cod 
    keep if type==2 & year==2019 & sex==3
    ** Women and Men combined  
    tabdisp cod , cell(rate) format(%6.1fc) 
    sort cod 
    gen rate_int = round(rate, 0.1)
    mkmat cod rate_int , matrix(col5b)
    matrix list col5b
    forval x = 1(1)9 {
        global rate`x'_5b = col5b[`x',2]
    }
restore 




** -----------------------------------------------------
** COLUMN 6
** Outputs: Change in Rate between 2000 and 2019 
** -----------------------------------------------------
** Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==1 & sex==3 & (year==2000 | year==2019)
    keep type year cod rate 
    reshape wide rate, i(type cod) j(year)

    ** absolute change
    gen rate_ac = sqrt((rate2000 - rate2019)^2)
    ** percentage change
    gen rate_pc = ( (rate2019 - rate2000) / rate2000 ) * 100
    gen rate_pc_abs = ( (sqrt((rate2019 - rate2000)^2)) / rate2000 ) * 100

    sort cod 
    gen rate_pc_int = round(rate_pc, 0.1)
    mkmat cod rate_pc_int , matrix(col6a)
    matrix list col6a
    forval x = 1(1)9 {
        global pc`x'_6a = col6a[`x',2]
    } 
restore
** Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==2 & sex==3 & (year==2000 | year==2019)
    keep type year cod rate 
    reshape wide rate, i(type cod) j(year)

    ** absolute change
    gen rate_ac = sqrt((rate2000 - rate2019)^2)
    ** percentage change
    gen rate_pc = ( (rate2019 - rate2000) / rate2000 ) * 100
    gen rate_pc_abs = ( (sqrt((rate2019 - rate2000)^2)) / rate2000 ) * 100

    sort cod 
    gen rate_pc_int = round(rate_pc, 0.1)
    mkmat cod rate_pc_int , matrix(col6b)
    matrix list col6b
    forval x = 1(1)9 {
        global pc`x'_6b = col6b[`x',2]
    } 
restore


** -----------------------------------------------------
** COLUMN 6
** Outputs: Change in Number between 2000 and 2019 
** -----------------------------------------------------
** Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==1 & sex==3 & (year==2000 | year==2019)
    keep type year cod count 
    reshape wide count, i(type cod) j(year)

    ** absolute change
    gen count_ac = sqrt((count2000 - count2019)^2)
    ** percentage change
    gen count_pc = ( (count2019 - count2000) / count2000 ) * 100
    gen count_pc_abs = ( (sqrt((count2019 - count2000)^2)) / count2000 ) * 100

    sort cod 
    gen count_pc_int = round(count_pc, 0.1)
    mkmat cod count_pc_int , matrix(col7a)
    matrix list col7a
    forval x = 1(1)9 {
        global pnum`x'_7a = col7a[`x',2]
    } 
restore
** Absolute / Relative Change between 2000 and 2019
preserve
    keep if type==2 & sex==3 & (year==2000 | year==2019)
    keep type year cod count 
    reshape wide count, i(type cod) j(year)

    ** absolute change
    gen count_ac = sqrt((count2000 - count2019)^2)
    ** percentage change
    gen count_pc = ( (count2019 - count2000) / count2000 ) * 100
    gen count_pc_abs = ( (sqrt((count2019 - count2000)^2)) / count2000 ) * 100

    sort cod 
    gen count_pc_int = round(count_pc, 0.1)
    mkmat cod count_pc_int , matrix(col7b)
    matrix list col7b
    forval x = 1(1)9 {
        global pnum`x'_7b = col7b[`x',2]
    } 
restore





** -----------------------------------------------------
** AUTOMATED WORD TABLE FOR REPORT
** -----------------------------------------------------
** matrix twidth = (20, 13, 13, 13, 13, 13, 13)

putdocx begin , pagesize(A4) font(calibri light, 9)
putdocx table t2 = (21 , 7) 

** ----------------------
** Formatting
** ----------------------
putdocx table t2(.,1), width(25%) 

** All cells - vertical centering
putdocx table t2(.,.), valign(center) 

** ROWS 1 and 2 - shading
putdocx table t2(1/2,.), bold border(all, single, "000000") shading("bfbfbf")
putdocx table t2(3,.) , shading("e6e6e6")
putdocx table t2(12,.) , shading("e6e6e6")

** Merge rows
putdocx table t2(1,2),colspan(2)
putdocx table t2(1,3),colspan(2)
putdocx table t2(1,4),colspan(2)
    ** ROW 10 as single cell for comments
putdocx table t2(21,1),colspan(7)
putdocx table t2(21,.),halign(left) font(calibri light, 8)
putdocx table t2(21,.),border(left, single, "FFFFFF")
putdocx table t2(21,.),border(right, single, "FFFFFF")
putdocx table t2(21,.),border(bottom, single, "FFFFFF")

** ----------------------
** Row and Column Titles
** ----------------------
putdocx table t2(1,2) = ("Number of events "),  font(calibri light,10, "000000")
putdocx table t2(2,2) = ("2000 "),              font(calibri light,10, "000000") 
putdocx table t2(2,3) = ("2019 "),              font(calibri light,10, "000000") 

putdocx table t2(1,3) = ("Rate per 100,000"),   font(calibri light,10, "000000")
putdocx table t2(2,4) = ("2000 "),              font(calibri light,10, "000000") 
putdocx table t2(2,5) = ("2019 "),              font(calibri light,10, "000000") 

putdocx table t2(1,4) = ("Percent change (2000 - 2019)"),  font(calibri light,10, "000000")
putdocx table t2(2,6) = ("Count "),  font(calibri light,10, "000000")
putdocx table t2(2,7) = ("Rate "),  font(calibri light,10, "000000")

** ROW headers
putdocx table t2(3,1) = ("DEATHS "), halign(right) bold
putdocx table t2(4,1) = ("CVD "), halign(right) bold
/// putdocx table t2(3,1) = ("2"), bold halign(right) script(super) append
putdocx table t2(5,1) = ("Cancer"), halign(right) bold
putdocx table t2(6,1) = ("Respiratory "), halign(right) bold
putdocx table t2(7,1) = ("Diabetes "), halign(right) bold
putdocx table t2(8,1) = ("Mental Health "), halign(right) bold
putdocx table t2(9,1) = ("Neurological "), halign(right) bold
putdocx table t2(10,1) = ("Combined NCD "), halign(right) bold
putdocx table t2(10,1) = ("1"), halign(right) script(super) append
putdocx table t2(11,1) = ("All NCD "), halign(right) bold
putdocx table t2(11,1) = ("2"), halign(right) script(super) append

putdocx table t2(12,1) = ("DALYs "), halign(right) bold
putdocx table t2(13,1) = ("CVD "), halign(right) bold
putdocx table t2(14,1) = ("Cancer"), halign(right) bold
putdocx table t2(15,1) = ("Respiratory "), halign(right) bold
putdocx table t2(16,1) = ("Diabetes "), halign(right) bold
putdocx table t2(17,1) = ("Mental Health "), halign(right) bold
putdocx table t2(18,1) = ("Neurological "), halign(right) bold
putdocx table t2(19,1) = ("Combined NCD "), halign(right) bold
putdocx table t2(19,1) = ("1"), halign(right) script(super) append
putdocx table t2(20,1) = ("All NCD "), halign(right) bold
putdocx table t2(20,1) = ("2"), halign(right) script(super) append

** ----------------------
** DATA
** ----------------------
** COL2. COUNT in 2000
putdocx table  t2(4,2) = ("$count3_2a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(5,2) = ("$count4_2a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(6,2) = ("$count5_2a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(7,2) = ("$count6_2a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(8,2) = ("$count7_2a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(9,2) = ("$count8_2a") , nformat(%12.0fc) trim halign(right)
putdocx table t2(10,2) = ("$count9_2a") , nformat(%12.0fc) trim halign(right)
putdocx table t2(11,2) = ("$count2_2a") , nformat(%12.0fc) trim halign(right)
putdocx table t2(13,2) = ("$count3_2b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(14,2) = ("$count4_2b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(15,2) = ("$count5_2b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(16,2) = ("$count6_2b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(17,2) = ("$count7_2b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(18,2) = ("$count8_2b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(19,2) = ("$count9_2b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(20,2) = ("$count2_2b") , nformat(%12.0fc) trim halign(right)

** COL3. COUNT in 2019
putdocx table  t2(4,3) = ("$count3_3a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(5,3) = ("$count4_3a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(6,3) = ("$count5_3a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(7,3) = ("$count6_3a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(8,3) = ("$count7_3a") , nformat(%12.0fc) trim halign(right)
putdocx table  t2(9,3) = ("$count8_3a") , nformat(%12.0fc) trim halign(right)
putdocx table t2(10,3) = ("$count9_3a") , nformat(%12.0fc) trim halign(right)
putdocx table t2(11,3) = ("$count2_3a") , nformat(%12.0fc) trim halign(right)
putdocx table t2(13,3) = ("$count3_3b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(14,3) = ("$count4_3b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(15,3) = ("$count5_3b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(16,3) = ("$count6_3b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(17,3) = ("$count7_3b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(18,3) = ("$count8_3b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(19,3) = ("$count9_3b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(20,3) = ("$count2_3b") , nformat(%12.0fc) trim halign(right)

** COL4. RATE in 2000
putdocx table t2(4,4) =  ("$rate3_4a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(5,4) =  ("$rate4_4a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(6,4) =  ("$rate5_4a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(7,4) =  ("$rate6_4a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(8,4) =  ("$rate7_4a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(9,4) =  ("$rate8_4a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(10,4) =  ("$rate9_4a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(11,4) = ("$rate2_4a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(13,4) = ("$rate3_4b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(14,4) = ("$rate4_4b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(15,4) = ("$rate5_4b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(16,4) = ("$rate6_4b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(17,4) = ("$rate7_4b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(18,4) = ("$rate8_4b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(19,4) = ("$rate9_4b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(20,4) = ("$rate2_4b") , nformat(%12.0fc) trim halign(right)

** COL5. RATE in 2019
putdocx table  t2(4,5) = ("$rate3_5a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(5,5) = ("$rate4_5a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(6,5) = ("$rate5_5a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(7,5) = ("$rate6_5a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(8,5) = ("$rate7_5a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(9,5) = ("$rate8_5a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(10,5) = ("$rate9_5a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(11,5) = ("$rate2_5a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(13,5) = ("$rate3_5b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(14,5) = ("$rate4_5b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(15,5) = ("$rate5_5b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(16,5) = ("$rate6_5b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(17,5) = ("$rate7_5b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(18,5) = ("$rate8_5b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(19,5) = ("$rate9_5b") , nformat(%12.0fc) trim halign(right)
putdocx table t2(20,5) = ("$rate2_5b") , nformat(%12.0fc) trim halign(right)

** COL6. CHANGE IN COUNT between 2000 and 2019
putdocx table  t2(4,6) = ("$pnum3_7a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(5,6) = ("$pnum4_7a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(6,6) = ("$pnum5_7a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(7,6) = ("$pnum6_7a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(8,6) = ("$pnum7_7a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(9,6) = ("$pnum8_7a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(10,6) = ("$pnum9_7a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(11,6) = ("$pnum2_7a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(13,6) = ("$pnum3_7b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(14,6) = ("$pnum4_7b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(15,6) = ("$pnum5_7b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(16,6) = ("$pnum6_7b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(17,6) = ("$pnum7_7b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(18,6) = ("$pnum8_7b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(19,6) = ("$pnum9_7b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(20,6) = ("$pnum2_7b") , nformat(%12.1fc) trim halign(right)

** COL7. CHANGE IN RATE between 2000 and 2019
putdocx table  t2(4,7) = ("$pc3_6a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(5,7) = ("$pc4_6a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(6,7) = ("$pc5_6a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(7,7) = ("$pc6_6a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(8,7) = ("$pc7_6a") , nformat(%12.1fc) trim halign(right)
putdocx table  t2(9,7) = ("$pc8_6a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(10,7) = ("$pc9_6a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(11,7) = ("$pc2_6a") , nformat(%12.1fc) trim halign(right)
putdocx table t2(13,7) = ("$pc3_6b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(14,7) = ("$pc4_6b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(15,7) = ("$pc5_6b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(16,7) = ("$pc6_6b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(17,7) = ("$pc7_6b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(18,7) = ("$pc8_6b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(19,7) = ("$pc9_6b") , nformat(%12.1fc) trim halign(right)
putdocx table t2(20,7) = ("$pc2_6b") , nformat(%12.1fc) trim halign(right)

** FINAL TABLE NOTES
putdocx table t2(21,1) = ("(1) ") , script(super) font(calibri light, 8)
putdocx table t2(21,1) = ("Combined NCDs, includes the following six groups of conditions: cardiovascular diseases, cancers, chronic respiratory diseases, diabetes, mental and substance-use disorders, neurological conditions.") , append font(calibri light, 8) 

putdocx table t2(21,1) = ("(2) ") , script(super) font(calibri light, 8) append
putdocx table t2(21,1) = ("All NCDs, includes all noncommunicable diseases") , append font(calibri light, 8) 

** Save the Table
putdocx save "`outputpath'/articles/paper-ncd/article-draft/ncd_table2", replace 


