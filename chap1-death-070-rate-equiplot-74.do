** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-death-070-rate-equiplot.do
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
    log using "`logpath'\chap1-death-070-rate-equiplot", replace
** HEADER -----------------------------------------------------

** Use MR datasets
use "`datapath'\from-who\chap1_mortrate_001_74", clear
append using "`datapath'\from-who\chap1_mortrate_002_74"

/*
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
sort ghecause sex arate


** A few statistics to accompany the EQUIPLOT graphic below 
preserve
	use "`datapath'\from-who\chap1_mortrate_003_74", clear
	**append using "`datapath'\from-who\chap1_mortrate_002"

	** Rates per 100,000
	replace crate = crate * 100000
	replace arate = arate * 100000
	replace aupp = aupp * 100000
	replace alow = alow * 100000
	format pop %15.0fc

	** Inequality in 2019 
	** keep if year==2019
	keep if region<100
	drop crate aupp alow ase pop
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

	sort ghecause sex arate
	#delimit ; 
	label define oregion_   
                    1 "Antigua and Barbuda"
                    2 "Argentina"
                    3 "Bahamas"
                    4 "Barbados"
                    5 "Bolivia"
                    6 "Brazil"
                    7 "Belize"
                    8 "Canada"
                    9 "Chile"
                    10 "Colombia"
                    11 "Costa Rica"
                    12 "Cuba"
                    13 "Dominican Republic"
                    14 "Ecuador"
                    15 "El Salvador"
                    16 "Grenada"
                    17 "Guatemala"
                    18 "Guyana"
                    19 "Haiti"
                    20 "Honduras"
                    21 "Jamaica"
                    22 "Mexico"
                    23 "Nicaragua"
                    24 "Panama"
                    25 "Paraguay"
                    26 "Peru"
                    27 "Saint Lucia"
                    28 "Saint Vincent and the Grenadines"
                    29 "Suriname"
                    30 "Trinidad and Tobago"
                    31 "United States"
                    32 "Uruguay"
                    33 "Venezuela", modify;                     
	#delimit cr 
	label values region oregion_  
	sort year ghecause sex arate
restore

/*

** -------------------------------------------------------------------
** GRAPHIC
** -------------------------------------------------------------------

** Legend outer limits for graphing 
local outer1 -2 -15 28 -15 28 230 -2 230 -2 -15 
local outer2 -2 240 28 240 28 465 -2 465 -2 240 

** Shifting NCDs and Injures further down screen
gen zero = 0
replace oregion = oregion + 9 if ghecause==20
replace oregion = oregion + 18 if ghecause==30

** Rates among females to allow reverse graphic from RHS
gen zerof = 450
gen dratef = 450 - drate

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
        (function y=27, yaxis(1) range(0 0) lc(gs13) lp("-") dropline(0))
        (function y=27, yaxis(2) range(450 450) lc(gs13) lp("-") dropline(450))

        /// COM vertical lines
		(function y=8, yaxis(1) range(100 115) lc("`com'%25") lp("-") )
        (function y=8, yaxis(2) range(342 357) lc("`com'%25") lp("-") )
		(function y=115, range(6 8) hor lc("`com'%25") lp("-") )
		(function y=342, range(6 8) hor lc("`com'%25") lp("-") )

        /// NCD vertical lines
		(function y=17, yaxis(1) range(199 214) lc("`ncd'%25") lp("-") )
        (function y=17, yaxis(2) range(272 287) lc("`ncd'%25") lp("-") )
		(function y=214, range(15 17) hor lc("`ncd'%25") lp("-") )
		(function y=272, range(15 17) hor lc("`ncd'%25") lp("-") )

        /// INJ vertical lines
		(function y=26, yaxis(1) range(75 90) lc("`inj'%25") lp("-") )
        (function y=26, yaxis(2) range(411 426) lc("`inj'%25") lp("-") )
		(function y=90, range(24 26) hor lc("`inj'%25") lp("-") )
		(function y=411, range(24 26) hor lc("`inj'%25") lp("-") )

        (scatteri `outer1' , yaxis(1) recast(area) lw(0.2) lc(gs10) fc(none)  )
        (scatteri `outer2' , yaxis(2) recast(area) lw(0.2) lc(gs10) fc(none)  )

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
        (sc oregion dratef         if sex==2 & ghecause==10 , yaxis(2) msize(3) m(o) mlc("`com'") mfc("`com'") mlw(0.1))	

		/// NCD. FEMALE
        (rbar zerof dratef oregion if sex==2 & ghecause==20 , yaxis(2) horizontal fc("`ncd'%50") barw(0.05) lw(none))
        (sc oregion dratef         if sex==2 & ghecause==20 , yaxis(2) msize(3) m(o) mlc("`ncd'") mfc("`ncd'") mlw(0.1))

		/// INJ. FEMALE
        (rbar zerof dratef oregion if sex==2 & ghecause==30 , yaxis(2) horizontal fc("`inj'%50") barw(0.05) lw(none))
        (sc oregion dratef         if sex==2 & ghecause==30 , yaxis(2) msize(3) m(o) mlc("`inj'") mfc("`inj'") mlw(0.1))			
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(11) xsize(15)

			/// TOP
			xlab(none, 
			axis(1) labc(gs8) labs(2.5) notick grid glc(gs16) angle(0) format(%9.0f))
			xscale(axis(1) noline range(0(10)430) lw(vthin)) 
			xtitle("", axis(1)  size(2.5) color(gs8) margin(l=1 r=1 t=0 b=0)) 

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
			axis(1) labc(gs8) labs(2.25) tlc(gs8) nogrid notick glc(blue) angle(0) format(%9.0f) labgap(0))
			yscale(axis(1) noline reverse range(-6(0.5)29) noextend) 
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
			axis(2) labc(gs8) labs(2.25) tlc(gs8) nogrid notick glc(red) angle(0) format(%9.0f) labgap(0))
			yscale(axis(2) noline reverse range(-6(0.5)29) noextend) 
			ytitle(" ", axis(2) color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            /// Legend Text
            text(27 170 "Men",  place(c) size(3) color(gs8))   
            text(27 300 "Women",  place(c) size(3) color(gs8))   
            text(-3 225 "Mortality Rate Excess (per 100,000 people)",  place(c) size(3) color(gs8))   
            text(-1 0 "0",  place(c) size(3) color(gs8))   
            text(-1 450 "0",  place(c) size(3) color(gs8))   
			/// Values
			text(5.4 115 "100",  place(c) size(2.5) color("`com'"))   
			text(5.4 342 "92",  place(c) size(2.5) color("`com'"))   
			
			text(14.4 214 "199",  place(c) size(2.5) color("`ncd'"))   
			text(14.4 272 "162",  place(c) size(2.5) color("`ncd'"))   			
			
			text(23.4 90 "75",  place(c) size(2.5) color("`inj'"))   
			text(23.4 411 "24",  place(c) size(2.5) color("`inj'"))   

			legend(size(2.5) position(12) nobox ring(0) bm(t=0 b=0 l=0 r=0) colf cols(3)
			region(fcolor(gs16)  lw(none) margin(t=0 b=1 l=0 r=0)) 
			order(24 26 28) 
			lab(24 "Communicable") 
			lab(26 "NCDs") 		
			lab(28 "Injuries") 		
            )
			name(men_adiff)
			;
#delimit cr	