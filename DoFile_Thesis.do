/******************** Robustness Checks *******************
I'm gonna now check whether the results hold for the case when I code
part-time work in the NL as workers working below 36h

*************************************************************/
use "C:\Users\be_al\Google Drive\UvA_RMSS\2nd year\Internship\Data\posted\final_dataset_fully_merged", clear


**-- Check distribution of "Involuntariness" --**

fre cw526 // You work(ed) for less than 36 hours. Can you indicate for what reason(s)? - a fulltime job in my company amounts to less than 36 hours

fre cw390 // You work(ed) for less than 36 hours. Can you indicate for what reason(s)? - I am (was) not able to work more hours at my current (last) employer

fre cw145 // How many hours per week in total would you like to work? - 

fre cw126 // How many hours per week are (were) you employed in your (last) job, according to your employment contract?

fre cw127 // How many hours per week do (did) you actually work on average in your (last) job?

* Tell Stata that It is panel data

table syear cw127
xtset pid syear

/************************************************************* 
I Reduce the sample to the appropriate working population and non-students. Specially because part-time work can be an appealing arrangement to both work-students
***************************************************************/

drop if syear == 2021 // because Politics and Values questions were not measured in 2021 yet

* Age
gen ageyrs = syear - gebjaar 
keep if ageyrs >= 15 & ageyrs <= 65
drop if ageyrs == .

* keep non-students
fre belbezig
rename belbezig primary_occup
drop if primary_occup == 7 | primary_occup == 9 | ///
primary_occup == 14 | primary_occup == .
fre primary_occup

* Gender
recode geslacht (1 = 0 "Male") (2 = 1 "Female"), gen(gender)
fre gender
label var gender "Gender"

* Civil Status
recode burgstat (1 = 1 "Married") (2/5 = 0 " Not Married") ///
, gen(civil_status)
lab var civil_status "Civil Status"
fre civil_status

* Income
gen net_income = nettoink_f
replace net_income = 10001 if nettoink_f > 10000 & nettoink_f != .
hist net_income, percent

* Ideology
recode cv101 (-9 = .) (999 = .) (0 = 0 "Extreme Left") (10 = 10 "Extreme Right"), gen(ideology)
fre ideology

* Education
recode oplcat (1/2 = 0 "Low educated") (3/4 = 1 "middle educated") ///
(5/6 = 2 "highly educated"), gen(cat_educ)
fre cat_educ 

* Origin
recode herkomstgroep (0 = 0 "Dutch background") (101 = 1 "1st_Generation/Western Background") (102 = 2 "1st Generation/non-Western background") (201 = 3 "2nd Generation/Western Background") (202 = 4 "2nd Generation/non-Western Background"), gen(origin)
lab var origin "Cultural Background"
tab herkomstgroep origin
table syear herkomstgroep

* Origin 2
recode herkomstgroep (0 = 0 "Dutch background") (101/202 = 1 "Non Dutch Background"), gen(origin_2)
lab var origin_2 "Cultural Background Dummy"
tab herkomstgroep origin_2

* Employment Category - 1
tab cw121, m
rename cw121 employcateg
label define x 1 "permanent emp." 2 "temporary emp" ///
3 "on-call employee" 4 "temp-staffer" 5 "self-employed/freelancer" ///
6 "indep. prof." 7 "director" 8 "shareholder director"
lab var employcateg "Occupational Status"
lab val employcateg x
fre employcateg

* Employment Category - 2
recode employcateg (1 = 1 "permanent employees") (2/5 = 2 "atypical workers") ( 6/8 = 3 "professionals"), gen (employcateg_2)
lab var employcateg_2 "Occupational Status_2"
fre employcateg_2

* Employment Category - 3
recode employcateg (1 = 1 "other workers")(5 = 1) (6/8 = 1) (2/4 = 0 "atypical workers"), gen(employcateg_3)
fre employcateg_3

* Propensity to vote PVV - from wave 9 to wave 13
rename cv248 prop_PVV
lab var prop_PVV "Propensity to vote for PVV"
egen std_prop_PVV = std(prop_PVV)

* Propensity to vote SP - from wave 9 to wave 13
rename cv249 prop_SP
lab var prop_SP "Propensity to vote for SP"
egen std_prop_SP = std(prop_SP)


/********************* General Descriptives**************************

The motivation to focus on involuntary part-time work in the NL comes from its figures according to Hausermann et al (2015) as opposed to the measure used by "Dutch-specific" studies. This first section briefly report how involuntary part-time work varied across time according to both classfications and in proportion to different working groups.
 ************************************************************************/


* Number of the entire active workforce
bys syear: egen work_force = count(cw127) if cw088 == 1 & cw127 != 0 

* Get the number of part-timers
bys syear: egen part_timers = count(cw127) if cw127 <= 36 & cw088 == 1 & cw127 != 0

* Get involuntary part-timers, i.e, part-times that are not satisfied with the hours they get.
gen hrs_mismatch = cw145 - cw127 if cw088 == 1 & cw127 <= 36 & cw127 != 0 

bys syear: egen inv_part_timers = count(hrs_mismatch) if hrs_mismatch > 0


* Now to calculate the rate of involutariness among part-timers:
gen rate_invpat_h = (inv_part_timers / part_timers) * 100

* Now to calculate the rate of involuntary part-timers among the the entire workforce:
gen rate_invpat_h_wf = (inv_part_timers / work_force) * 100 

** For Dutch studies

* Number of part-timers is the same. The difference is the criteria to consider one as a involuntary part-timer. It's not only the mismatch of hours, but the impossibility to find a full-time job, which our proxy is the question cw390
gen hrs_mismatch_ds = cw145 - cw127 if cw088 == 1 & cw127 <= 36 & cw127 != 0 & cw390 == 1 

bys syear: egen inv_part_timers_ds = count(hrs_mismatch_ds) if hrs_mismatch_ds > 0 

* Now to calculate the rate of involuntary part-timers for Dutch Scholars
gen rate_invpat_ds = (inv_part_timers_ds / part_timers) * 100

* Now to calculate the rate of involuntary part-timers among the the entire workforce:
gen rate_invpat_ds_wf = (inv_part_timers_ds / work_force) * 100

* Plot the rate of part-timers over the entire work force
 
*-> It is striking that it shows a slight descending order, but it is around the estimates of Eurostat and Dutch Studies (Plantenga, 2002).But different from the measure of Eurostat and probably others.

gen rate_part_wf = part_timers / work_force * 100

graph twoway scatter rate_part_wf syear, ///
ylab(0(10)60) xlab(2008(1)2020) ///
msymbol(d) title("Rate of part-timers over the entire workforce") ///
xtitle("") ///
 || lfit rate_part_wf syear, lcolor(red) ///
legend(order(1 "Hausermann et al") pos(6) ///
ring(3) row(1)) saving(plot1)


* Plot the the rate of involuntary part-timers among the entire workforce for both classifications // Very different from Hausermann et al
graph twoway scatter rate_invpat_h_wf syear, ///
ylab(0(10)60) xlab(2008(1)2020) ///
msymbol(d) title("Percentage of involuntary part-timers among the entire workforce") ///
xtitle("") ///
 ||scatter rate_invpat_ds_wf syear, msymbol(t)  ///
 || lfit rate_invpat_h_wf syear, lcolor(red) ///
 || lfit rate_invpat_ds_wf syear, lcolor(eltblue) ///
	legend(order(1 "Hausermann et al" 2 "Dutch Studies") pos(6) ///
ring(3) row(1)) saving(plot2)


* Plot the the rate of involuntary part-timers among the part-timer workforce for both classifications
graph twoway scatter rate_invpat_h syear, ///
ylab(0(10)60) xlab(2008(1)2020) ///
msymbol(d) title("Percentage of part-timers that are involuntary part-timers") ///
xtitle("") ///
 ||scatter rate_invpat_ds syear, msymbol(t)  ///
 || lfit rate_invpat_h syear, lcolor(red) ///
 || lfit rate_invpat_ds syear, lcolor(eltblue) ///
legend(order(1 "Hausermann et al" 2 "Dutch Studies") pos(6) ///
ring(3) row(1)) saving(plot5)


* Plot the rate of female part-timers over the entire female workforce across time
bys syear: egen fem_part_timers = count(cw127) if cw127 <= 36 & cw088 == 1 & cw127 != 0 & gender == 1
bys syear: egen fem_work_force = count(cw127) if cw088 == 1 & cw127 != 0 & gender == 1

* And what is the gender composition of part-timers:  
 gen part_timers_comp = fem_part_timers / part_timers * 100
* Plot this
 graph twoway scatter part_timers_comp syear, ///
ylab(0(10)100) xlab(2008(1)2020) ///
msymbol(d) title("Gender composition of part-time workers") ///
xtitle("") ///
 || lfit part_timers_comp syear, lcolor(red) ///
legend(order(1 "Hausermann et al") pos(6) ///
ring(3) row(1)) saving(plot3)
 
* Calulate the rate of female part-timers over the female labour force // below the common value of 70/75% in several studies but close to Plantenga. Certainly very different from Hausermann et al

gen rate_fem_part_timers = fem_part_timers / fem_work_force * 100

* Plot that relationship:
graph twoway scatter rate_fem_part_timers syear, ///
ylab(0(10)100) xlab(2008(1)2020) ///
msymbol(d) title("Rate of female part-timers over the entire female workforce") ///
xtitle("") ///
 || lfit rate_fem_part_timers syear, lcolor(red) ///
legend(order(1 "Hausermann et al") pos(6) ///
ring(3) row(1)) saving(plot3)

* Involuntary female part-timers:

gen fem_hrs_mismatch = cw145 - cw127 if cw088 == 1 & cw127 <= 36 & cw127 != 0 & gender == 1

by syear: egen inv_fem_part_timers = count(fem_hrs_mismatch) if fem_hrs_mismatch > 0

gen rate_fem_inv_part_timers = inv_fem_part_timers / fem_part_timers * 100


* Plot the rate of female involuntary part_timers among female part_timers
graph twoway scatter rate_fem_inv_part_timers syear, ///
ylab(0(10)100) xlab(2008(1)2020) ///
msymbol(d) title("Percentage of female part-timers that are involuntary part-timers") ///
xtitle("") ///
 || lfit rate_fem_inv_part_timers syear, lcolor(red) ///
legend(order(1 "Hausermann et al") pos(6) ///
ring(3) row(1)) saving(plot4)

/*************************Analysis Part ****************************
First, I code the independent variable of this project
Second, I code the dependent variables tested
Third, I check socioeconomic characteristics to see how much between and within variation exists between part-timers and full-timers
********************************************************************/


*** ---- THE independent variable of the thesis ---- ***
gen occ_categories = .

* Part-timers:
gen hrs_mismatch = cw145 - cw127 if cw088 == 1 & cw127 < 36 & cw127 != 0 // create the range from over-time to under-time part-timers
replace occ_categories = 0 if hrs_mismatch > 0 & hrs_mismatch !=. // involuntary part-timers
replace occ_categories = 1 if hrs_mismatch == 0 // voluntary part-timers
replace occ_categories = 2 if hrs_mismatch < 0 // overt-time involuntary part-timers


* For full-timers (Considering full-timers people working above or equal to 30h): 
gen full_hrs_mismatch = cw145 - cw127 if cw088 == 1 & cw127 >= 36 &  cw127 != 0
fre full_hrs_mismatch
recode full_hrs_mismatch (-200/-41 = -40) (40/100 = 40)

replace occ_categories = 3 if full_hrs_mismatch > 0 & full_hrs_mismatch != . // involuntary full-timers
replace occ_categories = 4 if full_hrs_mismatch == 0 // voluntary full-timers
replace occ_categories = 5 if full_hrs_mismatch < 0 // over-time(involuntary) full-timers 

* Finally, check if the coding is right and add labels:
lab var occ_categories "Part-timers and Full-timers"
lab define occ 0 "under-time part-timers" 1 "voluntary part-timers" 2 "over-time part-timers" 3 "under-time full-timers" 4 "voluntary full-timers" 5 "over-time full-timers"
lab val occ_categories occ
fre occ_categories

*** ---- The dependent variable of the thesis ---- ***

** Job Satisfaction - With my current work 
recode cw133 (999 = .), gen(sat_currwor)
egen std_sat_currwor = std(sat_currwor)
fre cw133
** Job Quality - "There is very little freedom for me to determine how to do my work" disagree entirely(1) - agree entirely(4) // It doesnt matter
fre cw429
egen std_job_auton = std(cw429)

** Job Quality - "I have opportunity to learn new skills" - disagree entirely(1) - agree entirely(4)
fre cw430
egen std_job_opp = std(cw430) 

** Job Quality - "I get appreciation I deserve for my work" - disagree entirely (1) - agree entirely(4)
fre cw432
egen std_job_app = std(cw432)

** Job Quality - "My prospects of career advancement/promotion in my job are poor" - disagree entirely(1) - agree entirely(4) - REVERSE
fre cw434 
recode cw434 (1 = 4 "disagree entirely") (2 = 3 "disagree") (3 = 2 "agree") (4 = 1 "agree entirely"), gen(job_prosp)
egen std_job_prosp = std(job_prosp)

** Job Quality "It is uncertain whether my job will continue to exist" - disagree entirely(1) - agree entirely(4) - REVERSE
fre cw435 
recode cw435 (1 = 4 "disagree entirely") (2 = 3 "disagree") (3 = 2 "agree") (4 = 1 "agree entirely"), gen(job_uncert)
egen std_job_uncert = std(job_uncert)

*** Create a composite index of Job Satisfaction
alpha std_job_uncert std_job_prosp std_job_app std_job_opp std_job_auton std_sat_currwor // alpha 0.67

egen jobsatis_index = rowmean(std_job_uncert std_job_prosp std_job_app std_job_opp std_job_auton std_sat_currwor)
fre jobsatis_index

** Redistribution
fre cv103
recode cv103 (-9 = .) (99 = .), gen(redist)
lab var redist "Preference for Redistribution"
fre redist
lab define l_redist 1  "income diff should increase" 5  "income diff should decrease"
lab values redist l_redist
egen std_redist = std(redist)

** Voting for the Socialist Party
fre cv079 
recode cv079 (-9 = .) (999 = .), gen(vote_SP)
lab var vote_SP "What do you think of the Socialist Party"
lab define votesp 0 "unsympathetic" 10 "sympathetic"
lab values vote_SP votesp
egen std_vote_SP = std(vote_SP)

** Voting for the PVV 
fre cv085 
recode cv085 (-9 = .) (999 = .), gen(vote_PVV)
lab var vote_PVV "What do you think of the PVV"
lab define votepvv 0 "unsympathetic" 10 "sympathetic"
lab values vote_PVV votepvv
fre vote_PVV
egen std_vote_PVV = std(vote_PVV)

** Cultural Intolerance (Mijs and Gidron, 2019)

fre cv104 // Immigrants can retain their own culture (1) /should adapt entirely (5)
recode cv104 (-9 = .) (99 = .), gen(i1)

fre cv116 // Good society consists of different cultures *reverse*6
recode cv116 (1 = 5) (2 = 4) (4 = 2) (5 = 1), gen(i2)

fre cv118 //It should be made easier to obtain asylum in the Netherlands *reverse*
recode cv118 (1 = 5) (2 = 4) (4 = 2) (5 = 1), gen(i3)

fre cv119 //Legally residing foreigners should be entitled to the same social security as Dutch citizens *revers*
recode cv119 (1 = 5) (2 = 4) (4 = 2) (5 = 1), gen(i4) 

fre cv120 // There are too many people of foreign origin or descent in the Netherlands

fre cv123 // It does not help a neighborhood if many people of foreign origin or descent move in

* Create the Index - rowmean takes into account missing values.
alpha i1 i2 i3 i4 cv120 cv123 // cronbach alpha 0.82
egen nattivist_attitudes = rowmean(i1 i2 i3 i4 cv120 cv123) 
fre nattivist_attitudes
egen std_nattivist_attitudes = std(nattivist_attitudes)

save "C:\Users\be_al\Google Drive\UvA_RMSS\2nd year\Internship\Data\posted\working_sample_v2_36", replace


*** ---- Are these groups alike or very much different? ---- ****
use "C:\Users\be_al\Google Drive\UvA_RMSS\2nd year\Internship\Data\posted\working_sample_v2_36", clear

/*** Difference in job satisfaction measures
tabstat cw430 cw429 cw435 cw434 sat_currwor, by(occ_categories) stat ( mean sd n) long format(%12.2f) nototal */

*** Difference in job satisfaction measures
graph hbar (mean) cw429 cw430 cw432 cw434 cw435 sat_currwor, over(occ_categories) 

***Difference in the standard deviation from the mean: 
graph hbar (mean) jobsatis_index, over(occ_categories) ylab(-0.1(0.05) 0.15) yline(0)

*** Differences in mean income
graph hbar (mean) net_income, over(occ_categories) ///
 title("Income differences: part-timers vs full-timers") ///
 ytitle("Individual average monthly net income")

*** Gender composition
graph hbar, over(gender) over(occ_categories) asyvars percentages ///
ytitle("percent") title("Gender composition: part-timers vs full-timers")

*** Occupational composition
graph hbar, over(employcateg_3) over(occ_categories) ///
 legend(pos(6) ring(3) row(1)) ytitle("Percent") ///
 percentages asyvars ///
title("Occupational profile: part-timers vs full-timers") ///
 yscale(r(0 0.8))
 
*** Sympathy for the PVV,for the Socialist party and Redistributive preferences
 graph hbar (mean) redist vote_SP, over(occ_categories) ///
 title("Political Attitudes: part-timers vs full-timers") ///
 ytitle("Average scores") legend(order(1 "Support for Redistribution" 2 "Sympathy for the Socialist Party") pos(6) ring(3) row(1))
 
 ** Standardized version - Redistribution and Vote SP
  graph hbar (mean) std_redist std_vote_SP, over(occ_categories) ///
  title("Political Attitudes: part-timers vs full-timers") ///
  ytitle("Scores as standard deviations from the mean(zero)") yline(0)   ylab(-.15(0.05)0.15) legend(order(1 "Support for Redistribution" 2    "Sympathy for the SP") pos(10) ring(0) row(2) bmargin(medium))
 
*** Sympathy for the PVV and nattivist attitudes
 graph hbar (mean) nattivist_attitudes, over(occ_categories) ///
 title("Political Attitudes: part-timers vs full-timers") ///
 ytitle("Average scores") legend(order(1 "Nattivist attitudes" 2 "Sympathy for the PVV") pos(6) ring(3) row(1))
 // Restrict to temporary and non-temporary
  
  ** Standardized version - Nativist attitudes and vote PVV
  graph hbar (mean) std_nattivist_attitudes std_vote_PVV, over(			
  occ_categories) ///
  title("Political Attitudes: part-timers vs full-timers") ///
  ytitle("Scores as standard deviations from the mean(zero)") yline(0)   ylab(-.15(0.05)0.15) legend(order(1 "Nattivist attitudes" 2
   "Sympathy for the PVV") pos(1) ring(0) row(2) bmargin(small))
   
*** Ideology
 graph hbar (mean) ideology, over(occ_categories) ///
  title("Left-right wing scale: part-timers vs full-timers") ///
  subtitle("Scale from 0 (extreme) Left to 10 (extreme) right") ///
  ytitle("Average scores") legend(pos(6) ring(3) row(1))
 
*** Education level
graph hbar,  over(cat_educ) over(occ_categories) ///
legend(pos(6) ring(3) row(1)) ytitle("Percent") ///
title("Education profile: part-timers vs full-timers") ///
yscale(range(0 3)) asyvars percentages
// -> Interestingly, under-time part-timers are less educated than voluntary part-timers

*** Cultural background
graph hbar if origin != 0,  over(origin) over(occ_categories)  ///
legend(pos(5) bmargin(small) ring(1) row(4)) ytitle("Percent") ///
title("Cultural Background: part-timers vs full-timers") ///
ylab(0(10)100) asyvars percentages

*** Cultural background-2
graph hbar,  over(origin_2) over(occ_categories)  ///
legend(pos(6) ring(1) row(1)) ytitle("Percent") ///
title("Cultural Background: part-timers vs full-timers") ///
ylab(0(10)100) asyvars percentages

**** Age
graph hbar (mean) ageyrs,  over(occ_categories) 
 

**** Civil Status
graph hbar, over(civil_status) over(occ_categories) ///
  asyvars percentages 
  
*** ---- First Tests: Pooled OLS Models ---- ***

*** Job satisfaction
reg jobsatis_index i.occ_categories i.origin_2 ageyrs i.civil_status net_income i.cat_educ i.employcateg_3 i.origin_2 i.syear i.gender, robust


*** Redistribution
reg std_redist i.occ_categories i.origin_2 jobsatis_index ageyrs i.civil_status net_income i.cat_educ i.employcateg_3 i.syear, robust

*** Nattivist Attitudes - Puzzling(?) results
reg std_nattivist_attitudes i.occ_categories i.cat_educ i.origin_2 net_income i.gender jobsatis_index i.employcateg_3 ageyrs i.civil_status i.syear, robust 

*** Sympathy for the Socialist Party
reg std_vote_SP i.occ_categories i.origin_2 i.gender net_income jobsatis_index ageyrs i.civil_status i.cat_educ i.employcateg_3 i.syear , robust 


*** Sympathy for the PVV
reg std_vote_PVV i.occ_categories i.gender i.cat_educ i.origin_2 net_income jobsatis_index i.employcateg_3 ageyrs i.civil_status i.syear, robust 

*** Mediation hypotheses

*** Sympathy for the Socialist Party mediated by redistribution?
reg std_vote_SP i.occ_categories redist i.origin_2 i.gender net_income jobsatis_index ageyrs i.civil_status i.cat_educ i.employcateg_3 i.syear , robust 

*** Sympathy for the PVV mediated by nativist attitudes?
reg std_vote_PVV i.occ_categories nattivist_attitudes i.gender i.cat_educ i.origin_2 net_income jobsatis_index i.employcateg_3 ageyrs i.civil_status i.syear,robust 


/********************** Fixed-effects designs **********************
In this section, based on the theory and on cross-sectional evidence, I investigate whether there is a causal link between occupational status and political preferences. There are clear differences BETWEEN individuals with different occupational and socioeconomic characteristcs. This begs the question though how under-time part-time impact a individual's life course.  In other words, to what extent changing from under-time part-time work to any other category WITHIN an individual's life course has an impact on political preferences, job satisfaction, and nattivist attitudes.
********************************************************************/


****** Job Quality
xtreg jobsatis_index i.occ_categories if gender == 0, fe robust


****** Support for Redistribution 

*** 4th scale
xtreg std_redist i.occ_categories i.syear, fe robust

/*
Controlling for job quality doesn't change the effect, and the effect of job quality is not very substantive (-0.02) 
*/


****** Voting for the Socialist Party

*** 4th scale
xtreg std_vote_SP i.occ_categories if gender == 1, fe robust
/*
This effect is not being mediated by redist preferences either?
*/


****** Cultural intolerance
*** 4th scale
xtreg std_nattivist_attitudes i.occ_categories if gender == 0, fe robust


****** Voting for the PVV

*** 4th scale
xtreg std_vote_PVV i.occ_categories i.syear if gender == 0 & syear > 2016, fe robust



******************************************************
*       Robustness checks - Propensity to Vote       *
*                                                    * 
******************************************************

* Propensity to vote for the Socialist Party
xtreg prop_SP i.occ_categories i.syear if gender == 1, fe robust
xtreg prop_SP i.occ_categories i.syear if gender == 0, fe robust

* Propensity to vote for PVV
xtreg prop_PVV i.occ_categories i.syear if gender == 0, fe robust // adding year-fixed effects is of extreme importance
xtreg prop_PVV i.occ_categories if gender == 1, fe robust 

* Vote for the Greens

table syear occ_categories