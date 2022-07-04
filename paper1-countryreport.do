** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    caricom_03profiles.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	31-MAr-2021
    //  algorithm task			    Reading the WHO GHE dataset - disease burden, YLL and DALY

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
    local outputpath "X:\OneDrive - The University of the West Indies\Writing\w003\outputs\articles\paper-ncd\article-draft"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\paper1-140-population-table1-2019", replace
** HEADER -----------------------------------------------------


** -------------------------------------------------------------
** PLAN THE COUNTRY REPORT
** -------------------------------------------------------------
** Will need to re-create each componenet in this file, and save to graph files or globals
** for insertion into PDF report
**  	COUNTRY REPORTS. This will be 33 standardized reports containing the following:
**  	PAGE 1. 
**          (a) Table has THREE rows (Womwn, Men, All)
**              Table columns with the following metrics. 
**  	        (i) Population (2000/2020/2060). 
**  	        (ii) Proportion 70+ (2000/2020/2060). 
**
**  	    (b) Figure 1 squares for the country + for subregion and for LAC with proportion 70+ for women, men, both. 
**              - Rank x out of 33.
**
**  	    (d) 2000 to 2019. Arrows for changes due to growth, aging, epidemiological.
**
**  	    (e) 2020 – 2039 – predictions?
**
**  	PAGE 2. 
**          (a) Give Table 2 for country?
**          (b) Methods
** -------------------------------------------------------------

** Draw on same data that created Table 1 
use "`datapath'/paper1_population2", clear

        ** Keep required years and drop wider world regions:
        keep if year==2000 | year==2020 | year==2040 | year==2060
        drop if paho_subregion==.
        ** UN region
        gen region = 1
        label define region_ 1 "Americas"
        label values region region_ 
        order region, after(iso3n)

        ** Collapse into PAHO sub-regions
        preserve
            tempfile sr_totals
            collapse (sum) a0 a5 a10 a15 a20 a25 a30 a35 a40 a45 a50 a55 a60 a65 a70 a75 a80 a85 a90 a95 a100, by(paho_subregion year sex)
            save `sr_totals', replace
        restore

        ** Collapse into AMERICAS region
        preserve
            tempfile r_totals
            collapse (sum) a0 a5 a10 a15 a20 a25 a30 a35 a40 a45 a50 a55 a60 a65 a70 a75 a80 a85 a90 a95 a100, by(region year sex)
            save `r_totals', replace
        restore

        ** Join sbregional and regional files to country files
        append using `sr_totals'
        append using `r_totals'

        ** Calculate age-group percentages
        egen group1 = rowtotal(a0 a5 a10 a15) 
        egen group2 = rowtotal(a20 a25 a30 a35 a40 a45 a50 a55 a60 a65) 
        egen group3 = rowtotal(a70 a75 a80 a85 a90 a95 a100) 
        egen total = rowtotal(a0 a5 a10 a15 a20 a25 a30 a35 a40 a45 a50 a55 a60 a65 a70 a75 a80 a85 a90 a95 a100) 
        label var group1 "Ages 0-19"
        label var group2 "Ages 20-69"
        label var group3 "Ages 70+"
        label var total "Total across all ages"
        format group1 group2 group3 total %15.0fc
        gen pg1 = (group1/total) 
        gen pg2 = (group2/total) 
        gen pg3 = (group3/total) 
        label var pg1 "Proportion 0-19"
        label var pg2 "Proportion 20-69"
        label var pg3 "Proportion 70+"
        keep iso3n region paho_subregion sex year group1 group2 group3 total pg1 pg2 pg3
        sort paho_subregion iso3n sex year

        ** Generate unique code by country - alphabetically
        decode iso3n, gen(country)
        order country, after(iso3n)
        sort country year 
        egen uid = group(country)
        order uid
        replace uid = 34 if paho_subregion==1 & iso3n==.
        replace uid = 35 if paho_subregion==2 & iso3n==.
        replace uid = 36 if paho_subregion==3 & iso3n==.
        replace uid = 37 if paho_subregion==4 & iso3n==.
        replace uid = 38 if paho_subregion==5 & iso3n==.
        replace uid = 39 if paho_subregion==6 & iso3n==.
        replace uid = 40 if paho_subregion==7 & iso3n==.
        replace uid = 41 if paho_subregion==8 & iso3n==.
        replace uid = 42 if region==1 & iso3n==.
        labmask uid, values(iso3n) lblname(uid_) decode
        #delimit ;
        label define uid_   34 "North America"
                            35 "Central America" 
                            36 "Andean Area"
                            37 "Southern Cone"
                            38 "Latin Caribbean"
                            39 "non-Latin Carib"
                            40 "Brazil"
                            41 "Mexico"
                            42 "Americas", modify ;
        #delimit cr
        label values uid uid_

        ** New code for looping through Regions, then subregions, then countries
        gen uid1 = 1 if uid==42
        ** North America (Canada, USA)
        replace uid1 = 2 if uid==34
        replace uid1 = 3 if uid==8
        replace uid1 = 4 if uid==31
        ** Central America (BLZ, CRI, SLV, GTM, HND, NIC PAN)
        replace uid1 = 5 if uid==35
        replace uid1 = 6 if uid==5
        replace uid1 = 7 if uid==11
        replace uid1 = 8 if uid==15
        replace uid1 = 9 if uid==17
        replace uid1 = 10 if uid==20
        replace uid1 = 11 if uid==23
        replace uid1 = 12 if uid==24
        ** Andean Area (BOL, COL, ECU, PER, VEN)
        replace uid1 = 13 if uid==36
        replace uid1 = 14 if uid==6
        replace uid1 = 15 if uid==10
        replace uid1 = 16 if uid==14
        replace uid1 = 17 if uid==26
        replace uid1 = 18 if uid==33
        ** Southern Cone (ARG, CHL, PRY, URY)
        replace uid1 = 19 if uid==37
        replace uid1 = 20 if uid==2
        replace uid1 = 21 if uid==9
        replace uid1 = 22 if uid==25
        replace uid1 = 23 if uid==32
        ** Latin Caribbean (CUB, DOM, HTI)
        replace uid1 = 24 if uid==38
        replace uid1 = 25 if uid==12
        replace uid1 = 26 if uid==13
        replace uid1 = 27 if uid==19
        ** non-Latin Caribbean (ATG, BHS, BRB, GRD, GUY, JAM, LCA, VCT, SUR, TTO)
        replace uid1 = 28 if uid==39
        replace uid1 = 29 if uid==1
        replace uid1 = 30 if uid==3
        replace uid1 = 31 if uid==4
        replace uid1 = 32 if uid==16
        replace uid1 = 33 if uid==18
        replace uid1 = 34 if uid==21
        replace uid1 = 35 if uid==27
        replace uid1 = 36 if uid==28
        replace uid1 = 37 if uid==29
        replace uid1 = 38 if uid==30
        ** Brazil / Mexico
        replace uid1 = 39 if uid==7
        replace uid1 = 40 if uid==22
        order uid1, after(uid) 
        labmask uid1, values(uid) lblname(uid1_) decode
        decode uid1, gen(country1)
        order country1, after(country)

        ** Metrics for Table
        replace country1 = "St Vincent & Gren" if country=="Saint Vincent and the Grenadines"
        replace country1 = "Antigua & Barbuda" if country=="Antigua and Barbuda"
        replace country1 = "Trinidad & Tobago" if country=="Trinidad and Tobago"
        replace country1 = "Dominican Rep" if country=="Dominican Republic"
        ** (1) Country
        ** (2) Population
        ** (3) Percent change 70+ between 2000 and 2020
        ** (4) Annual growth rate of Older adults
        ** (5) Dependency Ratio
        gsort uid sex -year
        gen pc1 = ( group3[_n] - group3[_n-1] ) / total[_n-1] if paho_subregion[_n] == paho_subregion[_n-1] 
        ** Growth rate all ages
        gen gr = round( ( ( ln(total[_n-1] / total[_n]) ) / 20 ) * 100 , 0.01)  if uid[_n] == uid[_n-1] 
        label var gr "Annual growth rate (%)"
        ** Growth rate older adults (70+)
        gen gr3 = round( ( ( ln(group3[_n-1] / group3[_n]) ) / 20 ) * 100 , 0.01)  if uid[_n] == uid[_n-1] & sex[_n] == sex[_n-1]
        label var gr3 "Annual growth rate for adults 70+ (%)"
        ** Old Age Dependency Ratio: Ratio of people aged 70+ per 100 people aged 20-69
        gen dr3 = (group3 / group2) * 100
        label var dr3 "Old-age dependency ratio (per 100 aged 20-69)"
        ** Percentage 70+ 
        gen perc3 = pg3 * 100

** TOTAL    : Population values as globals (pop)
** GROUP3   : 70+ population as globals (p70)
** PERC3    : 70+ percentage as globals (perc70)
** GR       : Growth rate (gr)
** GR3      : Growth rate in 70+ (gr3)
** DR3      : Old-age dependency ratio (dr3)
forval a = 1(1)42 {
    forval b = 1(1)3 {
        forval c = 2000(20)2060 {
            preserve
                keep if uid==`a' & sex==`b' & year==`c'
                ** Population all ages
                local pop_`a'_`b'_`c' = total 
                global pop_`a'_`b'_`c' : dis %11.0fc `pop_`a'_`b'_`c'' 
                ** Population 70+ 
                local p70_`a'_`b'_`c' = group3
                global p70_`a'_`b'_`c' : dis %11.0fc `p70_`a'_`b'_`c'' 
                ** Percentage 70+
                local perc70_`a'_`b'_`c' = perc3
                global perc70_`a'_`b'_`c' : dis %5.1fc `perc70_`a'_`b'_`c'' 
                ** Growth Rate
                local gr_`a'_`b'_`c' = gr
                global gr_`a'_`b'_`c' : dis %5.2fc `gr_`a'_`b'_`c'' 
                ** Growth Rate 70+
                local gr3_`a'_`b'_`c' = gr3
                global gr3_`a'_`b'_`c' : dis %5.2fc `gr3_`a'_`b'_`c'' 
                ** Old-age dependency ratio
                local dr3_`a'_`b'_`c' = dr3
                global dr3_`a'_`b'_`c' : dis %5.1fc `dr3_`a'_`b'_`c'' 
            restore
        }
    }
}

** 3-digit ISO codes
gen iso3 = "ATG" if uid==1
order iso3
replace iso3 = "ARG" if uid==2  
replace iso3 = "BHS" if uid==3  
replace iso3 = "BRB" if uid==4  
replace iso3 = "BLZ" if uid==5  
replace iso3 = "BOL" if uid==6  
replace iso3 = "BRA" if uid==7  
replace iso3 = "CAN" if uid==8  
replace iso3 = "CHL" if uid==9  
replace iso3 = "COL" if uid==10 
replace iso3 = "CRI" if uid==11  
replace iso3 = "CUB" if uid==12  
replace iso3 = "DOM" if uid==13  
replace iso3 = "ECU" if uid==14  
replace iso3 = "SLV" if uid==15  
replace iso3 = "GRD" if uid==16  
replace iso3 = "GTM" if uid==17  
replace iso3 = "GUY" if uid==18  
replace iso3 = "HTI" if uid==19  
replace iso3 = "HND" if uid==20  
replace iso3 = "JAM" if uid==21
replace iso3 = "MEX" if uid==22 
replace iso3 = "NIC" if uid==23  
replace iso3 = "PAN" if uid==24  
replace iso3 = "PRY" if uid==25  
replace iso3 = "PER" if uid==26  
replace iso3 = "LCA" if uid==27 
replace iso3 = "VCT" if uid==28 
replace iso3 = "SUR" if uid==29  
replace iso3 = "TTO" if uid==30  
replace iso3 = "USA" if uid==31  
replace iso3 = "URY" if uid==32  
replace iso3 = "VEN" if uid==33  



** GRAPHIC - Age Groups 
** Country / Sub-region / Americas
** -------------------------------------------------------
** GRAPHIC
** ONLY using PAHO-SUBREGIONS
** -------------------------------------------------------

forval a = 1(1)2 {
    preserve
        ** GRAPH of women and men combined
        gen keep = 0 
        replace keep = 1 if uid == `a' 
        gen sr1 = paho_subregion if uid==`a'
        egen sr = min(sr1)
        local sr = sr
        dis `sr'
        replace keep = 1 if uid>33 & paho_subregion==`sr'
        replace keep = 1 if uid==42
        keep if keep==1
        keep if sex==3

        drop region
        gen region = .
        replace region = 1 if uid==`a'
        replace region = 2 if uid>33 & paho_subregion==`sr'
        replace region = 3 if uid==42
        order region, before(paho_subregion)


        ** Standardize LOCAL 70+ metrics for the retained regions 
        ** Rename sub-region to a standard NUMBER
        gen t1 = uid if region==2 
        egen t2 = min(t1)
        local t2 = t2
        forval b = 1(1)3 {
            forval c = 2000(20)2060 {        
                local perc70_50_`b'_`c' = `perc70_`t2'_`b'_`c''
                global perc70_50_`b'_`c' : dis %5.1fc `perc70_50_`b'_`c'' 
            }
        } 

        ** Y-AXIS NAMES
        label define uid_ 28 "St Vincent & Gren" 1 "Antigua & Barbuda" 30 "Trinidad & Tobago" 13 "Dominican Rep", modify
        * country 
        gen c3 = uid if uid==`a'
            label values c3 uid_
            egen c4 = min(c3)
            label values c4 uid_
            decode c4, gen(c5)
            global cname = c5
            sort t1 uid
        * sub-region
        gen c8 = uid if t1<.
            label values c8 uid_
            egen c9 = min(c8)
            label values c9 uid_
            decode c9, gen(c10)
            global srname = c10

        ** Matrix of 400 dots
        ** agroup is the defining age grouping
        gen d1 = round(pg1 * 400, 1)
        gen d3 = round(pg3 * 400, 1)
        gen d2 = 400 - d1 - d3 
        keep uid region paho_subregion year d1 d2 d3 group* total pg*  
        reshape long d, i(uid year) j(agroup) 
        label define agroup_ 1 "0-19" 2 "20-69" 3 "70+",modify
        label values agroup agroup_ 

        * define the dots
        expand d
        sort region year agroup 
        // define the dots
        local rows =  20   // row dots
        local cols  = 20   // col dots

        * generate the dots
        bysort uid year: egen y = seq() , b(`cols')
        egen x = seq() , t(`rows')
        bysort uid year: egen y1 = seq() , f(`cols') t(1) b(`cols')
        egen x1 = seq() , f(`rows') t(1)
        
        ** Shift Subregion vertically
        replace y1 = y1 + 10 if region==1
        replace y1 = y1 + 35 if region==2
        replace y1 = y1 + 60 if region==3

        ** Shift Years horizontally
        replace x1 = x1 + 25 if year==2020
        replace x1 = x1 + 50 if year==2040
        replace x1 = x1 + 75 if year==2060

        ** generate -locals- from the d3 qualitative-paired color scheme
        colorpalette sfso blue, nograph
        local list r(p) 
        ** Darkest to lightest
        local blu1 `r(p1)'
        local blu2 `r(p2)'
        local blu3 `r(p3)'
        local blu4 `r(p4)'
        local blu5 `r(p5)'
        local blu6 `r(p6)'
        local blu7 `r(p7)'
        colorpalette sfso orange, nograph
        local list r(p) 
        ** Darkest to lightest
        local ora1 `r(p1)'
        local ora2 `r(p2)'
        local ora3 `r(p3)'
        local ora4 `r(p4)'
        local ora5 `r(p5)'
        local ora6 `r(p6)'
        local ora7 `r(p7)'
        colorpalette sfso purple, nograph
        local list r(p) 
        ** Darkest to lightest
        local pur1 `r(p1)'
        local pur2 `r(p2)'
        local pur3 `r(p3)'
        local pur4 `r(p4)'
        local pur5 `r(p5)'
        local pur6 `r(p6)'
        local pur7 `r(p7)'

        ** Recode to have 70+ age group at bottom of chart
        recode agroup 3=1 1=3

        * Version 2 - legend outside
        ** Legend outer limits for graphing 
        local a3 80 100    77 100    77 105    80 105    80 100 
        local a2 75 100    72 100    72 105    75 105    75 100  
        local a1 70 100    67 100    67 105    70 105    70 100   
        local b3 55 100    52 100    52 105    55 105    55 100 
        local b2 50 100    47 100    47 105    50 105    50 100  
        local b1 45 100    42 100    42 105    45 105    45 100   
        local c3 30 100    27 100    27 105    30 105    30 100 
        local c2 25 100    22 100    22 105    25 105    25 100  
        local c1 20 100    17 100    17 105    20 105    20 100   

        #delimit ; 
        twoway 
            /// (1) Country
            /// (2) Subregion 
            /// (3) Americas
            (scatter y1 x1 if region==1 & year==2000 & agroup==1, msize(0.3) mc("`blu2'") m(O))
            (scatter y1 x1 if region==1 & year==2000 & agroup==2, msize(0.3) mc("`blu6'") m(O))
            (scatter y1 x1 if region==1 & year==2000 & agroup==3, msize(0.3) mc("`blu4'") m(O))
            (scatter y1 x1 if region==1 & year==2020 & agroup==1, msize(0.3) mc("`blu2'") m(O))
            (scatter y1 x1 if region==1 & year==2020 & agroup==2, msize(0.3) mc("`blu6'") m(O))
            (scatter y1 x1 if region==1 & year==2020 & agroup==3, msize(0.3) mc("`blu4'") m(O))
            (scatter y1 x1 if region==1 & year==2040 & agroup==1, msize(0.3) mc("`blu2'") m(O))
            (scatter y1 x1 if region==1 & year==2040 & agroup==2, msize(0.3) mc("`blu6'") m(O))
            (scatter y1 x1 if region==1 & year==2040 & agroup==3, msize(0.3) mc("`blu4'") m(O))
            (scatter y1 x1 if region==1 & year==2060 & agroup==1, msize(0.3) mc("`blu2'") m(O))
            (scatter y1 x1 if region==1 & year==2060 & agroup==2, msize(0.3) mc("`blu6'") m(O))
            (scatter y1 x1 if region==1 & year==2060 & agroup==3, msize(0.3) mc("`blu4'") m(O))

            (scatter y1 x1 if region==2 & year==2000 & agroup==1, msize(0.3) mc("`ora2'") m(O))
            (scatter y1 x1 if region==2 & year==2000 & agroup==2, msize(0.3) mc("`ora6'") m(O))
            (scatter y1 x1 if region==2 & year==2000 & agroup==3, msize(0.3) mc("`ora4'") m(O))
            (scatter y1 x1 if region==2 & year==2020 & agroup==1, msize(0.3) mc("`ora2'") m(O))
            (scatter y1 x1 if region==2 & year==2020 & agroup==2, msize(0.3) mc("`ora6'") m(O))
            (scatter y1 x1 if region==2 & year==2020 & agroup==3, msize(0.3) mc("`ora4'") m(O))
            (scatter y1 x1 if region==2 & year==2040 & agroup==1, msize(0.3) mc("`ora2'") m(O))
            (scatter y1 x1 if region==2 & year==2040 & agroup==2, msize(0.3) mc("`ora6'") m(O))
            (scatter y1 x1 if region==2 & year==2040 & agroup==3, msize(0.3) mc("`ora4'") m(O))
            (scatter y1 x1 if region==2 & year==2060 & agroup==1, msize(0.3) mc("`ora2'") m(O))
            (scatter y1 x1 if region==2 & year==2060 & agroup==2, msize(0.3) mc("`ora6'") m(O))
            (scatter y1 x1 if region==2 & year==2060 & agroup==3, msize(0.3) mc("`ora4'") m(O))

            (scatter y1 x1 if region==3 & year==2000 & agroup==1, msize(0.3) mc("`pur2'") m(O))
            (scatter y1 x1 if region==3 & year==2000 & agroup==2, msize(0.3) mc("`pur6'") m(O))
            (scatter y1 x1 if region==3 & year==2000 & agroup==3, msize(0.3) mc("`pur4'") m(O))
            (scatter y1 x1 if region==3 & year==2020 & agroup==1, msize(0.3) mc("`pur2'") m(O))
            (scatter y1 x1 if region==3 & year==2020 & agroup==2, msize(0.3) mc("`pur6'") m(O))
            (scatter y1 x1 if region==3 & year==2020 & agroup==3, msize(0.3) mc("`pur4'") m(O))
            (scatter y1 x1 if region==3 & year==2040 & agroup==1, msize(0.3) mc("`pur2'") m(O))
            (scatter y1 x1 if region==3 & year==2040 & agroup==2, msize(0.3) mc("`pur6'") m(O))
            (scatter y1 x1 if region==3 & year==2040 & agroup==3, msize(0.3) mc("`pur4'") m(O))
            (scatter y1 x1 if region==3 & year==2060 & agroup==1, msize(0.3) mc("`pur2'") m(O))
            (scatter y1 x1 if region==3 & year==2060 & agroup==2, msize(0.3) mc("`pur6'") m(O))
            (scatter y1 x1 if region==3 & year==2060 & agroup==3, msize(0.3) mc("`pur4'") m(O))

            /// Legend 
            (scatteri `a1' , recast(area) lw(none) lc("`pur2'") fc("`pur2'")  )
            (scatteri `a2' , recast(area) lw(none) lc("`pur6'") fc("`pur6'")  )
            (scatteri `a3' , recast(area) lw(none) lc("`pur4'") fc("`pur4'")  )

            (scatteri `b1' , recast(area) lw(none) lc("`ora2'") fc("`ora2'")  )
            (scatteri `b2' , recast(area) lw(none) lc("`ora6'") fc("`ora6'")  )
            (scatteri `b3' , recast(area) lw(none) lc("`ora4'") fc("`ora4'")  )

            (scatteri `c1' , recast(area) lw(none) lc("`blu2'") fc("`blu2'")  )
            (scatteri `c2' , recast(area) lw(none) lc("`blu6'") fc("`blu6'")  )
            (scatteri `c3' , recast(area) lw(none) lc("`blu4'") fc("`blu4'")  )

                , 

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
            ysize(8) xsize(16)

            ylab(
                    75 "$cname"
                    50 "$srname" 
                    20 "Americas"
                ,
            valuelabel labc(gs0) labs(4.5) tlc(gs0) notick nogrid glc(gs16) angle(0) format(%9.0f))
            yscale(noline lw(none) lc(gs16) noextend range(0(10)90)) 
            ytitle("", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            xlab(none , 
            valuelabel labc(gs0) labs(3) notick nogrid glc(gs16) angle(0) format(%9.0f))
            xscale(noline lw(vthin) range(0(5)155) ) 
            xtitle(" ", size(3) color(gs0) margin(l=0 r=0 t=0 b=0)) 

            xtitle("") xscale(noline) xlabel(, nogrid)

            /// Column headings
            text(85 11 "2000" ,  place(c) size(4.5) color(gs0) just(right))
            text(85 36 "2020" ,  place(c) size(4.5) color(gs0) just(right))
            text(85 61 "2040" ,  place(c) size(4.5) color(gs0) just(right))
            text(85 86 "2060" ,  place(c) size(4.5) color(gs0) just(right))
            text(87 125 "Aged 70+ (%)" ,  place(e) size(4.5) color(gs0) just(right))
            text(82 130 "Women" ,  place(c) size(4) color(gs4) just(right))
            text(82 142 "Men" ,  place(c) size(4) color(gs4) just(right))
            text(82 150 "All" ,  place(c) size(4) color(gs4) just(right))

            /// COUNTRY
            text(76 118 "2000:  ${perc70_`a'_2_2000}" ,   place(e) size(4) color(gs8) just(right))
            text(71 118 "2060:  ${perc70_`a'_2_2060}" ,   place(e) size(4) color(gs8) just(right))
            text(76 137        "${perc70_`a'_1_2000}" ,           place(e) size(4) color(gs8) just(right))
            text(71 137        "${perc70_`a'_1_2060}" ,           place(e) size(4) color(gs8) just(right))
            text(76 147        "${perc70_`a'_3_2000}" ,           place(e) size(4) color(gs8) just(right))
            text(71 147        "${perc70_`a'_3_2060}" ,           place(e) size(4) color(gs8) just(right))

            /// SUB-REGION
            text(51 118 "2000:  ${perc70_50_2_2000}" ,   place(e) size(4) color(gs8) just(right))
            text(46 118 "2060:  ${perc70_50_2_2060}" ,   place(e) size(4) color(gs8) just(right))
            text(51 137        "${perc70_50_1_2000}" ,           place(e) size(4) color(gs8) just(right))
            text(46 137        "${perc70_50_1_2060}" ,           place(e) size(4) color(gs8) just(right))
            text(51 147        "${perc70_50_3_2000}" ,           place(e) size(4) color(gs8) just(right))
            text(46 147        "${perc70_50_3_2060}" ,           place(e) size(4) color(gs8) just(right))

            /// REGION
            text(26 118 "2000:  ${perc70_42_2_2000}" ,   place(e) size(4) color(gs8) just(right))
            text(21 118 "2060:  ${perc70_42_2_2060}" ,   place(e) size(4) color(gs8) just(right))
            text(26 137        "${perc70_42_1_2000}" ,           place(e) size(4) color(gs8) just(right))
            text(21 137        "${perc70_42_1_2060}" ,           place(e) size(4) color(gs8) just(right))
            text(26 147        "${perc70_42_3_2000}" ,           place(e) size(4) color(gs8) just(right))
            text(21 147        "${perc70_42_3_2060}" ,           place(e) size(4) color(gs8) just(right))

            /// Legend Text
            text(79 106  "0-19",  place(e) size(4) color(gs8))   
            text(74 106 "20-69",  place(e) size(4) color(gs8))   
            text(69 106   "70+",  place(e) size(4) color(gs8))   
            text(54 106  "0-19",  place(e) size(4) color(gs8))   
            text(49 106 "20-69",  place(e) size(4) color(gs8))   
            text(44 106   "70+",  place(e) size(4) color(gs8))   
            text(29 106  "0-19",  place(e) size(4) color(gs8))   
            text(24 106 "20-69",  place(e) size(4) color(gs8))   
            text(19 106   "70+",  place(e) size(4) color(gs8))               


            legend(off) 
            name(figure_`a')
            ;
        #delimit cr 
        graph export "`outputpath'/figure_`a'.png", replace width(4000)
    restore
}



** TABLE. Combined NCDs for COUNTRY, SUB-REGION, THE AMERICAS
** ------------------------------------------------------
** PDF COUNTRY REPORT
** ------------------------------------------------------

local a = 1
**forval a = 1(1)2 {
** preserve
    ** This code chunk creates COUNTRY ISO CODE and COUNTRY NAME
    ** for automated use in the PDF reports.
    **      country  = 3-character ISO name
    **      cname    = FULL country name
    **      -country- used in all loop structures
    **      -cname- used for visual display of full country name on PDF
    gen c3 = uid if uid==`a'
    label values c3 uid_
    egen c4 = min(c3)
    label values c4 uid_
    decode c4, gen(c5)
    global cname = c5

** TEST ON BARBADOS
putpdf begin, pagesize(letter) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** TITLE, ATTRIBUTION, DATE of CREATION
    putpdf table intro = (1,12), width(100%) halign(left)    
    putpdf table intro(.,.), border(all, nil)
    putpdf table intro(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro(1,1)
    putpdf table intro(1,2), colspan(11)
    putpdf table intro(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro(1,2)=("Country report for $cname"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro(1,2)=("Briefing created by Ian Hambleton. "), linebreak append halign(left) 
    putpdf table intro(1,2)=("The University of the West Indies. "), linebreak halign(left) append 
    putpdf table intro(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("TABLE. ") , bold
    putpdf text ("Population size and proportion of older adults between 2000 and 2060 in $cname. ")

** TABLE: KEY SUMMARY METRICS
    putpdf table t1 = (6,8), width(90%) halign(center)    
    putpdf table t1(1/2,1/8), font("Calibri Light", 10, 000000) border(left,single,999999) border(right,single,999999) border(top, single,999999) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3/6,1/8), font("Calibri Light", 10, 000000) border(all,single,999999) bgcolor(ffffff) 

    putpdf table t1(1,3)=("Women"), halign(center) 
    putpdf table t1(2,3)=("All ages (N)"), halign(center) 
    putpdf table t1(2,4)=("70+ (%)"), halign(center) 

    putpdf table t1(1,5)=("Men"), halign(center) 
    putpdf table t1(2,5)=("All ages (N)"), halign(center) 
    putpdf table t1(2,6)=("70+ (%)"), halign(center) 

    putpdf table t1(1,7)=("All"), halign(center) 
    putpdf table t1(2,7)=("All ages (N)"), halign(center) 
    putpdf table t1(2,8)=("70+ (%)"), halign(center) 

    putpdf table t1(3,1)=("Population"), halign(center) 
    putpdf table t1(3,2)=("2000"), halign(center) 
    putpdf table t1(4,2)=("2020"), halign(center) 
    putpdf table t1(5,2)=("2040"), halign(center) 
    putpdf table t1(6,2)=("2060"), halign(center) 

    ** Column 3 - Women ALL
    putpdf table t1(3,3)=("${pop_`a'_2_2000}"), halign(center) 
    putpdf table t1(4,3)=("${pop_`a'_2_2020}"), halign(center) 
    putpdf table t1(5,3)=("${pop_`a'_2_2040}"), halign(center) 
    putpdf table t1(6,3)=("${pop_`a'_2_2060}"), halign(center) 
    ** Column 4 - Women 70+
    putpdf table t1(3,4)=("${p70_`a'_2_2000}"), halign(center) 
    putpdf table t1(4,4)=("${p70_`a'_2_2020}"), halign(center) 
    putpdf table t1(5,4)=("${p70_`a'_2_2040}"), halign(center) 
    putpdf table t1(6,4)=("${p70_`a'_2_2060}"), halign(center) 
    ** Column 5 - Men ALL
    putpdf table t1(3,5)=("${pop_`a'_1_2000}"), halign(center) 
    putpdf table t1(4,5)=("${pop_`a'_1_2020}"), halign(center) 
    putpdf table t1(5,5)=("${pop_`a'_1_2040}"), halign(center) 
    putpdf table t1(6,5)=("${pop_`a'_1_2060}"), halign(center) 
    ** Column 6 - Men 70+
    putpdf table t1(3,6)=("${p70_`a'_1_2000}"), halign(center) 
    putpdf table t1(4,6)=("${p70_`a'_1_2020}"), halign(center) 
    putpdf table t1(5,6)=("${p70_`a'_1_2040}"), halign(center) 
    putpdf table t1(6,6)=("${p70_`a'_1_2060}"), halign(center) 
    ** Column 7 - Men ALL
    putpdf table t1(3,7)=("${pop_`a'_3_2000}"), halign(center) 
    putpdf table t1(4,7)=("${pop_`a'_3_2020}"), halign(center) 
    putpdf table t1(5,7)=("${pop_`a'_3_2040}"), halign(center) 
    putpdf table t1(6,7)=("${pop_`a'_3_2060}"), halign(center) 
    ** Column 8 - Men 70+
    putpdf table t1(3,8)=("${p70_`a'_3_2000}"), halign(center) 
    putpdf table t1(4,8)=("${p70_`a'_3_2020}"), halign(center) 
    putpdf table t1(5,8)=("${p70_`a'_3_2040}"), halign(center) 
    putpdf table t1(6,8)=("${p70_`a'_3_2060}"), halign(center) 

    ** FIGURE 1. 70+ percentages for COUNTRY, Sub-Region, Americas
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("Graph."), bold
    putpdf text (" Proportion of older adults (70+ years) in $cname")

    putpdf table t2 = (3,12), width(90%) halign(center)   
    putpdf table t2(1,2), span(3, 11)

    putpdf table t2(1,2)=image("`outputpath'/figure_`a'.png")
    putpdf table t2(1,1)=("$cname"), halign(center) 
    putpdf table t2(2,1)=("$srname"), halign(center) 
    putpdf table t2(3,1)=("Americas"), halign(center) 


** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/briefing_`a'", replace

**restore
**}
