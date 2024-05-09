** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-140-figure3-version1.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	9-Jul-2022
    //  algorithm task			    Figure 3

    ** General algorithm set-up
    version 17
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DATASETS to encrypted SharePoint folder
    local datapath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\Sync\CaribData\My Drive\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\paper2-140-figure3-version1", replace
** HEADER -----------------------------------------------------

use "`datapath'\paper2-inj\dataset01", clear

rename mortr arate
rename dalyr drate
** -----------------------------------------------------
** Keep only the INJURY conditions used in the report
** -----------------------------------------------------
** (1)  56   "interpersonal violence" 
** (2)  48   "road injury" 
** (3)  55   "self harm" 
** (4)  50   "falls" 
** (5)  52   "drowning" 
** (6)  53   "mechanical forces" 
** (7)  51   "fire and heat" 
** (8)  49   "poisonings" 
** (9)  57   "colective violence" 
** (10) 54   "natural disasters" 

gen cod = 1 if ghecause==56 
replace cod = 2 if ghecause==48
replace cod = 3 if ghecause==55
replace cod = 4 if ghecause==50
replace cod = 5 if ghecause==52
replace cod = 6 if ghecause==53
replace cod = 7 if ghecause==51
replace cod = 8 if ghecause==49
replace cod = 9 if ghecause==57
replace cod = 10 if ghecause==54
replace cod = 11 if ghecause==1000
replace cod = 12 if ghecause==1100
replace cod = 13 if ghecause==1200

label define ghecause_ 1000 "all injuries" 1100 "unintentional injuries" 1200 "intentional injuries",modify
label values ghecause ghecause_

decode ghecause, gen(codname)
labmask cod, val(codname)
keep if cod<. 
order cod, after(sex)
sort cod year sex region
drop ghecause

** Region Restriction
** Americas + Subregions
keep if (region<=33 | region==2000)

** Reshape to wide
keep year sex region cod paho* drate 
reshape wide drate , i(year cod region) j(sex)

** Save the dataset
keep if year==2000 | year==2005 | year>=2010
drop paho_subregion
drop if region==2000
tempfile data1
save `data1', replace



** -----------------------------------------------
** LOAD GII METRICS
** -----------------------------------------------
import excel using "`datapath'\paper2-inj\GII_HDR2020_040722.xlsx", sheet("GII_HDR2020_040722") clear first
drop region

** Keep only the 33 countries of interest and give same numbering as "data1" (1 to 33)
#delimit ;
keep if     iso3=="ATG" | iso3=="ARG" |
            iso3=="BHS" | iso3=="BLZ" |
            iso3=="BOL" | iso3=="BRA" |
            iso3=="BRB" | iso3=="CAN" |
            iso3=="CHL" | iso3=="COL" |
            iso3=="CRI" | iso3=="CUB" |
            iso3=="DOM" | iso3=="ECU" |
            iso3=="GRD" | iso3=="GTM" |
            iso3=="GUY" | iso3=="HND" |
            iso3=="HTI" | iso3=="JAM" |
            iso3=="LCA" | iso3=="MEX" |
            iso3=="NIC" | iso3=="PAN" |
            iso3=="PRY" | iso3=="SLV" |
            iso3=="SUR" | iso3=="TTO" |
            iso3=="URY" | iso3=="USA" |
            iso3=="VCT" | iso3=="VEN" |
            iso3=="PER" ;
#delimit cr

gen region = 1 if iso3=="ATG"
replace region = 2 if iso3=="ARG"
replace region = 3 if iso3=="BHS"
replace region = 4 if iso3=="BRB"
replace region = 5 if iso3=="BOL"
replace region = 6 if iso3=="BRA"
replace region = 7 if iso3=="BLZ"
replace region = 8 if iso3=="CAN"
replace region = 9 if iso3=="CHL"
replace region = 10 if iso3=="COL"
replace region = 11 if iso3=="CRI"
replace region = 12 if iso3=="CUB"
replace region = 13 if iso3=="DOM"
replace region = 14 if iso3=="ECU"
replace region = 15 if iso3=="SLV"
replace region = 16 if iso3=="GRD"
replace region = 17 if iso3=="GTM"
replace region = 18 if iso3=="GUY"
replace region = 19 if iso3=="HTI"
replace region = 20 if iso3=="HND"
replace region = 21 if iso3=="JAM"
replace region = 22 if iso3=="MEX"
replace region = 23 if iso3=="NIC"
replace region = 24 if iso3=="PAN"
replace region = 25 if iso3=="PRY"
replace region = 26 if iso3=="PER"
replace region = 27 if iso3=="LCA"
replace region = 28 if iso3=="VCT"
replace region = 29 if iso3=="SUR"
replace region = 30 if iso3=="TTO"
replace region = 31 if iso3=="USA"
replace region = 32 if iso3=="URY"
replace region = 33 if iso3=="VEN"

#delimit ; 
label define region_   
                    1 "Antigua and Barbuda"
                    2 "Argentina"
                    3 "Bahamas"
                    4 "Barbados"
                    5 "Bolivia"
                    6 "Brazil"
                    7 "Belize"
                    8 "Canada"
                    9 "Chile"
                    10 "Colombia"
                    11 "Costa Rica"
                    12 "Cuba"
                    13 "Dominican Republic"
                    14 "Ecuador"
                    15 "El Salvador"
                    16 "Grenada"
                    17 "Guatemala"
                    18 "Guyana"
                    19 "Haiti"
                    20 "Honduras"
                    21 "Jamaica"
                    22 "Mexico"
                    23 "Nicaragua"
                    24 "Panama"
                    25 "Paraguay"
                    26 "Peru"
                    27 "Saint Lucia"
                    28 "Saint Vincent and the Grenadines"
                    29 "Suriname"
                    30 "Trinidad and Tobago"
                    31 "United States"
                    32 "Uruguay"
                    33 "Venezuela"
                    , modify;                     
#delimit cr
label values region region_  
order region

** Keep and reshape to long
**      GII = gender Inequality index
**      MMR = Maternal Mortality Index
**      ABR = Adolescent Birth Rate
**      SE_F = Secondary eduction - female
**      SE_M = Secondary eduction - male
**      PR_F = Share of parliamentary seats - female
**      PR_M = Share of parliamentary seats - male
**      LFPR_F = Labor force participation rate - female 
**      LFPR_M = Labor force participation rate - male 

keep region gii_2000 gii_2005 gii_201* mmr_2* abr_2* se_f_2* se_m_2* pr_f_2* pr_m_2* lfpr_f_2* lfpr_m_2*
reshape long gii_ mmr_ abr_ se_f_ se_m_ pr_f_ pr_m_ lfpr_f_ lfpr_m_ , i(region) j(year)
merge 1:m region year using `data1'
drop _merge
sort year region cod





/*
** -----------------------------------------------
** ANALYSIS
** -----------------------------------------------
** Outcome
forval x=11(1)13 {
    preserve
    keep if cod==`x'
    gen out`x' = ln(drate1/drate2)
    xtset region year , yearly
    dis "OUTCOME IS `x' "
    dis "LONGITUDINAL" 
    ///xtreg out`x' se_f_ if year>=2010 & year<=2019
    regress out`x' gii_ if year==2019
    restore
    }
