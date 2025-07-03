** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-life-040-panel-birth.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	13-Mar-2025
    //  algorithm task			    Presentation-WDC

    ** General algorithm set-up
    version 16
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
    log using "`logpath'\presentation-wdc-life-040-panel-birth-001", replace
** HEADER -----------------------------------------------------


** ---------------------------------------------------
** SEX CODES 
** WOMEN 	= 1 
** MEN 		= 2
** BOTH 	= 3 
** ---------------------------------------------------

** EXAMPLE IS LIFE EXPECTANCY at BIRTH
** PANEL OF LINE CHARTS
** to compare Americas

** FULL LIFE TABLE DATASET (life expectancy at birth)
insheet using "`datapath'\from-un\lifetables2025\unpopulation_dataportal_20250313051125-birth.csv", clear
keep locationid location iso3 time sexid sex value
rename time year 
rename value metric 

** Year restriction
keep if year>=2000 & year<=2019

** New x-axis values running from 1 to 20 to represent YEARS 2000-2019
gen yr1 = .
forval x=1/20 {
	replace yr1 = `x' if year==`x'+1999 
}

** OTHER RESTRICTIONS for GRAPHIC ONE - regions
** 5505 - Americas
** 2901 - SIDS Caribbean 
** 915 - Caribbean
** 900 - World 
keep if locationid==5505 | locationid==2091 | locationid==915 | locationid==900

** Reshape wide for SEX 
drop location iso3 sex
reshape wide metric, i(locationid year) j(sexid)
order locationid year yr1 metric1 metric2 metric3
label var metric1 "LE0 men" 
label var metric2 "LE0 women" 
label var metric3 "LE0 both" 

label define loc_ 900 "World" 5505 "The Americas" 2091 "SIDS Caribbean" 915 "Caribbean",modify 
label values locationid loc_

** generate a local for the ColorBrewer color scheme
colorpalette cblind, n(9) nograph
local list r(p) 
** Blue (World)
local wld `r(p4)'
** Orange (Americas)
local amr `r(p3)'

** Jitter men by a fraction to improve visual
replace yr1 = yr1 - 0.4 if locationid==5505 

** Legend outer limits for graphing 
local outer1 83.5 10 84.5 10 84.5 12 83.5 12 83.5 10 
local outer2 81.5 10 82.5 10 82.5 12 81.5 12 81.5 10 

** BUILD THE GRAPHIC IN STAGES

** 001. Women World
#delimit ;
	gr twoway 

		/// Shaded areas represents difference between women (upper) and men (lower) 
		
        /// AMERICAS-gender-difference 
        (rarea metric2 metric1 yr1 if locationid==5505 , lw(none) color("gs16"))
	    /// AMERICAS-women
        (line metric2 yr1 if locationid==5505 , lw(0.4) lp("l") lc("gs16"))
	    /// AMERICAS-men
        (line metric1 yr1 if locationid==5505 , lw(0.4) lp("-")  lc("gs16"))
	    /// WORLD-gender-difference
        (rarea metric2 metric1 yr1 if locationid==900 , lw(none) color("gs16"))
	    /// WORLD-women
        (line metric2 yr1 if locationid==900 , lw(0.4) lp("l") lc("`wld'"))
	    /// WORLD-men
        (line metric1 yr1 if locationid==900 , lw(0.4) lp("-")  lc("gs16"))

        /// Legend
        (function y=84, range(2 4) lc(gs10) lp("l") lw(0.4))
        (function y=82, range(2 4) lc(gs10) lp("-") lw(0.4))
        (scatteri `outer1' , recast(area) lw(none) lc("`amr'%75") fc("`amr'%75")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`wld'%75") fc("`wld'%75")  )

		/// X-Axis lines
        (function y=57, range(1 20) lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(12) xsize(12)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(60(5)80,
			valuelabel notick labc(gs0) labs(5.5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f) labgap(3))
			yscale(lw(vthin) lc(gs8) range(60(5)87) noextend) 
			ytitle(" ", color(gs8) size(4.5) margin(l=1 r=1 t=1 b=1)) 

			/// X-Axis text
            text(58 1 "2000",  place(e) size(6) color(gs0))
            text(58 20 "2019",  place(w) size(6) color(gs0))
            text(84   4.4 "Women",  place(e) size(4) color(gs8))   
            text(82   4.4 "Men",  place(e) size(4) color(gs8))   
            text(84   12.4 "Americas",  place(e) size(4) color(gs8))   
            text(82   12.4 "World",  place(e) size(4) color(gs8)) 
			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le01)
			;
#delimit cr	

** 002. Women and Men World
#delimit ;
	gr twoway 

		/// Shaded areas represents difference between women (upper) and men (lower) 
		
        /// AMERICAS-gender-difference 
        (rarea metric2 metric1 yr1 if locationid==5505 , lw(none) color("gs16"))
	    /// AMERICAS-women
        (line metric2 yr1 if locationid==5505 , lw(0.4) lp("l") lc("gs16"))
	    /// AMERICAS-men
        (line metric1 yr1 if locationid==5505 , lw(0.4) lp("-")  lc("gs16"))
	    /// WORLD-gender-difference
        (rarea metric2 metric1 yr1 if locationid==900 , lw(none) color("gs16"))
	    /// WORLD-women
        (line metric2 yr1 if locationid==900 , lw(0.4) lp("l") lc("`wld'"))
	    /// WORLD-men
        (line metric1 yr1 if locationid==900 , lw(0.4) lp("-")  lc("`wld'"))

        /// Legend
        (function y=84, range(2 4) lc(gs10) lp("l") lw(0.4))
        (function y=82, range(2 4) lc(gs10) lp("-") lw(0.4))
        (scatteri `outer1' , recast(area) lw(none) lc("`amr'%75") fc("`amr'%75")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`wld'%75") fc("`wld'%75")  )

		/// X-Axis lines
        (function y=57, range(1 20) lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(12) xsize(12)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(60(5)80,
			valuelabel notick labc(gs0) labs(5.5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f) labgap(3))
			yscale(lw(vthin) lc(gs8) range(60(5)87) noextend) 
			ytitle(" ", color(gs8) size(4.5) margin(l=1 r=1 t=1 b=1)) 

			/// X-Axis text
            text(58 1 "2000",  place(e) size(6) color(gs0))
            text(58 20 "2019",  place(w) size(6) color(gs0))
            text(84   4.4 "Women",  place(e) size(4) color(gs8))   
            text(82   4.4 "Men",  place(e) size(4) color(gs8))   
            text(84   12.4 "Americas",  place(e) size(4) color(gs8))   
            text(82   12.4 "World",  place(e) size(4) color(gs8)) 
			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le02)
			;
#delimit cr	


** 003. Women and Men World with shading
#delimit ;
	gr twoway 

		/// Shaded areas represents difference between women (upper) and men (lower) 
		
        /// AMERICAS-gender-difference 
        (rarea metric2 metric1 yr1 if locationid==5505 , lw(none) color("gs16"))
	    /// AMERICAS-women
        (line metric2 yr1 if locationid==5505 , lw(0.4) lp("l") lc("gs16"))
	    /// AMERICAS-men
        (line metric1 yr1 if locationid==5505 , lw(0.4) lp("-")  lc("gs16"))
	    /// WORLD-gender-difference
        (rarea metric2 metric1 yr1 if locationid==900 , lw(none) color("`wld'%55"))
	    /// WORLD-women
        (line metric2 yr1 if locationid==900 , lw(0.4) lp("l") lc("`wld'"))
	    /// WORLD-men
        (line metric1 yr1 if locationid==900 , lw(0.4) lp("-")  lc("`wld'"))

        /// Legend
        (function y=84, range(2 4) lc(gs10) lp("l") lw(0.4))
        (function y=82, range(2 4) lc(gs10) lp("-") lw(0.4))
        (scatteri `outer1' , recast(area) lw(none) lc("`amr'%75") fc("`amr'%75")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`wld'%75") fc("`wld'%75")  )

		/// X-Axis lines
        (function y=57, range(1 20) lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(12) xsize(12)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(60(5)80,
			valuelabel notick labc(gs0) labs(5.5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f) labgap(3))
			yscale(lw(vthin) lc(gs8) range(60(5)87) noextend) 
			ytitle(" ", color(gs8) size(4.5) margin(l=1 r=1 t=1 b=1)) 

			/// X-Axis text
            text(58 1 "2000",  place(e) size(6) color(gs0))
            text(58 20 "2019",  place(w) size(6) color(gs0))
            text(84   4.4 "Women",  place(e) size(4) color(gs8))   
            text(82   4.4 "Men",  place(e) size(4) color(gs8))   
            text(84   12.4 "Americas",  place(e) size(4) color(gs8))   
            text(82   12.4 "World",  place(e) size(4) color(gs8)) 
			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le03)
			;
#delimit cr	


** 003. Women and Men World with shading / AMR also added 
#delimit ;
	gr twoway 

		/// Shaded areas represents difference between women (upper) and men (lower) 
		
        /// AMERICAS-gender-difference 
        (rarea metric2 metric1 yr1 if locationid==5505 , lw(none) color("`amr'%55"))
	    /// AMERICAS-women
        (line metric2 yr1 if locationid==5505 , lw(0.4) lp("l") lc("`amr'"))
	    /// AMERICAS-men
        (line metric1 yr1 if locationid==5505 , lw(0.4) lp("-")  lc("`amr'"))
	    /// WORLD-gender-difference
        (rarea metric2 metric1 yr1 if locationid==900 , lw(none) color("`wld'%55"))
	    /// WORLD-women
        (line metric2 yr1 if locationid==900 , lw(0.4) lp("l") lc("`wld'"))
	    /// WORLD-men
        (line metric1 yr1 if locationid==900 , lw(0.4) lp("-")  lc("`wld'"))

        /// Legend
        (function y=84, range(2 4) lc(gs10) lp("l") lw(0.4))
        (function y=82, range(2 4) lc(gs10) lp("-") lw(0.4))
        (scatteri `outer1' , recast(area) lw(none) lc("`amr'%75") fc("`amr'%75")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`wld'%75") fc("`wld'%75")  )

		/// X-Axis lines
        (function y=57, range(1 20) lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(12) xsize(12)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(60(5)80,
			valuelabel notick labc(gs0) labs(5.5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f) labgap(3))
			yscale(lw(vthin) lc(gs8) range(60(5)87) noextend) 
			ytitle(" ", color(gs8) size(4.5) margin(l=1 r=1 t=1 b=1)) 

			/// X-Axis text
            text(58 1 "2000",  place(e) size(6) color(gs0))
            text(58 20 "2019",  place(w) size(6) color(gs0))
            text(84   4.4 "Women",  place(e) size(4) color(gs8))   
            text(82   4.4 "Men",  place(e) size(4) color(gs8))   
            text(84   12.4 "Americas",  place(e) size(4) color(gs8))   
            text(82   12.4 "World",  place(e) size(4) color(gs8)) 
			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le04)
			;
#delimit cr	
