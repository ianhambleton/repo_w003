** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-mortrate-004.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-Apr-2021
    //  algorithm task			    Panel graphic - proportion of deaths by AGE group

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
    log using "`logpath'\chap1-mortrate-004", replace
** HEADER -----------------------------------------------------

** Use MR datasets
use "`datapath'\from-who\chap1_mortrate_001", clear
append using "`datapath'\from-who\chap1_mortrate_002"

** Rates per 100,000
replace crate = crate * 100000
replace arate = arate * 100000
replace aupp = aupp * 100000
replace alow = alow * 100000
format pop %15.0fc

** Inequality in 2019 
keep if year==2019
keep if region<100
drop year crate aupp alow ase pop
sort sex ghecause
order sex ghecause region 

** There will be SIX charts, by SEX x GHECAUSE
** Identify minimum rate for each chart
sort sex ghecause arate 
bysort sex ghecause : egen mrate = min(arate)
gen drate = arate - mrate
replace drate = 0 if drate<0.001
** Ordered y-axis
bysort sex ghecause : gen oregion = _n
decode region, gen(tregion)

** -------------------------------------------------------------------
** GRAPHIC
** -------------------------------------------------------------------
gen zero = 0
replace oregion = oregion + 9 if ghecause==20
replace oregion = oregion + 18 if ghecause==30

gen zerof = 400
gen dratef = 400 - drate



** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(9)  nograph
local list r(p) 
** (COM --> ghecause = 10)
local com `r(p3)'
** (NCD --> ghecause = 600)
local ncd `r(p6)'
** (INJ --> ghecause = 1510)
local inj `r(p9)'

#delimit ;
	gr twoway 
        (function y=26.5, range(0 0) lc(gs13) lp("-") dropline(0))
        (function y=26.5, range(400 400) lc(gs13) lp("-") dropline(400))

		/// COM. MALE
        (rbar zero drate oregion if sex==1 & ghecause==10 , yaxis(1) horizontal fc("`com'%50") barw(0.05) lw(none))
        (sc oregion drate        if sex==1 & ghecause==10 , yaxis(1) msize(3) m(o) mlc("`com'") mfc("`com'") mlw(0.1))

		/// NCD. MALE
        (rbar zero drate oregion if sex==1 & ghecause==20 , yaxis(1) horizontal fc("`ncd'%50") barw(0.05) lw(none))
        (sc oregion drate        if sex==1 & ghecause==20 , yaxis(1) msize(3) m(o) mlc("`ncd'") mfc("`ncd'") mlw(0.1))

		/// INJ. MALE
        (rbar zero drate oregion if sex==1 & ghecause==30 , yaxis(1) horizontal fc("`inj'%50") barw(0.05) lw(none))
        (sc oregion drate        if sex==1 & ghecause==30 , yaxis(1) msize(3) m(o) mlc("`inj'") mfc("`inj'") mlw(0.1))

		/// COM. FEMALE
        (rbar zerof dratef oregion if sex==2 & ghecause==10 , yaxis(2) horizontal fc("`com'%50") barw(0.05) lw(none))
        (sc oregion dratef       if sex==2 & ghecause==10 , yaxis(2) msize(3) m(o) mlc("`com'") mfc("`com'") mlw(0.1))	

		/// NCD. FEMALE
        (rbar zerof dratef oregion if sex==2 & ghecause==20 , yaxis(2) horizontal fc("`ncd'%50") barw(0.05) lw(none))
        (sc oregion dratef        if sex==2 & ghecause==20 , yaxis(2) msize(3) m(o) mlc("`ncd'") mfc("`ncd'") mlw(0.1))

		/// INJ. FEMALE
        (rbar zerof dratef oregion if sex==2 & ghecause==30 , yaxis(2) horizontal fc("`inj'%50") barw(0.05) lw(none))
        (sc oregion dratef        if sex==2 & ghecause==30 , yaxis(2) msize(3) m(o) mlc("`inj'") mfc("`inj'") mlw(0.1))			
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(10) xsize(15)

			/// men
			xlab(none, 
			labc(gs0) labs(10) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline range(0(10)200) lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			/// men
			ylab(	1 "north america"
					2 "mexico"
					3 "central america"
					4 "non-latin caribbean"
					5 "andean"
					6 "brazil"
					7 "southern cone"
					8 "latin caribbean"
					10 "central america"
					11 "north america"
					12 "andean"
					13 "southern cone"
					14 "brazil"
					15 "mexico"
					16 "non-latin caribbean"
					17 "latin caribbean"
					19 "north america"
					20 "andean"
					21 "mexico"
					22 "central america"
					23 "brazil"
					24 "non-latin caribbean"
					25 "latin caribbean"
					26 "southern cone"
					,
			axis(1) valuelabel labc(gs8) labs(3) tlc(gs8) nogrid notick glc(gs16) angle(0) format(%9.0f) labgap(5))
			yscale(axis(1) noline reverse range(0.5(1)8.5) ) 
			ytitle(" ", axis(1) color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

			/// women
			ylab(	
					1	"north america"
					2	"mexico"
					3	"non-latin caribbean"
					4	"andean"
					5	"central america"
					6	"brazil"
					7	"southern cone"
					8	"latin caribbean"
					10	"central america"
					11	"andean"
					12	"north america"
					13	"brazil"
					14	"mexico"
					15	"southern cone"
					16	"non-latin caribbean"
					17	"latin caribbean"
					19	"andean"
					20	"mexico"
					21	"central america"
					22	"brazil"
					23	"north america"
					24	"non-latin caribbean"
					25	"southern cone"
					26	"latin caribbean"
					,
			axis(2) valuelabel labc(gs8) labs(3) tlc(gs8) nogrid notick glc(gs16) angle(0) format(%9.0f) labgap(5))
			yscale(axis(2) reverse noline range(0.5(1)8.5) ) 
			ytitle(" ", axis(2) color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
            /// text(790 2010 "North" "America",  place(c) size(3) color(gs5))

            /// Legend Text
            ///text(708 2034 "Men",  place(w) size(3) color(gs8))   

			/// X-Axis text
           /// text(0 2000 "2000",  place(e) size(2.5) color(gs8))

			legend(off)
			name(men_adiff)
			;
#delimit cr	