# Replication files for:

> Blair, Robert, Sabrina Karim, and Ben Morse. "Establishing the Rule of Law in Weak and War-Torn States: Evidence from a Field Experiment with the Liberian National Police." (2019).

Publishers version (gated):
https://doi.org/10.1017/S0003055419000121

Ungated pre-print available at:  
https://papers.ssrn.com/sol3/papers.cfm?abstract_id=3095944

## READ ME

The main text of Blair, Karim & Morse (2019) contains three figures and three tables. To reproduce the results for Figures 1-3 and Table 3 of the main text (as well as the results for most of the tables and figures in the Appendix), starting from the raw survey data, run `analysis files\cp_analysis_paper.do`.

To reproduce the results for Tables 1-2 and the tables for Appendix A12 and A13 from the raw data, run: `analysis files\cp_crime_analysis.do`.

### A few things to note:

- Apart from our analysis of official crime records (Appendix A11), our analysis relies on data from an endline survey administered to leaders and citizens. (There was no baseline survey, though we show pretreatment balance on town-level variables from the census (Appendix A7)).

- As you'll see when you open `cp_analysis_paper.do`, which runs the cleaning files before proceeding with the main analysis, our data processing and analysis proceeds in four steps:
  - Clean endline data from citizens (`cleaning files\endline_clean.do`)
  - Clean endline data from leaders (`cleaning files\endline_clean_leaders.do`)
  - Append clean citizen and leader data, merge administrative data from census (`cleaning files\endline_merge.do`)
  - Conduct analysis (`analysis files\cp_analysis_paper.do`)

- `cp_crime_analysis.do` analyzes a "crime-level" dataset constructed from citizens' reports of crimes in their communities to produce results for Tables 1-2 and Appendix 12 and 13. Again, the file calls up cleaning files, and the whole process is the same as above, plus a step for reshaping respondent-level survey data from wide to long to create a crime-level dataset:
  - Clean endline data from citizens
  - Clean endline data from leaders
  - Append clean citizen and leader data, merge admin data from census
  - Reshape data from wide to long, to create a crime-level dataset with 18 observations for each individual (1 for each type of crime) along with indicators for whether the crime occurred, whether it was reported, and other outcomes. (`cleaning files\crime_reshape.do`)
  - Conduct analysis (`analysis files\cp_crime_analysis_paper.do`)

- For the figures, we produce the underlying results in Stata, then outsheet the coefficients and standard errors as a `.csv` for plotting in R (see `analysis files\construct_figures.r`).

- Questions? Email: benjaminsmorse@gmail.com

## A more detailed breakdown of the contents of this replication package is as follows:

### `Replication_files\rawdata\` contains three files:
- `endline_survey_raw.dta`: raw survey data for citizens
- `endline_survey_raw_leaders`: raw survey data for leaders
- `CWF_Donations_Data`: raw data of respondents donations to the Community Watch Team/Forum

### `Replication_files\admindata\` contains two files:
- `final_sample_randomization_wtowncode_wlisgis.csv`: town-level census data and town-level data on assignment to treatment and randomization stratum
- `PatrolLog.csv`: dates of each patrol in each treatment community

### `Replication_files\cleaning files\` contains four files:
- `endline_clean.do`: cleaning file to insheet raw citizen survey data, construct outcome and control variables, and save the resulting dataset as `Replication_files\data\cleandata\endline_survey_clean.dta`
- `endline_clean_leaders.do`: cleaning file to insheet the raw leaders survey data, construct outcome and control variables, and save the resulting dataset as `Replication_files\data\cleandata\endline_survey_leaders_clean.dta`
- `endline_merge.do`: cleaning file to append `endline_survey_clean.dta` and `endline_survey_leaders_clean.dta`, merge in admin data and save the resulting dataset as `Replication_files\data\cleandata\endline_analysis.dta`
- `crime_reshape.do`: cleaning file to append `endline_survey_clean.dta` and `endline_survey_leaders_clean.dta`, merge admin data, and reshape the data from wide to long to create a crime-level dataset, construct crime reporting outcomes, and save the resulting data as `Replication_files\data\cleandata\crime_level_analysis.dta`

### `Replication_files\analysis files` contains two files:
- `cp_analysis_paper.do`: replicates Figures 1-3, Table 3 and most tables and figures in the Appendix, starting from the raw data; outputs results (coefficients and standard errors) to: `Figure1_AverageEffects.csv`, `Figure2_ATE_crime.csv`, and `Figure3_Heteffects.csv` for plotting in R via `construct_figures.r`
- `cp_crime_analysis.do`: replicates Tables 1-2, and Appendix A12 and A13, starting from the raw data
- `construct_figures.R`: constructs Figures 1-3 using `Figure1_AverageEffects.csv`, `Figure2_ATE_crime.csv`, and `Figure3_Heteffects.csv`, which are outputted from `cp_analysis_paper.do`

### `Replication_files\output` contains six files:
- `Figure1.pdf`: PDF of Figure 1
- `Figure1_AverageEffects.csv`: results for Figure 1 outputted from `cp_analysis_paper.do`. These results need to be manually reformatted following instructions in `construct_figures.r` before they can be plotted
- `Figure1_AverageEffects_plot.csv`: results reformatted for plotting Figure 1, following instructions in `construct_figures.r`
- `Figure2.pdf`: PDF of Figure 2
- `Figure2_ATE_crime.csv`: results for Figure 2 outputted from `cp_analysis_paper.do`. These results need to be manually reformatted following instructions in `construct_figures.r` before they can be plotted
- `Figure2_ATE_crime_plot.csv`: results reformatted for plotting Figure 2, following instructions in `construct_figures.r`
- `Figure3.pdf`: PDF of Figure 3
- `Figure3_Heteffects.csv`: results for Figure 3 outputted from `cp_analysis_paper.do`. These results need to be manually reformatted following instructions in `construct_figures.r` before they can be plotted
- `Figure3_Heteffects_plot.csv`: results reformatted for plotting Figure 3, following instructions in `construct_figures.r`
- `Table1.tex`, `Table2.tex`, and `Table3.tex`: Tables 1-3 of main paper, respectively.
