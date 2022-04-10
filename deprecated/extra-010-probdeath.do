** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    extra-010-probdeath.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-Apr-2021
    //  algorithm task			    Summary graphic of MR change between 2000 and 2019

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
    log using "`logpath'\extra-010-probdeath", replace
** HEADER -----------------------------------------------------

** -----------------------------------------------------
** TEST CALCULATION USING AUSTRIA 2014
** -----------------------------------------------------
        input age deaths pop
        1   86      577713
        2   140     544966
        3   339     618886
        4   719     709478
        5   1360    682921
        6   1980    569842
        7   2939    471089
        8   4248    422748
        end

        ** (y5mx) 5-year age-specific mortality rates
        ** (y5qx) probability of death in each 5-year age group
        gen y5mx = deaths/pop 
        gen y5qx_t1 = (y5mx * 5) / (1 + y5mx)
        gen y5qx = 1 - y5qx_t1
        format y5mx y5qx %15.9fc

        ** Calculate product
        keep age y5qx 
        gen k = 1 
        reshape wide y5qx, i(k) j(age)

        ** Unconditional prob dying between 30 (age=7) and 69 (age=14)
        egen stat1 = rprod(y5qx1 y5qx2 y5qx3 y5qx4 y5qx5 y5qx6 y5qx7 y5qx8)
        gen q7030 = (1 - stat1) * 100



** -----------------------------------------------------
** AMERICAS 2019
** -----------------------------------------------------
** UNCONDITIONAL PROBABILITY OF DEATH 
**      Could repeat this for subregions or for 
**      individual countries by
**      extracting dataset from appropriate 
**      chap2 preparation DO file
** -----------------------------------------------------

** ---------------------------------------
** DEATHS by AGE
** WOMEN AND MEN COMBINED
** ---------------------------------------

** THE AMERICAS
** DATASETS FROM: 
**      chap2-000a-mr-region-groups.do
**      chap2-000a-mr-region.do
tempfile t1 americas1 americas2
use "`datapath'\from-who\chap2_equiplot_mr_byage_groupeddeath", clear
    keep if who_region==2 & year>=2015
    ** CVD (400) / Cancer (500) / CRD (600) / Diabetes (700)
    keep if ghecause==400 | ghecause==500 | ghecause==600 | ghecause==700
    drop who_region
    rename dths deaths
    save `americas1' , replace

** THE SUBREGIONS
** DATASETS FROM: 
**      chap2-000a-mr-subregion-groups.do
**      chap2-000a-mr-subregion.do
tempfile t1 subregions1 
use "`datapath'\from-who\chap3_byage_subregion_groups_both", clear
    keep if year>=2015
    ** CVD (400) / Cancer (500) / CRD (600) / Diabetes (700)
    keep if ghecause==400 | ghecause==500 | ghecause==600 | ghecause==700
    rename dths deaths
    save `subregions1' , replace
use `americas1'

** Conbine and collapse
append using `subregions1'
replace paho_subregion = 10 if paho_subregion == .
label define paho_subregion_ 10 "Americas", add modify
label values paho_subregion paho_subregion_
collapse (sum) deaths pop, by(paho_subregion year ghecause age18 agroup)
sort ghecause age18
save `t1', replace

** Unconditional probability of dying between age30 and age69
gen f30t69 = 0
replace f30t69 = 1 if age18>=7 & age18<=14
label var f30t69 "Age groups 30 to 69"

** (y5mx) 5-year age-specific mortality rates
** (y5qx) probability of death in each 5-year age group
gen y5mx = deaths/pop 
gen y5qx_t1 = (y5mx * 5) / (1 + y5mx)
gen y5qx = 1 - y5qx_t1
format y5mx y5qx %15.9fc

** Calculate product
keep ghecause age y5qx year paho_subregion
rename age18 age 
reshape wide y5qx, i(ghecause year paho_subregion) j(age)

** Unconditional prob dying between 30 (age=7) and 69 (age=14)
egen stat2 = rprod(y5qx7 y5qx8 y5qx9 y5qx10 y5qx11 y5qx12 y5qx13 y5qx14)
gen q70_30 = (1 - stat2) * 100

format q* %9.3fc
keep paho_subregion year ghecause q*
order paho_subregion year ghecause q*
sort paho_subregion ghecause year

** Initial value by SUBREGION and GHECAUSE
bysort paho_subregion ghecause : gen f1= q70_30 if _n==1
bysort paho_subregion ghecause : egen f= min(f1)
drop f1
** Final value by SUBREGION and GHECAUSE
bysort paho_subregion ghecause : gen l1= q70_30 if _n==5
bysort paho_subregion ghecause : egen l= min(l1)
drop l1

** Diff
gen adiff = l - f
gen pdiff = ( (l - f) / f) * 100
gen apdiff = pdiff / 4

** Single value for each subregion/cause combination
egen yaxis = group(paho_subregion ghecause)
keep if yaxis[_n]!=yaxis[_n+1]

replace yaxis = yaxis+1 if paho_subregion==2
replace yaxis = yaxis+2 if paho_subregion==3
replace yaxis = yaxis+3 if paho_subregion==4
replace yaxis = yaxis+4 if paho_subregion==5
replace yaxis = yaxis+5 if paho_subregion==6
replace yaxis = yaxis+6 if paho_subregion==7
replace yaxis = yaxis+7 if paho_subregion==8
replace yaxis = yaxis+8 if paho_subregion==9
replace yaxis = yaxis+9 if paho_subregion==10

** -----------------------------------------------------
** GRAPHICS COLOR SCHEME
** -----------------------------------------------------
    colorpalette ptol, rainbow n(12)  nograph
    local list r(p) 
    ** Mortality Rate
    local mrate `r(p1)'
    ** DALY
    local daly `r(p4)'
    ** Improve and worsen
    local improve `r(p7)'
    local worsen `r(p12)'

    ** generate a local for the ColorBrewer color scheme
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
    ** Blue 
    local blu1 `r(p1)'
    local blu2 `r(p2)'
    ** Red
    local red1 `r(p7)'
    local red2 `r(p8)'
    ** Gray
    local gry1 `r(p15)'
    local gry2 `r(p16)'

** -----------------------------------------------------
** GRAPHIC
** -----------------------------------------------------
** Change in RATE between 2000 and 2019
** -----------------------------------------------------

/// ** Create graphics order according to SIZE OF MORT.RATE CHANGE
/// sort mr_ac
/// gen yorder = _n
/// decode cod, gen(codname)
/// labmask yorder, val(codname)
/// order yorder, after(cod) 
/// gen xlocation1 = -40
/// gen xlocation2 = -45
/// 
/// ** Integer absolute change
/// gen mr_aci = round(mr_ac, 1) 
/// replace mr_aci = round(mr_ac, 0.1) if mr_ac>-1 & mr_ac<1 
/// 
/// ** Rank importance by MR in 2019
/// gsort -mr2019 
/// gen rank = _n
/// order rank, after(yorder)
/// 
** Negative change
gen origin1 = -0.1
gen apdiff1 = apdiff - 0.1 if apdiff<0
 
** Positive change
gen origin2 = 0.1
gen apdiff2 = apdiff + 0.1 if apdiff>=0

/// local line1 29 0 1 0
/// local line2 20.5 -40 20.5 0
/// local line3 29.5 -60 29.5 -40
/// ** Triangles & associated text
/// local outer1 15 -35 20 -32 15 -29 15 -35
/// local outer2 26 -35 21 -32 26 -29 26 -35
/// bysort mr_change : egen schange1 = sum(mr_ac)
/// gen schange2 = abs(int(schange1)) 
/// egen schange3 = max(schange2)
/// global sch_fewer = schange3
/// egen schange4 = min(schange2)
/// global sch_more = schange4

#delimit ;  
	gr twoway 
		/// CVD
        (rbar origin1 apdiff1 yaxis if apdiff< 0 & ghecause==400, horizontal barw(0.6) fcol("`cvd1'") lcol("`cvd1'") lw(0.1))           
        (rbar origin2 apdiff2 yaxis if apdiff>=0 & ghecause==400, horizontal barw(0.6) fcol("`cvd2'") lcol("`cvd2'") lw(0.1))           
		/// Cancer
        (rbar origin1 apdiff1 yaxis if apdiff< 0 & ghecause==500, horizontal barw(0.6) fcol("`can1'") lcol("`can1'") lw(0.1))           
        (rbar origin2 apdiff2 yaxis if apdiff>=0 & ghecause==500, horizontal barw(0.6) fcol("`can2'") lcol("`can2'") lw(0.1))           
		/// Respiratory
        (rbar origin1 apdiff1 yaxis if apdiff< 0 & ghecause==600, horizontal barw(0.6) fcol("`crd1'") lcol("`crd1'") lw(0.1))           
        (rbar origin2 apdiff2 yaxis if apdiff>=0 & ghecause==600, horizontal barw(0.6) fcol("`crd2'") lcol("`crd2'") lw(0.1))           
		/// Diabetes
        (rbar origin1 apdiff1 yaxis if apdiff< 0 & ghecause==700, horizontal barw(0.6) fcol("`dia1'") lcol("`dia1'") lw(0.1))           
        (rbar origin2 apdiff2 yaxis if apdiff>=0 & ghecause==700, horizontal barw(0.6) fcol("`dia2'") lcol("`dia2'") lw(0.1))           

        ///(sc yorder xlocation1, msymbol(i) mlabel(mr_aci) mlabsize(2.5) mlabcol(gs8) mlabp(0))
        /// (scatteri `line1' , recast(line) lw(0.2) lc("`gry1'%50") fc("`gry1'%50") lp("-") )
        /// (scatteri `line2' , recast(line) lw(0.2) lc("`gry2'%25") fc("`gry2'%25") lp("l") )
        /// (scatteri -0.5 -25 "Absolute change (2000 to 2019)" , msymbol(i) mlabpos(0) mlabcol(gs8) mlabsize(3) mlabangle(0))
        /// (scatteri `outer1' , recast(area) lw(none) lc("`improve'%25") fc("`improve'%25")  )
        /// (scatteri `outer2' , recast(area) lw(none) lc("`worsen'%25") fc("`worsen'%25")  )
            ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(16) xsize(8)

			xlab(, 
            notick labs(2.5) tlc(gs0) labc(gs8) notick nogrid glc(gs16))
			xscale(noline ) 
			xtitle("", size(2) color(gs0) margin(l=0 r=0 t=0 b=0)) 
			
			ylab(, valuelabel
			labc(gs8) labs(2.5) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(2))
			yscale(reverse noline lw(vthin) ) 
			ytitle("", size(2) margin(l=0 r=0 t=0 b=0)) 

            ///text(17 -30 "$sch_fewer fewer deaths" "per 100,000", place(e) size(2.5) color("`improve'%85") just(center) margin(l=2 r=2 t=2 b=2))
            ///text(23 -30 "$sch_more more deaths" "per 100,000", place(e) size(2.5) color("`worsen'%85") just(center) margin(l=2 r=2 t=2 b=2))

            ///text(31 -64 "Abbreviations: IHD=Ischemic Heart Disease, COPD=Chronic Obstructive Pulmonary Disease", place(e) size(2) color(gs8) ) 
            ///text(31.75 -54 "RHD=Rheumatic Heart Disease, IPV=Interpersonal Violence, HHD=Hypertensive Heart Disease", place(e) size(2) color(gs8) ) 

            legend(off)
			name(q3070)
			;
#delimit cr	

