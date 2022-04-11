** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper1-110-population.do
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
    log using "`logpath'\paper1-110-population", replace
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
import excel using "`datapath'/paper1-ncd/WPP2019_POP_F15_1_ANNUAL_POPULATION_BY_AGE_BOTH_SEXES.xlsx", clear sheet("ESTIMATES") cellrange(a18:ac18122)
** Variable names
drop B D
rename A iid
rename C area
rename E iso3n 
rename F rtype 
rename G rcode
rename H year
#delimit ; 
    rename I age0; rename J age5;rename K age10;rename L age15;rename M age20; rename N age25; rename O age30; rename P age35; rename Q age40; 
    rename R age45;rename S age50;rename T age55;rename U age60;rename V age65;rename W age70;rename X age75;rename Y age80;
    rename Z age85;rename AA age90;rename AB age95;rename AC age100;
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
tempfile unpop2019
save `unpop2019' , replace

** Link to ISO codes
** ISO dataset prepared in 
** C:\Users\20003146\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\
** ap010-load-ghe-burden.do
use "`datapath'\from-owid\regions", clear
merge 1:m iso3n using `unpop2019'
keep if _merge>1

** To link with the WHO GHE dataset, we keep 33 countries across EIGHT subregions
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
** 11-APR-2021
        ** Limit to all countries and selected regions
        ** Using a few of the regions in associated RESULTS text
        ** Keep countries and major UN regions
        ** 900      World
        ** 1503     High Income
        ** 1517     Middle income
        ** 1500     Low income
        ** 903      Africa
        ** 935      Asia
        ** 908      Europe
        ** 904      LAC
        ** 905      Northern America
        ** 909      Oceania
        ** 1830     LAC ?
        ** 915      Caribbean
        ** 916      Central America
        ** 931      South America
        #delimit ;
        keep if  (paho_subregion<. & who_region<.) | 
                    (iso3n==900 | iso3n==1503 | iso3n==1517 | iso3n==1500 | 
                    iso3n==903 | iso3n==935 | iso3n==908 | iso3n==904 | iso3n==905 | iso3n==909 |
                    iso3n==1830 | iso3n==915 | iso3n==916 | iso3n==931 );
        label define iso3n 900     "World"
                            1503    "High income"
                            1517    "Middle income"
                            1500    "Low income"
                            903     "Africa"
                            935     "Asia"
                            908     "Europe"
                            904     "LAC"
                            905     "Northern America"
                            909     "Oceania"
                            1830    "LAC again"
                            915     "Caribbean"
                            916     "Central America"
                            931     "South America" , modify; 
        label values iso3n iso3n;
        #delimit cr
** Drop the 2 countries with populations below 90k in 2019 
drop if iso3c=="DMA" | iso3c=="KNA"
drop _merge area rtype who_region un_region 
sort paho_subregion iso3c
label var iso3c "iso3 Alphanumeric country code"
** Save the basic population file
gen sex = 3 
label define sex_ 1 "men" 2 "women" 3 "both" 
label values sex sex_ 
order sex, after(rcode) 
label data "Population data by age group: Americas 1050 to 2020 (women and men combined)"
sort sex iso3n year 
save "`datapath'/paper1_population2_both", replace



** ------------------------------------------------------------
** Population data from UN WPP (2019 release)
** 2. Men Only
** ------------------------------------------------------------
** Downloaded from:
** https://population.un.org/wpp/Download/Standard/Population/
**
** FULL FILEPATH: 
** https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/EXCEL_FILES/1_Population/WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx
import excel using "`datapath'/paper1-ncd/WPP2019_POP_F15_2_ANNUAL_POPULATION_BY_AGE_MALE.xlsx", clear sheet("ESTIMATES") cellrange(a18:ac18122)
** Variable names
drop B D
rename A iid
rename C area
rename E iso3n 
rename F rtype 
rename G rcode
rename H year
#delimit ; 
    rename I age0; rename J age5;rename K age10;rename L age15;rename M age20; rename N age25; rename O age30; rename P age35; rename Q age40; 
    rename R age45;rename S age50;rename T age55;rename U age60;rename V age65;rename W age70;rename X age75;rename Y age80;
    rename Z age85;rename AA age90;rename AB age95;rename AC age100;
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
tempfile unpop2019
save `unpop2019' , replace

** Link to ISO codes
** ISO dataset prepared in 
** C:\Users\20003146\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\
** ap010-load-ghe-burden.do
use "`datapath'\from-owid\regions", clear
merge 1:m iso3n using `unpop2019'
keep if _merge>1

** To link with the WHO GHE dataset, we keep 33 countries across EIGHT subregions
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
** 11-APR-2021
        ** Limit to all countries and selected regions
        ** Using a few of the regions in associated RESULTS text
        ** Keep countries and major UN regions
        ** 900      World
        ** 1503     High Income
        ** 1517     Middle income
        ** 1500     Low income
        ** 903      Africa
        ** 935      Asia
        ** 908      Europe
        ** 904      LAC
        ** 905      Northern America
        ** 909      Oceania
        ** 1830     LAC ?
        ** 915      Caribbean
        ** 916      Central America
        ** 931      South America
        #delimit ;
        keep if  (paho_subregion<. & who_region<.) | 
                    (iso3n==900 | iso3n==1503 | iso3n==1517 | iso3n==1500 | 
                    iso3n==903 | iso3n==935 | iso3n==908 | iso3n==904 | iso3n==905 | iso3n==909 |
                    iso3n==1830 | iso3n==915 | iso3n==916 | iso3n==931 );
        label define iso3n 900     "World"
                            1503    "High income"
                            1517    "Middle income"
                            1500    "Low income"
                            903     "Africa"
                            935     "Asia"
                            908     "Europe"
                            904     "LAC"
                            905     "Northern America"
                            909     "Oceania"
                            1830    "LAC again"
                            915     "Caribbean"
                            916     "Central America"
                            931     "South America" , modify; 
        label values iso3n iso3n;
        #delimit cr
** Drop the 2 countries with populations below 90k in 2019 
drop if iso3c=="DMA" | iso3c=="KNA"
drop _merge area rtype who_region un_region 
sort paho_subregion iso3c
label var iso3c "iso3 Alphanumeric country code"
** Save the basic population file
gen sex = 1
label define sex_ 1 "men" 2 "women" 3 "both" 
label values sex sex_ 
order sex, after(rcode) 
label data "Population data by age group: Americas 1050 to 2020 (men)"
save "`datapath'/paper1_population2_men", replace




** ------------------------------------------------------------
** Population data from UN WPP (2019 release)
** 3. Women Only
** ------------------------------------------------------------
** Downloaded from:
** https://population.un.org/wpp/Download/Standard/Population/
**
** FULL FILEPATH: 
** https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/EXCEL_FILES/1_Population/WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx
import excel using "`datapath'/paper1-ncd/WPP2019_POP_F15_3_ANNUAL_POPULATION_BY_AGE_FEMALE.xlsx", clear sheet("ESTIMATES") cellrange(a18:ac18122)
** Variable names
drop B D
rename A iid
rename C area
rename E iso3n 
rename F rtype 
rename G rcode
rename H year
#delimit ; 
    rename I age0; rename J age5;rename K age10;rename L age15;rename M age20; rename N age25; rename O age30; rename P age35; rename Q age40; 
    rename R age45;rename S age50;rename T age55;rename U age60;rename V age65;rename W age70;rename X age75;rename Y age80;
    rename Z age85;rename AA age90;rename AB age95;rename AC age100;
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
tempfile unpop2019
save `unpop2019' , replace

** Link to ISO codes
** ISO dataset prepared in 
** C:\Users\20003146\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\
** ap010-load-ghe-burden.do
use "`datapath'\from-owid\regions", clear
merge 1:m iso3n using `unpop2019'
keep if _merge>1

** To link with the WHO GHE dataset, we keep 33 countries across EIGHT subregions
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
** 11-APR-2021
        ** Limit to all countries and selected regions
        ** Using a few of the regions in associated RESULTS text
        ** Keep countries and major UN regions
        ** 900      World
        ** 1503     High Income
        ** 1517     Middle income
        ** 1500     Low income
        ** 903      Africa
        ** 935      Asia
        ** 908      Europe
        ** 904      LAC
        ** 905      Northern America
        ** 909      Oceania
        ** 1830     LAC ?
        ** 915      Caribbean
        ** 916      Central America
        ** 931      South America
        #delimit ;
        keep if  (paho_subregion<. & who_region<.) | 
                    (iso3n==900 | iso3n==1503 | iso3n==1517 | iso3n==1500 | 
                    iso3n==903 | iso3n==935 | iso3n==908 | iso3n==904 | iso3n==905 | iso3n==909 |
                    iso3n==1830 | iso3n==915 | iso3n==916 | iso3n==931 );
        label define iso3n 900     "World"
                            1503    "High income"
                            1517    "Middle income"
                            1500    "Low income"
                            903     "Africa"
                            935     "Asia"
                            908     "Europe"
                            904     "LAC"
                            905     "Northern America"
                            909     "Oceania"
                            1830    "LAC again"
                            915     "Caribbean"
                            916     "Central America"
                            931     "South America" , modify; 
        label values iso3n iso3n;
        #delimit cr
** Drop the 2 countries with populations below 90k in 2019 
drop if iso3c=="DMA" | iso3c=="KNA"
drop _merge area rtype who_region un_region 
sort paho_subregion iso3c
label var iso3c "iso3 Alphanumeric country code"
** Save the basic population file
gen sex = 2
label define sex_ 1 "men" 2 "women" 3 "both" 
label values sex sex_ 
order sex, after(rcode) 
label data "Population data by age group: Americas 1050 to 2020 (women)"
save "`datapath'/paper1_population2_women", replace





** Medium Predictions


** ------------------------------------------------------------
** Population data from UN WPP (2019 release)
** 1. Women and Men combined
** ------------------------------------------------------------
** Downloaded from:
** https://population.un.org/wpp/Download/Standard/Population/
**
** FULL FILEPATH: 
** https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/EXCEL_FILES/1_Population/WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx
import excel using "`datapath'/paper1-ncd/WPP2019_POP_F15_1_ANNUAL_POPULATION_BY_AGE_BOTH_SEXES.xlsx", clear sheet("MEDIUM VARIANT") cellrange(a18:ac20672)
** Variable names
drop B D
rename A iid
rename C area
rename E iso3n 
rename F rtype 
rename G rcode
rename H year
#delimit ; 
    rename I age0; rename J age5;rename K age10;rename L age15;rename M age20; rename N age25; rename O age30; rename P age35; rename Q age40; 
    rename R age45;rename S age50;rename T age55;rename U age60;rename V age65;rename W age70;rename X age75;rename Y age80;
    rename Z age85;rename AA age90;rename AB age95;rename AC age100;
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
tempfile unpop2019
save `unpop2019' , replace

** Link to ISO codes
** ISO dataset prepared in 
** C:\Users\20003146\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\
** ap010-load-ghe-burden.do
use "`datapath'\from-owid\regions", clear
merge 1:m iso3n using `unpop2019'
keep if _merge>1

** To link with the WHO GHE dataset, we keep 33 countries across EIGHT subregions
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
** 11-APR-2021
        ** Limit to all countries and selected regions
        ** Using a few of the regions in associated RESULTS text
        ** Keep countries and major UN regions
        ** 900      World
        ** 1503     High Income
        ** 1517     Middle income
        ** 1500     Low income
        ** 903      Africa
        ** 935      Asia
        ** 908      Europe
        ** 904      LAC
        ** 905      Northern America
        ** 909      Oceania
        ** 1830     LAC ?
        ** 915      Caribbean
        ** 916      Central America
        ** 931      South America
        #delimit ;
        keep if  (paho_subregion<. & who_region<.) | 
                    (iso3n==900 | iso3n==1503 | iso3n==1517 | iso3n==1500 | 
                    iso3n==903 | iso3n==935 | iso3n==908 | iso3n==904 | iso3n==905 | iso3n==909 |
                    iso3n==1830 | iso3n==915 | iso3n==916 | iso3n==931 );
        label define iso3n 900     "World"
                            1503    "High income"
                            1517    "Middle income"
                            1500    "Low income"
                            903     "Africa"
                            935     "Asia"
                            908     "Europe"
                            904     "LAC"
                            905     "Northern America"
                            909     "Oceania"
                            1830    "LAC again"
                            915     "Caribbean"
                            916     "Central America"
                            931     "South America" , modify; 
        label values iso3n iso3n;
        #delimit cr
drop if year==2020
** Drop the 2 countries with populations below 90k in 2019 
drop if iso3c=="DMA" | iso3c=="KNA"
drop _merge area rtype who_region un_region 
sort paho_subregion iso3c
label var iso3c "iso3 Alphanumeric country code"
** Save the basic population file
gen sex = 3 
label define sex_ 1 "men" 2 "women" 3 "both" 
label values sex sex_ 
order sex, after(rcode) 
label data "Population data by age group: Americas 1050 to 2020 (women and men combined)"
sort sex iso3n year 
save "`datapath'/paper1_population2_both_pred", replace



** ------------------------------------------------------------
** Population data from UN WPP (2019 release)
** 2. Men Only
** ------------------------------------------------------------
** Downloaded from:
** https://population.un.org/wpp/Download/Standard/Population/
**
** FULL FILEPATH: 
** https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/EXCEL_FILES/1_Population/WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx
import excel using "`datapath'/paper1-ncd/WPP2019_POP_F15_2_ANNUAL_POPULATION_BY_AGE_MALE.xlsx", clear sheet("MEDIUM VARIANT") cellrange(a18:ac20672)
** Variable names
drop B D
rename A iid
rename C area
rename E iso3n 
rename F rtype 
rename G rcode
rename H year
#delimit ; 
    rename I age0; rename J age5;rename K age10;rename L age15;rename M age20; rename N age25; rename O age30; rename P age35; rename Q age40; 
    rename R age45;rename S age50;rename T age55;rename U age60;rename V age65;rename W age70;rename X age75;rename Y age80;
    rename Z age85;rename AA age90;rename AB age95;rename AC age100;
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
tempfile unpop2019
save `unpop2019' , replace

** Link to ISO codes
** ISO dataset prepared in 
** C:\Users\20003146\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\
** ap010-load-ghe-burden.do
use "`datapath'\from-owid\regions", clear
merge 1:m iso3n using `unpop2019'
keep if _merge>1

** To link with the WHO GHE dataset, we keep 33 countries across EIGHT subregions
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
** 11-APR-2021
        ** Limit to all countries and selected regions
        ** Using a few of the regions in associated RESULTS text
        ** Keep countries and major UN regions
        ** 900      World
        ** 1503     High Income
        ** 1517     Middle income
        ** 1500     Low income
        ** 903      Africa
        ** 935      Asia
        ** 908      Europe
        ** 904      LAC
        ** 905      Northern America
        ** 909      Oceania
        ** 1830     LAC ?
        ** 915      Caribbean
        ** 916      Central America
        ** 931      South America
        #delimit ;
        keep if  (paho_subregion<. & who_region<.) | 
                    (iso3n==900 | iso3n==1503 | iso3n==1517 | iso3n==1500 | 
                    iso3n==903 | iso3n==935 | iso3n==908 | iso3n==904 | iso3n==905 | iso3n==909 |
                    iso3n==1830 | iso3n==915 | iso3n==916 | iso3n==931 );
        label define iso3n 900     "World"
                            1503    "High income"
                            1517    "Middle income"
                            1500    "Low income"
                            903     "Africa"
                            935     "Asia"
                            908     "Europe"
                            904     "LAC"
                            905     "Northern America"
                            909     "Oceania"
                            1830    "LAC again"
                            915     "Caribbean"
                            916     "Central America"
                            931     "South America" , modify; 
        label values iso3n iso3n;
        #delimit cr
drop if year==2020
** Drop the 2 countries with populations below 90k in 2019 
drop if iso3c=="DMA" | iso3c=="KNA"
drop _merge area rtype who_region un_region 
sort paho_subregion iso3c
label var iso3c "iso3 Alphanumeric country code"
** Save the basic population file
gen sex = 1
label define sex_ 1 "men" 2 "women" 3 "both" 
label values sex sex_ 
order sex, after(rcode) 
label data "Population data by age group: Americas 1050 to 2020 (men)"
save "`datapath'/paper1_population2_men_pred", replace




** ------------------------------------------------------------
** Population data from UN WPP (2019 release)
** 3. Women Only
** ------------------------------------------------------------
** Downloaded from:
** https://population.un.org/wpp/Download/Standard/Population/
**
** FULL FILEPATH: 
** https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/EXCEL_FILES/1_Population/WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx
import excel using "`datapath'/paper1-ncd/WPP2019_POP_F15_3_ANNUAL_POPULATION_BY_AGE_FEMALE.xlsx", clear sheet("MEDIUM VARIANT") cellrange(a18:ac20672)
** Variable names
drop B D
rename A iid
rename C area
rename E iso3n 
rename F rtype 
rename G rcode
rename H year
#delimit ; 
    rename I age0; rename J age5;rename K age10;rename L age15;rename M age20; rename N age25; rename O age30; rename P age35; rename Q age40; 
    rename R age45;rename S age50;rename T age55;rename U age60;rename V age65;rename W age70;rename X age75;rename Y age80;
    rename Z age85;rename AA age90;rename AB age95;rename AC age100;
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
tempfile unpop2019
save `unpop2019' , replace

** Link to ISO codes
** ISO dataset prepared in 
** C:\Users\20003146\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\
** ap010-load-ghe-burden.do
use "`datapath'\from-owid\regions", clear
merge 1:m iso3n using `unpop2019'
keep if _merge>1

** To link with the WHO GHE dataset, we keep 33 countries across EIGHT subregions
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
** 11-APR-2021
        ** Limit to all countries and selected regions
        ** Using a few of the regions in associated RESULTS text
        ** Keep countries and major UN regions
        ** 900      World
        ** 1503     High Income
        ** 1517     Middle income
        ** 1500     Low income
        ** 903      Africa
        ** 935      Asia
        ** 908      Europe
        ** 904      LAC
        ** 905      Northern America
        ** 909      Oceania
        ** 1830     LAC ?
        ** 915      Caribbean
        ** 916      Central America
        ** 931      South America
        #delimit ;
        keep if  (paho_subregion<. & who_region<.) | 
                    (iso3n==900 | iso3n==1503 | iso3n==1517 | iso3n==1500 | 
                    iso3n==903 | iso3n==935 | iso3n==908 | iso3n==904 | iso3n==905 | iso3n==909 |
                    iso3n==1830 | iso3n==915 | iso3n==916 | iso3n==931 );
        label define iso3n 900     "World"
                            1503    "High income"
                            1517    "Middle income"
                            1500    "Low income"
                            903     "Africa"
                            935     "Asia"
                            908     "Europe"
                            904     "LAC"
                            905     "Northern America"
                            909     "Oceania"
                            1830    "LAC again"
                            915     "Caribbean"
                            916     "Central America"
                            931     "South America" , modify; 
        label values iso3n iso3n;
        #delimit cr
drop if year==2020
** Drop the 2 countries with populations below 90k in 2019 
drop if iso3c=="DMA" | iso3c=="KNA"
drop _merge area rtype who_region un_region 
sort paho_subregion iso3c
label var iso3c "iso3 Alphanumeric country code"
** Save the basic population file
gen sex = 2
label define sex_ 1 "men" 2 "women" 3 "both" 
label values sex sex_ 
order sex, after(rcode) 
label data "Population data by age group: Americas 1050 to 2020 (women)"
save "`datapath'/paper1_population2_women_pred", replace

** Join the SIX datasets
use "`datapath'/paper1_population2_men", clear 
append using "`datapath'/paper1_population2_men_pred"
append using "`datapath'/paper1_population2_women"
append using "`datapath'/paper1_population2_women_pred"
append using "`datapath'/paper1_population2_both"
append using "`datapath'/paper1_population2_both_pred"

recode iso3n (905 = 904)
label define iso3n 904 "Americas UN" 1830 "LAC" 10000 "Americas IH" 20000 "PAHO subregions IH", modify
label values iso3n iso3n
collapse (sum) a0 a5 a10 a15 a20 a25 a30 a35 a40 a45 a50 a55 a60 a65 a70 a75 a80 a85 a90 a95 a100 , by(iso3n un_subregion paho_subregion sex year)

sort sex iso3n year 
label var un_subregion "UN subregions"
label var paho_subregion "PAHO subregions of the Americas"
** label var iid "Unique code on UN WPP data spreadsheet"
** label var rcode "UN regional code"
label var sex "1=men, 2=women, 3=both"
label var year "Annual totals: 1950 to 2020" 
label data "Population data by age: Americas 1050 to 2020"
save "`datapath'/paper1_population2", replace

