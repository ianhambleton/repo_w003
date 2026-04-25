** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-2026-table3.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	22-JUN-2024
    //  algorithm task			    Injuries paper - Table 3

    ** General algorithm set-up
    version 17
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DATASETS to encrypted SharePoint folder
    local datapath "C:\yoshimi-hot\output\analyse-write\w003\data\2025"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yoshimi-hot\output\analyse-write\w003\tech-docs\2025"

    ** REPORTS and Other outputs
    local outputpath "C:\yoshimi-hot\output\analyse-write\w003\outputs\2025"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\paper2-2026-table3", replace
** HEADER -----------------------------------------------------


** -----------------------------------------------------
** TABLE PART ONE 
** DEATHS METRICS
** -----------------------------------------------------

tempfile kcancer region_mr12 region_mr3 region_daly12 region_daly3

** Mortality Rate statistics first
** FROM --> paper2-2025-005-datasets
use "`datapath'\dataset03", clear
rename mortr arate
rename dalyr drate
rename yllr mrate
rename yldr lrate

** -----------------------------------------------------
** Keep only the INJURY conditions used in the report
** -----------------------------------------------------
**
** (X) = TABLE ROW
** 
** (6) Injuries          (ghecause: 4)
** (7) Unintentional Inj (ghecause: 5)
** (8) Intentional Inj   (ghecause: 6)
** (2)                   (ghecause  7. road injury)
**                       (ghecause  8. poisonings)
** (4)                   (ghecause  9. falls)
**                       (ghecause 10. fire and heat)
** (5)                   (ghecause 11. drowning)
**                       (ghecause 12. mechanical forces)
**                       (ghecause 13. natural disasters)
** (3)                   (ghecause 14. self harm)
** (1)                   (ghecause 15. interpersonal violence)
**                       (ghecause 16. collective violence)
gen cod = 1 if ghecause==15 
replace cod = 2 if ghecause==7
replace cod = 3 if ghecause==14
replace cod = 4 if ghecause==9
replace cod = 5 if ghecause==11
replace cod = 6 if ghecause==4
replace cod = 7 if ghecause==5
replace cod = 8 if ghecause==6

#delimit ; 
label define cod_   1 "Interpersonal violence"
                    2 "Road injury"
                    3 "Self harm"
                    4 "Falls"
                    5 "Drowning"
                    6 "Injuries"
                    7 "Unintentional injuries"
                    8 "Intentional injuries";
#delimit cr 
label values cod cod_
keep if cod<. 
order cod, after(sex)
sort cod year sex region
drop ghecause

**------------------------------------------------
** BEGIN STATISTICS FOR TEXT
** -----------------------------------------------
///rename ghecause cod
tempfile daly1 daly2 daly3 
tempfile yld1 yld2 yld3
tempfile yll1 yll2 yll3 

** ---------------------------------------------------
** Statistics for the text to accompany this graphic
** DALY count 
** Percentage YLD 
** Percentage YLD 
** ---------------------------------------------------


** Keep selected years / region
keep if year==2021 
keep if region==44

** DALY COUNT for men, women, both 
preserve
    * men
    keep if sex==1
    collapse (mean) daly, by(cod)
    rename daly daly1
    save  `daly1', replace
restore
preserve
    * women
    keep if sex==2
    collapse (mean) daly, by(cod)
    rename daly daly2
    save  `daly2', replace
restore
preserve
    * all 
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==3
    collapse (mean) daly, by(cod)
    rename daly daly3
    save  `daly3', replace
restore

** YLD PERCENTAGE for men, women, both 
preserve
    * men  
    keep if sex==1
    gen yldp1 = (yld/daly)*100
    collapse (mean) yldp1, by(cod)
    save  `yld1', replace
restore
preserve
    * women  
    keep if sex==2
    gen yldp2 = (yld/daly)*100
    collapse (mean) yldp2, by(cod)
    save  `yld2', replace
restore
preserve
    * all  
    keep if sex==3
    gen yldp3 = (yld/daly)*100
    collapse (mean) yldp3, by(cod)
    save  `yld3', replace
restore

** YLL PERCENTAGE for men, women, both 
preserve
    * men  
    keep if sex==1
    gen yllp1 = (yll/daly)*100
    collapse (mean) yllp1, by(cod)
    save  `yll1', replace
restore
preserve
    * women  
    keep if sex==2
    gen yllp2 = (yll/daly)*100
    collapse (mean) yllp2, by(cod)
    save  `yll2', replace
restore
preserve
    * all  
    keep if sex==3
    gen yllp3 = (yll/daly)*100
    collapse (mean) yllp3, by(cod)
    save  `yll3', replace
restore


** Join the datasets
use `daly1', replace 
merge 1:1 cod using `daly2', gen(daly2m)
merge 1:1 cod using `daly3', gen(daly3m)
merge 1:1 cod using `yld1', gen(yld1m)
merge 1:1 cod using `yld2', gen(yldm2)
merge 1:1 cod using `yld3', gen(yldm3)
merge 1:1 cod using `yll1', gen(yllm1)
merge 1:1 cod using `yll2', gen(yllm2)
merge 1:1 cod using `yll3', gen(yllm3)

label var daly1 "DALY count - Male"
label var daly2 "DALY count - Female"
label var daly3 "DALY count - Both"
label var yldp1 "YLD Percentage - Male"
label var yldp2 "YLD Percentage - Female"
label var yldp3 "YLD Percentage - Both"
label var yllp1 "YLL Percentage - Male"
label var yllp2 "YLL Percentage - Female"
label var yllp3 "YLL Percentage - Both"

format daly1 daly2 daly3 %12.0fc
format yldp1 yldp2 yldp3 yllp1 yllp2 yllp3 %5.1f

** ----------------------------------------------------
** SUPPLEMENT TABLE 12
** ----------------------------------------------------

	** Begin Table 
	putdocx begin , landscape font(calibri light, 9)
	putdocx paragraph 
		putdocx text ("TABLE. "), bold
		putdocx text ("Proportion of Disability Adjusted Life Years (DALYs) due to Years Lived with Disability (YLDs) and due to Years of Life Lost (YLLs) in 2021."), 
		putdocx table t2 = data("cod daly1 daly2 daly3 yldp1 yldp2 yldp3 yllp1 yllp2 yllp3"), varnames 
		putdocx table t2(2/5,.), border(bottom, single, "e6e6e6")
		putdocx table t2(7/8,.), border(bottom, single, "e6e6e6")

		putdocx table t2(1,.),  shading("e6e6e6")
        
		putdocx table t2(1,2) = ("Men"),  font(calibri light,10, "000000")
		putdocx table t2(1,3) = ("Women"),  font(calibri light,10, "000000")
		putdocx table t2(1,4) = ("All"),  font(calibri light,10, "000000")
		putdocx table t2(1,5) = ("Men"),  font(calibri light,10, "000000")
		putdocx table t2(1,6) = ("Women"),  font(calibri light,10, "000000")
		putdocx table t2(1,7) = ("All"),  font(calibri light,10, "000000")
		putdocx table t2(1,8) = ("Men"),  font(calibri light,10, "000000")
		putdocx table t2(1,9) = ("Women"),  font(calibri light,10, "000000")
		putdocx table t2(1,10) = ("All"),  font(calibri light,10, "000000")

		putdocx table t2(2,1) = ("Interpersonal violence"),  font(calibri light,10, "000000")
		putdocx table t2(3,1) = ("Road injury"),  font(calibri light,10, "000000")
		putdocx table t2(4,1) = ("Self harm"),  font(calibri light,10, "000000")
		putdocx table t2(5,1) = ("Falls"),  font(calibri light,10, "000000")
		putdocx table t2(6,1) = ("Drowning"),  font(calibri light,10, "000000")
		putdocx table t2(7,1) = ("All injuries"), bold font(calibri light,10, "000000")
		putdocx table t2(8,1) = ("Unintentional injuries"), bold font(calibri light,10, "000000")
		putdocx table t2(9,1) = ("Intentional injuries"), bold font(calibri light,10, "000000")

        putdocx table t2(1,.), addrows(1, before)
		putdocx table t2(1,.),  shading("e6e6e6")
        putdocx table t2(1,2) , colspan(3)
        putdocx table t2(1,3) , colspan(3)
        putdocx table t2(1,4) , colspan(3)
		putdocx table t2(1,2) = ("DALY Count"),  font(calibri light,10, "000000")
		putdocx table t2(1,3) = ("YLD Percentage"),  font(calibri light,10, "000000")
		putdocx table t2(1,4) = ("YLL Percentage"),  font(calibri light,10, "000000")

        putdocx table t2(.,1)  , width(22%)
        putdocx table t2(.,2)  , width(10%)
        putdocx table t2(.,3)  , width(10%)
        putdocx table t2(.,4)  , width(10%)
        putdocx table t2(.,5)  , width(8%)
        putdocx table t2(.,6)  , width(8%)
        putdocx table t2(.,7)  , width(8%)
        putdocx table t2(.,8)  , width(8%)
        putdocx table t2(.,9)  , width(8%)
        putdocx table t2(.,10) , width(8%)

        putdocx table t2(1,1) , rowspan(2)        
        putdocx table t2(1,1) = ("Injury Cause"),  font(calibri light,10, "000000")

		/// putdocx table t2(2/10,4), border(right, single, "000000")
		/// putdocx table t2(2/10,7), border(right, single, "000000")
		/// putdocx table t2(2/10,10), border(right, single, "000000")

	** Save the Table
    putdocx save "`outputpath'/inj_supplement_table12", replace

