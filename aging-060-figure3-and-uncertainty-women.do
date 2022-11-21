** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    aging-060-figure3-and-uncertainty.do
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
    log using "`logpath'\aging-060-figure3-and-uncertainty", replace
** HEADER -----------------------------------------------------




** ----------------------------------------------------------
** (A) Decomposition chart
** (i) DEATH - POINT ESTIMATE
** ----------------------------------------------------------

    ** Use the decomposition dataset, then will be used for sensitivity analyses
    use "`datapath'\from-who\decomposition_women", clear
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
    label define y         32 "St.Vincent & Gren"
                            11 "Antigua & Barbuda"
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
    gen xloc3 = 300
    gen pd = round(ch) 
    gen ad = int(d19 - d00)
    format ad %10.0fc

    ** Manual Boxes and Lines 
    ** Two boxes to surround the vertical metrics
    local box1 0.5 220 34 220 34 260 0.5 260
    local box2 0.5 270 34 270 34 330 0.5 330
    ** X-axis ticks
    local tick0 -1 -100 -1.75 -100
    local tick1 -1 -50 -1.75 -50
    local tick2 -1 0 -1.75 0
    local tick3 -1 50 -1.75 50
    local tick4 -1 100 -1.75 100
    local tick5 -1 150 -1.75 150
    local tick6 -1 200 -1.75 200
    local tick7 -1 250 -1.75 250
    local tick8a -1 350 -1.75 350
    local tick8 -1 400 -1.75 400
    local tick9 -1 450 -1.75 450
    local tick10 -1 500 -1.75 500
    local tick11 -1 550 -1.75 550
    local tick12 -1 600 -1.75 600
    local tick13 -1 650 -1.75 650
    local tick14 -1 700 -1.75 700
    ** Legend shapes
    local leg_circle 39.5 -100 
    local leg1 39 0   40 0   40 25   39 25   39 0 
    local leg2 39 215   40 215   40 240   39 240   39 215 
    local leg3 39 390   40 390   40 415   39 415   39 390 

    ** We develop the graphic to be TWO graph panels in a single graphic
    ** This involves shifting the x-axis values for the CI chart
    local shift = 450
    gen realzero_shift = `shift'
    gen ch_shift  = ch  + `shift'
    gen ch2_shift = ch2 + `shift'
    gen ch3_shift = ch3 + `shift'


** CHART
    sort ch
    #delimit ;
	graph twoway 
		/// PANEL A. DECOMPOSITION CHART
		/// Vertical Zero Line
		(line y realzero, lcolor("`red'*0.25") lp(l) lc("`blk'*0.25")) 
        ///epi change (usually negative, but not always)
		(rbar zero ep y, horizontal barwidth(.75)  lc("`gre'*0.8") lw(0.05) fc("`gre'*0.8")) 
		/// Change due to Population Aging
		(rbar basepop addage y , horizontal barwidth(.75)  lc("`ora'*0.8") lw(0.05) fc("`ora'*0.8")) 
		/// Change due to Population Growth
		(rbar addage addpop y , horizontal barwidth(.75)  lc("`bl2'*0.8") lw(0.05) fc("`bl2'*0.8")) 
		/// Overall Change point
		(scatter y ch, msymbol(O) mlcolor("`blk'") mfcolor("gs16") msize(1.15) mlw(0.1))
        /// Boxes around metrics
		(scatteri `box1'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		(scatteri `box2'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		/// Percentage change in deaths
		(sc y xloc2, msymbol(i) mlabel(pd) mlabsize(1.75) mlabcol(gs8) mlabp(0))
		/// Actual change in numbers of deaths
		(sc y xloc3, msymbol(i) mlabel(ad) mlabsize(1.75) mlabcol(gs8) mlabp(0))

		/// PANEL B. UNCERTAINTY LIMIT CHART
		/// Vertical Zero Line
		(line y realzero_shift, lp(l) lc("`blk'*0.25")) 
        ///epi change (usually negative, but not always)
		(rbar ch2_shift ch3_shift y, barwidth(0.1) horizontal lc("`blk'") fc("`blk'") lw(0.1) ) 
		/// Overall Change point
		(scatter y ch_shift, msymbol(O) mlcolor("`blk'") mfcolor("gs16") msize(1.15) mlw(0.1))

        /// X-axes
        (function y=-1, range(350 700) lp("l") lc("`gry'") lw(0.1))
        (function y=-1, range(-100 250) lp("l") lc("`gry'") lw(0.1))
        (scatteri `tick0' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick1' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick2' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick3' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick4' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick5' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick6' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick7' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick8a' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick8' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick9' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick10' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick11' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick12' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick13' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick14' , recast(line) lw(0.1) lc("`gry'"))

        /// Legend
        (scatteri `leg_circle' , msymbol(O) msize(1.15) mlw(0.1) mlc("`blk'") mfc("gs16"))
        (scatteri `leg1' , recast(area) lw(none) lc("`gry'%35") fc("`gre'%35")  )
        (scatteri `leg2' , recast(area) lw(none) lc("`gry'%35") fc("`ora'%35")  )
        (scatteri `leg3' , recast(area) lw(none) lc("`gry'%35") fc("`bl2'%35")  )
        (function y=39.5, range(560 590) lp("l") lc("`blk'") lw(0.2))
        (function y=38, range(-100 650) lp("l") lc("`gry'") lw(0.1))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(12) xsize(16)
	
		xlabel(none, labsize(2) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2)) 

		ylabel(1(1)33
		, notick valuelabel angle(0) labsize(2) labcolor("`gry'") grid glc(gs10) glw(0.15) glp(".")) 
		ytitle(" ", axis(1)) 
		yscale(noline range(-5(1)36))

        /// Legend text
        text(40 -97 "Change" "in deaths", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40  18 "Change due to age-" "specific mortality rates", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 232 "Change due to" "population aging", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 407 "Change due to" "population growth", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 583 "95% UI", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))

        /// x-axis numbers
        text(-3 -100 "-100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 -50 "-50", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 0 "0",     place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 50 "50",   place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 100 "100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 150 "150", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 200 "200", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 250 "250", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 350 "-100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 400 "-50", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 450 "0",   place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 500 "50",  place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 550 "100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 600 "150", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 650 "200", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 700 "250", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))

        /// x-axis title
        text(-6 100 "Percent Change in Deaths" "2000-2019", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=1 b=0))
        text(-6 550 "Percent Change in Deaths" "2000-2019", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=1 b=0))
        text(35.5 240 "Percent" "Change", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=0 b=2))
        text(35.5 300 "Extra" "Deaths", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=0 b=2))

		legend(off order(5 1 2 3 10) keygap(2) rowgap(1) linegap(0.45)
		label(1 "Change due to age-" "specific mortality rates")  
		label(2 "Change due to" "population aging") 
		label(3 "Change due to" "population growth") 
		label(5 "Change" "in deaths") 
		label(10 "95% Uncertainty" "interval") 
		cols(5) position(6) size(2) symysize(2) color(gs8)
		) 
		name(deaths_est_women)
	;
#delimit cr
graph export "`outputpath'/figure3a_deaths_women.png", replace width(4000)

** Page 2 of UI report
** Table of Uncertainty
sort iso3c

** ------------------------------------------
** PDF of Figure 3A
** DEATHS
** ------------------------------------------
putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)
** FIGURE
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Figure 3a"), bold font("Calibri Light", 12)
    putpdf table t2 = (1,1), width(90%) halign(center) border(all,nil) 
    putpdf table t2(1,1)=image("`outputpath'/figure3a_deaths_women.png")
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Data from: "), bold font("Calibri Light", 10)
    putpdf text ("UN DESA, Population Division (2019). World Population Prospects (Ref. 16), and from WHO Global Health Estimates (2019). (Refs. 19-21)"), font("Calibri Light", 10)
** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/figure3a_women", replace





** ----------------------------------------------------------
** (A) Decomposition chart
** (i) DEATH - LOWER BOUND
** ----------------------------------------------------------

    ** Use the decomposition dataset, then will be used for sensitivity analyses
    use "`datapath'\from-who\decomposition_women", clear
    keep if type == 1

    rename ch2 ch
    rename as2 as
    rename gr2 gr
    rename ep2 ep
    rename d00_2 d00
    rename d19_2 d19

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
                            6 "Antigua & Barbuda"
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
    gen xloc3 = 300
    gen pd = round(ch) 
    gen ad = int(d19 - d00)
    format ad %10.0fc

    ** Manual Boxes and Lines 
    ** Two boxes to surround the vertical metrics
    local box1 0.5 220 34 220 34 260 0.5 260
    local box2 0.5 270 34 270 34 330 0.5 330
    ** X-axis ticks
    local tick0 -1 -100 -1.75 -100
    local tick1 -1 -50 -1.75 -50
    local tick2 -1 0 -1.75 0
    local tick3 -1 50 -1.75 50
    local tick4 -1 100 -1.75 100
    local tick5 -1 150 -1.75 150
    local tick6 -1 200 -1.75 200
    local tick7 -1 250 -1.75 250
    local tick8a -1 350 -1.75 350
    local tick8 -1 400 -1.75 400
    local tick9 -1 450 -1.75 450
    local tick10 -1 500 -1.75 500
    local tick11 -1 550 -1.75 550
    local tick12 -1 600 -1.75 600
    local tick13 -1 650 -1.75 650
    local tick14 -1 700 -1.75 700
    ** Legend shapes
    local leg_circle 39.5 -100 
    local leg1 39 0   40 0   40 25   39 25   39 0 
    local leg2 39 215   40 215   40 240   39 240   39 215 
    local leg3 39 390   40 390   40 415   39 415   39 390 

    ** We develop the graphic to be TWO graph panels in a single graphic
    ** This involves shifting the x-axis values for the CI chart
    local shift = 450
    gen realzero_shift = `shift'
    gen ch1_shift  = ch1  + `shift'
    gen ch_shift = ch + `shift'
    gen ch3_shift = ch3 + `shift'


** CHART
    sort ch
    #delimit ;
	graph twoway 
		/// PANEL A. DECOMPOSITION CHART
		/// Vertical Zero Line
		(line y realzero, lcolor("`red'*0.25") lp(l) lc("`blk'*0.25")) 
        ///epi change (usually negative, but not always)
		(rbar zero ep y, horizontal barwidth(.75)  lc("`gre'*0.8") lw(0.05) fc("`gre'*0.8")) 
		/// Change due to Population Aging
		(rbar basepop addage y , horizontal barwidth(.75)  lc("`ora'*0.8") lw(0.05) fc("`ora'*0.8")) 
		/// Change due to Population Growth
		(rbar addage addpop y , horizontal barwidth(.75)  lc("`bl2'*0.8") lw(0.05) fc("`bl2'*0.8")) 
		/// Overall Change point
		(scatter y ch, msymbol(O) mlcolor("`blk'") mfcolor("gs16") msize(1.15) mlw(0.1))
        /// Boxes around metrics
		(scatteri `box1'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		(scatteri `box2'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		/// Percentage change in deaths
		(sc y xloc2, msymbol(i) mlabel(pd) mlabsize(1.75) mlabcol(gs8) mlabp(0))
		/// Actual change in numbers of deaths
		(sc y xloc3, msymbol(i) mlabel(ad) mlabsize(1.75) mlabcol(gs8) mlabp(0))

		/// PANEL B. UNCERTAINTY LIMIT CHART
		/// Vertical Zero Line
		(line y realzero_shift, lp(l) lc("`blk'*0.25")) 
        ///epi change (usually negative, but not always)
		(rbar ch_shift ch3_shift y, barwidth(0.1) horizontal lc("`blk'") fc("`blk'") lw(0.1) ) 
		/// Overall Change point
		(scatter y ch_shift, msymbol(O) mlcolor("`blk'") mfcolor("gs16") msize(1.15) mlw(0.1))

        /// X-axes
        (function y=-1, range(350 700) lp("l") lc("`gry'") lw(0.1))
        (function y=-1, range(-100 250) lp("l") lc("`gry'") lw(0.1))
        (scatteri `tick0' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick1' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick2' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick3' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick4' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick5' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick6' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick7' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick8a' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick8' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick9' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick10' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick11' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick12' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick13' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick14' , recast(line) lw(0.1) lc("`gry'"))

        /// Legend
        (scatteri `leg_circle' , msymbol(O) msize(1.15) mlw(0.1) mlc("`blk'") mfc("gs16"))
        (scatteri `leg1' , recast(area) lw(none) lc("`gry'%35") fc("`gre'%35")  )
        (scatteri `leg2' , recast(area) lw(none) lc("`gry'%35") fc("`ora'%35")  )
        (scatteri `leg3' , recast(area) lw(none) lc("`gry'%35") fc("`bl2'%35")  )
        (function y=39.5, range(560 590) lp("l") lc("`blk'") lw(0.2))
        (function y=38, range(-100 650) lp("l") lc("`gry'") lw(0.1))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(12) xsize(16)
	
		xlabel(none, labsize(2) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2)) 

		ylabel(1(1)33
		, notick valuelabel angle(0) labsize(2) labcolor("`gry'") grid glc(gs10) glw(0.15) glp(".")) 
		ytitle(" ", axis(1)) 
		yscale(noline range(-5(1)36))

        /// Legend text
        text(40 -97 "Change" "in deaths", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40  18 "Change due to age-" "specific mortality rates", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 232 "Change due to" "population aging", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 407 "Change due to" "population growth", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 583 "95% UI", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))

        /// x-axis numbers
        text(-3 -100 "-100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 -50 "-50", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 0 "0",     place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 50 "50",   place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 100 "100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 150 "150", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 200 "200", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 250 "250", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 350 "-100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 400 "-50", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 450 "0",   place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 500 "50",  place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 550 "100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 600 "150", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 650 "200", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 700 "250", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))

        /// x-axis title
        text(-6 100 "Percent Change in Deaths" "2000-2019", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=1 b=0))
        text(-6 550 "Percent Change in Deaths" "2000-2019", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=1 b=0))
        text(35.5 240 "Percent" "Change", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=0 b=2))
        text(35.5 300 "Extra" "Deaths", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=0 b=2))

		legend(off order(5 1 2 3 10) keygap(2) rowgap(1) linegap(0.45)
		label(1 "Change due to age-" "specific mortality rates")  
		label(2 "Change due to" "population aging") 
		label(3 "Change due to" "population growth") 
		label(5 "Change" "in deaths") 
		label(10 "95% Uncertainty" "interval") 
		cols(5) position(6) size(2) symysize(2) color(gs8)
		) 
		name(deaths_est_women_lo)
	;
#delimit cr
graph export "`outputpath'/figure3a_deaths_women_lo.png", replace width(4000)



** ------------------------------------------
** PDF of Figure 3A
** DEATHS
** ------------------------------------------
putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)
** FIGURE
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Figure 3a. Lower UI bound"), bold font("Calibri Light", 12)
    putpdf table t2 = (1,1), width(90%) halign(center) border(all,nil) 
    putpdf table t2(1,1)=image("`outputpath'/figure3a_deaths_women_lo.png")
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Data from: "), bold font("Calibri Light", 10)
    putpdf text ("UN DESA, Population Division (2019). World Population Prospects (Ref. 16), and from WHO Global Health Estimates (2019). (Refs. 19-21)"), font("Calibri Light", 10)
** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/figure3a_women_lo", replace






** ----------------------------------------------------------
** (A) Decomposition chart
** (i) DEATH - UPPER BOUND
** ----------------------------------------------------------

    ** Use the decomposition dataset, then will be used for sensitivity analyses
    use "`datapath'\from-who\decomposition_women", clear
    keep if type == 1

    rename ch3 ch
    rename as3 as
    rename gr3 gr
    rename ep3 ep
    rename d00_3 d00
    rename d19_3 d19

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
    label define y         32 "St.Vincent & Gren"
                            15 "Antigua & Barbuda"
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
    gen xloc3 = 300
    gen pd = round(ch) 
    gen ad = int(d19 - d00)
    format ad %10.0fc

    ** Manual Boxes and Lines 
    ** Two boxes to surround the vertical metrics
    local box1 0.5 220 34 220 34 260 0.5 260
    local box2 0.5 270 34 270 34 330 0.5 330
    ** X-axis ticks
    local tick0 -1 -100 -1.75 -100
    local tick1 -1 -50 -1.75 -50
    local tick2 -1 0 -1.75 0
    local tick3 -1 50 -1.75 50
    local tick4 -1 100 -1.75 100
    local tick5 -1 150 -1.75 150
    local tick6 -1 200 -1.75 200
    local tick7 -1 250 -1.75 250
    local tick8a -1 350 -1.75 350
    local tick8 -1 400 -1.75 400
    local tick9 -1 450 -1.75 450
    local tick10 -1 500 -1.75 500
    local tick11 -1 550 -1.75 550
    local tick12 -1 600 -1.75 600
    local tick13 -1 650 -1.75 650
    local tick14 -1 700 -1.75 700
    ** Legend shapes
    local leg_circle 39.5 -100 
    local leg1 39 0   40 0   40 25   39 25   39 0 
    local leg2 39 215   40 215   40 240   39 240   39 215 
    local leg3 39 390   40 390   40 415   39 415   39 390 

    ** We develop the graphic to be TWO graph panels in a single graphic
    ** This involves shifting the x-axis values for the CI chart
    local shift = 450
    gen realzero_shift = `shift'
    gen ch1_shift  = ch1  + `shift'
    gen ch2_shift = ch2 + `shift'
    gen ch_shift = ch + `shift'


** CHART
    sort ch
    #delimit ;
	graph twoway 
		/// PANEL A. DECOMPOSITION CHART
		/// Vertical Zero Line
		(line y realzero, lcolor("`red'*0.25") lp(l) lc("`blk'*0.25")) 
        ///epi change (usually negative, but not always)
		(rbar zero ep y, horizontal barwidth(.75)  lc("`gre'*0.8") lw(0.05) fc("`gre'*0.8")) 
		/// Change due to Population Aging
		(rbar basepop addage y , horizontal barwidth(.75)  lc("`ora'*0.8") lw(0.05) fc("`ora'*0.8")) 
		/// Change due to Population Growth
		(rbar addage addpop y , horizontal barwidth(.75)  lc("`bl2'*0.8") lw(0.05) fc("`bl2'*0.8")) 
		/// Overall Change point
		(scatter y ch, msymbol(O) mlcolor("`blk'") mfcolor("gs16") msize(1.15) mlw(0.1))
        /// Boxes around metrics
		(scatteri `box1'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		(scatteri `box2'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		/// Percentage change in deaths
		(sc y xloc2, msymbol(i) mlabel(pd) mlabsize(1.75) mlabcol(gs8) mlabp(0))
		/// Actual change in numbers of deaths
		(sc y xloc3, msymbol(i) mlabel(ad) mlabsize(1.75) mlabcol(gs8) mlabp(0))

		/// PANEL B. UNCERTAINTY LIMIT CHART
		/// Vertical Zero Line
		(line y realzero_shift, lp(l) lc("`blk'*0.25")) 
        ///epi change (usually negative, but not always)
		(rbar ch2_shift ch_shift y, barwidth(0.1) horizontal lc("`blk'") fc("`blk'") lw(0.1) ) 
		/// Overall Change point
		(scatter y ch_shift, msymbol(O) mlcolor("`blk'") mfcolor("gs16") msize(1.15) mlw(0.1))

        /// X-axes
        (function y=-1, range(350 700) lp("l") lc("`gry'") lw(0.1))
        (function y=-1, range(-100 250) lp("l") lc("`gry'") lw(0.1))
        (scatteri `tick0' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick1' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick2' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick3' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick4' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick5' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick6' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick7' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick8a' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick8' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick9' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick10' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick11' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick12' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick13' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick14' , recast(line) lw(0.1) lc("`gry'"))

        /// Legend
        (scatteri `leg_circle' , msymbol(O) msize(1.15) mlw(0.1) mlc("`blk'") mfc("gs16"))
        (scatteri `leg1' , recast(area) lw(none) lc("`gry'%35") fc("`gre'%35")  )
        (scatteri `leg2' , recast(area) lw(none) lc("`gry'%35") fc("`ora'%35")  )
        (scatteri `leg3' , recast(area) lw(none) lc("`gry'%35") fc("`bl2'%35")  )
        (function y=39.5, range(560 590) lp("l") lc("`blk'") lw(0.2))
        (function y=38, range(-100 650) lp("l") lc("`gry'") lw(0.1))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(12) xsize(16)
	
		xlabel(none, labsize(2) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2)) 

		ylabel(1(1)33
		, notick valuelabel angle(0) labsize(2) labcolor("`gry'") grid glc(gs10) glw(0.15) glp(".")) 
		ytitle(" ", axis(1)) 
		yscale(noline range(-5(1)36))

        /// Legend text
        text(40 -97 "Change" "in deaths", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40  18 "Change due to age-" "specific mortality rates", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 232 "Change due to" "population aging", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 407 "Change due to" "population growth", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 583 "95% UI", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))

        /// x-axis numbers
        text(-3 -100 "-100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 -50 "-50", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 0 "0",     place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 50 "50",   place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 100 "100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 150 "150", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 200 "200", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 250 "250", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 350 "-100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 400 "-50", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 450 "0",   place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 500 "50",  place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 550 "100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 600 "150", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 650 "200", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 700 "250", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))

        /// x-axis title
        text(-6 100 "Percent Change in Deaths" "2000-2019", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=1 b=0))
        text(-6 550 "Percent Change in Deaths" "2000-2019", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=1 b=0))
        text(35.5 240 "Percent" "Change", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=0 b=2))
        text(35.5 300 "Extra" "Deaths", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=0 b=2))

		legend(off order(5 1 2 3 10) keygap(2) rowgap(1) linegap(0.45)
		label(1 "Change due to age-" "specific mortality rates")  
		label(2 "Change due to" "population aging") 
		label(3 "Change due to" "population growth") 
		label(5 "Change" "in deaths") 
		label(10 "95% Uncertainty" "interval") 
		cols(5) position(6) size(2) symysize(2) color(gs8)
		) 
		name(deaths_est_women_hi)
	;
#delimit cr
graph export "`outputpath'/figure3a_deaths_women_hi.png", replace width(4000)

** Page 2 of UI report
** Table of Uncertainty
sort iso3c

** ------------------------------------------
** PDF of Figure 3A
** DEATHS
** ------------------------------------------
putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)
** FIGURE
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Figure 3a. Upper UI bound"), bold font("Calibri Light", 12)
    putpdf table t2 = (1,1), width(90%) halign(center) border(all,nil) 
    putpdf table t2(1,1)=image("`outputpath'/figure3a_deaths_women_hi.png")
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Data from: "), bold font("Calibri Light", 10)
    putpdf text ("UN DESA, Population Division (2019). World Population Prospects (Ref. 16), and from WHO Global Health Estimates (2019). (Refs. 19-21)"), font("Calibri Light", 10)
** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/figure3a_women_hi", replace










** ----------------------------------------------------------
** (A) Decomposition chart
** (i) DALY - POINT ESTIMATE
** ----------------------------------------------------------

    ** Use the decomposition dataset, then will be used for sensitivity analyses
    use "`datapath'\from-who\decomposition_women", clear
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
    label define y         31 "St.Vincent & Gren"
                            7 "Antigua & Barbuda"
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
    gen xloc3 = 310
    gen pd = round(ch) 
    gen ad = int(d19 - d00)
    format ad %10.0fc

    ** Manual Boxes and Lines 
    ** Two boxes to surround the vertical metrics
    local box1 0.5 220 34 220 34 260 0.5 260
    local box2 0.5 270 34 270 34 350 0.5 350
    ** X-axis ticks
    local tick0 -1 -100 -1.75 -100
    local tick1 -1 -50 -1.75 -50
    local tick2 -1 0 -1.75 0
    local tick3 -1 50 -1.75 50
    local tick4 -1 100 -1.75 100
    local tick5 -1 150 -1.75 150
    local tick6 -1 200 -1.75 200
    local tick7 -1 250 -1.75 250
    local tick8a -1 350 -1.75 350
    local tick8 -1 400 -1.75 400
    local tick9 -1 450 -1.75 450
    local tick10 -1 500 -1.75 500
    local tick11 -1 550 -1.75 550
    local tick12 -1 600 -1.75 600
    local tick13 -1 650 -1.75 650
    local tick14 -1 700 -1.75 700
    ** Legend shapes
    local leg_circle 39.5 -100 
    local leg1 39 0   40 0   40 25   39 25   39 0 
    local leg2 39 215   40 215   40 240   39 240   39 215 
    local leg3 39 390   40 390   40 415   39 415   39 390 

    ** We develop the graphic to be TWO graph panels in a single graphic
    ** This involves shifting the x-axis values for the CI chart
    local shift = 450
    gen realzero_shift = `shift'
    gen ch_shift  = ch  + `shift'
    gen ch2_shift = ch2 + `shift'
    gen ch3_shift = ch3 + `shift'


** CHART
    sort ch
    #delimit ;
	graph twoway 
		/// PANEL A. DECOMPOSITION CHART
		/// Vertical Zero Line
		(line y realzero, lcolor("`red'*0.25") lp(l) lc("`blk'*0.25")) 
        ///epi change (usually negative, but not always)
		(rbar zero ep y, horizontal barwidth(.75)  lc("`gre'*0.8") lw(0.05) fc("`gre'*0.8")) 
		/// Change due to Population Aging
		(rbar basepop addage y , horizontal barwidth(.75)  lc("`ora'*0.8") lw(0.05) fc("`ora'*0.8")) 
		/// Change due to Population Growth
		(rbar addage addpop y , horizontal barwidth(.75)  lc("`bl2'*0.8") lw(0.05) fc("`bl2'*0.8")) 
		/// Overall Change point
		(scatter y ch, msymbol(O) mlcolor("`blk'") mfcolor("gs16") msize(1.15) mlw(0.1))
        /// Boxes around metrics
		(scatteri `box1'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		(scatteri `box2'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		/// Percentage change in deaths
		(sc y xloc2, msymbol(i) mlabel(pd) mlabsize(1.75) mlabcol(gs8) mlabp(0))
		/// Actual change in numbers of deaths
		(sc y xloc3, msymbol(i) mlabel(ad) mlabsize(1.75) mlabcol(gs8) mlabp(0))

		/// PANEL B. UNCERTAINTY LIMIT CHART
		/// Vertical Zero Line
		(line y realzero_shift, lp(l) lc("`blk'*0.25")) 
        ///epi change (usually negative, but not always)
		(rbar ch2_shift ch3_shift y, barwidth(0.1) horizontal lc("`blk'") fc("`blk'") lw(0.1) ) 
		/// Overall Change point
		(scatter y ch_shift, msymbol(O) mlcolor("`blk'") mfcolor("gs16") msize(1.15) mlw(0.1))

        /// X-axes
        (function y=-1, range(350 700) lp("l") lc("`gry'") lw(0.1))
        (function y=-1, range(-100 250) lp("l") lc("`gry'") lw(0.1))
        (scatteri `tick0' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick1' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick2' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick3' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick4' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick5' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick6' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick7' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick8a' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick8' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick9' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick10' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick11' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick12' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick13' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick14' , recast(line) lw(0.1) lc("`gry'"))

        /// Legend
        (scatteri `leg_circle' , msymbol(O) msize(1.15) mlw(0.1) mlc("`blk'") mfc("gs16"))
        (scatteri `leg1' , recast(area) lw(none) lc("`gry'%35") fc("`gre'%35")  )
        (scatteri `leg2' , recast(area) lw(none) lc("`gry'%35") fc("`ora'%35")  )
        (scatteri `leg3' , recast(area) lw(none) lc("`gry'%35") fc("`bl2'%35")  )
        (function y=39.5, range(560 590) lp("l") lc("`blk'") lw(0.2))
        (function y=38, range(-100 650) lp("l") lc("`gry'") lw(0.1))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(12) xsize(16)
	
		xlabel(none, labsize(2) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2)) 

		ylabel(1(1)33
		, notick valuelabel angle(0) labsize(2) labcolor("`gry'") grid glc(gs10) glw(0.15) glp(".")) 
		ytitle(" ", axis(1)) 
		yscale(noline range(-5(1)36))

        /// Legend text
        text(40 -97 "Change" "in DALYs", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40  18 "Change due to age-" "specific DALY rates", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 232 "Change due to" "population aging", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 407 "Change due to" "population growth", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 583 "95% UI", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))

        /// x-axis numbers
        text(-3 -100 "-100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 -50 "-50", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 0 "0",     place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 50 "50",   place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 100 "100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 150 "150", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 200 "200", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 250 "250", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 350 "-100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 400 "-50", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 450 "0",   place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 500 "50",  place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 550 "100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 600 "150", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 650 "200", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 700 "250", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))

        /// x-axis title
        text(-6 100 "Percent Change in DALYs" "2000-2019", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=1 b=0))
        text(-6 550 "Percent Change in DALYs" "2000-2019", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=1 b=0))
        text(35.5 240 "Percent" "Change", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=0 b=2))
        text(35.5 300 "Extra" "DALYs", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=0 b=2))

		legend(off order(5 1 2 3 10) keygap(2) rowgap(1) linegap(0.45)
		label(1 "Change due to age-" "specific mortality rates")  
		label(2 "Change due to" "population aging") 
		label(3 "Change due to" "population growth") 
		label(5 "Change" "in DALYs") 
		label(10 "95% Uncertainty" "interval") 
		cols(5) position(6) size(2) symysize(2) color(gs8)
		) 
		name(daly_est_women)
	;
#delimit cr
graph export "`outputpath'/figure3b_daly_women.png", replace width(4000)

** ------------------------------------------
** PDF of Figure 3A
** DALY
** ------------------------------------------
putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)
** FIGURE
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Figure 3a"), bold font("Calibri Light", 12)
    putpdf table t2 = (1,1), width(90%) halign(center) border(all,nil) 
    putpdf table t2(1,1)=image("`outputpath'/figure3b_daly_women.png")
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Data from: "), bold font("Calibri Light", 10)
    putpdf text ("UN DESA, Population Division (2019). World Population Prospects (Ref. 16), and from WHO Global Health Estimates (2019). (Refs. 19-21)"), font("Calibri Light", 10)
** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/figure3b_women", replace




** ----------------------------------------------------------
** (A) Decomposition chart
** (i) DALY - LOWER BOUND
** ----------------------------------------------------------

    ** Use the decomposition dataset, then will be used for sensitivity analyses
    use "`datapath'\from-who\decomposition_women", clear
    keep if type == 2

    rename ch2 ch
    rename as2 as
    rename gr2 gr
    rename ep2 ep
    rename d00_2 d00
    rename d19_2 d19

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
    label define y         31 "St.Vincent & Gren"
                            3 "Antigua & Barbuda"
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
    gen xloc3 = 310
    gen pd = round(ch) 
    gen ad = int(d19 - d00)
    format ad %10.0fc

    ** Manual Boxes and Lines 
    ** Two boxes to surround the vertical metrics
    local box1 0.5 220 34 220 34 260 0.5 260
    local box2 0.5 270 34 270 34 350 0.5 350
    ** X-axis ticks
    local tick0 -1 -100 -1.75 -100
    local tick1 -1 -50 -1.75 -50
    local tick2 -1 0 -1.75 0
    local tick3 -1 50 -1.75 50
    local tick4 -1 100 -1.75 100
    local tick5 -1 150 -1.75 150
    local tick6 -1 200 -1.75 200
    local tick7 -1 250 -1.75 250
    local tick8a -1 350 -1.75 350
    local tick8 -1 400 -1.75 400
    local tick9 -1 450 -1.75 450
    local tick10 -1 500 -1.75 500
    local tick11 -1 550 -1.75 550
    local tick12 -1 600 -1.75 600
    local tick13 -1 650 -1.75 650
    local tick14 -1 700 -1.75 700
    ** Legend shapes
    local leg_circle 39.5 -100 
    local leg1 39 0   40 0   40 25   39 25   39 0 
    local leg2 39 215   40 215   40 240   39 240   39 215 
    local leg3 39 390   40 390   40 415   39 415   39 390 

    ** We develop the graphic to be TWO graph panels in a single graphic
    ** This involves shifting the x-axis values for the CI chart
    local shift = 450
    gen realzero_shift = `shift'
    gen ch1_shift  = ch1  + `shift'
    gen ch_shift = ch + `shift'
    gen ch3_shift = ch3 + `shift'


** CHART
    sort ch
    #delimit ;
	graph twoway 
		/// PANEL A. DECOMPOSITION CHART
		/// Vertical Zero Line
		(line y realzero, lcolor("`red'*0.25") lp(l) lc("`blk'*0.25")) 
        ///epi change (usually negative, but not always)
		(rbar zero ep y, horizontal barwidth(.75)  lc("`gre'*0.8") lw(0.05) fc("`gre'*0.8")) 
		/// Change due to Population Aging
		(rbar basepop addage y , horizontal barwidth(.75)  lc("`ora'*0.8") lw(0.05) fc("`ora'*0.8")) 
		/// Change due to Population Growth
		(rbar addage addpop y , horizontal barwidth(.75)  lc("`bl2'*0.8") lw(0.05) fc("`bl2'*0.8")) 
		/// Overall Change point
		(scatter y ch, msymbol(O) mlcolor("`blk'") mfcolor("gs16") msize(1.15) mlw(0.1))
        /// Boxes around metrics
		(scatteri `box1'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		(scatteri `box2'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		/// Percentage change in deaths
		(sc y xloc2, msymbol(i) mlabel(pd) mlabsize(1.75) mlabcol(gs8) mlabp(0))
		/// Actual change in numbers of deaths
		(sc y xloc3, msymbol(i) mlabel(ad) mlabsize(1.75) mlabcol(gs8) mlabp(0))

		/// PANEL B. UNCERTAINTY LIMIT CHART
		/// Vertical Zero Line
		(line y realzero_shift, lp(l) lc("`blk'*0.25")) 
        ///epi change (usually negative, but not always)
		(rbar ch_shift ch3_shift y, barwidth(0.1) horizontal lc("`blk'") fc("`blk'") lw(0.1) ) 
		/// Overall Change point
		(scatter y ch_shift, msymbol(O) mlcolor("`blk'") mfcolor("gs16") msize(1.15) mlw(0.1))

        /// X-axes
        (function y=-1, range(350 700) lp("l") lc("`gry'") lw(0.1))
        (function y=-1, range(-100 250) lp("l") lc("`gry'") lw(0.1))
        (scatteri `tick0' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick1' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick2' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick3' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick4' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick5' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick6' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick7' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick8a' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick8' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick9' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick10' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick11' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick12' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick13' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick14' , recast(line) lw(0.1) lc("`gry'"))

        /// Legend
        (scatteri `leg_circle' , msymbol(O) msize(1.15) mlw(0.1) mlc("`blk'") mfc("gs16"))
        (scatteri `leg1' , recast(area) lw(none) lc("`gry'%35") fc("`gre'%35")  )
        (scatteri `leg2' , recast(area) lw(none) lc("`gry'%35") fc("`ora'%35")  )
        (scatteri `leg3' , recast(area) lw(none) lc("`gry'%35") fc("`bl2'%35")  )
        (function y=39.5, range(560 590) lp("l") lc("`blk'") lw(0.2))
        (function y=38, range(-100 650) lp("l") lc("`gry'") lw(0.1))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(12) xsize(16)
	
		xlabel(none, labsize(2) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2)) 

		ylabel(1(1)33
		, notick valuelabel angle(0) labsize(2) labcolor("`gry'") grid glc(gs10) glw(0.15) glp(".")) 
		ytitle(" ", axis(1)) 
		yscale(noline range(-5(1)36))

        /// Legend text
        text(40 -97 "Change" "in DALYs", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40  18 "Change due to age-" "specific DALY rates", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 232 "Change due to" "population aging", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 407 "Change due to" "population growth", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 583 "95% UI", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))

        /// x-axis numbers
        text(-3 -100 "-100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 -50 "-50", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 0 "0",     place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 50 "50",   place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 100 "100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 150 "150", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 200 "200", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 250 "250", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 350 "-100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 400 "-50", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 450 "0",   place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 500 "50",  place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 550 "100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 600 "150", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 650 "200", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 700 "250", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))

        /// x-axis title
        text(-6 100 "Percent Change in DALYs" "2000-2019", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=1 b=0))
        text(-6 550 "Percent Change in DALYs" "2000-2019", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=1 b=0))
        text(35.5 240 "Percent" "Change", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=0 b=2))
        text(35.5 300 "Extra" "DALYs", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=0 b=2))

		legend(off order(5 1 2 3 10) keygap(2) rowgap(1) linegap(0.45)
		label(1 "Change due to age-" "specific mortality rates")  
		label(2 "Change due to" "population aging") 
		label(3 "Change due to" "population growth") 
		label(5 "Change" "in DALYs") 
		label(10 "95% Uncertainty" "interval") 
		cols(5) position(6) size(2) symysize(2) color(gs8)
		) 
		name(daly_est_women_lo)
	;
#delimit cr
graph export "`outputpath'/figure3b_daly_women_lo.png", replace width(4000)



** ------------------------------------------
** PDF of Figure 3B
** DALY
** ------------------------------------------
putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)
** FIGURE
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Figure 3b. Lower UI bound"), bold font("Calibri Light", 12)
    putpdf table t2 = (1,1), width(90%) halign(center) border(all,nil) 
    putpdf table t2(1,1)=image("`outputpath'/figure3b_daly_women_lo.png")
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Data from: "), bold font("Calibri Light", 10)
    putpdf text ("UN DESA, Population Division (2019). World Population Prospects (Ref. 16), and from WHO Global Health Estimates (2019). (Refs. 19-21)"), font("Calibri Light", 10)
** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/figure3b_women_lo", replace




** ----------------------------------------------------------
** (A) Decomposition chart
** (i) DALY - UPPER BOUND
** ----------------------------------------------------------

    ** Use the decomposition dataset, then will be used for sensitivity analyses
    use "`datapath'\from-who\decomposition_women", clear
    keep if type == 2

    rename ch3 ch
    rename as3 as
    rename gr3 gr
    rename ep3 ep
    rename d00_3 d00
    rename d19_3 d19

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
    label define y         31 "St.Vincent & Gren"
                            7 "Antigua & Barbuda"
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
    gen xloc3 = 310
    gen pd = round(ch) 
    gen ad = int(d19 - d00)
    format ad %10.0fc

    ** Manual Boxes and Lines 
    ** Two boxes to surround the vertical metrics
    local box1 0.5 220 34 220 34 260 0.5 260
    local box2 0.5 270 34 270 34 350 0.5 350
    ** X-axis ticks
    local tick0 -1 -100 -1.75 -100
    local tick1 -1 -50 -1.75 -50
    local tick2 -1 0 -1.75 0
    local tick3 -1 50 -1.75 50
    local tick4 -1 100 -1.75 100
    local tick5 -1 150 -1.75 150
    local tick6 -1 200 -1.75 200
    local tick7 -1 250 -1.75 250
    local tick8a -1 350 -1.75 350
    local tick8 -1 400 -1.75 400
    local tick9 -1 450 -1.75 450
    local tick10 -1 500 -1.75 500
    local tick11 -1 550 -1.75 550
    local tick12 -1 600 -1.75 600
    local tick13 -1 650 -1.75 650
    local tick14 -1 700 -1.75 700
    ** Legend shapes
    local leg_circle 39.5 -100 
    local leg1 39 0   40 0   40 25   39 25   39 0 
    local leg2 39 215   40 215   40 240   39 240   39 215 
    local leg3 39 390   40 390   40 415   39 415   39 390 

    ** We develop the graphic to be TWO graph panels in a single graphic
    ** This involves shifting the x-axis values for the CI chart
    local shift = 450
    gen realzero_shift = `shift'
    gen ch1_shift  = ch1  + `shift'
    gen ch2_shift = ch2 + `shift'
    gen ch_shift = ch + `shift'


** CHART
    sort ch
    #delimit ;
	graph twoway 
		/// PANEL A. DECOMPOSITION CHART
		/// Vertical Zero Line
		(line y realzero, lcolor("`red'*0.25") lp(l) lc("`blk'*0.25")) 
        ///epi change (usually negative, but not always)
		(rbar zero ep y, horizontal barwidth(.75)  lc("`gre'*0.8") lw(0.05) fc("`gre'*0.8")) 
		/// Change due to Population Aging
		(rbar basepop addage y , horizontal barwidth(.75)  lc("`ora'*0.8") lw(0.05) fc("`ora'*0.8")) 
		/// Change due to Population Growth
		(rbar addage addpop y , horizontal barwidth(.75)  lc("`bl2'*0.8") lw(0.05) fc("`bl2'*0.8")) 
		/// Overall Change point
		(scatter y ch, msymbol(O) mlcolor("`blk'") mfcolor("gs16") msize(1.15) mlw(0.1))
        /// Boxes around metrics
		(scatteri `box1'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		(scatteri `box2'  , recast(area) lw(0.2) lc("`gry'") fc("gs14") lp("l"))
		/// Percentage change in deaths
		(sc y xloc2, msymbol(i) mlabel(pd) mlabsize(1.75) mlabcol(gs8) mlabp(0))
		/// Actual change in numbers of deaths
		(sc y xloc3, msymbol(i) mlabel(ad) mlabsize(1.75) mlabcol(gs8) mlabp(0))

		/// PANEL B. UNCERTAINTY LIMIT CHART
		/// Vertical Zero Line
		(line y realzero_shift, lp(l) lc("`blk'*0.25")) 
        ///epi change (usually negative, but not always)
		(rbar ch2_shift ch_shift y, barwidth(0.1) horizontal lc("`blk'") fc("`blk'") lw(0.1) ) 
		/// Overall Change point
		(scatter y ch_shift, msymbol(O) mlcolor("`blk'") mfcolor("gs16") msize(1.15) mlw(0.1))

        /// X-axes
        (function y=-1, range(350 700) lp("l") lc("`gry'") lw(0.1))
        (function y=-1, range(-100 250) lp("l") lc("`gry'") lw(0.1))
        (scatteri `tick0' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick1' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick2' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick3' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick4' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick5' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick6' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick7' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick8a' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick8' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick9' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick10' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick11' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick12' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick13' , recast(line) lw(0.1) lc("`gry'"))
        (scatteri `tick14' , recast(line) lw(0.1) lc("`gry'"))

        /// Legend
        (scatteri `leg_circle' , msymbol(O) msize(1.15) mlw(0.1) mlc("`blk'") mfc("gs16"))
        (scatteri `leg1' , recast(area) lw(none) lc("`gry'%35") fc("`gre'%35")  )
        (scatteri `leg2' , recast(area) lw(none) lc("`gry'%35") fc("`ora'%35")  )
        (scatteri `leg3' , recast(area) lw(none) lc("`gry'%35") fc("`bl2'%35")  )
        (function y=39.5, range(560 590) lp("l") lc("`blk'") lw(0.2))
        (function y=38, range(-100 650) lp("l") lc("`gry'") lw(0.1))

		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
		graphregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(12) xsize(16)
	
		xlabel(none, labsize(2) nogrid labcolor(gs8))
		xscale(noextend) 
		xtitle(" ", margin(top) color(gs0) size(2)) 

		ylabel(1(1)33
		, notick valuelabel angle(0) labsize(2) labcolor("`gry'") grid glc(gs10) glw(0.15) glp(".")) 
		ytitle(" ", axis(1)) 
		yscale(noline range(-5(1)36))

        /// Legend text
        text(40 -97 "Change" "in DALYs", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40  18 "Change due to age-" "specific DALY rates", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 232 "Change due to" "population aging", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 407 "Change due to" "population growth", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))
        text(40 583 "95% UI", place(e) size(2) color("gs8") just(left) margin(l=2 r=2 t=1 b=0))

        /// x-axis numbers
        text(-3 -100 "-100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 -50 "-50", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 0 "0",     place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 50 "50",   place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 100 "100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 150 "150", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 200 "200", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 250 "250", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 350 "-100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 400 "-50", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 450 "0",   place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 500 "50",  place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 550 "100", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 600 "150", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 650 "200", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))
        text(-3 700 "250", place(c) size(2) color("`gry'") just(center) margin(l=2 r=2 t=2 b=2))

        /// x-axis title
        text(-6 100 "Percent Change in DALYs" "2000-2019", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=1 b=0))
        text(-6 550 "Percent Change in DALYs" "2000-2019", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=1 b=0))
        text(35.5 240 "Percent" "Change", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=0 b=2))
        text(35.5 300 "Extra" "DALYs", place(c) size(2) color("gs8") just(center) margin(l=2 r=2 t=0 b=2))

		legend(off order(5 1 2 3 10) keygap(2) rowgap(1) linegap(0.45)
		label(1 "Change due to age-" "specific DALY rates")  
		label(2 "Change due to" "population aging") 
		label(3 "Change due to" "population growth") 
		label(5 "Change" "in DALYs") 
		label(10 "95% Uncertainty" "interval") 
		cols(5) position(6) size(2) symysize(2) color(gs8)
		) 
		name(daly_est_women_hi)
	;
#delimit cr
graph export "`outputpath'/figure3b_daly_women_hi.png", replace width(4000)


** ------------------------------------------
** PDF of Figure 3A
** DALY
** ------------------------------------------
putpdf begin, pagesize(letter) landscape font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)
** FIGURE
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Figure 3b. Upper UI bound"), bold font("Calibri Light", 12)
    putpdf table t2 = (1,1), width(90%) halign(center) border(all,nil) 
    putpdf table t2(1,1)=image("`outputpath'/figure3b_daly_women_hi.png")
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Data from: "), bold font("Calibri Light", 10)
    putpdf text ("UN DESA, Population Division (2019). World Population Prospects (Ref. 16), and from WHO Global Health Estimates (2019). (Refs. 19-21)"), font("Calibri Light", 10)
** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/figure3b_women_hi", replace




** TABLES as WORD DOCUMENTS

** ----------------------------------------------------
** DEATHS and DALYs. POINT ESTIMATE
** ----------------------------------------------------

use "`datapath'\from-who\decomposition_women", clear
decode iso3n , gen(cname)
sort cname
replace cname = "St Vincent & Gren" if cname=="Saint Vincent and the Grenadines"
replace cname = "Dominican Rep" if cname=="Dominican Republic"
replace cname = "Antigua & Barbuda" if cname=="Antigua and Barbuda"
replace cname = "Trinidad & Tobago" if cname=="Trinidad and Tobago"
replace cname = "LAC" if cname ==""

	format ch1 ch2 ch3 %5.1fc 
	format gr1 gr2 gr3 %5.1fc 
	format as1 as2 as3 %5.1fc 
	format ep1 ep2 ep3 %5.1fc 
    format d00_1 d19_1 %12.0fc

	** Begin Table 
	sort type cname 
    putdocx begin , font(calibri light, 9)
	putdocx paragraph 
		putdocx text ("TABLE S10. "), bold
		putdocx text ("Deaths in 2000 and in 2019, and percentage change in deaths between 2000 and 2019, with associated 95% Uncertainty Intervals. Women only."), 
		** Place data 
		putdocx table ss = data("cname type d00_1 d19_1 ch1 ch2 ch3 "), varnames
		** Line colors + Shadng
		///putdocx table ss(2/10,.), border(bottom, single, "e6e6e6")
		///putdocx table ss(12/20,.), border(bottom, single, "e6e6e6")
		putdocx table ss(1,.),  shading("e6e6e6")
		///putdocx table ss(.,1),  shading("e6e6e6")
		** Column and Row headers
		putdocx table ss(1,1) = ("Country"),  font(calibri light,10, "000000")
		putdocx table ss(1,2) = ("Deaths or DALYs"),  font(calibri light,10, "000000")
		putdocx table ss(1,3) = ("Count in 2000"),  font(calibri light,10, "000000")
		putdocx table ss(1,4) = ("Count in 2019"),  font(calibri light,10, "000000")
		putdocx table ss(1,5) = ("Percentage change (2000 to 2019)"),  font(calibri light,10, "000000")
		putdocx table ss(1,6) = ("Lower bound of Uncertainty Interval"),  font(calibri light,10, "000000")
		putdocx table ss(1,7) = ("Upper bound of Uncertainty Interval"),  font(calibri light,10, "000000")

		putdocx save "`outputpath'/decomp_women_ci", replace 
