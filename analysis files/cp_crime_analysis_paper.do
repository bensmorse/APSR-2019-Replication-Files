/***************************************************************************
*	Title: 		cp_crime_analysis_paper.do.do
*	Purpose: 	Conducts crime-level analysis for Tables 1 and 2 in Blair, Karim, & Morse (2019), as well as tables for Appendix 12 and 13
*	Inputs:  	crime_level_analysis.dta
*	Output:  	See "Replication_files\output"
****************************************************************************/
	
	
	clear
	clear matrix
	set mem 100m
	set more off	

		
// Set master global

	
	// Location of data
	
		gl cp "INSERT YOUR WORKING DIRECTOR HERE"
		
	// Clean raw data, construct variables, merge citizen and leader surveys
		
		do "$cp/cleaning files/endline_clean.do"
		do "$cp/cleaning files/endline_clean_leaders.do"
		do "$cp/cleaning files/crime_reshape.do"	
	
	use "$cp/data/cleandata/crime_level_analysis.dta",clear
 	
	
	gl ctrls_indv female  age2635 age3645 age4655 age5665 age65 educ_abc educ_jh educ_hs 
	gl ctrls_town log_localitypop poldepot
	/* Communities divided into 9 blocks (``patrols"), block randomized within blocks. See Sample \& Research Design section of paper */
	gl blocks patrol1 patrol2 patrol3 patrol4 patrol5 patrol6 patrol7 patrol8

	
 	
/**********************
// CRIME-LEVEL ANALYSIS
***********************/


// TABLE 1 TREATMENT EFFECTS  ON USAGE

	mean nowhere formal_only informal_only formal_and_informal
	mean nowhere formal_only informal_only formal_and_informal if felony_dispute==1
	mean nowhere formal_only informal_only formal_and_informal if felony_dispute==0

eststo clear

	foreach y of varlist nowhere formal_only informal_only formal_and_informal { 

	* All crimes
		eststo: areg `y' cptreat $ctrls_indv $ctrls_town [pweight=1/assignment_prob],  cl(towncode) ab(patrol)

	* Violent crimes
		eststo: areg `y' cptreat $ctrls_indv $ctrls_town if felony_dispute==1 [pweight=1/assignment_prob],  cl(towncode) ab(patrol)
	
	* Non-violent crimes
		eststo: areg `y' cptreat $ctrls_indv $ctrls_town if felony_dispute==0 [pweight=1/assignment_prob],  cl(towncode) ab(patrol)
		
	}
	

esttab _all , se(2) b(2) keep(cptreat)  depvar replace  label star(+ 0.10 * 0.05 ** 0.01 *** 0.001) 
esttab _all using "$cp/Output/Table1.tex", se(2) b(2) keep (cptreat) depvar replace  label star(+ 0.10 * 0.05 ** 0.01 *** 0.001) 


// TABLE 2 HETEROGENEOUS TREATMENT EFFECTS  ON CRIME REPORTING BY SOCIETY MEMBERSHIP

eststo clear

	* All crimes 
  foreach y of varlist nowhere formal_only informal_only formal_and_informal { 

	eststo: areg `y' c.cptreat##c.non_society $ctrls_indv if dispute_self==1 [pweight=1/assignment_prob],  cl(towncode) ab(patrol) 

}

	* Violent crimes
  foreach y of varlist nowhere formal_only informal_only formal_and_informal { 

	eststo: areg `y' c.cptreat##c.non_society $ctrls_indv if felony_dispute==1 & dispute_self==1 [pweight=1/assignment_prob],  cl(towncode) ab(patrol) 
		
}
		
	* Non-violent crimes
foreach y of varlist nowhere formal_only informal_only formal_and_informal { 

	eststo: areg `y' c.cptreat##c.non_society $ctrls_indv if felony_dispute==0 & dispute_self==1 [pweight=1/assignment_prob],  cl(towncode) ab(patrol) 

}

esttab _all , se(2) b(2)  depvar replace  label star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop($ctrls_indv)
esttab _all using "$cp/Output/Table2.tex", se(2) b(2) depvar replace  label star(+ 0.10 * 0.05 ** 0.01 *** 0.001)  drop($ctrls_indv)




/******************************************
*****  APPENDIX ************************
******************************************/



// APPENDIX A12 CONDITIONING ON CRIME OCCURRENCE WHEN ESTIMATING EFFECTS ON CRIME REPORTING

	// BALANCE -- are crimes that occurred in T communities similar on observables to those that occurred in C communities?
	
cap matrix drop E
		
		foreach x in $ctrls_indv $ctrls_town society minority {

		sum `x' if disp==1 & cptreat==0
				sca c_mu = r(mean)
				
		sum `x' if disp==1 & cptreat==1
				sca t_mu = r(mean)
				
		areg `x' cptreat if disp==1 [pweight=1/assignment_prob], ab(patrol)  cl(towncode)
			sca obs = e(N)
			sca b_cptreat = _b[cptreat]
			matrix V = e(V)
			sca se_cptreat = sqrt(V[1,1])
			sca T_cptreat = b_cptreat / se_cptreat
			
			matrix E = nullmat(E)\(c_mu,t_mu,b_cptreat,se_cptreat,T_cptreat,obs)
		
		}
					
			
		local cnames `" "Mean (control)" "Mean (treatment)" "Difference" "Std. Error" "T-statistic" "Obs" "'
		local rname	
			
		foreach x in $ctrls_indv $ctrls_town society minority  {
			local lbl  `x'
			local rname `" `rname' `lbl' "'
		}	
		
		matrix rownames E = `rname'
		matrix colnames E = MeanC MeanT Diff SE T N
		
		estout matrix(E, fmt(2 2 2 2 2 0)) using "$cp/Output/Appendix12.tex", style(tex) replace // "
	
	
	
/***********************************
// APPENDIX 13 HETEROGENEOUS TREATMENT EFFECTS ON CRIME REPORTING
***********************************/


//  HETEROGENEOUS TREATMENT EFFECTS  ON USAGE BY  FEMALE MINORITY YOUTH

eststo clear

foreach x of varlist minority { // female  minority youth {

	* All crimes 
  foreach y of varlist nowhere formal_only informal_only formal_and_informal { 

	eststo: areg `y' cptreat c.cptreat#c.`x' `x' if dispute_self==1 [pweight=1/assignment_prob],  cl(towncode) ab(patrol) 

}

esttab _all , se(2) b(2)  depvar replace  label star(+ 0.10 * 0.05 ** 0.01 *** 0.001)  tex br

	* Violent crimes
  foreach y of varlist nowhere formal_only informal_only formal_and_informal { 

	eststo: areg `y' cptreat c.cptreat#c.`x' `x'  if felony_dispute==1 & dispute_self==1 [pweight=1/assignment_prob],  cl(towncode) ab(patrol) 
		
}
	
esttab _all , se(2) b(2)  depvar replace  label star(+ 0.10 * 0.05 ** 0.01 *** 0.001)  tex br
	
	* Non-violent crimes
foreach y of varlist nowhere formal_only informal_only formal_and_informal { 

	eststo: areg `y' cptreat c.cptreat#c.`x' `x'  if felony_dispute==0 & dispute_self==1 [pweight=1/assignment_prob],  cl(towncode) ab(patrol) 

}
}

esttab _all , se(2) b(2)  depvar  label star(+ 0.10 * 0.05 ** 0.01 *** 0.001) tex br
/*esttab _all using "$cp/Output/Appendix13.tex", se(2) b(2) depvar replace  label star(+ 0.10 * 0.05 ** 0.01 *** 0.001) br*/



		
	
	
	
	
	
	
