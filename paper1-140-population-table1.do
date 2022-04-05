** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper1-140-population-table1.do
    //  project:				    UN WPP (2019 edition)
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	24-Mar-2022
    //  algorithm task			    Importing the UN WPP data for the Americas

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
    log using "`logpath'\paper1-140-population-table1", replace
** HEADER -----------------------------------------------------

** Load population file from: 
**      paper1-110-population.do 
use "`datapath'/paper1_population2", clear

** Keep required years:
keep if year==2000 | year==2019 
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
keep iso3n iso3c region paho_subregion sex year group1 group2 group3 total pg1 pg2 pg3
sort paho_subregion sex year

** Keep women and men combined
keep if sex==3 

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
label define uid_   34 "NORTH AMERICA"
                    35 "CENTRAL AMERICA" 
                    36 "ANDEAN AREA"
                    37 "SOUTHERN CONE"
                    38 "LATIN CARIBBEAN"
                    39 "NON-LATIN CARIBBEAN"
                    40 "BRAZIL"
                    41 "MEXICO"
                    42 "AMERICAS", modify ;
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
** (3) Percent change 70+ between 2000 and 2019
** (4) Annual growth rate of Older adults
** (5) Dependency Ratio
gsort uid -year
gen pc1 = ( group3[_n] - group3[_n-1] ) / total[_n-1] if paho_subregion[_n] == paho_subregion[_n-1] 
** Growth rate all ages
gen gr = round( ( ( ln(total[_n-1] / total[_n]) ) / 19 ) * 100 , 0.01)  if uid[_n] == uid[_n-1] 
** Growth rate older adults (70+)
gen gr3 = round( ( ( ln(group3[_n-1] / group3[_n]) ) / 19 ) * 100 , 0.01)  if uid[_n] == uid[_n-1] 
** Old Age Dependency Ratio: Ratio of people aged 70+ per 100 people aged 20-69
gen dr3 = (group3 / group2) * 100

    forval c = 1(1)40 {   
        forval y = 2000(19)2019 {
            preserve
                keep if uid1==`c' & year==`y'
                ** (1) Country
                global country_`c'_`y' = country1
                ** (2) Population
                local pop_`c'_`y' = total
                global pop_`c'_`y' : dis %11.0fc `pop_`c'_`y''
                ** (3) Percent 70+
                local a70_`c'_`y' = pg3 * 100      
                global a70_`c'_`y' : dis %5.1f `a70_`c'_`y''
                ** (4) Growth rates
                local gr_`c'_`y' = gr      
                global gr_`c'_`y' : dis %5.2f `gr_`c'_`y''
                local gr3_`c'_`y' = gr3      
                global gr3_`c'_`y' : dis %5.2f `gr3_`c'_`y''
            restore
        }
    }

** Construct Word Table, Dim: 35 rows by 7 cols
putdocx begin , font("calibri light", 10)
putdocx table t1 = (42,6) 

** Structural formats
putdocx table t1(.,1) , width(25%)
putdocx table t1(.,2) , width(15%)
putdocx table t1(.,3) , width(15%)
putdocx table t1(.,4) , width(15%)
putdocx table t1(.,5) , width(15%)
putdocx table t1(.,6) , width(15%)

putdocx table t1(1,3) , colspan(2)
putdocx table t1(1,4) , colspan(2)
putdocx table t1(1/2,.) , shading("bfbfbf")
putdocx table t1(3,.) , shading("e6e6e6")
putdocx table t1(4,.) , shading("e6e6e6")
putdocx table t1(7,.) , shading("e6e6e6")
putdocx table t1(15,.) , shading("e6e6e6")
putdocx table t1(21,.) , shading("e6e6e6")
putdocx table t1(26,.) , shading("e6e6e6")
putdocx table t1(30,.) , shading("e6e6e6")
putdocx table t1(41,.) , shading("e6e6e6")
putdocx table t1(42,.) , shading("e6e6e6")


** x2 Header rows
** Row 1
putdocx table t1(1,1) = ("Country"), halign(right)
putdocx table t1(1,2) = ("Population in 2019"), halign(right)
putdocx table t1(1,3) = ("Percent of population aged 70+"), halign(right)
putdocx table t1(1,4) = ("Annual growth rate (2000 to 2019)"), halign(right)
** Row 2
putdocx table t1(2,3) = ("2000"), halign(right)
putdocx table t1(2,4) = ("2019"), halign(right)
putdocx table t1(2,5) = ("All ages"), halign(right)
putdocx table t1(2,6) = ("Older adults (70+)"), halign(right)

** ROW 1: Country
** ROW 2: Population
** ROW 3: Percent 70+ years (2000)
** ROW 4: Percent 70+ years (2019)
local coi = 3 
forval c = 3(1)42 {
    global coi = `c' - 2
    putdocx table t1(`c',1) = ("${country_${coi}_2000}"), halign(right)
    putdocx table t1(`c',2) = ("${pop_${coi}_2000}"), halign(right)
    putdocx table t1(`c',3) = ("${a70_${coi}_2000}"), halign(right)
    putdocx table t1(`c',4) = ("${a70_${coi}_2019}"), halign(right)
    putdocx table t1(`c',5) = ("${gr_${coi}_2000}"), halign(right)
    putdocx table t1(`c',6) = ("${gr3_${coi}_2000}"), halign(right)
}


** Save Word table
putdocx save "`outputpath'/articles/paper-ncd/article-draft/ncd_table1", replace 


