** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap3-140-mr-inequality.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Summary graphic of MR change between 2000 and 2019

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
    log using "`logpath'\chap3-140-mr-inequality", replace
** HEADER -----------------------------------------------------


** -----------------------------------------------------
** TABLE PART ONE 
** DEATHS METRICS
** -----------------------------------------------------

tempfile kcancer region_mr12 region_mr3 region_daly12 region_daly3

** Mortality Rate statistics first
** use "`datapath'\from-who\chap2_000_mr", clear
use "`datapath'\paper2-inj\dataset01", clear
rename mortr arate
rename dalyr drate

** -----------------------------------------------------
** Keep only the INJURY conditions used in the report
** -----------------------------------------------------
** (1)  56   "interpersonal violence" 
** (2)  48   "road injury" 
** (3)  55   "self harm" 
** (4)  50   "falls" 
** (5)  52   "drowning" 
** (6)  53   "mechanical forces" 
** (7)  51   "fire and heat" 
** (8)  49   "poisonings" 
** (9)  57   "colective violence" 
** (10) 54   "natural disasters" 

gen cod = 1 if ghecause==56 
replace cod = 2 if ghecause==48
replace cod = 3 if ghecause==55
replace cod = 4 if ghecause==50
replace cod = 5 if ghecause==52
/// replace cod = 6 if ghecause==53
/// replace cod = 7 if ghecause==51
/// replace cod = 8 if ghecause==49
/// replace cod = 9 if ghecause==57
/// replace cod = 10 if ghecause==54
replace cod = 6 if ghecause==1000
replace cod = 7 if ghecause==1100
replace cod = 8 if ghecause==1200

label define ghecause_ 1000 "all injuries" 1100 "unintentional injuries" 1200 "intentional injuries",modify
label values ghecause ghecause_

decode ghecause, gen(codname)
labmask cod, val(codname)
keep if cod<. 
order cod, after(sex)
sort cod year sex region
drop ghecause

**------------------------------------------------
** BEGIN STATISTICS FOR TEXT
** Keep ALL INDIVIDUAL CAUSES (there are 57 of these) 
** -----------------------------------------------
///rename ghecause cod
tempfile d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14

** ---------------------------------------------------
** Statistics for the text to accompany this graphic
** Simple relative measure of inequality : Rate (R)
** Simple absolute measure of inequality : Difference (D)
** Simple relative measure of inequality : Index of Disparity (ID) 
** ---------------------------------------------------

** MORTALITY MALE in 2000
preserve
    keep if sex==1 & year==2000 & (region<100 | region==2000)

    ** BASED ON ADJUSTED MORTALITY RATE 
    ** (R) Simple - relative
    bysort cod : egen m_min = min(arate)
    bysort cod : egen m_max = max(arate)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = arate if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(arate)
    gen id1 = abs(arate - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen mid1 = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim mid1 , after(arate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) mid1, by(cod)
    save  `d1', replace
restore


** MORTALITY FEMALE in 2000
preserve
    keep if sex==2 & year==2000 & (region<100 | region==2000)

    ** BASED ON ADJUSTED MORTALITY RATE 
    ** (R) Simple - relative
    bysort cod : egen m_min = min(arate)
    bysort cod : egen m_max = max(arate)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = arate if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(arate)
    gen id1 = abs(arate - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen mid2 = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim mid2 , after(arate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) mid2, by(cod)
    save  `d2', replace
restore


** MORTALITY BOTH in 2000
preserve
    keep if sex==3 & year==2000 & (region<100 | region==2000)

    ** BASED ON ADJUSTED MORTALITY RATE 
    ** (R) Simple - relative
    bysort cod : egen m_min = min(arate)
    bysort cod : egen m_max = max(arate)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = arate if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(arate)
    gen id1 = abs(arate - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen mid3 = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim mid3 , after(arate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) mid3, by(cod)
    save  `d3', replace
restore


** MORTALITY MALE in 2019
preserve
    keep if sex==1 & year==2019 & (region<100 | region==2000)

    ** BASED ON ADJUSTED MORTALITY RATE 
    ** (R) Simple - relative
    bysort cod : egen m_min = min(arate)
    bysort cod : egen m_max = max(arate)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = arate if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(arate)
    gen id1 = abs(arate - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen mid4 = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim mid4 , after(arate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) mid4, by(cod)
    save  `d4', replace
restore


** MORTALITY FEMALE in 2019
preserve
    keep if sex==2 & year==2019 & (region<100 | region==2000)

    ** BASED ON ADJUSTED MORTALITY RATE 
    ** (R) Simple - relative
    bysort cod : egen m_min = min(arate)
    bysort cod : egen m_max = max(arate)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = arate if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(arate)
    gen id1 = abs(arate - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen mid5 = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim mid5 , after(arate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) mid5, by(cod)
    save  `d5', replace
restore


** MORTALITY BOTH in 2019
preserve
    keep if sex==3 & year==2019 & (region<100 | region==2000)

    ** BASED ON ADJUSTED MORTALITY RATE 
    ** (R) Simple - relative
    bysort cod : egen m_min = min(arate)
    bysort cod : egen m_max = max(arate)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = arate if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(arate)
    gen id1 = abs(arate - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen mid6 = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim mid6 , after(arate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) mid6, by(cod)
    save  `d6', replace
restore






** DALY MALE in 2000
preserve
    keep if sex==1 & year==2000 & (region<100 | region==2000)

    ** BASED ON ADJUSTED MORTALITY RATE 
    ** (R) Simple - relative
    bysort cod : egen m_min = min(drate)
    bysort cod : egen m_max = max(drate)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = drate if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(drate)
    gen id1 = abs(drate - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen did1 = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim did1 , after(drate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) did1, by(cod)
    save  `d7', replace
restore


** DALY FEMALE in 2000
preserve
    keep if sex==2 & year==2000 & (region<100 | region==2000)

    ** BASED ON ADJUSTED MORTALITY RATE 
    ** (R) Simple - relative
    bysort cod : egen m_min = min(drate)
    bysort cod : egen m_max = max(drate)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = drate if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(drate)
    gen id1 = abs(drate - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen did2 = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim did2 , after(drate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) did2, by(cod)
    save  `d8', replace
restore


** DALY BOTH in 2000
preserve
    keep if sex==3 & year==2000 & (region<100 | region==2000)

    ** BASED ON ADJUSTED MORTALITY RATE 
    ** (R) Simple - relative
    bysort cod : egen m_min = min(drate)
    bysort cod : egen m_max = max(drate)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = drate if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(drate)
    gen id1 = abs(drate - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen did3 = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim did3 , after(drate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) did3, by(cod)
    save  `d9', replace
restore


** DALY MALE in 2019
preserve
    keep if sex==1 & year==2019 & (region<100 | region==2000)

    ** BASED ON ADJUSTED MORTALITY RATE 
    ** (R) Simple - relative
    bysort cod : egen m_min = min(drate)
    bysort cod : egen m_max = max(drate)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = drate if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(drate)
    gen id1 = abs(drate - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen did4 = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim did4 , after(drate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) did4, by(cod)
    save  `d10', replace
restore


** DALY FEMALE in 2019
preserve
    keep if sex==2 & year==2019 & (region<100 | region==2000)

    ** BASED ON ADJUSTED MORTALITY RATE 
    ** (R) Simple - relative
    bysort cod : egen m_min = min(drate)
    bysort cod : egen m_max = max(drate)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = drate if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(drate)
    gen id1 = abs(drate - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen did5 = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim did5 , after(drate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) did5, by(cod)
    save  `d11', replace
restore


** DALY BOTH in 2019
preserve
    keep if sex==3 & year==2019 & (region<100 | region==2000)

    ** BASED ON ADJUSTED MORTALITY RATE 
    ** (R) Simple - relative
    bysort cod : egen m_min = min(drate)
    bysort cod : egen m_max = max(drate)
    gen rel_sim = m_max / m_min
    label var rel_sim "Relative inequality: WHO simple measure"

    ** (D) Simple - absolute
    gen abs_sim = m_max - m_min
    label var abs_sim "Absolute inequality: WHO simple measure"
    drop m_min m_max 

    ** (ID) Complex - relative
    * --> Index of Disparity (Each country compared to Americas average rate)
    * --> number of countries in group 
    bysort cod : gen J = _N - 1
    gen americas1 = drate if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(drate)
    gen id1 = abs(drate - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen did6 = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim did6 , after(drate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) did6, by(cod)
    save  `d12', replace
restore

** Join the datasets
    use  `d1', replace
    forval x = 2(1)12 {
        merge 1:1 cod using `d`x''
        rename _merge merge`x'
    }
    drop merge*


label var mid1 "Mortality rate: Index of disparity in 2000 - Male"
label var mid2 "Mortality rate: Index of disparity in 2000 - Female"
label var mid3 "Mortality rate: Index of disparity in 2000 - Both"
label var mid4 "Mortality rate: Index of disparity in 2019 - Male"
label var mid5 "Mortality rate: Index of disparity in 2019 - Female"
label var mid6 "Mortality rate: Index of disparity in 2019 - Both"

label var did1 "DALY rate: Index of disparity in 2000 - Male"
label var did2 "DALY rate: Index of disparity in 2000 - Female"
label var did3 "DALY rate: Index of disparity in 2000 - Both"
label var did4 "DALY rate: Index of disparity in 2019 - Male"
label var did5 "DALY rate: Index of disparity in 2019 - Female"
label var did6 "DALY rate: Index of disparity in 2019 - Both"


** ----------------------------------------------------
** TABLE 2
** ----------------------------------------------------

	forval m = 1(1)6 {
        format mid`m' %5.1f
        format did`m' %5.1f
        }

	** Begin Table 
	putdocx begin , landscape font(calibri light, 10)
	putdocx paragraph 
		putdocx text ("Table 2. "), bold
		putdocx text ("Inequality summary metric (Index of Disparity, IoD) between 33 countries in the Americas in 2000 and in 2019."), 
		putdocx table t2 = data("cod mid1 mid2 mid3 mid4 mid5 mid6 did1 did2 did3 did4 did5 did6"), varnames 
		putdocx table t2(2/8,.), border(bottom, single, "e6e6e6")
		putdocx table t2(1,.),  shading("e6e6e6")
        
		putdocx table t2(1,2) = ("Men"),  font(calibri light,10, "000000")
		putdocx table t2(1,3) = ("Women"),  font(calibri light,10, "000000")
		putdocx table t2(1,4) = ("Both"),  font(calibri light,10, "000000")
		putdocx table t2(1,5) = ("Men"),  font(calibri light,10, "000000")
		putdocx table t2(1,6) = ("Women"),  font(calibri light,10, "000000")
		putdocx table t2(1,7) = ("Both"),  font(calibri light,10, "000000")
		putdocx table t2(1,8) = ("Men"),  font(calibri light,10, "000000")
		putdocx table t2(1,9) = ("Women"),  font(calibri light,10, "000000")
		putdocx table t2(1,10) = ("Both"),  font(calibri light,10, "000000")
		putdocx table t2(1,11) = ("Men"),  font(calibri light,10, "000000")
		putdocx table t2(1,12) = ("Women"),  font(calibri light,10, "000000")
		putdocx table t2(1,13) = ("Both"),  font(calibri light,10, "000000")

		putdocx table t2(2,1) = ("Interpersonal violence"),  font(calibri light,10, "000000")
		putdocx table t2(3,1) = ("Road injury"),  font(calibri light,10, "000000")
		putdocx table t2(4,1) = ("Self harm"),  font(calibri light,10, "000000")
		putdocx table t2(5,1) = ("Falls"),  font(calibri light,10, "000000")
		putdocx table t2(6,1) = ("Drowning"),  font(calibri light,10, "000000")
		putdocx table t2(7,1) = ("All injuries"),  font(calibri light,10, "000000")
		putdocx table t2(8,1) = ("Unintentional injuries"),  font(calibri light,10, "000000")
		putdocx table t2(9,1) = ("Intentional injuries"),  font(calibri light,10, "000000")

        putdocx table t2(1,.), addrows(1, before)
		putdocx table t2(1,.),  shading("e6e6e6")
        putdocx table t2(1,2) , colspan(3)
        putdocx table t2(1,3) , colspan(3)
        putdocx table t2(1,4) , colspan(3)
        putdocx table t2(1,5) , colspan(3)        
		putdocx table t2(1,2) = ("Mortality in 2000"),  font(calibri light,10, "000000")
		putdocx table t2(1,3) = ("Mortality in 2019"),  font(calibri light,10, "000000")
		putdocx table t2(1,4) = ("DALY in 2000"),  font(calibri light,10, "000000")
		putdocx table t2(1,5) = ("DALY in 2019"),  font(calibri light,10, "000000")

        putdocx table t2(.,1)  , width(28%)
        putdocx table t2(.,2)  , width(6%)
        putdocx table t2(.,3)  , width(6%)
        putdocx table t2(.,4)  , width(6%)
        putdocx table t2(.,5)  , width(6%)
        putdocx table t2(.,6)  , width(6%)
        putdocx table t2(.,7)  , width(6%)
        putdocx table t2(.,8)  , width(6%)
        putdocx table t2(.,9)  , width(6%)
        putdocx table t2(.,10) , width(6%)
        putdocx table t2(.,11) , width(6%)
        putdocx table t2(.,12) , width(6%)
        putdocx table t2(.,13) , width(6%)
        putdocx table t2(1,1) , rowspan(2)        
        putdocx table t2(1,1) = ("Injury Cause"),  font(calibri light,10, "000000")

	** Save the Table
    putdocx save "`outputpath'/articles/paper-injury/article-draft/inj_table2", replace

