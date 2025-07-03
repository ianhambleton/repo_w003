** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-2025-table2.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	22-JUN-2024
    //  algorithm task			    Injuries paper - Table 2

    ** General algorithm set-up
    version 17
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DATASETS to encrypted SharePoint folder
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data\2025"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs\2025"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs\2025"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\paper2-2025-table2", replace
** HEADER -----------------------------------------------------


** -----------------------------------------------------
** TABLE PART ONE 
** DEATHS METRICS
** -----------------------------------------------------

tempfile kcancer region_mr12 region_mr3 region_daly12 region_daly3

** Mortality Rate statistics first
** FROM --> paper2-2025-005-datasets
use "`datapath'\dataset01", clear
rename mortr arate
rename dalyr drate

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
tempfile d2000_1 d2000_2 d2000_3 e2000_1 e2000_2 e2000_3
tempfile d2001_1 d2001_2 d2001_3 e2001_1 e2001_2 e2001_3
tempfile d2005_1 d2005_2 d2005_3 e2005_1 e2005_2 e2005_3
tempfile d2010_1 d2010_2 d2010_3 e2010_1 e2010_2 e2010_3
tempfile d2015_1 d2015_2 d2015_3 e2015_1 e2015_2 e2015_3
tempfile d2021_1 d2021_2 d2021_3 e2021_1 e2021_2 e2021_3

** ---------------------------------------------------
** Statistics for the text to accompany this graphic
** Simple relative measure of inequality : Rate (R)
** Simple absolute measure of inequality : Difference (D)
** Simple relative measure of inequality : Index of Disparity (ID) 
** ---------------------------------------------------


** MORTALITY 

** 2000 male
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==1 & year==2000 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid1 mid2000_1
    save  `d2000_1', replace
restore
** 2000 female
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==2 & year==2000 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid2 mid2000_2
    save  `d2000_2', replace
restore
** 2000 both
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==3 & year==2000 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid3 mid2000_3
    save  `d2000_3', replace
restore



** 2001 male
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==1 & year==2001 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid1 mid2001_1
    save  `d2001_1', replace
restore
** 2001 female
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==2 & year==2001 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid2 mid2001_2
    save  `d2001_2', replace
restore
** 2001 both
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==3 & year==2001 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid3 mid2001_3
    save  `d2001_3', replace
restore


** 2005 male
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==1 & year==2006 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid1 mid2006_1
    save  `d2005_1', replace
restore
** 2005 female
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==2 & year==2006 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid2 mid2006_2
    save  `d2005_2', replace
restore
** 2005 both
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==3 & year==2006 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid3 mid2006_3
    save  `d2005_3', replace
restore
** 2010 male
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==1 & year==2011 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid1 mid2011_1
    save  `d2010_1', replace
restore
** 2010 female
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==2 & year==2011 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid2 mid2011_2
    save  `d2010_2', replace
restore
** 2010 both
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==3 & year==2011 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid3 mid2011_3
    save  `d2010_3', replace
restore
** 2015 male
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==1 & year==2016 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid1 mid2016_1
    save  `d2015_1', replace
restore
** 2015 female
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==2 & year==2016 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid2 mid2016_2
    save  `d2015_2', replace
restore
** 2015 both
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==3 & year==2016 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid3 mid2016_3
    save  `d2015_3', replace
restore
** 2021 male
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==1 & year==2021 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid4 mid2021_1
    save  `d2021_1', replace
restore
** 2021 female
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==2 & year==2021 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid5 mid2021_2
    save  `d2021_2', replace
restore
** 2021 both
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==3 & year==2021 & (region<=35 | region==44)

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
    gen americas1 = arate if region==44
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
    rename mid6 mid2021_3
    save  `d2021_3', replace
restore




** REPEAT USING DALY

** 2000 male
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==1 & year==2000 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did1 did2000_1
    save  `e2000_1', replace
restore
** 2000 female
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==2 & year==2000 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did2 did2000_2
    save  `e2000_2', replace
restore
** 2000 both
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==3 & year==2000 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did3 did2000_3
    save  `e2000_3', replace
restore



** 2001 male
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==1 & year==2001 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did1 did2001_1
    save  `e2001_1', replace
restore
** 2001 female
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==2 & year==2001 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did2 did2001_2
    save  `e2001_2', replace
restore
** 2001 both
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==3 & year==2001 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did3 did2001_3
    save  `e2001_3', replace
restore


** 2005 male
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==1 & year==2006 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did1 did2006_1
    save  `e2005_1', replace
restore
** 2005 female
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==2 & year==2006 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did2 did2006_2
    save  `e2005_2', replace
restore
** 2005 both
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==3 & year==2006 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did3 did2006_3
    save  `e2005_3', replace
restore
** 2010 male
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==1 & year==2011 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did1 did2011_1
    save  `e2010_1', replace
restore
** 2010 female
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==2 & year==2011 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did2 did2011_2
    save  `e2010_2', replace
restore
** 2010 both
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==3 & year==2011 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did3 did2011_3
    save  `e2010_3', replace
restore
** 2015 male
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==1 & year==2016 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did1 did2016_1
    save  `e2015_1', replace
restore
** 2015 female
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==2 & year==2016 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did2 did2016_2
    save  `e2015_2', replace
restore
** 2015 both
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==3 & year==2016 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did3 did2016_3
    save  `e2015_3', replace
restore
** 2021 male
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==1 & year==2021 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did4 did2021_1
    save  `e2021_1', replace
restore
** 2021 female
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==2 & year==2021 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did5 did2021_2
    save  `e2021_2', replace
restore
** 2021 both
preserve
    ** Keep individual countries (<=35) + Americas (44) 
    keep if sex==3 & year==2021 & (region<=35 | region==44)

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
    gen americas1 = drate if region==44
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
    rename did6 did2021_3
    save  `e2021_3', replace
restore

** Join the datasets
use `d2000_1', replace 
merge 1:1 cod using `d2000_2', gen(m2000_2)
merge 1:1 cod using `d2000_3', gen(m2000_3)
merge 1:1 cod using `d2001_1', gen(m2001_1)
merge 1:1 cod using `d2001_2', gen(m2001_2)
merge 1:1 cod using `d2001_3', gen(m2001_3)
merge 1:1 cod using `d2005_1', gen(m2005_1)
merge 1:1 cod using `d2005_2', gen(m2005_2)
merge 1:1 cod using `d2005_3', gen(m2005_3)
merge 1:1 cod using `d2010_1', gen(m2010_1)
merge 1:1 cod using `d2010_2', gen(m2010_2)
merge 1:1 cod using `d2010_3', gen(m2010_3)
merge 1:1 cod using `d2015_1', gen(m2015_1)
merge 1:1 cod using `d2015_2', gen(m2015_2)
merge 1:1 cod using `d2015_3', gen(m2015_3)
merge 1:1 cod using `d2021_1', gen(m2021_1)
merge 1:1 cod using `d2021_2', gen(m2021_2)
merge 1:1 cod using `d2021_3', gen(m2021_3)
merge 1:1 cod using `e2000_1', gen(d2000_1)
merge 1:1 cod using `e2000_2', gen(d2000_2)
merge 1:1 cod using `e2000_3', gen(d2000_3)
merge 1:1 cod using `e2001_1', gen(d2001_1)
merge 1:1 cod using `e2001_2', gen(d2001_2)
merge 1:1 cod using `e2001_3', gen(d2001_3)
merge 1:1 cod using `e2005_1', gen(d2005_1)
merge 1:1 cod using `e2005_2', gen(d2005_2)
merge 1:1 cod using `e2005_3', gen(d2005_3)
merge 1:1 cod using `e2010_1', gen(d2010_1)
merge 1:1 cod using `e2010_2', gen(d2010_2)
merge 1:1 cod using `e2010_3', gen(d2010_3)
merge 1:1 cod using `e2015_1', gen(d2015_1)
merge 1:1 cod using `e2015_2', gen(d2015_2)
merge 1:1 cod using `e2015_3', gen(d2015_3)
merge 1:1 cod using `e2021_1', gen(d2021_1)
merge 1:1 cod using `e2021_2', gen(d2021_2)
merge 1:1 cod using `e2021_3', gen(d2021_3)

label var mid2000_1 "Mortality rate: Index of disparity in 2000 - Male"
label var mid2000_2 "Mortality rate: Index of disparity in 2000 - Female"
label var mid2000_3 "Mortality rate: Index of disparity in 2000 - Both"
label var mid2001_1 "Mortality rate: Index of disparity in 2001 - Male"
label var mid2001_2 "Mortality rate: Index of disparity in 2001 - Female"
label var mid2001_3 "Mortality rate: Index of disparity in 2001 - Both"
label var mid2006_1 "Mortality rate: Index of disparity in 2006 - Male"
label var mid2006_2 "Mortality rate: Index of disparity in 2006 - Female"
label var mid2006_1 "Mortality rate: Index of disparity in 2006 - Both"
label var mid2011_1 "Mortality rate: Index of disparity in 2011 - Male"
label var mid2011_2 "Mortality rate: Index of disparity in 2011 - Female"
label var mid2011_1 "Mortality rate: Index of disparity in 2011 - Both"
label var mid2016_1 "Mortality rate: Index of disparity in 2016 - Male"
label var mid2016_2 "Mortality rate: Index of disparity in 2016 - Female"
label var mid2016_1 "Mortality rate: Index of disparity in 2016 - Both"
label var mid2021_1 "Mortality rate: Index of disparity in 2021 - Male"
label var mid2021_2 "Mortality rate: Index of disparity in 2021 - Female"
label var mid2021_1 "Mortality rate: Index of disparity in 2021 - Both"

label var did2000_1 "DALY rate: Index of disparity in 2000 - Male"
label var did2000_2 "DALY rate: Index of disparity in 2000 - Female"
label var did2000_3 "DALY rate: Index of disparity in 2000 - Both"
label var did2001_1 "DALY rate: Index of disparity in 2001 - Male"
label var did2001_2 "DALY rate: Index of disparity in 2001 - Female"
label var did2001_3 "DALY rate: Index of disparity in 2001 - Both"
label var did2006_1 "DALY rate: Index of disparity in 2006 - Male"
label var did2006_2 "DALY rate: Index of disparity in 2006 - Female"
label var did2006_1 "DALY rate: Index of disparity in 2006 - Both"
label var did2011_1 "DALY rate: Index of disparity in 2011 - Male"
label var did2011_2 "DALY rate: Index of disparity in 2011 - Female"
label var did2011_1 "DALY rate: Index of disparity in 2011 - Both"
label var did2016_1 "DALY rate: Index of disparity in 2016 - Male"
label var did2016_2 "DALY rate: Index of disparity in 2016 - Female"
label var did2016_1 "DALY rate: Index of disparity in 2016 - Both"
label var did2021_1 "DALY rate: Index of disparity in 2021 - Male"
label var did2021_2 "DALY rate: Index of disparity in 2021 - Female"
label var did2021_1 "DALY rate: Index of disparity in 2021 - Both"

format did2000_1 did2000_2 did2000_3 mid2000_1 mid2000_2 mid2000_3  %5.1f
format did2001_1 did2001_2 did2001_3 mid2001_1 mid2001_2 mid2001_3  %5.1f
format did2006_1 did2006_2 did2006_3 mid2006_1 mid2006_2 mid2006_3  %5.1f
format did2011_1 did2011_2 did2011_3 mid2011_1 mid2011_2 mid2011_3  %5.1f
format did2016_1 did2016_2 did2016_3 mid2016_1 mid2016_2 mid2016_3  %5.1f
format did2021_1 did2021_2 did2021_3 mid2021_1 mid2021_2 mid2021_3  %5.1f


** ----------------------------------------------------
** TABLE 2
** ----------------------------------------------------

	** Begin Table 
	putdocx begin , landscape font(calibri light, 10)
	putdocx paragraph 
		putdocx text ("Table 2. "), bold
		putdocx text ("Inequality summary metric (Index of Disparity, IoD) between 35 countries in the Americas in 2000 and in 2021."), 
		putdocx table t2 = data("cod mid2000_3 mid2001_3 mid2006_3 mid2011_3 mid2016_3 mid2021_3 did2000_3 did2001_3 did2006_3 did2011_3 did2016_3 did2021_3"), varnames 
		putdocx table t2(2/5,.), border(bottom, single, "e6e6e6")
		putdocx table t2(7/8,.), border(bottom, single, "e6e6e6")
		putdocx table t2(.,2/6), border(right, single, "e6e6e6")
		putdocx table t2(.,8/12), border(right, single, "e6e6e6")
		putdocx table t2(1,.),  shading("e6e6e6")
        
		putdocx table t2(1,2) = ("2000"),  font(calibri light,10, "000000")
		putdocx table t2(1,3) = ("2001"),  font(calibri light,10, "000000")
		putdocx table t2(1,4) = ("2006"),  font(calibri light,10, "000000")
		putdocx table t2(1,5) = ("2011"),  font(calibri light,10, "000000")
		putdocx table t2(1,6) = ("2016"),  font(calibri light,10, "000000")
		putdocx table t2(1,7) = ("2021"),  font(calibri light,10, "000000")
		putdocx table t2(1,8) = ("2000"),  font(calibri light,10, "000000")
		putdocx table t2(1,9) = ("2001"),  font(calibri light,10, "000000")
		putdocx table t2(1,10) = ("2006"),  font(calibri light,10, "000000")
		putdocx table t2(1,11) = ("2011"),  font(calibri light,10, "000000")
		putdocx table t2(1,12) = ("2016"),  font(calibri light,10, "000000")
		putdocx table t2(1,13) = ("2021"),  font(calibri light,10, "000000")

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
        putdocx table t2(1,2) , colspan(6)
        putdocx table t2(1,3) , colspan(6)
		putdocx table t2(1,2) = ("Between-country inequality (Mortality Rate)"),  font(calibri light,10, "000000")
		putdocx table t2(1,3) = ("Between-country inequality (DALY Rate)"),  font(calibri light,10, "000000")

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
    putdocx save "`outputpath'/inj_table2_v2", replace

