/***************************************************************************
*	Title: endline_clean.do
*	Purpose: clean raw endline survey data from citizens
*	Inputs:  endline_survey_raw.dta 
*	Output:  endline_survey_clean.dta
****************************************************************************/


version 10.0
clear


// Set directories and open rawdata 

	// Location of data
	
		*gl cp "INSERT YOUR WORKING DIRECTORY HERE"
	
		use "$cp/data/rawdata/endline_survey_raw.dta",clear
	

/********************************	
// CLEAN DATA
********************************/


	// DROP VARIABLES NOT RELEVANT TO EVALUATION

	drop  BACKGROUND FOREIGN_AID-moeresourcev2 recordid unitid GENDER_POLICE-whoprotectrape	 psuothersscared cpdatecorrect CONCLUSION willshare distractions angry  emotional concend
		
	// CONVERT STRINGS TO NUMERIC (ORDINAL DATA) 

	gl demo gender educ religion occupation wallmat roofmat tribe
	gl land hssecure hsimprove2015 hsdisp hsdispres fplotsecure fpnewirrig fpfallow2015 fpfallow2016 fpdisp fpdispres fpdispldrsatis fpdisppolsatis fpdispcourtsatis hsdispldrsatis hsdisppolsatis hsdispcourtsatis
	gl knowledge cwfbeat bushbodysuspect habeascorpus chiefdisp sassywood	
	gl perceptions polcasepaysmall - taxauthoritypay
	gl compliance burglarypolvex dviolpolvex burglarysasswoodcomm burglarysasswoodself missingsasswoodcomm missingsasswoodself murdersasswoodcomm murdersasswoodself ldrcaseobey ldrfambizzobey  ldrdecidepol
	gl cwf_pol  cwforumdonate cwfrogues cwflazy cwfmobviol cwfkeepsecure
	gl tax commmeet refusetopay citizenspaytax avoidpaytax democracyliberia
	gl ebola tcomm hwprotest ngoprotest erealj26 eliej26 ereportcasesj26 ebolaconspiracy ebolasatisfied  vote2011who
	gl war displaced wararmed warbeatwitness warbeat warkill wardestroy
	gl crime physicalabusethreat arobldrsatis arobpolsatis arobcourtsatis robldrsatis robpolsatis robcourtsatis  aattackldrsatis aattackpolsatis aattackcourtsatis attackldrsatis attackpolsatis  abuseldrsatis abusepolsatis abusecourtsatis dviolldrsatis dviolpolsatis dviolcourtsatis narobldrsatis narobpolsatis narobcourtsatis nrobldrsatis nrobpolsatis nrobcourtsatis naattackldrsatis naattackpolsatis naattackcourtsatis nattackldrsatis nattackpolsatis nattackcourtsatis rapeldrsatis rapepolsatis rapecourtsatis

	
	foreach x of varlist  $demo $land $knowledge $perceptions $compliance $cwf_pol /* $endorse*/ $tax $ebola $war $crime /* $gender_and_war $gender_police */ /* $aid_perceptions*/ /*$surveyexp */ {
			
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

	gl demo_yn phone readnews society 
	gl land_yn  hsdispthreat hsdispdestr fpdispthreat fpdispdestr
	gl knowledge_yn polstation polnumber knowhub knowhubwhere visithub 
	gl cwf_pol_yn paypolice witphypolabuse witverbpolabuse polcomplainpunish cwforum cwfmember
	gl crime_yn missing rape arob rob aattack attack abuse verbalabuse dviol narob nrob naattack nattack
	gl tax_yn refusetopaychance  
	gl patrols_yn psu psumeeting vote2011  psuscared  psuscarednow  
		
	foreach x of varlist $demo_yn $land_yn $knowledge_yn $cwf_pol_yn $crime_yn $tax_yn $patrols_yn /* $aid_exposure_yn*/  {
	
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
	label define religion 1 "Christian" 2 "Muslim" 3 "Other"
	label define frequency 1 "Everyday" 2 "Weekly" 3 "Monthly" 4 "Not too often"
	label define yesnodkrta 0 "No" 1 "Yes" .a "Don't know" .b "Refuse to answer"
	label define agreedisagree3point 0 "Strongly disagree" 1 "Disagree" 2 "Agree" 3 "Strongly agree" .a "Do not know " .b "Refuse to answer"
	label define extent 0 "Not at all" 1 "Just a little" 2 "Somewhat" 3 "A lot" .a "Don't know" .b "Refuse to answer"
	label define agreedisagree 0 "Disagree" 1 "Agree" .a "Don't know" .b "Refuse to answer"
	label define whorules 1 "Govt" 2 "NGOs" 3 "UNMIL" 4 "Community Leaders" 5 "Traditional Leaders" 6 "Community residents" 88 "Other"
	label define ability 0 "Very bad" 1 "Bad" 2 "Good" 3 "Very good"
	label define occupations 0 "None" 1 "Petty business" 2 "Buying and selling" 3 "Mining" 4 "Rubber tapping" 5 "Hunting" 6 "Road work" 8 "Daily hire" 9 "Peim peim" 10 "Making farm" 11 "Skilled trade" 12 "Office work" 13 "Hustling" 14 "Other" 88 "Other"
	label define actor 1 "Anti government rebel group" 2 "LNP" 3 "Criminals" 4 "Traditional or village leaders" 5 "No one" 6 "Other" .a "Do not know " .b "Refuse to answer"
	label define respond 1 "Female LNP" 2 "Male LNP " 3 "Female traditional leader " 4 "Male traditional leader " .a "Do not know " .b "Refuse to answer"
	label define tribe 1 "Bassa" 2 "Gbandi" 3 "Belle" 4 "Gbei" 5 "Gio" 6 "Gola" 7 "Grebo" 8 "Kissi" 9 "Kpelle" 10 "Krahn" 11 "Kru" 12 "Lorma" 13 "Mandingo" 14 "Mano" 15 "Mende" 16 "Vai" 17 "Congo" 18 "Fula" 19 "Other"
	
	la values occupation occupations
	la values tribe tribe
	la values gender gender
	la values educ educ
	la values religion religion
	la values polcasepaysmall - taxauthoritypay agreedisagree3point


	
	
/*************************************	
//  CONSTRUCT CONTROL VARIABLES 
**************************************/
		
	gen COVARIATES=.
		la var COVARIATES "===================================="
	placevar COVARIATES, f
		
	
	// CONTROL VARIABLES FROM DEMOGRAPHICS SECTION
			
		la var hhsize "household size"
				
		
		gen female=cond(gender==2,1,0) if gender!=.
		gen wall_cement=cond(wallmat==4,1,0)
		gen roof_zinc=cond(roofmat==4,1,0)
		egen house_qual=rowtotal(wall_cement roof_zinc)
			drop wall_cement roof_zinc
		
		gen rel_Christian=cond(religion==1,1,0)
		gen rel_Muslim=cond(religion==2,1,0)
		gen rel_other=cond(religion==3,1,0)

		gen educ_none=cond(educ==0,1,0)
		gen educ_abc=cond(educ==1 | educ==2,1,0)
		gen educ_jh=cond(educ==3 | educ==4,1,0)
		gen educ_hs=cond(educ>=5 & educ!=.,1,0)
	
		gen kpelle=cond(tribe==9,1,0)
		gen lorma=cond(tribe==12,1,0)
		
		/* create dummies denoting whether respondent is a leader, and if so, what type.*/
		/* this is the citizen survey, so no one is a leader. but data will later be merged with data from leader survey */
		
		gen leader=0
		gen lead_chief=0
		gen lead_women=0
		gen lead_youth=0
		gen lead_elder=0
			

		/* defining minority as dummy for any non-modal tribe */
		
		bys towncode: egen majortribe=mode(tribe)
			gen minority=cond(tribe!=majortribe,1,0) // assumes minority=0 if tribe missing
			drop majortribe

		replace age=18 if age==8
	
		*gen over_30=(age>=30) if age!=.	
		gen youth=cond(age<=35,1,0) & age!=.	
		gen readnews_dum=cond(readnews==1,1,0)		
		gen elder=cond(age>45,1,0) if age!=.
		
		gen age1825=cond(age<25,1,0)
		gen age2635=cond(25<age & age<36,1,0)
		gen age3645=cond(35<age & age<46,1,0)
		gen age4655=cond(45<age & age<56,1,0)
		gen age5665=cond(55<age & age<66,1,0)
		gen age65=cond(65<age,1,0)

		placevar female - age65 , after(COVARIATES)
	
		la var female "Female"
		la var minority "Minority in town"
		la var educ_none "No education"
		la var educ_abc "Primary school education"
		la var educ_jh "Middle school education"
		la var house_qual "HH quality index"
		la var educ_hs "High school or greater education"
		la var readnews_dum "Literate"
		la var kpelle "Kpelle ethnicity"
		la var lorma "Lorma ethnicity"
		la var leader "1 if town leader of any type"
		la var lead_chief "1 if town chief"
		la var lead_women "1 if womens leader"
		la var lead_youth "1 if youth leader"
		la var lead_elder "1 if town elder"
		la var age1825 "18-25 years old"
		la var age2635 "26-35 years old"
		la var age3645 "36-45 years old"
		la var age4655 "46-55 years old"
		la var age5665 "56-65 years old"
		la var age65 "65+ years old"
		la var rel_Christian "Christian"
		la var rel_Muslim "Muslim"
		la var rel_other "Other religion"
		la var youth "Under 35 years old"
		la var elder "Over 45 years old"
		

	/* Some covariates are missing. To avoid dropping observations, we impute these with median value if missing */
	/* 45 changes made total across all vars all respondents */
		
		foreach x of varlist female minority age hhsize rel_Christian educ_abc educ_jh educ_hs readnews_dum {
		
			qui sum `x', d
			replace `x'=`r(p50)' if `x'==.
		}



		
/*************************************	
//  CONSTRUCT OUTCOME VARIABLES ***** 
**************************************/

		
	// SECURITY OF PROPERTY RIGHTS  FROM LAND SECTION OF SURVEY
		
	gen OUTCOMES_PROPERTYRIGHTS=.
		la var OUTCOMES_PROPERTYRIGHTS "=================================="
		placevar OUTCOMES_PROPERTYRIGHTS, f
			
			
	gen hssecure_sure=cond(hssecure==2 | hssecure==3,1,0) if hssecure!=.
		la var hssecure_sure "House property is secure?"
	
	gen fplotsecure_sure=cond(fplotsecure==2 | fplotsecure==3,1,0) if fplotsecure!=.
		la var fplotsecure_sure "Farm property is secure?"
	
	recode hsdisp fpdisp (0=1) (1=0), pre(rec_)	
		la var rec_hsdisp "Did not have housespot land dispute past year"
		la var rec_fpdisp "Did not have farm land dispute past year"
		placevar hssecure_sure hsimprove2015  fplotsecure_sure fpnewirrig fpfallow2015 fpfallow2016 rec_hsdisp rec_fpdisp, after (OUTCOMES_PROPERTYRIGHTS)

		la var hssecure_sure "House property is secure?"
		la var hsimprove2015 "Made improvements to your house property in past 12 months?"
		la var fplotsecure "Farm plot secure?"
		la var fpnewirrig "Made major improvements to farm in past 12 months?"
		la var fpfallow2015 "Left farm fallow in 2015?"
		la var fpfallow2016 "Plan to leave farm fallow in 2016?"
		la var rec_hsdisp  "No disputes over house land in past year"
		la var rec_fpdisp "No disputes over farm land in past year"	
	
	// KNOWLEDGE OF POLICE FROM KNOWLEDGE SECTION OF SURVEY
	
		gen OUTCOMES_KNOWLEDGE_POLICE=.
		la var OUTCOMES_KNOWLEDGE_POLICE "=================================="
		placevar OUTCOMES_KNOWLEDGE_POLICE, f

	
		/* respondents who don't know about the hub can't know where it is */ 
			replace knowhubwhere=0 if knowhub==0

			gen knowhubdoes=.
			la var knowhubdoes "knows what hub does"
				/* respondents who know about the hub and can mention at least one thing it does coded as 1 */
				replace knowhubdoes=1 if knowhub==1 & hubdoes!="" & hubdoes!="97-Do not know"
				/* respondents who either do not know about the hub or don't know what it does coded as 0 */
				replace knowhubdoes=0 if knowhub==0 | hubdoes=="" | hubdoes=="97-Do not know"

		placevar polstation polnumber knowhub knowhubwhere knowhubdoes, after(OUTCOMES_KNOWLEDGE_POLICE)

			la var polstation "Knows location of nearest police station"
			la var polnumber "Knows number of any police officer"
			la var knowhub "Knows about the Hub"
			la var knowhubwhere "Knows where the Hub is located"
			la var knowhubdoes "Knows what the Hub does"		
		
	
	// KNOWLEDGE OF THE LAW FROM KNOWLEDGE SECTION OF SURVEY
	
		gen OUTCOMES_KNOWLEDGE_LAW=.
		la var OUTCOMES_KNOWLEDGE_LAW "=================================="
		placevar OUTCOMES_KNOWLEDGE_LAW, f

		/* Dummies for correct answers to law questions */
		
		gen cwfbeat_correct=(cwfbeat==0) 
		gen bushbodysuspect_correct=(bushbodysuspect==0) 
		gen habeascorpus_correct=(habeascorpus==1) 
		gen chiefdisp_correct=(chiefdisp==0) 
		gen sassywood_correct=(sassywood==0) 
		
		placevar cwfbeat_correct bushbodysuspect_correct habeascorpus_correct chiefdisp_correct sassywood_correct, after(OUTCOMES_KNOWLEDGE_LAW)

			la var cwfbeat_correct "Knows Town Watch Team cannot beat suspects"
			la var bushbodysuspect_correct "Knows law protects informants"
			la var habeascorpus_correct "Knows about Habeas Corpus"
			la var chiefdisp_correct "Knows that formal law trumps customary law"
			la var sassywood_correct "Knows trial by ordeal is illegal"			
	
	
		/* Create dummies for true responses (used for descriptives statistics reported in appendix) */
		foreach x of varlist cwfbeat bushbodysuspect habeascorpus chiefdisp sassywood  {
				
				gen `x'_true=cond(`x'==1,1,0)  if `x'!=.
				placevar `x'_true, after(sassywood)
				
			}
		
	
	// PERCEPTIONS OF POLICE OUTCOMES FROM PERCEPTIONS SECTION OF SURVEY
	
	
		gen OUTCOMES_PERCEPTIONS_POLICE=.
		la var OUTCOMES_PERCEPTIONS_POLICE "=================================="
		placevar OUTCOMES_PERCEPTIONS_POLICE, f

	
		foreach x of varlist $perceptions  {
				
				gen `x'_agree=cond(`x'==2 | `x'==3,1,0) if `x'!=.
				gen `x'_disagree=cond(`x'==0 | `x'==1,1,0)  if `x'!=.
				placevar `x'_agree `x'_disagree, after(taxauthoritypay)
				
			}
	
	
	placevar polcasepaysmall_disagree polcaseserious_agree polcasefreecriminal_disagree polcasesatis_agree polsusverbabuse_disagree polsusphsyabuse_disagree polsuspaysmall_disagree polcorr_disagree polttreatallequal_agree polwomensame_agree, after (OUTCOMES_PERCEPTIONS)
	
	
		la var polcasepaysmall_disagree "Police will make you pay a bribe? Disagree"
		la var polcasepaysmall_agree "Police will make you pay a bribe? Agree"
		la var polcaseserious_agree "Police take cases seriously? Agree"
		la var polcaseserious_disagree "Police take cases seriously? Disagree"
		la var polcasefreecriminal_disagree "Police will free a criminal for a bribe? Disagree"
		la var polcasefreecriminal_agree "Police will free a criminal for a bribe? Agree"
		la var polcasesatis_agree "Victims who report will be satisfied with police? Agree"
		la var polcasesatis_disagree "Victims who report will be satisfied with police? Disagree"
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
		
		foreach x of varlist burglaryres1- halahalres5 {
				
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
		gen arobres_LNP=cond(arobres1==1 | arobres2==1 | arobres3==1  | arobres4==1  | arobres5==1,1,0)
		gen murderres_LNP=cond(murderres1==1 | murderres2==1 | murderres3==1 | murderres4==1,1,0)
		gen mobviolres_LNP=cond(mobviolres1==1 | mobviolres2==1 | mobviolres3==1,1,0)
		gen halahalres_LNP=cond(halahalres1==1 | halahalres2==1 | halahalres3==1 | halahalres4==1 | halahalres5==1,1,0)
			
		/* drop extraneous variables used just for construction */
		
		drop burglaryres1- halahalres5
	
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
			placevar `x'_agree, after(ldrdecidepol)
			
		}
	
	placevar murdersasswoodself_agree missingsasswoodself_agree burglarysasswoodself_agree murdersasswoodcomm_agree missingsasswoodcomm_agree burglarysasswoodcomm_agree, after(OUTCOMES_TRIAL_BY_ORDEAL)

		la var murdersasswoodself_agree "Support trial by ordeal for unsolved murder?"
		la var missingsasswoodself_agree "Support trial by ordeal for missing person?"
		la var burglarysasswoodself_agree "Support trial by ordeal for unsolved burglary?"
		la var murdersasswoodcomm_agree "Community supports trial by ordeal for unsolved murder?"
		la var missingsasswoodcomm_agree "Community supports trial by ordeal for missing person?"
		la var burglarysasswoodcomm_agree "Community supports trial by ordeal for unsolved burglary?"

	

// SOCIAL SANCTIONS FOR REPORTING CRIMES OUTCOMES
	
	gen OUTCOMES_SOCIAL_SANCTIONS=.
		la var OUTCOMES_SOCIAL_SANCTIONS "=================================="
		placevar OUTCOMES_SOCIAL_SANCTIONS, f
	
	foreach x of varlist burglarypolvex dviolpolvex  {
			
			gen `x'_agree=cond(`x'==2 | `x'==3,1,0) if `x'!=.
			
		}

	gen devil2015_any=(devil2015>0 & devil2015!=.)
		
	placevar burglarypolvex_agree dviolpolvex_agree devil2015_any, after(OUTCOMES_SOCIAL_SANCTIONS)
	la var burglarypolvex_agree "People get angry for reporting burglary to police?"
	la var dviolpolvex_agree "People get angry for reporting domestiv violence to police?"
	la var devil2015_any "Any devil showing in 2015?"
	
				
// CONSTRUCT CRIME OUTCOMES
	
	gen OUTCOMES_CRIME=.
		la var OUTCOMES_CRIME "=================================="
		placevar OUTCOMES_CRIME, f
			
	/* in a few (7) instances, skip order problems resulted in situations where number of [crime]_num>0 but [crime]_any=. or 0. Replacing [crime]_num with 1 in these instances */
	
	foreach x of varlist arob rob aattack attack abuse dviol nrob naattack nattack {
	
		replace `x'=1 if `x'==0 & `x'num>0 & `x'num!=.	
	
	}
	

	/* Dummy for whether respondent reported a [category] crime, whether against him/herself or against someone they know in their community */
	
	gen armed_assault=cond(naattack==1 | aattack==1,1,0) if naattack!=. | aattack!=.
	gen armed_robbery=cond(narob==1 | arob==1,1,0) if narob!=. | arob!=.
	gen domestic_violence=cond(abuse==1 | dviol==1,1,0) if abuse!=. | dviol!=.
	gen domestic_abuse=cond(verbalabuse==1 | physicalabusethreat==1,1,0) if verbalabuse!=. | physicalabusethreat!=.
	gen assault=cond(attack==1 | nattack==1,1,0) if attack!=. | nattack!=.
	gen robbery=cond(nrob==1 | rob==1,1,0) if nrob!=. | rob!=.
		
	/* note: we did not ask about respondent's self rape victimization; so here we only have the survye variable on whether someone they knew in their community was raped */
	
	placevar armed_assault armed_robbery domestic_violence domestic_abuse assault robbery rape, after(OUTCOMES_CRIME)
	
	la var armed_assault "Aggravated assault"
	la var armed_robbery "Armed robbery"
	la var domestic_violence "Domestic violence"
	la var domestic_abuse "Domestic abuse"
	la var assault "Simple assault"
	la var robbery "Theft or burglary"
	la var rape "Rape"		
	
	
	// SECONDARY OUTCOMES

		gen OUTCOMES_SECONDARY=.
			la var OUTCOMES_SECONDARY "=================================="
			placevar OUTCOMES_SECONDARY, f

		replace ebolacases=. if ebolacases==97

		la var ebolacases "# of ppl in town with Ebola"
		la var taxauthoritypay_agree "Government has right to make ppl pay taxes"

		placevar ebolacases taxauthoritypay_agree, after(OUTCOMES_SECONDARY)
			


	// WAR TIME EXPERIENCES (FOR HETEROGENEITY ANALYSIS IN APPENDIX)

		
		/* war violence victimization index */
		egen war_viol=rowtotal(warbeatwitness warbeat warkill wardestroy), missing
				
		/* we're interested in whether this victimization was at the hand of government or rebels */
		/* here, we delimit multiple selection questions on the perpetrators before constructing indices for number of acts of victimization by each rebel group */
		foreach x of varlist warbeatwitnesswho warbeatwho warkillwho wardestroywho {
		
			split `x', parse(;) gen(`x')
			
		}
		
		foreach x of varlist warbeatwitnesswho1-wardestroywho4 {
				
			tab `x',gen(`x')

		}
		
		egen war_viol_skd=rowtotal(warbeatwitnesswho11 warbeatwho11 warkillwho11 wardestroywho11)	
		egen war_viol_npfl=rowtotal(warbeatwho13 warbeatwho22 warbeatwho31 warkillwho13 warkillwho22 warkillwho31 wardestroywho13 wardestroywho22 wardestroywho31)	
		egen war_viol_tgovt=rowtotal(warbeatwho12 warbeatwho21 warkillwho12 warkillwho21 wardestroywho12 wardestroywho21)	
		egen war_viol_otherrebel=rowtotal(warbeatwho14 warbeatwho23 warbeatwho32 warbeatwho41 warkillwho14 warkillwho23 warkillwho32 warkillwho41 wardestroywho14 wardestroywho23 wardestroywho32 wardestroywho41)	
		
		egen war_viol_rebel=rowtotal(war_viol_npfl war_viol_otherrebel )	
		egen war_viol_govt=rowtotal(war_viol_tgovt war_viol_skd )	
			drop war_viol_skd war_viol_npfl war_viol_tgovt war_viol_otherrebel war*who*
		
		placevar war_viol war_viol_rebel war_viol_govt, after(age65)
	
		la var war_viol "Index of wartime violence experienced"
		la var war_viol_rebel "Index of wartime rebel violence experienced"
		la var war_viol_govt "Index of wartime government violence experienced"
	
	/* drop 76 dud surveys */
	
	drop if age==. & polnumber==.
	
	/* Miscellaneous labeling of variables */

la var polcasepaysmall_disagree "Police will make you pay a bribe? Disagree"
la var polcasepaysmall_agree "Police will make you pay a bribe? Agree"
la var polcaseserious_agree "Police take cases seriously? Agree"
la var polcaseserious_disagree "Police take cases seriously? Disagree"
la var polcasefreecriminal_disagree "Police will free a criminal for a bribe? Disagree"
la var polcasefreecriminal_agree "Police will free a criminal for a bribe? Agree"
la var polcasesatis_agree "Victims who report will be satisfied with police? Agree"
la var polcasesatis_disagree "Victims who report will be satisfied with police? Disagree"
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


la var cwfbeat_true "Law allows town to beat a criminal?"
la var bushbodysuspect_true "Law requires reporting suspicious dead bodies?"
la var habeascorpus_true "Law requires habeas corpus?"
la var chiefdisp_true "Law proscribes taking case to police if chief disagrees?"
la var sassywood_true "Law allows trial by ordeal?"	

la var leadcorr_agree    "Town leader is corrupt? Agree"
la var ldrtreatallequal_agree "Town leader treats all tribes the same? Agree"
la var ldrwomensame_agree "Town leader treats men and women equally? Agree"
la var govtcorr_agree "Government is corrupt? Disagree"
la var govttreatallequal_agree "Government treats all tribes equally? Agree"
la var govtdecopen_agree "Government open and transparent? Agree"
la var govtcorr_disagree "Govt is corrupt? Disagree"
	
	
		

	// GENERATE TREATMENT  VARIABLE 
			
		/* Towns with towncodes are CONTROL, odd towncodes are TREATMENT */
		gen cptreat=mod(towncode,2) // remainder division.
		la var cptreat "assigned to treatment"
			
		gen TREATMENT_VARIABLE=.
			la var TREATMENT_VARIABLE "=================================="
			placevar TREATMENT_VARIABLE cptreat, f
		
		
saveold "$cp/data/cleandata/endline_survey_clean.dta",  replace





	


