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
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs"

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
    gen tdaly = round(daly)
    keep  cod tdaly
    save  `d1', replace
restore

** Mortality Rate in 2000
preserve
    keep if region==2000 & year==2000 & sex==3
    sort cod 
    gen dr2000 = round(drate, 0.1)
    keep  cod dr2000
    save  `d2', replace
restore 

** Mortality Rate in 2019
preserve
    keep if region==2000 & year==2019 & sex==3
    sort cod 
    gen dr2019 = round(drate, 0.01)
    keep  cod dr2019
    save  `d3', replace
restore 


** DALY Rate ratio of Men to Women in 2019
preserve
    keep if sex<3 & region==2000 & year==2019
    keep sex cod drate 
    reshape wide drate, i(cod) j(sex)

    gen drat2019 = drate1 / drate2 
    keep  cod drat2019
    save  `d4', replace
restore

** DALY Rate ratio of Men to Women in 2000
preserve
    keep if sex<3 & region==2000 & year==2000
    keep sex cod drate 
    reshape wide drate, i(cod) j(sex)

    gen drat2000 = drate1 / drate2 
    keep  cod drat2000
    save  `d5', replace
restore

** Mortality Rate ratio of Men to Women in 2019
preserve
    keep if sex<3 & region==2000 & year==2019
    keep sex cod arate 
    reshape wide arate, i(cod) j(sex)

    gen arat2019 = arate1 / arate2 
    keep  cod arat2019
    save  `d6', replace
restore

** Mortality Rate ratio of Men to Women in 2000
preserve
    keep if sex<3 & region==2000 & year==2000
    keep sex cod arate 
    reshape wide arate, i(cod) j(sex)

    gen arat2000 = arate1 / arate2 
    keep  cod arat2000
    save  `d7', replace
restore

** Join the datasets
    use  `d1', replace
    forval x = 2(1)7 {
        merge 1:1 cod using `d`x''
        rename _merge merge`x'
    }
    order cod tdaly dr2000 dr2019 arat2000 arat2019 drat2000 drat2019  
    drop merge*

    ** Breast cancer should not have a gender ratio 
    replace drat2019 = . if cod==7 | cod==10
    replace drat2000 = . if cod==7 | cod==10
    replace arat2019 = . if cod==7 | cod==10
    replace arat2000 = . if cod==7 | cod==10
    ** 4 conditions should not have a MR gender ratio
    **      depressive disorders
    **      anxiety disorders
    **      migraines
    **      non-migraine headaches
    replace arat2000 = . if cod == 20 | cod==21 | cod==25 | cod==27     
    replace arat2019 = . if cod == 20 | cod==21 | cod==25 | cod==27     


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
** Change in GENDER DALY rate between 2000 and 2019
** -----------------------------------------------------
drop if drat2019==.

** Create graphics order according to SIZE OF IoD
gen group = 1 if cod<=5
replace group = 2 if cod>=6 & cod<=15 
replace group = 3 if cod>=16 & cod<=17 
replace group = 4 if cod>=18 & cod<=18
replace group = 5 if cod>=19 & cod<=28 
replace group = 6 if cod>=29 & cod<=33 
label define group_ 1 "cvd" 2 "cancer" 3 "crd" 4 "diabetes" 5 "mental/neuro" 6 "injuries", modify
label values group group_ 
gsort group -drat2019
gen yorder = _n
decode cod, gen(codname)
labmask yorder, val(codname)
order group yorder, after(cod) 

** Integer absolute change in Gender Ratio
/// gen id_i = round(id, 1) 

** Gaps between cause of death groups
gen yorder2 = yorder 
replace yorder2 = yorder + 1 if cod>=6
replace yorder2 = yorder + 2 if cod>=16
replace yorder2 = yorder + 3 if cod>=18
replace yorder2 = yorder + 4 if cod>=19
replace yorder2 = yorder + 7 if cod>=29

** Rank importance by MR in 2019
#delimit ;
label define yorder_ 
    1    "IHD"
    2    "Cardiomyopathy etc"
    3    "HHD"
    4    "Stroke"
    5    "RHD"

    7    "Liver cancer"
    8    "Stomach cancer"
    9    "Lymphomas, myelomas"
    10    "Lung cancer"
    11    "Leukemia"
    12    "Colorectal cancer"
    13    "Pancreatic cancer"

    15    "COPD"
    16    "Asthma"

    18    "Diabetes"

    20    "Alcohol use disorders"
    21    "Parkinson disease"
    22    "Drug use disorders"
    23    "Epilepsy"
    24    "Schizophrenia"
    25    "Dementias"
    26    "Non-migraine headache"
    27    "Anxiety disorders"
    28    "Depressive disorders"
    29    "Migraine"

    33    "IPV"
    34    "Drowning"
    35    "Self-harm"
    36    "Road injury"
    37    "Falls"
         , modify;
 #delimit cr

gen change = 1 if drat2019 > drat2000
replace change = 2 if drat2019 < drat2000
replace change = 3 if drat2019 == drat2000
label define change_ 1 "up" 2 "down" 3 "same"
label values change change_ 
order change, after(drat2019)

gen origin2000_up = 1.05
gen origin2019_up = 1.05
gen origin2000_dn = 0.95
gen origin2019_dn = 0.95

gen yorder2000 = yorder2 
gen yorder2019 = yorder2 
label values yorder2000 yorder_ 
label values yorder2019 yorder_ 

** The Gender ratio values for plotting on graphic
** Ratios < 1 are reciprocated 
gen i2019 = drat2019 
** replace i2019 = 1/drat2019 if drat2019 < 1
replace i2019 = drat2019 if drat2019 < 1
replace i2019 = round(i2019,0.1)
format i2019 %3.1fc 
** The Gender ration values for creating bar lengths
** note that injury values are contracted for visual ease
gen drat2019_inj = 3.25 if cod==29
replace drat2019_inj = 1.85 if cod==33
replace drat2019_inj = 1.6 if cod==31
replace drat2019_inj = 1.6 if cod==30
replace drat2019_inj = 1.3 if cod==32

local line1 -3.5 1  29.5 1
local line2 32.5 1  37.5 1
local line3 0.5 0  29.5 0
local line4 32.5 0  37.5 0
local box1 0  0   -1.25 0   -1.25 3.25   0 3.25  0 0   

local box2 32 0   30.75 0   30.75 3.25   32 3.25  32 0 

gen xlocation = -0.15
gen drat2019i = drat2019 
order drat2019, after(cod)

** Unicode markers for graphic
/// †  	U+2020 (alt-08224)	DAGGER = obelisk, obelus, long cross
/// ‡  	U+2021 (alt-08225)	DOUBLE DAGGER = diesis, double obelisk
/// •  	U+2022 (alt-08226)	BULLET = black small circle
/// x   U+00D7 (alt-0215)
local mult = uchar(0215)

** 2019 only
#delimit ;  
	gr twoway 
        /// CVD
        (rbar origin2019_up drat2019 yorder2019 if cod>=1 & cod<=5 & drat2019>1, horizontal barw(0.5) fcol("`cvd2'") lcol("`cvd2'") lw(0.1))   
        (rbar origin2019_dn drat2019 yorder2019 if cod>=1 & cod<=5 & drat2019<1, horizontal barw(0.5) fcol("`cvd2'") lcol("`cvd2'") lw(0.1))   

        /// Cancer
        (rbar origin2019_up drat2019 yorder2019 if cod>=6 & cod<=15 & drat2019>1, horizontal barw(0.5) fcol("`can2'") lcol("`can2'") lw(0.1))   
        (rbar origin2019_dn drat2019 yorder2019 if cod>=6 & cod<=15 & drat2019<1, horizontal barw(0.5) fcol("`can2'") lcol("`can2'") lw(0.1))   
 
        /// CRD
        (rbar origin2019_up drat2019 yorder2019 if cod>=16 & cod<=17 & drat2019>1, horizontal barw(0.5) fcol("`crd2'")     lcol("`crd2'") lw(0.1))   
        (rbar origin2019_dn drat2019 yorder2019 if cod>=16 & cod<=17 & drat2019<1, horizontal barw(0.5) fcol("`crd2'")     lcol("`crd2'") lw(0.1))   

        /// Diabetes
        (rbar origin2019_up drat2019 yorder2019 if cod>=18 & cod<=18 & drat2019>1, horizontal barw(0.5) fcol("`dia2'")     lcol("`dia2'") lw(0.1))   
        (rbar origin2019_dn drat2019 yorder2019 if cod>=18 & cod<=18 & drat2019<1, horizontal barw(0.5) fcol("`dia2'")     lcol("`dia2'") lw(0.1))   
 
        /// Mental Health / Neurological
        (rbar origin2019_up drat2019 yorder2019 if cod>=19 & cod<=28 & drat2019>1, horizontal barw(0.5) fcol("`men2'")     lcol("`men2'") lw(0.1))   
        (rbar origin2019_dn drat2019 yorder2019 if cod>=19 & cod<=28 & drat2019<1, horizontal barw(0.5) fcol("`men2'")     lcol("`men2'") lw(0.1))   

        /// Injuries
        (rbar origin2019_up drat2019_inj yorder2019 if cod>=29 & cod<=33 & drat2019>1, horizontal barw(0.5) fcol("`inj2'")     lcol("`inj2'") lw(0.1))   
        (rbar origin2019_dn drat2019_inj yorder2019 if cod>=29 & cod<=33 & drat2019<1, horizontal barw(0.5) fcol("`inj2'")     lcol("`inj2'") lw(0.1))    

        (scatteri `line1' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("-") )
        (scatteri `line2' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("-") )
        (scatteri `line3' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("l") )
        (scatteri `line4' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("l") )
        (scatteri `box1'  , recast(area) lw(0.1) lc("gs13%50") fc("gs13%50") lp("l"))
        (scatteri `box2'  , recast(area) lw(0.1) lc("gs13%50") fc("gs13%50") lp("l"))

        /// The Gender Ratio values
        (sc yorder2019 xlocation, msymbol(i) mlabel(i2019) mlabsize(2.5) mlabcol(gs8) mlabp(0))

                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(14) xsize(10)

			xlab(none, 
            notick labs(2.5) tlc(gs0) labc(gs8) notick nogrid glc(gs16))
			xscale(noline noextend range(0(1)3)) 
			xtitle("", size(2) color(gs0) margin(l=0 r=0 t=0 b=0)) 

			ylab(1(1)5 7(1)13 15 16 18 20(1)29 33(1)37, valuelabel
			labc(gs8) labs(2.4) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(1))
			yscale(reverse noline lw(vthin) range(-4(1)38)) 
			ytitle("", size(2) margin(l=0 r=0 t=0 b=0)) 

            text(-5 1 "DALY gender ratio, 2019" , place(c) size(3.5) color("gs8") just(right) margin(l=0 r=1 t=4 b=2))
            text(-3 0.75 "More" "women"        , place(w) size(3) color("gs8") just(right) margin(l=0 r=1 t=4 b=2))
            text(-3 1.5 "More" "men"        , place(e) size(3) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))

            text(-0.9 0.5 "`mult'2"        , place(c) size(3) color("gs6") just(left) margin(l=0 r=1 t=4 b=2))
            text(-0.9 2 "`mult'2"        , place(c) size(3) color("gs6") just(left) margin(l=0 r=1 t=4 b=2))
            text(-0.9 3 "`mult'3"        , place(c) size(3) color("gs6") just(left) margin(l=0 r=1 t=4 b=2))

            text(31.1 0.5 "`mult'2"        , place(c) size(3) color("gs6") just(left) margin(l=0 r=1 t=4 b=2))
            text(31.1 2 "`mult'4"        , place(c) size(3) color("gs6") just(left) margin(l=0 r=1 t=4 b=2))
            text(31.1 3 "`mult'6"        , place(c) size(3) color("gs6") just(left) margin(l=0 r=1 t=4 b=2))

            legend(off)
			name(gr_2019)
			;
#delimit cr	

** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\2024-edits\graphics\fig30.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig30.pdf", replace





/*
** 2000 and 2019
#delimit ;  
	gr twoway 
        /// CVD
        (rbar origin2019_up drat2019 yorder2019 if cod>=1 & cod<=5 & drat2019>1, horizontal barw(0.35) fcol("`cvd1'") lcol("`cvd2'") lw(0.1))   
        (rbar origin2000_up drat2000 yorder2000 if cod>=1 & cod<=5 & drat2000>1, horizontal barw(0.35) fcol("`cvd1'%50") lcol("`cvd1'%50") lw(0.1))   
        (rbar origin2019_dn drat2019 yorder2019 if cod>=1 & cod<=5 & drat2019<1, horizontal barw(0.35) fcol("`cvd1'") lcol("`cvd2'") lw(0.1))   
        (rbar origin2000_dn drat2000 yorder2000 if cod>=1 & cod<=5 & drat2000<1, horizontal barw(0.35) fcol("`cvd1'%50") lcol("`cvd1'%50") lw(0.1))   

        /// Cancer
        (rbar origin2019_up drat2019 yorder2019 if cod>=6 & cod<=15 & drat2019>1, horizontal barw(0.35) fcol("`can2'") lcol("`can2'") lw(0.1))   
        (rbar origin2000_up drat2000 yorder2000 if cod>=6 & cod<=15 & drat2000>1, horizontal barw(0.35) fcol("`can2'%50") lcol("`can2'%50") lw(0.1))   
        (rbar origin2019_dn drat2019 yorder2019 if cod>=6 & cod<=15 & drat2019<1, horizontal barw(0.35) fcol("`can2'") lcol("`can2'") lw(0.1))   
        (rbar origin2000_dn drat2000 yorder2000 if cod>=6 & cod<=15 & drat2000<1, horizontal barw(0.35) fcol("`can2'%50") lcol("`can2'%50") lw(0.1))   
 
        /// CRD
        (rbar origin2019_up drat2019 yorder2019 if cod>=16 & cod<=17 & drat2019>1, horizontal barw(0.35) fcol("`crd2'")     lcol("`crd2'") lw(0.1))   
        (rbar origin2000_up drat2000 yorder2000 if cod>=16 & cod<=17 & drat2000>1, horizontal barw(0.35) fcol("`crd2'%50")  lcol("`crd2'%50") lw(0.1))   
        (rbar origin2019_dn drat2019 yorder2019 if cod>=16 & cod<=17 & drat2019<1, horizontal barw(0.35) fcol("`crd2'")     lcol("`crd2'") lw(0.1))   
        (rbar origin2000_dn drat2000 yorder2000 if cod>=16 & cod<=17 & drat2000<1, horizontal barw(0.35) fcol("`crd2'%50")  lcol("`crd2'%50") lw(0.1))   

        /// Diabetes
        (rbar origin2019_up drat2019 yorder2019 if cod>=18 & cod<=18 & drat2019>1, horizontal barw(0.35) fcol("`dia2'")     lcol("`dia2'") lw(0.1))   
        (rbar origin2000_up drat2000 yorder2000 if cod>=18 & cod<=18 & drat2000>1, horizontal barw(0.35) fcol("`dia2'%50")  lcol("`dia2'%50") lw(0.1))   
        (rbar origin2019_dn drat2019 yorder2019 if cod>=18 & cod<=18 & drat2019<1, horizontal barw(0.35) fcol("`dia2'")     lcol("`dia2'") lw(0.1))   
        (rbar origin2000_dn drat2000 yorder2000 if cod>=18 & cod<=18 & drat2000<1, horizontal barw(0.35) fcol("`dia2'%50")  lcol("`dia2'%50") lw(0.1))   
 
        /// Mental Health / Neurological
        (rbar origin2019_up drat2019 yorder2019 if cod>=19 & cod<=28 & drat2019>1, horizontal barw(0.35) fcol("`men2'")     lcol("`men2'") lw(0.1))   
        (rbar origin2000_up drat2000 yorder2000 if cod>=19 & cod<=28 & drat2000>1, horizontal barw(0.35) fcol("`men2'%50")  lcol("`men2'%50") lw(0.1))   
        (rbar origin2019_dn drat2019 yorder2019 if cod>=19 & cod<=28 & drat2019<1, horizontal barw(0.35) fcol("`men2'")     lcol("`men2'") lw(0.1))   
        (rbar origin2000_dn drat2000 yorder2000 if cod>=19 & cod<=28 & drat2000<1, horizontal barw(0.35) fcol("`men2'%50")  lcol("`men2'%50") lw(0.1))   

        /// Injuries
        (rbar origin2019_up drat2019 yorder2019 if cod>=29 & cod<=33 & drat2019>1, horizontal barw(0.35) fcol("`inj2'")     lcol("`inj2'") lw(0.1))   
        (rbar origin2000_up drat2000 yorder2000 if cod>=29 & cod<=33 & drat2000>1, horizontal barw(0.35) fcol("`inj2'%50")  lcol("`inj2'%50") lw(0.1))   
        (rbar origin2019_dn drat2019 yorder2019 if cod>=29 & cod<=33 & drat2019<1, horizontal barw(0.35) fcol("`inj2'")     lcol("`inj2'") lw(0.1))   
        (rbar origin2000_dn drat2000 yorder2000 if cod>=29 & cod<=33 & drat2000<1, horizontal barw(0.35) fcol("`inj2'%50")  lcol("`inj2'%50") lw(0.1))   


        (scatteri `line1' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("-") )
        (scatteri `line2' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("-") )
        (scatteri `line3' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("l") )
        (scatteri `line4' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("l") )
        (scatteri `box1'  , recast(area) lw(0.1) lc("gs13%50") fc("gs13%50") lp("l"))
        (scatteri `box2'  , recast(area) lw(0.1) lc("gs13%50") fc("gs13%50") lp("l"))

                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(18) xsize(10)

			xlab(none, 
            notick labs(2.5) tlc(gs0) labc(gs8) notick nogrid glc(gs16))
			xscale(noline noextend range(-1(1)4)) 
			xtitle("", size(2) color(gs0) margin(l=0 r=0 t=0 b=0)) 

			ylab(1(1)5 7(1)13 15 16 18 20(1)29 33(1)37, valuelabel
			labc(gs8) labs(3) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(1))
			yscale(reverse noline lw(vthin) range(-4(1)38)) 
			ytitle("", size(2) margin(l=0 r=0 t=0 b=0)) 

            text(-5 1 "DALY Gender Ratio, 2000 to 2019" , place(c) size(4) color("gs8") just(right) margin(l=0 r=1 t=4 b=2))
            text(-3 0.5 "More" "Women"        , place(w) size(3) color("gs8") just(right) margin(l=0 r=1 t=4 b=2))
            text(-3 1.5 "More" "Men"        , place(e) size(3) color("gs8") just(left) margin(l=0 r=1 t=4 b=2))

            text(-0.9 0.5 "x2"        , place(c) size(4) color("gs6") just(left) margin(l=0 r=1 t=4 b=2))
            text(-0.9 2 "x2"        , place(c) size(4) color("gs6") just(left) margin(l=0 r=1 t=4 b=2))
            text(-0.9 4 "x4"        , place(c) size(4) color("gs6") just(left) margin(l=0 r=1 t=4 b=2))

            text(31.1 0.5 "x2"        , place(c) size(4) color("gs6") just(left) margin(l=0 r=1 t=4 b=2))
            text(31.1 2 "x4"        , place(c) size(4) color("gs6") just(left) margin(l=0 r=1 t=4 b=2))
            text(31.1 4 "x8"        , place(c) size(4) color("gs6") just(left) margin(l=0 r=1 t=4 b=2))

            legend(off)
			name(gr_2000_2019)
			;
#delimit cr	
