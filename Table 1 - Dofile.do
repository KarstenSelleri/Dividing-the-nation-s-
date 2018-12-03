**********************************************************************************
************************************  RECODINGS   ********************************
**********************************************************************************

*MERGE DATE

joinby Year country using "/Users/Karsten/Desktop/Projekter/2. Structural Conditions/Analysis/NEW ANALYSIS/Eurostat_inequality.dta", unmatched(none)
joinby Year country using "/Users/Karsten/Desktop/Projekter/2. Structural Conditions/Analysis/NEW ANALYSIS/Structural data.dta", unmatched(none)


destring EUROSTAT_Quintile_ratio EUROSTAT_Gini EUROSTAT_Quintile_ratio_dev_pct EUROSTAT_Gini_dev_pct EUROSTAT_Quintile_ratio_dev_poin EUROSTAT_Gini_dev_point, replace

gen X_LEFT_QUANT_DEV_point=EUROSTAT_Quintile_ratio_dev_poin*LR_LEFT_WING
gen X_LEFT_GINI_DEV_point=EUROSTAT_Gini_dev_point*LR_LEFT_WING
gen X_RIGHT_QUANT_DEV_point=EUROSTAT_Quintile_ratio_dev_poin*LR_RIGHT_WING
gen X_RIGHT_GINI_DEV_point=EUROSTAT_Gini_dev_point*LR_RIGHT_WING

gen QUINT2=.
replace QUINT2=1 if EUROSTAT_Quintile_ratio<=4.4
replace QUINT2=2 if EUROSTAT_Quintile_ratio>=4.5
label define QUINT2 1"Low inequality" 2"High inequality", replace
label values QUINT2 QUINT2

gen QUINT3=.
replace QUINT3=1 if EUROSTAT_Quintile_ratio<=3.9
replace QUINT3=2 if EUROSTAT_Quintile_ratio<=5.3 & EUROSTAT_Quintile_ratio>=4.0
replace QUINT3=3 if EUROSTAT_Quintile_ratio>=5.4
label define QUINT3 1"Low inequality" 2"Medium inequality" 3"High inequality", replace
label values QUINT3 QUINT3

gen GINI2=.
replace GINI2=1 if EUROSTAT_Gini<=29.3
replace GINI2=2 if EUROSTAT_Gini>=29.4
replace GINI2=. if EUROSTAT_Gini==.
label define GINI2 1"Low inequality" 2"High inequality", replace
label values GINI2 GINI2

gen GINI3=.
replace GINI3=1 if EUROSTAT_Gini<=26.8
replace GINI3=2 if EUROSTAT_Gini>=26.9 & EUROSTAT_Gini<=31.9
replace GINI3=3 if EUROSTAT_Gini>=32
replace GINI3=. if EUROSTAT_Gini==.
label define GINI3 1"Low inequality" 2"Medium inequality" 3"High inequality", replace
label values GINI3 GINI3

******************************************************************************************
************************************ ANALYSIS ********************************************
******************************************************************************************
*Model 0
xi: xtmelogit EUsupport if nomiss==1 || GROUP_country_date:, var
predict scorehat_Model_0, xb
estimates store Model_0
*Model 1 - Level of inequality
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING EUROSTAT_Gini Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 Exceldate if nomiss==1 || GROUP_country_date:, var
predict scorehat_Model_1, xb
estimates store Model_1
lrtest Model_0 Model_1
*Model 1b - Changes in inequality [NOT INCLUDED]
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING EUROSTAT_Gini_dev_point Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 Exceldate if nomiss==1 || GROUP_country_date:, var
predict scorehat_Model_1b, xb
estimates store Model_1b
*Model 2 - Level and changes in inequality
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING EUROSTAT_Gini EUROSTAT_Gini_dev_point Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 Exceldate if nomiss==1 || GROUP_country_date:, var
predict scorehat_Model_2, xb
estimates store Model_2
lrtest Model_1 Model_2
*Model 3 - Level and changes in inequality ( + INTERACTION)
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING EUROSTAT_Gini EUROSTAT_Gini_dev_point X_LEFT_GINI_DEV_point X_RIGHT_GINI_DEV_point Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 Exceldate if nomiss==1 || GROUP_country_date:, var
estimates store Model_3
predict scorehat_Model_3, xb
lrtest Model_1 Model_3
lrtest Model_2 Model_3
twoway (lfitci scorehat_Model_3 EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_LEFT_WING==1 ) ///
(lfitci scorehat_Model_3 EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_MODERATE==1) ///
(lfitci scorehat_Model_3 EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_RIGHT_WING==1) if EUROSTAT_Gini_dev_point>=-5, by(GINI3, row(1)) legend(label(1 "95% CI") label(2 "Left-wing") label(3 "Center") label(4 "Right-wing")) ysize(5) xsize(10) ytitle("Predicted effect on EU support")
*Model 4 - Level and changes in inequality ( + INTERACTION & RANDOM EFFECTS)
gen X_LEFT_Gini=EUROSTAT_Gini*LR_LEFT_WING
gen X_RIGHT_Gini=EUROSTAT_Gini*LR_RIGHT_WING
gen X_GINI_GINIdev=EUROSTAT_Gini*EUROSTAT_Gini_dev_point
gen XX_LEFT_GINI_GINIdev=LR_LEFT_WING*EUROSTAT_Gini*EUROSTAT_Gini_dev_point
gen XX_RIGHT_GINI_GINIdev=LR_RIGHT_WING*EUROSTAT_Gini*EUROSTAT_Gini_dev_point
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING EUROSTAT_Gini EUROSTAT_Gini_dev_point X_LEFT_GINI_DEV_point X_RIGHT_GINI_DEV_point X_LEFT_Gini X_RIGHT_Gini X_GINI_GINIdev XX_LEFT_GINI_GINIdev XX_RIGHT_GINI_GINIdev Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 Exceldate if nomiss==1 || GROUP_country_date:, var
estimates store Model_4
predict scorehat_Model_4, xb
lrtest Model_1 Model_4
lrtest Model_2 Model_4
lrtest Model_3 Model_4
twoway (lfitci scorehat_Model_4 EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_LEFT_WING==1 ) ///
(lfitci scorehat_Model_4 EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_MODERATE==1) ///
(lfitci scorehat_Model_4 EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_RIGHT_WING==1) if EUROSTAT_Gini_dev_point>=-5, by(GINI3, row(1)) legend(label(1 "95% CI") label(2 "Left-wing") label(3 "Center") label(4 "Right-wing")) ysize(5) xsize(10) ytitle("Predicted effect on EU support")
twoway (lfitci scorehat_Model_4 EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_LEFT_WING==1 ) ///
(lfitci scorehat_Model_4 EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_MODERATE==1) ///
(lfitci scorehat_Model_4 EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_RIGHT_WING==1) if EUROSTAT_Gini_dev_point>=-5, by(GINI2, row(1)) legend(label(1 "95% CI") label(2 "Left-wing") label(3 "Center") label(4 "Right-wing")) ysize(5) xsize(10) ytitle("Predicted effect on EU support")

*********************************************************************
************************** ROBUSTNESS TEST **************************
*********************************************************************
*1. 20/80 ratio as inequality measure
*Model 1 - Level of inequality
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING EUROSTAT_Quintile_ratio Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 Exceldate if nomiss==1 || GROUP_country_date:, var
predict scorehat_Model_1x, xb
estimates store Model_1x
*Model 2 - Level and changes in inequality
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING  EUROSTAT_Quintile_ratio EUROSTAT_Quintile_ratio_dev_poin Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 Exceldate if nomiss==1 || GROUP_country_date:, var
predict scorehat_Model_2x, xb
estimates store Model_2x
lrtest Model_1x Model_2x
*Model 3 - Level and changes in inequality ( + INTERACTION)
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING EUROSTAT_Quintile_ratio EUROSTAT_Quintile_ratio_dev_poin X_LEFT_QUANT_DEV X_RIGHT_QUANT_DEV Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 Exceldate if nomiss==1 || GROUP_country_date:, var
estimates store Model_3x
predict scorehat_Model_3x, xb
lrtest Model_1x Model_3x
lrtest Model_2x Model_3x
twoway (lfitci scorehat_Model_3x EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_LEFT_WING==1 ) ///
(lfitci scorehat_Model_3x EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_MODERATE==1) ///
(lfitci scorehat_Model_3x EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_RIGHT_WING==1) if EUROSTAT_Gini_dev_point>=-5, by(GINI3, row(1)) legend(label(1 "95% CI") label(2 "Left-wing") label(3 "Center") label(4 "Right-wing")) ysize(5) xsize(10) ytitle("Predicted effect on EU support")
*Model 4 - Level and changes in inequality ( + INTERACTION & RANDOM EFFECTS)
gen X_LEFT_QUINT=EUROSTAT_Quintile_ratio*LR_LEFT_WING
gen X_RIGHT_QUINT=EUROSTAT_Quintile_ratio*LR_RIGHT_WING
gen X_QUINT_QUINTdev=EUROSTAT_Quintile_ratio*EUROSTAT_Quintile_ratio_dev_poin
gen XX_LEFT_QUINT_QUINTdev=LR_LEFT_WING*EUROSTAT_Quintile_ratio*EUROSTAT_Quintile_ratio_dev_poin
gen XX_RIGHT_QUINT_QUINTdev=LR_RIGHT_WING*EUROSTAT_Quintile_ratio*EUROSTAT_Quintile_ratio_dev_poin
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING EUROSTAT_Quintile_ratio EUROSTAT_Quintile_ratio_dev_poin X_LEFT_QUANT_DEV X_RIGHT_QUANT_DEV X_LEFT_QUINT X_RIGHT_QUINT X_QUINT_QUINTdev XX_LEFT_QUINT_QUINTdev XX_RIGHT_QUINT_QUINTdev Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 Exceldate if nomiss==1 || GROUP_country_date:, var
estimates store Model_4x
predict scorehat_Model_4x, xb
lrtest Model_1x Model_4x
lrtest Model_2x Model_4x
lrtest Model_3x Model_4x
twoway (lfitci scorehat_Model_4x EUROSTAT_Quintile_ratio_dev_poin [aweight=weight_eu28] if LR_LEFT_WING==1 ) ///
(lfitci scorehat_Model_4x EUROSTAT_Quintile_ratio_dev_poin [aweight=weight_eu28] if LR_MODERATE==1) ///
(lfitci scorehat_Model_4x EUROSTAT_Quintile_ratio_dev_poin [aweight=weight_eu28] if LR_RIGHT_WING==1) if EUROSTAT_Gini_dev_point>=-5, by(QUINT2, row(1)) legend(label(1 "95% CI") label(2 "Left-wing") label(3 "Center") label(4 "Right-wing")) ysize(5) xsize(10) ytitle("Predicted effect on EU support")

*2. Countries as groups and Year fixed effects
*Model 1 - Level of inequality
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING EUROSTAT_Gini Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 i.Year if nomiss==1 || country:, var
predict scorehat_Model_1y, xb
estimates store Model_1y
*Model 2 - Level and changes in inequality
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING EUROSTAT_Gini EUROSTAT_Gini_dev_point Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 i.Year if nomiss==1 || country:, var
predict scorehat_Model_2y, xb
estimates store Model_2y
lrtest Model_1y Model_2y
*Model 3 - Level and changes in inequality ( + INTERACTION)
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING EUROSTAT_Gini EUROSTAT_Gini_dev_point X_LEFT_GINI_DEV_point X_RIGHT_GINI_DEV_point Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 i.Year if nomiss==1 || country:, var
estimates store Model_3y
predict scorehat_Model_3y, xb
lrtest Model_1y Model_3y
lrtest Model_2y Model_3y
twoway (lfitci scorehat_Model_3y EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_LEFT_WING==1 ) ///
(lfitci scorehat_Model_3y EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_MODERATE==1) ///
(lfitci scorehat_Model_3y EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_RIGHT_WING==1) if EUROSTAT_Gini_dev_point>=-5, by(GINI3, row(1)) legend(label(1 "95% CI") label(2 "Left-wing") label(3 "Center") label(4 "Right-wing")) ysize(5) xsize(10) ytitle("Predicted effect on EU support")
*Model 4 - Level and changes in inequality ( + INTERACTION & RANDOM EFFECTS)
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING EUROSTAT_Gini EUROSTAT_Gini_dev_point X_LEFT_GINI_DEV_point X_RIGHT_GINI_DEV_point X_LEFT_Gini X_RIGHT_Gini X_GINI_GINIdev XX_LEFT_GINI_GINIdev XX_RIGHT_GINI_GINIdev Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 i.Year if nomiss==1 || country:, var
estimates store Model_4y
predict scorehat_Model_4y, xb
lrtest Model_1y Model_4y
lrtest Model_2y Model_4y
lrtest Model_3y Model_4y
twoway (lfitci scorehat_Model_4y EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_LEFT_WING==1 ) ///
(lfitci scorehat_Model_4y EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_MODERATE==1) ///
(lfitci scorehat_Model_4y EUROSTAT_Gini_dev_point [aweight=weight_eu28] if LR_RIGHT_WING==1) if EUROSTAT_Gini_dev_point>=-5, by(GINI3, row(1)) legend(label(1 "95% CI") label(2 "Left-wing") label(3 "Center") label(4 "Right-wing")) ysize(5) xsize(10) ytitle("Predicted effect on EU support")


*****PCT increases
gen X_LEFT_GINI_DEV_pct=EUROSTAT_Gini_dev_pct*LR_LEFT_WING
gen X_RIGHT_GINI_DEV_pct=EUROSTAT_Gini_dev_pct*LR_RIGHT_WING
gen X_GINI_GINIdev_pct=EUROSTAT_Gini*EUROSTAT_Gini_dev_pct
gen XX_LEFT_GINI_GINIdev_pct=LR_LEFT_WING*EUROSTAT_Gini*EUROSTAT_Gini_dev_pct
gen XX_RIGHT_GINI_GINIdev_pct=LR_RIGHT_WING*EUROSTAT_Gini*EUROSTAT_Gini_dev_pct
xi: xtmelogit EUsupport LR_LEFT_WING LR_RIGHT_WING EUROSTAT_Gini EUROSTAT_Gini_dev_pct ///
X_LEFT_GINI_DEV_pct X_RIGHT_GINI_DEV_pct X_LEFT_Gini X_RIGHT_Gini X_GINI_GINIdev_pct XX_LEFT_GINI_GINIdev_pct XX_RIGHT_GINI_GINIdev_pct ///
Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 Exceldate if nomiss==1 || GROUP_country_date:, var
estimates store Model_R1
predict scorehat_Model_R1, xb
twoway (lfitci scorehat_Model_R1 EUROSTAT_Gini_dev_pct [aweight=weight_eu28] if LR_LEFT_WING==1 ) ///
(lfitci scorehat_Model_R1 EUROSTAT_Gini_dev_pct [aweight=weight_eu28] if LR_MODERATE==1) ///
(lfitci scorehat_Model_R1 EUROSTAT_Gini_dev_pct [aweight=weight_eu28] if LR_RIGHT_WING==1) if EUROSTAT_Gini_dev_point>=-5, by(GINI2, row(1)) legend(label(1 "95% CI") label(2 "Left-wing") label(3 "Center") label(4 "Right-wing")) ysize(5) xsize(10) ytitle("Predicted effect on EU support")



