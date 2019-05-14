gen LEFT_WING=0
replace LEFT_WING=0.25 if lr_scale==4
replace LEFT_WING=0.50 if lr_scale==3
replace LEFT_WING=0.75 if lr_scale==2
replace LEFT_WING=1.00 if lr_scale==1

gen RIGHT_WING=0 
replace RIGHT_WING=0.25 if lr_scale==7
replace RIGHT_WING=0.50 if lr_scale==8
replace RIGHT_WING=0.75 if lr_scale==9
replace RIGHT_WING=1.00 if lr_scale==10

gen EUsupport_int=((MEM_ATT_cat3-1)/-2)+1
********************************************************************************
***************************** Estimation table 2 *******************************
********************************************************************************
*Model 1
xtmixed EUsupport_int LEFT_WING RIGHT_WING EUROSTAT_Gini EUROSTAT_Gini_dev_point Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 i.low_income timevar if nomiss==1 || GROUP_country_date:, var
estimates store Model_1_linear
predict Model_1_linear, xb
*Model 2
xtmixed EUsupport_int c.LEFT_WING##c.EUROSTAT_Gini_dev_point c.RIGHT_WING##c.EUROSTAT_Gini_dev_point EUROSTAT_Gini Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 i.low_income timevar if nomiss==1 || GROUP_country_date:, var
estimates store Model_2_linear
predict Model_2_linear, xb
lrtest Model_1_linear Model_2_linear
*Model 3
xtmixed EUsupport_int c.LEFT_WING##c.EUROSTAT_Gini_dev_point##c.EUROSTAT_Gini c.RIGHT_WING##c.EUROSTAT_Gini_dev_point##c.EUROSTAT_Gini Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 i.low_income timevar if nomiss==1 || GROUP_country_date:, var
estimates store Model_3_linear
predict Model_3_linear, xb
lrtest Model_1_linear Model_3_linear
lrtest Model_2_linear Model_3_linear	
*Model 4
xtmixed EUsupport_int c.LEFT_WING##c.EUROSTAT_Gini_dev_point##c.EUROSTAT_Gini c.RIGHT_WING##c.EUROSTAT_Gini_dev_point##c.EUROSTAT_Gini Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation Prisk_ratio_inv Prisk_prior taxrev socialspending ///
demo_age i.demo_female i.demo_commtype i.demo_education_cat3 i.low_income timevar if nomiss==1 || GROUP_country_date:, var
estimates store Model_4_linear
predict Model_4_alternative, xb
lrtest Model_1_linear Model_4_linear
lrtest Model_2_linear Model_4_linear
lrtest Model_3_linear Model_4_linear
twoway (qfitci Model_4_alternative lr_scale [aweight=weight_eu28] if EUROSTAT_Gini_dev_point<=-.3) ///
(qfitci Model_4_alternative lr_scale [aweight=weight_eu28] if EUROSTAT_Gini_dev_point>=-.2 & EUROSTAT_Gini_dev_point<=.2) ///
(qfitci Model_4_alternative lr_scale [aweight=weight_eu28] if EUROSTAT_Gini_dev_point>=.3), by(GINI2, row(1)) xlabel(1(1)10) ylabel(.65(.025).75) legend(label(1 "95% CI") label(2 "Decrease (<=-.3)") label(3 "Status quo (>-.3 to <.3)") label(4 "Increase (>=.3)")) ysize(5) xsize(10) ytitle("Predicted EU support") xtitle("Left-/right placement")
	*Model 4 - Alternative: Quintiles
	xtmixed EUsupport_int c.LEFT_WING##c.EUROSTAT_Quintile_ratio##c.EUROSTAT_Quintile_ratio_dev_poin c.RIGHT_WING##c.EUROSTAT_Quintile_ratio##c.EUROSTAT_Quintile_ratio_dev_poin Unemployment GDP_percapita GDP_percapita_pct_growth OECD_Inflation Prisk_ratio_inv Prisk_prior taxrev socialspending ///
	demo_age i.demo_female i.demo_commtype i.demo_education_cat3 i.low_income timevar if nomiss==1 || GROUP_country_date:, var
	predict M4_linear_QUINT, xb
	twoway (qfitci M4_linear_QUINT lr_scale [aweight=weight_eu28] if EUROSTAT_Quintile_ratio_dev_poin<=-.2) ///
	(qfitci M4_linear_QUINT lr_scale [aweight=weight_eu28] if EUROSTAT_Quintile_ratio_dev_poin>=-.1 & EUROSTAT_Quintile_ratio_dev_poin<=.1) ///
	(qfitci M4_linear_QUINT lr_scale [aweight=weight_eu28] if EUROSTAT_Quintile_ratio_dev_poin>=.3), by(QUINT2, row(1)) xlabel(1(1)10) ylabel(.65(.025).75) legend(label(1 "95% CI") label(2 "Decrease (<=-.2)") label(3 "Status quo (>-.2 to <.2)") label(4 "Increase (>=.2)")) ysize(5) xsize(10) ytitle("Predicted EU support") xtitle("Left-/right placement")

********************************************************************************
***************************** Robustness table A1 *******************************
********************************************************************************
*MODEL 1 - Linear ML model (GINI, country as group)
xtmixed EUsupport_int c.LEFT_WING##c.EUROSTAT_Gini##c.EUROSTAT_Gini_dev_point c.RIGHT_WING##c.EUROSTAT_Gini##c.EUROSTAT_Gini_dev_point ///
GDP_percapita GDP_percapita_pct_growth Unemployment OECD_Inflation timevar ///
i.demo_female i.low_income i.demo_education_cat3 i.demo_alder_cat4 i.demo_commtype [pweight=weight_eu28] || country:,
predict GINI_MIXED_c, xb
estimates store GINI_MIXED_c
*MODEL 2 - Linear ML model (QUINT, country as group)
xtmixed EUsupport_int c.LEFT_WING##c.EUROSTAT_Quintile_ratio##c.EUROSTAT_Quintile_ratio_dev_poin c.RIGHT_WING##c.EUROSTAT_Quintile_ratio##c.EUROSTAT_Quintile_ratio_dev_poin ///
GDP_percapita GDP_percapita_pct_growth Unemployment OECD_Inflation timevar ///
i.demo_female i.low_income i.demo_education_cat3 i.demo_alder_cat4 i.demo_commtype [pweight=weight_eu28] || country:,
predict QUINT_MIXED_c, xb
estimates store QUINT_MIXED_c
*MOdel 3 - Three level estimation: Country & timevar
xtmixed EUsupport_int c.LEFT_WING##c.EUROSTAT_Gini##c.EUROSTAT_Gini_dev_point c.RIGHT_WING##c.EUROSTAT_Gini##c.EUROSTAT_Gini_dev_point ///
GDP_percapita GDP_percapita_pct_growth Unemployment OECD_Inflation ///
i.demo_female i.low_income i.demo_education_cat3 i.demo_alder_cat4 i.demo_commtype [pweight=weight_eu28] || country: || timevar:,

*MODEL 4 - Logit model (GINI, country fixed effects)
drop nomiss
mark nomiss
markout nomiss EUsupport_int LEFT_WING EUROSTAT_Quintile_ratio EUROSTAT_Quintile_ratio_dev_poin RIGHT_WING GDP_percapita GDP_percapita_pct_growth Unemployment OECD_Inflation timevar demo_female low_income demo_education_cat3 demo_alder_cat4 demo_commtype weight_eu28 country
logit EUsupport c.LEFT_WING##c.EUROSTAT_Gini##c.EUROSTAT_Gini_dev_point c.RIGHT_WING##c.EUROSTAT_Gini##c.EUROSTAT_Gini_dev_point ///
GDP_percapita GDP_percapita_pct_growth Unemployment OECD_Inflation ///
i.demo_female i.low_income i.demo_education_cat3 i.demo_alder_cat4 i.demo_commtype timevar i.country if nomiss==1
predict GINI_FElogit_c, xb
twoway (qfitci GINI_FElogit_c lr_scale [aweight=weight_eu28] if EUROSTAT_Gini_dev_point<=-.3) ///
(qfitci GINI_FElogit_c lr_scale [aweight=weight_eu28] if EUROSTAT_Gini_dev_point>=-.2 & EUROSTAT_Gini_dev_point<=.2) ///
(qfitci GINI_FElogit_c lr_scale [aweight=weight_eu28] if EUROSTAT_Gini_dev_point>=.3), by(GINI2, row(1)) legend(label(1 "95% CI") label(2 "Decrease") label(3 "Status quo") label(4 "Increase")) ysize(5) xsize(10) ytitle("Predicted EU support")
*MODEL 5 - Logit model (QUINT, country fixed effects)
logit EUsupport c.LEFT_WING##c.EUROSTAT_Quintile_ratio##c.EUROSTAT_Quintile_ratio_dev_poin c.RIGHT_WING##c.EUROSTAT_Quintile_ratio##c.EUROSTAT_Quintile_ratio_dev_poin ///
GDP_percapita GDP_percapita_pct_growth Unemployment OECD_Inflation ///
i.demo_female i.low_income i.demo_education_cat3 i.demo_alder_cat4 i.demo_commtype timevar i.country if nomiss==1
predict QUINT_FElogit_c, xb
twoway (qfitci QUINT_FElogit_c lr_scale [aweight=weight_eu28] if EUROSTAT_Gini_dev_point<=-.3) ///
(qfitci QUINT_FElogit_c lr_scale [aweight=weight_eu28] if EUROSTAT_Gini_dev_point>=-.2 & EUROSTAT_Gini_dev_point<=.2) ///
(qfitci QUINT_FElogit_c lr_scale [aweight=weight_eu28] if EUROSTAT_Gini_dev_point>=.3), by(GINI2, row(1)) legend(label(1 "95% CI") label(2 "Decrease") label(3 "Status quo") label(4 "Increase")) ysize(5) xsize(10) ytitle("Predicted EU support")

