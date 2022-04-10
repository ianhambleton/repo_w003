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
collapse (sum) deaths pop, by(paho_subregion year age18 agroup)
sort age18
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
keep age y5qx year paho_subregion
rename age18 age 
reshape wide y5qx, i(year paho_subregion) j(age)

** Unconditional prob dying between 30 (age=7) and 69 (age=14)
egen stat2 = rprod(y5qx7 y5qx8 y5qx9 y5qx10 y5qx11 y5qx12 y5qx13 y5qx14)
gen q70_30 = (1 - stat2) * 100

format q* %9.3fc
keep paho_subregion year q*
order paho_subregion year q*
sort paho_subregion year

** Initial value by SUBREGION
bysort paho_subregion : gen f1= q70_30 if _n==1
bysort paho_subregion : egen f= min(f1)
drop f1
** Final value by SUBREGION
bysort paho_subregion : gen l1= q70_30 if _n==5
bysort paho_subregion : egen l= min(l1)
drop l1

** Diff
gen adiff = l - f
gen pdiff = ( (l - f) / f) * 100
gen apdiff = pdiff / 4

** Single value for each subregion/cause combination
egen yaxis = group(paho_subregion)
keep if yaxis[_n]!=yaxis[_n+1]

** -----------------------------------------------------
** GRAPHICS COLOR SCHEME
** -----------------------------------------------------
colorpalette RdYlBu , n(9) nogr
local list r(p) 
* Red / Orange / Yellow / Blue1 / Blue2
local q1 `r(p1)'
local q2 `r(p3)'
local q3 `r(p5)'
local q4 `r(p7)'
local q5 `r(p9)'

** -----------------------------------------------------
** GRAPHIC
** -----------------------------------------------------

** Split the bars into colors representing increasing improvement 
gen b1 = 0
replace b1 = 1 if apdiff<0
gen b2 = 0
replace b2 = 1 if apdiff<-0.5
gen b3 = 0
replace b3 = 1 if apdiff<-1
gen b4 = 0
replace b4 = 1 if apdiff<-1.5
gen apdiff1 = apdiff
gen apdiff2 = -1.5 
replace apdiff2 = apdiff if apdiff>-1.5
gen apdiff3 = -1
replace apdiff3 = apdiff if apdiff>-1
gen apdiff4 = -0.5
replace apdiff4 = apdiff if apdiff>-0.5

** The change between 2015 and 2019
/// gen ch = l - f
/// * largest change as 1
/// egen mch = min(ch) 
/// gen ch2 = (ch / mch) * 2
/// gen l2 = l-1.5
/// gen f2 = l2 + ch2
/// order ch ch2 f2 l2, after(l)
gen l2 = (l - 1.5)*1.5
gen f2 = (f - 1.5)*1.5
order f2 l2 , after(l)
replace f2 = 3.55 if paho_subregion==8

** Origin and extra lines
gen origin1 = 0
local line1 10 -0.25 0 -0.25
local line2 10 -0.5 0 -0.5
local line3 10 -0.75 0 -0.75
local line4 10 -1 0 -1
local line5 10 -1.25 0 -1.25
local line6 10 -1.5 0 -1.5
local line7 10.5 2.25 10.5 6.75
local line8 10.5 0 10.5 -2

#delimit ;  
	gr twoway 
		/// CVD
        (rbar origin1 apdiff1 yaxis if b4==1 , horizontal barw(0.6) fcol("`q5'") lcol("`q5'") lw(0.1))           
        (rbar origin1 apdiff2 yaxis if b3==1 , horizontal barw(0.6) fcol("`q4'") lcol("`q4'") lw(0.1))           
        (rbar origin1 apdiff3 yaxis if b2==1 , horizontal barw(0.6) fcol("`q2'") lcol("`q2'") lw(0.1))           
        (rbar origin1 apdiff4 yaxis if b1==1 , horizontal barw(0.6) fcol("`q1'") lcol("`q1'") lw(0.1))           

        /// Absolute change
        /// (rbar l2 f2 yaxis , horizontal barw(0.1) fcol("gs10") lcol("gs10") lw(0.1))
        /// (sc yaxis l2 , mc("gs10") msymbol(arrowf) msangle(90) msize(5))           
        (rbar l2 f2 yaxis , horizontal barw(0.1) fcol("gs10") lcol("gs10") lw(0.1))
        (sc yaxis l2 , mc("gs10") msymbol(arrowf) msangle(90) msize(5) lw(0.1))   

        ///(sc yorder xlocation1, msymbol(i) mlabel(mr_aci) mlabsize(2.5) mlabcol(gs8) mlabp(0))
        (scatteri `line1' , recast(line) lw(0.75) lc("gs16") fc("gs16") lp("l") )
        (scatteri `line2' , recast(line) lw(0.75) lc("gs16") fc("gs16") lp("l") )
        (scatteri `line3' , recast(line) lw(0.75) lc("gs16") fc("gs16") lp("l") )
        (scatteri `line4' , recast(line) lw(0.75) lc("gs16") fc("gs16") lp("l") )
        (scatteri `line5' , recast(line) lw(0.75) lc("gs16") fc("gs16") lp("l") )
        (scatteri `line6' , recast(line) lw(0.75) lc("gs16") fc("gs16") lp("l") )
        /// X-axes
        (scatteri `line7' , recast(line) lw(0.25) lc("gs10") fc("gs10") lp("l") )
        (scatteri `line8' , recast(line) lw(0.25) lc("gs10") fc("gs10") lp("l") )
            ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(8) xsize(16)

			xlab(none, 
            notick labs(3.5) tlc(gs0) labc(gs8) notick nogrid glc(gs16))
			xscale(line range(-2(0.1)1.5) lc(gs10)) 
			xtitle("", size(2) color(gs0) margin(l=0 r=0 t=0 b=0)) 
			
			ylab(none, valuelabel
			labc(gs8) labs(2.5) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(0))
			yscale(reverse noline lw(vthin) range(1(1)11) ) 
			ytitle("", size(2) margin(l=0 r=0 t=0 b=0)) 

            text(9.8 -1 "Annual percent change" ,  place(c) size(4) color(gs10) just(left))
            text(9.8 4.5 "Prob dying between 30 and 70 years" ,  place(c) size(4) color(gs10) just(left))
            text(1 0.1 "North America"          ,  place(e) size(4) color(gs10) just(center))
            text(2 0.1 "Central America"        ,  place(e) size(4) color(gs10) just(left))
            text(3 0.1 "Andean"                 ,  place(e) size(4) color(gs10) just(left))
            text(4 0.1 "Southern Cone"           ,  place(e) size(4) color(gs10) just(left))
            text(5 0.1 "Latin Caribbean"        ,  place(e) size(4) color(gs10) just(left))
            text(6 0.1 "non-Latin Caribbean"    ,  place(e) size(4) color(gs10) just(left))
            text(7 0.1 "Brazil"                 ,  place(e) size(4) color(gs10) just(left))
            text(8 0.1 "Mexico"                 ,  place(e) size(4) color(gs10) just(left))
            text(9 0.1 "The Americas"           ,  place(e) size(4) color(gs10) just(left))

            /// X-axis values (LHS)
            text(11 -0.5 "-0.5%"           ,  place(c) size(3.5) color(gs10) just(left))
            text(11 -1 "-1%"           ,  place(c) size(3.5) color(gs10) just(left))
            text(11 -1.5 "-1.5%"           ,  place(c) size(3.5) color(gs10) just(left))
            text(11 -2 "-2%"           ,  place(c) size(3.5) color(gs10) just(left))
            /// X-axis values (RHS)
            text(11 2.25 "3%"           ,  place(c) size(3.5) color(gs10) just(left))
            text(11 3.75 "4%"           ,  place(c) size(3.5) color(gs10) just(left))
            text(11 5.25 "5%"           ,  place(c) size(3.5) color(gs10) just(left))
            text(11 6.75 "6%"           ,  place(c) size(3.5) color(gs10) just(left))


            legend(off)
			name(q3070)
			;
#delimit cr	

