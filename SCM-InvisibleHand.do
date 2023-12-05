
*********************************************************
********  TRABAJO FINAL - ECONOMETRIA AVANZADA   ********
********            SARA CAICEDO SILVA           ********
********                   2023                  ********
*********************************************************

*********************************************************
******* CONTROL SINTÉTICO PARA ESTIMAR EL EFECTO ********
*******  DEL SHOW "FREE TO CHOOSEE" DE FRIEDMAN  ********
*******   SOBRE LAS CITAS DE LA MANO INVISIBLE   ********
*********************************************************


	clear all
	cd "/Users/sara/Desktop/Econometria Avanzada/Trabajo Final/"
	use "Data_InvisibleHand.dta"
	
** Cambio de colores 
	set scheme white_tableau	
** 
	ren A_os year
	drop index
	tsset ID year

*** Elimino comunismo y marxismo, probablmente son variables tratadas.
	drop if ID == 11 | ID == 9

	
**#Creación de una variable relativa
	bysort ID: gen citas_base = log_citas if year == 1979
	egen citas_1979 = max(citas_base), by(ID)
	gen citas_ratio = log_citas/citas_1979

/*	
** TRATAMIENTO: Publicación del libro y la serie "Free to choose" de 
	Milton y Rosa Friedman
** OUTCOME DE INTERÉS: Citas de "invisible hand" en google Ngrams
** AÑO DE TRATAMIENTO: 1980
*/


**# Estimación para 1980

tsset ID year
synth log_citas citas_ratio(1960) citas_ratio(1970) citas_ratio log_citas(1950) log_citas(1955) log_citas(1960) log_citas(1965) log_citas(1970) log_citas(1975) log_citas(1979) AA_E AA_G U_E U_NA U_A U_I U_T Long, trunit(0) trperiod(1980) unitnames(Variable) 
		
			
		* Constantes (no negativas) de cada variable independiente
		mat list e(V_matrix)
		
		* Vector de pesos 
		mat list e(W_weights)
		
*) Presentación gráfica del efecto del tratamiento
	snapshot save, label("Base temporal para 1")
	* Base temporal
	tempfile synth
	
	* Estimación en una base
	qui synth log_citas citas_ratio(1960) citas_ratio(1970) log_citas(1950) log_citas(1955) log_citas(1960) log_citas(1965) log_citas(1970) log_citas(1975) log_citas(1979) AA_E AA_G U_E U_NA U_A U_I U_T, trunit(0) trperiod(1980) unitnames(Variable) keep(`synth')
	
	* Ajuste de la base
	use `synth', replace
	drop _Co_Number _W_Weight
	rename (_time _Y_treated _Y_synthetic) (year treat counterfact)
	
	* Gráfica
	twoway (line treat year,lp(solid)lw(vthin)lcolor(black))					///
			(line counterfact year,lp(solid)lw(vthin)lcolor(navy)),				///
			xline(1980, lpattern(shortdash) lcolor(black)) ///
			xtitle("Año", si(medsmall)) xlabel(#10) ///
			title("Tendencia en la variación de las citas") ///
			xsc(r(1950 2020)) ///
			ytitle("Porcentaje de citas", size(medsmall)) ///
			graphregion(fcolor(white)) ///
			legend(pos (6) row(1))
			
	gr save diferencia, replace	
	
	*Efecto
	gen effect=treat-counterfact
	
	twoway (line effect year,lp(solid)lw(vthin)lcolor(black)),				///
		xline(1980, lpattern(shortdash) lcolor(black)) 						///
		title("Diferencia en la variación de las citas") ///
		xtitle("Año",si(medsmall)) xlabel(#10) 	///
		yline(0 ,lpattern(shortdash) lcolor(grey)) ///
		ytitle("Diferencia en porcentaje de citas", size(medsmall)) legend(off) ///
		graphregion(fcolor(white))
	gr save efecto, replace	
	gr combine diferencia.gph efecto.gph
	gr export dif_efecto.pdf, replace
	
	snapshot restore 1
	
	
**#P-values
synth_runner log_citas citas_ratio(1960) citas_ratio(1970) log_citas(1950) log_citas(1955) log_citas(1960) log_citas(1965) log_citas(1970) log_citas(1975) log_citas(1979) AA_E AA_G U_E U_NA U_A U_I U_T, trunit(0) trperiod(1980) unitnames(Variable) gen_vars

keep effect year ID
reshape wide effect, i (year) j (ID)
rename effect0 Invisiblehand


	twoway (line effect1 -effect10 year, lc(gray*0.75 ...) lw(vthin ...))		///
			(line effect12 -effect20 year, lc(gray*0.75 ...) lw(vthin ...))    ///
			(line effect21 -effect30 year, lc(gray*0.75 ...) lw(vthin ...))    ///
			(line effect31 -effect42 year, lc(gray*0.75 ...) lw(vthin ...))    ///
			(line Invisiblehand year, lc(black)),                               ///
			legend(off) graphregion (fcolor(white )) xsc(r(1950 2020)) ///      
			xline(1980,lpattern (shortdash) lcolor (black))                     ///
			yline(0, lpattern (shortdash) lcolor (black)) ///
			xtitle("Años",si(medsmall)) ///
			ytitle("Diferencia en porcentaje de citas", size(medsmall)) legend(off)

	gr export PlacebosPvalue.pdf, replace
	snapshot restore 1
	
**# ROBUSTEZ: Placebo para 2008

	synth log_citas citas_ratio(1960) citas_ratio(1970) log_citas(1950) log_citas(1955) log_citas(1960) log_citas(1965) log_citas(1970) log_citas(1975) log_citas(1979) AA_E AA_G U_E U_NA U_A U_I U_T, trunit(0) trperiod(2008) unitnames(Variable) gen_vars
				
		* Constantes (no negativas) de cada variable independiente
		mat list e(V_matrix)
		
		* Vector de pesos 
		mat list e(W_weights)
		
*) Presentación gráfica del efecto del tratamiento
	snapshot save, label("Base temporal para 1")
	* Base temporal
	tempfile synth
	
	* Estimación en una base
	qui synth log_citas log_citas(1961) log_citas(1965) log_citas(1970) log_citas(1975) log_citas(1980) log_citas(1985) log_citas(1990) log_citas(2000) log_citas(2005) AA_E(1990) AA_G(1990) U_E(1990) U_NA(1991)	U_I(1991) U_T(1991)	Long(1991), trunit(0) trperiod(1985) unitnames(Variable) keep(`synth')
	
	* Ajuste de la base
	use `synth', replace
	drop _Co_Number _W_Weight
	rename (_time _Y_treated _Y_synthetic) (year treat counterfact)
	
	* Gráfica
	twoway (line treat year,lp(solid)lw(vthin)lcolor(black))					///
			(line counterfact year,lp(solid)lw(vthin)lcolor(navy)),				///
			xline(1985, lpattern(shortdash) lcolor(black)) 						///
			xtitle("Año",si(medsmall)) xlabel(#10) 								///
			ytitle("Porcentaje de citas", size(medsmall)) ///
			graphregion(fcolor(white)) ///
			legend(pos (6) row(1))
	gr save placebo85_1, replace
	
	
	*Efecto
	gen effect=treat-counterfact
	
	twoway (line effect year,lp(solid)lw(vthin)lcolor(black)),				///
		xline(1985, lpattern(shortdash) lcolor(black)) 						///
		xtitle("Año",si(medsmall)) xlabel(#10) 								///
		ytitle("Porcentaje de citas", size(medsmall)) legend(off)		///
		graphregion(fcolor(white))
	gr save placebo85_2, replace
	gr combine placebo85_1.gph placebo85_2.gph
	gr export placebo85.pdf, replace

	snapshot restore 1
**# Placebo sin términos de ciencias sociales
	drop if AA_G == 1 & ID !=0
	br

	synth log_citas citas_ratio(1960) citas_ratio(1970) log_citas(1950) log_citas(1955) log_citas(1960) log_citas(1965) log_citas(1970) log_citas(1975) log_citas(1979) AA_E AA_G U_E U_NA U_A U_I U_T, trunit(0) trperiod(1980) unitnames(Variable) gen_vars
				
		* Constantes (no negativas) de cada variable independiente
		mat list e(V_matrix)
		
		* Vector de pesos 
		mat list e(W_weights)
		
*) Presentación gráfica del efecto del tratamiento
	
	* Base temporal
	tempfile synth
	
	* Estimación en una base
	qui synth log_citas log_citas(1961) log_citas(1965) log_citas(1970) log_citas(1975) log_citas(1980) log_citas(1985) log_citas(1990) log_citas(2000) log_citas(2005) AA_E(1990) AA_G(1990) U_E(1990) U_NA(1991)	U_I(1991) U_T(1991)	Long(1991), trunit(0) trperiod(1980) unitnames(Variable) keep(`synth')
	
	* Ajuste de la base
	use `synth', replace
	drop _Co_Number _W_Weight
	rename (_time _Y_treated _Y_synthetic) (year treat counterfact)
	
	* Gráfica
	twoway (line treat year,lp(solid)lw(vthin)lcolor(black))					///
			(line counterfact year,lp(solid)lw(vthin)lcolor(navy)),				///
			xline(1980, lpattern(shortdash) lcolor(black)) 						///
			xtitle("Año",si(medsmall)) xlabel(#10) 								///
			ytitle("Porcentaje de citas", size(medsmall)) ///
			graphregion(fcolor(white)) ///
			legend(pos (6) row(1))
	gr save placebo85_1, replace
	
	
	*Efecto
	gen effect=treat-counterfact
	
	twoway (line effect year,lp(solid)lw(vthin)lcolor(black)),				///
		xline(1985, lpattern(shortdash) lcolor(black)) 						///
		xtitle("Año",si(medsmall)) xlabel(#10) 								///
		ytitle("Porcentaje de citas", size(medsmall)) legend(off)		///
		graphregion(fcolor(white))
	gr save placebo85_2, replace
	gr combine placebo85_1.gph placebo85_2.gph
	gr export placebo85.pdf, replace


snapshot restore 1

