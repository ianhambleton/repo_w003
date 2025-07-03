** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-life-050-panel-elderly.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-Apr-2021
    //  algorithm task			    Chapter 1 - Life Expectancy

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
    log using "`logpath'\cpresentation-wdc-le-by-country", replace
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
insheet using "`datapath'\from-un\lifetables2025\unpopulation_dataportal_20250313053110-full.csv", clear


keep locationid location iso3 time sexid sex age value
keep if age==65
drop age
rename time year 
rename value metric 

** Year restriction
keep if year>=2000 & year<=2019

** New x-axis values running from 1 to 20 to represent YEARS 2000-2019
gen yr1 = .
forval x=1/20 {
	replace yr1 = `x' if year==`x'+1999 
}

** generate a local for the ColorBrewer color scheme
colorpalette cblind, n(9) nograph
local list r(p) 
** Orange (Americas)
local amr `r(p3)'
** Blue (Barbados)
local brb `r(p7)'
** Light Blue (Second Country)
local oth `r(p4)'

colorpalette #D89C60 #045174
local list r(p) 
** Orange (Americas)
local amr `r(p1)'
** Blue (Barbados)
local brb `r(p2)'


#delimit ; 
drop if locationid==5541|locationid==5549|locationid==5557|
		locationid==2091|locationid==915|locationid==2090 |
		locationid==961|locationid==904|locationid==900;
#delimit cr 


** FIRST GRAPHIC
#delimit ;
	gr twoway 

		/// N=27 --> BELOW Americas LE in 2019
		/// HAITI (line metric year if locationid==332 & sexid==3 , lw(0.25) col6r("`oth'%40"))
		/// N=5 --> ABOVE Americas LE in 2019
		(line metric year  if locationid==28 & sexid==3 , lw(0.35) color(gs16))
		(line metric year  if locationid==44 & sexid==3 , lw(0.35) color(gs16))
		(line metric year  if locationid==84 & sexid==3 , lw(0.35) color(gs16))
		(line metric year  if locationid==92 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==192 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==212 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==214 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==254 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==308 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==328 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==388 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==500 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==531 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==533 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==534 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==535 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==659 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==660 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==662 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==666 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==670 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==740 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==780 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==796 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==850 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==663 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==136 & sexid==3 , lw(0.35) color(gs16))
		(line metric year  if locationid==60 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==312 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==652 & sexid==3 , lw(0.35) color(gs16))

		/// BARBADOS LE from 65 years 
		(line metric year if locationid==52 & sexid==3 , lw(2) color(gs16))

		/// AMERICAS LE from 65 years 
	    (line metric year if locationid==5505 & sexid==3 , lw(2) color("`amr'"))


        /// droplines
        /// (function y=25, range(1 35.5) lc(gs12) dropline(5.5 10.5 15.5 20.5 25.5 30.5 35.5))

		/// X-Axis lines
        /// (function y=9, range(1 5) lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(16) xsize(12)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin) range(2000(1)2027) ) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(14(1)19,
			valuelabel labc(gs0) labs(4) tlc(gs0) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) lc(gs0) range(15.8(0.2)19.2) noextend) 
			ytitle(" ", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 
			///ymtick(20(0.5)23)

            /// Region Titles 
            text(18.8 2021 "The" "Americas",  place(e) size(5) color(gs0))
            ///text(17.3 2021 "Barbados",  place(e) size(5) color(gs0))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le65_panel1)
			;
#delimit cr	


** SECOND GRAPHIC
#delimit ;
	gr twoway 

		/// N=27 --> BELOW Americas LE in 2019
		/// HAITI (line metric year if locationid==332 & sexid==3 , lw(0.25) col6r("`oth'%40"))
		/// N=5 --> ABOVE Americas LE in 2019
		(line metric year  if locationid==28 & sexid==3 , lw(0.35) color(gs16))
		(line metric year  if locationid==44 & sexid==3 , lw(0.35) color(gs16))
		(line metric year  if locationid==84 & sexid==3 , lw(0.35) color(gs16))
		(line metric year  if locationid==92 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==192 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==212 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==214 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==254 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==308 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==328 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==388 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==500 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==531 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==533 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==534 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==535 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==659 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==660 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==662 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==666 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==670 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==740 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==780 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==796 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==850 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==663 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==136 & sexid==3 , lw(0.35) color(gs16))
		(line metric year  if locationid==60 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==312 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==652 & sexid==3 , lw(0.35) color(gs16))

		/// BARBADOS LE from 65 years 
		(line metric year if locationid==52 & sexid==3 , lw(2) color("`brb'%75"))

		/// AMERICAS LE from 65 years 
	    (line metric year if locationid==5505 & sexid==3 , lw(2) color("`amr'"))


        /// droplines
        /// (function y=25, range(1 35.5) lc(gs12) dropline(5.5 10.5 15.5 20.5 25.5 30.5 35.5))

		/// X-Axis lines
        /// (function y=9, range(1 5) lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(16) xsize(12)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin) range(2000(1)2027) ) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(14(1)19,
			valuelabel labc(gs0) labs(4) tlc(gs0) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) lc(gs0) range(15.8(0.2)19.2) noextend) 
			ytitle(" ", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 
			///ymtick(20(0.5)23)

            /// Region Titles 
            text(18.8 2021 "The" "Americas",  place(e) size(5) color(gs0))
            text(17.3 2021 "Barbados",  place(e) size(5) color(gs0))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le65_panel2)
			;
#delimit cr	



** THIRD GRAPHIC
#delimit ;
	gr twoway 

		/// N=27 --> BELOW Americas LE in 2019
		/// HAITI (line metric year if locationid==332 & sexid==3 , lw(0.25) col6r("`brb'%40"))
		/// N=5 --> ABOVE Americas LE in 2019
		(line metric year  if locationid==28 & sexid==3 , lw(0.35) color(gs16))
		(line metric year  if locationid==44 & sexid==3 , lw(0.35) color(gs16))
		(line metric year  if locationid==84 & sexid==3 , lw(0.35) color(gs16))
		(line metric year  if locationid==92 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==192 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==212 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==214 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==254 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==308 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==328 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==388 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==500 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==531 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==533 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==534 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==535 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==659 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==660 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==662 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==666 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==670 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==740 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==780 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==796 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==850 & sexid==3 , lw(0.35) color(gs16))
		(line metric year if locationid==663 & sexid==3 , lw(0.35) color("`amr'%30"))
		(line metric year if locationid==136 & sexid==3 , lw(0.35) color("`amr'%30"))
		(line metric year  if locationid==60 & sexid==3 , lw(0.35) color("`amr'%30"))
		(line metric year if locationid==312 & sexid==3 , lw(0.35) color("`amr'%30"))
		(line metric year if locationid==652 & sexid==3 , lw(0.35) color("`amr'%30"))

		/// BARBADOS LE from 65 years 
		(line metric year if locationid==52 & sexid==3 , lw(2) color("`brb'%75"))

		/// AMERICAS LE from 65 years 
	    (line metric year if locationid==5505 & sexid==3 , lw(2) color("`amr'"))

        /// droplines
        /// (function y=25, range(1 35.5) lc(gs12) dropline(5.5 10.5 15.5 20.5 25.5 30.5 35.5))

		/// X-Axis lines
        /// (function y=9, range(1 5) lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(16) xsize(12)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin) range(2000(1)2027) ) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(14(1)19,
			valuelabel labc(gs0) labs(4) tlc(gs0) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) lc(gs0) range(15.8(0.2)19.2) noextend) 
			ytitle(" ", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 
			///ymtick(20(0.5)23)

            /// Region Titles 
            text(18.8 2021 "The" "Americas",  place(e) size(5) color(gs0))
            text(17.3 2021 "Barbados",  place(e) size(5) color(gs0))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le65_panel3)
			;
#delimit cr	



** THIRD GRAPHIC
#delimit ;
	gr twoway 

		/// N=27 --> BELOW Americas LE in 2019
		/// HAITI (line metric year if locationid==332 & sexid==3 , lw(0.25) col6r("`brb'%40"))
		/// N=5 --> ABOVE Americas LE in 2019
		(line metric year  if locationid==28 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year  if locationid==44 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year  if locationid==84 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year  if locationid==92 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==192 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==212 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==214 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==254 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==308 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==328 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==388 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==500 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==531 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==533 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==534 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==535 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==659 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==660 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==662 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==666 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==670 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==740 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==780 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==796 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==850 & sexid==3 , lw(0.35) color("`brb'%30"))
		(line metric year if locationid==663 & sexid==3 , lw(0.35) color("`amr'%30"))
		(line metric year if locationid==136 & sexid==3 , lw(0.35) color("`amr'%30"))
		(line metric year  if locationid==60 & sexid==3 , lw(0.35) color("`amr'%30"))
		(line metric year if locationid==312 & sexid==3 , lw(0.35) color("`amr'%30"))
		(line metric year if locationid==652 & sexid==3 , lw(0.35) color("`amr'%30"))

		/// BARBADOS LE from 65 years 
		(line metric year if locationid==52 & sexid==3 , lw(2) color("`brb'%75"))

		/// AMERICAS LE from 65 years 
	    (line metric year if locationid==5505 & sexid==3 , lw(2) color("`amr'"))

        /// droplines
        /// (function y=25, range(1 35.5) lc(gs12) dropline(5.5 10.5 15.5 20.5 25.5 30.5 35.5))

		/// X-Axis lines
        /// (function y=9, range(1 5) lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(16) xsize(12)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin) range(2000(1)2027) ) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(14(1)19,
			valuelabel labc(gs0) labs(4) tlc(gs0) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) lc(gs0) range(15.8(0.2)19.2) noextend) 
			ytitle(" ", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 
			///ymtick(20(0.5)23)

            /// Region Titles 
            text(18.8 2021 "The" "Americas",  place(e) size(5) color(gs0))
            text(17.3 2021 "Barbados",  place(e) size(5) color(gs0))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le65_panel4)
			;
#delimit cr	

/*
** ADD JAM
#delimit ;
	gr twoway 

		/// Shaded region represents difference between HALE (lower) and LE (upper) 
	    (line metric year if country=="AMR" & sex==3 , lw(2) color("`amr'"))
		(line metric year if country=="BRB" & sex==3 , lw(2) color("`brb'%75"))
		(line metric year if country=="JAM" & sex==3 , lw(2) color("`xtra'%25"))

        /// droplines
        /// (function y=25, range(1 35.5) lc(gs12) dropline(5.5 10.5 15.5 20.5 25.5 30.5 35.5))

		/// X-Axis lines
        /// (function y=9, range(1 5) lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(16) xsize(12)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin) range(2000(1)2027) ) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(20(1)23,
			valuelabel labc(gs0) labs(4) tlc(gs0) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) lc(gs0) range(19.8(0.2)24.2) noextend) 
			ytitle(" ", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 
			ymtick(20(0.5)23)

            /// Region Titles 
            text(22.7 2021 "The" "Americas",  place(e) size(5) color(gs0))
            text(21.0 2021 "Barbados",  place(e) size(5) color(gs0))
            text(20.2 2004 "Jamaica",  place(e) size(5) color(gs8))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le_panel_JAM)
			;
#delimit cr	

** ADD ATG
#delimit ;
	gr twoway 

		/// Shaded region represents difference between HALE (lower) and LE (upper) 
	    (line metric year if country=="AMR" & sex==3 , lw(2) color("`amr'"))
		(line metric year if country=="BRB" & sex==3 , lw(2) color("`brb'%75"))
		(line metric year if country=="ATG" & sex==3 , lw(2) color("`xtra'%25"))

        /// droplines
        /// (function y=25, range(1 35.5) lc(gs12) dropline(5.5 10.5 15.5 20.5 25.5 30.5 35.5))

		/// X-Axis lines
        /// (function y=9, range(1 5) lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(16) xsize(12)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin) range(2000(1)2027) ) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(20(1)23,
			valuelabel labc(gs0) labs(4) tlc(gs0) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) lc(gs0) range(19.8(0.2)24.2) noextend) 
			ytitle(" ", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 
			ymtick(20(0.5)23)

            /// Region Titles 
            text(22.7 2021 "The" "Americas",  place(e) size(5) color(gs0))
            text(21.0 2021 "Barbados",  place(e) size(5) color(gs0))
            text(20.2 2004 "Antigua & Barbuda",  place(e) size(5) color(gs8))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le_panel_ATG)
			;
#delimit cr	

** ADD BHS
#delimit ;
	gr twoway 

		/// Shaded region represents difference between HALE (lower) and LE (upper) 
	    (line metric year if country=="AMR" & sex==3 , lw(2) color("`amr'"))
		(line metric year if country=="BRB" & sex==3 , lw(2) color("`brb'%75"))
		(line metric year if country=="BHS" & sex==3 , lw(2) color("`xtra'%25"))

        /// droplines
        /// (function y=25, range(1 35.5) lc(gs12) dropline(5.5 10.5 15.5 20.5 25.5 30.5 35.5))

		/// X-Axis lines
        /// (function y=9, range(1 5) lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(16) xsize(12)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin) range(2000(1)2027) ) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(20(1)23,
			valuelabel labc(gs0) labs(4) tlc(gs0) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(noline lw(vthin) lc(gs0) range(19.8(0.2)24.2) noextend) 
			ytitle(" ", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 
			ymtick(20(0.5)23)

            /// Region Titles 
            text(22.7 2021 "The" "Americas",  place(e) size(5) color(gs0))
            text(21.0 2021 "Barbados",  place(e) size(5) color(gs0))
            text(20.2 2004 "Bahamas",  place(e) size(5) color(gs8))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le_panel_BHS)
			;
#delimit cr	
