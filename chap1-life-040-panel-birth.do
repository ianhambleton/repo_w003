** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-life-040-panel-birth.do
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
    log using "`logpath'\chap1-life-040-panel-birth", replace
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

** FULL LIFE TABLE DATASET 
use "`datapath'\from-who\lifetables\who-lifetable-2019-all", clear
** Only keep regional LE data
drop if country!=""
** Keep ex data --> ghocode==35
keep if ghocode==35 

** APPEND the HALE regional dataset 
append using "`datapath'\from-who\lifetables\who-hale-2019-regions"
label define ghocode_ 100 "hale",modify 
label values ghocode ghocode_ 


** Construct a single example panel, which we will then repeat for each major WHO region 
** This will be a simple line chart of LE (y) by age (x)

** New x-axis values to represent YEARS
gen yr1 = .
replace yr1 = 1 if year==2000 
replace yr1 = 2 if year==2005 
replace yr1 = 3 if year==2010 
replace yr1 = 4 if year==2015 
replace yr1 = 5 if year==2019 
replace yr1 = yr1 + 5 if region=="EMR"
replace yr1 = yr1 + 10 if region=="SEAR"
replace yr1 = yr1 + 15 if region=="GLOBAL"
replace yr1 = yr1 + 20 if region=="AMR"
replace yr1 = yr1 + 25 if region=="WPR"
replace yr1 = yr1 + 30   if region=="EUR"

** RESTRICT ROWS and re-shape
keep if agroup==1 
drop if year==2005 
sort region year ghocode agroup sex 
reshape wide metric , i(region year agroup sex) j(ghocode)


** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(6)  nograph
local list r(p) 
** Aqua (MEN --> sex = 2)
local men `r(p3)'
** Orange (Women --> sex = 1)
local women `r(p5)'

** Jitter men by a fraction to improve visual
replace yr1 = yr1 - 0.2 if sex==1 
replace yr1 = yr1 + 0.2 if sex==2 

** Legend outer limits for graphing 
local outer1 75 0.7 77 0.7 77 2.1 75 2.1 75 0.7 
local outer2 72 0.7 74 0.7 74 2.1 72 2.1 72 0.7 
local outer3 33 0.7 35 0.7 35 2.1 33 2.1 33 0.7 
local outer4 30 0.7 32 0.7 32 2.1 30 2.1 30 0.7 

#delimit ;
	gr twoway 

		/// Shaded region represents difference between HALE (lower) and LE (upper) 
	    (rarea metric35 metric100 yr1 if region=="AFR" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="AFR" & sex==2 & agroup==1 , lw(none) color("`men'%25"))
		
	    (rarea metric35 metric100 yr1 if region=="AMR" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="AMR" & sex==2 & agroup==1 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="EMR" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="EMR" & sex==2 & agroup==1 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="EUR" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="EUR" & sex==2 & agroup==1 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="SEAR" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="SEAR" & sex==2 & agroup==1 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="WPR" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="WPR" & sex==2 & agroup==1 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="GLOBAL" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="GLOBAL" & sex==2 & agroup==1 , lw(none) color("`men'%25"))

		/// Africa
		(line metric35 yr1 if region=="AFR" & sex==2 & agroup==1 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="AFR" & sex==1 & agroup==1 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="AFR" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="AFR" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))

		/// The Americas
		(line metric35 yr1 if region=="AMR" & sex==2 & agroup==1 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="AMR" & sex==1 & agroup==1 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="AMR" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="AMR" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))


		/// Eastern Mediterranean
		(line metric35 yr1 if region=="EMR" & sex==2 & agroup==1 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="EMR" & sex==1 & agroup==1 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="EMR" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="EMR" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))


		/// Europe
		(line metric35 yr1 if region=="EUR" & sex==2 & agroup==1 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="EUR" & sex==1 & agroup==1 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="EUR" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="EUR" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))

		/// South-East Asia
		(line metric35 yr1 if region=="SEAR" & sex==2 & agroup==1 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="SEAR" & sex==1 & agroup==1 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="SEAR" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="SEAR" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))

		/// Western Pacific
		(line metric35 yr1 if region=="WPR" & sex==2 & agroup==1 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="WPR" & sex==1 & agroup==1 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="WPR" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="WPR" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))

		/// World
		(line metric35 yr1 if region=="GLOBAL" & sex==2 & agroup==1 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="GLOBAL" & sex==1 & agroup==1 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="GLOBAL" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="GLOBAL" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))

        /// droplines
        (function y=85, range(1 35.5) lc(gs12) dropline(5.5 10.5 15.5 20.5 25.5 30.5 35.5))

        /// Legend
        (function y=82, range(0.7 2.1) lc(gs10) lw(0.4))
        (function y=79, range(0.7 2.1) lp("-") lc(gs10) lw(0.4))
        (scatteri `outer1' , recast(area) lw(none) lc("`women'%35") fc("`women'%35")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`men'%35") fc("`men'%35")  )

		/// X-Axis lines
        (function y=39, range(1 5) lc(gs8) lw(0.2))
        (function y=39, range(6 10) lc(gs8) lw(0.2))
        (function y=39, range(11 15) lc(gs8) lw(0.2))
        (function y=39, range(16 20) lc(gs8) lw(0.2))
        (function y=39, range(21 25) lc(gs8) lw(0.2))
        (function y=39, range(26 30) lc(gs8) lw(0.2))
        (function y=39, range(31 35) lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(8) xsize(16)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(40(5)85,
			valuelabel labc(gs8) labs(2.5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) range(50(5)90) noextend) 
			ytitle("Life Expectancy at birth (yrs)", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
            text(87 3 "Africa",  place(c) size(2.5) color(gs5))
            text(87 8 "Eastern" "Mediterranean",  place(c) size(2.5) color(gs5))
            text(87 13 "South-East" "Asia",  place(c) size(2.5) color(gs5))
            text(87 18 "World",  place(c) size(2.5) color(gs5))
            text(87 23 "The" "Americas",  place(c) size(2.5) color(gs5))
            text(87 28 "Western" "Pacific",  place(c) size(2.5) color(gs5))
            text(87 33 "Europe",  place(c) size(2.5) color(gs5))   
            /// Legend Text
            text(82 2.5 "LE",  place(e) size(2.5) color(gs8))   
            text(79 2.5   "HALE",  place(e) size(2.5) color(gs8))   
            text(76   2.5 "Women",  place(e) size(2.5) color(gs8))   
            text(73   2.5   "Men",  place(e) size(2.5) color(gs8))   
			/// X-Axis text
            text(40 1 "2000",  place(e) size(2.5) color(gs8))
            text(40 5 "2019",  place(w) size(2.5) color(gs8))
            text(40 6 "2000",  place(e) size(2.5) color(gs8))
            text(40 10 "2019",  place(w) size(2.5) color(gs8))
            text(40 11 "2000",  place(e) size(2.5) color(gs8))
            text(40 15 "2019",  place(w) size(2.5) color(gs8))
            text(40 16 "2000",  place(e) size(2.5) color(gs8))
            text(40 20 "2019",  place(w) size(2.5) color(gs8))
            text(40 21 "2000",  place(e) size(2.5) color(gs8))
            text(40 25 "2019",  place(w) size(2.5) color(gs8))
            text(40 26 "2000",  place(e) size(2.5) color(gs8))
            text(40 30 "2019",  place(w) size(2.5) color(gs8))
            text(40 31 "2000",  place(e) size(2.5) color(gs8))
            text(40 35 "2019",  place(w) size(2.5) color(gs8))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le_panel)
			;
#delimit cr	


* Version 2 - legend outside
** Legend outer limits for graphing 
local outer1 95 16.7 97 16.7 97 18.1 95 18.1 95 16.7 
local outer2 92 16.7 94 16.7 94 18.1 92 18.1 92 16.7 

#delimit ;
	gr twoway 

		/// Shaded region represents difference between HALE (lower) and LE (upper) 
	    (rarea metric35 metric100 yr1 if region=="AFR" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="AFR" & sex==2 & agroup==1 , lw(none) color("`men'%25"))
		
	    (rarea metric35 metric100 yr1 if region=="AMR" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="AMR" & sex==2 & agroup==1 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="EMR" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="EMR" & sex==2 & agroup==1 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="EUR" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="EUR" & sex==2 & agroup==1 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="SEAR" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="SEAR" & sex==2 & agroup==1 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="WPR" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="WPR" & sex==2 & agroup==1 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="GLOBAL" & sex==1 & agroup==1 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="GLOBAL" & sex==2 & agroup==1 , lw(none) color("`men'%25"))

		/// Africa
		(line metric35 yr1 if region=="AFR" & sex==2 & agroup==1 , lp("l") lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="AFR" & sex==1 & agroup==1 , lp("l") lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="AFR" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="AFR" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))

		/// The Americas
		(line metric35 yr1 if region=="AMR" & sex==2 & agroup==1 , lp("l") lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="AMR" & sex==1 & agroup==1 , lp("l") lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="AMR" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="AMR" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))

		/// Eastern Mediterranean
		(line metric35 yr1 if region=="EMR" & sex==2 & agroup==1 , lp("l") lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="EMR" & sex==1 & agroup==1 , lp("l") lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="EMR" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="EMR" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))


		/// Europe
		(line metric35 yr1 if region=="EUR" & sex==2 & agroup==1 , lp("l") lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="EUR" & sex==1 & agroup==1 , lp("l") lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="EUR" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="EUR" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))

		/// South-East Asia
		(line metric35 yr1 if region=="SEAR" & sex==2 & agroup==1 , lp("l") lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="SEAR" & sex==1 & agroup==1 , lp("l") lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="SEAR" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="SEAR" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))

		/// Western Pacific
		(line metric35 yr1 if region=="WPR" & sex==2 & agroup==1 , lp("l") lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="WPR" & sex==1 & agroup==1 , lp("l") lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="WPR" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="WPR" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))

		/// World
		(line metric35 yr1 if region=="GLOBAL" & sex==2 & agroup==1 , lp("l") lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="GLOBAL" & sex==1 & agroup==1 , lp("l") lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="GLOBAL" & sex==2 & agroup==1 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="GLOBAL" & sex==1 & agroup==1 , lp("-") lw(0.4) lc("`women'%25"))

        /// droplines
        (function y=85, range(1 35.5) lc(gs12) lp("l") dropline(5.5 10.5 15.5 20.5 25.5 30.5 35.5))

        /// Legend
        (function y=96, range(11.7 13.1) lp("l") lc(gs10) lw(0.4))
        (function y=93, range(11.7 13.1) lp("-") lc(gs10) lw(0.4))
        (function y=91, range(10.5 20.5) lp("l") lc(gs14) lw(0.4))
        (scatteri `outer1' , recast(area) lw(none) lc("`women'%35") fc("`women'%35")  )
        (scatteri `outer2' , recast(area) lw(none) lc("`men'%35") fc("`men'%35")  )

		/// X-Axis lines
        (function y=39,   range(1 5) lp("l") lc(gs8) lw(0.2))
        (function y=39,  range(6 10) lp("l") lc(gs8) lw(0.2))
        (function y=39, range(11 15) lp("l") lc(gs8) lw(0.2))
        (function y=39, range(16 20) lp("l") lc(gs8) lw(0.2))
        (function y=39, range(21 25) lp("l") lc(gs8) lw(0.2))
        (function y=39, range(26 30) lp("l") lc(gs8) lw(0.2))
        (function y=39, range(31 35) lp("l") lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(8) xsize(16)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(40(5)85,
			valuelabel labc(gs8) labs(2.5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) range(50(1)98) noextend) 
			ytitle("Life Expectancy at birth (yrs)", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
            text(87 3 "Africa",  place(c) size(2.5) color(gs5))
            text(87 8 "Eastern" "Mediterranean",  place(c) size(2.5) color(gs5))
            text(87 13 "South-East" "Asia",  place(c) size(2.5) color(gs5))
            text(87 18 "World",  place(c) size(2.5) color(gs5))
            text(87 23 "The" "Americas",  place(c) size(2.5) color(gs5))
            text(87 28 "Western" "Pacific",  place(c) size(2.5) color(gs5))
            text(87 33 "Europe",  place(c) size(2.5) color(gs5))   
            /// Legend Text
            text(96 13.5 "LE",  place(e) size(2.5) color(gs8))   
            text(93 13.5   "HALE",  place(e) size(2.5) color(gs8))   
            text(96 18.5 "Women",  place(e) size(2.5) color(gs8))   
            text(93 18.5   "Men",  place(e) size(2.5) color(gs8))   
			/// X-Axis text
            text(40 1 "2000",  place(e) size(2.5) color(gs8))
            text(40 5 "2019",  place(w) size(2.5) color(gs8))
            text(40 6 "2000",  place(e) size(2.5) color(gs8))
            text(40 10 "2019",  place(w) size(2.5) color(gs8))
            text(40 11 "2000",  place(e) size(2.5) color(gs8))
            text(40 15 "2019",  place(w) size(2.5) color(gs8))
            text(40 16 "2000",  place(e) size(2.5) color(gs8))
            text(40 20 "2019",  place(w) size(2.5) color(gs8))
            text(40 21 "2000",  place(e) size(2.5) color(gs8))
            text(40 25 "2019",  place(w) size(2.5) color(gs8))
            text(40 26 "2000",  place(e) size(2.5) color(gs8))
            text(40 30 "2019",  place(w) size(2.5) color(gs8))
            text(40 31 "2000",  place(e) size(2.5) color(gs8))
            text(40 35 "2019",  place(w) size(2.5) color(gs8))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le_panel2)
			;
#delimit cr	
** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\2024-edits\graphics\fig1.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig1.pdf", replace



