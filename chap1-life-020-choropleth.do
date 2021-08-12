** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-life-020-choropleth.do
    //  project:				    WHO Global Health Estimates
    //  analysts:				    Ian HAMBLETON
    // 	date last modified	    	16-Apr-2021
    //  algorithm task			    Chapter 1 - Life Expectancy

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
    log using "`logpath'\chap1-life-020-choropleth", replace
** HEADER -----------------------------------------------------

** ***************************************************************
** PLAN
**
** 1.   Using WHO regions and countries of the Americas.
**      Consider the following:
**      (a) Maps of the Americas with LE-0 in 2000, LE-0 in 2019, Change in LE-0
**      (b) Difference between LE in women and men 
**          - regional - chart with men centred at 0
**          - country - men on x, women on y. Diagonal=equality
** ***************************************************************

** MAP

** Load the shapefile
cd "`datapath'/shapefiles/UIA_World_Countries_Boundaries"
spshape2dta "`datapath'\shapefiles\UIA_World_Countries_Boundaries\World_Countries__Generalized_.shp", replace saving(americas)

use americas_shp, clear

** merge with attributes file to get the names
merge m:1 _ID using americas 
drop _merge 

egen tag = tag(COUNTRY)
sort _ID 
list COUNTRY _ID ISO if tag==1

** Keep South and Central America and the Caribbean
#delimit ; 
keep if ISO=="CA" | 
        ISO=="US" |
        ISO=="SV" |
        ISO=="GT" |
        ISO=="MX" |
        ISO=="AR" |
        ISO=="CL" |
        ISO=="EC" |
        ISO=="PE" |
        ISO=="BO" |
        ISO=="BR" |
        ISO=="PY" |
        ISO=="UY" |
        ISO=="AI" |
        ISO=="AG" |
        ISO=="AW" |
        ISO=="BS" |
        ISO=="BB" |
        ISO=="BZ" |
        ISO=="BM" |
        ISO=="BQ" |
        ISO=="VG" |
        ISO=="KY" |
        ISO=="CO" |
        ISO=="CR" |
        ISO=="CU" |
        ISO=="CW" |
        ISO=="DM" |
        ISO=="DO" |
        ISO=="GF" |
        ISO=="GD" |
        ISO=="GP" |
        ISO=="GY" |
        ISO=="HT" |
        ISO=="HN" |
        ISO=="JM" |
        ISO=="MQ" |
        ISO=="MS" |
        ISO=="NI" |
        ISO=="PA" |
        ISO=="PR" |
        ISO=="BQ" |
        ISO=="BL" |
        ISO=="BQ" |
        ISO=="KN" |
        ISO=="LC" |
        ISO=="MF" |
        ISO=="PM" |
        ISO=="VC" |
        ISO=="SX" |
        ISO=="SR" |
        ISO=="TT" |
        ISO=="TC" |
        ISO=="VI" |
        ISO=="VE";
#delimit cr 
rename COUNTRY country 
drop if ISO=="US" & _X>150 & _X<200
keep _ID _X _Y rec_header shape_order 
save americas_shp.dta, replace


** Save the labels data for the Americas only 
use americas, clear 
** Keep South and Central America and the Caribbean
#delimit ; 
keep if ISO=="CA" | 
        ISO=="US" |
        ISO=="SV" |
        ISO=="GT" |
        ISO=="MX" |
        ISO=="AR" |
        ISO=="CL" |
        ISO=="EC" |
        ISO=="PE" |
        ISO=="BO" |
        ISO=="BR" |
        ISO=="PY" |
        ISO=="UY" |
        ISO=="AI" |
        ISO=="AG" |
        ISO=="AW" |
        ISO=="BS" |
        ISO=="BB" |
        ISO=="BZ" |
        ISO=="BM" |
        ISO=="BQ" |
        ISO=="VG" |
        ISO=="KY" |
        ISO=="CO" |
        ISO=="CR" |
        ISO=="CU" |
        ISO=="CW" |
        ISO=="DM" |
        ISO=="DO" |
        ISO=="GF" |
        ISO=="GD" |
        ISO=="GP" |
        ISO=="GY" |
        ISO=="HT" |
        ISO=="HN" |
        ISO=="JM" |
        ISO=="MQ" |
        ISO=="MS" |
        ISO=="NI" |
        ISO=="PA" |
        ISO=="PR" |
        ISO=="BQ" |
        ISO=="BL" |
        ISO=="BQ" |
        ISO=="KN" |
        ISO=="LC" |
        ISO=="MF" |
        ISO=="PM" |
        ISO=="VC" |
        ISO=="SX" |
        ISO=="SR" |
        ISO=="TT" |
        ISO=="TC" |
        ISO=="VI" |
        ISO=="VE";
#delimit cr 
save americas, replace
rename COUNTRY country 
keep _CX _CY country 
save americas_label.dta, replace

** Merge the (americas) dataset with country characteristics file  
use americas, clear
rename ISO iso2c 
merge m:m iso2c using "`datapath'\from-who\lifetables\americas-ex0-full"
keep if who_region == 2 
drop if _ID==. 
drop _merge
sort _ID year sex 

** generate a local for the ColorBrewer color scheme
colorpalette Spectral, n(11)  nograph
local colors `r(p)'

/*

** ***************************************************
** 2019 EASTERN CARIBBEAN COUNTRY MAPS
** ***************************************************
** This will be combined with the regional map
** LOOP through each country
** ***************************************************
local ukot ""Bermuda (UKOT)" "Anguilla (UKOT)" "BVI (UKOT)" "Cayman Islands (UKOT)" "Montserrat (UKOT)" "Turks and Caicos Islands (UKOT)" "
local ec "Antigua "St. Kitts and Nevis" Guadeloupe Dominica Martinique "St. Lucia" Barbados "St. Vincent" Grenada "Trinidad and Tobago" " 
local car "Bahamas Belize Guyana Haiti Jamaica Suriname" 
local country "`ukot' `ec' `car'"
local cname "bma aia vgb cym msr tca atg kna glp dma mtq lca brb vct grd tto bhs blz guy hti jam sur"
local cvalu "34 28 36 37 52 67 29 59 46 42 51 60 32 63 45 66 31 33 47 48 50 65"
local n: word count `cname' 




forval y = 2000(19)2019 {
** Complete selection indicators for graphic among countries with no GHE data
** This allows countries to exist on map with grey (no information) shading
gen year`y' = year 
gen sex`y' = sex 
replace year`y' = `y' if year`y'==. 
replace sex`y' = 3 if sex`y'==. 

forvalues i = 1/`n' {
    local a : word `i' of `cvalu'
    local b : word `i' of `cname'
    local c : word `i' of `country'

    #delimit ; 
    spmap metric using americas_shp if _ID==`a' & year`y'==`y' & sex`y'==3
        ,
        fysize(10) 
        id(_ID)
        clmethod(custom) 
        clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
        ocolor(gs10 ..) fcolor("`colors'") osize(0.04 ..)  
        ndocolor(gs10 ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
        legend(off pos(7) size(*0.8)) legstyle(2) 
        /// title("Life expectancy at birth (2000)", size(4))
        note("`c'" , size(4))
        name(map_`b'`y')
        saving("`outputpath'/graphics/ex0-`b'-`y'", replace)
        ;
    #delimit cr
    graph export "`outputpath'/graphics/ex0-`b'-`y'.png", replace width(500)
}
}

** ***************************************************
** CREATING A SINGLE GRAPHIC FOR THE EASTERN CARIBBEAN
** ***************************************************
forval y = 2000(19)2019 {

#delimit ; 
gr combine 
    "`outputpath'/graphics/ex0-atg-`y'" 
    "`outputpath'/graphics/ex0-bhs-`y'" 
    "`outputpath'/graphics/ex0-blz-`y'" 
    "`outputpath'/graphics/ex0-hti-`y'" 
    "`outputpath'/graphics/ex0-jam-`y'" 

    "`outputpath'/graphics/ex0-lca-`y'" 
    "`outputpath'/graphics/ex0-brb-`y'" 
    "`outputpath'/graphics/ex0-vct-`y'" 
    "`outputpath'/graphics/ex0-grd-`y'" 
    "`outputpath'/graphics/ex0-tto-`y'" 
    ,
    rows(5) cols(2) colfirst
    saving("`outputpath'/graphics/ex0-ec-`y'", replace)
    name(map_ec`y')
    ;
#delimit cr
}

*/

** DROP geographically outlying territories to improve visual
    * Drop Bermuda 
    drop if _ID==34 
    * Drop Saint Pierre and Miquelon
    drop if _ID==62 




** ***************************************************
** LATIN AMERICA AND THE CARIBBEAN (2019)
** ***************************************************

** forval y = 2000(19)2019 {

#delimit ; 
spmap metric using americas_shp if year==2019 & sex==3
    ,
    fysize(100) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(gs10 ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(gs10 ..) ndfcolor(gs10 ..) ndsize(0.02 ..) ndlabel("Missing") 
    legend(pos(7) size(*0.8)) legstyle(2) 
    note("Data source: WHO GHE (2019). The following Caribbean territories have no data, and are not represented. " 
    "Six United Kingdom Overseas Territories or UKOTS: Anguilla, Bermuda, British Virgin Islands, Cayman Islands, "
    "Montserrat, Turks and Caicos Islands), Guadeloupe, Martinique, Sint Eustatius and Saba, St. Martin and St. Barthelemy." , size(1.75))
    name(maplac2019)
    saving("`outputpath'/graphics/ex0-lac-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-lac-2019.png", replace width(1500)
** }



** ***************************************************
** CREATING A SINGLE GRAPHIC FOR THE AMERICAS
** ***************************************************
** forval y = 2000(19)2019 {

#delimit ; 
gr combine 
    "`outputpath'/graphics/ex0-lac-2019" 
    "`outputpath'/graphics/ex0-ec-2019" 
    ,
    rows(1) cols(2)
    /// Outline
    graphregion(lpattern("l") lcolor(gs16) lwidth(0.1) lalign(outside)) 
    title("Life Expectancy in the Americas, 2019", color(gs10) size(3.75) justification(left))
    saving("`outputpath'/graphics/ex0-americas-2019", replace)
    name(map_lac2019)
    ;
#delimit cr
**}
