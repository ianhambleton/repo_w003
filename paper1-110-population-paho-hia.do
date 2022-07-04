** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper1-110-population-paho-hia.do
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
    log using "`logpath'\paper1-110-population-paho-hia", replace
** HEADER -----------------------------------------------------


** ------------------------------------------------------------
** Population data from UN WPP (2019 release)
** 1. Women and Men combined
** ------------------------------------------------------------
** Downloaded from:
** https://population.un.org/wpp/Download/Standard/Population/
**
** FULL FILEPATH: 
** https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/EXCEL_FILES/1_Population/WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx
import excel using "`datapath'/paho-hia/REG-WPP2019_POP_F08_1_TOTAL_POPULATION_BY_BROAD_AGE_GROUP_BOTH_SEXES.xlsx", clear sheet("ESTIMATES") cellrange(a18:bm3842)

** Variable names
drop B D
rename A iid
rename C area
rename E iso3n 
rename F rtype 
rename G rcode
rename H year
rename I agetot
rename K age4 
rename M age17 
rename O age24
rename BH age65
rename BI age70
keep iid area iso3n rtype rcode year agetot age4 age17 age24 age65 age70 
tempfile unpop2019
save `unpop2019' , replace

** Link to ISO codes
** ISO dataset prepared in 
** C:\Users\20003146\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\
** ap010-load-ghe-burden.do
use "`datapath'\from-owid\regions", clear
merge 1:m iso3n using `unpop2019'
keep if _merge>1

** Keep selected countries of the Caribbean
** Caribbean (915)
** Belize (84)
** French Guiana (254)
** Guyana (328)
** Suriname (740)
** Canada (124)
** USA (840)
keep if rcode==915 | iso3n==915 | iso3n==1830 | iso3n==84 | iso3n==254 | iso3n==328 | iso3n==740 | iso3n==124 | iso3n==840
keep if year==1980

** Final prep
drop _merge area rtype who_region un_region 
sort paho_subregion iso3c
label var iso3c "iso3 Alphanumeric country code"
** Save the basic population file
gen sex = 3 
label define sex_ 1 "men" 2 "women" 3 "both" 
label values sex sex_ 
order sex, after(rcode) 
label data "Population data by age group: Americas to 2020 (women and men combined)"
sort sex iso3n year 
save "`datapath'/paho_hia_both_estimates", replace



** ------------------------------------------------------------
** Population data from UN WPP (2019 release)
** 1. Women and Men combined
** ------------------------------------------------------------
** Downloaded from:
** https://population.un.org/wpp/Download/Standard/Population/
**
** FULL FILEPATH: 
** https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/EXCEL_FILES/1_Population/WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx
import excel using "`datapath'/paho-hia/REG-WPP2019_POP_F08_1_TOTAL_POPULATION_BY_BROAD_AGE_GROUP_BOTH_SEXES.xlsx", clear sheet("MEDIUM VARIANT") cellrange(a18:bm3842)

** Variable names
drop B D
rename A iid
rename C area
rename E iso3n 
rename F rtype 
rename G rcode
rename H year
rename I agetot
rename K age4 
rename M age17 
rename O age24
rename BH age65
rename BI age70
keep iid area iso3n rtype rcode year agetot age4 age17 age24 age65 age70 

tempfile unpop2019
save `unpop2019' , replace

** Link to ISO codes
** ISO dataset prepared in 
** C:\Users\20003146\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\
** ap010-load-ghe-burden.do
use "`datapath'\from-owid\regions", clear
merge 1:m iso3n using `unpop2019'
keep if _merge>1

** Keep selected countries of the Caribbean
** Caribbean (915)
** Belize (84)
** French Guiana (254)
** Guyana (328)
** Suriname (740)
** Canada (124)
** USA (840)
keep if rcode==915 | iso3n==915 | iso3n==1830 | iso3n==84 | iso3n==254 | iso3n==328 | iso3n==740 | iso3n==124 | iso3n==840

** Final prep
drop _merge area rtype who_region un_region 
sort paho_subregion iso3c
label var iso3c "iso3 Alphanumeric country code"
** Save the basic population file
gen sex = 3 
label define sex_ 1 "men" 2 "women" 3 "both" 
label values sex sex_ 
order sex, after(rcode) 
label data "Population data by age group: Americas to 2020 (women and men combined)"
sort sex iso3n year 
save "`datapath'/paho_hia_both_medium", replace


** Join the TWO datasets
use "`datapath'/paho_hia_both_estimates", clear 
append using "`datapath'/paho_hia_both_medium"


** Final Preparation

* Curacao coding
replace iso3c="CUW" if iso3c=="" & iso3n==531
replace un_subregion = 29 if iso3n==531
replace paho_subregion = 6 if iso3n==531

* Americas + Caribbean regional values
replace iso3c="CAR" if iso3c=="" & iso3n==915
replace un_subregion = 1000 if iso3n==915
replace paho_subregion = 1000 if iso3n==915
replace iso3c="LAC" if iso3c=="" & iso3n==1830
replace un_subregion = 2000 if iso3n==1830
replace paho_subregion = 2000 if iso3n==1830


rename age4 t000
gen age4 = real(t000)
rename age17 t00
gen age17 = real(t00)
rename age24 t0
gen age24 = real(t0)
rename age65 t1
gen age65 = real(t1)
rename age70 t2
gen age70 = real(t2)
rename agetot t3
gen agetot = real(t3)
drop t000 t00 t0 t1 t2 t3
replace age4 = age4 * 1000
replace age17 = age17 * 1000
replace age24 = age24 * 1000
replace age65 = age65 * 1000
replace age70 = age70 * 1000
replace agetot = agetot * 1000

** Proportion 65-plus and 70-plus
gen prop4 = (age4/agetot) * 100
gen prop17 = (age17/agetot) * 100
gen prop24 = (age24/agetot) * 100
gen prop65 = (age65/agetot) * 100
gen prop70 = (age70/agetot) * 100

** Keep selected years
keep if year==1980 | year==2020 | year==2060

** Percentage point change in 65+
sort iso3n year 
gen ch4 = prop4 - prop4[_n-1] if iso3n==iso3n[_n-1]
gen ch17 = prop17 - prop17[_n-1] if iso3n==iso3n[_n-1]
gen ch24 = prop24 - prop24[_n-1] if iso3n==iso3n[_n-1]
gen ch65 = prop65 - prop65[_n-1] if iso3n==iso3n[_n-1]
gen ch70 = prop70 - prop70[_n-1] if iso3n==iso3n[_n-1]

sort iso3n year 
label var un_subregion "UN subregions"
label var paho_subregion "PAHO subregions of the Americas"
label var iid "Unique code on UN WPP data spreadsheet"
label var rcode "UN regional code"
label var sex "1=men, 2=women, 3=both"
label var year "Annual totals: 1950 to 2020" 
label var age4 "Number of population <=5" 
label var age17 "Number of population <=18" 
label var age24 "Number of population <=25" 
label var age65 "Number of population 65+" 
label var age70 "Number of population 70+" 
label var agetot "Total population size" 
label var prop65 "Proportion of population 65+" 
label var prop70 "Proportion of population 70+" 
label var ch65 "Percentage point change in proportion 65+" 
label var ch70 "Percentage point change in proportion 70+" 
label data "Aging Americas : 1080 to 2060"
save "`datapath'/paho_hia_aging", replace

** Table of results
format ch65 ch70 prop65 prop70 %9.1f 
list iso3n year prop4 ch4 prop65 ch65 , table sepby(iso3n) linesize(120)
