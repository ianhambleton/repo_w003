** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    paper1-100-population.do
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
    log using "`logpath'\paper1-100-population", replace
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
import excel using "`datapath'/paper1-ncd/Fig1-WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx", clear sheet("ESTIMATES") cellrange(a165:bz306)
** Variable names
drop B D
rename A iid
rename C area
rename E iso3n 
rename F rtype 
rename G rcode 
local year = 1950 
foreach var in H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ {
    rename `var' p`year'
    label var p`year' "Year of estimate: `year'"
    replace p`year' = p`year'*1000
    format p`year' %15.0fc
    local year = `year'+1
}
tempfile unpop2019
save `unpop2019' , replace

** Link to ISO codes
** ISO dataset prepared in 
** C:\Users\20003146\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\
** ap010-load-ghe-burden.do
use "`datapath'\from-owid\regions", clear
merge 1:1 iso3n using `unpop2019'
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
keep if paho_subregion<. & who_region<.
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
label data "Population data: Americas 1050 to 2020 (women and men combined)"
save "`datapath'/paper1_population1_both", replace



** ------------------------------------------------------------
** Population data from UN WPP (2019 release)
** 2. Men Only
** ------------------------------------------------------------
** Downloaded from:
** https://population.un.org/wpp/Download/Standard/Population/
**
** FULL FILEPATH: 
** https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/EXCEL_FILES/1_Population/WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx
import excel using "`datapath'/paper1-ncd/Fig1-WPP2019_POP_F01_2_TOTAL_POPULATION_MALE.xlsx", clear sheet("ESTIMATES") cellrange(a164:bz272)
** Variable names
drop B D
rename A iid
rename C area
rename E iso3n 
rename F rtype 
rename G rcode 
local year = 1950 
foreach var in H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ {
    rename `var' p`year'
    label var p`year' "Year of estimate: `year'"
    replace p`year' = p`year'*1000
    format p`year' %15.0fc
    local year = `year'+1
}
tempfile unpop2019
save `unpop2019' , replace

** Link to ISO codes
** ISO dataset prepared in 
** C:\Users\20003146\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\
** ap010-load-ghe-burden.do
use "`datapath'\from-owid\regions", clear
merge 1:1 iso3n using `unpop2019'
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
keep if paho_subregion<. & who_region<.
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
label data "Population data: Americas 1050 to 2020 (men)"
save "`datapath'/paper1_population1_men", replace




** ------------------------------------------------------------
** Population data from UN WPP (2019 release)
** 3. Women Only
** ------------------------------------------------------------
** Downloaded from:
** https://population.un.org/wpp/Download/Standard/Population/
**
** FULL FILEPATH: 
** https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/EXCEL_FILES/1_Population/WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx
import excel using "`datapath'/paper1-ncd/Fig1-WPP2019_POP_F01_3_TOTAL_POPULATION_FEMALE.xlsx", clear sheet("ESTIMATES") cellrange(a164:bz272)
** Variable names
drop B D
rename A iid
rename C area
rename E iso3n 
rename F rtype 
rename G rcode 
local year = 1950 
foreach var in H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ {
    rename `var' p`year'
    label var p`year' "Year of estimate: `year'"
    replace p`year' = p`year'*1000
    format p`year' %15.0fc
    local year = `year'+1
}
tempfile unpop2019
save `unpop2019' , replace

** Link to ISO codes
** ISO dataset prepared in 
** C:\Users\20003146\OneDrive - The University of the West Indies\repo_ianhambleton\repo_w003\
** ap010-load-ghe-burden.do
use "`datapath'\from-owid\regions", clear
merge 1:1 iso3n using `unpop2019'
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
keep if paho_subregion<. & who_region<.
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
label data "Population data: Americas 1050 to 2020 (women)"
save "`datapath'/paper1_population1_women", replace



** Join the THREE datasets
use "`datapath'/paper1_population1_men", clear 
append using "`datapath'/paper1_population1_women"
append using "`datapath'/paper1_population1_both"
label data "Population data: Americas 1050 to 2020"
save "`datapath'/paper1_population1", replace
