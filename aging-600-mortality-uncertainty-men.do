** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    aging-600-mortality-uncertainty.do
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
    log using "`logpath'\aging-600-mortality-uncertainty", replace
** HEADER -----------------------------------------------------

** We create the following for insertion into a sensitivity / uncertainty analysis
**      A. The Original chart (Figure 3, F3)
**      B. TWO new F3 charts using the lower and upper bounds for deaths
**      C. FOUR uncertainty charts:
**          - % change overall          (lo, hi)
**          - % change from pop growth  (lo, hi)
**          - % change from pop aging   (lo, hi)
**          - % change from epi         (lo, hi)
**          - NOTE that for each, the lower bound may not be from the lower bound for deaths, and so on.
**      D. TABLE. 
**          - Rows: Country
**          - Cols: Metrics (# deaths 2000) (# deaths 2019) (# deaths, growth 2000) (# deaths, growth 2019) (# deaths, aging 2000) (# deaths, aging 2019) (# deaths, epi 2000) (# deaths, epi 2019)
**          - Cells: (Lower limit - upper limit)


** ------------------------------------------------
** Load the mortality dataset
** ------------------------------------------------
    use "`datapath'\from-who\deaths3_ci", clear

** append using "`datapath'\from-who\paper1-chap3_byage_groups_both"
	append using "`datapath'\from-who\deaths1_ci"
	keep if sex==1
    keep if who_region==. | who_region==2
	replace iso3c = "LAC" if who_region==2
	replace iso3n = 2000 if who_region==2

	rename age18 age
	rename dths death
    rename dths_lo death_lo
    rename dths_hi death_hi

	** Combined NCDs (6-groups), not all NCDs.
    keep if ghecause==50
	keep if year==2000 | year==2019
	drop paho_subregion agroup 
	rename pop pop_orig
	collapse (sum) death death_lo death_hi (mean) pop = pop_orig , by(iso3c iso3n year age) 
	order iso3c iso3n year  
	bysort year iso3c : egen tpop = sum(pop)
	format tpop %15.0fc
	reshape wide death death_lo death_hi pop tpop , i(iso3c iso3n age) j(year)

    ** Rename variables ready for decomposition loop
    rename death2000        d00_1
    rename death_lo2000     d00_2
    rename death_hi2000     d00_3
    rename death2019        d19_1
    rename death_lo2019     d19_2
    rename death_hi2019     d19_3
    rename pop2000          p00
    rename tpop2000         t00
    rename pop2019          p19
    rename tpop2019         t19
    order iso* age p00 t00 p19 t19 d*

    tempfile decomp
    save `decomp', replace

** Calculate the Decomposition 
tempfile decomp1 decomp2 decomp3

forval x = 1(1)3 {
                    use `decomp', clear
** POINT ESTIMATE
    **              AS = age-structure
    **               P = Population
    **               R = Crude Rate 
    **               D = Deaths

    ** METRIC 1.    POPULATION
    **              Age-specific population from 2000, re-scaled for population growth between 2000 and 2019  
                    **gen as2000_p2019 = (pop2000 / tpop2000) * tpop2019
                    gen extraa = (p00 / t00) * t19

    ** METRIC 2.    RATES
    **              Age-specific Mortality Rates in 2000 and in 2019 
                    ** gen r2000 = death2000 / pop2000
                    ** gen r2019 = death2019 / pop2019
                    gen r00_`x' = d00_`x' / p00
                    gen r19_`x' = d19_`x' / p19

    ** METRIC 3.    DEATHS  
    **		        deaths2000		(Deaths | POP2000 and AS2000 and MR2000). Deaths in 2000
    **		        d_p2019_as2000	(Deaths | POP2019 and AS2000 and MR2000). Deaths in 2019 due to pop growth
    **		        d_p2019_as2019	(Deaths | POP2019 and AS2019 and MR2000). Deaths in 2019 due to pop growth + pop aging
    **		        deaths2019		(Deaths | POP2019 and AS2019 and MR2019). Deaths in 2019 due to pop growth + pop aging + epi-change
    **
    **              (a) deaths2000
    **              Represents deaths in 2000, with population levels of 2000, age-structure of 2000, and mortality-rates (epi) of 2000
    **
    **	            (b) d_p2019_as2000
    **              Represents age-specific DEATHS assuming (i) POP in 2019, (ii) AS in 2000, (iii) mortality rate in 2000
                    ** gen d_p2019_as2000 = as2000_p2019 * (r2000)
                    gen extrab_`x' = extraa * (r00_`x')
    **
    **	            (c) age-specific DEATHS assuming (i) POP in 2019, (ii) AS in 2019, (iii) mortality rate in 2000
                    ** gen d_p2019_as2019 = pop2019 * (r2000) 
                    gen extrac_`x' = p19 * (r00_`x') 
    **
    **              (d) deaths2019
    **              Represents deaths in 2019, with population levels of 2019, age-structure of 2019, and mortality-rates (epi) of 2019
    **
    **              Aggregate over ages / format the new variables
                    collapse (sum) d00_* d19_* extrab_* extrac_*, by(iso3c iso3n)
                    format extrab* extrac* d00* d19* %15.1fc

                    ** CH: Overall change in deaths between 2000 and 2019, as a percentage of (deaths in 2000)
                    ** GR: Due to population growth. As a percentage of (deaths in 2000)
                    ** AS: Population structure/aging. As a percentage of (deaths in 2000)
                    ** EP: Epidemiological change. As a percentage of (deaths in 2000)
                    gen ch`x' = ((d19_`x' - d00_`x') / d00_`x') * 100
                    gen gr`x' = ((extrab_`x' - d00_`x') / d00_`x') * 100
                    gen as`x' = ((extrac_`x' - extrab_`x') / d00_`x') * 100
                    gen ep`x' = ((d19_`x' - extrac_`x') / d00_`x') * 100

                    keep iso3c iso3n d00* d19* ch`x' gr`x' as`x' ep`x'
                    sort iso3n
                    save `decomp`x'', replace
                    }

use `decomp1', clear
merge iso3n using `decomp2'
drop _merge
sort iso3n
merge iso3n using `decomp3'
drop _merge
gen type = 1
label define type_ 1 "deaths" 2 "daly",modify
label values type type_
order iso3c iso3n type d00* d19* ch* gr* as* ep*

** Save the decomposition dataset, then will be used for sensitivity analyses
save "`datapath'\from-who\decomposition_deaths_men", replace


** ------------------------------------------------
** Load the DALY dataset
** ------------------------------------------------
    use "`datapath'\from-who\daly3_ci", clear

** append using "`datapath'\from-who\paper1-chap3_byage_groups_both"
	append using "`datapath'\from-who\daly1_ci"
	keep if sex==1
    keep if who_region==. | who_region==2
	replace iso3c = "LAC" if who_region==2
	replace iso3n = 2000 if who_region==2

	** Combined NCDs (6-groups), not all NCDs.
    keep if ghecause==50
	keep if year==2000 | year==2019
	drop paho_subregion agroup 
	rename pop pop_orig
	collapse (sum) daly daly_lo daly_hi (mean) pop = pop_orig , by(iso3c iso3n year age) 
	order iso3c iso3n year  
	bysort year iso3c : egen tpop = sum(pop)
	format tpop %15.0fc
	reshape wide daly daly_lo daly_hi pop tpop , i(iso3c iso3n age) j(year)

    ** Rename variables ready for decomposition loop
    rename daly2000        d00_1
    rename daly_lo2000     d00_2
    rename daly_hi2000     d00_3
    rename daly2019        d19_1
    rename daly_lo2019     d19_2
    rename daly_hi2019     d19_3
    rename pop2000          p00
    rename tpop2000         t00
    rename pop2019          p19
    rename tpop2019         t19
    order iso* age p00 t00 p19 t19 d*

    tempfile decomp
    save `decomp', replace

** Calculate the Decomposition 
tempfile decomp1 decomp2 decomp3

forval x = 1(1)3 {
                    use `decomp', clear
** POINT ESTIMATE
    **              AS = age-structure
    **               P = Population
    **               R = Crude Rate 
    **               D = Deaths

    ** METRIC 1.    POPULATION
    **              Age-specific population from 2000, re-scaled for population growth between 2000 and 2019  
                    **gen as2000_p2019 = (pop2000 / tpop2000) * tpop2019
                    gen extraa = (p00 / t00) * t19

    ** METRIC 2.    RATES
    **              Age-specific Mortality Rates in 2000 and in 2019 
                    ** gen r2000 = death2000 / pop2000
                    ** gen r2019 = death2019 / pop2019
                    gen r00_`x' = d00_`x' / p00
                    gen r19_`x' = d19_`x' / p19

    ** METRIC 3.    DEATHS  
    **		        deaths2000		(Deaths | POP2000 and AS2000 and MR2000). Deaths in 2000
    **		        d_p2019_as2000	(Deaths | POP2019 and AS2000 and MR2000). Deaths in 2019 due to pop growth
    **		        d_p2019_as2019	(Deaths | POP2019 and AS2019 and MR2000). Deaths in 2019 due to pop growth + pop aging
    **		        deaths2019		(Deaths | POP2019 and AS2019 and MR2019). Deaths in 2019 due to pop growth + pop aging + epi-change
    **
    **              (a) deaths2000
    **              Represents deaths in 2000, with population levels of 2000, age-structure of 2000, and mortality-rates (epi) of 2000
    **
    **	            (b) d_p2019_as2000
    **              Represents age-specific DEATHS assuming (i) POP in 2019, (ii) AS in 2000, (iii) mortality rate in 2000
                    ** gen d_p2019_as2000 = as2000_p2019 * (r2000)
                    gen extrab_`x' = extraa * (r00_`x')
    **
    **	            (c) age-specific DEATHS assuming (i) POP in 2019, (ii) AS in 2019, (iii) mortality rate in 2000
                    ** gen d_p2019_as2019 = pop2019 * (r2000) 
                    gen extrac_`x' = p19 * (r00_`x') 
    **
    **              (d) deaths2019
    **              Represents deaths in 2019, with population levels of 2019, age-structure of 2019, and mortality-rates (epi) of 2019
    **
    **              Aggregate over ages / format the new variables
                    collapse (sum) d00_* d19_* extrab_* extrac_*, by(iso3c iso3n)
                    format extrab* extrac* d00* d19* %15.1fc

                    ** CH: Overall change in deaths between 2000 and 2019, as a percentage of (deaths in 2000)
                    ** GR: Due to population growth. As a percentage of (deaths in 2000)
                    ** AS: Population structure/aging. As a percentage of (deaths in 2000)
                    ** EP: Epidemiological change. As a percentage of (deaths in 2000)
                    gen ch`x' = ((d19_`x' - d00_`x') / d00_`x') * 100
                    gen gr`x' = ((extrab_`x' - d00_`x') / d00_`x') * 100
                    gen as`x' = ((extrac_`x' - extrab_`x') / d00_`x') * 100
                    gen ep`x' = ((d19_`x' - extrac_`x') / d00_`x') * 100

                    keep iso3c iso3n d00* d19* ch`x' gr`x' as`x' ep`x'
                    sort iso3n
                    save `decomp`x'', replace
                    }

use `decomp1', clear
merge iso3n using `decomp2'
drop _merge
sort iso3n
merge iso3n using `decomp3'
drop _merge
gen type = 2
label define type_ 1 "deaths" 2 "daly",modify
label values type type_
order iso3c iso3n type d00* d19* ch* gr* as* ep*

** Save the decomposition dataset, then will be used for sensitivity analyses
save "`datapath'\from-who\decomposition_daly_men", replace

use "`datapath'\from-who\decomposition_deaths_men", replace
append using "`datapath'\from-who\decomposition_daly_men"

** FINAL decomp dataset
save "`datapath'\from-who\decomposition_men", replace
