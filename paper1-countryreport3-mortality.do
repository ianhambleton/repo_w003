** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper1-countryreport3-mortality.do
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
    local datapath "X:\CaribData\My Drive\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "X:\CaribData\My Drive\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "X:\CaribData\My Drive\output\analyse-write\w003\outputs\BRB"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\paper1-countryreport3-mortality", replace
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

tempfile for_report
save `for_report', replace

save "`outputpath'/for_report", replace





** GRAPHIC - Age Groups 
** Country / Sub-region / Americas
** -------------------------------------------------------
** GRAPHIC
** ONLY using PAHO-SUBREGIONS
** -------------------------------------------------------
local a = 4
** forval a = 1(1)4 {
    preserve
        ** GRAPH of women and men combined
        gen keep = 0 
        replace keep = 1 if uid == `a' 
        gen sr1 = paho_subregion if uid==`a'
        egen sr = min(sr1)
        local sr_`a' = sr
        dis `sr_`a''
        replace keep = 1 if uid>33 & paho_subregion==`sr_`a''
        replace keep = 1 if uid==42
        keep if keep==1
        keep if sex==3

        drop region
        gen region = .
        replace region = 1 if uid==`a'
        replace region = 2 if uid>33 & paho_subregion==`sr_`a''
        replace region = 3 if uid==42
        order region, before(paho_subregion)


        ** Standardize LOCAL 70+ metrics for the retained regions 
        ** Rename sub-region to a standard NUMBER
        gen t1 = uid if region==2 
        egen t2 = min(t1)
        local t2 = t2
        forval b = 1(1)3 {
            forval c = 2000(20)2060 {        
                local perc70_50_`a'_`b'_`c' = `perc70_`t2'_`b'_`c''
                global perc70_50_`a'_`b'_`c' : dis %5.1fc `perc70_50_`a'_`b'_`c'' 
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
            global srname_`a' = c10

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
        replace y1 = y1 + 2 if region==1
        replace y1 = y1 + 2 if region==2
        replace y1 = y1 + 2 if region==3

        ** Shift Years horizontally
        replace x1 = x1 + 25 if year==2020
        replace x1 = x1 + 50 if year==2040
        replace x1 = x1 + 75 if year==2060

        ** generate -locals- from the d3 qualitative-paired color scheme
        colorpalette sfso blue, nograph
        local list r(p) 
        ** Darkest to lightest
        local col1_1 `r(p1)'
        local col2_1 `r(p2)'
        local col3_1 `r(p3)'
        local col4_1 `r(p4)'
        local col5_1 `r(p5)'
        local col6_1 `r(p6)'
        local col7_1 `r(p7)'
        colorpalette sfso orange, nograph
        local list r(p) 
        ** Darkest to lightest
        local col1_2 `r(p1)'
        local col2_2 `r(p2)'
        local col3_2 `r(p3)'
        local col4_2 `r(p4)'
        local col5_2 `r(p5)'
        local col6_2 `r(p6)'
        local col7_2 `r(p7)'
        colorpalette sfso purple, nograph
        local list r(p) 
        ** Darkest to lightest
        local col1_3 `r(p1)'
        local col2_3 `r(p2)'
        local col3_3 `r(p3)'
        local col4_3 `r(p4)'
        local col5_3 `r(p5)'
        local col6_3 `r(p6)'
        local col7_3 `r(p7)'
        colorpalette sfso red, nograph
        local list r(p) 
        ** Darkest to lightest
        local col1_4 `r(p1)'
        local col2_4 `r(p2)'
        local col3_4 `r(p3)'
        local col4_4 `r(p4)'
        local col5_4 `r(p5)'
        local col6_4 `r(p6)'
        local col7_4 `r(p7)'
        colorpalette sfso green, nograph
        local list r(p) 
        ** Darkest to lightest
        local col1_5 `r(p1)'
        local col2_5 `r(p2)'
        local col3_5 `r(p3)'
        local col4_5 `r(p4)'
        local col5_5 `r(p5)'
        local col6_5 `r(p6)'
        local col7_5 `r(p7)'

        ** Recode to have 70+ age group at bottom of chart
        recode agroup 3=1 1=3

        * Version 2 - legend outside
        ** Legend outer limits for graphing  
        local c3 20 100    17 100    17 105    20 105    20 100  
        local c2 15 100    12 100    12 105    15 105    15 100   
        local c1 10 100    7 100    7 105    10 105    10 100   

        #delimit ; 
        forval r=1(1)3 {;
            twoway 
            /// (1) Country
            /// (2) Subregion 
            /// (3) Americas
            (scatter y1 x1 if region==`r' & year==2000 & agroup==1, msize(2) mc("`col2_`r''") m(O))
            (scatter y1 x1 if region==`r' & year==2000 & agroup==2, msize(2) mc("`col6_`r''") m(O))
            (scatter y1 x1 if region==`r' & year==2000 & agroup==3, msize(2) mc("`col4_`r''") m(O))
            (scatter y1 x1 if region==`r' & year==2020 & agroup==1, msize(2) mc("`col2_`r''") m(O))
            (scatter y1 x1 if region==`r' & year==2020 & agroup==2, msize(2) mc("`col6_`r''") m(O))
            (scatter y1 x1 if region==`r' & year==2020 & agroup==3, msize(2) mc("`col4_`r''") m(O))
            (scatter y1 x1 if region==`r' & year==2040 & agroup==1, msize(2) mc("`col2_`r''") m(O))
            (scatter y1 x1 if region==`r' & year==2040 & agroup==2, msize(2) mc("`col6_`r''") m(O))
            (scatter y1 x1 if region==`r' & year==2040 & agroup==3, msize(2) mc("`col4_`r''") m(O))
            (scatter y1 x1 if region==`r' & year==2060 & agroup==1, msize(2) mc("`col2_`r''") m(O))
            (scatter y1 x1 if region==`r' & year==2060 & agroup==2, msize(2) mc("`col6_`r''") m(O))
            (scatter y1 x1 if region==`r' & year==2060 & agroup==3, msize(2) mc("`col4_`r''") m(O))

            /// Legend 
            (scatteri `c1' , recast(area) lw(none) lc("`blu2'") fc("`col2_`r''")  )
            (scatteri `c2' , recast(area) lw(none) lc("`blu6'") fc("`col6_`r''")  )
            (scatteri `c3' , recast(area) lw(none) lc("`blu4'") fc("`col4_`r''")  )
                , 

            plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 		
            graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin) margin(l=2 r=2 b=0 t=0)) 
            ysize(3) xsize(15)

            ylab(none
                ,
            valuelabel labc(gs0) labs(4.5) tlc(gs0) notick nogrid glc(gs16) angle(0) format(%9.0f))
            yscale(noline lw(none) lc(gs16) noextend range(0(1)26)) 
            ytitle("", color(gs8) size(3) margin(l=1 r=1 t=1 b=1)) 

            xlab(none , 
            valuelabel labc(gs0) labs(3) notick nogrid glc(gs16) angle(0) format(%9.0f))
            xscale(noline lw(vthin) range(0(5)115) ) 
            xtitle(" ", size(3) color(gs0) margin(l=0 r=0 t=0 b=0)) 

            xtitle("") xscale(noline) xlabel(, nogrid)

            /// Legend Text 
            text(19 106  "0-19",  place(e) size(12) color(gs8))   
            text(14 106 "20-69",  place(e) size(12) color(gs8))   
            text(9 106   "70+",   place(e) size(12) color(gs8))               

            legend(off) 
            name(figure_`a'_`r')
            ;
        #delimit cr 
        graph export "`outputpath'/figure_`a'_`r'.png", replace width(4000)
        }
    restore
** }



** TABLE 3
** MORTALITY due to ALL NCDs

local a = 4
** forval a = 1(1)4 {

        use "X:\OneDrive - The University of the West Indies\Writing\w003\data\from-who\chap2_000_mr_adjusted", clear

        ** Create new GHE CoD order for Table 
        ** 100  All causes
        ** 300  NCDs
        ** 400  CVDs
        ** 500  Cancer
        ** 600  Respiratory
        **  31  Diabetes
        ** 800  Mental
        ** 900  Neurological
        gen     cod = 1 if ghecause==100 
        replace cod = 2 if ghecause==300
        replace cod = 3 if ghecause==400
        replace cod = 4 if ghecause==500
        replace cod = 5 if ghecause==600
        replace cod = 6 if ghecause==700
        replace cod = 7 if ghecause==800
        replace cod = 8 if ghecause==900
        replace cod = 9 if ghecause==50

        #delimit ; 
        label define cod_   1 "All cause" 
                            2 "NCDs" 
                            3 "CVDs" 
                            4 "Cancer" 
                            5 "Respiratory"
                            6 "Diabetes"
                            7 "Mental"
                            8 "Neurological"
                            9 "Combined NCDs", modify ;
        #delimit cr
        label values cod cod_ 
        keep if cod<=9

        ** Restrict to Americas in 2000 and 2019
        ** keep if region==2000
        keep if cod==2
        keep if year==2000 | year==2019
        format pop %15.0fc
        rename pop pop_
        rename mortr rate 
        rename dths count 
        tempfile dalys
        save `dalys' , replace

        recode region 100=34 200=35 300=36 400=37 500=38 600=39 700=40 800=41 2000=42
        drop if region>=1000
        label define region_ 28 "St Vincent & Gren" 1 "Antigua & Barbuda" 30 "Trinidad & Tobago" 13 "Dominican Rep", modify

        #delimit ;
        label define region_    34 "North America"
                                35 "Central America"
                                36 "Andean"
                                37 "Southern Cone"
                                38 "Latin Caribbean"
                                39 "non-Latin Carib"
                                40 "Brazil"
                                41 "Mexico"
                                42 "Americas", modify;
        #delimit cr

        gen keep = 0 
        replace keep = 1 if region == `a' 
        gen sr1 = paho_subregion if region==`a'
        egen sr = min(sr1)
        local sr = sr
        dis `sr'
        replace keep = 1 if region>33 & paho_subregion==`sr'
        replace keep = 1 if region==42
        keep if keep==1
        ** keep if sex==3

        gen region_keep = .
        replace region_keep = 1 if region==`a'
        replace region_keep = 2 if region>33 & paho_subregion==`sr'
        replace region_keep = 3 if region==42
        order region_keep, before(region)

        ** Extract the required DALY metrics
        forval x = 1(1)3 {
            forval b = 1(1)3 {
                forval c = 2000(19)2019 {
                    preserve
                        keep if region_keep==`x' & sex==`b' & year==`c'
                        ** DALY number
                        local mort_`a'_`x'_`b'_`c' = count 
                        global mort_`a'_`x'_`b'_`c' : dis %11.0fc `mort_`a'_`x'_`b'_`c'' 
                        ** DALY rate 
                        local mortr_`a'_`x'_`b'_`c' = rate
                        global mortr_`a'_`x'_`b'_`c' : dis %11.0fc `mortr_`a'_`x'_`b'_`c'' 
                    restore
                }
            }
        }

        label define region_ 28 "St Vincent & Gren" 1 "Antigua & Barbuda" 30 "Trinidad & Tobago" 13 "Dominican Rep", modify
        * country 
        gen c3 = region if region==`a'
            label values c3 region_
            egen c4 = min(c3)
            label values c4 region_
            decode c4, gen(c5)
            global cname = c5
        * sub-region
        gen c8 = paho_subregion if region==`a'
            label values c8 paho_subregion_
            egen c9 = min(c8)
            label values c9 paho_subregion_
            decode c9, gen(c10)
            global srname_t3_`a' = c10
**     }





** TABLE 4 - Change due to Growth, Aging, Epi
local a = 4
** forval a = 1(1)4 {

    use "`outputpath'/country_report_table4", clear

        ** Have iso3n. Need to join with running count for countries to match the other files
        ** Generate unique code by country - alphabetically
        decode iso3n, gen(country)
        order country, after(iso3n)
        replace country = "ZZZ Americas" if country=="THE AMERICAS"
        sort country  
        egen uid = group(country)
        order uid
        replace uid = 42 if uid==34
        labmask uid, values(iso3n) lblname(uid_) decode
        #delimit ;
        label define uid_ 28 "St Vincent & Gren" 1 "Antigua & Barbuda" 30 "Trinidad & Tobago" 13 "Dominican Rep", modify;
        label define uid_   42 "Americas", modify ;
        #delimit cr
        replace country = "Americas" if country=="ZZZ Americas"
        label values uid uid_

        gen keep = 0 
        replace keep = 1 if uid == `a' 
        replace keep = 1 if uid==42
        keep if keep==1

        gen region_keep = .
        replace region_keep = 1 if uid==`a'
        replace region_keep = 2 if uid==42
        order region_keep, before(uid)

        ** Extract the required metrics
        gen ch_d2 = sqrt(ch_d^2)
        gen ch_gr2 = sqrt(ch_gr^2)
        gen ch_as2 = sqrt(ch_as^2)
        gen ch_epi2 = sqrt(ch_epi^2)
        forval x = 1(1)2 {
                    preserve
                        keep if region_keep==`x'
                        ** OVERALL
                        local ov_`a'_`x' = ch_d 
                        global ov_`a'_`x' : dis %5.1fc `ov_`a'_`x'' 
                        ** OVERALL2 (always positive)
                        local ov2_`a'_`x' = ch_d2 
                        global ov2_`a'_`x' : dis %5.1fc `ov2_`a'_`x'' 
                        ** GROWTH
                        local gr_`a'_`x' = ch_gr 
                        global gr_`a'_`x' : dis %5.1fc `gr_`a'_`x'' 
                        ** GROWTH (always positive)
                        local gr2_`a'_`x' = ch_gr2 
                        global gr2_`a'_`x' : dis %5.1fc `gr2_`a'_`x'' 
                        ** AGING
                        local ag_`a'_`x' = ch_as
                        global ag_`a'_`x' : dis %5.1fc `ag_`a'_`x'' 
                        ** AGING (alwats positive)
                        local ag2_`a'_`x' = ch_as2
                        global ag2_`a'_`x' : dis %5.1fc `ag2_`a'_`x'' 
                        ** EPI (with sign)
                        local epi_`a'_`x' = ch_epi
                        global epi_`a'_`x' : dis %5.1fc `epi_`a'_`x'' 
                        ** EPI2 (always positive)
                        local epi2_`a'_`x' = ch_epi2
                        global epi2_`a'_`x' : dis %5.1fc `epi2_`a'_`x'' 
                    restore
**                }
    }



** ------------------------------------------------------
** PDF COUNTRY REPORT
** ------------------------------------------------------
use `for_report', clear


** TABLE COL WIDTH
matrix T2W = (20, 60, 5, 5, 5, 5)
matrix T3W = (23, 11, 11, 11, 11, 11, 11, 11)
matrix T4W = (23, 3, 2, 15, 2, 2, 15, 2, 2, 15, 2, 2, 15)

label define uid_ 28 "St Vincent & Gren" 1 "Antigua & Barbuda" 30 "Trinidad & Tobago" 13 "Dominican Rep", modify

** forval a = 1(1)4 {
local a = 4

if `a'==1 {
    local crep = "ATG"
}
if `a'==2 {
    local crep = "ARG"
}
if `a'==3 {
    local crep = "BHS"
}
if `a'==4 {
    local crep = "BRB"
}
if `a'==5 {
    local crep = "BLZ"
}
if `a'==6 {
    local crep = "BOL"
}
if `a'==7 {
    local crep = "BRA"
}
if `a'==8 {
    local crep = "CAN"
}
if `a'==9 {
    local crep = "CHL"
}
if `a'==10 {
    local crep = "COL"
}
if `a'==11 {
    local crep = "CRI"
}
if `a'==12 {
    local crep = "CUB"
}
if `a'==13 {
    local crep = "DOM"
}
if `a'==14 {
    local crep = "ECU"
}
if `a'==15 {
    local crep = "SLV"
}
if `a'==16 {
    local crep = "GRD"
}
if `a'==17 {
    local crep = "GTM"
}
if `a'==18 {
    local crep = "GUY"
}
if `a'==19 {
    local crep = "HTI"
}
if `a'==20 {
    local crep = "HND"
}
if `a'==21 {
    local crep = "JAM"
}
if `a'==22 {
    local crep = "MEX"
}
if `a'==23 {
    local crep = "NIC"
}
if `a'==24 {
    local crep = "PAN"
}
if `a'==25 {
    local crep = "PRY"
}
if `a'==26 {
    local crep = "PER"
}
if `a'==27 {
    local crep = "LCA"
}
if `a'==28 {
    local crep = "VCT"
}
if `a'==29 {
    local crep = "SUR"
}
if `a'==30 {
    local crep = "TTO"
}
if `a'==31 {
    local crep = "USA"
}
if `a'==32 {
    local crep = "URY"
}
if `a'==33 {
    local crep = "VEN"
}

preserve
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

putpdf begin, pagesize(legal) font("Calibri Light", 10) margin(top,0.5cm) margin(bottom,0.25cm) margin(left,0.5cm) margin(right,0.25cm)

** TITLE, ATTRIBUTION, DATE of CREATION
    putpdf table intro = (1,12), width(90%) halign(left)    
    putpdf table intro(.,.), border(all, nil)
    putpdf table intro(1,.), font("Calibri Light", 8, 000000)  
    putpdf table intro(1,1)
    putpdf table intro(1,2), colspan(11)
    putpdf table intro(1,1)=image("`outputpath'/uwi_crest_small.jpg")
    putpdf table intro(1,2)=("Population Aging and Noncommunicable Disease in $cname"), halign(left) linebreak font("Calibri Light", 12, 000000)
    putpdf table intro(1,2)=("Briefing created by Ian Hambleton. "),  linebreak append halign(left) 
    putpdf table intro(1,2)=("The University of the West Indies. "),  linebreak halign(left) append 
    putpdf table intro(1,2)=("Updated on: $S_DATE at $S_TIME "), halign(left) bold append

** INTRODUCTION
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text ("WHAT IS "), bold font("Calibri Light", 12)
    putpdf text ("the size of the population and the number of older adults in $cname?"), font("Calibri Light", 11)

** TABLE: KEY SUMMARY METRICS
    putpdf table t1 = (6,8), width(90%) halign(center)    
    putpdf table t1(1/2,1/8), font("Calibri Light", 10, 000000) border(left,single,999999) border(right,single,999999) border(top, single,999999) border(bottom, nil) bgcolor(e6e6e6)  
    putpdf table t1(3/6,1/8), font("Calibri Light", 10, 000000) border(all,single,999999) bgcolor(ffffff) 
    putpdf table t1(1,3), colspan(2) 
    putpdf table t1(1,5), colspan(2) 
    putpdf table t1(1,7), colspan(2) 

    putpdf table t1(1,3)=("Women (n)"), halign(center) 
    putpdf table t1(2,3)=("All ages"), halign(center) 
    putpdf table t1(2,4)=("70+"), halign(center) 

    putpdf table t1(1,5)=("Men (n)"), halign(center) 
    putpdf table t1(2,5)=("All ages"), halign(center) 
    putpdf table t1(2,6)=("70+"), halign(center) 

    putpdf table t1(1,7)=("All (n)"), halign(center) 
    putpdf table t1(2,7)=("All ages"), halign(center) 
    putpdf table t1(2,8)=("70+"), halign(center) 

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

    /// if ${m05_`country'} == 1 {
    ///     putpdf table t1(4,5), font("Calibri Light", 11, 000000) border(left, single, 999999) border(right, single, 999999) border(top, single, 999999) border(bottom, single, 999999) bgcolor(ffcccc) 
    ///     putpdf table t1(4,5)=("${up_`country'}"), halign(center) 
    /// }
    /// else if ${m05_`country'} == 2 {
    ///     putpdf table t1(4,5), font("Calibri Light", 11, 000000) border(left, single, 999999) border(right, single, 999999) border(top, single, 999999) border(bottom, single, 999999) bgcolor(d6f5d6) 
    ///     putpdf table t1(4,5)=("${down_`country'}"), halign(center)  
    /// }



    ** FIGURE 1. 70+ percentages for COUNTRY, Sub-Region, Americas
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text (" "), linebreak
    putpdf text ("HOW WILL "), bold font("Calibri Light", 12)
    putpdf text ("the proportion of older adults change in the future in $cname"), font("Calibri Light", 11)

    putpdf table t2 = (5,6), width(90%) width(T2W) halign(center)  
    putpdf table t2(3,2)=image("`outputpath'/figure_`a'_1.png")
    putpdf table t2(4,2)=image("`outputpath'/figure_`a'_2.png")
    putpdf table t2(5,2)=image("`outputpath'/figure_`a'_3.png")
    putpdf table t2(3,1)=("$cname"), halign(center) valign(center)
    putpdf table t2(4,1)=("${srname_`a'}"), halign(center) valign(center) 
    putpdf table t2(5,1)=("Americas"), halign(center) valign(center) 
    putpdf table t2(1,3), colspan(4) 

    putpdf table t2(1/5,1/6), font("Calibri Light", 10, 000000) border(all, nil)
    putpdf table t2(1,1/6), font("Calibri Light", 10, 000000) border(top, single, 999999) bgcolor(e6e6e6)  
    putpdf table t2(2,1/6), font("Calibri Light", 10, 000000) border(bottom, single, 999999) bgcolor(e6e6e6)  
    putpdf table t2(5,1/6), font("Calibri Light", 10, 000000) border(bottom, single, 999999)  
    putpdf table t2(1/5,1), font("Calibri Light", 10, 000000) border(left, single, 999999)  
    putpdf table t2(1,3), font("Calibri Light", 10, 000000) border(right, single, 999999)  
    putpdf table t2(2/5,6), font("Calibri Light", 10, 000000) border(right, single, 999999)  

    putpdf table t2(1,3)=("Percentage 70+"), halign(center) 
    putpdf table t2(2,3)=("Year"), halign(center) 
    putpdf table t2(2,4)=("W "), halign(center) 
    putpdf table t2(2,5)=("M "), halign(center) 
    putpdf table t2(2,6)=("Tot "), halign(center) 
    putpdf table t2(2,2)=("         2000                      2020                     2040                     2060 "), halign(left) 


    ** COUNTRY
    putpdf table t2(3,3)=("2000"), halign(center) valign(center) linebreak  
    putpdf table t2(3,3)=("2060"), halign(center) valign(center)  append
    putpdf table t2(3,4)=("${perc70_`a'_2_2000}"), halign(center) valign(center) linebreak  
    putpdf table t2(3,4)=("${perc70_`a'_2_2060}"), halign(center) valign(center) append  
    putpdf table t2(3,5)=("${perc70_`a'_1_2000}"), halign(center) valign(center) linebreak 
    putpdf table t2(3,5)=("${perc70_`a'_1_2060}"), halign(center) valign(center) append  
    putpdf table t2(3,6)=("${perc70_`a'_3_2000}"), halign(center) valign(center) linebreak 
    putpdf table t2(3,6)=("${perc70_`a'_3_2060}"), halign(center) valign(center) append  

    ** SUB-REGION
    putpdf table t2(4,3)=("2000"), halign(center) valign(center)  
    putpdf table t2(4,3)=("2060"), halign(center) valign(center)  append
    putpdf table t2(4,4)=("${perc70_50_`a'_2_2000}"), halign(center) valign(center) linebreak  
    putpdf table t2(4,4)=("${perc70_50_`a'_2_2060}"), halign(center) valign(center) append  
    putpdf table t2(4,5)=("${perc70_50_`a'_1_2000}"), halign(center) valign(center) linebreak 
    putpdf table t2(4,5)=("${perc70_50_`a'_1_2060}"), halign(center) valign(center) append  
    putpdf table t2(4,6)=("${perc70_50_`a'_3_2000}"), halign(center) valign(center) linebreak 
    putpdf table t2(4,6)=("${perc70_50_`a'_3_2060}"), halign(center) valign(center) append  

    ** AMERICAS
    putpdf table t2(5,3)=("2000"), halign(center) valign(center)  
    putpdf table t2(5,3)=("2060"), halign(center) valign(center)  append
    putpdf table t2(5,4)=("${perc70_42_2_2000}"), halign(center) valign(center) linebreak  
    putpdf table t2(5,4)=("${perc70_42_2_2060}"), halign(center) valign(center) append  
    putpdf table t2(5,5)=("${perc70_42_1_2000}"), halign(center) valign(center) linebreak 
    putpdf table t2(5,5)=("${perc70_42_1_2060}"), halign(center) valign(center) append  
    putpdf table t2(5,6)=("${perc70_42_3_2000}"), halign(center) valign(center) linebreak 
    putpdf table t2(5,6)=("${perc70_42_3_2060}"), halign(center) valign(center) append  



** TABLE 3
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text (" "), linebreak
    putpdf text ("WHAT ARE ") , bold font("Calibri Light", 12)
    putpdf text ("the number of deaths and the mortality rates from noncommunicable disease in $cname. "), font("Calibri Light", 11)
    ** DALY rates for Combined NCDs
    putpdf table t3 = (8,8), width(90%) width(T3W) halign(center)  
    putpdf table t3(1/8,1/8), font("Calibri Light", 10, 000000) border(all, single, 999999)  
    putpdf table t3(1/2,1/8), font("Calibri Light", 10, 000000) bgcolor(e6e6e6)  
    putpdf table t3(3,1)=("$cname"), halign(center) valign(center)
    putpdf table t3(5,1)=("${srname_`a'}"), halign(center) valign(center) 
    putpdf table t3(7,1)=("Americas"), halign(center) valign(center) 
    putpdf table t3(3,2)=("2000"), halign(center) valign(center)
    putpdf table t3(4,2)=("2019"), halign(center) valign(center) 
    putpdf table t3(5,2)=("2000"), halign(center) valign(center)
    putpdf table t3(6,2)=("2019"), halign(center) valign(center) 
    putpdf table t3(7,2)=("2000"), halign(center) valign(center)
    putpdf table t3(8,2)=("2019"), halign(center) valign(center) 
    putpdf table t2(1,1/6), font("Calibri Light", 10, 000000) border(top, single, 999999) bgcolor(e6e6e6)  
    putpdf table t3(2,3)=("F"), halign(center) valign(center) 
    putpdf table t3(2,4)=("M"), halign(center) valign(center) 
    putpdf table t3(2,5)=("Tot"), halign(center) valign(center) 
    putpdf table t3(2,6)=("F"), halign(center) valign(center) 
    putpdf table t3(2,7)=("M"), halign(center) valign(center) 
    putpdf table t3(2,8)=("Tot"), halign(center) valign(center) 
    putpdf table t3(1,3), colspan(3) 
    putpdf table t3(1,6), colspan(3) 
    putpdf table t3(1,3)=("Mortality (n)"), halign(center) valign(center) 
    putpdf table t3(1,6)=("Mortality (rate per 100,000)"), halign(center) valign(center) 

    ** MORTALITY
    putpdf table t3(3,3)=  ("${mort_`a'_1_2_2000}"), halign(center) valign(center)
    putpdf table t3(3,4)=  ("${mort_`a'_1_1_2000}"), halign(center) valign(center)
    putpdf table t3(3,5)=  ("${mort_`a'_1_3_2000}"), halign(center) valign(center)
    putpdf table t3(3,6)= ("${mortr_`a'_1_2_2000}"), halign(center) valign(center)
    putpdf table t3(3,7)= ("${mortr_`a'_1_1_2000}"), halign(center) valign(center)
    putpdf table t3(3,8)= ("${mortr_`a'_1_3_2000}"), halign(center) valign(center)
    putpdf table t3(4,3)=  ("${mort_`a'_1_2_2019}"), halign(center) valign(center)
    putpdf table t3(4,4)=  ("${mort_`a'_1_1_2019}"), halign(center) valign(center)
    putpdf table t3(4,5)=  ("${mort_`a'_1_3_2019}"), halign(center) valign(center)
    putpdf table t3(4,6)= ("${mortr_`a'_1_2_2019}"), halign(center) valign(center)
    putpdf table t3(4,7)= ("${mortr_`a'_1_1_2019}"), halign(center) valign(center)
    putpdf table t3(4,8)= ("${mortr_`a'_1_3_2019}"), halign(center) valign(center)

    ** SUB-REGION
    putpdf table t3(5,3)=  ("${mort_`a'_2_2_2000}"), halign(center) valign(center)
    putpdf table t3(5,4)=  ("${mort_`a'_2_1_2000}"), halign(center) valign(center)
    putpdf table t3(5,5)=  ("${mort_`a'_2_3_2000}"), halign(center) valign(center)
    putpdf table t3(5,6)= ("${mortr_`a'_2_2_2000}"), halign(center) valign(center)
    putpdf table t3(5,7)= ("${mortr_`a'_2_1_2000}"), halign(center) valign(center)
    putpdf table t3(5,8)= ("${mortr_`a'_2_3_2000}"), halign(center) valign(center)
    putpdf table t3(6,3)=  ("${mort_`a'_2_2_2019}"), halign(center) valign(center)
    putpdf table t3(6,4)=  ("${mort_`a'_2_1_2019}"), halign(center) valign(center)
    putpdf table t3(6,5)=  ("${mort_`a'_2_3_2019}"), halign(center) valign(center)
    putpdf table t3(6,6)= ("${mortr_`a'_2_2_2019}"), halign(center) valign(center)
    putpdf table t3(6,7)= ("${mortr_`a'_2_1_2019}"), halign(center) valign(center)
    putpdf table t3(6,8)= ("${mortr_`a'_2_3_2019}"), halign(center) valign(center)     

    ** AMERICAS
    putpdf table t3(7,3)=  ("${mort_`a'_3_2_2000}"), halign(center) valign(center)
    putpdf table t3(7,4)=  ("${mort_`a'_3_1_2000}"), halign(center) valign(center)
    putpdf table t3(7,5)=  ("${mort_`a'_3_3_2000}"), halign(center) valign(center)
    putpdf table t3(7,6)= ("${mortr_`a'_3_2_2000}"), halign(center) valign(center)
    putpdf table t3(7,7)= ("${mortr_`a'_3_1_2000}"), halign(center) valign(center)
    putpdf table t3(7,8)= ("${mortr_`a'_3_3_2000}"), halign(center) valign(center)
    putpdf table t3(8,3)=  ("${mort_`a'_3_2_2019}"), halign(center) valign(center)
    putpdf table t3(8,4)=  ("${mort_`a'_3_1_2019}"), halign(center) valign(center)
    putpdf table t3(8,5)=  ("${mort_`a'_3_3_2019}"), halign(center) valign(center)
    putpdf table t3(8,6)= ("${mortr_`a'_3_2_2019}"), halign(center) valign(center)
    putpdf table t3(8,7)= ("${mortr_`a'_3_1_2019}"), halign(center) valign(center)
    putpdf table t3(8,8)= ("${mortr_`a'_3_3_2019}"), halign(center) valign(center)




** TABLE 4
** Change in Combined NCDs due to Growt, Aging, Epi
    putpdf paragraph ,  font("Calibri Light", 10)
    putpdf text (" "), linebreak
    putpdf text ("HOW HAS ") , bold font("Calibri Light", 12)
    putpdf text ("population growth, population aging, and epidemiological change affected the number of deaths in $cname. "), font("Calibri Light", 11)
    ** DALY rates for Combined NCDs
    putpdf table t4 = (6,13), width(90%) width(T4W) halign(center)  
    putpdf table t4(1/6,1/13), font("Calibri Light", 10, 000000) border(all, nil, 999999)  

    putpdf table t4(2,3/4), bgcolor(e6e6e6)  
    putpdf table t4(2,6/7), bgcolor(e6e6e6)  
    putpdf table t4(2,9/10), bgcolor(e6e6e6)  
    putpdf table t4(2,12/13), bgcolor(e6e6e6)  

    putpdf table t4(4,1)=("$cname"), halign(center) valign(center) font("Calibri Light", 12) 
    putpdf table t4(6,1)=("Americas"), halign(center) valign(center) font("Calibri Light", 12)
    putpdf table t4(2,4)=("Overall"), halign(center) valign(center) font("Calibri Light", 12) bgcolor(e6e6e6) 
    putpdf table t4(2,7)=("Growth"), halign(center) valign(center) font("Calibri Light", 12) bgcolor(e6e6e6)
    putpdf table t4(2,10)=("Aging"), halign(center) valign(center) font("Calibri Light", 12) bgcolor(e6e6e6)
    putpdf table t4(2,13)=("Epi"), halign(center) valign(center) font("Calibri Light", 12) bgcolor(e6e6e6)
    putpdf table t4(1,3), colspan(11) 

    ** METRICS
    
    * overall - country
    if ${ov_`a'_1}>0 {
        putpdf table t4(4,4)=  ("UP ${ov2_`a'_1}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_4'") 
        putpdf table t4(4,4), bgcolor("`col6_4'") 
        putpdf table t4(4,3), bgcolor("`col1_4'") 
        }
    else if ${ov_`a'_1}<0 {
        putpdf table t4(4,4)=  ("DOWN ${ov2_`a'_1}"), halign(center) valign(center) font("Calibri Light", 12)  bgcolor("`col6_5'") 
        putpdf table t4(4,4), bgcolor("`col6_5'") 
        putpdf table t4(4,3), bgcolor("`col1_5'") 
        }
    * overall - americas
    if ${ov_`a'_2}>0 {
        putpdf table t4(6,4)=  ("UP ${ov2_`a'_2}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_4'") 
        putpdf table t4(6,4), bgcolor("`col6_4'") 
        putpdf table t4(6,3), bgcolor("`col1_4'") 
        }
    else if ${ov_`a'_2}<0 {
        putpdf table t4(6,4)=  ("DOWN ${ov2_`a'_2}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_5'") 
        putpdf table t4(6,4), bgcolor("`col6_5'") 
        putpdf table t4(6,3), bgcolor("`col1_5'") 
        }

    * growth - country
    if ${gr_`a'_1}>0 {
        putpdf table t4(4,7)=  ("UP ${gr2_`a'_1}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_4'") 
        putpdf table t4(4,7), bgcolor("`col6_4'") 
        putpdf table t4(4,6), bgcolor("`col1_4'") 
        }
    else if ${gr_`a'_1}<0 {
        putpdf table t4(4,7)=  ("DOWN ${gr2_`a'_1}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_5'") 
        putpdf table t4(4,7), bgcolor("`col6_5'") 
        putpdf table t4(4,6), bgcolor("`col1_5'") 
        }
    * growth - americas
    if ${gr_`a'_2}>0 {
        putpdf table t4(6,7)=  ("UP ${gr2_`a'_2}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_4'") 
        putpdf table t4(6,7), bgcolor("`col6_4'") 
        putpdf table t4(6,6), bgcolor("`col1_4'") 
        }
    else if ${gr_`a'_2}<0 {
        putpdf table t4(6,7)=  ("DOWN ${gr2_`a'_2}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_5'") 
        putpdf table t4(6,7), bgcolor("`col6_5'") 
        putpdf table t4(6,6), bgcolor("`col1_5'") 
        }

    * AGING - country
    if ${ag_`a'_1}>0 {
        putpdf table t4(4,10)=  ("UP ${ag2_`a'_1}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_4'") 
        putpdf table t4(4,10), bgcolor("`col6_4'") 
        putpdf table t4(4,9), bgcolor("`col1_4'") 
        }
    else if ${ag_`a'_1}<0 {
        putpdf table t4(4,10)=  ("DOWN ${ag2_`a'_1}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_5'") 
        putpdf table t4(4,10), bgcolor("`col6_5'") 
        putpdf table t4(4,9), bgcolor("`col1_5'") 
        }
    * AGING - americas
    if ${ag_`a'_2}>0 {
        putpdf table t4(6,10)=  ("UP ${ag2_`a'_2}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_4'") 
        putpdf table t4(6,10), bgcolor("`col6_4'") 
        putpdf table t4(6,9), bgcolor("`col1_4'") 
        }
    else if ${ag_`a'_2}<0 {
        putpdf table t4(6,10)=  ("DOWN ${ag2_`a'_2}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_5'") 
        putpdf table t4(6,10), bgcolor("`col6_5'") 
        putpdf table t4(6,9), bgcolor("`col1_5'") 
        }

    * EPI - country
    if ${epi_`a'_1}>0 {
        putpdf table t4(4,13)=  ("UP ${epi2_`a'_1}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_4'")
        putpdf table t4(4,13), bgcolor("`col6_4'") 
        putpdf table t4(4,12), bgcolor("`col1_4'") 
        }
    else if ${epi_`a'_1}<0 {
        putpdf table t4(4,13)=  ("DOWN ${epi2_`a'_1}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_5'") 
        putpdf table t4(4,13), bgcolor("`col6_5'") 
        putpdf table t4(4,12), bgcolor("`col1_5'") 
        }
    * EPI - americas
    if ${epi_`a'_2}>0 {
        putpdf table t4(6,13)=  ("UP ${epi2_`a'_2}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_4'") 
        putpdf table t4(6,13), bgcolor("`col6_4'") 
        putpdf table t4(6,12), bgcolor("`col1_4'") 
        }
    else if ${epi_`a'_2}<0 {
        putpdf table t4(6,13)=  ("DOWN ${epi2_`a'_2}"), halign(center) valign(center) font("Calibri Light", 12) bgcolor("`col6_5'") 
        putpdf table t4(6,13), bgcolor("`col6_5'") 
        putpdf table t4(6,12), bgcolor("`col1_5'") 
        }

    putpdf paragraph ,  font("Calibri Light", 11)
    putpdf text (" "), linebreak
    putpdf text ("This last chart presents the percentage change in deaths between 2000 and 2019, ") , font("Calibri Light", 11)
    putpdf text ("due to population growth, population aging, ") , font("Calibri Light", 11)
    putpdf text ("and due to ") , font("Calibri Light", 11)
    putpdf text ("epidemiological change. ") , italic font("Calibri Light", 11)
    putpdf text ("This last effect is more accurately called ") , font("Calibri Light", 11)
    putpdf text ("the change in age-specific mortality rates, ") , italic font("Calibri Light", 11)
    putpdf text ("which can be ascribed to changes in the health profile of a population ") , font("Calibri Light", 11)
    putpdf text ("and national health system changes.") , font("Calibri Light", 11)

** Save the PDF
    local c_date = c(current_date)
    local date_string = subinstr("`c_date'", " ", "", .)
    putpdf save "`outputpath'/briefing_`crep'", replace

restore
** }
