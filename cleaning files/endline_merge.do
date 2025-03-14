/***************************************************************************
*			Title: endline_merge.do
*			Purpose: Append ('merge' in filename a bit of a misnomer) clean endline data for citizens and leaders to produce analysis ready datafile
*			Inputs:  endline_survey_clean.dta and endline_survey_leaders_clean.dta
*			Output:  endline_analysis.dta
****************************************************************************/


version 10.0
clear

// Set directories

	// Location of data
	
		*gl cp "INSERT YOUR WORKING DIRECTORY HERE"
		
		use "$cp/data/cleandata/endline_survey_clean.dta", clear
		
// APPEND RESIDENTS AND LEADERS SURVEYS
	
	append using "$cp/data/cleandata/endline_survey_leaders_clean.dta"
	
	sort towncode
	
	
	/* avoid duplicate respids between leaders and citizens */
	duplicates tag respid, gen (dups)
	replace respid=respid+35 if dups==1 & leader==1
	drop dups
	

	
// GENERATE COMMUNITY-LEVEL CONTROL VARIABLES

	gen COVARIATES_TOWN=.
		la var COVARIATES_TOWN "===================================="
	placevar COVARIATES_TOWN, f

	foreach x of varlist townpop /* clinics schools wells latrines guesthouse roaddistrain_min polstationdist_min*/ {
		bys towncode: egen m`x'=mean(`x')
		}

		la var mtownpop "Town population (ldr. mean)"
		
				
	foreach x of varlist mobile clinics_any schools_any wells_any latrines_any guesthouse_any /* dviol narob nrob naattack nattack rape murder riot devil2015_any sassynum_any mobviol_any */ {
		bys towncode: egen m`x'=mode(`x') if leader==1, maxmode
			bys towncode: egen maxm`x'=max(m`x')
				replace m`x'=maxm`x' if m`x'==.
				drop maxm`x'
		}
	
		la var mmobile "Cell coverage in town (ldr. mode)"
		la var mclinics_any "Any clinics in town (ldr. mode)"
		la var mschools_any "Any schools in town (ldr. mode)"
		la var mwells_any "Any wells in town (ldr. mode)"
		la var mlatrines_any "Any latrines in town (ldr. mode)"
		la var mguesthouse_any "Any guesthouses in town (ldr. mode)"

	
	gen facilities_index=mclinics_any+mschools_any+mwells_any+mlatrines_any+mguesthouse_any
		la var facilities_index "# of facilities available in town (ldr. mode, additive)"
		
		/* drop extraneous vars used only for construction */
		drop mclinics_any mschools_any mwells_any mlatrines_any mguesthouse_any
			
	placevar  mtownpop mmobile facilities_index, after(COVARIATES_TOWN)


// MERGE IN ADMINISTRATIVE DATA 
	

preserve

	// Insheet admin data
	
		/* admin data */
		insheet using "$cp/data/admindata/final_sample_randomization_wtowncode_wlisgis.csv",clear
			tempfile randz
			
		/* Generate weights denoting the inverse of the proportion of subjects within each block assigned to treatment (for treatment units) and control (for control units) */
		/* Will use these as regression weights, see Gerber & Green Section 4.5, p. 117 specifically */
		
		bys patrol: egen assignment_prob=mean(treatment)
			replace assignment_prob=1-assignment_prob if treatment==0
			la var assignment_prob "prob. of being assigned to treatment/control"
			la var patrol "randomization stratum"
			
		/* Generate dummies for treatment block */ 
		
		tab patrol,gen(patrol)
				
		save  `randz'
 
		/* insheet patrol logs */
		
		insheet using "$cp/data/admindata/PatrolLog.csv",clear
		keep towncode patrol1 patrol2 patrol3 patrol4 patrol5
			ren patrol1 patrol1date
			ren patrol2 patrol2date
			ren patrol3 patrol3date
			ren patrol4 patrol4date
			ren patrol5 patrol5date		
		tempfile patrollog
		save `patrollog'	
restore

	/* Merge administrative data */
				
		merge m:1 towncode using `randz'
		merge m:1 towncode using `patrollog', gen(logmerge)
	
	/* Merge data on respondents' donations to community watch groups/forums */
	
		merge 1:1 respid using "$cp/data/rawdata/CWF_Donations_Data.dta", gen(donmerge)
		drop if donmerge==2	 /* drops donations data for 428 donations that cannot be matched to a valid respondent id due to enumerator errors */ 
	
		
// SAVE

	saveold "$cp/data/cleandata/endline_analysis.dta",  replace

