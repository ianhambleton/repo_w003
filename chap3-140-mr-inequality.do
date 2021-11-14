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
use "`datapath'\from-who\chap2_000_adjusted", clear
rename mortr arate
rename dalyr drate


** -----------------------------------------------------
** Keep only the TOP conditions used in the report
** -----------------------------------------------------
** CVD 
** 3 - IHD
** 4 - stroke
** 2 - Hypertensive
** 5 - Cardiomyopathy
** 1 - Rheumatic
gen cod = 1 if ghecause==3 
replace cod = 2 if ghecause==4
replace cod = 3 if ghecause==2
replace cod = 4 if ghecause==5
replace cod = 5 if ghecause==1

** 12   "trachea/lung" 
** 14   "breast" 
** 18   "prostate" 
** 9    "colon/rectum" 
** 15   "cervix uteri" 
** 11   "pancreas"
** 27   "lymphomas/myeloma"
** 8    "stomach"
** 10   "liver"
** 28   "leukemia"
replace cod = 6 if ghecause==12 
replace cod = 7 if ghecause==14
replace cod = 8 if ghecause==18
replace cod = 9 if ghecause==9
replace cod = 10 if ghecause==15
replace cod = 11 if ghecause==11
replace cod = 12 if ghecause==27
replace cod = 13 if ghecause==8
replace cod = 14 if ghecause==10
replace cod = 15 if ghecause==28

** Create new GHE CoD order for Table 
** 29 - COPD
** 30 - asthma
** 600 - All Respiratory
replace cod = 16 if ghecause==29
replace cod = 17 if ghecause==30

** 31 - Diabetes
replace cod = 18 if ghecause==31

** MENTAL HEALTH
** (36)  1   "Drug use disorders" 
** (32)  2   "Depressive disorders" 
** (37)  3   "Anxiety disorders" 
** (35)  4   "Alcohol use disorders" 
** (34)  5   "Schizophrenia" 
** NEUROLOGICAL
** (42)  6   "Alzheimer/dementias"
** (46)  7   "Migraine"
** (44)  8   "Epilepsy"
** (47)  9   "Non-migraine headache"
** (43)  10  "Parkinson disease"
replace cod = 19 if ghecause==36
replace cod = 20 if ghecause==32
replace cod = 21 if ghecause==37
replace cod = 22 if ghecause==35
replace cod = 23 if ghecause==34
replace cod = 24 if ghecause==42
replace cod = 25 if ghecause==46
replace cod = 26 if ghecause==44
replace cod = 27 if ghecause==47
replace cod = 28 if ghecause==43

** (1) 56   "interpersonal violence" 
** (2) 48   "road injury" 
** (3) 55   "self harm" 
** (4) 50   "falls" 
** (5) 53   "mechanical forces" 
replace cod = 29 if ghecause==56 
replace cod = 30 if ghecause==48
replace cod = 31 if ghecause==55
replace cod = 32 if ghecause==50
replace cod = 33 if ghecause==52

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
tempfile d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 


** ---------------------------------
** DEATHS: d1 to d5
** ---------------------------------

** Output: Total Deaths
preserve 
    keep if region==2000 & year==2019 & sex==3
    sort cod 
    gen tdeath = round(dths)
    keep  cod tdeath
    save  `d1', replace
restore

** Mortality Rate in 2000
preserve
    keep if region==2000 & year==2000 & sex==3
    sort cod 
    gen mr2000 = round(arate, 0.1)
    keep  cod mr2000
    save  `d2', replace
restore 

** Mortality Rate in 2019
preserve
    keep if region==2000 & year==2019 & sex==3
    sort cod 
    gen mr2019 = round(arate, 0.01)
    keep  cod mr2019
    save  `d3', replace
restore 

** Mortality Rate percentage change between 2000 and 2019
preserve
    keep if sex==3 & region==2000 & (year==2000 | year==2019)
    keep  year cod arate 
    reshape wide arate, i(cod) j(year)
    ** Improving rate (green chart) or Worsening rate (so red chart) 
    gen change = . 
    replace change = 1 if arate2019 < arate2000
    replace change = 2 if arate2019 >= arate2000
    label define change_ 1 "improving" 2 "worsening", modify 
    label values change change_
    rename change mr_change 
    ** absolute change
    gen mr_ac = (arate2019 - arate2000)
    ** percentage change
    gen mr_pc = ( (arate2019 - arate2000) / arate2000 ) * 100
    keep  cod mr_change mr_ac mr_pc 
    save  `d4', replace
restore


** Mortality Rate ratio of Men to Women in 2019
preserve
    keep if sex<3 & region==2000 & year==2019
    keep sex cod arate 
    reshape wide arate, i(cod) j(sex)

    gen mr_ratio = arate1 / arate2 
    keep  cod mr_ratio 
    save  `d5', replace
restore

** ---------------------------------------------------
** Statistics for the text to accompany this graphic
** Simple relative measure of inequality : Rate (R)
** Simple absolute measure of inequality : Difference (D)
** Simple relative measure of inequality : Index of Disparity (ID) 
** ---------------------------------------------------

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
    gen id = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim id , after(arate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) id, by(cod)
    save  `d6', replace
restore

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
    gen id2000 = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim id2000 , after(arate)

    ** Collapse to 1 row per Cause-of-death
    collapse (mean) id, by(cod)
    save  `d7', replace
restore

** Join the datasets
    use  `d1', replace
    forval x = 2(1)7 {
        merge 1:1 cod using `d`x''
        rename _merge merge`x'
    }
    drop merge*

** IoD up or down between 2000 and 2019
    gen id_change = . 
    replace id_change = 1 if id <  id2000
    replace id_change = 2 if id >= id2000
    label define id_change_ 1 "down" 2 "up", modify 
    label values id_change id_change_
    drop if cod == 20 | cod==21 | cod==25 | cod==27 
    gsort -id
    gen n2019 = _n
    gsort -id2000
    gen n2000 = _n
    order n2000 n2019, last
    gsort -id




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

    ** generate a local for the ColorBrewer color scheme
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

    ** Blue 
    local blu1 `r(p1)'
    local blu2 `r(p2)'
    ** Red
    local red1 `r(p7)'
    local red2 `r(p8)'
    ** Gray
    local gry1 `r(p15)'
    local gry2 `r(p16)'
    ** Aqua
    local aqu1 `r(p19)'
    local aqu2 `r(p20)'

** -----------------------------------------------------
** GRAPHIC
** -----------------------------------------------------
** Change in RATE between 2000 and 2019
** -----------------------------------------------------

** WILL NOT PLOT 4 CONDITIONS
** WHICH HAD VERY SMALL NUMBERS OF DEATHS
**      depressive disorders
**      anxiety disorders
**      migraines
**      non-migraine headaches
drop if cod == 20 | cod==21 | cod==25 | cod==27 

** Create graphics order according to SIZE OF IoD
gen group = 1 if cod<=5
replace group = 2 if cod>=6 & cod<=15 
replace group = 3 if cod>=16 & cod<=17 
replace group = 4 if cod>=18 & cod<=18
replace group = 5 if cod>=19 & cod<=28 
replace group = 6 if cod>=29 & cod<=33 
label define group_ 1 "cvd" 2 "cancer" 3 "crd" 4 "diabetes" 5 "mental/neuro" 6 "injuries", modify
label values group group_ 
gsort group -id
gen yorder = _n
decode cod, gen(codname)
labmask yorder, val(codname)
order group yorder, after(cod) 

** Integer absolute change in IoD
gen id_i = round(id, 1) 

** Gaps between cause of death groups
gen yorder2 = yorder 
replace yorder2 = yorder + 1 if cod>=6
replace yorder2 = yorder + 2 if cod>=16
replace yorder2 = yorder + 3 if cod>=18
replace yorder2 = yorder + 4 if cod>=19
replace yorder2 = yorder + 5 if cod>=29

** Rank importance by MR in 2019
#delimit ;
label define yorder_ 
    1     "RHD"
    2     "Stroke"
    3     "HHD"
    4     "Cardiomyopathy etc"
    5     "IHD"

    7     "Prostate cancer"
    8     "Cervical cancer"
    9     "Stomach cancer"
    10    "Lung cancer"
    11    "Breast cancer"
    12    "Liver cancer"
    13    "Pancreas cancer"
    14    "Colorectal cancer"
    15    "Lymphomas, myelomas"
    16    "Leukaemia"

    18    "Asthma"
    19    "COPD"

    21    "Diabetes"

    23    "Schizophrenia"
    24    "Drug use disorders"
    25    "Alcohol use disorders"
    26    "Epilepsy"
    27    "Dementias"
    28    "Parkinson disease"

    30    "Drowning"
    31    "IPV"
    32    "Self-harm"
    33    "Road injury"
    34    "Falls"
         , modify;
 #delimit cr
label values yorder2 yorder_ 
sort yorder
gen origin1 = 2 
gen xlocation1 = -5

local line1 1 -15  5 -15
local line2 7 -15  16 -15
local line3 18 -15  19 -15
local line4 20.5 -15  21.5 -15
local line5 23 -15  28 -15
local line6 30 -15  34 -15

#delimit ;  
	gr twoway 
		/// country values
        (rbar origin1 id yorder2 if cod>=1 & cod<=5  , horizontal barw(0.6) fcol("`cvd2'") lcol("`cvd2'") lw(0.1))           
        (rbar origin1 id yorder2 if cod>=6 & cod<=15 , horizontal barw(0.6) fcol("`can2'") lcol("`can2'") lw(0.1))           
        (rbar origin1 id yorder2 if cod>=16 & cod<=17, horizontal barw(0.6) fcol("`crd2'") lcol("`crd2'") lw(0.1))           
        (rbar origin1 id yorder2 if cod>=18 & cod<=18, horizontal barw(0.6) fcol("`dia2'") lcol("`dia2'") lw(0.1))           
        (rbar origin1 id yorder2 if cod>=19 & cod<=28, horizontal barw(0.6) fcol("`men2'") lcol("`men2'") lw(0.1))           
        (rbar origin1 id yorder2 if cod>=29 & cod<=33, horizontal barw(0.6) fcol("`inj2'") lcol("`inj2'") lw(0.1))           
        (sc yorder2 xlocation1, msymbol(i) mlabel(id_i) mlabsize(2) mlabcol(gs8) mlabp(0))
        (scatteri -0.5 50 "Index of Disparity, 2019" , msymbol(i) mlabpos(0) mlabcol(gs8) mlabsize(2.5) mlabangle(0))
        /// (scatteri `line1' , recast(line) lw(0.2) lc("gs12") fc("gs12") lp("l") )
        /// (scatteri `line2' , recast(line) lw(0.2) lc("gs12") fc("gs12") lp("l") )
        /// (scatteri `line3' , recast(line) lw(0.2) lc("gs12") fc("gs12") lp("l") )
        /// (scatteri `line4' , recast(line) lw(0.2) lc("gs12") fc("gs12") lp("l") )
        /// (scatteri `line5' , recast(line) lw(0.2) lc("gs12") fc("gs12") lp("l") )
        /// (scatteri `line6' , recast(line) lw(0.2) lc("gs12") fc("gs12") lp("l") )

                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(10) xsize(10)

			xlab(0(50)150, 
            notick labs(2.5) tlc(gs0) labc(gs8) notick nogrid glc(gs16))
			xscale(noline noextend) 
			xtitle("", size(2) color(gs0) margin(l=0 r=0 t=0 b=0)) 
			
			ylab(1(1)5 7(1)16 18 19 21 23(1)28 30(1)34, valuelabel
			labc(gs8) labs(2) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(1))
			yscale(reverse noline lw(vthin) ) 
			ytitle("", size(2) margin(l=0 r=0 t=0 b=0)) 

            /// text(3.0  -15 "Cardiovascular" "Disease"        , place(w) size(2) color("gs8") just(right) margin(l=0 r=1 t=4 b=2))
            /// text(10.5 -15 "Cancers"                         , place(w) size(2) color("gs8") just(right) margin(l=0 r=1 t=4 b=2))
            /// text(18.0 -15 "Chronic Respiratory" "Diseases"  , place(w) size(2) color("gs8") just(right) margin(l=0 r=1 t=4 b=2))
            /// text(20.5 -15 "Diabetes"                        , place(w) size(2) color("gs8") just(right) margin(l=0 r=1 t=4 b=2))
            /// text(25.0 -15 "Mental Health /" "Neurological"  , place(w) size(2) color("gs8") just(right) margin(l=0 r=1 t=4 b=2))
            /// text(31.0 -15 "External" "Causes"               , place(w) size(2) color("gs8") just(right) margin(l=0 r=1 t=4 b=2))

            legend(off)
			name(mr_IoD)
			;
#delimit cr	