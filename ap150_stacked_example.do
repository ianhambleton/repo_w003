** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			        p003-stacked.do
    //  project:				        WHO Global Health Estimates
    //  analysts:				        Ian HAMBLETON
    // 	date last modified	            4-April-2021
    //  algorithm task			        Stacked Line chart example

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
    log using "`logpath'\p003-stacked", replace
** HEADER -----------------------------------------------------

** UN deaths equiplot example
use "`datapath'\from-who\who-ghe-deaths-001-who2", clear

** Restrict to main disease categories 
**      (10)    Communicable disease
**      (600)  Non-communicable disease
**      (1510) Injuries 
keep if ghecause==10 | ghecause==600 | ghecause==1510 
drop if age==-2 | age==-1 
drop if iso3c=="USA" | iso3c=="CAN"
** All Americas, women and men combined 
collapse (sum) dths, by(year ghecause)
reshape wide dths, i(year) j(ghecause)

** Total count 
gen total = dths10 + dths600 + dths1510 
** Relative percentages
gen p1510 = (dths1510/total)*100
gen p600 = (dths600/total)*100
gen p10 = (dths10/total)*100
gen p_inj = p1510 
gen p_ncd = p600 + p1510 
gen p_com = p10 + p600 + p1510 

** Absolute numbers 
** Injuries 
gen d_inj = dths1510 
** NCDS = NCDs + injuries 
gen d_ncd = dths600 + dths1510
** Comms = comms + NCDs + injuries
gen d_com = dths10 + dths600 + dths1510



** Example stacked Line
** Primary colors (-colorpalette- SFSO Parties)
** RED 199 62 49 
** BLUE 69 112 186
** YELLOW 236 206 66

** Absolute burden
#delimit ;
	gr twoway 
		  /// lw=line width, msize=symbol size, mc=symbol colour, lc=line color
		  /// Colours use RGB system
		  (area d_com year, lp("-") color("199 62 49%75") lw(none))
		  (area d_ncd year, lp("-") color("69 112 186%75") lw(none))
		  (area d_inj year, lp("l") color("236 206 66%75") lw(none))
		  ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(8) xsize(12)

			xlab(2000 2005 2010 2015 2019, labs(medium) labc(gs10) nogrid notick angle(0))
			xtitle(" ", margin(t=3) size(4) color(gs10)) 
			xscale(noline range(2000(1)2027)) 

			ylab(0 1000000 "1 million" 2000000 "2 million" 3000000 "3 million"  4000000 "4 million", labgap(4) labs(medium) labc(gs10) nogrid notick angle(0) format(%9.0f))
			ytitle(" ", margin(r=3) size(4) color(gs10))
            yscale(lc(gs10))

            title("Total deaths by cause", size(5) color(gs10) position(11))
            subtitle("Americas, 2000 to 2019", size(4) color(gs10) position(11))
            text(370000 2019.5 "Injuries",  place(e) size(3) color("236 206 66%100"))
            text(2000000 2019.5 "Non-communicable",  place(e) size(3) color("69 112 186%100"))
            text(3800000  2019.5 "Communicable",  place(e) size(3) color("199 62 49%100"))

			legend(off size(4) position(12) bm(t=1 b=0 l=0 r=0) colf cols(1)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(3 2 1)
			lab(3 "injuries")
			lab(2 "Non-communicable")
			lab(1 "Communicable"))
			name(stacked1)
			;
#delimit cr

** Relative burden
#delimit ;
	gr twoway 
		  /// lw=line width, msize=symbol size, mc=symbol colour, lc=line color
		  /// Colours use RGB system
		  (area p_com year, lp("-") color("199 62 49%75") lw(none))
		  (area p_ncd year, lp("-") color("69 112 186%75") lw(none))
		  (area p_inj year, lp("l") color("236 206 66%75") lw(none))
		  ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(8) xsize(16)

			xlab(2000 2005 2010 2015 2019, labs(medium) labc(gs10) nogrid notick angle(0))
			xtitle(" ", margin(t=3) size(4) color(gs10)) 
			xscale(noline range(2000(1)2027)) 

			ylab(0(25)100, labgap(4) labs(medium) labc(gs10) nogrid notick angle(0) format(%9.0f))
			ytitle(" ", margin(r=3) size(4) color(gs10))
            yscale(lc(gs10))

            title("Total deaths by cause", size(5) color(gs10) position(11))
            text(10 2019.5 "Injuries",  place(e) size(5) color("236 206 66%100"))
            text(50 2019.5 "Non-communicable",  place(e) size(5) color("69 112 186%100"))
            text(90 2019.5 "Communicable",  place(e) size(5) color("199 62 49%100"))

			legend(off size(medium) position(12) bm(t=1 b=0 l=0 r=0) colf cols(1)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(3 2 1)
			lab(1 "injuries")
			lab(2 "Non-communicable")
			lab(3 "Communicable"))
			name(stacked2)
			;
#delimit cr

/*
** Line chart 
#delimit ;
	gr twoway 
		  /// lw=line width, msize=symbol size, mc=symbol colour, lc=line color
		  /// Colours use RGB system
		  (connect dths year if ghecause==10, lp("-") lw(medium) msize(medium) mc("116 196 118") lc("116 196 118"))
		  (connect  dths year if ghecause==600, lp("-") lw(medium) msize(medium) mc("186 228 179") lc("186 228 179"))
		  (connect  dths year if ghecause==1510, lp("l") lw(medium) msize(medium) mc("0 109 44") lc("0 109 44"))
		  ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 		
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(7) xsize(10)

			xlab(, labs(medium) nogrid angle(45))
			xtitle("Time (in years)", margin(t=3) size(medlarge)) 
			xmtick(2000(5)2015)

			ylab(0(500000)3500000, labs(medium) nogrid glc(gs14) angle(0) format(%9.0f))
			ytitle("Deaths", margin(r=3) size(medlarge))
			///ytick(0(10)80) ymtick(0(5)80)

			legend(size(medium) position(12) bm(t=1 b=0 l=0 r=0) colf cols(1)
			region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(3 1 2)
			lab(1 "Communicable")
			lab(2 "Non-communicable")
			lab(3 "Injuries"))
			name(equiplot)
			;
#delimit cr

