** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-230-cvd-equiplot.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    CVD leading diseases: by-country equiplot

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
use "`datapath'\from-who\chap2_cvd_mr", clear
rename arate mortr
replace mortr = mortr * 100000
keep year sex ghecause region mortr 
save `t1', replace 

** DALY rate 
use "`datapath'\from-who\chap2_cvd_daly", clear
rename arate dalyr
replace dalyr = dalyr * 100000
keep year sex ghecause region dalyr 
merge 1:1 year sex ghecause region using `t1' 
drop _merge

** Restrict and reshape
keep if sex==3
keep if year==2000 | year==2019 
drop if ghecause==1160 
keep if region==2000
drop sex region
reshape wide mortr dalyr , i(ghecause) j(year) 
order ghecause mortr* dalyr* 

gen mort_rat2000 = mortr2000/mortr2000
gen mort_rat2019 = mortr2019/mortr2000

gen daly_rat2000 = dalyr2000/dalyr2000
gen daly_rat2019 = dalyr2019/dalyr2000
replace daly_rat2000 = daly_rat2000 + 2.5
replace daly_rat2019 = daly_rat2019 + 2.5

** GHE CAUSE running from 1
gen cod = 1 if ghecause==1130 
replace cod = 2 if ghecause==1140
replace cod = 3 if ghecause==1120
replace cod = 4 if ghecause==1150
replace cod = 5 if ghecause==1110
replace cod = 6 if ghecause==1100
#delimit ; 
label define cod_   1 "ischaemic" 
                    2 "stroke" 
                    3 "hypertensive" 
                    4 "cardiomyopathy etc" 
                    5 "rheumatic" 
                    6 "all cvd", modify ;
#delimit cr
label values cod cod_ 
drop ghecause 
order cod mortr* dalyr* mort_* daly_*

** --------------------------------------------------------
** GRAPHIC
** --------------------------------------------------------

** COLORS - PURPLES for CVD
    colorpalette hcl, purples  nograph
    local list r(p) 
    ** Age groups
    local point1 `r(p2)'    
    local point2 `r(p5)'    
    local line1 `r(p8)'    
    local line2 `r(p11)'    
    local line3 `r(p14)'   

** Outer boxes
local outer1   0.5 0   6.5 0   6.5 2.2   0.5 2.2   0.5 0 
local outer2a  0.5 2.2       0.5 4.7  
local outer2b  0.5 4.7       6.5 4.7  
local outer2c  6.5 2.2       6.5 4.7 

** Shift points to left (fall) or to right (increase)
gen mort_point = mort_rat2019 - 0.075 if mort_rat2019 <= mort_rat2000
replace mort_point = mort_rat2019 + 0.075 if mort_rat2019 > mort_rat2000
gen daly_point = daly_rat2019 - 0.075 if daly_rat2019 <= daly_rat2000
replace daly_point = daly_rat2019 + 0.075 if daly_rat2019 > daly_rat2000
#delimit ;
	gr twoway 
        /// Vertical lines
        ///(function y=0.1, horizontal range(1 6) lc("gs8%25") lp("l") lw(0.5))
        (function y=1, horizontal range(1 6) lc("gs8%25") lp("-") lw(0.5))
        (function y=3.5, horizontal range(1 6) lc("gs8%25") lp("-") lw(0.5))

		/// outer boxes 
        (scatteri `outer1'  , recast(area) lw(0.2) lc(gs10) fc(none)  )
        (scatteri `outer2a' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer2b' , recast(line) lw(0.2) lc(gs10) fc(none) )
        (scatteri `outer2c' , recast(line) lw(0.2) lc(gs10) fc(none) )

        /// Arrows
        (pcarrow cod mort_rat2000 cod mort_rat2019 , color("`line1'*0.4") lw(0.5) msize(4) mangle(30) barbsize(3) mlw(2))
        (pcarrow cod daly_rat2000 cod daly_rat2019 , color("`line1'*0.4") lw(0.5) msize(4) mangle(30) barbsize(3) mlw(2))
         
		/// Points
        (sc cod mort_rat2000 , msize(5) m(o) mlc("`point1'*0.75") mfc("`point1'*0.75") mlw(0.2))
        (sc cod   mort_point , msize(7) m(o) mlc("`point2'%25") mfc("`point1'%25") mlw(0.2))
        (sc cod daly_rat2000 , msize(5) m(o) mlc("`point1'*0.75") mfc("`point1'*0.75") mlw(0.2))
        (sc cod   daly_point , msize(7) m(o) mlc("`point2'%25") mfc("`point1'%25") mlw(0.2))

        ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(8) xsize(15)

			xlab(0.5 "half" 1 2 "double" 3 "half" 3.5 "1" 4.5 "double" , notick labs(4) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline  range(-0.75(0.1)4.75)) 
			xtitle("", size(5) color(gs0) margin(l=2 r=2 t=5 b=2))

			
			ylab(none,
			labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline rev lw(vthin) range(0.5(1)6.5)) 
			ytitle("", size(5) margin(l=2 r=5 t=2 b=2)) 

            /// Region Titles 
            text(1 -0.1 "Ischemic" "Heart Disease"         ,  place(w) size(4) color(gs8) just(right))
            text(2 -0.1 "Stroke"                           ,  place(w) size(4) color(gs8) just(right))
            text(3 -0.1 "Hypertensive" "Heart Diseases"    ,  place(w) size(4) color(gs8) just(right))
            text(4 -0.1 "Cardiomyopathy" "etc"             ,  place(w) size(4) color(gs8) just(right))
            text(5 -0.1 "Rheumatic" "Heart Disease"        ,  place(w) size(4) color(gs8) just(right))
            text(6 -0.1 "All" "CVD"                        ,  place(w) size(4) color(gs8) just(right))


			legend(off)
			name(eq1)
			;
#delimit cr	
