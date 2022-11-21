** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    aging-700-uncertainty-report.do
    //  project:				    UN WPP (2019 edition)
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-Nov-2022
    //  algorithm task			    Sensitivity work for mortality data

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
    log using "`logpath'\aging-700-uncertainty-report", replace
** HEADER -----------------------------------------------------



** ----------------------------------------------------------
** (A) REPEAT the original decomposition chart
** (i) POINT ESTIMATE
** ----------------------------------------------------------

    ** Use the decomposition dataset, then will be used for sensitivity analyses
    use "`datapath'\from-who\decomposition", clear
    keep if type == 1

    rename ch1 ch
    rename as1 as
    rename gr1 gr
    rename ep1 ep
    rename d00_1 d00
    rename d19_1 d19

    ** Further graph preparation
    gen zero = 0 
    gen realzero = 0

    ** addage:  change due to age structure as long as EPI change is negative
    ** basepop: start of the horizontal bar, which is normally below 0 due to negative EPI change
    ** addpop:  additional change due to population growth, on top of change due to aging
    gen addage = as if ep < 0  & as > 0
    gen basepop = 0 
    replace basepop = as if as < 0
    replace basepop = ep + basepop if ep > 0
    replace addage = as + ep if ep > 0 
    replace addage = ep if ep > 0 & as < 0
    gen addpop = addage + gr

    ** List the decompiosition by overall change in deaths
    ** IE same order as for graphic
            label define iso3n 2000 "THE AMERICAS", modify
            label values iso3n iso3n 
            gsort ch
            list iso3n ch gr as ep, sep(5) line(120)

    drop if iso3c=="LAC"

    ** Country names
    gsort -ch
    gen y = _n
    decode iso3n, gen(cname)
    labmask y, val(cname)
    #delimit ; 
    label define y         30 "St.Vincent & Gren"
                            14 "Antigua & Barbuda"
                            33 "Trinidad & Tobago"
                            1  "Dominican Rep", modify;
    label values y y; 
    #delimit cr


    ** Original Color scheme
    #delimit ;
    ** colorpalette d3, 20 n(20) nograph;
    ** local list r(p);    local blu1 `r(p1)'; local blu2 `r(p2)'; local red1 `r(p7)'; local red2 `r(p8)'; local gry1 `r(p15)'; local gry2 `r(p16)';
    **                     local ora1 `r(p3)'; local ora2 `r(p4)'; local pur1 `r(p9)'; local pur2 `r(p10)';
    ** Colorblind friendly palette (Bischof, 2017b);
    ** Bischof, D. 2017b. New graphic schemes for Stata: plotplain and plottig.  The Stata Journal 17(3): 748–759;
    colorpalette cblind, select(1 2 4 5 9 8 7 3 6) nograph;
    local list r(p);    local blk `r(p1)'; local gry `r(p2)'; local bl1 `r(p3)';  local gre `r(p4)'; local pur `r(p5)'; 
                        local red `r(p6)'; local bl2 `r(p7)'; local ora `r(p8)'; local yel `r(p9)';
    #delimit cr

    ** Column X-location for death metrics 
    ** Max of first panel = 144
    gen xloc2 = 240
    gen xloc3 = 330
    gen pd = round(ch) 
    gen ad = int(d19 - d00)
    format ad %10.0fc

    ** Boxes around metrics
    local box1 0.5 220 33.5 220 33.5 260 0.5 260
    local box2 0.5 280 33.5 280 33.5 380 0.5 380

    sort ch

** Decomposition chart
#delimit ;
	graph twoway 
		///epi change (usually negative, but not always)
		(rbar zero ep y, horizontal barwidth(.75)  lc("`gre'*0.8") lw(0.05) fc("`gre'*0.8")) 
		/// Change due to Population Aging
		(rbar basepop addage y , horizontal barwidth(.75)  lc("`ora'*0.8") lw(0.05) fc("`ora'*0.8")) 
		/// Change due to Population Growth
		(rbar addage addpop y , horizontal barwidth(.75)  lc("`bl2'*0.8") lw(0.05) fc("`bl2'*0.8")) 
		/// Vertical Zero Line
		(line y realzero, lcolor("`gry'") lp(l) lc("`gry'")) 
		/// Overall Change point
		(scatter y ch, msymbol(O) mlcolor("`gry'") mfcolor(gs16) msize(2))
        
        /// Boxes around metrics
		(scatteri `box1'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		(scatteri `box2'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))

		/// Percentage change in deaths
		(sc y xloc2, msymbol(i) mlabel(pd) mlabsize(2.5) mlabcol(gs8) mlabp(0))
		/// Actual change in numbers of deaths
		(sc y xloc3, msymbol(i) mlabel(ad) mlabsize(2.5) mlabcol(gs8) mlabp(0))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(15) xsize(10)
	
		xlabel(-100(50)250, labsize(2.5) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(1(1)33
		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(noline range(1(1)35))

        text(-2.5 50 "Percent Change in Deaths" "2000-2019", place(c) size(3) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 240 "Percent" "Change", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 330 "Extra" "Deaths", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(order(5 1 2 3) keygap(2) rowgap(2) linegap(0.75)
		label(1 "Change due to age-" "specific mortality rates")  
		label(2 "Change due to" "population aging") 
		label(3 "Change due to" "population growth") 
		label(5 "Change in deaths") 
		cols(2) position(6) size(2.5) symysize(3) color(gs8)
		) 
		name(deaths_est)
	;
#delimit cr





/*

** OVERALL CHANGE: Uncertainty intervals
local tick1 0 -50   -0.75 -50 
local tick2 0 0     -0.75 0 
local tick3 0 50    -0.75 50 
local tick4 0 100   -0.75 100 
local tick5 0 150   -0.75 150 
local tick6 0 200   -0.75 200 

#delimit ;
	graph twoway 
		///epi change (usually negative, but not always)
		(rbar ch2 ch3 y, horizontal barwidth(.1)  lc("`gry'*0.8") lw(0.05) fc("`gry'*0.8")) 
		/// Vertical Zero Line
		(line y realzero, lp(l) lc("`red'*0.25")) 
		/// Overall Change point
		(scatter y ch, msymbol(O) mlcolor("`gry'") mfcolor("gs10%80") msize(1.5))
        /// X-axis
        /// (function y=0, range(-50 200) lc(gs10) lw(0.2))
        (scatteri `tick1' , recast(line) lw(0.2) lc(gs16))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(15) xsize(10)
	
		xlabel(-50(50)200, labsize(2.5) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(1(1)33
		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(noline range(1(1)35))

        text(-2.5 50 "Percent Change in Deaths" "2000-2019", place(c) size(3) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(order(3 1 4 4) keygap(2) rowgap(2) linegap(0.75)
		label(3 "Change" "in deaths ")  
		label(1 "95% Uncertainty" "interval") 
        label(4 " ")
        label(4 " ")
		cols(2) position(6) size(3) symysize(3) color(gs8)
		) 
		name(ci_ch)
	;
#delimit cr
graph export "`outputpath'/figure3a_ci.png", replace width(4000)





*/

** ----------------------------------------------------------
** (A) REPEAT the original decomposition chart
** (i) POINT ESTIMATE DALY
** ----------------------------------------------------------

    ** Use the decomposition dataset, then will be used for sensitivity analyses
    use "`datapath'\from-who\decomposition", clear
    keep if type == 2

    rename ch1 ch
    rename as1 as
    rename gr1 gr
    rename ep1 ep
    rename d00_1 d00
    rename d19_1 d19

    ** Further graph preparation
    gen zero = 0 
    gen realzero = 0

    ** addage:  change due to age structure as long as EPI change is negative
    ** basepop: start of the horizontal bar, which is normally below 0 due to negative EPI change
    ** addpop:  additional change due to population growth, on top of change due to aging
    gen addage = as if ep < 0  & as > 0
    gen basepop = 0 
    replace basepop = as if as < 0
    replace basepop = ep + basepop if ep > 0
    replace addage = as + ep if ep > 0 
    replace addage = ep if ep > 0 & as < 0
    gen addpop = addage + gr

    ** List the decompiosition by overall change in deaths
    ** IE same order as for graphic
            label define iso3n 2000 "THE AMERICAS", modify
            label values iso3n iso3n 
            gsort ch
            list iso3n ch gr as ep, sep(5) line(120)

    drop if iso3c=="LAC"

    ** Country names
    gsort -ch
    gen y = _n
    decode iso3n, gen(cname)
    labmask y, val(cname)
    #delimit ; 
    label define y         26 "St.Vincent & Gren"
                            11 "Antigua & Barbuda"
                            32 "Trinidad & Tobago"
                            1  "Dominican Rep", modify;
    label values y y; 
    #delimit cr


    ** Original Color scheme
    #delimit ;
    ** colorpalette d3, 20 n(20) nograph;
    ** local list r(p);    local blu1 `r(p1)'; local blu2 `r(p2)'; local red1 `r(p7)'; local red2 `r(p8)'; local gry1 `r(p15)'; local gry2 `r(p16)';
    **                     local ora1 `r(p3)'; local ora2 `r(p4)'; local pur1 `r(p9)'; local pur2 `r(p10)';
    ** Colorblind friendly palette (Bischof, 2017b);
    ** Bischof, D. 2017b. New graphic schemes for Stata: plotplain and plottig.  The Stata Journal 17(3): 748–759;
    colorpalette cblind, select(1 2 4 5 9 8 7 3 6) nograph;
    local list r(p);    local blk `r(p1)'; local gry `r(p2)'; local bl1 `r(p3)';  local gre `r(p4)'; local pur `r(p5)'; 
                        local red `r(p6)'; local bl2 `r(p7)'; local ora `r(p8)'; local yel `r(p9)';
    #delimit cr

    ** Column X-location for death metrics 
    ** Max of first panel = 144
    gen xloc2 = 240
    gen xloc3 = 335
    gen pd = round(ch) 
    gen ad = int(d19 - d00)
    format ad %10.0fc

    ** Boxes around metrics
    local box1 0.5 220 33.5 220 33.5 260 0.5 260
    local box2 0.5 280 33.5 280 33.5 400 0.5 400

    sort ch

** Decomposition chart
#delimit ;
	graph twoway 
		///epi change (usually negative, but not always)
		(rbar zero ep y, horizontal barwidth(.75)  lc("`gre'*0.8") lw(0.05) fc("`gre'*0.8")) 
		/// Change due to Population Aging
		(rbar basepop addage y , horizontal barwidth(.75)  lc("`ora'*0.8") lw(0.05) fc("`ora'*0.8")) 
		/// Change due to Population Growth
		(rbar addage addpop y , horizontal barwidth(.75)  lc("`bl2'*0.8") lw(0.05) fc("`bl2'*0.8")) 
		/// Vertical Zero Line
		(line y realzero, lcolor("`gry'") lp(l) lc("`gry'")) 
		/// Overall Change point
		(scatter y ch, msymbol(O) mlcolor("`gry'") mfcolor(gs16) msize(2))
        
        /// Boxes around metrics
		(scatteri `box1'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		(scatteri `box2'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))

		/// Percentage change in deaths
		(sc y xloc2, msymbol(i) mlabel(pd) mlabsize(2.5) mlabcol(gs8) mlabp(0))
		/// Actual change in numbers of deaths
		(sc y xloc3, msymbol(i) mlabel(ad) mlabsize(2.5) mlabcol(gs8) mlabp(0))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(15) xsize(10)
	
		xlabel(-100(50)250, labsize(2.5) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2.5)) 

		ylabel(1(1)33
		, notick grid valuelabel angle(0) labsize(2.5) labcolor(gs10)) 
		ytitle(" ", axis(1)) 
		yscale(noline range(1(1)35))

        text(-2.5 50 "Percent Change in DALYs" "2000-2019", place(c) size(3) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 240 "Percent" "Change", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))
        text(35 335 "Extra" "DALYs", place(c) size(2.5) color("gs8") just(center) margin(l=2 r=2 t=4 b=2))

		legend(order(5 1 2 3) keygap(2) rowgap(2) linegap(0.75)
		label(1 "Change due to age-" "specific DALY rates")  
		label(2 "Change due to" "population aging") 
		label(3 "Change due to" "population growth") 
		label(5 "Change in DALYs") 
		cols(2) position(6) size(2.5) symysize(3) color(gs8)
		) 
		name(daly_est)
	;
#delimit cr

