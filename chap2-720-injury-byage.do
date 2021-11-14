** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-720-injury-byage.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	17-August-2021
    //  algorithm task			    Chart of Percentage of all deaths in 5 age groups

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
    log using "`logpath'\chap2-720-injury-byage", replace
** HEADER -----------------------------------------------------

** DEATHS by AGE
** DATASETS FROM: 
**      chap2-000a-mr-region-groups.do
**      chap2-000a-mr-region.do
tempfile t1 injury1 
use "`datapath'\from-who\chap2_equiplot_mr_byage_groupeddeath", replace
keep if year==2019 & who_region==2 & ghecause==1000 
drop pop who_region year
rename dths deaths
save `injury1' , replace
use "`datapath'\from-who\chap2_equiplot_mr_byage", clear
keep if year==2019 & who_region==2  
drop pop who_region year
rename dths deaths
append using `injury1'

gen age16 = 1       if age18==1
replace age16 = 2   if age18==2
replace age16 = 3   if age18==3
replace age16 = 4   if age18==4
replace age16 = 5   if age18==5
replace age16 = 6   if age18==6
replace age16 = 7   if age18==7
replace age16 = 8   if age18==8
replace age16 = 9   if age18==9
replace age16 = 10  if age18==10
replace age16 = 11  if age18==11
replace age16 = 12  if age18==12
replace age16 = 13  if age18==13
replace age16 = 14  if age18==14
replace age16 = 15  if age18==15
replace age16 = 16  if age18==16 | age18==17 | age18==18
collapse (sum) deaths, by(ghecause age16 agroup)
#delimit ; 
label define age16_     1 "0-4"
                        2 "5-9"
                        3 "10-14"
                        4 "15-19"
                        5 "20-24"
                        6 "25-29"
                        7 "30-34"
                        8 "35-39"
                        9 "40-44"
                        10 "45-49"
                        11 "50-54"
                        12 "55-59"
                        13 "60-64"
                        14 "65-69"
                        15 "70-74"
                        16 "75+";
#delimit cr
label values age16 age16_ 
sort ghecause age16
save `t1', replace


** DALY by AGE
** DATASETS FROM: 
**      chap2-000a-daly-region-groups.do
**      chap2-000a-daly-region.do
tempfile injury2 
use "`datapath'\from-who\chap2_equiplot_daly_byage_groupeddeath", replace
keep if year==2019 & who_region==2 & ghecause==1000 
drop pop who_region year
save `injury2' , replace

use "`datapath'\from-who\chap2_equiplot_daly_byage", clear
keep if year==2019 & who_region==2 
drop pop who_region year
append using `injury2'
rename age18 age16
sort ghecause age16

** Merge and collapse to broad age groups 
merge 1:1 ghecause age16 using `t1' 
drop _merge age16
collapse (sum) daly deaths , by(ghecause agroup)
format deaths daly %15.0fc 
reshape wide daly deaths , i(ghecause) j(agroup)
egen deaths_tot = rowtotal(deaths1 deaths2 deaths3 deaths4 deaths5) 
egen daly_tot = rowtotal(daly1 daly2 daly3 daly4 daly5) 
sort ghecause deaths* daly* 
format deaths* daly* deaths_tot daly_tot %15.0fc 

forval x = 1(1)5 {
    gen death_perc`x' = (deaths`x' / deaths_tot) * 100 
    gen daly_perc`x' = (daly`x' / daly_tot) * 100 
}
keep ghecause death_perc* daly_perc*
order ghecause death_* daly_*


**------------------------------------------------
** BEGIN STATISTICS FOR TEXT
** to accompany the CANCER METRICS TABLE
** (1) 56   "interpersonal violence" 
** (2) 48   "road injury" 
** (3) 55   "self harm" 
** (4) 50   "falls" 
** (5) 52   "Drowning" 
** 1000     "all injuries"
** 100      "all cause", modif    
** -----------------------------------------------
gen cod = 1 if ghecause==56 
replace cod = 2 if ghecause==48
replace cod = 3 if ghecause==55
replace cod = 4 if ghecause==50
replace cod = 5 if ghecause==52
replace cod = 6 if ghecause==1000
#delimit ; 
label define cod_   1 "Interpersonal violence" 
                    2 "Road injury" 
                    3 "Self harm" 
                    4 "Falls" 
                    5 "Drowning" 
                    6 "All injuries", modify;
#delimit cr
label values cod cod_ 
keep if cod<=6
sort cod 
order cod ghecause death_* daly_*


** ------------------------------------------------------
** GRAPHIC
** ------------------------------------------------------

** COLORS - RED for INJURY
    colorpalette hcl, reds nograph n(14)
    local list r(p) 
    local child `r(p2)'    
    local youth `r(p5)'    
    local young `r(p8)'    
    local older `r(p11)'    
    local elderly `r(p14)'  
    colorpalette #990000 #e60000 #ff3333 #ff8080 #ffcccc , nograph
    local list r(p) 
    local child `r(p1)'    
    local youth `r(p2)'    
    local young `r(p3)'    
    local older `r(p4)'    
    local elderly `r(p5)'  
  

** Jitter - visually split low percentage groups
replace death_perc3 = death_perc3 + 2 if cod==2
replace death_perc3 = death_perc3 + 2 if cod==3
replace death_perc1 = death_perc1 + 2 if cod==4
replace daly_perc2 = daly_perc2 - 2 if cod==6

** Outer box and legend locations
local outer1 -1 -30     7.5 -30    7.5 280    -1 280 
local outer2 0 110     7.4 110 
local outer3 0 230     7.4 230 
local legend1 2     240
local legend2 2.75  240
local legend3 3.5   240
local legend4 4.25  240
local legend5 5     240

** Y-axis recode
rename death_perc1 p11 
rename death_perc2 p21 
rename death_perc3 p31 
rename death_perc4 p41 
rename death_perc5 p51 
rename daly_perc1 p12
rename daly_perc2 p22 
rename daly_perc3 p32 
rename daly_perc4 p42 
rename daly_perc5 p52 

reshape long p1 p2 p3 p4 p5 , i(cod) j(type)
label define type_ 1 "death" 2 "daly"
label values type type_  

gen cod2 = . 
replace cod2 = 1 if cod==1 & type==1
replace cod2 = 1 if cod==1 & type==2
replace cod2 = 2 if cod==2 & type==1
replace cod2 = 2 if cod==2 & type==2
replace cod2 = 3 if cod==3 & type==1
replace cod2 = 3 if cod==3 & type==2
replace cod2 = 4 if cod==4 & type==1
replace cod2 = 4 if cod==4 & type==2
replace cod2 = 5 if cod==5 & type==1
replace cod2 = 5 if cod==5 & type==2
replace cod2 = 6 if cod==6 & type==1
replace cod2 = 6 if cod==6 & type==2

gen daly1 = p1 + 120 if type==2
gen daly2 = p2 + 120 if type==2
gen daly3 = p3 + 120 if type==2
gen daly4 = p4 + 120 if type==2
gen daly5 = p5 + 120 if type==2


* Statistics text to accompany the graphic
sort type cod

** Max and min for deaths
egen mind = rowmin(p1 p2 p3 p4 p5)
egen maxd = rowmax(p1 p2 p3 p4 p5)
order mind maxd, after(p5)
egen mindaly = rowmin(daly1 daly2 daly3 daly4 daly5)
egen maxdaly = rowmax(daly1 daly2 daly3 daly4 daly5)
order mindaly maxdaly, after(daly5)

#delimit ;
	gr twoway 
        (scatteri `outer1' , recast(area) lw(0.25) lc(gs10) fc(none) )
        (scatteri `outer2' , recast(line) lw(0.25) lc(gs10) fc(none) )
        (scatteri `outer3' , recast(line) lw(0.25) lc(gs10) fc(none) )
        (scatteri `legend1' , msize(6) m(o) mlw(0.1) mlc(gs10) mfc("`child'") )
        (scatteri `legend2' , msize(6) m(o) mlw(0.1) mlc(gs10) mfc("`youth'") )
        (scatteri `legend3' , msize(6) m(o) mlw(0.1) mlc(gs10) mfc("`young'") )
        (scatteri `legend4' , msize(6) m(o) mlw(0.1) mlc(gs5)  mfc("`older'") )
        (scatteri `legend5' , msize(6) m(o) mlw(0.1) mlc(gs5)  mfc("`elderly'") )

        /// DEATH horizontal lines
        (rbar mind maxd cod2 if type==1, horizontal fc("`elderly'")   barw(0.5) lw(none))

        /// DALY horizontal lines
        (rbar mindaly maxdaly cod2 if type==2, horizontal fc("`elderly'")   barw(0.5) lw(none))

		/// DEATH Points
        (sc cod2 p1 if type==1,  msize(8) m(o) mlc(gs10) mfc("`child'%75") mlw(0.1))
        (sc cod2 p2 if type==1 , msize(8) m(o) mlc(gs10) mfc("`youth'%75") mlw(0.1))
        (sc cod2 p3 if type==1 , msize(8) m(o) mlc(gs10) mfc("`young'%75") mlw(0.1))
        (sc cod2 p4 if type==1 , msize(8) m(o) mlc(gs7) mfc("`older'%75") mlw(0.1))
        (sc cod2 p5 if type==1 , msize(8) m(o) mlc(gs7) mfc("`elderly'%75") mlw(0.1))
		/// DALY Points
        (sc cod2 daly1 , msize(8) m(o) mlc(gs10) mfc("`child'%75") mlw(0.1))
        (sc cod2 daly2 , msize(8) m(o) mlc(gs10) mfc("`youth'%75") mlw(0.1))
        (sc cod2 daly3 , msize(8) m(o) mlc(gs10) mfc("`young'%75") mlw(0.1))
        (sc cod2 daly4 , msize(8) m(o) mlc(gs7) mfc("`older'%75") mlw(0.1))
        (sc cod2 daly5 , msize(8) m(o) mlc(gs7) mfc("`elderly'%75") mlw(0.1))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(6) xsize(15)

			/// X-axis
			xlab(0 50 100 120 "0" 170 "50" 220 "100", 
			labc(gs8) labs(4) notick grid glc(gs16) angle(0) format(%9.0f))
			xscale(noline range(-5(5)100) lw(vthin)) 
			xtitle(" ", size(3) color(gs8) margin(l=0 r=0 t=0 b=0)) 
            xmtick(0 25 75 100 120 145 170 195 220, tlc(gs8))

			/// Y-axis
			ylab(	1 "Interpersonal violence" 
                    2 "Road injury" 
                    3 "Self harm" 
                    4 "Falls" 
                    5 "Drowning" 
                    6 "All injuries"
					,
			labc(gs8) labs(4) tlc(gs8) nogrid notick glc(blue) angle(0) format(%9.0f) labgap(2) )
			yscale(noline reverse range(0.5(0.5)7.5) noextend   ) 
			ytitle("", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            text(-0.3 50 "Deaths"           ,  place(c) size(4.5) color(gs8) just(right))
            text(-0.3 170 "DALYs"           ,  place(c) size(4.5) color(gs8) just(right))
            text(7 50 "% of all Deaths"     ,  place(c) size(4) color(gs8) just(right))
            text(7 170 "% of all DALYs"     ,  place(c) size(4) color(gs8) just(right))
            text(2  245 "Under 5s"     ,  place(e) size(3.5) color(gs8) just(right))
            text(2.75  245 "5-19"     ,  place(e) size(3.5) color(gs8) just(right))
            text(3.5   245 "20-39"     ,  place(e) size(3.5) color(gs8) just(right))
            text(4.25  245 "40-64"    ,  place(e) size(3.5) color(gs8) just(right))
            text(5     245 "65+"            ,  place(e) size(3.5) color(gs8) just(right))

			legend(off size(3) color(gs8) position(3) nobox ring(0) bm(t=0 b=0 l=0 r=0) colf cols(1)
			region(fcolor(gs16) lw(none) margin(t=0 b=1 l=0 r=0)) 
			order(7 8 9 10 11) textfirst
			lab(7 "Under 5s") 
			lab(8 "5-19") 		
			lab(9 "20-39") 		
			lab(10 "40-64") 		
			lab(11 "65+") 		
            )
			name(equiplot_byage)
			;
#delimit cr	
