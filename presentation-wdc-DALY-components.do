** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper1-160-health-figure3.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-OCT-2021
    //  algorithm task			    Summary graphic of POP change between 2000 and 2019

    ** General algorithm set-up
    version 17
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
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs\articles\paper-ncd\article-draft"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\paper1-160-health-figure3", replace
** HEADER -----------------------------------------------------


** -----------------------------------------------
** 2. DALY
** -----------------------------------------------

** Load the country-level daly and population data
** This comes from:
**	--> C:\Sync\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\chap2-000g-daly-country-groups.do
use "`datapath'\from-who\paper1-chap3_byage_country_groups_both_daly", clear
	append using "`datapath'\from-who\paper1-chap3_byage_groups_both_daly"
	keep if who_region==. | who_region==2
	replace iso3c = "LAC" if who_region==2
	replace iso3n = 2000 if who_region==2

	rename age18 age

	** keep if ghecause==100
	keep if ghecause==50
	keep if year==2000 | year==2019
	drop paho_subregion agroup 
	rename pop pop_orig
	collapse (sum) daly (mean) pop = pop_orig , by(iso3c iso3n year age) 
	order iso3c iso3n year  
	bysort year iso3c : egen tpop = sum(pop)
	format tpop %15.0fc
	reshape wide daly pop tpop , i(iso3c iso3n age) j(year)

** AS = age-structure
**  P = Population
**  R = Crude Rate 
**  D = dalys

** METRIC 1. Population given the Age-Structure in 2000, rescaled for the population in 2019  
gen as2000_p2019 = (pop2000 / tpop2000) * tpop2019
format as2000_p2019 %15.1fc

** METRIC 2. Age-specific Mortality Rates in each year 
gen r2000 = daly2000 / pop2000
gen r2019 = daly2019 / pop2019

** METRIC 3. dalyS, assuming:  
**	(a) age-stratified dalyS assuming (POP in 2019 given AS in 2000) and (mortality rate in 2000)
gen d_p2019_as2000 = as2000_p2019 * (r2000)
**	(b) age-stratified dalyS (POP in 2019 given AS in 2019) and (mortality rate in 2000)
gen d_p2019_as2019 = pop2019 * (r2000) 
format d_p2019_as2000 d_p2019_as2019 %15.1fc

** COLLAPSE OUT AGE - keeping 4 statistics
**		- d_p2019_as2000	dalys | POP2019 and AS2000 and MR2000
**		- d_p2019_as2019	dalys | POP2019 and AS2019 and MR2000
**		- dalys2000		dalys | POP2000 and AS2000 and MR2000
**		- dalys2019		dalys | POP2019 and AS2019 and MR2019
collapse (sum) d_* daly2000 daly2019, by(iso3c iso3n)
format d_* daly2000 daly2019 %15.1fc

** Percentage change in dalys between 2000 and 2019
gen ch_d = ((daly2019 - daly2000) / daly2000) * 100


** Combined metrics of interest

** Percentage change due to population growth
gen ch_gr    = ((d_p2019_as2000 - daly2000) / daly2000) * 100
gen ch_as    = ((d_p2019_as2019 - d_p2019_as2000) / daly2000) * 100
gen ch_epi   = (ch_d - ch_as - ch_gr) 
gen test_epi = ((daly2019 - d_p2019_as2019) / daly2000) * 100

** Further graph preparation
gen zero = 0 
gen realzero = 0

gen addage = ch_as  if ch_epi < 0  & ch_as > 0
gen basepop = 0 
replace basepop = ch_as if ch_as < 0
replace basepop = ch_epi + basepop if ch_epi > 0
replace addage = ch_as + ch_epi if ch_epi > 0 
replace addage = ch_epi if ch_epi > 0 & ch_as < 0
gen addpop = addage + ch_gr

format daly* %15.0fc

** List the decompiosition by overall change in deaths
** IE same order as for graphic
		label define iso3n 2000 "THE AMERICAS", modify
		label values iso3n iso3n 
		gsort ch_d
		list iso3n ch_d ch_gr ch_as ch_epi, sep(5) line(120)


** Color scheme
colorpalette d3, 20 n(20) nograph
local list r(p) 
** Blue 
local blu1 `r(p1)'
local blu2 `r(p2)'
** Red
local red1 `r(p7)'
local red2 `r(p8)'
** Gray
local gry1 `r(p15)'
local gry2 `r(p16)'
** Orange
local ora1 `r(p3)'
local ora2 `r(p4)'
** Purple
local pur1 `r(p9)'
local pur2 `r(p10)'

** Column X-location for daly metrics 
** Max of first panel = 144
gen xloc2 = 220
gen xloc3 = 310
gen pd = round(ch_d) 
gen ad = int(daly2019 - daly2000)
format ad %10.0fc

** BARBADOS / JAMAICA / ANTIGUA / BAHAMAS
keep if iso3n==52 | iso3n==388 | iso3n==28 | iso3n==44  

gen y1 = 1 if iso3n==52
replace y1 = 2 if iso3n==388
replace y1 = 3 if iso3n==28
replace y1 = 4 if iso3n==44

local line1 0.5 0 1.5 0
local line2 0.5 0 2.5 0
local line3 0.5 0 3.5 0
local line4 0.5 0 4.5 0


** BARBADOS 1st
#delimit ;
	graph twoway 
		/// Boxes around metrics
		/// (scatteri `box1'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))
		/// (scatteri `box2'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))

		///epi change
		(rbar zero ch_epi y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`blu1'")) 
		/// Change in Population Age
		(rbar basepop addage y1 if iso3n==52, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		/// Change in Population Size
		(rbar addage addpop y1 if iso3n==52, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		/// Overall Change point
		(scatter y1 ch_d if iso3n==52, msymbol(O) mlcolor(gs16) mlw(1) mfcolor(gs16) msize(8))

		/// JAMAICA
		(rbar zero ch_epi y1 if iso3n==388, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==388, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==388, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==388, msymbol(O) mlcolor(gs16) mlw(1) mfcolor(gs16) msize(8))

		/// ANTIGUA & BARBUDA
		(rbar zero ch_epi y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==28, msymbol(O) mlcolor("gs16") mlw(1) mfcolor("gs16") msize(8))

		/// BAHAMAS
		(rbar zero ch_epi y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==44, msymbol(O) mlcolor("gs16") mlw(1) mfcolor("gs16") msize(8))

        (scatteri `line4' , recast(line) lw(0.75) lc("gs16"))
        (scatteri `line1' , recast(line) lw(0.75) lc("gs0"))
		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(6) xsize(18)
	
		xlabel(-10 0 , notick labsize(8) nogrid labcolor(gs0))
		xscale(noline range(-50(5)95)) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(none
		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(reverse noline range(1(1)4))

        text(1 -20 "Barbados", place(w) size(8) color("gs4") just(center) margin(l=2 r=2 t=4 b=2))
        text(2 -20 "Jamaica", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))
        text(3 -20 "Antigua & Barbuda", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))
        text(4 -20 "Bahamas", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))

		/// Percentage 1
        text(1.7 0 "-5%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(off) 

		name(partition_BRB1)
	;
#delimit cr


** BARBADOS 2nd
#delimit ;
	graph twoway 
		/// Boxes around metrics
		/// (scatteri `box1'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))
		/// (scatteri `box2'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))

		///epi change
		(rbar zero ch_epi y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`blu1'")) 
		/// Change in Population Age
		(rbar basepop addage y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`ora1'")) 
		/// Change in Population Size
		(rbar addage addpop y1 if iso3n==52, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		/// Overall Change point
		///(scatter y1 ch_d if iso3n==52, msymbol(O) mlcolor(gs16) mlw(1) mfcolor(gs16) msize(8))

		/// JAMAICA
		(rbar zero ch_epi y1 if iso3n==388, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==388, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==388, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==388, msymbol(O) mlcolor(gs16) mlw(1) mfcolor(gs16) msize(8))

		/// ANTIGUA & BARBUDA
		(rbar zero ch_epi y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==28, msymbol(O) mlcolor("gs16") mlw(1) mfcolor("gs16") msize(8))

		/// BAHAMAS
		(rbar zero ch_epi y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==44, msymbol(O) mlcolor("gs16") mlw(1) mfcolor("gs16") msize(8))

        (scatteri `line4' , recast(line) lw(0.75) lc("gs16"))
        (scatteri `line1' , recast(line) lw(0.75) lc("gs0"))
		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(6) xsize(18)
	
		xlabel(-10 0 20 40 , notick labsize(8) nogrid labcolor(gs0))
		xscale(noline range(-50(5)95)) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(none
		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(reverse noline range(1(1)4))

        text(1 -20 "Barbados", place(w) size(8) color("gs4") just(center) margin(l=2 r=2 t=4 b=2))
        text(2 -20 "Jamaica", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))
        text(3 -20 "Antigua & Barbuda", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))
        text(4 -20 "Bahamas", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))

		/// Percentage 2
        text(1.7 0 "-5%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(1.7 27 "27%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(off) 

		name(partition_BRB2)
	;
#delimit cr


** BARBADOS 3rd
#delimit ;
	graph twoway 
		/// Boxes around metrics
		/// (scatteri `box1'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))
		/// (scatteri `box2'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))

		///epi change
		(rbar zero ch_epi y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`blu1'")) 
		/// Change in Population Age
		(rbar basepop addage y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`ora1'")) 
		/// Change in Population Size
		(rbar addage addpop y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`pur1'")) 
		/// Overall Change point
		///(scatter y1 ch_d if iso3n==52, msymbol(O) mlcolor(gs16) mlw(1) mfcolor(gs16) msize(8))

		/// JAMAICA
		(rbar zero ch_epi y1 if iso3n==388, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==388, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==388, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==388, msymbol(O) mlcolor(gs16) mlw(1) mfcolor(gs16) msize(8))

		/// ANTIGUA & BARBUDA
		(rbar zero ch_epi y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==28, msymbol(O) mlcolor("gs16") mlw(1) mfcolor("gs16") msize(8))

		/// BAHAMAS
		(rbar zero ch_epi y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==44, msymbol(O) mlcolor("gs16") mlw(1) mfcolor("gs16") msize(8))

        (scatteri `line4' , recast(line) lw(0.75) lc("gs16"))
        (scatteri `line1' , recast(line) lw(0.75) lc("gs0"))
		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(6) xsize(18)
	
		xlabel(-10 0 20 40 , notick labsize(8) nogrid labcolor(gs0))
		xscale(noline range(-50(5)95)) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(none
		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(reverse noline range(1(1)4))

        text(1 -20 "Barbados", place(w) size(8) color("gs4") just(center) margin(l=2 r=2 t=4 b=2))
        text(2 -20 "Jamaica", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))
        text(3 -20 "Antigua & Barbuda", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))
        text(4 -20 "Bahamas", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))

		/// Percentage 3
        text(1.7 0 "-5%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(1.7 27 "27%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(1.7 36 "6%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(off) 

		name(partition_BRB3)
	;
#delimit cr


** BARBADOS 4th
#delimit ;
	graph twoway 
		/// Boxes around metrics
		/// (scatteri `box1'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))
		/// (scatteri `box2'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))

		///epi change
		(rbar zero ch_epi y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`blu1'")) 
		/// Change in Population Age
		(rbar basepop addage y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`ora1'")) 
		/// Change in Population Size
		(rbar addage addpop y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`pur1'")) 
		/// Overall Change point
		(scatter y1 ch_d if iso3n==52, msymbol(O) mlcolor(gs0) mlw(1) mfcolor(gs16%90) msize(8))

		/// JAMAICA
		(rbar zero ch_epi y1 if iso3n==388, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==388, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==388, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==388, msymbol(O) mlcolor(gs16) mlw(1) mfcolor(gs16) msize(8))

		/// ANTIGUA & BARBUDA
		(rbar zero ch_epi y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==28, msymbol(O) mlcolor("gs16") mlw(1) mfcolor("gs16") msize(8))

		/// BAHAMAS
		(rbar zero ch_epi y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==44, msymbol(O) mlcolor("gs16") mlw(1) mfcolor("gs16") msize(8))

        (scatteri `line4' , recast(line) lw(0.75) lc("gs16"))
        (scatteri `line1' , recast(line) lw(0.75) lc("gs0"))
		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(6) xsize(18)
	
		xlabel(-10 0 20 40 , notick labsize(8) nogrid labcolor(gs0))
		xscale(noline range(-50(5)95)) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(none
		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(reverse noline range(1(1)4))

        text(1 -20 "Barbados", place(w) size(8) color("gs4") just(center) margin(l=2 r=2 t=4 b=2))
        text(2 -20 "Jamaica", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))
        text(3 -20 "Antigua & Barbuda", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))
        text(4 -20 "Bahamas", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))

		/// Percentage 4
        text(0.9 43 "28%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(off) 

		name(partition_BRB4)
	;
#delimit cr

/*

** JAMAICA
#delimit ;
	graph twoway 
		/// Boxes around metrics
		/// (scatteri `box1'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))
		/// (scatteri `box2'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))

		///epi change
		(rbar zero ch_epi y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`blu1'")) 
		/// Change in Population Age
		(rbar basepop addage y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`ora1'")) 
		/// Change in Population Size
		(rbar addage addpop y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`pur1'")) 
		/// Overall Change point
		(scatter y1 ch_d if iso3n==52, msymbol(O) mlcolor(gs0) mlw(1) mfcolor(gs16%90) msize(8))

		/// JAMAICA
		(rbar zero ch_epi y1 if iso3n==388, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`blu1'")) 
		(rbar basepop addage y1 if iso3n==388, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`ora1'")) 
		(rbar addage addpop y1 if iso3n==388, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`pur1'")) 
		(scatter y1 ch_d if iso3n==388, msymbol(O) mlcolor(gs0) mlw(1) mfcolor(gs16%90) msize(8))

		/// ANTIGUA & BARBUDA
		(rbar zero ch_epi y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==28, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==28, msymbol(O) mlcolor("gs16") mlw(1) mfcolor("gs16") msize(8))

		/// BAHAMAS
		(rbar zero ch_epi y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==44, msymbol(O) mlcolor("gs16") mlw(1) mfcolor("gs16") msize(8))

        (scatteri `line4' , recast(line) lw(0.75) lc("gs16"))
        (scatteri `line2' , recast(line) lw(0.75) lc("gs0"))
		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(6) xsize(18)
	
		xlabel(-10 0 20 40 , notick labsize(8) nogrid labcolor(gs0))
		xscale(noline range(-50(5)95)) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(none
		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(reverse noline range(1(1)4))

        text(1 -20 "Barbados", place(w) size(8) color("gs4") just(center) margin(l=2 r=2 t=4 b=2))
        text(2 -20 "Jamaica", place(w) size(8) color("gs4") just(center) margin(l=2 r=2 t=4 b=2))
        text(3 -20 "Antigua & Barbuda", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))
        text(4 -20 "Bahamas", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))

		/// Percentage 4
        text(0.9 43 "28%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(1.9 45 "32%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(off) 

		name(partition_JAM)
	;
#delimit cr


** ANTIGUA & BARBUDA
#delimit ;
	graph twoway 
		/// Boxes around metrics
		/// (scatteri `box1'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))
		/// (scatteri `box2'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))

		///epi change
		(rbar zero ch_epi y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`blu1'")) 
		/// Change in Population Age
		(rbar basepop addage y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`ora1'")) 
		/// Change in Population Size
		(rbar addage addpop y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`pur1'")) 
		/// Overall Change point
		(scatter y1 ch_d if iso3n==52, msymbol(O) mlcolor(gs0) mlw(1) mfcolor(gs16%90) msize(8))

		/// JAMAICA
		(rbar zero ch_epi y1 if iso3n==388, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`blu1'")) 
		(rbar basepop addage y1 if iso3n==388, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`ora1'")) 
		(rbar addage addpop y1 if iso3n==388, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`pur1'")) 
		(scatter y1 ch_d if iso3n==388, msymbol(O) mlcolor(gs0) mlw(1) mfcolor(gs16%90) msize(8))

		/// ANTIGUA & BARBUDA
		(rbar zero ch_epi y1 if iso3n==28, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`blu1'")) 
		(rbar basepop addage y1 if iso3n==28, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`ora1'")) 
		(rbar addage addpop y1 if iso3n==28, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`pur1'")) 
		(scatter y1 ch_d if iso3n==28, msymbol(O) mlcolor(gs0) mlw(1) mfcolor(gs16%90) msize(8))

		/// BAHAMAS
		(rbar zero ch_epi y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar basepop addage y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(rbar addage addpop y1 if iso3n==44, horizontal barwidth(.75)  lc("gs16") lw(0.1) fc("gs16")) 
		(scatter y1 ch_d if iso3n==44, msymbol(O) mlcolor("gs16") mlw(1) mfcolor("gs16") msize(8))

        (scatteri `line4' , recast(line) lw(0.75) lc("gs16"))
        (scatteri `line3' , recast(line) lw(0.75) lc("gs0"))
		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(6) xsize(18)
	
		xlabel(-10 0 20 40 60, notick labsize(8) nogrid labcolor(gs0))
		xscale(noline range(-50(5)95)) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(none
		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(reverse noline range(1(1)4))

        text(1 -20 "Barbados", place(w) size(8) color("gs4") just(center) margin(l=2 r=2 t=4 b=2))
        text(2 -20 "Jamaica", place(w) size(8) color("gs4") just(center) margin(l=2 r=2 t=4 b=2))
        text(3 -20 "Antigua & Barbuda", place(w) size(8) color("gs4") just(center) margin(l=2 r=2 t=4 b=2))
        text(4 -20 "Bahamas", place(w) size(8) color("gs16") just(center) margin(l=2 r=2 t=4 b=2))

		/// Percentage 4
        text(0.9 43 "28%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(1.9 45 "32%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(2.9 74 "55%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(off) 

		name(partition_ATG)
	;
#delimit cr



** FULL GRAPHIC
#delimit ;
	graph twoway 
		/// Boxes around metrics
		/// (scatteri `box1'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))
		/// (scatteri `box2'  , recast(area) lw(0.2) lc("gs13") fc("gs14") lp("l"))

		///epi change
		(rbar zero ch_epi y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`blu1'")) 
		/// Change in Population Age
		(rbar basepop addage y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`ora1'")) 
		/// Change in Population Size
		(rbar addage addpop y1 if iso3n==52, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`pur1'")) 
		/// Overall Change point
		(scatter y1 ch_d if iso3n==52, msymbol(O) mlcolor(gs0) mlw(1) mfcolor(gs16%90) msize(8))

		/// JAMAICA
		(rbar zero ch_epi y1 if iso3n==388, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`blu1'")) 
		(rbar basepop addage y1 if iso3n==388, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`ora1'")) 
		(rbar addage addpop y1 if iso3n==388, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`pur1'")) 
		(scatter y1 ch_d if iso3n==388, msymbol(O) mlcolor(gs0) mlw(1) mfcolor(gs16%90) msize(8))

		/// ANTIGUA & BARBUDA
		(rbar zero ch_epi y1 if iso3n==28, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`blu1'")) 
		(rbar basepop addage y1 if iso3n==28, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`ora1'")) 
		(rbar addage addpop y1 if iso3n==28, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`pur1'")) 
		(scatter y1 ch_d if iso3n==28, msymbol(O) mlcolor(gs0) mlw(1) mfcolor(gs16%90) msize(8))

		/// BAHAMAS
		(rbar zero ch_epi y1 if iso3n==44, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`blu1'")) 
		(rbar basepop addage y1 if iso3n==44, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`ora1'")) 
		(rbar addage addpop y1 if iso3n==44, horizontal barwidth(.75)  lc("gs8") lw(0.1) fc("`pur1'")) 
		(scatter y1 ch_d if iso3n==44, msymbol(O) mlcolor(gs0) mlw(1) mfcolor(gs16%90) msize(8))

        (scatteri `line4' , recast(line) lw(0.75) lc("gs0"))
		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(6) xsize(18)
	
		xlabel(-10 0 20 40 60 80, notick labsize(8) nogrid labcolor(gs0))
		xscale(noline range(-50(5)95)) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(none
		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(reverse noline range(1(1)4))

        text(1 -20 "Barbados", place(w) size(8) color("gs4") just(center) margin(l=2 r=2 t=4 b=2))
        text(2 -20 "Jamaica", place(w) size(8) color("gs4") just(center) margin(l=2 r=2 t=4 b=2))
        text(3 -20 "Antigua & Barbuda", place(w) size(8) color("gs4") just(center) margin(l=2 r=2 t=4 b=2))
        text(4 -20 "Bahamas", place(w) size(8) color("gs4") just(center) margin(l=2 r=2 t=4 b=2))

		/// Percentage 4
        text(0.9 43 "28%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(1.9 45 "32%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(2.9 74 "55%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(3.9 86 "75%", place(w) size(7) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(off order(7 3 4 5) keygap(2) rowgap(2) linegap(0.75)
		label(3 "Change due to age-" "specific mortality rates")  
		label(4 "Change due to" "population aging") 
		label(5 "Change due to" "population growth") 
		label(7 "Change in deaths") 
		cols(2) position(6) size(2.5) symysize(3) color(gs8)
		) 
		name(partition_ALL)
	;
#delimit cr

