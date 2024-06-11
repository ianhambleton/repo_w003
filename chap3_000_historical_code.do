** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap3-110-pop-change.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	26-OCT-2021
    //  algorithm task			    Summary graphic of POP change between 2000 and 2019

    ** General algorithm set-up
    version 17
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
    log using "`logpath'\chap3-110-pop-change", replace
** HEADER -----------------------------------------------------

		
** bring in country order 
	insheet using "`datapath'\chapter3\orderkey.csv", comma clear names 
	tempfile key 
	save `key', replace
	
** Prepping reference population data from UN 
** (Need to add DMA data)
	use "`datapath'\chapter3\reference_pop_allyears.dta", clear 
	
		rename age_start1 age
		drop if age ==. 
		replace iso3="SUR" if country_name =="Suriname"
		replace iso3="GUY" if country_name =="Guyana"
		drop if iso3 ==""
		drop if year ==. 
		
		reshape wide pop, i(iso3 age) j(year)
		tempfile pop 
		save `pop', replace 

** Bring in draw data from IHME (received August 17, 2015)
		** insheet using "`folder'/Data/Prepped/death_draws_1990_2010.csv", comma clear 
		use "`datapath'\chapter3\allyears_decomp.dta", clear 
		keep iso3 age country_name death_01990 death_11990 pop1990 death_02013 death_12013 pop2013 totalpop1990 totalpop2013 
		replace age =0 if age==97 
		** GBD uses 97 to correspond to under 5 age group. 

		** keep if sex ==3

		tempfile interim 
		save `interim', replace

** Collapse causes to look at CVD+Diabetes
		///drop  *1995 *2000 *2005 *2010
		///collapse (sum) death* , by(iso3  age)


** now getting total population 
		///merge 1:1 age iso3  using `poplim'
		
		///drop if _m!=3
		///drop _m 

** Generate all age population to see if pop>150,000 in 2010 - nevermind we've scrapped this part 
		preserve
		collapse (sum) pop*, by(iso3)
		foreach x of numlist 1990 2013 { 
		rename pop`x' totalpop`x'
		}
	
		
		tempfile poplim 
		save `poplim', replace
		restore


** Merge on total population
		merge m:1 iso3 using `poplim' 
		keep if _m==3
		drop _m 
/*
** Modified age structure doesn't vary across draws 
		gen agestruc1990_pop2013 = (pop1990/totalpop1990)*totalpop2013

		tempfile data 
		save `data', replace 

** setting local to save
		local start =1 

** generate measures of interest using UN pop and GBD rates, looping through 0-999
		foreach x of numlist 0/1 {
			use `data', clear
			
			
			keep agestruc1990_pop2013 iso3 country_name total* pop* death_`x'1990 death_`x'2013
			gen rt_1990`x' = death_`x'1990/pop1990
			gen rt_2013`x' = death_`x'2013/pop2013
	
			
			gen deaths_2013pop_1990age_`x' = agestruc1990_pop2013*(rt_1990`x')
			gen deaths_2013pop_2013age_`x' = pop2013*(rt_1990`x')
			
			collapse (sum) death* , by(country_name iso3)

			gen change_deaths_`x'=((death_`x'2013-death_`x'1990)/death_`x'1990)


			** Combined metrics of interest
			gen change_pop_growth_`x'=(deaths_2013pop_1990age_`x'-death_`x'1990)/death_`x'1990
			gen change_aging_`x' = (deaths_2013pop_2013age_`x'-deaths_2013pop_1990age_`x')/death_`x'1990
			gen change_epi_`x' = (change_deaths_`x'-change_aging_`x'-change_pop_growth_`x') 
			gen test_epi_`x' = (death_`x'2013-deaths_2013pop_2013age_`x')/death_`x'1990

			keep iso3 country_name change_pop_growth_`x'  change_aging_`x' change_epi_`x' test_epi_`x' change_deaths_`x'

			reshape long change_pop_growth_ change_aging_ change_epi_ test_epi_ change_deaths_, i(country_name iso3) j(iter)

			
			if `start' ==1 { 
				tempfile results
				}
			else { 
				append using `results'
				}

			save `results', replace 
			local start =0
			}



/*
		** does it make sense to take uncertainty by look at epi changes? 
		** perhaps because most uncertainty around epi changes... 
		** and we want them to stay consistent with each other. 

	** changes in epi	
		bysort iso3: egen med_epi = median(change_epi_)
		bysort iso3: egen lower_epi = pctile(change_epi_), p(2.75)
		bysort iso3: egen upper_epi = pctile(change_epi_), p(97.5)

	** changes in aging
		bysort iso3: egen med_aging = median(change_aging_)
		bysort iso3: egen lower_aging = pctile(change_aging_), p(2.75)
		bysort iso3: egen upper_aging = pctile(change_aging_), p(97.5)

	** changes in aging
		bysort iso3: egen med_popgrowth = median(change_pop_growth_)
		bysort iso3: egen lower_popgrowth = pctile(change_pop_growth_), p(2.75)
		bysort iso3: egen upper_popgrowth = pctile(change_pop_growth_), p(97.5)

	** changes in deaths 
		bysort iso3: egen med_deaths = median(change_deaths_)
		bysort iso3: egen lower_deaths = pctile(change_deaths_), p(2.75)
		bysort iso3: egen upper_deaths = pctile(change_deaths_), p(97.5)

	** Graphing bar charts with uncertainty
		duplicates drop iso3 country_name, force
		sort country_name

		
		replace country_name ="SVG" if country_name=="Saint Vincent and the Grenadines"
		replace country_name ="USVI" if country_name=="United States Virgin Islands"
	
	** order by size of epi change
	
	
		
	
	** graphing
		graph hbar med_epi med_popgrowth med_aging, stack over(country_name) yline(1)
		
		gen zero=0
		
		gen addage = med_aging if med_epi<0  & med_aging>0
		*replace addage = 
		gen basepop =0 
		replace basepop =med_aging if med_aging<0
		replace basepop =med_epi +basepop if med_epi>0
		replace addage = med_aging+med_epi if med_epi>0 
		replace addage = med_epi if med_epi>0 & med_aging<0
		gen addpop = addage+med_popgrowth
		
		
		gsort - med_deaths
		gen y1=_n
		
		*label define orderlabel 14 "SVG" 13 "Guyana" 12 "Barbados" 11 "Grenada" 10 "Jamaica" 9 "Antigua" 8 "Cuba" 7 "Saint Luia" 6 "TNT" 5 "Belize" 4 "Haiti" 3 "Suriname" 2 "Bahamas" 1 "DR" , replace 
		label define orderlabel 14 "Guyana" 13 "Barbados" 12 "SVG" 11 "Grenada" 10 "Cuba" 9 "Antigua" 8 "Jamaica" 7 "Saint Lucia" 6 "TNT" 5 "Haiti" 4 "Suriname" 3 "Bahamas" 2 "Belize" 1 "DR" , replace 
		label values y1 orderlabel
		
		set scheme s1color  
		
		twoway rbar zero med_epi y1, barwidth(.5) horizontal  color("27 158 119") || rbar basepop addage y1 , barwidth(.5) horizontal color("217 95 2") || rbar addage addpop y1 , barwidth(.5) horizontal color("117 112 179") || rcap zero zero y1, horizontal lcolor(black) msize(vlarge)  || scatter y1 med_deaths, msymbol(diamond_hollow) mcolor(black) msize(medlarge)  ylabel(1(1)14,valuelabel angle(0) labsize(2)) legend( order( 1 2 3 5)label(3 Percent change driven by changes in population size) label(2 Percent change driven by changes in age structure) label(1 Percent change driven by changes in age-standardized mortality rates)  label(5 "Percent change in deaths from 1990-2013") cols(1) size(2) symysize(1) symxsize(2)) ytitle("") xtitle("Percent Change in Deaths, 1990-2013",margin(top)) legend(region(lcolor(none)))  xlabel(-.5 "-50%" 0 "0" .5 "50%" 1 "100%", labsize(2))
		graph export "Graphs/decomp_1990_2013.png", replace height(1600) width(1600)
		
	
	
		gen sort =_n
		gsort - sort 
		keep country_name med_epi lower_epi upper_epi med_aging lower_aging upper_aging med_popgrowth lower_popgrowth upper_popgrowth med_deaths lower_deaths upper_deaths
		
		outsheet using "Results/decomp.csv", comma replace 
		
		save "Results/decomp_data_1990_2013.dta", replace 
		
		
		** calcualte proportion due to aging
		gen prop_aging= (abs(med_aging))/ (abs(med_aging) + abs(med_epi) +abs(med_popgrowth))
		