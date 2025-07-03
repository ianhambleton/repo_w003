** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper2-2025-001.do
    //  project:				    WHO Global Health Estimates 2021
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	19-JUN-2025
    //  algorithm task			    Importing the UN WPP data for the Americas (2024 Edition)

    ** General algorithm set-up
    version 18
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DATASETS to encrypted SharePoint folder
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data\2025"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs\2025"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs\2025"


    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\paper2-2025-001", replace
** HEADER -----------------------------------------------------


** ------------------------------------------------------------
** Population data from UN WPP (2024 release)
** WOMEN AND MEN COMBINED
** ------------------------------------------------------------
** Downloaded from (Active web location in June 2025)
** https://population.un.org/wpp/downloads?folder=Standard%20Projections&group=Population
import excel using "`datapath'/UN-WPP-2024/WPP2024_POP_F02_1_POPULATION_5-YEAR_AGE_GROUPS_BOTH_SEXES.xlsx", clear sheet("Estimates") cellrange(a18:af22000)
** Variable names
drop B D G H
rename A iid
rename C area
rename E uncode 
rename F iso3c 
rename I rtype 
rename J rcode
rename K year
#delimit ; 
    rename L age0; rename M age5;rename N age10;rename O age15;rename P age20; rename Q age25; rename R age30; rename S age35; rename T age40; 
    rename U age45;rename V age50;rename W age55;rename X age60;rename Y age65;rename Z age70;rename AA age75;rename AB age80;
    rename AC age85;rename AD age90;rename AE age95;rename AF age100;
#delimit cr

local year = 0 
forval x = 0(5)100 {
    local y = `x'+4
    replace age`x' = "" if age`x'=="..." 
    gen a`x' = real(age`x')
    label var a`x' "Population in age range: `x' to `y'"
    replace a`x' = a`x'*1000
    format a`x' %15.0fc
    drop age`x'
}
tempfile unpop2024
save `unpop2024' , replace

** Link to PAHO SUB-REGIONS variable 
** Prepared in paper2-2025-001.do
use "`datapath'\regions", clear

merge 1:m iso3c using `unpop2024'
keep if _merge>1

** To link with the WHO GHE dataset, we keep 35 countries across EIGHT subregions
** Within the region of the Americas, the report groups countries into eight subregions, as defined by PAHO:
** - North America
**      2 countries: Canada, USA
** - Central America
**      7 countries: Belize, Costa Rica, El Salvador, Guatemala, Honduras, Nicaragua, Panama
** - Andean
**      5 countries: Bolivia, Colombia, Ecuador, Peru, Venezuela
** - Southern Cone
**      4 countries: Argentina, Chile, Paraguay, Uruguay
** - Latin Caribbean
**      3 countries: Cuba, Dominican Republic, Haiti
** - Non-Latin Caribbean (10)
**      10 countries: Antigua and Barbuda, Bahamas, Barbados, Grenada, Guyana, Jamaica, Saint Lucia, Saint Vincent and the
**                      Grenadines, Suriname, Trinidad and Tobago
** - Brazil as a separate country
** - Mexico as a separate country
**
** 19-JUN-2025
        ** Limit to all countries and selected regions
        ** Using a few of the regions in associated RESULTS text
        ** Keep countries and major UN regions
        ** 900      World
        ** 904      LAC
        ** 915      Caribbean
        ** 916      Central America
        ** 931      South America
        #delimit ;
        keep if  paho_subregion<. | 
                    (iso3n==900 | iso3n==904 | iso3n==905 | iso3n==915 | iso3n==916 | iso3n==931 );
        label define iso3n  900     "World"
                            904     "LAC"
                            905     "Northern America"
                            915     "Caribbean"
                            916     "Central America"
                            931     "South America" , modify; 
        label values iso3n iso3n;
        #delimit cr

drop _merge area rtype 
sort paho_subregion iso3c
label var iso3c "iso3 Alphanumeric country code"
** Save the basic population file
gen sex = 3 
label define sex_ 1 "men" 2 "women" 3 "both" 
label values sex sex_ 
order sex, after(rcode) 
label data "Population data by age group: Americas (women and men combined)"
sort sex iso3n year 
tempfile un_wpp_2024_americas_3
save `un_wpp_2024_americas_3', replace




** ------------------------------------------------------------
** Population data from UN WPP (2024 release)
** MEN ONLY
** ------------------------------------------------------------
** Downloaded from (Active web location in June 2025)
** https://population.un.org/wpp/downloads?folder=Standard%20Projections&group=Population
import excel using "`datapath'/UN-WPP-2024/WPP2024_POP_F02_2_POPULATION_5-YEAR_AGE_GROUPS_MALE.xlsx", clear sheet("Estimates") cellrange(a18:af22000)
** Variable names
drop B D G H
rename A iid
rename C area
rename E uncode 
rename F iso3c 
rename I rtype 
rename J rcode
rename K year
#delimit ; 
    rename L age0; rename M age5;rename N age10;rename O age15;rename P age20; rename Q age25; rename R age30; rename S age35; rename T age40; 
    rename U age45;rename V age50;rename W age55;rename X age60;rename Y age65;rename Z age70;rename AA age75;rename AB age80;
    rename AC age85;rename AD age90;rename AE age95;rename AF age100;
#delimit cr

local year = 0 
forval x = 0(5)100 {
    local y = `x'+4
    replace age`x' = "" if age`x'=="..." 
    gen a`x' = real(age`x')
    label var a`x' "Population in age range: `x' to `y'"
    replace a`x' = a`x'*1000
    format a`x' %15.0fc
    drop age`x'
}
tempfile unpop2024
save `unpop2024' , replace

** Link to PAHO SUB-REGIONS variable 
** Prepared in paper2-2025-001.do
use "`datapath'\regions", clear

merge 1:m iso3c using `unpop2024'
keep if _merge>1

** To link with the WHO GHE dataset, we keep 35 countries across EIGHT subregions
** Within the region of the Americas, the report groups countries into eight subregions, as defined by PAHO:
** - North America
**      2 countries: Canada, USA
** - Central America
**      7 countries: Belize, Costa Rica, El Salvador, Guatemala, Honduras, Nicaragua, Panama
** - Andean
**      5 countries: Bolivia, Colombia, Ecuador, Peru, Venezuela
** - Southern Cone
**      4 countries: Argentina, Chile, Paraguay, Uruguay
** - Latin Caribbean
**      3 countries: Cuba, Dominican Republic, Haiti
** - Non-Latin Caribbean (10)
**      10 countries: Antigua and Barbuda, Bahamas, Barbados, Grenada, Guyana, Jamaica, Saint Lucia, Saint Vincent and the
**                      Grenadines, Suriname, Trinidad and Tobago
** - Brazil as a separate country
** - Mexico as a separate country
**
** 19-JUN-2025
        ** Limit to all countries and selected regions
        ** Using a few of the regions in associated RESULTS text
        ** Keep countries and major UN regions
        ** 900      World
        ** 904      LAC
        ** 915      Caribbean
        ** 916      Central America
        ** 931      South America
        #delimit ;
        keep if  paho_subregion<. | 
                    (iso3n==900 | iso3n==904 | iso3n==905 | iso3n==915 | iso3n==916 | iso3n==931 );
        label define iso3n  900     "World"
                            904     "LAC"
                            905     "Northern America"
                            915     "Caribbean"
                            916     "Central America"
                            931     "South America" , modify; 
        label values iso3n iso3n;
        #delimit cr

drop _merge area rtype 
sort paho_subregion iso3c
label var iso3c "iso3 Alphanumeric country code"
** Save the basic population file
gen sex = 1
label define sex_ 1 "men" 2 "women" 3 "both" 
label values sex sex_ 
order sex, after(rcode) 
label data "Population data by age group: Americas (women and men combined)"
sort sex iso3n year 
tempfile un_wpp_2024_americas_1
save `un_wpp_2024_americas_1', replace



** ------------------------------------------------------------
** Population data from UN WPP (2024 release)
** WOMEN ONLY
** ------------------------------------------------------------
** Downloaded from (Active web location in June 2025)
** https://population.un.org/wpp/downloads?folder=Standard%20Projections&group=Population
import excel using "`datapath'/UN-WPP-2024/WPP2024_POP_F02_3_POPULATION_5-YEAR_AGE_GROUPS_FEMALE.xlsx", clear sheet("Estimates") cellrange(a18:af22000)
** Variable names
drop B D G H
rename A iid
rename C area
rename E uncode 
rename F iso3c 
rename I rtype 
rename J rcode
rename K year
#delimit ; 
    rename L age0; rename M age5;rename N age10;rename O age15;rename P age20; rename Q age25; rename R age30; rename S age35; rename T age40; 
    rename U age45;rename V age50;rename W age55;rename X age60;rename Y age65;rename Z age70;rename AA age75;rename AB age80;
    rename AC age85;rename AD age90;rename AE age95;rename AF age100;
#delimit cr

local year = 0 
forval x = 0(5)100 {
    local y = `x'+4
    replace age`x' = "" if age`x'=="..." 
    gen a`x' = real(age`x')
    label var a`x' "Population in age range: `x' to `y'"
    replace a`x' = a`x'*1000
    format a`x' %15.0fc
    drop age`x'
}
tempfile unpop2024
save `unpop2024' , replace

** Link to PAHO SUB-REGIONS variable 
** Prepared in paper2-2025-001.do
use "`datapath'\regions", clear

merge 1:m iso3c using `unpop2024'
keep if _merge>1

** To link with the WHO GHE dataset, we keep 35 countries across EIGHT subregions
** Within the region of the Americas, the report groups countries into eight subregions, as defined by PAHO:
** - North America
**      2 countries: Canada, USA
** - Central America
**      7 countries: Belize, Costa Rica, El Salvador, Guatemala, Honduras, Nicaragua, Panama
** - Andean
**      5 countries: Bolivia, Colombia, Ecuador, Peru, Venezuela
** - Southern Cone
**      4 countries: Argentina, Chile, Paraguay, Uruguay
** - Latin Caribbean
**      3 countries: Cuba, Dominican Republic, Haiti
** - Non-Latin Caribbean (10)
**      10 countries: Antigua and Barbuda, Bahamas, Barbados, Grenada, Guyana, Jamaica, Saint Lucia, Saint Vincent and the
**                      Grenadines, Suriname, Trinidad and Tobago
** - Brazil as a separate country
** - Mexico as a separate country
**
** 19-JUN-2025
        ** Limit to all countries and selected regions
        ** Using a few of the regions in associated RESULTS text
        ** Keep countries and major UN regions
        ** 900      World
        ** 904      LAC
        ** 915      Caribbean
        ** 916      Central America
        ** 931      South America
        #delimit ;
        keep if  paho_subregion<. | 
                    (iso3n==900 | iso3n==904 | iso3n==905 | iso3n==915 | iso3n==916 | iso3n==931 );
        label define iso3n  900     "World"
                            904     "LAC"
                            905     "Northern America"
                            915     "Caribbean"
                            916     "Central America"
                            931     "South America" , modify; 
        label values iso3n iso3n;
        #delimit cr

drop _merge area rtype 
sort paho_subregion iso3c
label var iso3c "iso3 Alphanumeric country code"
** Save the basic population file
gen sex = 2
label define sex_ 1 "men" 2 "women" 3 "both" 
label values sex sex_ 
order sex, after(rcode) 
label data "Population data by age group: Americas (women and men combined)"
sort sex iso3n year 
tempfile un_wpp_2024_americas_2
save `un_wpp_2024_americas_2', replace


** Join the THREE datasets
use `un_wpp_2024_americas_1', clear 
append using `un_wpp_2024_americas_2'
append using `un_wpp_2024_americas_3'

**NOTE - FINISH RESHAPE, 
**NOTE - THEN MERGE WITH GHE...
**NOTE - THEN CALCULATE RATES 
**NOTE -        BY COUNTRY - once for individual conditions, once for grouped conditions
**NOTE -        BY SUBREGION - once for individual conditions, once for grouped conditions
**NOTE -        BY REGION - once for individual conditions, once for grouped conditions

** Only need to add population to the GHE datasets
keep iso3c iso3n year sex a*
reshape long a , i(iso3c iso3n year sex) j(age) 
** Keep the same years as for GHE 2024 
keep if year>=2000 & year<=2021

** Create same age categories as GHE data (18 5-year groups)
#delimit ;
recode age  (0=1) (5=2) (10=3) (15=4) (20=5) (25=6) (30=7) 
            (35=8) (40=9) (45=10) (50=11) (55=12) (60=13) 
            (65=14) (70=15) (75=16) (80=17) (85 90 95 100=18);
#delimit cr

#delimit ; 
label define age18_   1 "0-4 yrs"
                    2 "5-9 yrs"
                    3 "10-14 yrs"
                    4 "15-19 yrs"
                    5 "20-24 yrs"
                    6 "25-29 yrs"
                    7 "30-34 yrs"
                    8 "35-39 yrs"
                    9 "40-44 yrs"
                    10 "45-49 yrs"
                    11 "50-54 yrs"
                    12 "55-59 yrs"
                    13 "60-64 yrs"
                    14 "65-69 yrs"
                    15 "70-74 yrs"
                    16 "75-79 yrs"
                    17 "80-84 yrs"
                    18 "85+ yrs"; 
#delimit cr 
label values age age18_ 

rename a pop 
collapse (sum) pop , by(iso3c iso3n year sex age)

label var sex "1=men, 2=women, 3=both"
label var year "Annual totals: 2000 to 2021"
label var age "Age in 18 groups" 
label var pop "UN WPP estimated population"
label data "Population data by age: Americas 2000 to 2021"
save "`datapath'/un-wpp-2024", replace
