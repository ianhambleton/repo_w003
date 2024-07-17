** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-500-diabetes-stats.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Preparing Diabetes mortality and DALY statistics

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
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap2-500-diabetes-stats", replace
** HEADER -----------------------------------------------------


** Load primary deaths dataset
use "`datapath'\from-who\chap2_000_adjusted", clear
** Restrict to Americas ONLY
keep if region==2000 & sex==3
keep dths daly year ghecause 
reshape wide dths daly, i(year) j(ghecause)

** CODES
**    31  "Diabetes"

** DIABETES as percentage of all deaths
gen p31 = (dths31/dths100)*100
gen ddrat31 = daly31 / dths31
gen ddrat_all = daly100 / dths100





**-----------------------------------------------------------
** Diabetes (31)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_adjusted", clear
    drop yll yllr yld yldr 
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 31 & region==2000
    drop pop*
    ** 1=men 2=women 3=both
    reshape wide mrate dths drate daly, i(year) j(sex)
    /// DEATHS
    gen mratio_rate = mrate1 / mrate2
    gen mdiff_rate = mrate1 - mrate2
    gen mdiff_count = dths1 - dths2 
    /// DALY
    gen dratio_rate = drate1 / drate2
    gen ddiff_rate = drate1 - drate2
    gen ddiff_count = daly1 - daly2 

    order year dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff* 
    format dths* daly* mrate* drate* mratio* mdiff* dratio* ddiff*   %12.2fc

    noi dis "DIABETES" 
    noi list year mrate1 mrate2 mrate3 mratio_rate mdiff_rate mdiff_count, noobs ab(20)
    noi list year drate1 drate2 drate3 dratio_rate ddiff_rate ddiff_count, noobs ab(20)
}




**-----------------------------------------------------------
** Diabetes (31)
** Percent Improvement
** Death excess (men vs women)
**-----------------------------------------------------------
qui {
    use "`datapath'\from-who\chap2_000_daly_adjusted", clear
    keep if ghecause == 31 & region==2000
    rename dalyr drate
    tempfile daly 
    save `daly', replace
    use "`datapath'\from-who\chap2_000_mr_adjusted", clear
    keep if ghecause == 31 & region==2000
    rename mortr mrate
    merge 1:1 year sex using `daly'
    drop _merge pop*
    ** 1=men 2=women 3=both
    reshape wide mrate drate dths daly, i(year) j(sex)
    order year mrate* drate* dths* daly* 
    ** Restrict to 2000 and 2019, and reshape to wide
    ** drop daly* dths* 
    keep if year==2000 | year==2019
    gen k=1
    reshape wide dths1 dths2 dths3 daly1 daly2 daly3 mrate1 mrate2 mrate3 drate1 drate2 drate3, i(k) j(year)
    order k mrate1* mrate2* mrate3* drate1* drate2* drate3* dths1* dths2* dths3* daly1* daly2* daly3*
    ** percentage improvement
    gen mperc1 = ((mrate12019 - mrate12000)/mrate12000) * 100
    gen mperc2 = ((mrate22019 - mrate22000)/mrate22000) * 100
    gen mperc3 = ((mrate32019 - mrate32000)/mrate32000) * 100
    gen dperc1 = ((drate12019 - drate12000)/drate12000) * 100
    gen dperc2 = ((drate22019 - drate22000)/drate22000) * 100
    gen dperc3 = ((drate32019 - drate32000)/drate32000) * 100
    format mperc1 mperc2 mperc3 dperc1 dperc2 dperc3 %9.1f
    ** death excess (women and men combined)
    gen dth_excess = dths12019-dths22019
    gen daly_excess = daly12019-daly22019
    format dths12019 dths22019 daly12019 daly22019 dth_excess daly_excess %12.0fc
    ** Transpose
    drop k
    xpose , clear varname format(%15.1fc)
    order _varname
    dis "ALL MENTAL HEALTH - Change between 2000 and 2019"
    noi list _varname v1, sep(6)
}


** Ratio of MORTALITY RATE: women to men
** FOR subregions and/or countries
**-----------------------------------------------------------
** Diabetes (31)
**-----------------------------------------------------------
    use "`datapath'\from-who\chap2_000_adjusted", clear
    drop yll yllr yld yldr 
    rename mortr mrate
    rename dalyr drate
    keep if ghecause == 31 
    keep if (region>=100 & region<=800) | region==2000
    drop pop* ghecause
    ** 1=men 2=women 3=both
    reshape wide mrate dths drate daly, i(year region) j(sex)
    sort paho_subregion year 
        /// DEATHS
    gen mratio_rate = mrate1 / mrate2
    gen dratio_rate = drate1 / drate2


** generate -locals- from the d3 qualitative-paired color scheme
colorpalette d3, 20 n(20) nograph
local list r(p) 
** CVD
local cvd1 `r(p9)'
local cvd2 `r(p10)'
** Cancer 
local can1 `r(p1)'
local can2 `r(p2)'
** CRD
local crd1 `r(p5)'
local crd2 `r(p6)'
** Diabetes
local dia1 `r(p17)'
local dia2 `r(p18)'
** Mental Health
local men1 `r(p3)'
local men2 `r(p4)'
** External causes
local inj1 `r(p7)'
local inj2 `r(p8)'
** GENDER RATIO
local rat1 `r(p19)'
local rat2 `r(p20)'

** generate a local for the ColorBrewer color scheme
colorpalette ptol, rainbow n(6)  nograph
local list r(p) 
** Aqua (MEN --> sex = 2)
local men `r(p3)'
** Orange (Women --> sex = 1)
local women `r(p5)'

** Legend outer boundaries 
local outer1 695 2013 730 2013 730 2018 695 2018 695 2013
local outer2 635 2013 670 2013 670 2018 635 2018 635 2013
local outer3 575 2013 610 2013 610 2018 575 2018 575 2013

** Creating PANEL by shifting sub-regions along the x-axis
gen yr1 = . 
replace yr1 = year if region==100
replace yr1 = year + 21 if region==200
replace yr1 = year + 42 if region==300
replace yr1 = year + 63 if region==400
replace yr1 = year + 84 if region==500
replace yr1 = year + 105 if region==600
replace yr1 = year + 126 if region==700
replace yr1 = year + 147 if region==800
order year yr1 

** Gender equality 
gen equal1 = 1
gen equal2 = equal1 - 1

** Jitter deaths by a horizontal and vertical fraction to improve visual
gen mratio_rate2 = mratio_rate - 1
gen yr2 = yr1 + 0.2 

#delimit ;
	gr twoway 
		/// Areas for all regions
	    (rarea equal1 dratio_rate yr1 if region==100 , lw(none) color("`dia1'%45"))
	    (rarea equal1 dratio_rate yr1 if region==200 , lw(none) color("`dia1'%45"))
	    (rarea equal1 dratio_rate yr1 if region==300 , lw(none) color("`dia1'%45"))
	    (rarea equal1 dratio_rate yr1 if region==400 , lw(none) color("`dia1'%45"))
	    (rarea equal1 dratio_rate yr1 if region==500 , lw(none) color("`dia1'%45"))
	    (rarea equal1 dratio_rate yr1 if region==600 , lw(none) color("`dia1'%45"))
	    (rarea equal1 dratio_rate yr1 if region==700 , lw(none) color("`dia1'%45"))
	    (rarea equal1 dratio_rate yr1 if region==800 , lw(none) color("`dia1'%45"))


		/// MEN (1). COM. NORTH AMERICA.
        (line dratio_rate yr1 if region==100  , lw(0.2) lc("`dia1'%85") lp("l"))
        (line dratio_rate yr1 if region==200  , lw(0.2) lc("`dia1'%85") lp("l"))
        (line dratio_rate yr1 if region==300  , lw(0.2) lc("`dia1'%85") lp("l"))
        (line dratio_rate yr1 if region==400  , lw(0.2) lc("`dia1'%85") lp("l"))
        (line dratio_rate yr1 if region==500  , lw(0.2) lc("`dia1'%85") lp("l"))
        (line dratio_rate yr1 if region==600  , lw(0.2) lc("`dia1'%85") lp("l"))
        (line dratio_rate yr1 if region==700  , lw(0.2) lc("`dia1'%85") lp("l"))
        (line dratio_rate yr1 if region==800  , lw(0.2) lc("`dia1'%85") lp("l"))
        
        /// droplines
       (function y=1.5, lp("l") range(2000 2167) lc(gs12) dropline(2020 2041 2062 2083 2104 2125 2146 2167))

        /// Legend
        /// (function y=708, range(2035 2039) lc(gs10) lw(0.4))
        /// (function y=648, range(2035 2039) lp("-") lc(gs10) lw(0.4))
        /// (scatteri `outer1' , recast(area) lw(none) lc("`com'%35") fc("`com'%35")  )
        /// (scatteri `outer2' , recast(area) lw(none) lc("`ncd'%35") fc("`ncd'%35")  )
        /// (scatteri `outer3' , recast(area) lw(none) lc("`inj'%35") fc("`inj'%35")  )

		/// X-Axis lines
        (function y=0.5, range(2000 2019) lc(gs12) lw(0.2) lp("l"))
        (function y=0.5, range(2021 2040) lc(gs12) lw(0.2) lp("l"))
        (function y=0.5, range(2042 2061) lc(gs12) lw(0.2) lp("l"))
        (function y=0.5, range(2063 2082) lc(gs12) lw(0.2) lp("l"))
        (function y=0.5, range(2084 2103) lc(gs12) lw(0.2) lp("l"))
        (function y=0.5, range(2105 2124) lc(gs12) lw(0.2) lp("l"))
        (function y=0.5, range(2126 2145) lc(gs12) lw(0.2) lp("l"))
        (function y=0.5, range(2147 2166) lc(gs12) lw(0.2) lp("l"))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(5) xsize(15)

			xlab(none, 
			valuelabel labc(gs0) labs(3) notick nogrid glc(gs16) angle(45) format(%9.0f))
			xscale(noline lw(vthin)) 
			xtitle(" ", size(3) color(gs0) margin(l=1 r=1 t=1 b=1)) 
			
			ylab(0.5(0.5)1.5,
			valuelabel labc(gs8) labs(3) tlc(gs8) nogrid glc(gs16) angle(0) format(%9.1f))
			yscale(lw(vthin) lc(gs8) range(0.5(0.1)1.6) noextend) 
			ytitle("Gender ratio", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 
            ymtick(0.5(0.1)1.5)

            /// Region Titles 
            text(1.55 2010 "North" "America",       place(c) size(3) color(gs5))
            text(1.55 2031 "Central" "America",     place(c) size(3) color(gs5))
            text(1.55 2053 "Andean",                place(c) size(3) color(gs5))
            text(1.55 2074 "Southern" "Cone",       place(c) size(3) color(gs5))
            text(1.55 2095 "Latin" "Caribbean",     place(c) size(3) color(gs5))
            text(1.55 2116 "Non-Latin" "Caribbean", place(c) size(3) color(gs5))
            text(1.55 2137 "Brazil",                place(c) size(3) color(gs5))
            text(1.55 2158 "Mexico",                place(c) size(3) color(gs5))

            /// Legend Text
            /// text(708 2034 "Men",  place(w) size(3) color(gs8))   
            /// text(648 2034 "Women",  place(w) size(3) color(gs8))   
            /// text(712 2012 "Communicable",  place(w) size(3) color(gs8))   
            /// text(652 2012   "NCDs",  place(w) size(3) color(gs8))   
            /// text(592 2012   "Injuries",  place(w) size(3) color(gs8))   

			/// X-Axis text
            text(0.55 2000 "2000",  place(e) size(3) color(gs8))
            text(0.55 2019 "2019",  place(w) size(3) color(gs8))
            text(0.55 2021 "2000",  place(e) size(3) color(gs8))
            text(0.55 2040 "2019",  place(w) size(3) color(gs8))
            text(0.55 2042 "2000",  place(e) size(3) color(gs8))
            text(0.55 2061 "2019",  place(w) size(3) color(gs8))
            text(0.55 2063 "2000",  place(e) size(3) color(gs8))
            text(0.55 2082 "2019",  place(w) size(3) color(gs8))
            text(0.55 2084 "2000",  place(e) size(3) color(gs8))
            text(0.55 2103 "2019",  place(w) size(3) color(gs8))
            text(0.55 2105 "2000",  place(e) size(3) color(gs8))
            text(0.55 2124 "2019",  place(w) size(3) color(gs8))
            text(0.55 2126 "2000",  place(e) size(3) color(gs8))
            text(0.55 2145 "2019",  place(w) size(3) color(gs8))
            text(0.55 2147 "2000",  place(e) size(3) color(gs8))
            text(0.55 2166 "2019",  place(w) size(3) color(gs8))

			/// Text explaining the earthquake year in 2010 in the Latin caribbean
            /// text(370 2096 "Haitian earthquake" " " "Injury rate (men)" "977 per 100k" " " "Injury rate (women)" "614 per 100k",  place(c) size(2.5) color(gs10) just(right))

			legend(off)
			name(sexratio_panel)
			;
#delimit cr	

** Export to Vector Graphic
** DEC 22nd, 2022
graph export "`outputpath'\reports\2024-edits\graphics\fig19.svg", replace
graph export "`outputpath'\reports\2024-edits\graphics\fig19.pdf", replace


    ** Export data for FIGURE-19
    drop if region==2000
    keep year region dratio_rate  
    rename dratio_rate daly_rate_ratio 
    export excel "`outputpath'\reports\2024-edits\graphics\chap2_data.xlsx", sheet("figure-19", replace) first(var) keepcellfmt
