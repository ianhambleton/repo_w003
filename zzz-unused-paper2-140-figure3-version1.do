** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-140-figure3-version1.do
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
    log using "`logpath'\paper2-140-figure3-version1", replace
** HEADER -----------------------------------------------------

** XX
use "`datapath'\paper2-inj\dataset01", clear
** keep if ghecause>=48 & ghecause<=57
** keep if ghecause>=1000
keep if sex<3
keep if year==2019
** keep if region<=33 | region==2000
keep if (region>=100 & region <1000) | region==2000
keep year sex ghecause region dalyr  
reshape wide dalyr , i(region ghecause) j(sex)
gen srel = dalyr1 / dalyr2
gsort -srel
gen ylab = _n
decode region, gen(rlabel)
labmask ylab , values(rlabel) 

gen origin = 0
gsort ghecause -srel
/*
#delimit ;  
	gr twoway 
		/// country values
        (rbar origin scaler1 region1 if cod==1 & region!=2000, horizontal barw(0.6) fcol("`dia2'") lcol("`dia2'") lw(0.1))           
        (rbar origin scaler1 region1 if cod==1 & region==2000, horizontal barw(0.6) fcol(gs0) lcol(gs0) lw(0.1))           
        ///(sc value1 x1, msymbol(i) mlabel(value1) mlabsize(7) mlabcol(gs8) mlabp(0))
                		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(16) xsize(4)

			xlab(none, notick labs(7) tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(noline range(1(1)100)) 
			xtitle("", size(7) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(1(1)34, valuelabel
			labc(gs0) labs(7) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f) labgap(10))
			yscale(noline lw(vthin) range(-2.5(0.5)36)) 
			ytitle("", size(7) margin(l=2 r=2 t=2 b=2)) 

            legend(off)
			name(figure 3a)
			;
#delimit cr	