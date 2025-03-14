/***************************************************************************
*	Title: crime_reshape.do
*	Purpose: 
*		append clean endline data for leaders and citizens; reshape dataset from wide to long to create a crime-level dataset 
*		with 18 observations for each individual (1 for each type of crime) along with indicators 
*		for whether the crime occurred, whether it was reported, and other outcomes.
*	Inputs:  endline_survey_clean.dta and endline_survey_leaders_clean.dta
*	Output:  crime_level_analysis.dta
****************************************************************************/
	
	
	clear
	clear matrix
	set mem 100m
	set more off

		
// Set directories

	// Location of data
	
	*gl cp "INSERT YOUR WORKING DIRECTORY HERE"
	
	use "$cp/data/cleandata/endline_survey_clean.dta", clear
	

// load up admin data

	insheet using "$cp/data/admindata/final_sample_randomization_wtowncode_wlisgis.csv",clear
		tempfile randz
		
		/* Generate weights for the inverse of the proportion of subjects within each block assigned to treatment (for treatment units) and control (for control units) */
		/* Will use these as regression weights, see G&G Section 4.5, p. 117 specifically */
		
		bys patrol: egen assignment_prob=mean(treatment)
			replace assignment_prob=1-assignment_prob if treatment==0
			la var assignment_prob "prob. of being assigned to treatment/control"
		save  `randz'
		
		
// Append citizen and leader surveys, merge in admin treatment data
			
		use "$cp/data/cleandata/endline_survey_clean.dta",clear
		append using "$cp/data/cleandata/endline_survey_leaders_clean.dta"
		merge m:1 towncode using `randz'
		
				 		
	/* drop 121 observations where entire crime section is missing */
	
	drop if arob==. & rob==. & aattack==. & attack==. & abuse==. & rape==. & dviol==. & narob==. & nrob==. & naattack==. & nattack==. 	
	
	
	/* avoid duplicate IDs between leaders and citizens */
	
	duplicates tag respid, gen (dups)
	replace respid=respid+35 if dups==1 & leader==1
	drop dups

		
			
// RESHAPE DATA FROM WIDE TO LONG TO CREATE A DISPUTE-LEVEL DATASET
	 

	gl i_ctrls_res female age kpelle lorma rel_Christian rel_Muslim rel_oth educ_none educ_abc educ_jh educ_hs readnews_dum  society age1825 age2635 age3645 age4655 age5665 age65 house_qual minority youth
	gl c_ctrls_census localitypop cunder18 ceduc cliterate cunemployed cwealth relelf elf poldepot
	gl crimes hsdisp fpdisp arob rob aattack attack abuse dviol nrob naattack nattack rape narob
	gl casewhere fpcasewhere hsdispwhere arobcasewhere robcasewhere aattackcasewhere attackcasewhere abusecasewhere dviolcasewhere narobcasewhere nrobcasewhere naattackcasewhere nattackcasewhere rapecasewhere

	keep respid cptreat patrol towncode assignment_prob leader $crimes $i_ctrls_res $c_ctrls_census $casewhere  fpdispthreat fpdispdestr hsdispthreat hsdispdestr

		ren hsdisp disp1
		ren fpdisp disp2
		ren arob disp3
		ren rob disp4
		ren aattack disp5
		ren attack disp6
		ren abuse disp7
		ren dviol disp8
		ren nrob disp9
		ren narob disp10
		ren naattack disp11
		ren nattack disp12
		ren rape disp13

		
		ren hsdispwhere  dispwhere1
		ren fpcasewhere dispwhere2
		ren arobcasewhere dispwhere3
		ren robcasewhere dispwhere4
		ren aattackcasewhere dispwhere5
		ren attackcasewhere dispwhere6
		ren abusecasewhere dispwhere7
		ren dviolcasewhere dispwhere8
		ren nrobcasewhere dispwhere9
		ren narobcasewhere dispwhere10
		ren nattackcasewhere dispwhere11
		ren naattackcasewhere dispwhere12
		ren rapecasewhere dispwhere13
		
	  

	/* Reshape data */	
		
		reshape long disp /*ldrsatis polsatis courtsatis*/ dispwhere, i(respid) j(disptype)
			
		la var disp "1 if crime occurred"
		la var disptype "type of crime"
		
		label define disptype 1 "house" 2 "farm" 3 "armed robbery" 4 "robbery" 5 "armed assault" 6 "assault" 7 "domestic abuse" 8 "domestic violence (in town)" 9 "robbery (in town)" 10 "armed robbery (in town)" 11 "armed assault (in town)" 12 "assault (in town)" 13 "rape (in town)"
		la values disptype disptype
	

	/* LEADERS WERE NOT ASKED ABOUT DISPTYPES 1 TO 7, SO THESE DISPUTES (OBSERVATIONS) ARE DROPPED */
		
		drop if leader==1 & disptype<8
		
		

/*************************************	
//  CONSTRUCT CRIME-LEVEL OUTCOME VARIABLES ON REPORTING
**************************************/

		
	gen OUTCOMES_REPORTING=.
		la var OUTCOMES_REPORTING "===================================="
	placevar OUTCOMES_REPORTING, f
		

	split dispwhere, parse(;) gen(dispwhere)
	gen use_court=cond(dispwhere1=="2-Court" | dispwhere2=="2-Court" | dispwhere3=="2-Court" | dispwhere4=="2-Court",1,0) if disp==1
	gen use_pol=cond(dispwhere1=="1-Police" | dispwhere2=="1-Police" | dispwhere3=="1-Police" | dispwhere4=="1-Police" ,1,0) if disp==1
	gen use_ldr=cond(dispwhere1=="4-Town chief" | dispwhere2=="4-Town chief" | dispwhere3=="4-Town chief" | dispwhere4=="4-Town chief" | dispwhere1=="5-Elders" | dispwhere2=="5-Elders" | dispwhere3=="5-Elders" | dispwhere4=="5-Elders",1,0) if disp==1
		
		/* drop extraneous variables used only for construction */
		drop dispwhere1 dispwhere2 dispwhere3 dispwhere4

	gen formal_and_informal=cond(use_ldr==1 & (use_pol==1 | use_court==1),1,0) if use_ldr!=.	
	gen formal_only=cond((use_court==1 | use_pol==1) & use_ldr==0,1,0) if use_ldr!=.
	gen informal_only=cond((use_court==0 & use_pol==0) & use_ldr==1,1,0) if use_ldr!=.
	gen nowhere=cond(use_court==0 & use_pol==0 & use_ldr==0,1,0) if use_ldr!=.

	placevar use_court use_pol use_ldr formal_and_informal formal_only informal_only nowhere, after(OUTCOMES_REPORTING)
	
		la var use_court "Crime reported to court"
		la var use_pol "Crime reported to police"
		la var use_ldr "Crime reported to town leader or town elders"
		la var formal_and_informal "Crime reported to formal and informal forums"
		la var formal_only "Crime reported to police or courts only"
		la var informal_only "Crime reported to town leader or leders only"
		la var nowhere "Crime reported nowhere"
		
		
/*************************************	
//  CONSTRUCT CONTROL VARIABLES 
**************************************/


	gen COVARIATES_CRIMELEVEL=.
		la var COVARIATES_CRIMELEVEL "===================================="
	placevar COVARIATES_CRIMELEVEL, f

	//  CRIME-LEVEL CONTROLS 
		
		gen dispute_self=cond(disptype<9,1,0)
			la var dispute_self "1 if self-victimization"
		gen dispute_town=cond(disptype>=9,1,0)
			la var dispute_town "1 if others victimization"
		
		/* define felony = armed robbery, aggravated assault, rape, property violent for heterogeneity analysis */
		
		label list disptype
		gen felony_dispute=cond(disptype==3 | disptype==5 | disptype==10 | disptype==11 | disptype==13,1,0) 
			/* If a land dispute involved threats of violence or property destruction or actual property destruction, it is coded as a felony */
			replace felony_dispute = 1 if disp==1 & disptype==1 & ( hsdispthreat==1 | hsdispdestr==1) 
			replace felony_dispute = 1 if disp==1 & disptype==2 & ( fpdispthreat==1 | fpdispdestr==1) 
			la var felony_dispute "1 if felony crime"
			
			
		/* drop extraneous variables used only for construction */
			drop hsdispthreat hsdispdestr fpdispthreat fpdispdestr	
			
		placevar dispute_self dispute_town felony_dispute, after(COVARIATES_CRIMELEVEL)

		
	// INDIVIDUAL LEVEL CONTROLS
	
	gen COVARIATES_INDV=.
		la var COVARIATES_INDV "===================================="
	placevar COVARIATES_INDV, f
	
		gen non_society = 1-society if society!=.
			la var non_society "Non-society member"
		
		placevar $i_ctrls_res non_society, after(COVARIATES_INDV)
			
		
	// TOWN LEVEL CONTROLS
	
	gen COVARIATES_TOWN=.
		la var COVARIATES_TOWN "===================================="
	placevar COVARIATES_TOWN, f
		
		gen log_localitypop=log(localitypop)
		placevar $c_ctrls_census log_localitypop, after(COVARIATES_TOWN)
		
		
		la var localitypop "Locality population (census)"
		la var cunder18 "Prop. town under 18 (census)"
		la var ceduc "Mean town edu (years) (census)"
		la var cliterate "Prop. town literate (census)"
		la var cunemployed "Prop. town unemployed (census)"
		la var cwealth "Mean town asset index (std) census"
		la var relelf "Town religious ELF (census)"
		la var elf "Town ethnicity ELF (census)"
		la var poldepot "Town has police station (census)"
		la var log_localitypop "Log town population (census)"
			
	
	// MISCELLEANEOUS LABELING AND ORGANIZING 
	
		la define cptreat 0 "Control" 1 "Treatment"
		la values cptreat cptreat
		la define society 0 "Not a society member" 1 "Society member"
		la values society society
		
		la var society "Society"
		la var female "Female"
		la var minority "Minority"
		la var youth "Youth"
		la var age2635 "Age 26-35"
		la var age3645 "Age 36-55"
		la var age4655 "Age 46-55"
		la var age5665 "Age 56-65"
		la var age65 "Age over 65"
		la var educ_abc "Primary school edu"
		la var educ_jh "Secondary school edu"
		la var educ_hs "Secondary or above edu"
		la var log_localitypop "Town population (logged)"
		la var poldepot "Police depot in town"
		la var rel_Christian "Christian"
		la var rel_Muslim "Muslim"
		la var rel_other "Other religion"
		la var age1825 "Age 18-25"
		la var house_qual "House quality index"


	gen ADMIN_DATA=.
		la var ADMIN_DATA "===================================="
	placevar ADMIN_DATA, before(respid)
		la var respid "respondent id"
		la var towncode "towncode"
		la var dispwhere "where crime reported"
		la var patrol "randomization block"
		


saveold "$cp/data/cleandata/crime_level_analysis.dta",replace	
		


		
