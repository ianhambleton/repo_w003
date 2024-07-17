** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap3-100-mr-change.do
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
    log using "`logpath'\chap3-100-mr-change", replace
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

** ---------------------------------
** DALYs: d6 to d10
** ---------------------------------

** Output: Total DALYs
preserve 
    keep if region==2000 & year==2019 & sex==3
    sort cod 
    gen tdaly = round(daly)
    keep  cod tdaly
    save  `d6', replace
restore

** DALY Rate in 2000
preserve
    keep if region==2000 & year==2000 & sex==3
    sort cod 
    gen dr2000 = round(drate, 0.1)
    keep  cod dr2000
    save  `d7', replace
restore 

** Mortality Rate in 2019
preserve
    keep if region==2000 & year==2019 & sex==3
    sort cod 
    gen dr2019 = round(drate, 0.1)
    keep  cod dr2019
    save  `d8', replace
restore 

** Mortality Rate percentage change between 2000 and 2019
preserve
    keep if sex==3 & region==2000 & (year==2000 | year==2019)
    keep  year cod drate 
    reshape wide drate, i(cod) j(year)
    ** Improving rate (green chart) or Worsening rate (so red chart) 
    gen change = . 
    replace change = 1 if drate2019 < drate2000
    replace change = 2 if drate2019 >= drate2000
    label define change_ 1 "improving" 2 "worsening", modify 
    label values change change_
    rename change dr_change 
    ** absolute change
    gen dr_ac = (drate2019 - drate2000)
    ** percentage change
    gen dr_pc = ( (drate2019 - drate2000) / drate2000 ) * 100
    keep  cod dr_change dr_ac dr_pc 
    save  `d9', replace
restore


** Mortality Rate ratio of Men to Women in 2019
preserve
    keep if sex<3 & region==2000 & year==2019
    keep sex cod arate 
    reshape wide arate, i(cod) j(sex)

    gen mr_ratio = arate1 / arate2 
    keep  cod mr_ratio 
    save  `d10', replace
restore


** Join the datasets
    use  `d1', replace
    forval x = 2(1)10 {
        merge 1:1 cod using `d`x''
        rename _merge merge`x'
    }
    drop merge*

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

** Create graphics order according to SIZE OF MORT.RATE CHANGE
sort mr_ac
gen yorder = _n
decode cod, gen(codname)
labmask yorder, val(codname)
order yorder, after(cod) 
gen xlocation1 = -40
gen xlocation2 = -45

** Integer absolute change
gen mr_aci = round(mr_ac, 1) 
replace mr_aci = round(mr_ac, 0.1) if mr_ac>-1 & mr_ac<1 


** Rank importance by MR in 2019
gsort -mr2019 
gen rank = _n
order rank, after(yorder)

#delimit ;
label define yorder_ 
        1  "IHD"
        2  "Stroke"
        3  "Lung cancer"
        4  "COPD"
        5  "Prostate cancer"
        6  "Breast cancer"
        7  "Cardiomyopathy etc"
        8  "Colorectal cancer"
        9  "Road injury"
        10 "Stomach cancer"
        11 "Lymphomas, myelomas"
        12 "Cervical cancer"
        13 "Leukemia"
        14 "Diabetes"
        15 "Asthma"
        16 "Drowning"
        17 "RHD"
        18 "IPV"
        19 "Alcohol use disorders"
        20 "Pancreatic cancer"
        21 "Schizophrenia"
        22 "Epilepsy"
        23 "Liver cancer"
        24 "Parkinson disease"
        25 "HHD"
        26 "Self-harm"
        27 "Falls"
        28 "Drug use disorders"
        29 "Dementias", modify;
#delimit cr
label values yorder yorder_ 
sort yorder


** Negative change
gen origin1 = -1 
gen mr_ac_gr1 = mr_ac - 1 if mr_ac<0
replace mr_ac_gr1 = -35 if mr_aci==-44
replace mr_ac_gr1 = mr_ac_gr1 - 0.5 

** Positive change
gen origin2 = 1
gen mr_ac_gr2 = mr_ac + 1 if mr_ac>=0
replace mr_ac_gr2 = mr_ac_gr2 + 0.5 if cod!=23

local line1 29 0 1 0
local line2 20.5 -40 20.5 0
local line3 29.5 -60 29.5 -40
** Triangles & associated text
local outer1 15 -35 20 -32 15 -29 15 -35
local outer2 26 -35 21 -32 26 -29 26 -35
bysort mr_change : egen schange1 = sum(mr_ac)
gen schange2 = abs(int(schange1)) 
egen schange3 = max(schange2)
global sch_fewer = schange3
egen schange4 = min(schange2)
global sch_more = schange4

/// #delimit ; 
/// label define mr_aci_    -44 "–44"
///                         -18 "–18"
///                         -9 "–9"
///                         -6 "–6"
///                         -5 "–5"
///                         -4 "–4"
///                         -3 "–3"
///                         -3 "–3"
///                         -3 "–3"
///                         -2 "–2"
///                         -2 "–2"
///                         -2 "–2"
///                         -1 "–1"
///                         -1 "–1"
///                         -.9 "–0.9"
///                         -.8 "–0.8"
///                         -.6 "–0.6"
///                         -.6 "–0.6"
///                         -.1 "–0.1"
///                         -.1 "–0.1"
///                         0 "0"
///                         .1 "0.1"
///                         .5 "0.5"
///                         .8 "0.8"
///                         1 "1"
///                         1 "1"
///                         2 "2"
///                         5 "5"
///                         11 "11", modify;
/// label values mr_aci mr_aci_;
/// #delimit cr 

gen yorder1 = yorder 
order yorder1, after(yorder)

#delimit ; 
label define yorder1_    1 "–44"
                        2 "–18"
                        3 "–9"
                        4 "–6"
                        5 "–5"
                        6 "–4"
                        7 "–3"
                        8 "–3"
                        9 "–3"
                        10 "–2"
                        11 "–2"
                        12 "–2"
                        13 "–1"
                        14 "–1"
                        15 "–0.9"
                        16 "–0.8"
                        17 "–0.6"
                        18 "–0.6"
                        19 "–0.1"
                        20 "–0.1"
                        21 "0"
                        22 "0.1"
                        23 "0.5"
                        24 "0.8"
                        25 "1"
                        26 "1"
                        27 "2"
                        28 "5"
                        29 "11", modify;
label values yorder1 yorder1_;
#delimit cr


#delimit ;  
	gr twoway 
		/// country values
        (rbar origin1 mr_ac_gr1 yorder if mr_pc<0, horizontal barw(0.6) fcol("`improve'") lcol("`improve'") lw(0.1))           
        (rbar origin2 mr_ac_gr2 yorder if mr_pc>=0, horizontal barw(0.6) fcol("`worsen'") lcol("`worsen'") lw(0.1))           
        (sc yorder1 xlocation1, msymbol(i) mlabel(yorder1) mlabsize(2.3) mlabcol(gs8) mlabp(0))
        (scatteri `line1' , recast(line) lw(0.2) lc("`gry1'%50") fc("`gry1'%50") lp("-") )
        (scatteri `line2' , recast(line) lw(0.2) lc("`gry2'%25") fc("`gry2'%25") lp("l") )
        (scatteri -0.5 -25 "Absolute change (2000 to 2019)" , msymbol(i) mlabpos(0) mlabcol(gs8) mlabsize(3) mlabangle(0))
        (scatteri `outer1' , recast(area) lw(none) lc("`improve'%25") fc("`improve'%25")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`worsen'%25") fc("`worsen'%25")  )
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(12) xsize(10)

			xlab(none, 
            notick labs(2.5) tlc(gs0) labc(gs8) notick nogrid glc(gs16))
			xscale(noline ) 
			xtitle("", size(2) color(gs0) margin(l=0 r=0 t=0 b=0)) 
			
			ylab(1(1)29, valuelabel
			labc(gs8) labs(2.5) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(2))
			yscale(reverse noline lw(vthin) range(1(1)31)) 
			ytitle("", size(2) margin(l=0 r=0 t=0 b=0)) 

            text(17 -30 "$sch_fewer fewer deaths" "per 100 000", place(e) size(2.5) color("`improve'%85") just(center) margin(l=2 r=2 t=2 b=2))
            text(23 -30 "$sch_more more deaths" "per 100 000", place(e) size(2.5) color("`worsen'%85") just(center) margin(l=2 r=2 t=2 b=2))

            text(31 -64 "Abbreviations:", place(e) size(2) color(gs8)  just(left)) 
            text(31.75 -64 "IHD=Ischemic heart disease, COPD=Chronic obstructive pulmonary disease", just(left) place(e) size(2) color(gs8) ) 
            text(32.5 -64 "RHD=Rheumatic heart disease, IPV=Interpersonal violence, HHD=Hypertensive heart disease", just(left) place(e) size(2) color(gs8) ) 

            legend(off)
			name(mr_change57)
			;
#delimit cr	

** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\2024-edits\graphics\fig26.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig26.pdf", replace



** Export data for Figure 26
keep yorder mr_ac
rename yorder cause
rename mr_ac mortality_rate
export excel "`outputpath'\reports\2024-edits\graphics\chap3_data.xlsx", sheet("figure-26", replace) first(var)


