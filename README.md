# repo_w003
## Project w003 (WHO Global Health Estimates). Algorithm repository.

---
## Project background
WHO’s Global Health Estimates (GHE) present comprehensive and comparable time-series data from 2000 onwards for health-related indicators, including life expectancy, healthy life expectancy, mortality and morbidity, as well as burden of diseases at global, regional and country levels, disaggregated by age, sex and cause1.<br>

The estimates are produced using data from multiple consolidated sources, including national vital registration data, latest estimates from its technical programmes, United Nations partners and inter-agency groups, and other scientific studies. A broad spectrum of robust and well-established scientific methods is applied for the processing, synthesis, and analysis of data¹.
WHO’s Global Health Estimates (GHE) provide the latest available data on death and disability globally and geographically disaggregated by WHO regions and countries. The latest updates include global, regional, and country trends estimates from 2000 to 2019.<br>

## Broad goal of analyses
The purpose of this project is to produce an in-depth analysis using the GHE (2000-2019) trend-series presenting results on health-related indicators disaggregated by age, sex, and cause. The analysis should consider the different subregions and focus on changes over time. The idea is to produce one technical report, and two peer-reviewed articles from this work. Potential outlines are presented below.

---
### 1. Technical Document - potential outline
We plan to have 4 chapters, at a total length of between 30 and 40 pages. Chapters broadly might have the following structure.

#### General questions
<code>Q1. Always use full available time-range for change?</code><br>
<code>Q2. To what extent should we expand analytics to additional data resources (which may of course have a range of different biases?)</code><br>
<code>Q3. WHO has no sub-region classification. Am using UN M49 categorization instead? Corollary of this is that several "Caribbean" nations then belong to other subregions (Belize in Central America, Guyana, Suriname, and French Guiana in South America). Tweak UN classification?</code><br>
<code>Q4. If using WHO life table estimates (a) Only results for select yrs via GHO and (b) no sub-regional aggregation of LE estimates. Have limited burden and death files to match those limited years (2000, 05, 10, 15, 19)</code><br> 
<code>Q5. The Americas. Do we want North America subsumed into this broad categorisation - the aggrgated region-level summaries do include North America?</code><br> 

#### Chapter 1: Regional Overview
_Initial Brief_: The leading causes of deaths and disabilities and the changes over time (should include analysis on inequities and demographic/epidemiological transition). This chapter should also present results for the three main broad group of causes of deaths and disabilities: communicable (infectious diseases, along with maternal, perinatal, and nutritional conditions), noncommunicable diseases (including mental health) and external causes.

_Outline_:<br> 
**Section 1A.** LIFE EXPECTANCY GAINS (2000 to 2019)
Uses WHO GHE Life Table metrics (data for 2000, 05, 10, 15, 19). This provides the basic measure of health improvement over time for the region.
    - Present for all Americas - unstratified
    - Stratified by subregion only
    - Stratified by income classification only
    - Stratified by sex only

> **Graphic** 
> TYPE:   Vertical scatterplot.
> UNIT:   Each point is LE point estimate for one country
> X-AXIS: Country/sex stratifications 
> Y-AXIS: Life Expectancy at birth in years 
> USE:    Highlights LE range across countries within each stratification group
> PANELS: 
>    - Panel 1A. All Americas - unstratified (2000)
>    - Panel 1B. All Americas - unstratified (2019)
>    - Panel 2A. By subregion (2000)
>    - Panel 2B. By subregion (2019)
>    - Panel 3A. By WB income groups (2000)
>    - Panel 3B. By WB income groups (2019)
>    - Panel 4A. By sex (2000)
>    - Panel 4B. By sex (2019)
> 
> **Metrics Available**
> LE at birth by country
> LE at birth by region (aggregated) 
> **Metrics Not Available**
> LE at birth by sub-region (but average values not needed for this)

<code>**PROBABLE MESSAGE.** The region is living longer, but there remains important inequalities.</code><br><br>

**SECTION 1B.** AGING IN THE AMERICAS
Improvements in life expectancy mean that across the region people are living longer lives. Our populations are aging rapidly
Section based on basic demographics.
- population pyramids
- fraction of the elderly / dependency ratios

**SECTION 1C.** BROAD CAUSES OF DEATH (2000 to 2019)
Present the change in *standardized mortality rates (SMR)* between 2000 and 2019, for broad categories:
    - all cause 
    - infectious disease, maternal, perinatal, nutritional
    - noncommuunicable diseases
    - external causes

> **Graphic** 
> TYPE:   Line chart
> UNIT:   Each line is smoothed mortality rate for SMR group listed above
> X-AXIS: Time (in years, from 2000 to 2019) 
> Y-AXIS: Standardized Mortality rate (per 100,000)
> USE:    Highlights change in MR over time. Each line is a particular MR group (all cause, infect dis, etc). 
> PANELS: 
>   - Panel 1. All-cause (by subregion, include all Americas)
>   - Panel 2. All-cause (by WB country groups, include all Americas)
>   - Panel 3. All cause (by sex, include all Americas)
>
> **Metrics Available**
> Deaths.  
> **Metrics Not Available**
> Will calculate SMR overall, for subregions, and for each country

<code>**POSSIBLE MESSAGE.** Improvements in SMR pverall. Improvements in communicable disease, maternal deaths, perinatal deaths. Less improvement in SMR due to NCDs. Regional inequalities large (to be explored).</code><br><br>



**SECTION 1D.** TOP CAUSES OF DEATH and DISABILITY
SMR and DALY

SECTION 1D. XXX
xxx


#### Chapter 2: NCDs and deaths from external causes
_Initial Brief_: NCDs (including mental health) and external causes: two preventable killers
(including the dangerous combination of COVID-19 and NCDs and the impact of COVID-19 on the increase of violence).

_Outline_: 
Split chapter into NCDs then External causes

**NCDs**
- Link to SDG 3.4
- Mortality rate due to 4 major NCD groups (cancer, cvd, diabetes, respiratory)
- Premature mortality (prob of dying between 35 and 70 yrs)

**External Causes**
Link to SDG (16.1.1 - intentional homicide)
- Mortality rate per 100,000 by sex and age 
Link to SDG (16.1.2 - conflict related deaths)
- Mortality rate per 100,000 by sex and age 



#### Chapter 3: Saving lives and Improving quality of health
_Initial Brief_: Saving lives and improving quality of health: implementing policies and programs and strengthening the health care system response (including an assessment on losses and gains over time)

_Outline_: 

**NCDs / Avoidable mortality** 
- Avoidable mortality
- Focus on NCD Progress Monitor

**External causes**



---
### 2. Peer-reviewed article A: GHEs with focus on NCDs (incl. mental health)
_Initial Brief_: Scientific manuscript to be published in a high impact journal – using the GHE (2000-2019) trend-series to conduct a more in-depth analysis for the Americas on NCDs including mental health. The consultant will submit a proposed outline and an analysis plan for review and comments.

_Outline_: 


---
### 3. Peer-reviewed article B: GHEs with focus on NCDs (incl. mental health)
_Initial Brief_: Scientific manuscript to be published in a high impact journal - using the GHE (2000-2019) trend-series to conduct a more in-depth analysis for the Americas on external causes. The consultant will submit a proposed outline and an analysis plan for review and comments.

_Outline_: 
