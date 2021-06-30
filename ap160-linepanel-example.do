** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    ap160-linepanel-example.do
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
    log using "`logpath'\ap160-linepanel-example", replace
** HEADER -----------------------------------------------------

** EXAMPLE IS LIFE EXPECTANCY at BIRTH
** PANEL OF LINE CHARTS
** to compare Americas

** FULL LIFE TABLE DATASET 
use "`datapath'\from-who\lifetables\who-lifetable-2019-all", clear
** Only keep regional LE data
drop if country!=""
** Keep ex data --> ghocode==35
keep if ghocode==35 

** Construct a single example panel, which we will then repeat for each major WHO region 
** This will be a simple line chart of LE (y) by age (x)

#delimit ;
	gr twoway 
		/// Number 2 (SAME - GRAY)
		(line metric year if region=="AMR" & sex==1 & agroup==1 , lw(0.25) lc("127 127 127%50"))
		(line metric year if region=="AMR" & sex==2 & agroup==1 , lw(0.25) lc("127 127 127%50"))
		///(line metric agroup if region=="AMR" & sex==2 & year==2005 & agroup<=15, lw(0.25) lc("127 127 127%50"))
		///(line metric agroup if region=="AMR" & sex==2 & year==2010 & agroup<=15, lw(0.25) lc("127 127 127%50"))
		///(line metric agroup if region=="AMR" & sex==2 & year==2015 & agroup<=15, lw(0.25) lc("127 127 127%50"))
		///(line metric agroup if region=="EUR" & sex==2 & year==2019 & agroup<=15, lw(0.25) lc("127 127 127%50"))
		,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(10) xsize(5)

			xlab(, 
            notick tlc(gs0) labc(gs0) notick nogrid glc(gs16))
			xscale(lw(vthin)) 
			xtitle(" ", size(5) color(gs0) margin(l=2 r=2 t=5 b=2)) 
			
			ylab(60(5)85,
			valuelabel labc(gs0) labs(6) tstyle(major_notick) nogrid glc(gs16) angle(0) format(%9.0f))
			yscale(lw(vthin)) 
			ytitle(" Life Expectancy (yrs)", size(5) margin(l=2 r=5 t=2 b=2)) 

            /// title("DALYs in the Americas", size(7) color(gs0) position(11))

            /// Regions 
            /// text(1 12 "Cardiovascular",  place(e) size(5) color(gs0))
			legend(off)
			name(linepanel_01)
			;
#delimit cr	



/*




** AMERICAS dataset 
use "`datapath'\from-who\lifetables\americas-ex0-full", clear
drop if year==.
sort iso3c year sex

** OTHER WORLD REGIONS
