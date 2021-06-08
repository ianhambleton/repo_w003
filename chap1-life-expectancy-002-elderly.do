** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-life-expectancy-003-elderly.do
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
    local datapath "X:\OneDrive - The University of the West Indies\Writing\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:\OneDrive - The University of the West Indies\Writing\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "X:\OneDrive - The University of the West Indies\Writing\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap1-life-expectancy-003-elderly", replace
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
keep if agroup==14 
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
local outer3 21.6 0.7 22.4 0.7 22.4 2.1 21.6 2.1 21.6 0.7 
local outer4 20.6 0.7 21.4 0.7 21.4 2.1 20.6 2.1 20.6 0.7 

#delimit ;
	gr twoway 

		/// Shaded region represents difference between HALE (lower) and LE (upper) 
	    (rarea metric35 metric100 yr1 if region=="AFR" & sex==1 & agroup==14 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="AFR" & sex==2 & agroup==14 , lw(none) color("`men'%25"))
		
	    (rarea metric35 metric100 yr1 if region=="AMR" & sex==1 & agroup==14 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="AMR" & sex==2 & agroup==14 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="EMR" & sex==1 & agroup==14 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="EMR" & sex==2 & agroup==14 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="EUR" & sex==1 & agroup==14 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="EUR" & sex==2 & agroup==14 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="SEAR" & sex==1 & agroup==14 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="SEAR" & sex==2 & agroup==14 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="WPR" & sex==1 & agroup==14 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="WPR" & sex==2 & agroup==14 , lw(none) color("`men'%25"))

	    (rarea metric35 metric100 yr1 if region=="GLOBAL" & sex==1 & agroup==14 , lw(none) color("`women'%25"))
		(rarea metric35 metric100 yr1 if region=="GLOBAL" & sex==2 & agroup==14 , lw(none) color("`men'%25"))

		/// Africa
		(line metric35 yr1 if region=="AFR" & sex==2 & agroup==14 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="AFR" & sex==1 & agroup==14 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="AFR" & sex==2 & agroup==14 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="AFR" & sex==1 & agroup==14 , lp("-") lw(0.4) lc("`women'%25"))

		/// The Americas
		(line metric35 yr1 if region=="AMR" & sex==2 & agroup==14 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="AMR" & sex==1 & agroup==14 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="AMR" & sex==2 & agroup==14 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="AMR" & sex==1 & agroup==14 , lp("-") lw(0.4) lc("`women'%25"))


		/// Eastern Mediterranean
		(line metric35 yr1 if region=="EMR" & sex==2 & agroup==14 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="EMR" & sex==1 & agroup==14 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="EMR" & sex==2 & agroup==14 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="EMR" & sex==1 & agroup==14 , lp("-") lw(0.4) lc("`women'%25"))


		/// Europe
		(line metric35 yr1 if region=="EUR" & sex==2 & agroup==14 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="EUR" & sex==1 & agroup==14 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="EUR" & sex==2 & agroup==14 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="EUR" & sex==1 & agroup==14 , lp("-") lw(0.4) lc("`women'%25"))

		/// South-East Asia
		(line metric35 yr1 if region=="SEAR" & sex==2 & agroup==14 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="SEAR" & sex==1 & agroup==14 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="SEAR" & sex==2 & agroup==14 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="SEAR" & sex==1 & agroup==14 , lp("-") lw(0.4) lc("`women'%25"))

		/// Western Pacific
		(line metric35 yr1 if region=="WPR" & sex==2 & agroup==14 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="WPR" & sex==1 & agroup==14 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="WPR" & sex==2 & agroup==14 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="WPR" & sex==1 & agroup==14 , lp("-") lw(0.4) lc("`women'%25"))

		/// World
		(line metric35 yr1 if region=="GLOBAL" & sex==2 & agroup==14 , lw(0.4) lc("`men'%25"))
		(line metric35 yr1 if region=="GLOBAL" & sex==1 & agroup==14 , lw(0.4) lc("`women'%25"))
		(line metric100 yr1 if region=="GLOBAL" & sex==2 & agroup==14 , lp("-") lw(0.4) lc("`men'%25"))
		(line metric100 yr1 if region=="GLOBAL" & sex==1 & agroup==14 , lp("-") lw(0.4) lc("`women'%25"))

        /// droplines
        (function y=25, range(1 35.5) lc(gs12) dropline(5.5 10.5 15.5 20.5 25.5 30.5 35.5))

        /// Legend
        (function y=24, range(0.7 2.1) lc(gs10) lw(0.4))
        (function y=23, range(0.7 2.1) lp("-") lc(gs10) lw(0.4))
        (scatteri `outer3' , recast(area) lw(none) lc("`women'%35") fc("`women'%35")  )
        (scatteri `outer4' , recast(area) lw(none) lc("`men'%35") fc("`men'%35")  )


		/// X-Axis lines
        (function y=9, range(1 5) lc(gs8) lw(0.2))
        (function y=9, range(6 10) lc(gs8) lw(0.2))
        (function y=9, range(11 15) lc(gs8) lw(0.2))
        (function y=9, range(16 20) lc(gs8) lw(0.2))
        (function y=9, range(21 25) lc(gs8) lw(0.2))
        (function y=9, range(26 30) lc(gs8) lw(0.2))
        (function y=9, range(31 35) lc(gs8) lw(0.2))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(8) xsize(16)

			xlab(none, 
			valuelabel labc(gs0) labs(2.5) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(10(5)25,
			valuelabel labc(gs8) labs(2.5) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs8) range(10(1)28) noextend) 
			ytitle("Life Expectancy at 60 (yrs)", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            /// Region Titles 
            text(26 3 "Africa",  place(c) size(2.5) color(gs5))
            text(26 8 "Eastern" "Mediterranean",  place(c) size(2.5) color(gs5))
            text(26 13 "South-East" "Asia",  place(c) size(2.5) color(gs5))
            text(26 18 "World",  place(c) size(2.5) color(gs5))
            text(26 23 "The" "Americas",  place(c) size(2.5) color(gs5))
            text(26 28 "Western" "Pacific",  place(c) size(2.5) color(gs5))
            text(26 33 "Europe",  place(c) size(2.5) color(gs5))   
            /// Legend Text
            text(24 2.5 "LE",  place(e) size(2.5) color(gs8))   
            text(23 2.5   "HALE",  place(e) size(2.5) color(gs8))   
            text(22   2.5 "Women",  place(e) size(2.5) color(gs8))   
            text(21   2.5   "Men",  place(e) size(2.5) color(gs8))   
			/// X-Axis text
            text(9.5 1 "2000",  place(e) size(2.5) color(gs8))
            text(9.5 5 "2019",  place(w) size(2.5) color(gs8))
            text(9.5 6 "2000",  place(e) size(2.5) color(gs8))
            text(9.5 10 "2019",  place(w) size(2.5) color(gs8))
            text(9.5 11 "2000",  place(e) size(2.5) color(gs8))
            text(9.5 15 "2019",  place(w) size(2.5) color(gs8))
            text(9.5 16 "2000",  place(e) size(2.5) color(gs8))
            text(9.5 20 "2019",  place(w) size(2.5) color(gs8))
            text(9.5 21 "2000",  place(e) size(2.5) color(gs8))
            text(9.5 25 "2019",  place(w) size(2.5) color(gs8))
            text(9.5 26 "2000",  place(e) size(2.5) color(gs8))
            text(9.5 30 "2019",  place(w) size(2.5) color(gs8))
            text(9.5 31 "2000",  place(e) size(2.5) color(gs8))
            text(9.5 35 "2019",  place(w) size(2.5) color(gs8))

			legend(off size(2.5) position(9) nobox ring(0) bm(t=1 b=4 l=5 r=0) colf cols(1)
			region(fcolor(gs16)  lw(none) margin(zero)) 
			order(2 1) 
			lab(1 "xx") 
			lab(2 "xx") 		
            )
			name(le_panel)
			;
#delimit cr	


