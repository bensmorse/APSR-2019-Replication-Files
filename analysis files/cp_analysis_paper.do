/***************************************************************************
*	Title: 		cp_analysis_paper.do.do
*	Purpose: 	Produces results for Figures 1-3 and Table Table 3 in Blair, Karim, & Morse (2019), as well as Tables and Figures for the Appendix
*	Inputs:  	endline_survey_clean.dta, final_sample_randomization_wtowncode_wlisgis.csv
*	Output:  	See "Replication_files\output"
****************************************************************************/

	
// SETUP
	
		clear
		clear matrix
		set mem 100m
		set more off
				
	// Set master global
			
		gl cp "INSERT YOUR WORKING DIRECTORY HERE"
		
	// Clean raw data, construct variables, merge citizen and leader surveys
		
		do "$cp/cleaning files/endline_clean.do"
		do "$cp/cleaning files/endline_clean_leaders.do"
		do "$cp/cleaning files/endline_merge.do"

	
	// Open analysis dataset
				
		use "$cp/data/cleandata/endline_analysis.dta",clear						
		
	/* Call up avg_effect program, modified to allow for varying treatment assignment probabilities across blocks following Gerber & Green Section 4.5, p. 117 */

		do "$cp/analysis files/avg_effect_weighted_reg.do"
	
	
// DEFINE GLOBALS 

	// CONTROLS
					
		/* hhsize, religion, and minority excluded from CTRLs because not measured among leaders by accident */
		gl i_ctrls_res female /*minority*/ age /*hhsize*/ kpelle lorma /*rel_Christian*/ educ_abc educ_jh educ_hs readnews_dum leader
		gl c_ctrls_survey mtownpop mmobile facilities_index poldepot roaddist_primary /* NOTE: poldepot roaddist_primary come from census */
		gl c_ctrls_census cwealth cliterate cnoschool ceduc cunemployed cunder18 localitypop elf relelf cdisplaced
		/* Communities divided into 9 blocks (``patrols"), block randomized within blocks. See Sample \& Research Design section of paper */
		gl blocks patrol1 patrol2 patrol3 patrol4 patrol5 patrol6 patrol7 patrol8
	
	// OUTCOMES
		
	gl knowledge_police_hubs polstation polnumber knowhub knowhubwhere knowhubdoes		
	gl knowledge_law cwfbeat_correct bushbodysuspect_correct habeascorpus_correct chiefdisp_correct sassywood_correct
	gl perceptions_police polcasepaysmall_disagree polcaseserious_agree polcasefreecriminal_disagree polcasesatis_agree polsusverbabuse_disagree polsusphsyabuse_disagree polsuspaysmall_disagree polcorr_disagree polttreatallequal_agree polwomensame_agree
	gl perceptions_courts courtdecide_agree  courtwomensame_agree courttreatallequal_agree courtcorr_disagree
	gl perceptions_govt govtcorr_disagree govttreatallequal_agree govtdecopen_agree  
	gl crime_dummies armed_assault armed_robbery domestic_violence assault robbery rape
	gl preferences_LNP  burglaryres_LNP dviolres_LNP arobres_LNP murderres_LNP mobviolres_LNP halahalres_LNP
	gl sassywood murdersasswoodself_agree missingsasswoodself_agree burglarysasswoodself_agree murdersasswoodcomm_agree missingsasswoodcomm_agree burglarysasswoodcomm_agree	
	gl property_rights hssecure_sure hsimprove2015  fplotsecure_sure fpnewirrig fpfallow2015 fpfallow2016 rec_hsdisp rec_fpdisp

		
	
/************************************
***** MAIN TABLES AND FIGURES ******* 
************************************/	
			
			
	// FIGURE 1 AVERAGE EFFECTS - ALL OUTCOMES
		
	eststo clear
	foreach y in knowledge_police_hubs knowledge_law perceptions_police perceptions_courts perceptions_govt preferences_LNP sassywood crime_dummies property_rights {
	
	des $`y'
	eststo: avg_effect_weighted_reg $`y', effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks $i_ctrls_res $c_ctrls_survey) cl(towncode) ap(assignment_prob)
	
	}
	
	eststo: areg scwf_donation cptreat $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob], ab(patrol) cl(towncode)
	
	/* OUTSHEET RESULTS */
		esttab _all , keep(ae_cptreat cptreat) se(2) b(2) noobs  depvar label replace
		esttab _all using "$cp/Output/Figure1_AverageEffects.csv", replace keep(ae_cptreat cptreat) se(2) b(2) noobs  depvar label plain


		
	// FIGURE 2 - EFFECTS ON INCIDENCE OF CRIME, DISAGGREGATED

	eststo clear	
	eststo: avg_effect_weighted_reg $crime_dummies, effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks $i_ctrls_res $c_ctrls_survey) cl(towncode) ap(assignment_prob)

	foreach y of varlist armed_assault armed_robbery domestic_violence assault robbery rape  {

	eststo: areg `y' cptreat $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob], ab(patrol) cl(towncode)

	}	
	
	/* OUTSHEET RESULTS */	
		esttab _all , keep(ae_cptreat cptreat) se(2) b(2) noobs  depvar label replace 
		esttab _all using "$cp/Output/Figure2_ATE_crime.csv", replace keep(ae_cptreat cptreat) se(3) b(3) noobs  depvar label plain
		
		
	// TABLE 1: EFFECTS ON REPORTING TO STATUTORY VS. CUSTOMARY AUTHORITIES

	
		* See cp_dispute_analysis_paper.do
	

	// TABLE 2 HETEROGENEOUS TREATMENT EFFECTS  ON USAGE BY SOCIETY MEMBERSHIP
	
	
		* See cp_dispute_analysis_paper.do

		
	// TABLE 3: EFFECTS ON SOCIAL SANCTIONS & APPEARANCES OF THE BUSH DEVIL
	
	eststo clear
	  
	  eststo: areg dviolpolvex_agree cptreat  $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob] , ab(patrol) cl(towncode)
	  eststo: areg burglarypolvex_agree cptreat  $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob] , ab(patrol) cl(towncode)
	  eststo: areg devil2015_any cptreat  $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob], ab(patrol) cl(towncode)

	  /* OUTSHEET RESULTS */

		esttab _all, drop(female age kpelle lorma educ_abc educ_jh educ_hs readnews_dum $c_ctrls_survey)  se(2) b(2)   depvar label star(+ 0.10 * 0.05 ** 0.01 *** 0.001)
		esttab _all using "$cp/Output/Table3.tex", drop(female age kpelle lorma educ_abc educ_jh educ_hs readnews_dum $c_ctrls_survey)  se(2) b(2) depvar label star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace

	
	// FIGURE 3 HETEROGENEOUS TREATMENT EFFECTS
	
	gl het female minority youth society 
	
	foreach x of varlist $het {
	
		gen cptreat_`x'=cptreat*`x'
		gen not_`x'=1-`x' if `x'!=.
		gen cptreat_not_`x'=cptreat*not_`x'
		
	}
	
	
	/* for heterogeneous treatment effects on crime, we restrict to self-victimization (crimes against the respondent), omitting responses for questions about crimes they may know about that happened to other people in their community */
		
		gl own_crime_dummies arob rob aattack attack abuse verbalabuse physicalabusethreat

	eststo clear
	
	foreach y in knowledge_police_hubs knowledge_law perceptions_police perceptions_courts perceptions_govt preferences_LNP sassywood own_crime_dummies property_rights {
			
	eststo: avg_effect_weighted_reg $`y', effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks $i_ctrls_res $c_ctrls_survey) cl(towncode) ap(assignment_prob)

	foreach x of varlist  $het { 
	
	eststo: avg_effect_weighted_reg $`y', effectvar(cptreat_`x' cptreat_not_`x' ) controltest(cptreat==0) x(cptreat_`x' cptreat_not_`x' `x' $blocks $i_ctrls_res $c_ctrls_survey) cl(towncode) ap(assignment_prob)
	
	}
	}
	
	eststo: areg scwf_donation cptreat $het $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob], ab(patrol) cl(towncode)
	
	foreach x of varlist $het { 
	
	eststo: areg scwf_donation cptreat_`x' cptreat_not_`x' `x' $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob], ab(patrol) cl(towncode)
	
	}
	
	gl effects ae_cptreat ae_cptreat_female ae_cptreat_minority ae_cptreat_youth ae_cptreat_society ae_cptreat_not_female ae_cptreat_not_minority ae_cptreat_not_youth ae_cptreat_not_society cptreat cptreat_female cptreat_minority cptreat_youth cptreat_society cptreat_not_female cptreat_not_minority cptreat_not_youth cptreat_not_society 
	
	esttab _all , keep($effects)  se(2) b(2) noobs  depvar label replace plain
	esttab _all using "$cp/output/Figure3_HetEffects.csv", replace keep($effects)  se(2) b(2) noobs  depvar label plain
		
	
		

/*****************************************************
************** APPENDIX *****************************
*****************************************************/



// APPENDIX A.5 DESCRIPTIVE STATISTICS

	gl knowledge_police_hubs_sum polstation polnumber knowhub knowhubwhere knowhubdoes		
	gl knowledge_law_sum cwfbeat_true bushbodysuspect_true habeascorpus_true chiefdisp_true sassywood_true
	gl perceptions_police_sum polcasepaysmall_agree polcaseserious_disagree polcasefreecriminal_agree polsusverbabuse_agree polsusphsyabuse_agree polsuspaysmall_agree polcorr_agree polttreatallequal_agree polwomensame_agree
	gl perceptions_courts_sum courtdecide_agree  courtwomensame_agree courttreatallequal_agree courtcorr_agree
	gl perceptions_govt_sum govtcorr_agree govttreatallequal_agree govtdecopen_agree  
	gl crime_dummies_sum armed_assault armed_robbery domestic_violence assault robbery rape
	gl preferences_LNP_sum  burglaryres_LNP dviolres_LNP arobres_LNP murderres_LNP mobviolres_LNP halahalres_LNP
	gl sassywood_sum murdersasswoodself_agree missingsasswoodself_agree burglarysasswoodself_agree murdersasswoodcomm_agree missingsasswoodcomm_agree burglarysasswoodcomm_agree	
	gl property_rights_sum hssecure_sure hsimprove2015  fplotsecure_sure fpnewirrig fpfallow2015 fpfallow2016 hsdisp fpdisp
	
	gl sums "$knowledge_police_hubs_sum $knowledge_law_sum $perceptions_police_sum $perceptions_courts_sum $perceptions_govt_sum $crime_dummies_sum $preferences_LNP_sum $sassywood_sum $property_rights_sum"	
	
	
	preserve
	keep $sums 
	placevar $sums, f
	outreg2 using "$cp/Output/Appendix5.tex",  replace sum(log) keep($sums) auto(2) eqkeep(mean N) label tex 	
		cap erase  "$cp/Output/Appendix5.txt"
	restore
		

// APPENDIX A.6 -- CORRELATION MATRIX OF DVs

	*GENERATE OUTCOME INDEXES
			
		foreach y in knowledge_police_hubs knowledge_law perceptions_police perceptions_courts perceptions_govt preferences_LNP sassywood crime_dummies property_rights {				
			egen `y'_index=rowmean($`y')
			qui sum `y'_index, d
			replace `y'_index = (`y'_index - `r(mean)') / `r(sd)'
		}
			
	eststo clear
	estpost corr knowledge_police_hubs_index knowledge_law_index perceptions_police_index perceptions_courts_index perceptions_govt_index preferences_LNP_index sassywood_index crime_dummies_index property_rights_index, matrix 


// APPENDIX A.7 BALANCE

	/* var labels for balance table */
		
		la var cwealth "Wealth index"
		la var cliterate "% of community literate" 
		la var cnoschool "% of community with no schooling"
		la var ceduc "Average years of education"
		la var cunemployed "% of community unemployed"
		la var cunder18 "% of community under 18"
		la var localitypop "Town population"
		la var elf "Ethnic diversity (ELF)"
		la var relelf "Religious diversity"
		la var cdisplaced "% of community displaced during the war"
	
	/* Town-level balance analaysis */
		bys towncode: gen town_count=_n
	
	/* without block fixed effects */
		reg cptreat $c_ctrls_census if town_count==1 [pweight=1/assignment_prob]
	
	/* with block fixed effects */
		areg cptreat $c_ctrls_census if town_count==1 [pweight=1/assignment_prob], ab(patrol) 
	
	/* SIMPLE DIFFERENCE IN MEANS COMPARISON */
		
		foreach y of varlist $c_ctrls_census {
		
		reg `y' cptreat if town_count==1 [pweight=1/assignment_prob]
		areg `y' cptreat if town_count==1 [pweight=1/assignment_prob], ab(patrol) 	
		
		}
	
	
// APPENDIX A.8 RESULTS FOR FIGURES 1 AND 2 WITH MULTIPLE COMPARISONS ADJUSTMENT



	/* REPLICATE RESULTS FOR FIGURE 1- AVERAGE EFFECTS - ALL OUTCOMES */
		
	eststo clear
	foreach y in knowledge_police_hubs knowledge_law perceptions_police perceptions_courts perceptions_govt preferences_LNP sassywood crime_dummies property_rights {
	
	des $`y'
	eststo: avg_effect_weighted_reg $`y', effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks $i_ctrls_res $c_ctrls_survey) cl(towncode) ap(assignment_prob)
	
	}
	
	eststo: areg scwf_donation cptreat $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob], ab(patrol) cl(towncode)
	
		
		/* OUTSHEET RESULTS */
		
		esttab _all , keep(ae_cptreat cptreat) se(2) b(2)  depvar label replace
		
			
	/* REPLICATE RESULTS FOR FIGURE 2 - EFFECTS ON INCIDENCE OF CRIME, DISAGGREGATED */

		eststo clear	
		eststo: avg_effect_weighted_reg $crime_dummies, effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks $i_ctrls_res $c_ctrls_survey) cl(towncode) ap(assignment_prob)

		foreach y of varlist armed_assault armed_robbery domestic_violence assault robbery rape  {

		eststo: areg `y' cptreat $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob], ab(patrol) cl(towncode)

		}	
	
		/* OUTSHEET RESULTS */
		
		esttab _all , keep(ae_cptreat cptreat) se(2) b(2)  depvar label replace 		
		
			

// APPENDIX A.9 -- MAIN EFFECTS WITH AND WITHOUT CONTROLS 

		
	eststo clear
	foreach y in knowledge_police_hubs knowledge_law perceptions_police perceptions_courts perceptions_govt preferences_LNP sassywood crime_dummies property_rights {
	
	des $`y'
	eststo: avg_effect_weighted_reg $`y', effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks ) cl(towncode) ap(assignment_prob)
	eststo: avg_effect_weighted_reg $`y', effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks $i_ctrls_res $c_ctrls_survey) cl(towncode) ap(assignment_prob)
	
	}
	
	
	eststo: areg scwf_donation cptreat [pweight=1/assignment_prob], ab(patrol) cl(towncode)
	eststo: areg scwf_donation cptreat $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob], ab(patrol) cl(towncode)
	
	esttab _all , keep(ae_cptreat cptreat) se(2) b(2)  depvar label replace 
				
		
// APPENDIX A.10 AVERAGE TREATMENT EFFECTS ON COMPONDENT DEPENDENT VARIABLES

	eststo clear
	foreach y in knowledge_police_hubs knowledge_law perceptions_police perceptions_courts perceptions_govt preferences_LNP sassywood crime_dummies property_rights {
	
	des $`y'
	eststo: avg_effect_weighted_reg $`y', effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks $i_ctrls_res $c_ctrls_survey) cl(towncode) ap(assignment_prob)
	
	foreach o in $`y' {
	
	  eststo: areg `o' cptreat  $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob], ab(patrol) cl(towncode)
	
	}
	}
	
	eststo: areg scwf_donation cptreat $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob], ab(patrol) cl(towncode)

	/* OUTSHEET RESULTS */

	esttab _all , keep(ae_cptreat cptreat) se(2) b(2) noobs  depvar label replace plain


// APPENDIX A11 EFFECTS ON CRIME REPORTING USING LNP DATA
	
	/* Available upon request */


// APPENDIX A12 CONDITIONING ON CRIME OCCURRENCE WHEN ESTIMATING DIFFERENCES IN CRIME REPORTING

	
	/* BALANCE ACROSS CRIMES IN TREATMENT AND CONTROL COMMUNITIES */

		/* see cp_crime_analysis_paper.do */

	
	/* ROBUSTNESS OF CRIME REPORTING RESULTS USING APPROACH THAT AVOIDS POST-TREATMENT BIAS */
	

	/* We include violent and non-violent property disputes in this analysis, the variables for which we construct here: */
	
		gen farm_violent=cond(fpdisp==1 & (fpdispthreat==1 | fpdispdestr==1),1,0)
		gen farm_nonviolent=cond(fpdisp==1 & (fpdispthreat==0 & fpdispdestr==0),1,0)
		gen house_violent=cond(hsdisp==1 & (hsdispthreat==1 | hsdispdestr==1),1,0)
		gen house_nonviolent=cond(hsdisp==1 & (hsdispthreat==0 | hsdispdestr==0),1,0)		
	
	/* each crime falls into either of three categories i) did not occur, ii) occurred and was reported to the police, and iii) occurred but was not reported to the police */
	/* we construct those indicators here */
		
	* 1. No crime occurrence
	
		gen no_armed_assault=cond((naattack!=1 & aattack!=1),1,0) if naattack!=. | aattack!=.
		gen no_armed_robbery=cond((narob!=1 & arob!=1),1,0) if narob!=. | arob!=.
		gen no_domestic_violence=cond((abuse!=1 & dviol!=1),1,0) if abuse!=. | dviol!=.
		gen no_domestic_abuse=cond((verbalabuse!=1 & physicalabusethreat!=1),1,0) if verbalabuse!=. | physicalabusethreat!=.
		gen no_assault=cond((attack!=1 & nattack!=1),1,0) if attack!=. | nattack!=.
		gen no_robbery=cond((nrob!=1 & rob!=1),1,0) if nrob!=. | rob!=.
		gen no_rape=cond(rape==0,1,0) if rape!=.
		gen no_house_violent=cond(house_violent==0,1,0) if house_violent!=.
		gen no_farm_violent=cond(farm_violent==0,1,0) if farm_violent!=.
		gen no_house_nonviolent=cond(house_nonviolent==0,1,0) if house_nonviolent!=.
		gen no_farm_nonviolent=cond(farm_nonviolent==0,1,0) if farm_nonviolent!=.
	
	* 2. Crime occurred, reported to either police or courts
	
		foreach x in arob rob aattack attack abuse dviol nrob narob naattack nattack rape {
		cap gen `x'_res_pol=cond(`x'polsatis!=.,1,0) if `x'==1
		cap gen `x'_res_ldr=cond(`x'ldrsatis!=.,1,0) if `x'==1
		cap gen `x'_res_court=cond(`x'courtsatis!=.,1,0) if `x'==1
			
		}
		
		gen farm_violent_res_pol=cond(fpdisppolsatis!=.,1,0) if farm_violent==1
		gen farm_violent_res_ldr=cond(fpdispldrsatis!=.,1,0) if farm_violent==1
		gen farm_violent_res_court=cond(fpdispcourtsatis!=.,1,0) if farm_violent==1

		gen house_violent_res_pol=cond(hsdisppolsatis!=.,1,0) if house_violent==1
		gen house_violent_res_ldr=cond(hsdispldrsatis!=.,1,0) if house_violent==1
		gen house_violent_res_court=cond(hsdispcourtsatis!=.,1,0) if house_violent==1
			
		gen farm_nonviolent_res_pol=cond(fpdisppolsatis!=.,1,0) if farm_nonviolent==1
		gen farm_nonviolent_res_ldr=cond(fpdispldrsatis!=.,1,0) if farm_nonviolent==1
		gen farm_nonviolent_res_court=cond(fpdispcourtsatis!=.,1,0) if farm_nonviolent==1

		gen house_nonviolent_res_pol=cond(hsdisppolsatis!=.,1,0) if house_nonviolent==1
		gen house_nonviolent_res_ldr=cond(hsdispldrsatis!=.,1,0) if house_nonviolent==1
		gen house_nonviolent_res_court=cond(hsdispcourtsatis!=.,1,0) if house_nonviolent==1
		
		gen armed_assault_rep=cond((naattack==1 & (naattack_res_pol==1 | naattack_res_court==1)) | (aattack==1 & (aattack_res_pol==1 | aattack_res_court==1)),1,0) if naattack!=. | aattack!=.
		gen armed_robbery_rep=cond((narob==1 & (narob_res_pol==1 | narob_res_court==1)) | (arob==1 & (arob_res_pol==1 | arob_res_court==1)),1,0) if narob!=. | arob!=.
		gen domestic_violence_rep=cond((abuse==1 & (abuse_res_pol==1 | abuse_res_court==1)) | (dviol==1 & (dviol_res_pol==1 | dviol_res_court==1)),1,0) if abuse!=. | dviol!=.
		gen assault_rep=cond((attack==1 & (attack_res_pol==1 | attack_res_court==1)) | (nattack==1 & (nattack_res_pol==1 | nattack_res_court==1)),1,0) if attack!=. | nattack!=.
		gen robbery_rep=cond((nrob==1 & (nrob_res_pol==1 | nrob_res_court==1)) | (rob==1 & (rob_res_pol==1 | rob_res_court==1)),1,0) if nrob!=. | rob!=.
		gen rape_rep=cond(rape==1 & (rape_res_pol==1 | rape_res_court==1),1,0) if rape!=.
		gen house_violent_rep=cond(house_violent==1 & (house_violent_res_pol==1 | house_violent_res_court==1),1,0) if house_violent!=.
		gen farm_violent_rep=cond(farm_violent==1 & (farm_violent_res_pol==1 | farm_violent_res_court==1),1,0) if farm_violent!=.
		gen house_nonviolent_rep=cond(house_nonviolent==1 & (house_nonviolent_res_pol==1 | house_nonviolent_res_court==1),1,0) if house_nonviolent!=.
		gen farm_nonviolent_rep=cond(farm_nonviolent==1 & (farm_nonviolent_res_pol==1 | farm_nonviolent_res_court==1),1,0) if farm_nonviolent!=.

		
	
	
	* 3. Crime occurred, not reported to either police or courts
	
		gen armed_assault_nrep=cond((naattack==1 & (naattack_res_pol==0 & naattack_res_court==0)) | (aattack==1 & (aattack_res_pol==0 & aattack_res_court==0)),1,0) if naattack!=. | aattack!=.
		gen armed_robbery_nrep=cond((narob==1 & (narob_res_pol==0 & narob_res_court==0)) | (arob==1 & (arob_res_pol==0 & arob_res_court==0)),1,0) if narob!=. | arob!=.
		gen domestic_violence_nrep=cond((abuse==1 & (abuse_res_pol==0 & abuse_res_court==0)) | (dviol==1 & (dviol_res_pol==0 & dviol_res_court==0)),1,0) if abuse!=. | dviol!=.
		gen assault_nrep=cond((attack==1 & (attack_res_pol==0 & attack_res_court==0)) | (nattack==1 & (nattack_res_pol==0 & nattack_res_court==0)),1,0) if attack!=. | nattack!=.
		gen robbery_nrep=cond((nrob==1 & (nrob_res_pol==0 & nrob_res_court==0)) | (rob==1 & (rob_res_pol==0 & rob_res_court==0)),1,0) if nrob!=. | rob!=.
		gen rape_nrep=cond(rape==1 & (rape_res_pol==0 & rape_res_court==0),1,0) if rape!=.
		gen house_violent_nrep=cond(house_violent==1 & (house_violent_res_pol==0 & house_violent_res_court==0),1,0) if house_violent!=.
		gen farm_violent_nrep=cond(farm_violent==1 & (farm_violent_res_pol==0 & farm_violent_res_court==0),1,0) if farm_violent!=.
		gen house_nonviolent_nrep=cond(house_nonviolent==1 & (house_nonviolent_res_pol==0 & house_nonviolent_res_court==0),1,0) if house_nonviolent!=.
		gen farm_nonviolent_nrep=cond(farm_nonviolent==1 & (farm_nonviolent_res_pol==0 & farm_nonviolent_res_court==0),1,0) if farm_nonviolent!=.
	
	* Check construction
		
		tab1 armed_assault no_armed_assault armed_assault_rep armed_assault_nrep
		tab1 armed_robbery no_armed_robbery armed_robbery_rep armed_robbery_nrep
		tab1 domestic_violence no_domestic_violence domestic_violence_rep domestic_violence_nrep
		tab1 assault no_assault assault_rep assault_nrep
		tab1 robbery no_robbery robbery_rep robbery_nrep
		tab1 rape no_rape rape_rep rape_nrep
		tab1 house_violent no_house_violent house_violent_rep house_violent_nrep
		tab1 farm_violent no_farm_violent farm_violent_rep farm_violent_nrep
		tab1 house_nonviolent no_house_nonviolent house_nonviolent_rep house_nonviolent_nrep
		tab1 farm_nonviolent no_farm_nonviolent farm_nonviolent_rep farm_nonviolent_nrep	
	
		
	// ESTIMATE AES ACROSS ALL CRIMES
			
		eststo clear
			eststo: avg_effect_weighted_reg armed_assault armed_robbery domestic_violence assault robbery rape house_violent farm_violent house_nonviolent farm_nonviolent, effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks ) cl(towncode) keepmissing ap(assignment_prob)
				
			// crime did not occur
			eststo: avg_effect_weighted_reg  no_armed_assault no_armed_robbery no_domestic_violence no_assault no_robbery no_rape no_house_violent no_farm_violent no_house_nonviolent no_farm_nonviolent, effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks ) cl(towncode) keepmissing ap(assignment_prob)
			
			// crime occurred and reported
			eststo: avg_effect_weighted_reg armed_assault_rep armed_robbery_rep domestic_violence_rep assault_rep robbery_rep rape_rep house_violent_rep farm_violent_rep house_nonviolent_rep farm_nonviolent_rep, effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks) cl(towncode) keepmissing ap(assignment_prob)
			
			// crime occurred, but not reported
			eststo: avg_effect_weighted_reg armed_assault_nrep armed_robbery_nrep domestic_violence_nrep assault_nrep robbery_nrep rape_nrep house_violent_nrep farm_violent_nrep house_nonviolent_nrep farm_nonviolent_nrep , effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks ) cl(towncode) keepmissing ap(assignment_prob)

		esttab _all, keep(ae_cptreat)  se(2) b(3)   depvar label replace mtitles("Occurred" "Did not occur" "Reported" "Not reported")
		
		
	// FELONIES
	
		eststo clear
			eststo: avg_effect_weighted_reg armed_assault armed_robbery rape house_violent farm_violent, effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks) cl(towncode) keepmissing ap(assignment_prob)
			
			// crime did not occur
			eststo: avg_effect_weighted_reg  no_armed_assault no_armed_robbery no_rape no_house_violent no_farm_violent, effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks ) cl(towncode) keepmissing ap(assignment_prob)
			 
			// crime occurred and reported
			eststo: avg_effect_weighted_reg armed_assault_rep armed_robbery_rep rape_rep house_violent_rep farm_violent_rep, effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks ) cl(towncode)  keepmissing ap(assignment_prob)
			
			// crime occurred, but not reported
			eststo: avg_effect_weighted_reg armed_assault_nrep armed_robbery_nrep rape_nrep house_violent_nrep farm_violent_nrep, effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks ) cl(towncode) keepmissing ap(assignment_prob)

		esttab _all, keep(ae_cptreat)  se(2) b(2)   depvar label replace mtitles("Occurred" "Did not occur" "Reported" "Not reported")

		
	// MISDEMEANORS
	
		eststo clear
			eststo: avg_effect_weighted_reg domestic_violence assault robbery house_nonviolent farm_nonviolent, effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks) cl(towncode) keepmissing ap(assignment_prob)
			
			// crime did not occur
			eststo: avg_effect_weighted_reg  no_domestic_violence no_assault no_robbery no_house_nonviolent no_farm_nonviolent, effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks ) cl(towncode) keepmissing ap(assignment_prob)
			
			// crime occurred and reported
			eststo: avg_effect_weighted_reg domestic_violence_rep assault_rep robbery_rep house_nonviolent_rep farm_nonviolent_rep, effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks ) cl(towncode) keepmissing ap(assignment_prob)
			
			// crime occurred, but not reported
			eststo: avg_effect_weighted_reg domestic_violence_nrep assault_nrep robbery_nrep farm_nonviolent_nrep house_nonviolent_nrep, effectvar(cptreat) controltest(cptreat==0) x(cptreat $blocks ) cl(towncode) keepmissing ap(assignment_prob)

		esttab _all, keep(ae_cptreat)  se(2) b(2)   depvar label replace  mtitles("Occurred" "Did not occur" "Reported" "Not reported")
		


// APPENDIX A13 HETEROGENEOUS TREATMENT EFFECTS ON CRIME REPORTING


	/* see cp_crime_analysis_paper.do */
	
	
// APPENDIX A14 - ADDITIONAL PRE-SPECIFIED HETEROGENEOUS TREATMENT EFFECTS ANALYSES NOT INCLUDED IN MAIN PAPER
  
  
	/* EFFECTS ON SECONDARY OUTCOMES NOT REPORTED IN THE PAPER */
  
  
	la var ebolacases "# of ppl in town with Ebola"
	la var taxauthoritypay_agree "Government has right to make ppl pay taxes"
  

eststo clear
	foreach y in ebolacases taxauthoritypay_agree {
	
	eststo: areg `y' cptreat $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob], ab(patrol) cl(towncode)
	
	}

	esttab _all, drop($i_ctrls_res $c_ctrls_survey)  se(2) b(2)   depvar label star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

	
	/* ADDITIONAL PRE-SPECIFIED HETEROGENEOUS TREATMENT EFFECTS ANALYSES NOT INCLUDED IN MAIN PAPER */
	
	* CONSTRUCT NUMBER OF PATROLS 
		foreach x of varlist patrol1date patrol2date patrol3date patrol4date patrol5date {

			gen `x'_dum=cond(`x'!="",1,0)
		
		}
		
		egen num_patrols=rowtotal(patrol1date_dum patrol2date_dum patrol3date_dum patrol4date_dum patrol5date_dum)
		
	
	* CONSTRUCT TREATMENT EFFECT HETEROGENEITY INTERACTIONS
		gl het leader war_viol_rebel war_viol_govt poldepot num_patrols
		
		foreach x of varlist $het {
			gen cptreat_`x'=cptreat*`x'
		}
		

	eststo clear
	
	foreach y in knowledge_police_hubs knowledge_law perceptions_police perceptions_courts perceptions_govt preferences_LNP sassywood own_crime_dummies property_rights {
	foreach x of varlist $het { 
	
	eststo: avg_effect_weighted_reg $`y', effectvar(cptreat cptreat_`x' ) controltest(cptreat==0) x(cptreat cptreat_`x' `x' $blocks $i_ctrls_res $c_ctrls_survey) cl(towncode) ap(assignment_prob)
	
	}
	}
		
	foreach x of varlist $het { 
	
	eststo: areg scwf_donation cptreat cptreat_`x' `x' $i_ctrls_res $c_ctrls_survey [pweight=1/assignment_prob], ab(patrol) cl(towncode)
	
	}
	
	gl effects ae_cptreat ae_cptreat_leader ae_cptreat_war_viol_rebel ae_cptreat_war_viol_govt ae_cptreat_poldepot ae_cptreat_num_patrols cptreat cptreat_leader cptreat_war_viol_rebel cptreat_war_viol_govt cptreat_poldepot cptreat_num_patrols
	
	esttab _all, keep($effects)  se(2) b(2) noobs  depvar tex  label
	

	
	

	
