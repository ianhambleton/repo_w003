** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			    chap1-life-expectancy-001.do
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
    log using "`logpath'\chap1-life-expectancy-001", replace
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
keep if ISO=="SV" |
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
keep _ID _X _Y rec_header shape_order 
save americas_shp.dta, replace

** Save the labels data for the Americas only 
use americas, clear 
** Keep South and Central America and the Caribbean
#delimit ; 
keep if ISO=="SV" |
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

** LATIN AMERICA AND THE CARIBBEAN 
* Drop Saint Pierre and Miquelon
drop if _ID==62 

replace year=2019 if year==. 
replace sex=3 if sex==. 

** BERMUDA (UKOT - 2019)
#delimit ; 
spmap metric using americas_shp if _ID==34 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("Bermuda (UKOT)" , size(4))
    name(map_bma)
    saving("`outputpath'/graphics/ex0-bma-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-bma-2019.png", replace width(500)


* Drop Bermuda 
drop if _ID==34 


** LATIN AMERICA AND THE CARIBBEAN 
** 2019
#delimit ; 
spmap metric using americas_shp if year==2019 & sex==3
    ,
    fysize(100) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(pos(7) size(*0.8)) legstyle(2) 
    note("Data source: WHO GHE (2019). The following Caribbean territories have no data, and are not represented. " 
    "Six United Kingdom Overseas Territories or UKOTS: Anguilla, Bermuda, British Virgin Islands, Cayman Islands, "
    "Montserrat, Turks and Caicos Islands), Guadeloupe, Martinique, Sint Eustatius and Saba, St. Martin and St. Barthelemy." , size(1.75))
    name(maplac2019)
    saving("`outputpath'/graphics/ex0-lac-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-lac-2019.png", replace width(500)


** ANGUILLA (UKOT - 2019)
#delimit ; 
spmap metric using americas_shp if _ID==28 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("Anguilla (UKOT)" , size(4))
    name(map_aia)
    saving("`outputpath'/graphics/ex0-aia-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-aia-2019.png", replace width(500)

** BVI (UKOT - 2019)
#delimit ; 
spmap metric using americas_shp if _ID==36 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("British Virgin Islands (UKOT)" , size(4))
    name(map_vgb)
    saving("`outputpath'/graphics/ex0-vgb-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-vgb-2019.png", replace width(500)

** CAYMAN ISLANDS (UKOT - 2019)
#delimit ; 
spmap metric using americas_shp if _ID==37 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("Cayman Islands (UKOT)" , size(4))
    name(map_cym)
    saving("`outputpath'/graphics/ex0-cym-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-cym-2019.png", replace width(500)


** MONTSERRAT (2019)
#delimit ; 
spmap metric using americas_shp if _ID==52 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("Montserrat (UKOT)" , size(4))
    name(map_msr)
    saving("`outputpath'/graphics/ex0-msr-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-msr-2019.png", replace width(500)


** TURKS AND CAICOS ISLANDS (UKOT - 2019)
#delimit ; 
spmap metric using americas_shp if _ID==67 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("Turks and Caicos Islands (UKOT)" , size(4))
    name(map_tca)
    saving("`outputpath'/graphics/ex0-tca-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-tca-2019.png", replace width(500)



** ANTIGUA and BARBUDA (2019)
#delimit ; 
spmap metric using americas_shp if _ID==29 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("Antigua and Barbuda" , size(4))
    name(map_atg)
    saving("`outputpath'/graphics/ex0-atg-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-atg-2019.png", replace width(500)


** ST KITTS and NEVIS (2019)
#delimit ; 
spmap metric using americas_shp if _ID==59 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("St. Kitts and Nevis" , size(4))
    name(map_kna)
    saving("`outputpath'/graphics/ex0-kna-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-kna-2019.png", replace width(500)



** GUADELOUPE (2019)
#delimit ; 
spmap metric using americas_shp if _ID==46 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("Guadeloupe" , size(4))
    name(map_glp)
    saving("`outputpath'/graphics/ex0-glp-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-glp-2019.png", replace width(500)


** DOMINICA (2019)
#delimit ; 
spmap metric using americas_shp if _ID==42 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("Dominica" , size(4))
    name(map_dma)
    saving("`outputpath'/graphics/ex0-dma-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-dma-2019.png", replace width(500)


** MARTINIQUE (2019)
#delimit ; 
spmap metric using americas_shp if _ID==51 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("Martinique" , size(4))
    name(map_mtq)
    saving("`outputpath'/graphics/ex0-mtq-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-mtq-2019.png", replace width(500)

** ST.LUCIA (2019)
#delimit ; 
spmap metric using americas_shp if _ID==60 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("St. Lucia" , size(4))
    name(map_lca)
    saving("`outputpath'/graphics/ex0-lca-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-lca-2019.png", replace width(500)

** BARBADOS (2019)
#delimit ; 
spmap metric using americas_shp if _ID==32 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("Barbados" , size(4))
    name(map_brb)
    saving("`outputpath'/graphics/ex0-brb-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-brb-2019.png", replace width(500)

** ST.VINCENT (2019)
#delimit ; 
spmap metric using americas_shp if _ID==63 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("St. Vincent" , size(4))
    name(map_vct)
    saving("`outputpath'/graphics/ex0-vct-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-vct-2019.png", replace width(500)

** GRENADA (2019)
#delimit ; 
spmap metric using americas_shp if _ID==45 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("Grenada" , size(4))
    name(map_grd)
    saving("`outputpath'/graphics/ex0-grd-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-grd-2019.png", replace width(500)


** TRINIDAD AND TOBAGO (2019)
#delimit ; 
spmap metric using americas_shp if _ID==66 & year==2019 & sex==3
    ,
    fysize(10) 
    id(_ID)
    clmethod(custom) 
    clbreaks(30 40 50 60 65 67.5 70 73.5 75 77.5 80 85)
    ocolor(black ..) fcolor("`colors'") osize(0.04 ..)  
    ndocolor(black ..) ndfcolor(gs10 ..) ndsize(0.04 ..) ndlabel("Missing") 
    legend(off pos(7) size(*0.8)) legstyle(2) 
    /// title("Life expectancy at birth (2000)", size(4))
    note("Trinidad and Tobago" , size(4))
    name(map_tto)
    saving("`outputpath'/graphics/ex0-tto-2019", replace)
    ;
#delimit cr
graph export "`outputpath'/graphics/ex0-tto-2019.png", replace width(500)


** CREATING A SINGLE GRAPHIC FOR THE EASTERN CARIBBEAN
#delimit ; 
gr combine 
    "`outputpath'/graphics/ex0-kna-2019" 
    "`outputpath'/graphics/ex0-atg-2019" 
    "`outputpath'/graphics/ex0-glp-2019" 
    "`outputpath'/graphics/ex0-dma-2019" 
    "`outputpath'/graphics/ex0-mtq-2019" 

    "`outputpath'/graphics/ex0-lca-2019" 
    "`outputpath'/graphics/ex0-brb-2019" 
    "`outputpath'/graphics/ex0-vct-2019" 
    "`outputpath'/graphics/ex0-grd-2019" 
    "`outputpath'/graphics/ex0-tto-2019" 
    ,
    rows(5) cols(2) colfirst
    saving("`outputpath'/graphics/ex0-ec-2019", replace)
    name(map_ec)
    ;
#delimit cr


** CREATING A SINGLE GRAPHIC FOR THE AMERICAS
#delimit ; 
gr combine 
    "`outputpath'/graphics/ex0-lac-2019" 
    "`outputpath'/graphics/ex0-ec-2019" 
    ,
    rows(1) cols(3)
    saving("`outputpath'/graphics/ex0-americas-2019", replace)
    name(map_lac)
    ;
#delimit cr
