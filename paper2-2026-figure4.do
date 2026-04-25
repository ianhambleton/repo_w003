** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-2026-figure4.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	9-Jul-2022
    //  algorithm task			    Figure 4. Regression graphic

    ** General algorithm set-up
    version 18
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DATASETS to encrypted SharePoint folder
    local datapath "C:\yoshimi-hot\output\analyse-write\w003\data\2025"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yoshimi-hot\output\analyse-write\w003\tech-docs\2025"

    ** REPORTS and Other outputs
    local outputpath "C:\yoshimi-hot\output\analyse-write\w003\outputs\2025"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\paper2-2026-figure4", replace
** HEADER -----------------------------------------------------

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
** All injuries (was 1000, now 4) 
replace cod = 6 if ghecause==4
** Unintentional injuries (was 1100, now 5) 
replace cod = 7 if ghecause==5
** All injuries (was 1200, now 6) 
replace cod = 8 if ghecause==6

decode ghecause, gen(codname)
labmask cod, val(codname)
keep if cod<. 
order cod, after(sex)
sort cod year sex region
drop ghecause

** Region and Year Restriction
** Americas + Subregions in 2021
keep if (region<=35 | region==44) & year==2021

** Reshape to wide
drop if sex==3
keep sex region cod paho* drate 
reshape wide drate , i(cod region) j(sex)

** Looking at actual log values to interpret charts 
    gen log1 = log(drate1)
    gen log2 = log(drate2)
    gen div = log1 / log2
    sort cod div


** generate a local for the ColorBrewer color scheme
colorpalette ptol rainbow , n(10)  nograph
local list r(p) 
** c1 - c11
forval x = 1(1)10 {
    local a`x' `r(p`x')'
}

** FOR ARTICLE - COLORBLIND FRIENDLY
** Paul Tol’s Bright Palette (12 colors)
colorpalette tol muted, nograph 
local list r(p) 
local a1 `r(p1)'
local a2 `r(p2)'
local a3 `r(p3)'
local a4 `r(p4)'
local a5 `r(p5)'
local a6 `r(p6)'
local a7 `r(p7)'
local a8 `r(p8)'
local a9 `r(p9)'
local a10 `gs5'

** GRAPHIC - IPV
local size = 5
local x= 1
#delimit ;
	gr twoway 
        (sc drate1 drate2                 if cod==`x' & paho_subregion==1, msize(`size') m(o) mlc("`a1'%90") mfc("`a1'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==2, msize(`size') m(o) mlc("`a2'%90") mfc("`a2'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==3, msize(`size') m(o) mlc("`a3'%90") mfc("`a3'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==4, msize(`size') m(o) mlc("`a4'%90") mfc("`a4'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==5, msize(`size') m(o) mlc("`a5'%90") mfc("`a5'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==6, msize(`size') m(o) mlc("`a6'%90") mfc("`a6'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==7, msize(`size') m(o) mlc("`a7'%90") mfc("`a7'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==8, msize(`size') m(o) mlc("`a8'%90") mfc("`a8'%90") mlw(0.1))

        (function y=x, range(2 10000) lc(gs2) lp("-"))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=3 t=5)) 
			ysize(10) xsize(15)

			xlab(10 100 1000 "1,000" 10000 "10,000", notick labs(`size') tlc(gs0) labc(gs16) notick nogrid glc(gs16))
			xscale(fill log lw(vthin)  lc(gs16) range(10(1000)15010)) 
			xtitle("Female rate", size(`size') color(gs16) margin(l=1 r=1 t=1 b=1)) 

			ylab(10 100 1000 "1,000" 10000 "10,000",
			valuelabel labc(gs2) labs(`size') tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(log lw(vthin)  lc(gs2)) 
			ytitle("Male rate", size(`size') color(gs2) margin(l=1 r=1 t=1 b=1)) 

			/// X-Axis text
            ///text(90 2.8 "Health Expenditure (% GDP)",  place(e) size(4.25) color(gs2))
            ///text(90 -1.1 "Doctors and nurses (per 10,000 pop)",  place(e) size(4.25) color(gs2))

			legend(off size(`size') position(6) ring(1) bc(gs2) color(gs2) bm(t=1 b=4 l=5 r=0) colf cols(4)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
			order(1 2 3 4 5 6 7 8) 
			lab(1 "North America") 
			lab(2 "Southern Cone")
            lab(3 "Central America")
            lab(4 "Andean")
            lab(5 "Latin Caribbean")
            lab(6 "non-Latin Caribbean")
            lab(7 "Brazil")
            lab(8 "Mexico")
			)
			name(figure4_`x');
			graph export "`outputpath'/figure4_`x'.png", replace width(4000);
			;
#delimit cr	


** GRAPHIC - Road Injury
local size = 5
local x= 2
#delimit ;
	gr twoway 
        (sc drate1 drate2                 if cod==`x' & paho_subregion==1, msize(`size') m(o) mlc("`a1'%90") mfc("`a1'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==2, msize(`size') m(o) mlc("`a2'%90") mfc("`a2'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==3, msize(`size') m(o) mlc("`a3'%90") mfc("`a3'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==4, msize(`size') m(o) mlc("`a4'%90") mfc("`a4'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==5, msize(`size') m(o) mlc("`a5'%90") mfc("`a5'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==6, msize(`size') m(o) mlc("`a6'%90") mfc("`a6'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==7, msize(`size') m(o) mlc("`a7'%90") mfc("`a7'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==8, msize(`size') m(o) mlc("`a8'%90") mfc("`a8'%90") mlw(0.1))

        (function y=x, range(2 10000) lc(gs2) lp("-"))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=3 t=5)) 
			ysize(10) xsize(15)

			xlab(10 100 1000 "1,000" 10000 "10,000", notick labs(`size') tlc(gs0) labc(gs16) notick nogrid glc(gs16))
			xscale(fill log lw(vthin) lc(gs16)  range(10(1000)15010)) 
			xtitle("Female rate", size(`size') color(gs16) margin(l=1 r=1 t=1 b=1)) 

			ylab(10 100 1000 "1,000" 10000 "10,000",
			valuelabel labc(gs16) labs(`size') tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(fill log lw(vthin) lc(gs16) ) 
			ytitle("Male rate", size(`size') color(gs16) margin(l=1 r=1 t=1 b=1)) 

			/// X-Axis text
            ///text(90 2.8 "Health Expenditure (% GDP)",  place(e) size(4.25) color(gs2))
            ///text(90 -1.1 "Doctors and nurses (per 10,000 pop)",  place(e) size(4.25) color(gs2))

			legend(off size(`size') position(6) ring(1) bc(gs2) color(gs2) bm(t=1 b=4 l=5 r=0) colf cols(4)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
			order(1 2 3 4 5 6 7 8) 
			lab(1 "North America") 
			lab(2 "Southern Cone")
            lab(3 "Central America")
            lab(4 "Andean")
            lab(5 "Latin Caribbean")
            lab(6 "non-Latin Caribbean")
            lab(7 "Brazil")
            lab(8 "Mexico")
			)
			name(figure4_`x');
			graph export "`outputpath'/figure4_`x'.png", replace width(4000);
			;
#delimit cr



** GRAPHIC - Self Harm
local size = 5
local x= 3
#delimit ;
	gr twoway 
        (sc drate1 drate2                 if cod==`x' & paho_subregion==1, msize(`size') m(o) mlc("`a1'%90") mfc("`a1'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==2, msize(`size') m(o) mlc("`a2'%90") mfc("`a2'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==3, msize(`size') m(o) mlc("`a3'%90") mfc("`a3'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==4, msize(`size') m(o) mlc("`a4'%90") mfc("`a4'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==5, msize(`size') m(o) mlc("`a5'%90") mfc("`a5'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==6, msize(`size') m(o) mlc("`a6'%90") mfc("`a6'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==7, msize(`size') m(o) mlc("`a7'%90") mfc("`a7'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==8, msize(`size') m(o) mlc("`a8'%90") mfc("`a8'%90") mlw(0.1))

        (function y=x, range(2 10000) lc(gs2) lp("-"))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=3 t=5)) 
			ysize(10) xsize(15)

			xlab(10 100 1000 "1,000" 10000 "10,000", notick labs(`size') tlc(gs0) labc(gs16) notick nogrid glc(gs16))
			xscale(fill log lw(vthin) lc(gs16)  range(10(1000)15010)) 
			xtitle("Female rate", size(`size') color(gs16) margin(l=1 r=1 t=1 b=1)) 

			ylab(10 100 1000 "1,000" 10000 "10,000",
			valuelabel labc(gs2) labs(`size') tstyle(major_notick) nogrid glc(gs2) angle(0) format(%9.0f))
			yscale(fill log lw(vthin) lc(gs2) ) 
			ytitle("Male rate", size(`size') color(gs2) margin(l=1 r=1 t=1 b=1)) 

			/// X-Axis text
            ///text(90 2.8 "Health Expenditure (% GDP)",  place(e) size(4.25) color(gs2))
            ///text(90 -1.1 "Doctors and nurses (per 10,000 pop)",  place(e) size(4.25) color(gs2))

			legend(off size(`size') position(6) ring(1) bc(gs2) color(gs2) bm(t=1 b=4 l=5 r=0) colf cols(4)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
			order(1 2 3 4 5 6 7 8) 
			lab(1 "North America") 
			lab(2 "Southern Cone")
            lab(3 "Central America")
            lab(4 "Andean")
            lab(5 "Latin Caribbean")
            lab(6 "non-Latin Caribbean")
            lab(7 "Brazil")
            lab(8 "Mexico")
			)
			name(figure4_`x');
			graph export "`outputpath'/figure4_`x'.png", replace width(4000);
			;
#delimit cr	



** GRAPHIC - Falls
local size = 5
local x= 4
#delimit ;
	gr twoway 
        (sc drate1 drate2                 if cod==`x' & paho_subregion==1, msize(`size') m(o) mlc("`a1'%90") mfc("`a1'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==2, msize(`size') m(o) mlc("`a2'%90") mfc("`a2'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==3, msize(`size') m(o) mlc("`a3'%90") mfc("`a3'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==4, msize(`size') m(o) mlc("`a4'%90") mfc("`a4'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==5, msize(`size') m(o) mlc("`a5'%90") mfc("`a5'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==6, msize(`size') m(o) mlc("`a6'%90") mfc("`a6'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==7, msize(`size') m(o) mlc("`a7'%90") mfc("`a7'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==8, msize(`size') m(o) mlc("`a8'%90") mfc("`a8'%90") mlw(0.1))

        (function y=x, range(2 10000) lc(gs2) lp("-"))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=3 t=5)) 
			ysize(10) xsize(15)

			xlab(10 100 1000 "1,000" 10000 "10,000", notick labs(`size') tlc(gs0) labc(gs2) notick nogrid glc(gs16))
			xscale(fill log lw(vthin) lc(gs2) range(10(1000)15010)) 
			xtitle("Female rate", size(`size') color(gs2) margin(l=1 r=1 t=1 b=1)) 

			ylab(10 100 1000 "1,000" 10000 "10,000",
			valuelabel labc(gs16) labs(`size') tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(fill log lw(vthin) lc(gs16) ) 
			ytitle("Male rate", size(`size') color(gs16) margin(l=1 r=1 t=1 b=1)) 

			/// X-Axis text
            ///text(90 2.8 "Health Expenditure (% GDP)",  place(e) size(4.25) color(gs2))
            ///text(90 -1.1 "Doctors and nurses (per 10,000 pop)",  place(e) size(4.25) color(gs2))

			legend(off size(`size') position(6) ring(1) bc(gs2) color(gs2) bm(t=1 b=4 l=5 r=0) colf cols(4)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
			order(1 2 3 4 5 6 7 8) 
			lab(1 "North America") 
			lab(2 "Southern Cone")
            lab(3 "Central America")
            lab(4 "Andean")
            lab(5 "Latin Caribbean")
            lab(6 "non-Latin Caribbean")
            lab(7 "Brazil")
            lab(8 "Mexico")
			)
			name(figure4_`x');
			graph export "`outputpath'/figure4_`x'.png", replace width(4000);
			;
#delimit cr	



** GRAPHIC - Drowning
local size = 5
local x= 5
#delimit ;
	gr twoway 
        (sc drate1 drate2                 if cod==`x' & paho_subregion==1, msize(`size') m(o) mlc("`a1'%90") mfc("`a1'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==2, msize(`size') m(o) mlc("`a2'%90") mfc("`a2'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==3, msize(`size') m(o) mlc("`a3'%90") mfc("`a3'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==4, msize(`size') m(o) mlc("`a4'%90") mfc("`a4'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==5, msize(`size') m(o) mlc("`a5'%90") mfc("`a5'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==6, msize(`size') m(o) mlc("`a6'%90") mfc("`a6'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==7, msize(`size') m(o) mlc("`a7'%90") mfc("`a7'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==8, msize(`size') m(o) mlc("`a8'%90") mfc("`a8'%90") mlw(0.1))

        (function y=x, range(2 10000) lc(gs2) lp("-"))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=3 t=5)) 
			ysize(10) xsize(15)

			xlab(10 100 1000 "1,000" 10000 "10,000", notick labs(`size') tlc(gs0) labc(gs2) notick nogrid glc(gs16))
			xscale(fill log lw(vthin) lc(gs2) range(10(1000)15010)) 
			xtitle("Female rate", size(`size') color(gs2) margin(l=1 r=1 t=1 b=1)) 

			ylab(10 100 1000 "1,000" 10000 "10,000",
			valuelabel labc(gs2) labs(`size') tstyle(major_notick) nogrid glc(gs2) angle(0) format(%9.0f))
			yscale(fill log lw(vthin) lc(gs2) ) 
			ytitle("Male rate", size(`size') color(gs2) margin(l=1 r=1 t=1 b=1)) 

			/// X-Axis text
            ///text(90 2.8 "Health Expenditure (% GDP)",  place(e) size(4.25) color(gs2))
            ///text(90 -1.1 "Doctors and nurses (per 10,000 pop)",  place(e) size(4.25) color(gs2))

			legend(off size(`size') position(6) ring(1) bc(gs2) color(gs2) bm(t=1 b=4 l=5 r=0) colf cols(4)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
			order(1 2 3 4 5 6 7 8) 
			lab(1 "North America") 
			lab(2 "Southern Cone")
            lab(3 "Central America")
            lab(4 "Andean")
            lab(5 "Latin Caribbean")
            lab(6 "non-Latin Caribbean")
            lab(7 "Brazil")
            lab(8 "Mexico")
			)
			name(figure4_`x');
			graph export "`outputpath'/figure4_`x'.png", replace width(4000);
			;
#delimit cr	





** GRAPHIC - Unintentional 
local size = 5
local x= 7
#delimit ;
	gr twoway 
        (sc drate1 drate2                 if cod==`x' & paho_subregion==1, msize(`size') m(o) mlc("`a1'%90") mfc("`a1'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==2, msize(`size') m(o) mlc("`a2'%90") mfc("`a2'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==3, msize(`size') m(o) mlc("`a3'%90") mfc("`a3'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==4, msize(`size') m(o) mlc("`a4'%90") mfc("`a4'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==5, msize(`size') m(o) mlc("`a5'%90") mfc("`a5'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==6, msize(`size') m(o) mlc("`a6'%90") mfc("`a6'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==7, msize(`size') m(o) mlc("`a7'%90") mfc("`a7'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==8, msize(`size') m(o) mlc("`a8'%90") mfc("`a8'%90") mlw(0.1))

        (function y=x, range(100 10000) lc(gs2) lp("-"))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=3 t=5)) 
			ysize(10) xsize(15)

			xlab(100 1000 "1,000" 10000 "10,000", notick labs(`size') tlc(gs0) labc(gs2) notick nogrid glc(gs16))
			xscale(fill log lw(vthin) lc(gs2) range(100(1000)15100)) 
			xtitle("Female rate", size(`size') color(gs2) margin(l=1 r=1 t=1 b=1)) 

			ylab(100 1000 "1,000" 10000 "10,000",
			valuelabel labc(gs2) labs(`size') tstyle(major_notick) nogrid glc(gs2) angle(0) format(%9.0f))
			yscale(fill log lw(vthin) lc(gs2) ) 
			ytitle("Male rate", size(`size') color(gs2) margin(l=1 r=1 t=1 b=1)) 

			/// X-Axis text
            ///text(90 2.8 "Health Expenditure (% GDP)",  place(e) size(4.25) color(gs2))
            ///text(90 -1.1 "Doctors and nurses (per 10,000 pop)",  place(e) size(4.25) color(gs2))

			legend(off size(`size') position(6) ring(1) bc(gs2) color(gs2) bm(t=1 b=4 l=5 r=0) colf cols(4)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
			order(1 2 3 4 5 6 7 8) 
			lab(1 "North America") 
			lab(2 "Southern Cone")
            lab(3 "Central America")
            lab(4 "Andean")
            lab(5 "Latin Caribbean")
            lab(6 "non-Latin Caribbean")
            lab(7 "Brazil")
            lab(8 "Mexico")
			)
			name(figure4_`x');
			graph export "`outputpath'/figure4_`x'.png", replace width(4000);
			;
#delimit cr	



** GRAPHIC - Intentional 
local size = 5
local x= 8
#delimit ;
	gr twoway 
        (sc drate1 drate2                 if cod==`x' & paho_subregion==1, msize(`size') m(o) mlc("`a1'%90") mfc("`a1'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==2, msize(`size') m(o) mlc("`a2'%90") mfc("`a2'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==3, msize(`size') m(o) mlc("`a3'%90") mfc("`a3'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==4, msize(`size') m(o) mlc("`a4'%90") mfc("`a4'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==5, msize(`size') m(o) mlc("`a5'%90") mfc("`a5'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==6, msize(`size') m(o) mlc("`a6'%90") mfc("`a6'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==7, msize(`size') m(o) mlc("`a7'%90") mfc("`a7'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==8, msize(`size') m(o) mlc("`a8'%90") mfc("`a8'%90") mlw(0.1))

        (function y=x, range(100 10000) lc(gs2) lp("-"))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=3 t=5)) 
			ysize(10) xsize(15)

			xlab(100 1000 "1,000" 10000 "10,000", notick labs(`size') tlc(gs0) labc(gs2) notick nogrid glc(gs16))
			xscale(fill log lw(vthin) lc(gs2) range(100(1000)15100)) 
			xtitle("Female rate", size(`size') color(gs2) margin(l=1 r=1 t=1 b=1)) 

			ylab(100 1000 "1,000" 10000 "10,000",
			valuelabel labc(gs16) labs(`size') tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(fill log lw(vthin) lc(gs16) ) 
			ytitle("Male rate", size(`size') color(gs16) margin(l=1 r=1 t=1 b=1)) 

			/// X-Axis text
            ///text(90 2.8 "Health Expenditure (% GDP)",  place(e) size(4.25) color(gs2))
            ///text(90 -1.1 "Doctors and nurses (per 10,000 pop)",  place(e) size(4.25) color(gs2))

			legend(off size(`size') position(6) ring(1) bc(gs2) color(gs2) bm(t=1 b=4 l=5 r=0) colf cols(4)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
			order(1 2 3 4 5 6 7 8) 
			lab(1 "North America") 
			lab(2 "Southern Cone")
            lab(3 "Central America")
            lab(4 "Andean")
            lab(5 "Latin Caribbean")
            lab(6 "non-Latin Caribbean")
            lab(7 "Brazil")
            lab(8 "Mexico")
			)
			name(figure4_`x');
			graph export "`outputpath'/figure4_`x'.png", replace width(4000);
			;
#delimit cr	





** GRAPHIC - Intentional 
local size = 5
local size2 = 10
local x= 8
#delimit ;
	gr twoway 
        (sc drate1 drate2                 if cod==`x' & paho_subregion==1, msize(`size2') m(o) mlc("`a1'%90") mfc("`a1'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==2, msize(`size2') m(o) mlc("`a2'%90") mfc("`a2'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==3, msize(`size2') m(o) mlc("`a3'%90") mfc("`a3'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==4, msize(`size2') m(o) mlc("`a4'%90") mfc("`a4'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==5, msize(`size2') m(o) mlc("`a5'%90") mfc("`a5'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==6, msize(`size2') m(o) mlc("`a6'%90") mfc("`a6'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==7, msize(`size2') m(o) mlc("`a7'%90") mfc("`a7'%90") mlw(0.1))
        (sc drate1 drate2                 if cod==`x' & paho_subregion==8, msize(`size2') m(o) mlc("`a8'%90") mfc("`a8'%90") mlw(0.1))

        ///(function y=x, range(100 10000) lc(gs2) lp("-"))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=3 t=5)) 
			ysize(5) xsize(20)

			xlab(none, notick labs(`size') tlc(gs0) labc(gs16) notick nogrid glc(gs16))
			xscale(noline fill log lw(vthin) lc(gs16) range(100(1000)15100)) 
			xtitle("Female rate", size(`size') color(gs16) margin(l=1 r=1 t=1 b=1)) 

			ylab(none,
			valuelabel labc(gs16) labs(`size') tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline fill log lw(vthin) lc(gs16) ) 
			ytitle("Male rate", size(`size') color(gs16) margin(l=1 r=1 t=1 b=1)) 

			legend(size(`size2') position(6) ring(1) bc(gs2) color(gs2) bm(t=1 b=4 l=5 r=0) colf cols(4)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) 
			order(1 2 3 4 5 6 7 8) 
			lab(1 "North America") 
			lab(2 "Central America")
            lab(3 "Andean")
            lab(4 "Southern Cone")
            lab(5 "Latin Carib")
            lab(6 "non-Latin Carib")
            lab(7 "Brazil")
            lab(8 "Mexico")
			)
			name(figure4_legend);
			graph export "`outputpath'/Figure4_legend.png", replace width(4000);
			;
#delimit cr	


** ------------------------------------------------------
** FIGURE 4: PDF
** ------------------------------------------------------

    putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.5cm) margin(left,0.5cm) margin(right,0.5cm)
** PAGE 1. INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Figure 4. ") , bold
    putpdf text ("Disease burden in 33 countries of the Americas for 5 major causes of injury in 2021 (gender-specific DALY rate per 100,000), ")
    putpdf text ("and overall disease burden from unintentional and intentional injuries.")

** FIGURE OF DAILY COVID-19 COUNT
    putpdf table f2 = (8,2), width(75%) border(all,nil) halign(center)
    putpdf table f2(1,1)=("(A) Interpersonal violence")
    putpdf table f2(1,2)=("(B) Road injury")

    putpdf table f2(1,.), border(all, single, e6e6e6) bgcolor(f2f2f2) halign(center) 
    putpdf table f2(3,.), border(all, single, e6e6e6) bgcolor(f2f2f2) halign(center)
    putpdf table f2(5,.), border(all, single, e6e6e6) bgcolor(f2f2f2) halign(center)
    putpdf table f2(7,.), border(all, single, e6e6e6) bgcolor(f2f2f2) halign(center)

    putpdf table f2(3,1)=("(C) Self harm")
    putpdf table f2(3,2)=("(D) Falls")
    putpdf table f2(5,1)=("(E) Drowning")
    putpdf table f2(7,1)=("Unintentional injury")
    putpdf table f2(7,2)=("Intentional injury")

    putpdf table f2(2,1)=image("`outputpath'/figure4_1.png")
    putpdf table f2(2,2)=image("`outputpath'/figure4_2.png")
    putpdf table f2(4,1)=image("`outputpath'/figure4_3.png")
    putpdf table f2(4,2)=image("`outputpath'/figure4_4.png")
    putpdf table f2(6,1)=image("`outputpath'/figure4_5.png")
    putpdf table f2(8,1)=image("`outputpath'/figure4_7.png")
    putpdf table f2(8,2)=image("`outputpath'/figure4_8.png")

    putpdf table legend = (1,1), width(60%) border(all,nil) halign(center)
    putpdf table legend(1,1)=image("`outputpath'/figure4_legend_strip4.png")

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    ** putpdf save "`outputpath'/Figure_One_SS_`date_string'_grayscale", replace
    putpdf save "`outputpath'/Figure_4_`date_string'_color", replace
