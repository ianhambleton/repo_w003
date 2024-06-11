** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-life-080-regression.do
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
    log using "`logpath'\chap1-life-080-regression", replace
** HEADER -----------------------------------------------------

** LIFE EXPECTANCY STATISTICS for CHAPTER ONE

** LOAD THE FULL LIFE TABLE DATASET 
use "`datapath'\from-who\lifetables\who-lifetable-2019-all", clear
keep if ghocode==35
keep if agroup==1 | agroup==14 
** APPEND the HALE regional dataset 
append using "`datapath'\from-who\lifetables\who-hale-2019-country"
label define ghocode_ 100 "hale",modify 
label values ghocode ghocode_ 
keep if year==2000 | year==2019

** Drop the major regions
drop if country==""
keep if year==2019
keep if sex==3
keep if agroup==1
drop year sex agroup

** Fill-in the dataset to attach WB region to HALE data
gsort -country ghocode
gen cfull = cname 
replace cfull = cfull[_n-1] if cfull=="" & cfull[_n-1]!=""
drop cname 
rename cfull cname 
gen wbfull = wbregion 
replace wbfull = wbfull[_n-1] if wbfull=="" & wbfull[_n-1]!=""
drop wbregion 
rename wbfull wbregion 

** Create WB regions 
gen wb = . 
replace wb = 1 if wbregion == "WB_LI"
replace wb = 2 if wbregion == "WB_LMI"
replace wb = 3 if wbregion == "WB_UMI"
replace wb = 4 if wbregion == "WB_HI"
label define wb_ 1 "low" 2 "low-middle" 3 "upper-middle" 4 "high",modify 
label values wb wb_ 
drop wbregion 

** Create PAHO subregions
** (1) North America        USA, CAN
** (2) Southern Cone        ARG, CHL, PRY, URY
** (3) Central America      CRI, SLV, GTM, HND, NIC, PAN
** (4) Latin Caribbean      CUB, DOM, HTI
** (5) Andean               BOL, COL, ECU, PER, VEN
** (6) non-latin Caribbean  ATG, BHS, BLZ, BRB, GRD, GUY, JAM, LCA, SUR, TTO, VCT
** (7) Brazil               BRA
** (8) Mexico               MEX
gen sr = . 
replace sr = 1 if country=="USA" | country=="CAN"
replace sr = 2 if country=="ARG" | country=="CHL" | country=="PRY" | country=="URY"
replace sr = 3 if country=="CRI" | country=="SLV" | country=="GTM" | country=="HND" | country=="NIC" | country=="PAN"
replace sr = 4 if country=="BOL" | country=="COL" | country=="ECU" | country=="PER" | country=="VEN"
replace sr = 5 if country=="CUB" | country=="DOM" | country=="HTI" 
replace sr = 6 if country=="ATG" | country=="BHS" | country=="BLZ" | country=="BRB" | country=="GRD" | country=="GUY" | country=="JAM" | country=="LCA" | country=="SUR" | country=="TTO" | country=="VCT"
replace sr = 7 if country=="BRA"
replace sr = 8 if country=="MEX"


#delimit ; 
label define sr_    1 "north america"
                    2 "southern cone"
                    3 "central america"
                    4 "andean" 
                    5 "latin caribbean"
                    6 "non-latin caribbean"
                    7 "brazil"
                    8 "mexico", modify; 
#delimit cr 
label values sr sr_ 

** Save Main dataset
tempfile main main2 main3 main4 main5
sort country 
save `main', replace 

** Add further ecological data 

** ---------------------------------------------------------------
** FROM WHO GHO: Current health expenditure as a percentage of GDP
** Indicator Code: GHED_CHEGDP_SHA2011 
** ---------------------------------------------------------------
import excel using "`datapath'\from-gho\health-expenditure-gho", clear first
drop IndicatorCode Indicator ValueType ParentLocation Locationtype Location Periodtype 
rename ParentLocationCode region 
keep if region=="AMR"
rename SpatialDimValueCode country 
rename Period year 
drop Dim* Data* Fact* Language Date* Is*
rename Value healthexp 
keep if year==2018
drop year
sort country 
tempfile healthexpenditure
save `healthexpenditure', replace 
use `main', clear
merge m:1 country using `healthexpenditure'
drop if _merge==2 
drop _merge 
save `main2', replace 

** ---------------------------------------------------------------
** FROM WHO GHE: Population size 
** ---------------------------------------------------------------
use "`datapath'\from-who\who-ghe-deaths-001-americas", clear
rename iso3c country 
drop if age<0 
keep if year==2019 & ghecause==0
collapse (sum) pop , by(country)
tempfile pop 
save `pop', replace 
use `main2', clear
merge m:1 country using `pop'
drop _merge 
save `main3', replace 


** ---------------------------------------------------------------
** Per capita GDP. From WB Open Data 
** INDICATOR: NY.GDP.PCAP.CD
** ---------------------------------------------------------------
wbopendata, language(en - English) indicator(NY.GDP.PCAP.CD) clear latest
replace yr2018 = yr2014 if yr2018==. & countrycode=="VEN" 
keep yr2018 countrycode 
rename countrycode country 
tempfile gdp 
save `gdp', replace 
use `main3', clear 
merge m:1 country using `gdp'
rename yr2018 gdp2018 
gen gdp1k = gdp2018/1000
drop if _merge==2 
drop _merge
save `main4', replace 



** ---------------------------------------------------------------
** FROM WHO GHO: Number of doctors per 10000
** Indicator Code: HWF_002
** ---------------------------------------------------------------
import excel using "`datapath'\from-gho\doctors-per-10000", clear first
keep if GHOCODE=="HWF_0002" 
keep YEARCODE COUNTRYCODE REGIONCODE Numeric 
rename YEARCODE dyear 
rename COUNTRYCODE country 
rename Numeric doctor 
rename REGIONCODE region 
keep if region=="AMR"
sort country dyear 
keep if country!=country[_n+1]
drop region
tempfile ndoctor
save `ndoctor', replace 
use `main4', clear
merge m:1 country using `ndoctor'
drop if _merge==2 
drop _merge 
save `main5', replace 




** ---------------------------------------------------------------
** FROM WHO GHO: Number of nursing and midwifery staff per 10000
** Indicator Code: HWF_0007
** ---------------------------------------------------------------
import excel using "`datapath'\from-gho\nurses-per-10000", clear first
keep if GHOCODE=="HWF_0007" 
keep YEARCODE COUNTRYCODE REGIONCODE Numeric 
rename YEARCODE nyear 
rename COUNTRYCODE country 
rename Numeric nurse 
rename REGIONCODE region 
keep if region=="AMR"
sort country nyear 
keep if country!=country[_n+1]
drop region
tempfile nnurse
save `nnurse', replace 
use `main5', clear
merge m:1 country using `nnurse'
drop if _merge==2 
drop _merge 

** Doctors per 10000
gen drate = (doctor/pop) * 10000
gen nrate = (nurse/pop) * 10000
gen hrhrate = ((doctor + nurse)/pop) * 10000
gen drate10 = drate/10
gen nrate10 = nrate/10
gen hrhrate10 = hrhrate/10

gen pop10k = pop/10000

** Regression effects 
regress metric ib4.wb if ghocode==35
regress metric gdp1k if ghocode==35
regress metric healthexp if ghocode==35
regress metric drate10 if ghocode==35
regress metric nrate10 if ghocode==35
regress metric hrhrate10 if ghocode==35
regress metric healthexp ib4.wb drate10 nrate10 if ghocode==35
regress metric healthexp ib4.wb hrhrate10 if ghocode==35


** Outer boxes
local outer1 40 0.6 90 0.6 90 2.4 40 2.4  40 0.6 
local outer2 40 2.6 90 2.6 90 4.4 40 4.4  40 2.6 

** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(8)  nograph
local list r(p) 
** (LE --> sex = 1)
forval x = 1(1)8 {
    local le`x' `r(p`x')'
}


** LE only
keep if ghocode==35

** HRH RATE on RHS of graph
keep region ghocode metric country cname wb sr healthexp hrhrate

** Z-SCORES
sum healthexp 
gen zexp = (healthexp - r(mean)) / r(sd)
sum hrh 
gen zhrh = (hrhrate - r(mean)) / r(sd)
gen zhrh5 = zhrh + 4.1
gen zexp5 = zexp + 4.1

regress metric zexp if ghocode==35
predict zexp_xb, xb
predict zexp_se, stdp
gen zexp_lo = zexp_xb - 1.96 * zexp_se
gen zexp_hi = zexp_xb + 1.96 * zexp_se

regress metric zhrh if ghocode==35
predict zhrh_xb, xb
predict zhrh_se, stdp
gen zhrh_lo = zhrh_xb - 1.96 * zhrh_se
gen zhrh_hi = zhrh_xb + 1.96 * zhrh_se


** (1) GRAPH BY PAHO SUBREGION
#delimit ;
	gr twoway 
		/// outer boxes 
        /// (scatteri `outer1' , recast(area) lw(0.2) lc(gs10) fc(none)  )
        /// (scatteri `outer2' , recast(area) lw(0.2) lc(gs10) fc(none)  )

		/// country values
        
        /// Health Expenditure
        (rarea zexp_lo zexp_hi zexp5     if ghocode==35 , sort fc("gs8%25") lw(none))
        (line zexp_xb zexp5              if ghocode==35 , sort lc("gs8") lw(0.25) lp("-"))
        (sc metric zexp5                 if sr==1 & ghocode==35 , msize(4) m(o) mlc("`le1'%75") mfc("`le1'%75") mlw(0.1))
        (sc metric zexp5                 if sr==2 & ghocode==35 , msize(4) m(o) mlc("`le2'%75") mfc("`le2'%75") mlw(0.1))
        (sc metric zexp5                 if sr==3 & ghocode==35 , msize(4) m(o) mlc("`le3'%75") mfc("`le3'%75") mlw(0.1))
        (sc metric zexp5                 if sr==4 & ghocode==35 , msize(4) m(o) mlc("`le4'%75") mfc("`le4'%75") mlw(0.1))
        (sc metric zexp5                 if sr==5 & ghocode==35 , msize(4) m(o) mlc("`le5'%75") mfc("`le5'%75") mlw(0.1))
        (sc metric zexp5                 if sr==6 & ghocode==35 , msize(4) m(o) mlc("`le6'%75") mfc("`le6'%75") mlw(0.1))
        (sc metric zexp5                 if sr==7 & ghocode==35 , msize(4) m(o) mlc("`le7'%75") mfc("`le7'%75") mlw(0.1))
        (sc metric zexp5                 if sr==8 & ghocode==35 , msize(4) m(o) mlc("`le8'%75") mfc("`le8'%75") mlw(0.1))

        /// HRH staffing
        (rarea zhrh_lo zhrh_hi zhrh     if ghocode==35 , sort fc("gs8%25") lw(none))
        (line zhrh_xb zhrh              if ghocode==35 , sort lc("gs8") lw(0.25) lp("-"))
        (sc metric zhrh                 if sr==1 & ghocode==35 , msize(4) m(o) mlc("`le1'%75") mfc("`le1'%75") mlw(0.1))
        (sc metric zhrh                 if sr==2 & ghocode==35 , msize(4) m(o) mlc("`le2'%75") mfc("`le2'%75") mlw(0.1))
        (sc metric zhrh                 if sr==3 & ghocode==35 , msize(4) m(o) mlc("`le3'%75") mfc("`le3'%75") mlw(0.1))
        (sc metric zhrh                 if sr==4 & ghocode==35 , msize(4) m(o) mlc("`le4'%75") mfc("`le4'%75") mlw(0.1))
        (sc metric zhrh                 if sr==5 & ghocode==35 , msize(4) m(o) mlc("`le5'%75") mfc("`le5'%75") mlw(0.1))
        (sc metric zhrh                 if sr==6 & ghocode==35 , msize(4) m(o) mlc("`le6'%75") mfc("`le6'%75") mlw(0.1))
        (sc metric zhrh                 if sr==7 & ghocode==35 , msize(4) m(o) mlc("`le7'%75") mfc("`le7'%75") mlw(0.1))
        (sc metric zhrh                 if sr==8 & ghocode==35 , msize(4) m(o) mlc("`le8'%75") mfc("`le8'%75") mlw(0.1))

		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=3 t=5)) 
			ysize(6) xsize(15)

			xlab(none, notick labs(2) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline ) 
			xtitle("", size(5) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(50(10)90,
			valuelabel labc(gs8) labs(4) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs12)) 
			ytitle("Life expectancy at birth (yrs)", size(4) color(gs8) margin(l=2 r=2 t=2 b=2)) 

			/// X-Axis text
            text(90 2.8 "Health expenditure (% GDP)",  place(e) size(4.25) color(gs8))
            text(90 -1.1 "Doctors and nurses (per 10 000 pop.)",  place(e) size(4.25) color(gs8))

			legend(nobox size(4) position(5) ring(0) bc(gs8) color(gs8) bm(t=1 b=4 l=5 r=0) colf cols(2)
			region(fcolor(gs16) lc(gs16) lw(vthin) margin(l=0 r=0 t=0 b=0)) 
			order(3 4 5 6 7 8 9 10) 
			lab(3 "North America") 
			lab(4 "Southern Cone")
            lab(5 "Central America")
            lab(6 "Andean")
            lab(7 "Latin Caribbean")
            lab(8 "Non-Latin Caribbean")
            lab(9 "Brazil")
            lab(10 "Mexico")
			)
			name(subregion)
            saving("`outputpath'\reports\graphics\fig1-4-subregion.pdf", replace)
			;
#delimit cr	

** Export to Vector Graphic
graph export "`outputpath'\reports\2024-edits\graphics\fig4a.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig4a.pdf", replace


** (1) GRAPH BY WORLD BANK INCOME GROUPS
#delimit ;
	gr twoway 
		/// outer boxes 
        /// (scatteri `outer1' , recast(area) lw(0.2) lc(gs10) fc(none)  )
        /// (scatteri `outer2' , recast(area) lw(0.2) lc(gs10) fc(none)  )

		/// country values
        
        /// Health Expenditure
        (rarea zexp_lo zexp_hi zexp5     if ghocode==35 , sort fc("gs8%25") lw(none))
        (line zexp_xb zexp5              if ghocode==35 , sort lc("gs8") lw(0.25) lp("-"))
        (sc metric zexp5                 if wb==1 & ghocode==35 , msize(4) m(o) mlc("`le1'%75") mfc("`le1'%75") mlw(0.1))
        (sc metric zexp5                 if wb==2 & ghocode==35 , msize(4) m(o) mlc("`le3'%75") mfc("`le3'%75") mlw(0.1))
        (sc metric zexp5                 if wb==3 & ghocode==35 , msize(4) m(o) mlc("`le5'%75") mfc("`le5'%75") mlw(0.1))
        (sc metric zexp5                 if wb==4 & ghocode==35 , msize(4) m(o) mlc("`le7'%75") mfc("`le7'%75") mlw(0.1))
        /// (sc metric zexp5                 if wb==5 & ghocode==35 , msize(4) m(o) mlc("`le5'%75") mfc("`le5'%75") mlw(0.1))
        /// (sc metric zexp5                 if wb==6 & ghocode==35 , msize(4) m(o) mlc("`le6'%75") mfc("`le6'%75") mlw(0.1))
        /// (sc metric zexp5                 if wb==7 & ghocode==35 , msize(4) m(o) mlc("`le7'%75") mfc("`le7'%75") mlw(0.1))
        /// (sc metric zexp5                 if wb==8 & ghocode==35 , msize(4) m(o) mlc("`le8'%75") mfc("`le8'%75") mlw(0.1))

        /// HRH staffing
        (rarea zhrh_lo zhrh_hi zhrh     if ghocode==35 , sort fc("gs8%25") lw(none))
        (line zhrh_xb zhrh              if ghocode==35 , sort lc("gs8") lw(0.25) lp("-"))
        (sc metric zhrh                 if wb==1 & ghocode==35 , msize(4) m(o) mlc("`le1'%75") mfc("`le1'%75") mlw(0.1))
        (sc metric zhrh                 if wb==2 & ghocode==35 , msize(4) m(o) mlc("`le3'%75") mfc("`le3'%75") mlw(0.1))
        (sc metric zhrh                 if wb==3 & ghocode==35 , msize(4) m(o) mlc("`le5'%75") mfc("`le5'%75") mlw(0.1))
        (sc metric zhrh                 if wb==4 & ghocode==35 , msize(4) m(o) mlc("`le7'%75") mfc("`le7'%75") mlw(0.1))
        /// (sc metric zhrh                 if wb==5 & ghocode==35 , msize(4) m(o) mlc("`le5'%75") mfc("`le5'%75") mlw(0.1))
        /// (sc metric zhrh                 if wb==6 & ghocode==35 , msize(4) m(o) mlc("`le6'%75") mfc("`le6'%75") mlw(0.1))
        /// (sc metric zhrh                 if wb==7 & ghocode==35 , msize(4) m(o) mlc("`le7'%75") mfc("`le7'%75") mlw(0.1))
        /// (sc metric zhrh                 if wb==8 & ghocode==35 , msize(4) m(o) mlc("`le8'%75") mfc("`le8'%75") mlw(0.1))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=3 t=5)) 
			ysize(6) xsize(15)

			xlab(none, notick labs(2) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline ) 
			xtitle("", size(5) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(50(10)90,
			valuelabel labc(gs8) labs(4) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin) lc(gs12)) 
			ytitle("Life expectancy at birth (yrs)", size(4) color(gs8) margin(l=2 r=2 t=2 b=2)) 

			/// X-Axis text
            text(90 2.8 "Health expenditure (% GDP)",  place(e) size(4.25) color(gs8))
            text(90 -1.1 "Doctors and nurses (per 10 000 pop.)",  place(e) size(4.25) color(gs8))

			legend( size(4) position(5) ring(0) bc(gs8) color(gs8) bm(t=1 b=4 l=5 r=0) colf cols(2)
			region(fcolor(gs16) lc(gs16) lw(vthin) margin(l=0 r=0 t=0 b=0)) 
			order(3 4 5 6) 
			lab(3 "Low income") 
			lab(4 "Low-middle income")
            lab(5 "High-middle income")
            lab(6 "High income")
			)
			name(worldbank)
            saving("`outputpath'\reports\graphics\fig1-4-worldbank.pdf", replace)
			;
#delimit cr	

** Export to Vector Graphic
graph export "`outputpath'\reports\2024-edits\graphics\fig4b.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig4b.pdf", replace


** Figure 1.4
#delimit ;
gr combine  "`outputpath'\reports\graphics\fig1-4-subregion.pdf" 
            "`outputpath'\reports\graphics\fig1-4-worldbank.pdf"
            ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=3 t=5)) 

            rows(2) cols(1)
            iscale(*0.7)
            ycommon
            ;
#delimit cr

** Export to Vector Graphic
** DEC 22nd, 2022
** graph export "`outputpath'\reports\2024-edits\graphics\fig4.svg", replace
** graph export "`outputpath'\reports\2024-edits\graphics\fig4.pdf", replace
