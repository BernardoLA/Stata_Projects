/*------------------- Internship Project-----------------------------
* RQ: How Labour Market vulnerability impacts Political behaviour?
* Dofile: This do-file regards data cleaning, merging and rehape steps
* of the projects.
* Data: LiSS Panel

* Supervisors: Wouter Schakel, Armen Hakhverdian
* Intern: Bernardo Leivas 
--------------------------------------------------------------------- */
 
 **----Modules Politics and Values, Economic Situation: Income and Work and Schooling-----**
 
* I start working first with these three modules because they have the same data structure whereas the background variables dataset does not.
 
clear 
 global path "C:\Users\be_al\Google Drive\UvA_RMSS\2nd year\Internship\Data"
 global posted "$path\posted"

**-- Change directory to $path to merge files --*
 
 cd "$path"
 
**-- Change datasets from csv to dta --**
	 
 local files: dir "$path" files "*.csv"
 foreach file in `files'{
     clear
	 import delimited `file'
	 save `file'.dta, replace
 }
 
**-- Merging datasets --** 

use "$path\politics_values1.dta", clear

local files: dir "$path" files "*.dta"
foreach f in `files'{
	merge 1:1 nomem_encr using `f', keep (1 2 3)
	drop _merge
}

* --------- Add missing variables for the Replication exercise  --------- *

* What do you think of the PVV(cv213) and SP(cv214) - Those variables need to be renamed
* because they changed names across waves

** SP waves 1-3 cv079/ waves 4-5 cv177/ wave 6-13 cv(13f)214  
des cv*079
des cv*177
des cv*214
rename cv(##)?177 cv(##)*079
rename cv(##)?214 cv(##)*079

** PVV waves 1-3 cv(08a)085 / waves 4-5 cv175 / wave 6-13 cv213
des cv*085
des cv*175
des cv*213
rename cv(##)?175 cv(##)*085
rename cv(##)?213 cv(##)*085

**-- Reshaping dataset from wide to long --** 

* Renaming variables so the year comes at the end
foreach year in 08 09 10 11 12 13 14 15 16 17 18 19 20 21 {
	rename *`year'?(###) *.(###)_`year'
}

rename *_08 *_8
rename *_09 *_9

* Listing all variables that end in a year
quietly ds *_8 *_9 *_10 *_11 *_12 *_13 *_14 *_15 *_16 *_17 *_18 *_19 *_20 *_21

* This line until the reshape need to be executed at the same time
local stubs `r(varlist)'

* Creating stubs by removing the year suffix from all variable names
foreach year in 8 9 10 11 12 13 14 15 16 17 18 19 20 21 {
	local stubs: subinstr local stubs "_`year'" "_", all
}

* Deleting duplicates in the macro (i.e. variables that were included in
* multiple waves)
local stubs: list uniq stubs
reshape long `stubs', i(nomem_encr) j(syear)


* Final Renaming 
rename *_ *
rename nomem_encr pid

 forval i = 8(1)21{
 	if `i' < 10 recode syear (`i' = 200`i')
	if `i' >= 10 recode syear (`i' = 20`i')
 }
  
 **--Testing removing empty observations before merging with the BV_dataset --** 
 /* When I do merge the dataset without the empty observations we do not get anymore 
 that weird result of tons of unmatched obs from the using dataset down below */
 
egen missing = rownonmiss(cv012-cw538)
keep if missing != 0

save "$posted\pv&ws&es_reshaped_data", replace


*** I know move on to work with the separate dataset for Background variables ***
*** Only after some changes I can merge it with the dataset above. ***



**----------Background variables----------**
 clear
 
 global path "C:\Users\be_al\Google Drive\UvA_RMSS\2nd year\Internship\Data\Background_Variables"
 global posted "$path\posted"
 
 cd "$path"


**-- Save files as .dta --**
forval i = 3(1)14{
import delimited bv_wave`i'
save bv_wave`i'.dta
clear
}

**-- merge files --** /* Which solution? Slightly different results */

/*This first option I end up with 1 884 755 observations and 33 variables, 
although it seems to me not the proper command since in this case I want to
append and not to merge datasets. */

use bv_wave3
forval i = 4(1)14{
merge 1:1 nomem_encr wave using bv_wave`i', keep (1 2 3)
drop _merge
}*/

*This seems to be the right command, since the variables are exactly the same 
between datasets and only the observations that vary. It gives 1 895 575 
observations and 33 variables. I decide to draw on this data set */

use bv_wave3
forval i = 4(1)14{
	append using bv_wave`i'
}

save "..\posted\Merged_BV_longformat", replace



** -- Prepare the BV dataset to merge with the other modules --*

use "..\posted\Merged_BV_longformat", clear

sort nomem_encr wave

** I recode all the variables to the respective year to then pick up the last measurement of each year.

recode wave (200711/200812 = 2008)(200901/200912 = 2009) (201001/201012 = 2010) ///
(201101/201112 = 2011) (201201/201212 = 2012) (201301/201312 = 2013) (201401/201412 = 2014) ///
(201501/201512 = 2015) (201601/201612 = 2016) (201701/201712 = 2017) (201801/201812 = 2018) ///
(201901/201912 = 2019) (202001/202012 = 2020) (202101/202112 = 2021), gen(syear)


** I decide to take the mode of each categorical variable
br nomem_encr wave syear positie geslacht herkom* oplcat oplmet ///
oplzon belbezig


foreach v in positie geslacht herkomstgroep oplcat oplmet oplzon belbezig{
    bys nomem_encr syear: egen mode_`v' = mode(`v'), maxmode
}

* Now drop the original variables
drop positie geslacht herkomstgroep oplcat oplmet oplzon belbezig

* rename the modes
rename mode_* * 

* Check if the recoded worked as planned
tab syear

* rename the id variables
rename nomem_encr pid


/* Data collection took place in different months for each module. 
Since the background variables are relatively stable across time, 
I decided to calculate the mean value across months for each year. */

* Creates a list with all the variables in the data
quietly ds

* It calculates the mean value for each background variable stored on "`varlist'", sorted by the id variable nomem_encr

local varlist `r(varlist)'
foreach v in `varlist' {
	bysort pid syear: egen mean_`v' = mean(`v')

}

* Checking that the categorical variables are not affected by the mean calculation. They are now exactly the same as their mean versions.

tab herkomstgroep mean_herkomstgroep
tab belbezig mean_belbezig 
tab mean_oplcat oplcat

* Now, keep only 1 observation per group (nomem_encr year) which is the mean value for each corresponding year.
bys pid syear: keep if _n == 1

mdesc // /* The apparent problem of missing values don't seem to be in this dataset, 
     //     only 9% of observations are reported as missing net income */

* Keep the necessary variables
keep mean_* pid syear
drop mean_syear mean_nohous mean_pid 

* Remove _mean from variables before merge
rename mean_* * 

save "C:\Users\be_al\Google Drive\UvA_RMSS\2nd year\Internship\Data\posted\BV_Final", replace

**-- merge with other dataset with the modules Politics and Values, Economic Situation: Income and Work and Schooling --**

use "C:\Users\be_al\Google Drive\UvA_RMSS\2nd year\Internship\Data\posted\BV_Final", clear

cd "C:\Users\be_al\Google Drive\UvA_RMSS\2nd year\Internship\Data\posted"

merge 1:1 pid syear using pv&ws&es_reshaped_data, keep (1 2 3)

* save final dataset with all modules

save "C:\Users\be_al\Google Drive\UvA_RMSS\2nd year\Internship\Data\posted\final_dataset_fully_merged", replace








