/***************************************************************************
*	Title: endline_clean_leaders.do
*	Purpose: clean raw endline survey data from leaders
*	Inputs:  endline_survey_raw_leaders.dta 
*	Output:  endline_survey_clean_leaders.dta
****************************************************************************/


version 10.0
clear

// Set directories and open rawdata 

	// Location of data
	
		*gl cp "INSERT YOUR WORKING DIRECTORY HERE"
	
		use "$cp/data/rawdata/endline_survey_raw_leaders.dta",clear

	
/********************************	
// CLEAN DATA
********************************/


	// DROP VARIABLES NOT RELEVANT TO EVALUATION

	drop recordid unitid POLICY_ENDORSEMENT-towncode2 
	
	

	// CONVERT STRINGS TO NUMERIC (ORDINAL DATA) 

	gl demo gender educ tribe
	gl perceptions polcasepaysmall - taxauthoritypay
	gl compliance burglarypolvex dviolpolvex burglarysasswoodcomm burglarysasswoodself missingsasswoodcomm missingsasswoodself murdersasswoodcomm murdersasswoodself
	gl cwf_pol  cwfrogues cwflazy cwfmobviol 
	gl ebola hwprotest ngoprotest ebolasatisfied 
	
	replace tribe="12-Lorma" if tribe=="Lorna " 
	

	
	foreach x of varlist  $demo $perceptions $compliance $cwf_pol $ebola {
			
			qui tab `x'

			cap local lbl: variable label `x'
			cap rename `x' `x'_
			cap egen `x' = ends (`x'_), punct(-) head
			cap move `x' `x'_
			cap drop `x'_
			cap destring `x', replace
			cap replace `x'=.c if `x'==88
			cap replace `x'=.a if `x'==97
			cap replace `x'=.b if `x'==98
			cap la var `x' "`lbl'"
 
		}
	 	
		
		 
	
	// CONVERT Yes/No (Y or N) STRINGS TO DUMMIES

	gl demo_yn readnews 
	gl cwf_pol_yn paypolice witphypolabuse witverbpolabuse polcomplainpunish cwforum cwfmember
	gl crime_yn rape dviol narob nrob naattack nattack
	gl patrols_yn psu psumeeting psuscared  psuscarednow  

		
	foreach x of varlist $demo_yn $cwf_pol_yn $crime_yn $patrols_yn murder riot mobile {
	
		cap local lbl: variable label `x'
		cap rename `x' `x'_
		gen `x'=cond(`x'_=="Y",1,cond(`x'_=="N",0,.))
		la var `x' "`lbl'"
		move `x' `x'_
		drop `x'_
	
	}


	

	// DEFINE VARIABLE LABELS AND LABEL RAW VARIABLES

	label define gender 1 "Male" 2 "Female"
	label define educ 0 "None" 1 "Some ABC" 2 "Completed ABC" 3 "Some JH" 4 "Completed JH" 5 "Some HS" 6 "Completed HS" 7 "Some University" 8 "Completed University" 88 "Other"
	label define frequency 1 "Everyday" 2 "Weekly" 3 "Monthly" 4 "Not too often"
	label define yesnodkrta 0 "No" 1 "Yes" .a "Don't know" .b "Refuse to answer"
	label define agreedisagree3point 0 "Strong disagree" 1 "Disagree" 2 "Agree" 3 "Strongly Agree" .a "Don't know" .b "Refuse to answer"
	label define extent 0 "Not at all" 1 "Just a little" 2 "Somewhat" 3 "A lot" .a "Don't know" .b "Refuse to answer"
	label define agreedisagree 0 "Disagree" 1 "Agree" .a "Don't know" .b "Refuse to answer"
	label define whorules 1 "Govt" 2 "NGOs" 3 "UNMIL" 4 "Community Leaders" 5 "Traditional Leaders" 6 "Community residents" 88 "Other"
	label define ability 0 "Very bad" 1 "Bad" 2 "Good" 3 "Very good"
	label define occupations 0 "None" 1 "Petty business" 2 "Buying and selling" 3 "Mining" 4 "Rubber tapping" 5 "Hunting" 6 "Road work" 8 "Daily hire" 9 "Peim peim" 10 "Making farm" 11 "Skilled trade" 12 "Office work" 13 "Hustling" 14 "Other" 88 "Other"

		la values gender gender
		la values educ educ
		la values tribe tribe
		la values polcasepaysmall - taxauthoritypay agreedisagree3point


	
	
/*************************************	
//  CONSTRUCT CONTROL VARIABLES 
**************************************/
		
	gen COVARIATES=.
		la var COVARIATES "===================================="
	placevar COVARIATES, f
		
	
	// CONTROL VARIABLES FROM DEMOGRAPHICS SECTION
		
		gen female=cond(gender==2,1,0)
		gen educ_none=cond(educ==0,1,0)
		gen educ_abc=cond(educ==1 | educ==2,1,0)
		gen educ_jh=cond(educ==3 | educ==4,1,0)
		gen educ_hs=cond(educ>=5 & educ!=.,1,0)
	
		
		/* defining minority as dummy for any non-modal tribe */
		bys towncode: egen majortribe=mode(tribe)
			gen minority=cond(tribe!=majortribe,1,0) if tribe!=.
				drop majortribe
			
		/* elder define somewhat arbitrarily as above age 45 */
		/* gen elder=cond(age>45,1,0) if age!=. */
		
		gen readnews_dum=cond(readnews==1,1,0)
		gen age1825=cond(age<25,1,0)
		gen age2635=cond(25<age & age<36,1,0)
		gen age3645=cond(35<age & age<46,1,0)
		gen age4655=cond(45<age & age<56,1,0)
		gen age5665=cond(55<age & age<66,1,0)
		gen age65=cond(65<age,1,0)

		gen lead_chief=(leaderpos=="1-Chief" | leaderpos=="2-Assistant Chief") if leaderpos!=""
		gen lead_women=(leaderpos=="3-Womens leader" | leaderpos=="4-Assistant womens leader") if leaderpos!=""
		gen lead_youth=(leaderpos=="5-Youth leader" | leaderpos=="6-Assistant youth leader") if leaderpos!=""
		gen lead_elder=(leaderpos=="8-Elder") if leaderpos!=""
		gen leader=1
		
		gen kpelle=cond(tribe==9,1,0)
		gen lorma=cond(tribe==12,1,0)
		
				
	/*  impute controls with median value if missing -- ~50 changes made total across all vars. */

	foreach x of varlist lead_chief lead_women lead_youth female age  educ_abc educ_jh educ_hs readnews_dum	{
	
		qui sum `x',d
		replace `x'=`r(p50)' if `x'==.
	}
	
			

	// CONTROL VARIABLES FROM TOWN CHARACTERISTICS SECTION
		/* We asked leaders to report on things like town characteristics, population, etc */
	
	
		foreach x of varlist clinics schools wells latrines guesthouse {
			qui sum `x',d
			replace `x'=r(p99) if `x'>r(p99) & `x'!=.
			gen `x'_any=(`x'>0) if `x'!=.
		}
		
		
		qui sum townpop, d
			replace townpop=r(p99) if townpop>r(p99) & townpop!=.
		
		gen roaddistrain_min=roaddistrain
			replace roaddistrain_min=roaddistrain*60 if roaddistrainunit=="2-Hours"
		
		gen polstationdist_min=polstationdist
			replace polstationdist_min=polstationdist*60 if polstationdistunit=="2-Hours"
			
	placevar female-age65 leader lead_chief lead_women lead_youth lead_elder clinics_any schools_any wells_any latrines_any guesthouse_any roaddistrain_min polstationdist_min , after(COVARIATES)
		
		la var female "Female"
		la var minority "Minority in town"
		la var educ_none "No education"
		la var educ_abc "Primary school education"
		la var educ_jh "Middle school education"
		la var educ_hs "High school or greater education"
		la var readnews_dum "Literate"
		la var kpelle "Kpelle ethnicity"
		la var lorma "Lorma ethnicity"			
	
/*************************************	
//  CONSTRUCT OUTCOME VARIABLES ***** 
**************************************/

	
	
	// PERCEPTIONS OF POLICE OUTCOMES FROM PERCEPTIONS SECTION OF SURVEY
	
	
		gen OUTCOMES_PERCEPTIONS_POLICE=.
		la var OUTCOMES_PERCEPTIONS_POLICE "=================================="
		placevar OUTCOMES_PERCEPTIONS_POLICE, f

		
		tab1 $perceptions
				
		foreach x of varlist $perceptions  {
				
				gen `x'_agree=cond(`x'==2 | `x'==3,1,0) if `x'!=.
				gen `x'_disagree=cond(`x'==0 | `x'==1,1,0)  if `x'!=.
				placevar `x'_agree `x'_disagree, after(taxauthoritypay)
				
			}
		
					

	placevar polcasepaysmall_disagree polcaseserious_agree polcasefreecriminal_disagree polsusverbabuse_disagree polsusphsyabuse_disagree polsuspaysmall_disagree polcorr_disagree polttreatallequal_agree polwomensame_agree, after (OUTCOMES_PERCEPTIONS)
	

		la var polcasepaysmall_disagree "Police will make you pay a bribe? Disagree"
		la var polcasepaysmall_agree "Police will make you pay a bribe? Agree"
		la var polcaseserious_agree "Police take cases seriously? Agree"
		la var polcaseserious_disagree "Police take cases seriously? Disagree"
		la var polcasefreecriminal_disagree "Police will free a criminal for a bribe? Disagree"
		la var polcasefreecriminal_agree "Police will free a criminal for a bribe? Agree"
		la var polsusverbabuse_disagree "Police verbally abuse suspects? Disagree"
		la var polsusverbabuse_agree "Police verbally abuse suspects? Agree"
		la var polsusphsyabuse_disagree "Police physically abuse suspects? Disagree"
		la var polsusphsyabuse_agree "Police physically abuse suspects? Agree"
		la var polsuspaysmall_disagree "Police make victims pay bribes? Disagree"
		la var polsuspaysmall_agree "Police make victims pay bribes? Agree"
		la var polcorr_agree "Police are corrupt? Agree"
		la var polcorr_disagree "Police are corrupt? Disagree"
		la var polttreatallequal_disagree "Police treat all tribes equally? Disagree"
		la var polttreatallequal_agree "Police treat all tribes equally? Agree"
		la var polwomensame_disagree "Police treat women and men the same? Disagree"
		la var polwomensame_agree "Police treat women and men the same? Agree"
			
	
	// PERCEPTIONS OF COURTS OUTCOMES FROM PERCEPTIONS SECTION OF SURVEY
		
		gen OUTCOMES_PERCEPTIONS_COURTS=.
		la var OUTCOMES_PERCEPTIONS_COURTS "=================================="
		placevar OUTCOMES_PERCEPTIONS_COURTS, f
		
		placevar courtdecide_agree courtwomensame_agree courttreatallequal_agree courtcorr_disagree, after (OUTCOMES_PERCEPTIONS_COURTS)
		
		la var courtdecide_agree	"Courts are transparent? Agree"
		la var courtwomensame_agree "Courts treat men and women the same? Agree"
		la var courttreatallequal_agree "Courts treat all tribes equally? Agree"
		la var courtcorr_disagree	"Courts are corrupt? Disagree"		
		
	

	// PREFERENCES FOR POLICE FROM COMPLIANCE SECTION OF SURVEY
	
		gen OUTCOMES_PREFERENCES_LNP=.
			la var OUTCOMES_PREFERENCES_LNP "=================================="
			placevar OUTCOMES_PREFERENCES_LNP, f
				
			
		/* Respondents selected as many forums as they deemed appropriate, seperated by a semi-colon */
		/* Here, we delimit by `;', creating as many additional variables for each category as the max number of distinct forums */

		foreach x of varlist burglaryres dviolres arobres murderres mobviolres halahalres {
		
			split `x', parse(;) gen(`x')
			
		}
	
	
		/* now we convert to ordinal numeric */
		
		foreach x of varlist burglaryres1- halahalres4 {
				
				qui tab `x'
				cap rename `x' `x'_
				cap egen `x' = ends (`x'_), punct(-) head
				cap move `x' `x'_
				cap drop `x'_
				cap destring `x', replace
				cap replace `x'=.a if `x'==97

			}
		
		/* and finally we construct our dummy outcome variables */
		
		gen burglaryres_LNP=cond(burglaryres1==1 | burglaryres2==1 | burglaryres3==1 ,1,0)
		gen dviolres_LNP=cond(dviolres1==1 | dviolres2==1 | dviolres3==1,1,0)
		gen arobres_LNP=cond(arobres1==1 | arobres2==1 | arobres3==1  | arobres4==1,1,0)
		gen murderres_LNP=cond(murderres1==1 | murderres2==1 | murderres3==1 | murderres4==1,1,0)
		gen mobviolres_LNP=cond(mobviolres1==1 | mobviolres2==1 | mobviolres3==1,1,0)
		gen halahalres_LNP=cond(halahalres1==1 | halahalres2==1 | halahalres3==1 | halahalres4==1,1,0)
			
		/* drop extraneous variables used just for construction */
		
		drop burglaryres1- halahalres4
	
		/* organize outcomes at top of dataset */

	placevar burglaryres_LNP dviolres_LNP arobres_LNP murderres_LNP mobviolres_LNP halahalres_LNP, after(OUTCOMES_PREFERENCES_LNP)

		la var burglaryres_LNP "Prefer police respond to burglary?"
		la var dviolres_LNP "Prefer police respond to domestic violence?"
		la var arobres_LNP "Prefer police respond to armed robbery?"
		la var murderres_LNP "Prefer police respond to murder?"
		la var mobviolres_LNP "Prefer police respond to mob violence?"
		la var halahalres_LNP "Prefer police respond to inter-ethnic violence?"

	
// SUPPORT FOR TRIAL BY ORDEAL FROM COMPLIANCE SECTION OF SURVEY
	
	gen OUTCOMES_TRIAL_BY_ORDEAL=.
		la var OUTCOMES_TRIAL_BY_ORDEAL "=================================="
		placevar OUTCOMES_TRIAL_BY_ORDEAL, f
	
	foreach x of varlist burglarysasswoodcomm burglarysasswoodself missingsasswoodcomm missingsasswoodself murdersasswoodcomm murdersasswoodself   {
			
			gen `x'_agree=cond(`x'==1,1,0)  if `x'!=.
			
		}
	
	placevar murdersasswoodself_agree missingsasswoodself_agree burglarysasswoodself_agree murdersasswoodcomm_agree missingsasswoodcomm_agree burglarysasswoodcomm_agree, after(OUTCOMES_TRIAL_BY_ORDEAL)

		la var murdersasswoodself_agree "Support trial by ordeal for unsolved murder?"
		la var missingsasswoodself_agree "Support trial by ordeal for missing person?"
		la var burglarysasswoodself_agree "Support trial by ordeal for unsolved burglary?"
		la var murdersasswoodcomm_agree "Community supports trial by ordeal for unsolved murder?"
		la var missingsasswoodcomm_agree "Community supports trial by ordeal for missing person?"
		la var burglarysasswoodcomm_agree "Community supports trial by ordeal for unsolved burglary?"

	 
// CONSTRUCT CRIME OUTCOMES
	
	gen OUTCOMES_CRIME=.
		la var OUTCOMES_CRIME "=================================="
		placevar OUTCOMES_CRIME, f
	
			
	foreach x of varlist dviolnum narobnum nrobnum naattacknum nattacknum rapenum devil2015 sassynum mobviol {
	
		/* per skip order, missing indicate a negative response to "any [crime]", therefore number of [crime] is zero */
		replace `x'=0 if `x'==.
		
		/* cap at 99th pcntl -- about 20 changes made across all vars and all respondents */
		qui sum `x',d
		replace `x'=r(p99) if `x'>r(p99)
	
	}
	
	
	/* Dummy for whether respondent reported a [category] crime against someone they know in their community */
	
	gen armed_assault=cond(naattack==1,1,0) if naattack!=.  
	gen armed_robbery=cond(narob==1,1,0) if narob!=.  
	gen domestic_violence=cond(dviol==1 ,1,0) if dviol!=. 
	gen assault=cond(nattack==1,1,0) if nattack!=.
	gen robbery=cond(nrob==1,1,0) if nrob!=.
		
	/* note: we did not ask about respondent's self rape victimization; so here we only have the survye variable on whether someone they knew in their community was raped */
	
	placevar armed_assault armed_robbery domestic_violence assault robbery rape, after(OUTCOMES_CRIME)
	
	la var armed_assault "Aggravated assault"
	la var armed_robbery "Armed robbery"
	la var domestic_violence "Domestic violence"
	la var assault "Simple assault"
	la var robbery "Theft or burglary"
	la var rape "Rape"		
		
	
	// SECONDARY OUTCOMES

		gen OUTCOMES_SECONDARY=.
			la var OUTCOMES_SECONDARY "=================================="
			placevar OUTCOMES_SECONDARY, f

		replace ebolacases=. if ebolacases==97

		la var ebolacases "# of ppl in town with Ebola"

		placevar ebolacases, after(OUTCOMES_SECONDARY)
			
	
	
	// GENERATE TREATMENT  VARIABLE 
			
		/* Towns with towncodes are CONTROL, odd towncodes are TREATMENT */
		gen cptreat=mod(towncode,2) // remainder division.
		la var cptreat "assigned to treatment"
			
		gen TREATMENT_VARIABLE=.
			la var TREATMENT_VARIABLE "=================================="
			placevar TREATMENT_VARIABLE cptreat, f
		
		
	
saveold "$cp/data/cleandata/endline_survey_leaders_clean.dta", replace





	


