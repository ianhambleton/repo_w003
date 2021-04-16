# repo_w003
## Project w003 (WHO Global Health Estimates). Algorithm repository.

---
## Project background
WHO’s Global Health Estimates (GHE) present comprehensive and comparable time-series data from 2000 onwards for health-related indicators, including life expectancy, healthy life expectancy, mortality and morbidity, as well as burden of diseases at global, regional and country levels, disaggregated by age, sex and cause1.<br>

The estimates are produced using data from multiple consolidated sources, including national vital registration data, latest estimates from its technical programmes, United Nations partners and inter-agency groups, and other scientific studies. A broad spectrum of robust and well-established scientific methods is applied for the processing, synthesis, and analysis of data¹.
WHO’s Global Health Estimates (GHE) provide the latest available data on death and disability globally and geographically disaggregated by WHO regions and countries. The latest updates include global, regional, and country trends estimates from 2000 to 2019.<br>

## Broad goal of analyses
The purpose of this project is to produce an analysis using the GHE (2000-2019) trend-series presenting results on health-related indicators disaggregated by age, sex, and cause. The analysis will consider the different subregions and focus on changes over time. The idea is to produce one technical report, and two peer-reviewed articles from this work. 

## Algorithms
The algorithms in this repository are all written to run in the Stata statistical statistical software (cuurent version used is v16).


#### 1. Load the GHE disease burden file
- DO FILE: p001-load-ghe-burden.do
> Input dataset: dths_yld_daly.dta
> - Received as a large Stata dataset, from Bochen Cao (WHO). 

> **Prepare file for attaching regions to country data**
> 1. First load a country-region dataset (algorithm: -kountry-). 
> 2. This allows us to automatically attach UN regions to the dataset
> 3. Manually add UN subregions, WHO regions, and informal PAHO subregions

> **Add metadata to disease burden dataset**
> 1. Next load the burden dataset (dths_yld_daly.dta)
> 2. Add variable metadata
> 3. Save full dataset as (who-ghe-burden-001.dta)

> **Save data subsets to reduce filesize:**
> YLL: who-ghe-yll-001.dta
> YLD: who-ghe-yld-001.dta
> DALY: who-ghe-daly-001.dta
> DEATHS: who-ghe-deaths-001.dta



#### 2. Further GHE disease burden file restrictions
Further dataset reductions to reduce filesize. 
- DO FILE: p002-ghe-burden-byregion.do
> Input datasets: 
> - who-ghe-yll-001
> - who-ghe-yld-001 
> - who-ghe-daly-001 
> - who-ghe-deaths-001

> **Restrict to limited set of GHE causes**
> List as follows:
>     0       (All causes)
      10      (Communicable, maternal, perinatal, nutritional)
      20      (Infectious)
      420     (Maternal)
      490     (Neonatal)
      540     (Nutritional deficiencies)
      600     (Noncommunicable diseases)
      610     (Malignant neoplasms)
      800     (Diabetes)
      820     (Mental and substance use disorders)
      830     (Depressive disorders)
      940     (Neurological conditions)
      950     (Alzeimer's disease and other dementias)
      1100    (Cardiovascular diseases)
      1130    (Ischaemic Heart disease)
      1140    (Stroke)
      1170    (Respiratory Diseases)
      1510    (Injuries)
      1520    (Unintentional injuries)
      1530    (Road injury)
      1540    (poisonings)
      1550    (falls)
      1560    (fire)
      1570    (drowning)
      1575    (machanical)
      1580    (disasters)
      1590    (Other)
      1600    (intentional injuries)
      1610    (suicide)
      1620    (homicide)
      1630   (conflict)

> **Restrict to regional datasets- one for each UN and WHO region**
> 'var' = yll / yld / daly / deaths 
> - who-ghe-`var'-001-africa
> - who-ghe-`var'-001-americas
> - who-ghe-`var'-001-asia
> - who-ghe-`var'-001-europe
> - who-ghe-`var'-001-oceania
> - who-ghe-`var'-001-who1 (Africa)
> - who-ghe-`var'-001-who2 (Americas)
> - who-ghe-`var'-001-who3 (Eastern Mediterranean)
> - who-ghe-`var'-001-who4 (Europe)
> - who-ghe-`var'-001-who5 (South-East Asia)
> - who-ghe-`var'-001-who5 (Western Pacific)



#### 3. Americas dataset without restricting cause of death
- DO FILE: p002-ghe-burden-leading.do 
> input dataset: 
> - who-ghe-yll-001 
> - who-ghe-yld-001 
> - who-ghe-daly-001 
> - who-ghe-deaths-001

> Save data subset(s):
> - who-ghe-`var'-002-who2


#### 4. Equiplot example for report draft 
- DO FILE: p003-equiplot-example.do 
Uses Americas dataset (who-ghe-deaths-001-who2)


#### 5. Heatmap example for report draft 
- DO FILE: p003-heatmap-example.do 
Used heatmap from a previous analysis (p122)


#### 6. Linechart example for report draft 
- DO FILE: p003-linechart-example.do 
Uses Americas dataset (who-ghe-deaths-002-who2)


#### 7. Slopechart example for report draft 
- DO FILE: p003-slopechart-example.do 
Uses Americas dataset (who-ghe-deaths-002-who2)


#### 8. Sparklines example for report draft 
- DO FILE: p003-sparklines-example.do 
Uses Caribbean dataset of elderly metrics (Figures.xlsx)


#### 9. Stacked area chart example for report draft 
- DO FILE: p003-stacked-example.do 
Uses Americas dataset (who-ghe-deaths-001-who2)


#### 10. Load and prepare global lifetable dataset
- DO FILE: p004-life-global.do
> input dataset: 
> - lifetable-2019-global.csv  
> Downloaded from WHO GHO website (https://apps.who.int/gho/data/node.main.687?lang=en)
> Downloaded on: 15-Apr-2021


#### 11. Load and prepare WHO regions lifetable datasets
- DO FILE: p004-life-whoregions.do
> input dataset: 
> - lifetable-2019-<region>.csv (africa, americas, eastern-mediterranean, europe, south-east-asia, western pacific) 
> Downloaded from WHO GHO website (https://apps.who.int/gho/data/node.main.687?lang=en)
> Downloaded on: 15-Apr-2021


#### 12. Load and prepare WB income groups lifetable datasets
- DO FILE: p004-life-wbregions.do
> input dataset: 
> - lifetable-2019-<region>.csv (low-income, low-middle-income, upper-middle-income, high-income) 
> Downloaded from WHO GHO website (https://apps.who.int/gho/data/node.main.687?lang=en)
> Downloaded on: 15-Apr-2021


#### 13. Load and prepare country-level lifetable datasets for the Americas only
- DO FILE: p004-life-country.do
> input dataset: 
> - lifetable-2019-<country>.csv, where countries are:
> - antigua
> - argentina 
> - bahamas 
> - barbados
> - belize
> - bolivia
> - brazil
> - canada
> - chile
> - colombia
> - costarica
> - cuba
> - dominican republic
> - ecuador
> - el salvador
> - grenada
> - guatemala
> - guyana
> - haiti
> - honduras
> - jamaica
> - mexico
> - nicaragua
> - panama
> - paraguay
> - peru
> - st lucia
> - st vincent
> - suriname
> - trinidad
> - uruguay
> - usa 
 
> Downloaded from WHO GHO website (https://apps.who.int/gho/data/node.main.687?lang=en)
> Downloaded on: 15-Apr-2021


