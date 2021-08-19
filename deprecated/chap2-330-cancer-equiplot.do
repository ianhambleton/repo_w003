** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-330-cancer-equiplot.do
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
    log using "`logpath'\chap2-330-cancer-equiplot", replace
** HEADER -----------------------------------------------------

tempfile t1

** Mortality rate 
use "`datapath'\from-who\chap2_000_mr", clear
rename arate mortr
replace mortr = mortr * 100000
keep year sex ghecause region mortr 
save `t1', replace 

** DALY rate 
use "`datapath'\from-who\chap2_000_daly", clear
rename arate dalyr
replace dalyr = dalyr * 100000
keep year sex ghecause region dalyr 
merge 1:1 year sex ghecause region using `t1' 
drop _merge

** Restrict
keep if sex==3
keep if year==2019 
drop year sex 

**------------------------------------------------
** Create new GHE CoD order 
** CANCERS TO USE
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
** 500  "all cancers"
** 100  "all cause", modif    
** -----------------------------------------------
gen     cod = 1 if ghecause==12 
replace cod = 2 if ghecause==14
replace cod = 3 if ghecause==18
replace cod = 4 if ghecause==9
replace cod = 5 if ghecause==15
replace cod = 6 if ghecause==11
replace cod = 7 if ghecause==27
replace cod = 8 if ghecause==8
replace cod = 9 if ghecause==10
replace cod = 10 if ghecause==28
replace cod = 11 if ghecause==500
#delimit ; 
label define cod_   1 "trachea/lung" 
                    2 "breast" 
                    3 "prostate" 
                    4 "colon/rectum" 
                    5 "cervix uteri" 
                    6 "pancreas"
                    7 "lymphomas/myeloma"
                    8 "stomach"
                    9 "liver"
                    10 "leukemia"
                    11 "all cancers", modify ;
#delimit cr
label values cod cod_ 
sort cod 
drop ghecause 
order cod region mortr dalyr 
keep if cod<=11

** Restrict region to countries + Americas 
keep if region < 100 | region==2000

** Small rates are good
** New variable containing minimum rate for region, by CoD
** Except that (eg rheumatic disease - the minimum rate is 0) 
bysort cod : egen mr_mean = mean(mortr)
bysort cod : egen mr_sd = sd(mortr)
gen mort1 = (mortr - mr_mean) / mr_sd
gen mort2 = (mortr - mr_mean)
sort cod mort1
/*
bysort cod : egen mr_min = min(mort1)
gen mr_rel1 = mortr/mr_min
gen mr_rel2 = mort1/mr_min
drop mr_mean mr_sd mr_rel1 mr_min

** --------------------------------------------------------
** GRAPHIC
** --------------------------------------------------------

** COLORS - PURPLES for CVD
    colorpalette hcl, blues nograph n(14)
    local list r(p) 
    ** Age groups
    local child `r(p2)'    
    local youth `r(p5)'    
    local young `r(p8)'    
    local older `r(p11)'    
    local elderly `r(p14)'   

** Median (IQR) mortality rate in each CoD group
forval x = 1(1)6 {
    sum mr_rel2 if cod==`x', detail 
    local p50_`x' = r(p50)
    local p25_`x' = r(p25)
    local p75_`x' = r(p75)
    local max_`x' = r(max)
}

** 25th to 75th percentile boxes 
** by CoD
local iqr1 `p25_1' 0.5 `p75_1' 0.5 `p75_1' 1.5 `p25_1' 1.5  `p25_1' 0.5 
local iqr2 `p25_2' 1.5 `p75_2' 1.5 `p75_2' 2.5 `p25_2' 2.5  `p25_2' 1.5 
local iqr3 `p25_3' 2.5 `p75_3' 2.5 `p75_3' 3.5 `p25_3' 3.5  `p25_3' 2.5 
local iqr4 `p25_4' 3.5 `p75_4' 3.5 `p75_4' 4.5 `p25_4' 4.5  `p25_4' 3.5 
local iqr5 `p25_5' 4.5 `p75_5' 4.5 `p75_5' 5.5 `p25_5' 5.5  `p25_5' 4.5 
local iqr6 `p25_6' 5.5 `p75_6' 5.5 `p75_6' 6.5 `p25_6' 6.5  `p25_6' 5.5 

** Outer boxes
local outer1   1.75 0.5   -4.75 0.5   -4.75 1.5   1.75 1.5   1.75 0.5 
local outer2a  1.75 1.5    1.75 2.5  
local outer2b  1.75 2.5   -4.75 2.5  
local outer2c -4.75 1.5   -4.75 2.5 
local outer3a  1.75 2.5    1.75 3.5  
local outer3b  1.75 3.5   -4.75 3.5  
local outer3c -4.75 2.5   -4.75 3.5 
local outer4a  1.75 3.5    1.75 4.5  
local outer4b  1.75 4.5   -4.75 4.5  
local outer4c -4.75 3.5   -4.75 4.5 
local outer5a  1.75 4.5    1.75 5.5  
local outer5b  1.75 5.5   -4.75 5.5  
local outer5c -4.75 4.5   -4.75 5.5 
local outer6a  1.75 5.5    1.75 6.5  
local outer6b  1.75 6.5   -4.75 6.5  
local outer6c -4.75 5.5   -4.75 6.5 

** ---------------------------------------------------
** Statistics for the text to accompany this graphic
** Simple relative measure of inequality : Rate (R)
** Simple absolute measure of inequality : Difference (D)
** Simple absolute measure of inequality : Mean Absolute Deviation (MAD) 
** Simple relative measure of inequality : Index of Disparity (ID) 
** ---------------------------------------------------
drop dalyr 
sort cod mr_rel2

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

** (MAD) Complex - absolute
    ** Mean Absolute deviation
    * --> number of countries in group 
    * bysort cod : gen J = _N - 1
    * --> MD using best rate in group (best = lowest)
    * bysort cod : egen rref = min(mortr)
    * gen rdiff = abs(rref - mortr)
    * bysort cod : egen abs_com = sum(rdiff/J)

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

** ID to global macros
forval x = 1(1)6 {
    preserve
        keep if cod==`x' & touse==1
        local id`x' : dis %5.0f id
    restore
}

/// †  	U+2020 (alt-08224)	DAGGER = obelisk, obelus, long cross
/// ‡  	U+2021 (alt-08225)	DOUBLE DAGGER = diesis, double obelisk
/// •  	U+2022 (alt-08226)	BULLET = black small circle
local dagger = uchar(8224)
local ddagger = uchar(8225)

keep if cod<=5 | cod==11
recode cod 11=6

#delimit ;
	gr twoway 
        /// 25th to 75th percentiles
        (scatteri `iqr1' if cod==1, recast(area) color("`child'*0.4")  )
        (scatteri `iqr2' if cod==2, recast(area) color("`child'*0.4")  )
        (scatteri `iqr3' if cod==3, recast(area) color("`child'*0.4")  )
        (scatteri `iqr4' if cod==4, recast(area) color("`child'*0.4")  )
        (scatteri `iqr5' if cod==5, recast(area) color("`child'*0.4")  )
        (scatteri `iqr6' if cod==6, recast(area) color("`child'*0.4")  )
        (pcarrowi -1.1 0.2 -2.1 0.2 , color("`child'*0.4") lw(0.5) msize(4) mangle(30) barbsize(3) mlw(2))

		/// median values
        (function y=`p50_1' if cod==1, range(0.5 1.5) lc(gs5))
        (function y=`p50_2' if cod==2, range(1.5 2.5) lc(gs5))
        (function y=`p50_3' if cod==3, range(2.5 3.5) lc(gs5))
        (function y=`p50_4' if cod==4, range(3.5 4.5) lc(gs5))
        (function y=`p50_5' if cod==5, range(4.5 5.5) lc(gs5))
        (function y=`p50_6' if cod==6, range(5.5 6.5) lc(gs5))

		/// outer boxes 
        (scatteri `outer1'  , recast(area) lw(0.2) lc(gs10) fc(none)  )
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
        (sc mr_rel2 cod if cod==1 & region<2000 , msize(7) m(oh) mlc("`child'*0.5") mlw(0.2))
        (sc mr_rel2 cod if cod==1 & mr_rel2==1, msize(7) m(o) mlc("`child'") mfc("`child'") mlw(0.2))
        ///(sc mr_rel2 cod if cod==1 & region==2000, msize(7) m(o) mlc(gs0*0.5) mfc(gs0*0.5) mlw(0.2))

		(sc mr_rel2 cod if cod==2 & region<2000 , msize(7) m(oh) mlc("`child'*0.5") mlw(0.2))
        (sc mr_rel2 cod if cod==2 & mr_rel2==1, msize(7) m(o) mlc("`child'") mfc("`child'") mlw(0.2))
        ///(sc mr_rel2 cod if cod==2 & region==2000, msize(7) m(o) mlc(gs0*0.5) mfc(gs0*0.5) mlw(0.2))

		(sc mr_rel2 cod if cod==3 & region<2000 , msize(7) m(oh) mlc("`child'*0.5") mlw(0.2))
        (sc mr_rel2 cod if cod==3 & mr_rel2==1, msize(7) m(o) mlc("`child'") mfc("`child'") mlw(0.2))
        ///(sc mr_rel2 cod if cod==3 & region==2000, msize(7) m(o) mlc(gs0*0.5) mfc(gs0*0.5) mlw(0.2))
        
		(sc mr_rel2 cod if cod==4 & region<2000 , msize(7) m(oh) mlc("`child'*0.5") mlw(0.2))
        (sc mr_rel2 cod if cod==4 & mr_rel2==1, msize(7) m(o) mlc("`child'") mfc("`child'") mlw(0.2))
        ///(sc mr_rel2 cod if cod==4 & region==2000, msize(7) m(o) mlc(gs0*0.5) mfc(gs0*0.5) mlw(0.2))        
        
		(sc mr_rel2 cod if cod==5 & region<2000 , msize(7) m(oh) mlc("`child'*0.5") mlw(0.2))
        (sc mr_rel2 cod if cod==5 & mr_rel2==1, msize(7) m(o) mlc("`child'") mfc("`child'") mlw(0.2))
        ///(sc mr_rel2 cod if cod==4 & region==2000, msize(7) m(o) mlc(gs0*0.5) mfc(gs0*0.5) mlw(0.2))  
        
		(sc mr_rel2 cod if cod==6 & region<2000 , msize(7) m(oh) mlc("`child'*0.5") mlw(0.2))
        (sc mr_rel2 cod if cod==6 & mr_rel2==1, msize(7) m(o) mlc("`child'") mfc("`child'") mlw(0.2))
        ///(sc mr_rel2 cod if cod==6 & region==2000, msize(7) m(o) mlc(gs0*0.5) mfc(gs0*0.5) mlw(0.2))        
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(8) xsize(15)

			xlab(none , notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline ) 
			xtitle("", size(5) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(none,
			valuelabel labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(rev noline lw(vthin) range(0.5(0.1)-5.25)) 
			ytitle("", size(5) margin(l=2 r=5 t=2 b=2)) 

            /// Region Titles 
           /// text(-5 1 "Ischemic" "Heart Disease"         ,  place(c) size(3) color(gs8) just(center))
           /// text(-5 2 "Stroke"                           ,  place(c) size(3) color(gs8) just(center))
           /// text(-5 3 "Hypertensive" "Heart Diseases"    ,  place(c) size(3) color(gs8) just(center))
           /// text(-5 4 "Cardiomyopathy" "etc"             ,  place(c) size(3) color(gs8) just(center))
           /// text(-5 5 "Rheumatic" "Heart Disease"        ,  place(c) size(3) color(gs8) just(center))
           /// text(-5 6 "All" "CVD"                        ,  place(c) size(3) color(gs8) just(center))

            /// LOWEST RATE countries
           /// text(1.45 1 "Chile"               ,  place(c) size(3.1) color("`child'") just(center))
           /// text(1.45 2 "Canada"              ,  place(c) size(3.1) color("`child'") just(center))
           /// text(1.45 3 "El Salvador"         ,  place(c) size(3.1) color("`child'") just(center))
           /// text(1.45 4 "El Salvador"         ,  place(c) size(3.1) color("`child'") just(center))
           /// text(1.45 5 "Multiple `dagger'"            ,  place(c) size(3.1) color("`child'") just(center))
           /// text(1.45 6 "Peru"                ,  place(c) size(3.1) color("`child'") just(center))

            /// HIGHEST RATE countries
           /// IHD
           /// text(-3.55 1 "Guyana"                ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// text(-3.25 1 "Haiti"                 ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// text(-2.95 1 "Dominican Rep"         ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// STROKE
           /// text(-3.55 2 "Haiti"                 ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// text(-3.25 2 "Guyana"                ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// text(-2.95 2 "Suriname"              ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// HHD
           /// text(-3.55 3 "Bahamas"               ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// text(-3.25 3 "Guyana"                ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// text(-2.95 3 "Haiti"                 ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// CARDIOMYOPATHY
          /// text(-3.55 4 "Guyana"                ,  place(c) size(3.1) color("`child'*0.5") just(center))
          /// text(-3.25 4 "Haiti"                 ,  place(c) size(3.1) color("`child'*0.5") just(center))
          /// text(-2.95 4 "Bahamas"               ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// RHEUMATIC
           /// text(-3.375 5.25 "Haiti"                 ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// text(-2.75 5 "Bolivia"               ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// text(-2.45 5 "St Vincent"            ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// CVD
           /// text(-3.55 6 "Haiti"                 ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// text(-3.25 6 "Guyana"                ,  place(c) size(3.1) color("`child'*0.5") just(center))
           /// text(-2.95 6 "Suriname"              ,  place(c) size(3.1) color("`child'*0.5") just(center))

            /// INDEX OF DISPARITY VALUES
           text(-4.4 0.3 "ID{superscript:`ddagger'}" ,  place(c) size(7) color("`child'*0.5") just(center))
           text(-4.4 0.9 "`id1'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(-4.4 1.9 "`id2'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(-4.4 2.9 "`id3'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(-4.4 3.9 "`id4'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(-4.4 4.9 "`id5'"                     ,  place(c) size(7) color("`child'*0.5") just(center))
           text(-4.4 5.9 "`id6'"                     ,  place(c) size(7) color("`child'*0.5") just(center))

           /// Arrow text 
           text(-0.75 0.2 "Higher" "Rate" ,  place(c) size(3.1) color("`child'*0.5") just(center))

            /// Note text 
           /// text(1.90 0.5 "`dagger' Five Caribbean countries with no cases of rheumatic heart disease in 2019: Antigua, Bahamas, Belize, Grenada, St Lucia." ,  
           ///                         place(e) size(2.5) color("`child'*0.75") just(left))
           text(1.90 0.5 "`ddagger' ID = Index of Disparity." ,  
                                    place(e) size(2.5) color("`child'*0.75")  just(left))

			legend(off)
			name(eq1)
			;
#delimit cr	