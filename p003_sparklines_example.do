** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			        p003-sparklines.do
    //  project:				        WHO Global Health Estimates
    //  analysts:				        Ian HAMBLETON
    // 	date last modified	            5-April-2021
    //  algorithm task			        Slopechart example

    ** General algorithm set-up
    version 16
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
    log using "`logpath'\p003-sparklines", replace
** HEADER -----------------------------------------------------

** ---------------------------------------------------------------------------------------------
** Read the EXCEL spreadsheet
** X:\OneDrive - The University of the West Indies\Writing\w003\data
** ---------------------------------------------------------------------------------------------
import excel using "`datapath'\Figures.xlsx", sheet("data4stata") first clear

** Reshape to long
rename Country country
drop change_70_15 change_15_40
reshape long y, i(country) j(year)

** Country indicator
egen cid = group(country)
order cid, after(country)
labmask cid, values(country)




** Simple connected line plot (Line + Scatter)
** Taking size from HIV work for NHAC

local country = "Martinique"
local country = "United States Virgin Islands"
local country = "Guadeloupe"
local country = "USA"
local country = "Puerto Rico"
local country = "Cuba"
local country = "Curaçao"
local country = "Barbados"
local country = "Aruba"
local country = "Jamaica"
local country = "Saint Lucia"
local country = "Trinidad and Tobago"
local country = "Bahamas"
local country = "Antigua and Barbuda"
local country = "Grenada"
local country = "Saint Vincent and the Grenadines"
local country = "Suriname"
local country = "Dominican Republic"
local country = "Haiti"
local country = "Guyana"
local country = "Belize"
*/

#delimit ;
	gr twoway 
		(line y year if year<=2015 & country=="`country'", lc(gs0) fc(gs0) lw(vthick) msize(10))
		(sc y year if year<=2015 & country=="`country'", m(O) mfc(gs0) mlc(gs0) msize(10) )
		  ,
			plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin)) 
			graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin)) 
			ysize(1)
			
			xlab(, 
			labs(medsmall) nogrid glc(gs14) angle(0) labgap(3))
			xscale(off lw(vthin) ) xtitle("", margin(t=3) size(medsmall)) 

			yscale(off lw(vthin) ) 
			ylab(,nogrid)

			///text(1 123 "2013", place(w) size(15) just(right))
			
			legend(off)
			;
#delimit cr

