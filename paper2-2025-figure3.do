** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-2025-figure3.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	9-Jul-2022
    //  algorithm task			    Figure 3. Gender inequality in injuries

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
    log using "`logpath'\paper2-2025-figure3", replace
** HEADER -----------------------------------------------------


** -----------------------------------------------------
** TABLE PART ONE 
** DEATHS METRICS
** -----------------------------------------------------

tempfile kcancer region_mr12 region_mr3 region_daly12 region_daly3

** Mortality Rate statistics first
use "`datapath'\dataset01", clear
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

**  (ghecause: 1) - all causes 
**  (ghecause: 2) - communicable 
**  (ghecause: 3) - NCDs 
**  (ghecause: 4) - injuries
**  (ghecause: 5) - unintentional injuries
**  (ghecause: 6) - intentional injuries
**
**  (ghecause  7) - road injury
**  (ghecause  8) - poisonings
**  (ghecause  9) - falls
**  (ghecause 10) - fire and heat
**  (ghecause 11) - drowning
**  (ghecause 12) - mechanical forces
**  (ghecause 13) - natural disasters
**  (ghecause 14) - self harm
**  (ghecause 15) - interpersonal violence
**  (ghecause 16) - collective violence

** Interpersonal violence (was 56, now 15)
gen cod = 1 if ghecause==15 
** Road injury (was 48, now 7)
replace cod = 2 if ghecause==7
** Self harm (was 55, now 14)
replace cod = 3 if ghecause==14
** Falls (was 50, now 9)
replace cod = 4 if ghecause==9
** Drowning (was 52, now 11)
replace cod = 5 if ghecause==11
** Mechanical forces (was 53, now 12)
replace cod = 6 if ghecause==12
** Fire and heat (was 51, now 10)
replace cod = 7 if ghecause==10
** Poisonings (was 49, now 8) 
replace cod = 8 if ghecause==8
** Collective violence (was 57, now 16)
replace cod = 9 if ghecause==16
** Natural disasters (was 54, now 13)
replace cod = 10 if ghecause==13
** All injuries (was 1000, now 4)
replace cod = 11 if ghecause==4
** Unintentional injuries (was 1100, now 5)
replace cod = 12 if ghecause==5
** Intentional injuries (was 1200, now 6)
replace cod = 13 if ghecause==6

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
tempfile d1 d2 d3 d4 d5 d6 d7 d8

** ---------------------------------
** DEATHS: d1 to d5
** ---------------------------------

** Output: Male DALYs in 2019
preserve 
    keep if (region>=36 & region<=44) & year==2021 & sex==1
    sort cod 
    gen tdaly1 = round(daly)
    keep  cod tdaly1 region
    save  `d1', replace
restore

** Output: Female DALYs in 2021
preserve 
    keep if (region>=36 & region<=44) & year==2021 & sex==2
    sort cod 
    gen tdaly2 = round(daly)
    keep  cod tdaly2 region
    save  `d2', replace
restore

** Output: Total DALYs in 2021
preserve 
    keep if (region>=36 & region<=44) & year==2021 & sex==3
    sort cod 
    gen tdaly3 = round(daly)
    keep  cod tdaly3 region
    save  `d3', replace
restore

** DALY Rate in 2021 (Men)
preserve
    keep if (region>=36 & region<=44) & year==2021 & sex==1
    sort cod 
    gen dr2021_1 = round(drate, 0.01)
    keep  cod dr2021_1 region
    save  `d4', replace
restore 

** DALY Rate in 2021 (Women)
preserve
    keep if (region>=36 & region<=44) & year==2021 & sex==2
    sort cod 
    gen dr2021_2 = round(drate, 0.01)
    keep  cod dr2021_2 region
    save  `d5', replace
restore 

** DALY Rate in 2021 (Men + Women)
preserve
    keep if (region>=36 & region<=44) & year==2021 & sex==3
    sort cod 
    gen dr2021_3 = round(drate, 0.01)
    keep  cod dr2021_3 region
    save  `d6', replace
restore 

** DALY Rate ratio of Men to Women in 2000
preserve
    keep if (region>=36 & region<=44) & sex<3 & year==2000
    keep sex cod drate region
    reshape wide drate, i(cod region) j(sex)

    gen drat2000 = drate1 / drate2 
    keep  cod drat2000 region
    save  `d7', replace
restore

** DALY Rate ratio of Men to Women in 2021
preserve
    keep if (region>=36 & region<=44) & sex<3 & year==2021
    keep sex cod drate region
    reshape wide drate, i(cod region) j(sex)

    gen drat2021 = drate1 / drate2 
    keep  cod drat2021 region
    save  `d8', replace
restore


** Join the datasets
    use  `d1', replace
    forval x = 2(1)8 {
        merge 1:1 cod region using `d`x''
        rename _merge merge`x'
    }
    format tdaly1 tdaly2 tdaly3 %15.1fc
    order cod tdaly* dr2021* drat2000 drat2021  
    drop merge*

label var cod "Cause of disease burden"
label var tdaly1 "Male DALYs in 2021"
label var tdaly2 "Female DALYs in 2021"
label var tdaly3 "Total DALYs in 2021"
label var dr2021_1 "DALY rate per 100,000 in 2021 - Men"
label var dr2021_2 "DALY rate per 100,000 in 2021 - Women"
label var dr2021_3 "DALY rate per 100,000 in 2021 - All"
label var drat2000 "DALY rate ratio men:women in 2000"
label var drat2021 "DALY rate ratio men:women in 2021"

** -----------------------------------------------------
** GRAPHICS COLOR SCHEME
** -----------------------------------------------------
    colorpalette ptol rainbow , n(12)  nograph
    local list r(p) 
    ** Mortality Rate
    local mrate `r(p1)'
    ** DALY
    local daly `r(p4)'
    ** Improve and worsen
    local improve `r(p7)'
    local worsen `r(p12)'

    ** generate a local for the ColorBrewer color scheme
    colorpalette d3 20 , n(20) nograph
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

** generate a local for the ColorBrewer color scheme
colorpalette d3 20 , n(20)  nograph
local list r(p) 
local blu1 `r(p1)'
local blu2 `r(p2)'
local gry1 `r(p15)'
local gry2 `r(p16)'

** generate a local for the ColorBrewer color scheme
colorpalette ptol rainbow , n(10)  nograph
local list r(p) 
** c1 - c11
forval x = 1(1)10 {
    local a`x' `r(p`x')'
}

** -----------------------------------------------------
** GRAPHIC
** -----------------------------------------------------
** GENDER DALY ratio - 2021
** -----------------------------------------------------

** Create graphics order 
** By COD then by subregion according to SIZE OF gender-ratio
keep if cod<=5 
gsort cod -drat2021
gen yorder = _n

decode cod, gen(codname)
labmask yorder, val(codname)
order cod yorder 

** Integer absolute change in Gender Ratio
gen i2021 = round(drat2021, 0.1) 

** Gaps between cause of death groups
gen yorder2 = yorder 
replace yorder2 = yorder + 2 if cod>1
replace yorder2 = yorder + 4 if cod>2
replace yorder2 = yorder + 6 if cod>3
replace yorder2 = yorder + 8 if cod>4
replace yorder2 = yorder + 10 if cod>5


#delimit ;
label define yorder_ 

    1   "Brazil"
    2   "Andean"
    3   "Mexico"
    4   "Americas"
    5   "Southern Cone"
    6   "non Latin Caribbean"
    7   "Latin Caribbean"
    8   "North America"
    9   "Central America"

    12  "Brazil"
    13  "Mexico"
    14  "Central America"
    15  "Andean"
    16  "non Latin Caribbean"
    17  "Southern Cone"
    18  "Americas"
    19  "Latin Caribbean"
    20  "North America"

    23  "Mexico"
    24  "Andean"
    25  "North America"
    26  "Americas"
    27  "non Latin Caribbean"
    28  "Central America"
    29  "Latin Caribbean"
    30  "Southern Cone"
    31  "Brazil"

    34  "non Latin Caribbean"
    35  "Brazil"
    36  "Central America"
    37  "Andean"
    38  "Mexico"
    39  "Latin Caribbean"
    40  "Americas"
    41  "Southern Cone"
    42  "North America"

    45  "Central America"
    46  "Mexico"
    47  "non Latin Caribbean"
    48  "Brazil"
    49  "Southern Cone"
    50  "Andean"
    51  "Americas"
    52  "Latin Caribbean"
    53  "North America"         
    , modify;
 #delimit cr

** Has GR gone up or down between 2000 and 2019?
gen change = 1 if drat2021 > drat2000
replace change = 2 if drat2021 < drat2000
replace change = 3 if drat2021 == drat2000
label define change_ 1 "up" 2 "down" 3 "same"
label values change change_ 
order change, after(drat2021)

** Shifted origin for visual clarity
gen origin2000_up = 1.05
gen origin2021_up = 1.05
gen origin2000_dn = 0.95
gen origin2021_dn = 0.95

gen yorder2021 = yorder2 
label values yorder2021 yorder_ 

local line1 1 0.5   9 0.5
local line2 12 0.5  20 0.5
local line3 23 0.5  31 0.5
local line4 34 0.5  42 0.5
local line5 45 0.5  53 0.5

local box1  0  5  -1.5 5  -1.5 10    0 10   0 5   
local box2 11  5   9.5 5   9.5 10   11 10  11 5   

gen xlocation = -0.15
gen drat2021i = drat2021 
order drat2021, after(cod)

** 2021 only
#delimit ;  
	gr twoway 
        /// Subregions by injury group
        (rbar origin2021_up drat2021 yorder2021 if cod==1 & region!=44 , horizontal barw(0.5) fcol("`a1'%50") lcol("`a1'%75") lw(0.1))   
        (rbar origin2021_up drat2021 yorder2021 if cod==2 & region!=44 , horizontal barw(0.5) fcol("`a2'%50") lcol("`a2'%75") lw(0.1))   
        (rbar origin2021_up drat2021 yorder2021 if cod==3 & region!=44 , horizontal barw(0.5) fcol("`a3'%50") lcol("`a3'%75") lw(0.1))   
        (rbar origin2021_up drat2021 yorder2021 if cod==4 & region!=44 , horizontal barw(0.5) fcol("`a4'%50") lcol("`a4'%75") lw(0.1))   
        (rbar origin2021_up drat2021 yorder2021 if cod==5 & region!=44 , horizontal barw(0.5) fcol("`a5'%50") lcol("`a5'%75") lw(0.1))   
        /// Region by injury subgroup
        (rbar origin2021_up drat2021 yorder2021 if cod==1 & region==44 , horizontal barw(0.5) fcol("`a1'%95") lcol("`a1'%100") lw(0.1))   
        (rbar origin2021_up drat2021 yorder2021 if cod==2 & region==44 , horizontal barw(0.5) fcol("`a2'%95") lcol("`a2'%100") lw(0.1))   
        (rbar origin2021_up drat2021 yorder2021 if cod==3 & region==44 , horizontal barw(0.5) fcol("`a3'%95") lcol("`a3'%100") lw(0.1))   
        (rbar origin2021_up drat2021 yorder2021 if cod==4 & region==44 , horizontal barw(0.5) fcol("`a4'%95") lcol("`a4'%100") lw(0.1))   
        (rbar origin2021_up drat2021 yorder2021 if cod==5 & region==44 , horizontal barw(0.5) fcol("`a5'%95") lcol("`a5'%100") lw(0.1))   


        (scatteri `line1' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("l") )
        (scatteri `line2' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("l") )
        (scatteri `line3' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("l") )
        (scatteri `line4' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("l") )
        (scatteri `line5' , recast(line) lw(0.2) lc("gs8") fc("gs8") lp("l") )

        ///(scatteri `box1'  , recast(area) lw(0.1) lc("`a1'%50") fc("`a1'%25") lp("l"))
        ///(scatteri `box2'  , recast(area) lw(0.1) lc("`a2'%50") fc("`a2'%25") lp("l"))

        /// The Gender Ratio values
        (sc yorder2021 xlocation, msymbol(i) mlabel(i2021) mlabsize(2.5) mlabcol(gs8) mlabp(0))
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(16) xsize(10)

			xlab(none, 
            notick labs(2.5) tlc(gs0) labc(gs8) notick nogrid glc(gs16))
			xscale(noline noextend range(0(1)3)) 
			xtitle("", size(2) color(gs0) margin(l=0 r=0 t=0 b=0)) 

			ylab(1(1)9 12(1)20 23(1)31 34(1)42 45(1)53, valuelabel
			labc(gs8) labs(2.2) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(1))
			yscale(reverse noline lw(vthin) range(-2(1)38)) 
			ytitle("", size(2) margin(l=0 r=0 t=0 b=0)) 

            text(-0.8 -0.2 "Gender" "Ratio"  , place(c) size(2.5) color("`gry1'") just(center) )
            text(-0.8 9.9 "Interpersonal violence"  , place(w) size(3) color("`a1'") just(right) )
            text(10 9.9 "Road injury"               , place(w) size(3) color("`a2'") just(right) )
            text(21 9.9 "Self harm"                 , place(w) size(3) color("`a3'") just(right) )
            text(32 9.9 "Falls"                     , place(w) size(3) color("`a4'") just(right) )
            text(43 9.9 "Drowning"                  , place(w) size(3) color("`a5'") just(right) )

            legend(off)
			name(gr_2021)
			;
			graph export "`outputpath'/figure3.png", replace width(4000);
#delimit cr	




** ------------------------------------------------------
** FIGURE 3: PDF
** ------------------------------------------------------
    putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.5cm) margin(left,0.5cm) margin(right,0.5cm)
** PAGE 1. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Figure 3 ") , bold
    putpdf text ("Gender inequality in disease burden in 2021 for 5 major causes of injury, among 8 subregions of the Americas. ")
    putpdf text ("Disease burden measured using DALY rate per 100,000. Gender ratio (DALY rate in men / DALY rate in women)")

** FIGURE OF DAILY COVID-19 COUNT
    putpdf table f2 = (1,1), width(75%) border(all,nil) halign(center)
    putpdf table f2(1,1)=image("`outputpath'/figure3.png")

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/Figure_3_`date_string'_color", replace
