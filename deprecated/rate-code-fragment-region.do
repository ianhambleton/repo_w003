


** BY SEX

** ------- 7-Apr-2022 new rate code ---------------------- 
** Add the Reference population
    merge m:m age18 using `who_std'
    rename pop lpop
    rename dths case
    drop _merge

** Crude rate
    bysort sex year ghecause who_region: egen num = sum(case)
    bysort sex year ghecause who_region: egen denom = sum(lpop)
    gen crude = num / denom

** (Ref Pop)/(Local Pop) * (Local Observed Events)
    gen srate1 = rpop / lpop * case 
    bysort sex year ghecause who_region: egen tsrate1 = sum(srate1)
    bysort sex year ghecause who_region: egen trpop = sum(rpop)
    bysort sex year ghecause who_region: egen tlpop = sum(lpop)
    sort age18
    ** Per 10,000
    gen rate = tsrate1 / trpop

** Method
** DSR: 1 / sum(refpop) * sum(refpop*case/localpop) 
    bysort sex year ghecause who_region: egen t1a = sum(rpop)
    gen  t1b = 1/t1a
    gen t2a = rpop * case / lpop
    bysort sex year ghecause who_region: egen t2b = sum(t2a)
    gen dsr = t1b * t2b

** DSR 95%CI
    **  DSR
    gen ci1 = dsr 
    **  Case(lower)
    bysort sex year ghecause who_region: egen ol1 = sum(case)
    gen ol2 = 1 / (9*ol1)
    gen ol3 = 1.96 / (3 * sqrt(ol1))
    gen ol4 = ol1 * (1- ol2 - ol3)^3
    **  Case(upper)
    bysort sex year ghecause who_region: egen ou1 = sum(case)
    gen ou2 = 1 / (9*(ou1 + 1))
    gen ou3 = 1.96 / (3 * sqrt(ou1 + 1))
    gen ou4 = (ou1+1) * (1 - ou2 + ou3)^3
    **  Var(DSR)
    gen var1 = rpop^2 * case / lpop^2
    bysort sex year ghecause who_region: egen var2 = sum(var1)
    bysort sex year ghecause who_region: egen var3 = sum(rpop)
    gen var4 = var2 / (var3 ^2)
    **  DSR(lower)
    gen cl1 = dsr
    gen cl = cl1 + sqrt(var4/ol1) * (ol4 - ol1)
    **  DSR(upper)
    gen cu = cl1 + sqrt(var4/ol1) * (ou4 - ol1)
    ** Clear intermediate variables
    drop t1a t1b t2a t2b ci1 ol1 ol2 ol3 ol4 ou1 ou2 ou3 ou4 var1 var2 var3 var4 cl1 
    rename case cases 

    ** Collapse out the local population
    collapse (sum) cases lpop (mean) crate=crude arate=dsr aupp=cu alow=cl, by(sex year ghecause who_region)  

    ** Reformat variables
    ** rename case daly 
    rename lpop pop 
    gen ase = .  

    ** Variable re-naming and dropping unwanted variables
    rename who_region region
    format cases %12.1fc 
    keep cases crate arate aupp alow ase pop sex year ghecause region 
** ------- new code ends ---------------------- 











** SEXES COMBINED

** ------- 7-Apr-2022 new rate code  ---------------------- 
** Add the Reference population
    merge m:m age18 using `who_std'
    rename pop lpop
    rename dths case
    drop _merge

** Crude rate
    bysort year ghecause who_region: egen num = sum(case)
    bysort year ghecause who_region: egen denom = sum(lpop)
    gen crude = num / denom

** (Ref Pop)/(Local Pop) * (Local Observed Events)
    gen srate1 = rpop / lpop * case 
    bysort year ghecause who_region: egen tsrate1 = sum(srate1)
    bysort year ghecause who_region: egen trpop = sum(rpop)
    bysort year ghecause who_region: egen tlpop = sum(lpop)
    sort age18
    ** Per 10,000
    gen rate = tsrate1 / trpop

** Method
** DSR: 1 / sum(refpop) * sum(refpop*case/localpop) 
    bysort year ghecause who_region: egen t1a = sum(rpop)
    gen  t1b = 1/t1a
    gen t2a = rpop * case / lpop
    bysort year ghecause who_region: egen t2b = sum(t2a)
    gen dsr = t1b * t2b

** DSR 95%CI
    **  DSR
    gen ci1 = dsr 
    **  Case(lower)
    bysort year ghecause who_region: egen ol1 = sum(case)
    gen ol2 = 1 / (9*ol1)
    gen ol3 = 1.96 / (3 * sqrt(ol1))
    gen ol4 = ol1 * (1- ol2 - ol3)^3
    **  Case(upper)
    bysort year ghecause who_region: egen ou1 = sum(case)
    gen ou2 = 1 / (9*(ou1 + 1))
    gen ou3 = 1.96 / (3 * sqrt(ou1 + 1))
    gen ou4 = (ou1+1) * (1 - ou2 + ou3)^3
    **  Var(DSR)
    gen var1 = rpop^2 * case / lpop^2
    bysort year ghecause who_region: egen var2 = sum(var1)
    bysort year ghecause who_region: egen var3 = sum(rpop)
    gen var4 = var2 / (var3 ^2)
    **  DSR(lower)
    gen cl1 = dsr
    gen cl = cl1 + sqrt(var4/ol1) * (ol4 - ol1)
    **  DSR(upper)
    gen cu = cl1 + sqrt(var4/ol1) * (ou4 - ol1)
    ** Clear intermediate variables
    drop t1a t1b t2a t2b ci1 ol1 ol2 ol3 ol4 ou1 ou2 ou3 ou4 var1 var2 var3 var4 cl1 
    rename case cases

    ** Collapse out the local population
    collapse (sum) cases lpop (mean) crate=crude arate=dsr aupp=cu alow=cl, by(year ghecause who_region)  

    ** Reformat variables
    ** rename case daly 
    rename lpop pop 
    gen ase = .  

    ** Variable re-naming and dropping unwanted variables
    format cases %12.1fc
    rename who_region region
    keep cases crate arate aupp alow ase pop year ghecause region 
** ------- new code ends ---------------------- 