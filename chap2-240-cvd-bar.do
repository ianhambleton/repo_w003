** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-230-cvd-equiplot.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	19-August-2021
    //  algorithm task			    Leading causes of cancer death: by-country equiplot

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
    log using "`logpath'\chap2-230-cvd-equiplot", replace
** HEADER -----------------------------------------------------

tempfile t1

** Mortality rate 
use "`datapath'\from-who\chap2_000_mr_adjusted", clear
keep year sex ghecause region mortr 
save `t1', replace 

** DALY rate 
use "`datapath'\from-who\chap2_000_daly_adjusted", clear
keep year sex ghecause region dalyr 
merge 1:1 year sex ghecause region using `t1' 
drop _merge

** Restrict
keep if sex==3
keep if year==2019 
drop year sex 


**------------------------------------------------
** Create new GHE CoD order for Table 
** CODES
**    1  "Rheumatic heart disease"
**    2  "Hypertensive heart disease"
**    3  "Ischaemic heart disease"
**    4  "Stroke"
**    5  "Cardiomyopathy etc"
**    400  ALL CVD
**    100  ALL DEATHS
**------------------------------------------------
gen     cod = 1 if ghecause==3 
replace cod = 2 if ghecause==4
replace cod = 3 if ghecause==2
replace cod = 4 if ghecause==5
replace cod = 5 if ghecause==1
replace cod = 6 if ghecause==400
keep if cod<=6 
#delimit ; 
label define cod_   1 "ischaemic" 
                    2 "stroke" 
                    3 "hypertensive" 
                    4 "cardiomyopathy etc" 
                    5 "rheumatic" 
                    6 "all cvd", modify ;
#delimit cr
label values cod cod_ 
sort cod 
drop ghecause 
order cod region mortr dalyr 

** Restrict region to countries + Americas 
keep if region < 100 | region==2000


** ---------------------------------------------------
** Statistics for the text to accompany this graphic
** Simple relative measure of inequality : Rate (R)
** Simple absolute measure of inequality : Difference (D)
** Simple relative measure of inequality : Index of Disparity (ID) 
** ---------------------------------------------------
drop dalyr 

** BASED ON ADJUSTED MORTALITY RATE 
** (R) Simple - relative
    bysort cod : egen m_min = min(mortr)
    bysort cod : egen m_max = max(mortr)
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
    gen americas1 = mortr if region==2000
    bysort cod : egen mort_am = min(americas1) 
    drop americas1 
    order mort_am, after(mortr)
    gen id1 = abs(mortr - mort_am)
    bysort cod : egen id2 = sum(id1) 
    gen id3 = id2 / mort_am
    gen id = (1/J) * id3 * 100
    drop mort_am id1 id2 id3 J
    order abs_sim rel_sim id , after(mortr)

    bysort cod: gen touse = 1 if _n==1 
    tabdisp cod, c(abs_sim rel_sim) format(%9.1f)
    tabdisp cod, c(id) format(%9.1f)

** ID to local macros
forval x = 1(1)6 {
    preserve
        keep if cod==`x' & touse==1
        local id`x' : dis %5.0f id
    restore
}

** Unicode markers for graphic
/// †  	U+2020 (alt-08224)	DAGGER = obelisk, obelus, long cross
/// ‡  	U+2021 (alt-08225)	DOUBLE DAGGER = diesis, double obelisk
/// •  	U+2022 (alt-08226)	BULLET = black small circle
local dagger = uchar(8224)
local ddagger = uchar(8225)


** --------------------------------------------------------
** GRAPHIC
** --------------------------------------------------------

** COLORS - PURPLES for CVD
    colorpalette hcl, purples nograph n(14)
    local list r(p) 
    ** Age groups
    local child `r(p2)'    
    local youth `r(p5)'    
    local young `r(p8)'    
    local older `r(p11)'    
    local elderly `r(p14)'   

** COLORS - REDS
    colorpalette hcl, reds nograph n(14)
    local list r(p) 
    ** Age groups
    local americas1 `r(p2)'    
    local americas2 `r(p5)'    
    local americas3 `r(p8)'    
    local americas4 `r(p11)'    
    local americas5 `r(p14)' 

** Outer boxes
local outer1   52 -10   -15 -10   -15 110   52 110   52 -10 

local outer2a  52 110   52 230  
local outer2b  52 230   -15 230  
local outer2c  -15 110   -15 230 

local outer3a  52 230    52 350  
local outer3b  52 350   -15 350 
local outer3c -15 230   -15 350 

local outer4a  52 350    52 470  
local outer4b  52 470   -15 470  
local outer4c -15 350   -15 470 

local outer5a  52 470    52 590  
local outer5b  52 590   -15 590  
local outer5c -15 470   -15 590

local outer6a  52 590    52 710  
local outer6b  52 710   -15 710  
local outer6c -15 590   -15 710 

** Countries ordered by size for COD (1-6)
gsort cod mortr
decode region , gen(region_lab)
bysort cod : gen regiono = _n
forval x = 1(1)6 {
    gen region`x' = regiono if cod==`x'
    labmask region`x' if cod==`x', values(region_lab)
}

** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
bysort cod : egen maxr = max(mortr)
gen scaler = (mortr/maxr) * 100
order maxr scaler , after(mortr) 
forval x = 1(1)6 {
    gen scaler`x' = scaler if cod==`x'
}
gen origin1 = 0
gen origin2 = 120 
replace scaler2 = scaler2 + 120
gen origin3 = 240
replace scaler3 = scaler3 + 240
gen origin4 = 360 
replace scaler4 = scaler4 + 360
gen origin5 = 480 
replace scaler5 = scaler5 + 480
gen origin6 = 600 
replace scaler6 = scaler6 + 600

** St Vincent and the Grenadines -- Too Long - Abbreviate
replace region_lab = "St.Vincent & Grenadines" if region_lab == "Saint Vincent and the Grenadines"

** COUNTRIES with 
** THREE highest and THREE lowest Mortality Rates
preserve
    sort cod mortr
    bysort cod: gen include = _n
    mark keepme if include<=3 | include>=32
    keep if keepme==1
    bysort cod : gen regiono2 = _n
    order include regiono2, after(mortr)
    ** Trachea/Lung
    forval x = 1(1)6 {
        local cid1_`x' = region_lab[`x'] 
    }
    ** Breast
    forval x = 7(1)12 {
        local cid2_`x' = region_lab[`x'] 
    }
    ** Prostate
    forval x = 13(1)18 {
        local cid3_`x' = region_lab[`x'] 
    }
    ** Colon / Rectum
    forval x = 19(1)24 {
        local cid4_`x' = region_lab[`x'] 
    }
    ** Cervix uteri
    forval x = 25(1)30 {
        local cid5_`x' = region_lab[`x'] 
    }
    ** ALL cancers
    forval x = 31(1)36 {
        local cid6_`x' = region_lab[`x'] 
    }
restore


#delimit ;
	gr twoway 
		/// outer boxes 
        (scatteri `outer1'  , recast(area) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer2a' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer2b' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer2c' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer3a' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer3b' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer3c' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer4a' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer4b' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer4c' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer5a' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer5b' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer5c' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer6a' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer6b' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer6c' , recast(line) lw(0.2) lc(gs10) fc(none) )

		/// country values
        (rbar origin1 scaler1 region1 if cod==1 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`child'") lw(0.1))       
        (rbar origin2 scaler2 region2 if cod==2 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`child'") lw(0.1))           
        (rbar origin3 scaler3 region3 if cod==3 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`child'") lw(0.1))           
        (rbar origin4 scaler4 region4 if cod==4 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`child'") lw(0.1))           
        (rbar origin5 scaler5 region5 if cod==5 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`child'") lw(0.1))           
        (rbar origin6 scaler6 region6 if cod==6 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`child'") lw(0.1))           

        (rbar origin1 scaler1 region1 if cod==1 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))       
        (rbar origin2 scaler2 region2 if cod==2 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (rbar origin3 scaler3 region3 if cod==3 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (rbar origin4 scaler4 region4 if cod==4 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (rbar origin5 scaler5 region5 if cod==5 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        (rbar origin6 scaler6 region6 if cod==6 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(9) xsize(18)

			xlab(none, notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline ) 
			xtitle("", size(5) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(none,
			labc(gs0) labs(3) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) range(-20(1)55)) 
			ytitle("", size(5) margin(l=2 r=5 t=2 b=2)) 

           /// Region Titles 
           text(56 50  "Ischemic" "Heart Disease"         ,  place(c) size(3) color(gs8) just(center))
           text(56 170 "Stroke"                           ,  place(c) size(3) color(gs8) just(center))
           text(56 290 "Hypertensive" "Heart Diseases"    ,  place(c) size(3) color(gs8) just(center))
           text(56 410 "Cardiomyopathy" "etc"             ,  place(c) size(3) color(gs8) just(center))
           text(56 530 "Rheumatic" "Heart Disease"        ,  place(c) size(3) color(gs8) just(center))
           text(56 650 "All" "CVD"                        ,  place(c) size(3) color(gs8) just(center))


            /// INDEX OF DISPARITY VALUES
           /// text(-4.4 0.3 "ID{superscript:`ddagger'}" ,  place(c) size(7) color("`child'*0.5") just(center))
           text(14 60 "Index"                     ,  place(c) size(4) color("`child'*0.75") just(center))
           text(10 60 "`id1'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           ///text(14 180 "Index"                     ,  place(c) size(4) color("`child'*0.75") just(center))
           text(10 180 "`id2'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           ///text(14 300 "Index"                     ,  place(c) size(4) color("`child'*0.75") just(center))
           text(10 300 "`id3'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           ///text(14 420 "Index"                     ,  place(c) size(4) color("`child'*0.75") just(center))
           text(10 420 "`id4'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           ///text(14 540 "Index"                     ,  place(c) size(4) color("`child'*0.75") just(center))
           text(10 540 "`id5'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(10.6 567 "`ddagger'"                     ,  place(c) size(4) color("`child'*0.5") just(center))
           ///text(14 670 "Index"                     ,  place(c) size(4) color("`child'*0.75") just(center))
           text(10 670 "`id6'"                     ,  place(c) size(7) color("`child'*0.5") just(center))

           /// Y-Axis text 
           text(-18 340 "Mortality rate (per 100,000)" ,  
                                    place(c) size(4) color(gs8) just(center))

           /// High Rate Countries
           /// Trachea / Lung
           text(48 0 "Highest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(45 105 "`cid1_6'",  place(w) size(3) color("`child'*0.5") just(right))
           text(42 105 "`cid1_5'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 105 "`cid1_4'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-3 0 "Lowest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(-6 105 "`cid1_3'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-9 105 "`cid1_2'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-12 105 "`cid1_1'",  place(w) size(3) color("`child'*0.5") just(right))

           /// /// Breast
           /// ///text(48 0 "Highest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(45 225 "`cid2_12'",  place(w) size(3) color("`child'*0.5") just(right))
           text(42 225 "`cid2_11'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 225 "`cid2_10'",  place(w) size(3) color("`child'*0.5") just(right))
           /// ///text(-3 0 "Lowest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(-6 225 "`cid2_9'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-9 225 "`cid2_8'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-12 225 "`cid2_7'",  place(w) size(3) color("`child'*0.5") just(right))
           
           /// Prostate
           /// ///text(48 0 "Highest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(45 345 "`cid3_18'",  place(w) size(3) color("`child'*0.5") just(right))
           text(42 345 "`cid3_17'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 345 "`cid3_16'",  place(w) size(3) color("`child'*0.5") just(right))
           /// ///text(-3 0 "Lowest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(-6 345 "`cid3_15'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-9 345 "`cid3_14'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-12 345 "`cid3_13'",  place(w) size(3) color("`child'*0.5") just(right))
 
           /// Colon / Rectum
           /// ///text(48 0 "Highest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(45 465 "`cid4_24'",  place(w) size(3) color("`child'*0.5") just(right))
           text(42 465 "`cid4_23'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 465 "`cid4_22'",  place(w) size(3) color("`child'*0.5") just(right))
           /// ///text(-3 0 "Lowest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(-6 465 "`cid4_21'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-9 465 "`cid4_20'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-12 465 "`cid4_19'",  place(w) size(3) color("`child'*0.5") just(right))
 
           /// Cervix Uteri
           /// ///text(48 0 "Highest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(45 585 "`cid5_30'",  place(w) size(3) color("`child'*0.5") just(right))
           text(42 585 "`cid5_29'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 585 "`cid5_28'",  place(w) size(3) color("`child'*0.5") just(right))
           /// ///text(-3 0 "Lowest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(-6 585 "`cid5_27'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-9 585 "`cid5_26'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-12 585 "`cid5_25'",  place(w) size(3) color("`child'*0.5") just(right))
 
           /// All cancers
           ///text(48 0 "Highest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(45 705 "`cid6_36'",  place(w) size(3) color("`child'*0.5") just(right))
           text(42 705 "`cid6_35'",  place(w) size(3) color("`child'*0.5") just(right))
           text(39 705 "`cid6_34'",  place(w) size(3) color("`child'*0.5") just(right))
           /// ///text(-3 0 "Lowest Rates:",  place(e) size(3.5) color("`child'*0.80") just(right))
           text(-6 705 "`cid6_33'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-9 705 "`cid6_32'",  place(w) size(3) color("`child'*0.5") just(right))
           text(-12 705 "`cid6_31'",  place(w) size(3) color("`child'*0.5") just(right))

           /// NOTE
           text(-24 0.5 "`ddagger' Five Caribbean countries had no cases of rheumatic heart disease in 2019: Antigua, Bahamas, Belize, Grenada, St Lucia." ,  
                                    place(e) size(2.5) color(gs4) just(left))           
           text(-21.5 0.5 "`dagger' BLACK BAR is the mortality rate for the Region of the Americas." ,  
                                    place(e) size(2.5) color(gs4)  just(left))


            legend(off)
			name(bar1)
			;
#delimit cr	
