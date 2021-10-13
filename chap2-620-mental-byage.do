** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap2-620-mental-byage.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	18-August-2021
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
    log using "`logpath'\chap2-620-mental-byage", replace
** HEADER -----------------------------------------------------

** DEATHS by AGE
** DATASETS FROM: 
**      chap2-000a-mr-region-groups.do
**      chap2-000a-mr-region.do
tempfile t1 mental1 
use "`datapath'\from-who\chap2_equiplot_mr_byage_groupeddeath", replace
keep if year==2019 & who_region==2 & (ghecause==800 | ghecause==900) 
drop pop dths who_region year
save `mental1' , replace
use "`datapath'\from-who\chap2_equiplot_mr_byage", clear
keep if year==2019 & who_region==2  
drop pop dths who_region year
append using `mental1'

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
tempfile mental2 
use "`datapath'\from-who\chap2_equiplot_daly_byage_groupeddeath", replace
keep if year==2019 & who_region==2 & (ghecause==800 | ghecause==900) 
drop pop dalyt who_region year
save `mental2' , replace

use "`datapath'\from-who\chap2_equiplot_daly_byage", clear
keep if year==2019 & who_region==2 
drop pop who_region year dalyt
append using `mental2'
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

** 1-5 here refers to the 5 broad age groups
forval x = 1(1)5 {
    gen death_perc`x' = (deaths`x' / deaths_tot) * 100 
    gen daly_perc`x' = (daly`x' / daly_tot) * 100 
}
keep ghecause death_perc* daly_perc*
order ghecause death_* daly_*

**------------------------------------------------
** Ordered version of ghecause 
** MENTAL HEALTH
** (36)  1   "Drug use disorders" 
** (32)  2   "Depressive disorders" 
** (37)  3   "Anxiety disorders" 
** (35)  4   "Alcohol use disorders" 
** (34)  5   "Schizophrenia" 
** NEUROLOGICAL
** (42)  6   "Alzheimer/dementias"
** (46)  7   "Migraine"
** (44)  8   "Epilepsy"
** (47)  9   "Non-migraine headache"
** (43)  10  "Parkinson disease"
** (800)  11  "all mental"
** (900)  12  "all neurological"
** (100)  13  "all cause"  
** -----------------------------------------------
gen cod = .
replace cod = 1 if ghecause==36
replace cod = 2 if ghecause==32
replace cod = 3 if ghecause==37
replace cod = 4 if ghecause==35
replace cod = 5 if ghecause==34
replace cod = 6 if ghecause==800

replace cod = 7 if ghecause==42
replace cod = 8 if ghecause==46
replace cod = 9 if ghecause==44
replace cod = 10 if ghecause==47
replace cod = 11 if ghecause==43
replace cod = 12 if ghecause==900
#delimit ;
label define cod_   1   "Drug use disorders" 
                    2   "Depressive disorders" 
                    3   "Anxiety disorders" 
                    4   "Alcohol use disorders" 
                    5   "Schizophrenia" 
                    6  "all mental"
                    7   "Alzheimer/dementias"
                    8   "Migraine"
                    9   "Epilepsy"
                    10   "Non-migraine headache"
                    11  "Parkinson disease"
                    12  "all neurological", modify;
#delimit cr
label values cod cod_    
keep if cod<=12
sort cod


** ------------------------------------------------------
** GRAPHIC
** ------------------------------------------------------

** COLORS - ORANGES for MENTAL HEALTH / NEUROLOGICAL
    colorpalette hcl, oranges nograph n(14)
    local list r(p) 
    ** Age groups
    local child `r(p2)'    
    local youth `r(p5)'    
    local young `r(p8)'    
    local older `r(p11)'    
    local elderly `r(p14)'    

** Jitter - visually split low percentage groups
** DEATHS
replace death_perc2 = death_perc2 + 2 if cod==7
replace death_perc3 = death_perc3 + 4 if cod==7
replace death_perc4 = death_perc4 + 6 if cod==7
replace death_perc2 = death_perc2 + 2 if cod==8
** DALYS
replace daly_perc2 = daly_perc2 + 2 if cod==2
replace daly_perc4 = daly_perc4 + 2 if cod==4
replace daly_perc5 = daly_perc5 + 2 if cod==10
replace daly_perc2 = daly_perc2 + 2 if cod==11
replace daly_perc3 = daly_perc3 + 4 if cod==11

** Outer box and legend locations
local outer1    -1 -20       15 -20    15 280    -1 280 
local outer2    0   110      14.9 110 
local outer3    0   223      14.9 223 
local legend1   2     233
local legend2   3.5     233
local legend3   5     233
local legend4   6.5     233
local legend5   8     233

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

replace cod2 = 8 if cod==7 & type==1
replace cod2 = 8 if cod==7 & type==2
replace cod2 = 9 if cod==8 & type==1
replace cod2 = 9 if cod==8 & type==2
replace cod2 = 10 if cod==9 & type==1
replace cod2 = 10 if cod==9 & type==2
replace cod2 = 11 if cod==10 & type==1
replace cod2 = 11 if cod==10 & type==2
replace cod2 = 12 if cod==11 & type==1
replace cod2 = 12 if cod==11 & type==2
replace cod2 = 13 if cod==12 & type==1
replace cod2 = 13 if cod==12 & type==2

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
        (scatteri `legend1' , msize(5) m(o) mlw(0.1) mlc(gs10) mfc("`child'") )
        (scatteri `legend2' , msize(5) m(o) mlw(0.1) mlc(gs10) mfc("`youth'") )
        (scatteri `legend3' , msize(5) m(o) mlw(0.1) mlc(gs10) mfc("`young'") )
        (scatteri `legend4' , msize(5) m(o) mlw(0.1) mlc(gs5)  mfc("`older'") )
        (scatteri `legend5' , msize(5) m(o) mlw(0.1) mlc(gs5)  mfc("`elderly'") )

		/// Mental health / neurological separator
        (function y=7, range(-20 223) lc(gs10) lw(0.25) fc(none) lp("l") )

        /// DEATH horizontal lines
        (rbar mind maxd cod2 if type==1 & cod2!=2 & cod2!=3 & cod2!=9, horizontal fc("`elderly'")   barw(0.75) lw(none))

        /// DALY horizontal lines
        (rbar mindaly maxdaly cod2 if type==2, horizontal fc("`elderly'")   barw(0.75) lw(none))

		/// DEATH Points
        (sc cod2 p1 if type==1 & cod2!=2 & cod2!=3 & cod2!=9,  msize(5.5) m(o) mlc(gs10) mfc("`child'%75") mlw(0.1))
        (sc cod2 p2 if type==1 & cod2!=2 & cod2!=3 & cod2!=9 , msize(5.5) m(o) mlc(gs10) mfc("`youth'%75") mlw(0.1))
        (sc cod2 p3 if type==1 & cod2!=2 & cod2!=3 & cod2!=9 , msize(5.5) m(o) mlc(gs10) mfc("`young'%75") mlw(0.1))
        (sc cod2 p4 if type==1 & cod2!=2 & cod2!=3 & cod2!=9 , msize(5.5) m(o) mlc(gs7) mfc("`older'%75") mlw(0.1))
        (sc cod2 p5 if type==1 & cod2!=2 & cod2!=3 & cod2!=9 , msize(5.5) m(o) mlc(gs7) mfc("`elderly'%75") mlw(0.1))
		/// DALY Points
        (sc cod2 daly1 , msize(5.5) m(o) mlc(gs10) mfc("`child'%75") mlw(0.1))
        (sc cod2 daly2 , msize(5.5) m(o) mlc(gs10) mfc("`youth'%75") mlw(0.1))
        (sc cod2 daly3 , msize(5.5) m(o) mlc(gs10) mfc("`young'%75") mlw(0.1))
        (sc cod2 daly4 , msize(5.5) m(o) mlc(gs7) mfc("`older'%75") mlw(0.1))
        (sc cod2 daly5 , msize(5.5) m(o) mlc(gs7) mfc("`elderly'%75") mlw(0.1))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
			ysize(8) xsize(15)

			/// XX
			xlab(0 50 100 120 "0" 170 "50" 220 "100", 
			labc(gs8) labs(4) notick grid glc(gs16) angle(0) format(%9.0f))
			xscale(noline range(-5(5)100) lw(vthin)) 
			xtitle(" ", size(3) color(gs8) margin(l=0 r=0 t=0 b=0)) 
            xmtick(0 25 75 100 120 145 170 195 220, tlc(gs8))

			/// XX
			ylab(	1 "Drug use disorders" 
                    2 "Depressive disorders" 
                    3 "Anxiety disorders" 
                    4 "Alcohol use disorders" 
                    5 "Schizophrenia" 
                    6 "All mental health"
                    8 "Alzheimer's / dementias"
                    9 "Migraine"
                    10 "Epilepsy"
                    11 "Non-migraine headache"
                    12 "Parkinson disease"
                    13 "All neurological"
					,
			labc(gs8) labs(3.5) tlc(gs8) nogrid notick glc(blue) angle(0) format(%9.0f) labgap(0) )
			yscale(noline reverse range(0.5(0.5)14) noextend   ) 
			ytitle("", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            text(-0.5 50 "Deaths"           ,  place(c) size(4.5) color(gs8) just(right))
            text(-0.5 170 "DALYs"           ,  place(c) size(4.5) color(gs8) just(right))
            text(14.5 50 "% of all Deaths"     ,  place(c) size(4) color(gs8) just(right))
            text(14.5 170 "% of all DALYs"     ,  place(c) size(4) color(gs8) just(right))
            text(2  238 "Under 5s"     ,    place(e) size(3.5) color(gs8) just(right))
            text(3.5  238 "5-19"     ,        place(e) size(3.5) color(gs8) just(right))
            text(5  238 "20-39"     ,       place(e) size(3.5) color(gs8) just(right))
            text(6.5  238 "40-64"    ,        place(e) size(3.5) color(gs8) just(right))
            text(8  238 "65+"            ,  place(e) size(3.5) color(gs8) just(right))

			legend(off size(3) color(gs8) position(3) nobox ring(0) bm(t=0 b=0 l=0 r=0) colf cols(1)
			region(fcolor(gs16) lw(none) margin(t=0 b=1 l=0 r=0)) 
			order(7 8 9 10 11) textfirst		
            )
			name(equiplot_byage)
			;
#delimit cr	

