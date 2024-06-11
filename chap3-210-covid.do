** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap3_210_covid.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	31-MAr-2022
    //  algorithm task			    Reading the WHO GHE dataset - disease burden, YLL and DALY

    ** General algorithm set-up
    version 16
    clear all
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export

    ** DATASETS to encrypted SharePoint folder
    local datapath "C:\yasuki\Sync\output\analyse-write\w003\data"

    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath "C:\yasuki\Sync\output\analyse-write\w003\tech-docs"

    ** REPORTS and Other outputs
    local outputpath "C:\yasuki\Sync\output\analyse-write\w003\outputs"

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\chap3_210_covid", replace
** HEADER -----------------------------------------------------

** RUN covidprofiles_002_jhopkins.do BEFORE this algorithm
local c_date = c(current_date)
local date_string = subinstr("`c_date'", " ", "", .)
use "`datapath'\owid_time_series_`date_string'", clear 


** RESTRICT TO SELECTED COUNTRIES
** We keep 14 CARICOM countries:    --> ATG BHS BRB BLZ DMA GRD GUY HTI JAM KNA LCA VCT SUR TTO
** We keep 6 UKOTS                  --> AIA BMU VGB CYM MSR TCA 
** + Cuba                           --> CUB
** + Dominican Republic             --> DOM
#delimit ;
keep if
    /// North America | 
    iso_code == "CAN" |
    iso_code == "USA" |
    /// Centra America |
    iso_code == "BLZ" |
    iso_code == "CRI" |
    iso_code == "SLV" |
    iso_code == "GTM" |
    iso_code == "HND" |
    iso_code == "NIC" |
    iso_code == "PAN" |    
    /// Andean |
    iso_code == "BOL" |
    iso_code == "COL" |
    iso_code == "ECU" |
    iso_code == "PER" |
    iso_code == "VEN" |
    /// Southern Cone |
    iso_code == "ARG" |
    iso_code == "CHL" |
    iso_code == "PRY" |
    iso_code == "URY" |
    /// Latin Caribbean |
    iso_code == "CUB" |
    iso_code == "DOM" |
    iso_code == "HTI" |
    /// non-Latin Caribbean |
    iso_code == "ATG" |
    iso_code == "BHS" |
    iso_code == "BRB" |
    iso_code == "GRD" |
    iso_code == "GUY" |
    iso_code == "JAM" |
    iso_code == "LCA" |
    iso_code == "VCT" |
    iso_code == "SUR" |
    iso_code == "TTO" |
    /// Brazil |
    iso_code == "BRA" |
    /// Mexico |
    iso_code == "MEX";
#delimit cr

** Sort the dataset, ready for morning manual review 
sort iso date
format pop %15.0fc

** ---------------------------------------------------------
** FINAL PREPARATION
** ---------------------------------------------------------
rename iso_code iso

** Create internal numeric variable for countries 
encode iso, gen(iso_num)
order iso_num pop, after(iso)

** PAHO-SUBREGIONS
gen cgroup = .

replace cgroup = 1 if iso=="CAN" | iso=="USA" 
replace cgroup = 2 if iso=="BLZ" | iso=="CRI" | iso=="SLV" | iso=="GTM" | iso=="HND" | iso=="NIC" | iso=="PAN"
replace cgroup = 3 if iso=="BOL" | iso=="COL" | iso=="ECU" | iso=="PER" | iso=="VEN" 
replace cgroup = 4 if iso=="ARG" | iso=="CHL" | iso=="PRY" | iso=="URY" 
replace cgroup = 5 if iso=="CUB" | iso=="DOM" | iso=="HTI"
replace cgroup = 6 if iso=="ATG" | iso=="BHS" | iso=="BRB" | iso=="GRD" | iso=="GUY" | iso=="JAM" | iso=="LCA" | iso=="VCT" | iso=="SUR" | iso=="TTO" 
replace cgroup = 7 if iso=="BRA"
replace cgroup = 8 if iso=="MEX"
label define cgroup_ 1 "North America" 2 "Central America" 3 "Andean" 4 "Southern Cone" 5 "Latin Caribbean" 6 "non-Latin Caribbean" 7 "Brazil" 8 "Mexico",modify
label values cgroup cgroup_ 

** Fill-in missing data 
replace new_deaths = 0 if new_deaths==. 
replace total_deaths = 0 if total_deaths==. 

keep iso iso_num countryregion cgroup date total_cases total_deaths pop
order iso iso_num countryregion cgroup date total_cases total_deaths pop

** Keep LAST DAY in 2020 - this gives us the cumulative mortality rate in 2020
*! Change final date if running in future
sort iso date 
keep if date == d(31dec2020) | iso_num!=iso_num[_n+1]
gen year = 2020 if date == d(31dec2020)
replace year = 2022 if date == d(8apr2022)
sort year cgroup iso_num 
** Reshape to wide by date 
rename total_deaths cdeath 
rename total_cases ccase
drop date

** COUNTRY LEVEL
preserve
    collapse (sum) ccase cdeath pop, by(cgroup countryregion iso_num year) 
    reshape wide ccase cdeath pop , i(cgroup iso_num) j(year) 
    ** Crude Mortality Rate
    gen mrate2020 = (cdeath2020/pop2020) * 100000
    gen mrate2022 = (cdeath2022/pop2022) * 100000
    gen mrate = (cdeath2022/pop2022) * 100000
    ** Case-Fatality rate (deaths per 100 confirmed cases)
    gen cfat2020 = (cdeath2020/ccase2020) * 100
    gen cfat2022 = (cdeath2022/ccase2022) * 100
    gen cfat = (cdeath2022/ccase2022) * 100

    format mrate2020 mrate2022 mrate cfat2020 cfat2022 cfat %9.1f
    format ccase2022 cdeath2022 %15.0fc 
    list countryregion ccase2022 cdeath2022 mrate2022 cfat2022, sepby(cgroup) linesize(150)
restore

** SUBREGIONS
preserve
    collapse (sum) ccase cdeath pop, by(cgroup year) 
    reshape wide ccase cdeath pop , i(cgroup) j(year) 
    ** Crude Mortality Rate
    gen mrate2020 = (cdeath2020/pop2020) * 100000 * (12/9) 
    gen mrate2022 = (cdeath2022/pop2022) * 100000 * (12/10)
    gen mrate = (cdeath2022/pop2022) * 100000
    ** Case-Fatality rate (deaths per 100 confirmed cases)
    gen cfat2020 = (cdeath2020/ccase2020) * 100
    gen cfat2022 = (cdeath2022/ccase2022) * 100
    gen cfat = (cdeath2022/ccase2022) * 100    

    format mrate2020 mrate2022 mrate cfat2020 cfat2022 cfat %9.1f
    format ccase2022 cdeath2022 %15.0fc 
    list ccase2022 cdeath2022 cgroup mrate2022 cfat2022, linesize(150)
restore

** AMERICAS
preserve
    gen americas = 1 
    collapse (sum) ccase cdeath pop, by(americas year) 
    reshape wide ccase cdeath pop , i(americas) j(year) 
    ** Crude Mortality Rate
    gen mrate2020 = (cdeath2020/pop2020) * 100000 * (12/9) 
    gen mrate2022 = (cdeath2022/pop2022) * 100000 * (12/10)
    gen mrate = (cdeath2022/pop2022) * 100000
    ** Case-Fatality rate (deaths per 100 confirmed cases)
    gen cfat2020 = (cdeath2020/ccase2020) * 100
    gen cfat2022 = (cdeath2022/ccase2022) * 100
    gen cfat = (cdeath2022/ccase2022) * 100

    format mrate2020 mrate2022 mrate cfat2020 cfat2022 cfat %9.1f
    format ccase2022 cdeath2022 %15.0fc 
    list americas ccase2022 cdeath2022 mrate2022 cfat2022, linesize(150)
restore
