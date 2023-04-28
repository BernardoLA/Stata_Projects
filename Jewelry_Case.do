
clear
cd "C:\Users\be_al\OneDrive - UvA\Desktop\SKIM"
use "Trade_Off_Data", clear 


** -- Quick overview of the Nested structure of the data -- **
list resp task concept choice att1 att2 att3 att4 att5 price in 1/36, sepby(task) nolabel noobs

** -- Set the data to a mixed choice model panel data -- **
cmset resp task concept


**-- Recoding variables --**

*** Concept
fre concept
lab var concept "Products"
lab define x 1 "concept_1" 2 "concept_2" 3 "concept_3"
lab value concept x

*** Attribute 1
lab var att1 "Stone Coverage"
lab define latt1 1 "Low" 2 "Standard" 3 "High" 
lab value att1 latt1
fre att1

*** Attribute 2
lab var att2 "Level of Refinement"
lab define latt2 1 "Basic" 2 "Refined" 3 "High-End"
lab value att2 latt2
fre att2

*** Attribute 3 - First Specification, supposing that it was an error in the assignment
lab var att3 "Plating"
lab define latt3 1 "Rodhium" 2 "Silver" 3 "Gold Coat" 4 "Something else"
lab value att3 latt3
fre att3

*** Attribute 4
lab var att4 "Easy Removal"
lab define latt4 1 "Yes" 2 "No"
lab value att4 latt4
fre att4

*** Attribute 5
lab var att5 "Environmentally friendly"
lab define latt5 1 "Yes" 2 "No" 
lab value att5 latt5
fre att5

*** recode of price
fre price
recode price (79/119 = 1 "79-119") (139/249 = 2 "139-249") (289/519 = 3 "289-469") (519/749 = 4 "519-749"), gen(price_cat)
fre price_cat
fre price

/**************************************************                                   Exploratory Data Analysis                                  ********************************************************/

* Attribute 1 - We see that most purchased have high coverage
graph bar, over(att1) by(choice, ///
 title("Attribute 1: Stone Coverage") ///
 subtitle("Distribution of attribute levels by Decision") ///
 note("")) 
 
* Attribute 2 
graph bar, over(att2) by(choice, ///
 title("Attribute 2: Level of Refinement") ///
 subtitle("Distribution of attribute levels by Decision") ///
 note("")) 
 
* Attribute 3
graph bar, over(att3) by(choice, ///
 title("Attribute 3: Plating") ///
 subtitle("Distribution of attribute levels by Decision") ///
 note(""))

* Attribute 4
graph bar, over(att4) by(choice, ///
 title("Attribute 4: Easy Removal") ///
 subtitle("Distribution of attribute levels by Decision") ///
 note(""))

* Attribute 5
graph bar, over(att5) by(choice, ///
 title("Attribute 5: Environmentally friendly") ///
 subtitle("Distribution of attribute levels by Decision") ///
 note(""))

* Concepts
graph bar, over(concept) by(choice, ///
 title("Concepts: Distribution of concepts by Decision") ///
 note(""))

* Price 
graph bar, over(price, relabel(1 "79" 2 "89" 3 " " 4 "109" 5 " " 6 "139" 7 " " 8 "189" 9 " " 10 "249" 11 " " 12 "329" 13 " " 14 "419" 15 " " 16 "519" 17 " " 18 "629" 19 " " 20 "749")) ylab(0(1)8) ///
 by(choice, ///
 title("Price range of products over choices") ///
 note(""))
 
 
/************************************************************                                   Modelling Part                                   **************************************************************/

** First model without prices
cmxtmixlogit choice i.att1 i.att2 i.att3 i.att4 i.att5, basealternative("1") or
***

*** After controlling for prices
cmxtmixlogit choice i.att1 i.att2 i.att3 i.att4 i.att5 i.price ,  basealternative("1") or

** Check the price range for att3 
graph bar, over(price, relabel(1 "79" 2 "89" 3 " " 4 "109" 5 " " 6 "139" 7 " " 8 "189" 9 " " 10 "249" 11 " " 12 "329" 13 " " 14 "419" 15 " " 16 "519" 17 " " 18 "629" 19 " " 20 "749")) by(att3, note("")) 			  

** Check the price range for att1
graph bar, over(price, relabel(1 "79" 2 "89" 3 " " 4 "109" 5 " " 6 "139" 7 " " 8 "189" 9 " " 10 "249" 11 " " 12 "329" 13 " " 14 "419" 15 " " 16 "519" 17 " " 18 "629" 19 " " 20 "749")) by(att1, note("")) 

*** FIGURE 3 Plotting the overall preference controlling for all the other features for concept_2 over concepts 1 and 3. 
margins
marginsplot, legend(pos(6) row(1)) recast(bar) plot1opts(bcolor(%50)) ciopts(color(black)) ylab(0(0.1)0.5) xtitle("")

**-- 1) What attributes customers value most? --*

* Attribute 1
margins i.att1, outcome(concept_2) alternatives(concept_2)
marginsplot, legend(pos(6) row(1)) recast(bar) plot1opts(bcolor(%50)) ciopts(color(black)) ylab(0(0.1)0.5) xtitle("")

* Attribute 2
margins i.att2, outcome(concept_2) alternatives(concept_2)
margins i.att3, outcome(concept_2) alternatives(concept_2)
margins i.att4, outcome(concept_2) alternatives(concept_2)
margins i.att5, outcome(concept_2) alternatives(concept_2)

marginsplot, legend(pos(6) row(1)) recast(bar) plot1opts(bcolor(%50)) ciopts(color(black)) ylab(0(0.1)0.5) xtitle("")
marginsplot, legend(pos(6) row(1)) recast(bar) plot1opts(bcolor(%50)) ciopts(color(black)) ylab(0(0.1)0.5) xtitle("")
marginsplot, legend(pos(6) row(1)) recast(bar) plot1opts(bcolor(%50)) ciopts(color(black)) ylab(0(0.1)0.5) xtitle("")


**-- 2) Are there any pyshcological thresholds? 
**Checking visually how the "pyschological thresholds" of individuals **and how they are present in both...

** Concept 1
margins, at(price = (79(50)789)) outcome(concept_1)
marginsplot, legend(pos(6) row(1)) recast(line) recastci(rarea) ciopts(color(%20)) ylab(0(0.1)0.6) xline(419) saving(plota)

** Concept 2
margins, at(price = (79(50)789)) outcome(concept_2)
marginsplot, legend(pos(6) row(1)) recast(line) recastci(rarea) ciopts(color(%20)) xline(419) saving(plotb)

** Concept 3
margins, at(price = (79(50)789)) outcome(concept_3)
marginsplot, legend(pos(6) row(1)) recast(line) recastci(rarea) ciopts(color(%20)) xline(419) saving(plotc)

graph combine plota.gph plotb.gph plotc.gph

*** Visualizing that Att_1 is clearly the most important attribute according and particularly at the higher levels. 

* Predicted probabilities of choosing the concepts where the attribute levels correspond to observations where concept 2 has these attributes
margins i.att1, alternative(concept_2)
marginsplot,recast(dot) plotopts(dcolor(white%0) msize(large)) ///
			ciopts(color(%100)) ///
			plot2opts(color(black)) ci2opts(color(black%80)) ///
			legend(pos(6) row(1)) ylab(0(0.1)0.5) 

* Predicted probabilities of choosing the concepts where only concept 1 has these levels in attribute 1.
margins i.att1, alternative(concept_1)
marginsplot,recast(dot) plotopts(dcolor(white%0) msize(large)) ///
			ciopts(color(%100)) ///
			plot2opts(color(black)) ci2opts(color(black%80)) ///
			legend(pos(6) row(1)) ylab(0(0.1)0.5) 
			
			
* Predicted probabilities of choosing concepts where only observations of concept 3 have these levels in attribute 1 
margins i.att1, alternative(concept_3)
marginsplot,recast(dot) plotopts(dcolor(white%0) msize(large)) ///
			ciopts(color(%100)) ///
			plot2opts(color(black)) ci2opts(color(black%80)) ///
			legend(pos(6) row(1)) ylab(0(0.1)0.5) 

* Finally, I summarize these results focusing on concept_2 since it was the most valued product among consumers:
margins i.att1, outcome(concept_2) 
marginsplot, recast(dot) plotopts(dcolor(white%0) msize(large)) ///
			ciopts(color(%100)) ///
			plot2opts(color(black)) ci2opts(color(black%80)) ///
			legend(pos(6) row(1)) ylab(0(0.1)0.5) yline(0.430183)
			
//-> so the chances to buy concept 2 are higher when they are presented with high stone coverage  as opposed to when they are presented with the stone coverage for the other two concepts. However, the probability of acquiring concept 2 with standard coverage is smaller than other two cases pricesily when consumers are presented with concept 2 with this specification. And for Low stone coverage it doesn't matter which options were presented to consumers for the decision to purchase concept 2.
 
margins i.att1, outcome(concept_3) alternative(concept_3)
marginsplot, recast(dot) plotopts(dcolor(white%0) msize(large)) ///
			ciopts(color(%100)) ///
			plot2opts(color(black)) ci2opts(color(black%80)) ///
			legend(pos(6) row(1)) ylab(0(0.1)0.5)  

margins i.att1, outcome(concept_1) alternative(concept_1)
marginsplot, recast(dot) plotopts(dcolor(white%0) msize(large)) ///
			ciopts(color(%100)) ///
			plot2opts(color(black)) ci2opts(color(black%80)) ///
			legend(pos(6) row(1)) ylab(0(0.1)0.5)  	
//-> Similar conclusions for concept_1 and concept_3 people prefer it when presented with High Stone coverage.



*** APPENDIX A - Now, for the sake of time I move forward to briefly check all other attributes that were unimportant for acquiring the product. We see that all attributes overlap with each other. I also restrict it to the observations where only respondents were exposed to concept_2 levels of that attribute for the sake of clarity.
margins i.att2, outcome(concept_2) alternative(concept_2)
marginsplot, recast(dot) plotopts(dcolor(white%0) msize(large)) ///
			ciopts(color(%100)) ///
			legend(pos(6) row(1)) ylab(0(0.1)0.5)  

			
margins i.att3, outcome(concept_2) alternative(concept_2)
marginsplot, recast(dot) plotopts(dcolor(white%0) msize(large)) ///
			ciopts(color(%100)) ///
			legend(pos(6) row(1)) ylab(0(0.1)0.5)  
			
			
margins i.att4, outcome(concept_2) alternative(concept_2)
marginsplot, recast(dot) plotopts(dcolor(white%0) msize(large)) ///
			ciopts(color(%100)) ///
			legend(pos(6) row(1)) ylab(0(0.1)0.5)

margins i.att5, outcome(concept_2) alternative(concept_2)
marginsplot, recast(dot) plotopts(dcolor(white%0) msize(large)) ///
			ciopts(color(%100)) ///
			legend(pos(6) row(1)) ylab(0(0.1)0.5)
			
*** Which levels attribute allows them to increase the price the most?

** I'm now focusing on the chances of buying that product after seeing that product for each price mark. Starting with concept_2
	margins i.att1, at(price = (79(50)789)) outcome(concept_2) alternative(concept_2)
	marginsplot, recast(line) recastci(rarea) ciopts(color(%20)) plotopts(bcolor(%50)) ylab(0(0.1)0.7) xtitle("")legend(pos(6) row(1)) xline()

//-> So for all levels of attribute 1 the predicted probabilities decreases as prices increases for the three levels of attributes. However, while there is an overlap in extreme prices, between 179 and 479 euros there is statistically significant difference between a high and standard/low stone coverage. Indicating that products with high stone coverage can get be priced higher compared to those with low and standard stone coverage. 

** I run a stronger statistical test to confirm the aforementioned: the average marginal effects att1 on witin that price range

* Average marginal effects: It's the change of choosing an alternative(in this case concept_2) as a function of infinitisimal change at certain points of a covariate. In this case it is direct average marginal effects because restricted to same alternative and outcome. 
margins, dydx(i.att1) at(price = (79(50)789)) outcome(concept_2) alternative(concept_2)
marginsplot, recast(line) ciopts(recast(rarea) color(%20)) legend(pos(6) row(1)) yline(0, lcolor(black%50))

//-> In fact, what we see is that the the effect of Having High Stone coverage rather than low is positive in all price range, even if it decreases towards the extreme. Therefore the change from low to high stone coverage have roughly 0.10 probability increase in the chance to buy concept 2 at 79 euros. Similarly, although smaller, there is 0.06 proability increase to buy concept 2 at 779 euros if this product is with high stone coverage rather than low. If Standard was the reference category the effect would be even stronger:

//-> So we see that at 79 euros the difference from the other two concepts is the highest. Around 379 euros all three concepts would have the same proability of being purchased and from that point onwards they become more valuable than concept2.


*** What about the combination with other attributes?? Could it be that attribute one is more valuable in combination with other attributes. However, I also need to have theoretical insight to calculate such interactions. I assume that Jewelry X had a hypothesis that the combination of attribute 1 and 3 were appealing to consumers and they hold simlar ways of evaluating it: TESTED FOR 4, 5 e 3 e 2 

cmxtmixlogit choice i.att1##i.att2 i.att4 i.att5 i.att3 price, basealternative("1")

** For attributes 2 
margins i.att1, at(att2 = (1(1)3)) outcome(concept_2) alternative(concept_2)
marginsplot, recast(dot) plotopts(dcolor(white%0) msize(large)) ///
 ciopts(color(%100)) ///
 plot3opts(dcolor(black) msymbol(D) mcolor(black)) ci3opts(color(black%80)) ///
 ylab(0(0.1)0.7) xtitle("")legend(pos(6) row(1))
 

********** AMG ********
margins, dydx(att1) at(att2 = (1(1)3)) outcome(concept_2) alternative(concept_2)
 marginsplot, recast(dot) plotopts(dcolor(white%0) msize(large)) ///
 ciopts(color(%100)) ///
 plot1opts(dcolor(orange) msymbol(O) mcolor(orange)) ///
 ci1opts(color(orange%100)) ///
 plot2opts(dcolor(black) msymbol(D) mcolor(black)) ///
 ci2opts(color(black%80)) yline(0)
 
 
** On the other hand, the effect of Attiribute two remains relatively small:

margins i.att2, at(att1 = (1(1)3)) outcome(concept_2) alternative(concept_2)
marginsplot, recast(dot) plotopts(dcolor(white%0) msize(large)) ///
 ciopts(color(%100)) ///
 plot3opts(dcolor(black) msymbol(D) mcolor(black)) ci3opts(color(black%80)) ///
 ylab(0(0.1)0.7) xtitle("")legend(pos(6) row(1))
 
 margins, dydx(att2) at(att1 = (1(1)3)) outcome(concept_2) alternative(concept_2)

 marginsplot, recast(dot) plotopts(dcolor(white%0) msize(large)) ///
 ciopts(color(%100)) ///
 plot1opts(dcolor(orange) msymbol(O) mcolor(orange)) ///
 ci1opts(color(orange%80)) ///
 plot2opts(dcolor(black) msymbol(D) mcolor(black)) ///
 ci2opts(color(black%80)) yline(0)

//-> we see a that the effect of att1 is even stronger for the first level of attribute two, and it's the only level a high stone coverage is substantively different from the other two. FInally, the effets of attribute 2 remains relatively small in this model. And the average marginal effects although doesn't include zero, gets very close to it.


** APPENDIX A - As clear in the plots: for the other attributes it doesn't matter which levels we focus on in terms of pricing. None of them increase the probability of purchasing concept_2

* Attribute 2
*- Predicted Probabilities 
margins i.att2, at(price = (79(50)789)) outcome(concept_2) alternative(concept_2)
marginsplot, recast(line) recastci(rarea) ciopts(color(%20)) plotopts(bcolor(%50)) ylab(0(0.1)0.7) xtitle("")legend(pos(6) row(1))
*- AME
margins, dydx(i.att2) at(price = (79(50)789)) outcome(concept_2) alternative(concept_2)
marginsplot, recast(line) ciopts(recast(rarea) color(%20)) legend(pos(6) row(1)) yline(0, lcolor(black%50))

* Attribute 3
*- Predicted Probabilities
margins i.att3, at(price = (79(50)789)) outcome(concept_2) alternative(concept_2)
marginsplot, recast(line) recastci(rarea) ciopts(color(%20)) plotopts(bcolor(%50)) ylab(0(0.1)0.7) xtitle("")legend(pos(6) row(1))
*- AME
margins, dydx(i.att3) at(price = (79(50)789)) outcome(concept_2) alternative(concept_2)
marginsplot, recast(line) ciopts(recast(rarea) color(%20)) legend(pos(6) row(1)) yline(0, lcolor(black%50))

* Attribute 4
*- Predicted Probabilities
margins i.att4, at(price = (79(50)789)) outcome(concept_2) alternative(concept_2)
marginsplot, recast(line) recastci(rarea) ciopts(color(%20)) plotopts(bcolor(%50)) ylab(0(0.1)0.7) xtitle("")legend(pos(6) row(1))
*- AME
margins, dydx(i.att4) at(price = (79(50)789)) outcome(concept_2) alternative(concept_2)
marginsplot, recast(line) ciopts(recast(rarea) color(%20)) legend(pos(6) row(1)) yline(0, lcolor(black%50))

* Attribute 5
*- Predicted Probabilities
margins i.att5, at(price = (79(50)789)) outcome(concept_2) alternative(concept_2)
marginsplot, recast(line) recastci(rarea) ciopts(color(%20)) plotopts(bcolor(%50)) ylab(0(0.1)0.7) xtitle("")legend(pos(6) row(1))
*- AME
margins, dydx(i.att5) at(price = (79(50)789)) outcome(concept_2) alternative(concept_2)
marginsplot, recast(line) ciopts(recast(rarea) color(%20)) legend(pos(6) row(1)) yline(0, lcolor(black%50))

/*********************************************************************
                               CONCEPT_3	   
**********************************************************************/

** For attribute 1
*- Predicted Probabilities
margins i.att1, at(price = (79(50)789)) outcome(concept_3) alternative(concept_3)
marginsplot, recast(line) recastci(rarea) ciopts(color(%20)) plotopts(bcolor(%50)) ylab(0(0.1)0.7) xtitle("")legend(pos(6) row(1))
*- AME 
margins, dydx(i.att1) at(price = (79(50)789)) outcome(concept_3) alternative(concept_3)
marginsplot, recast(line) ciopts(recast(rarea) color(%20)) legend(pos(6) row(1)) yline(0, lcolor(black%50))

/*********************************************************************
                               CONCEPT_1 
**********************************************************************/

** For attribute 1
*- Predicted Probabilities
margins i.att1, at(price = (79(50)789)) outcome(concept_1) alternative(concept_1)
marginsplot, recast(line) recastci(rarea) ciopts(color(%20)) plotopts(bcolor(%50)) ylab(0(0.1)0.7) xtitle("")legend(pos(6) row(1))
*- AME 
margins, dydx(i.att1) at(price = (79(50)789)) outcome(concept_1) alternative(concept_1)
marginsplot, recast(line) ciopts(recast(rarea) color(%20)) legend(pos(6) row(1)) yline(0, lcolor(black%50))


*** Including a random slope for the attribute 1: 
cmxtmixlogit choice i.price i.att2 i.att3 i.att4 i.att5, random(i.att1) basealternative("1")
est store B
lrtest A B 

*** Including a random slope for attributes 1 and 2: 
cmxtmixlogit choice i.price i.att3 i.att4 i.att5, random(i.att1) random(i.att2) basealternative("1")
est store C 
lrtest B C // it doesn't improve the fit of the model.



clogit choice i.concept i.att1 i.att2 i.att3 i.att4 i.att5 price, group(_caseid)
cmmixlogit choice price i.att1 i.att2 i.att3 i.att4 i.att5, basealternative("1")
 

/*The results do not change substantively after adding the random slope for both attributes 1 and 2. I stop here and move forward to give a more clear interpretation of the coefficients. I assess the predicted probabilities and marginal effects of attributes across different price ranges.
The estimation of predicted probabilities and average marginal effects across covariates is very complex in the case of Panel-data mixed logit models (as it is for mixed-logit cross-sectional models). 
The estimation dependends on which one focus on. 
For instance, as you can see in FIGURE X, the predicted probabilities of attributes 1 across price levels depended on which concept we are referencing our estimates.

I take them two approaches:

1) I calculated what seemed to me the most intuitive scenario: each alternative-specific covariate (price, in particular) was assumed to change simultaneously across all alternatives.

2) I calculated what seemed to me the most intuitive scenario: Controlling for all features concept_2 was the most preferred one. Therefore I estimated a scenario where Jewelry X goes for concept 2. What would be the best approach. each alternative-specific covariate (price, in particular) was assumed to change simultaneously across all alternatives.
 
TESTED MODELS: hypothetical scenariosmodel with random slope for att1 and price with interaction.

cmxtmixlogit choice price i.att3 i.att4 i.att5, basealternative("1") random(i.att1##i.att2) // It didn't converge!!!
For this data, because there was not case-specific variables and lags were not explored I could have worked as if the data was cross-sectional. The coefficients are exactly the same. Yet, the standard errors differ due to estimation differences and sufficiently enough lead to different conclusions for the concepts. Additionaly, this data has a panel structure with 3 different time periods(tasks) and the cross-sectional model ignores that structure.
*/
