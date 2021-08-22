** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-540-diabetes-bar.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	19-August-2021
    //  algorithm task			    Leading causes of diabetes death: by-country bar chart

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
    log using "`logpath'\chap2-540-diabetes-bar", replace
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
** Create new GHE CoD order 
** 31 - Diabetes
** -----------------------------------------------
gen     cod = 1 if ghecause==31 
#delimit ; 
label define cod_   1 "diabetes" , modify ;
#delimit cr
label values cod cod_ 
sort cod 
drop ghecause 
order cod region mortr dalyr 
keep if cod<=1

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
    preserve
        keep if cod==1 & touse==1
        local id1 : dis %5.0f id
    restore

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
    colorpalette #6c6c13 #adad1f #dddd3c #e8e87d #f4f4be
    local list r(p) 
    ** Age groups
    local child `r(p1)'    
    local youth `r(p2)'    
    local young `r(p3)'    
    local older `r(p4)'    
    local elderly `r(p5)'   

** COLORS - REDS
    colorpalette hcl, reds nograph n(14)
    local list r(p) 
    ** Age groups
    local americas1 `r(p2)'    
    local americas2 `r(p5)'    
    local americas3 `r(p8)'    
    local americas4 `r(p11)'    
    local americas5 `r(p14)' 

** Outer boxes (CANCER CAUSES 1-6)
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

** Outer boxes (CANCER CAUSES 7-11)
local touter1   52 -10   9 -10   9 110   52 110   52 -10 

local touter2a  52 110   52 230  
local touter2b  52 230   9 230  
local touter2c  9 110   9 230 



** Countries ordered by size for COD (1-3)
gsort cod mortr
decode region , gen(region_lab)
bysort cod : gen regiono = _n
    gen region1 = regiono if cod==1
    labmask region1 if cod==1, values(region_lab)

** Scale all rates to 100 - keeps shape of all bar charts, and allows us to more easily create a panel of 6 charts
bysort cod : egen maxr = max(mortr)
gen scaler = (mortr/maxr) * 100
order maxr scaler , after(mortr) 
    gen scaler1 = scaler if cod==1
gen origin1 = 0


** COUNTRIES with High and Low Mortality Rates
preserve
    sort cod mortr
    bysort cod: gen include = _n
    mark keepme if include<=3 | include>=32
    keep if keepme==1
    bysort cod : gen regiono2 = _n
    order include regiono2, after(mortr)
    ** Diabetes
    forval x = 1(1)6 {
        local cid1_`x' = region_lab[`x'] 
    }
restore

#delimit ;
	gr twoway 
		/// outer boxes 
        (scatteri `outer1'  , recast(area) lw(0.2) lc(gs10) fc(none) )
        ///(scatteri `outer2a' , recast(line) lw(0.2) lc(gs10) fc(none) )
        ///(scatteri `outer2b' , recast(line) lw(0.2) lc(gs10) fc(none) )
        ///(scatteri `outer2c' , recast(line) lw(0.2) lc(gs10) fc(none) )
        ///(scatteri `outer3a' , recast(line) lw(0.2) lc(gs10) fc(none) )
        ///(scatteri `outer3b' , recast(line) lw(0.2) lc(gs10) fc(none) )
        ///(scatteri `outer3c' , recast(line) lw(0.2) lc(gs10) fc(none) )

		/// country values
        (rbar origin1 scaler1 region1 if cod==1 & region!=2000, horizontal barw(0.6) fcol("`youth'") lcol("`child'") lw(0.1))                   

        (rbar origin1 scaler1 region1 if cod==1 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))              
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(15) xsize(11)

			xlab(none, notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline ) 
			xtitle("", size(5) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(none,
			labc(gs0) labs(3) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) range(-20(1)55)) 
			ytitle("", size(5) margin(l=2 r=5 t=2 b=2)) 

           /// Region Titles 
           text(56 50 "Diabetes"       ,  place(c) size(6) color(gs8) just(center))

            /// INDEX OF DISPARITY VALUES
           /// text(-4.4 0.3 "ID{superscript:`ddagger'}" ,  place(c) size(7) color("`child'*0.5") just(center))
           text(14 60 "Index"                     ,  place(c) size(6) color("`child'*0.75") just(center))
           text(10 60 "`id1'"                     ,  place(c) size(9) color("`child'*0.5") just(center))

           /// Y-Axis text 
           text(-18 40 "Mortality rate (per 100,000)" ,  
                                    place(c) size(5) color(gs8) just(center))

           /// High Rate Countries
           /// COPD
           text(48 0 "Highest Rates:",  place(e) size(5) color("`child'*0.80") just(right))
           text(45 105 "`cid1_6'",  place(w) size(4.5) color("`child'*0.5") just(right))
           text(42 105 "`cid1_5'",  place(w) size(4.5) color("`child'*0.5") just(right))
           text(39 105 "`cid1_4'",  place(w) size(4.5) color("`child'*0.5") just(right))
           text(-3 0 "Lowest Rates:",  place(e) size(5) color("`child'*0.80") just(right))
           text(-6 105 "`cid1_3'",  place(w) size(4.5) color("`child'*0.5") just(right))
           text(-9 105 "`cid1_2'",  place(w) size(4.5) color("`child'*0.5") just(right))
           text(-12 105 "`cid1_1'",  place(w) size(4.5) color("`child'*0.5") just(right))
 
           /// NOTE
           text(-22 0 "`ddagger' RED BAR, mortality rate for the Region of the Americas." ,  
                                    place(e) size(3.5) color(gs8)  just(left))
			legend(off)
			name(bar1)
			;
#delimit cr	

