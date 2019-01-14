*****question 1**********;
***some basic analysis***;
proc sort data=final out=q1;
by Race Exonerated;
run;
data q1;
set q1;
keep Race No_Time State_Claim_Made Non_Statutory_Case_Filed Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Claim_Made=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data state;
set q2;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Claim_Made=. then State_Claim_Made=0;
run;

data two_situation;
set q1;
if State_Claim_Made=0 and Non_Statutory_Case_Filed=1 then only_civil=1;
else only_civil=0;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=1 then both_=1;
else both_=0;
run;

**** To prove whether there are different between different Race;
****assumption: Cause we are not interest in the people who do not filling compensation, so in this situation, in order to avoid 
the possible error of missing value, let set empty to be zero****;

***the likelihood of filling compensation between race****;

proc sql;
create table only_state as
select distinct(Race) as Race, sum(only_state)/count(Race) as only_state
from state
group by Race;

proc sql;
create table only_civil as
select distinct(Race) as Race, sum(only_civil)/count(Race) as only_civil
from two_situation
group by Race;

proc sql;
create table both as
select distinct(Race) as Race, sum(both_)/count(Race) as both_
from two_situation
group by Race;

proc sql;
create table likelihood as 
select a.Race,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.Race=b.Race and a.Race=c.Race;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*Race only_civil*Race both_*Race / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class Race;
model only_state=Race;
run;
proc anova data=two_situation;
class Race;
model only_civil=Race;
run;
proc anova data=two_situation;
class Race;
model both=Race;
run;
proc npar1way data=state wilcoxon;
class Race;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class Race;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class Race;
var both_;
run;


****relationship change over time**********************************************************;
proc sort data=state;
by Race Exonerated;
run;

proc sort data=two_situation;
by Race Exonerated;
run;


proc glm data=state;
class Exonerated Race;
model only_state=Exonerated|Race;
run;

proc glm data=two_situation;
class Exonerated Race;
model only_civil=Exonerated|Race;
run;

proc glm data=two_situation;
class Exonerated Race;
model both_=Exonerated|Race;
run;


******the impact of time lost************************************************************;
proc corr data=state pearson spearman;
var Years_Lost only_state;
run;

proc corr data=two_situation pearson spearman;
var Years_Lost only_civil;
run;

proc corr data=two_situation pearson spearman;
var Years_Lost both_;
run;

proc glm data=state;
class Race;
model only_state=Years_Lost;
run;


proc glm data=state;
class Race;
model only_state=Race | Years_Lost;
run;

proc logistic data=state PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model only_state(event='1')=Years_Lost;
   effectplot /noobs ;
run;

ods graphics on;
proc logistic data=state PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model only_state(event='1')= Race Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Race) / noobs ;
run;

ods graphics on;
proc gampl data=state plots seed=12345;
class Race;
model only_state(event='1') = spline(Years_Lost)/dist=binary;
run;

*;

proc glm data=two_situation;
class Race;
model only_civil=Years_Lost;
run;


proc glm data=two_situation;
class Race;
model only_civil=Race | Years_Lost;
run;

proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model only_civil(event='1')=Years_Lost;
   effectplot /noobs ;
run;

ods graphics on;
proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model only_civil(event='1')= Race Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Race) / noobs ;
run;

ods graphics on;
proc gampl data=two_situation plots seed=12345;
class Race;
model only_civil(event='1') = spline(Years_Lost)/dist=binary;
run;

*;

proc glm data=two_situation;
class Race;
model both_=Years_Lost;
run;


proc glm data=two_situation;
class Race;
model both_=Race | Years_Lost;
run;

proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model both_(event='1')=Years_Lost;
   effectplot /noobs ;
run;

ods graphics on;
proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model both_(event='1')= Race Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Race) / noobs ;
run;

ods graphics on;
proc gampl data=two_situation plots seed=12345;
class Race;
model both_(event='1') = spline(Years_Lost)/dist=binary;
run;

**************************************************
**************************************************
question 2;

 ***/////////////preprocessing;
proc sort data=final out=q1;
by Race Exonerated;
run;
data q1;
set q1;
keep Race No_Time State_Award Award Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between race****;

proc sql;
create table only_state as
select distinct(Race) as Race, sum(only_state)/count(Race) as only_state
from state
group by Race;

proc sql;
create table only_civil as
select distinct(Race) as Race, sum(only_civil)/count(Race) as only_civil
from two_situation
group by Race;

proc sql;
create table both as
select distinct(Race) as Race, sum(both_)/count(Race) as both_
from two_situation
group by Race;

proc sql;
create table likelihood as 
select a.Race,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.Race=b.Race and a.Race=c.Race;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*Race only_civil*Race both_*Race / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class Race;
model only_state=Race;
run;
proc anova data=two_situation;
class Race;
model only_civil=Race;
run;
proc anova data=two_situation;
class Race;
model both_=Race;
run;
proc npar1way data=state wilcoxon;
class Race;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class Race;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class Race;
var both_;
run;


****relationship change over time**********************************************************;
proc sort data=state;
by Race Exonerated;
run;

proc sort data=two_situation;
by Race Exonerated;
run;


proc glm data=state;
class Exonerated Race;
model only_state=Exonerated|Race;
run;

proc glm data=two_situation;
class Exonerated Race;
model only_civil=Exonerated|Race;
run;

proc glm data=two_situation;
class Exonerated Race;
model both_=Exonerated|Race;
run;


******the impact of time lost************************************************************;
proc corr data=state pearson spearman;
var Years_Lost only_state;
run;

proc corr data=two_situation pearson spearman;
var Years_Lost only_civil;
run;

proc corr data=two_situation pearson spearman;
var Years_Lost both_;
run;

proc glm data=state;
class Race;
model only_state=Years_Lost;
run;


proc glm data=state;
class Race;
model only_state=Race | Years_Lost;
run;

proc logistic data=state PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model only_state(event='1')=Years_Lost;
   effectplot /noobs ;
run;

ods graphics on;
proc logistic data=state PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model only_state(event='1')= Race Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Race) / noobs ;
run;

ods graphics on;
proc gampl data=state plots seed=12345;
class Race;
model only_state(event='1') = spline(Years_Lost)/dist=binary;
run;

*;

proc glm data=two_situation;
class Race;
model only_civil=Years_Lost;
run;


proc glm data=two_situation;
class Race;
model only_civil=Race | Years_Lost;
run;

proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model only_civil(event='1')=Years_Lost;
   effectplot /noobs ;
run;

ods graphics on;
proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model only_civil(event='1')= Race Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Race) / noobs ;
run;

ods graphics on;
proc gampl data=two_situation plots seed=12345;
class Race;
model only_civil(event='1') = spline(Years_Lost)/dist=binary;
run;

*;

proc glm data=two_situation;
class Race;
model both_=Years_Lost;
run;


proc glm data=two_situation;
class Race;
model both_=Race | Years_Lost;
run;

proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model both_(event='1')=Years_Lost;
   effectplot /noobs ;
run;

ods graphics on;
proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model both_(event='1')= Race Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Race) / noobs ;
run;

ods graphics on;
proc gampl data=two_situation plots seed=12345;
class Race;
model both_(event='1') = spline(Years_Lost)/dist=binary;
run;


******question 3***************************************************************************;
proc sort data=final out=q1;
by Race Exonerated;
run;

data q1;
set q1;
keep Race Amount_c Exonerated Years_Lost;
run;

data q1;
set q1;
if Amount_c=0 then delete;
run;

data q1;
set q1;
if Amount_c=. then delete;
run;

data q1;
set q1;
if Years_Lost=0 then delete;
run;

data civil;
set q1;
amount_per=Amount_c/Years_Lost;
run;

*********;
proc univariate data=civil;
class Race;
var amount_per;
histogram amount_per; 
qqplot amount_per;
run;

proc anova data=civil;
class Race;
model amount_per=Race;
run;

proc npar1way data=civil wilcoxon;
class Race;
var amount_per;
run;

*********************************************************;
proc corr data=civil pearson spearman;
var Exonerated amount_c;
run;

proc glm data=civil;
class Exonerated Race;
model amount_per=Exonerated|Race;
run;








*******question 4 *******************************************************************;
proc sort data=final out=q1;
by Sex Exonerated;
run;
data q1;
set q1;
keep Sex No_Time State_Claim_Made Non_Statutory_Case_Filed Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Claim_Made=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data state;
set q2;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Claim_Made=. then State_Claim_Made=0;
run;

data two_situation;
set q1;
if State_Claim_Made=0 and Non_Statutory_Case_Filed=1 then only_civil=1;
else only_civil=0;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=1 then both_=1;
else both_=0;
run;

**** To prove whether there are different between different Race;
****assumption: Cause we are not interest in the people who do not filling compensation, so in this situation, in order to avoid 
the possible error of missing value, let set empty to be zero****;

***the likelihood of filling compensation between race****;

proc sql;
create table only_state as
select distinct(Sex) as Sex, sum(only_state)/count(Sex) as only_state
from state
group by Sex;

proc sql;
create table only_civil as
select distinct(Sex) as Sex, sum(only_civil)/count(Sex) as only_civil
from two_situation
group by Sex;

proc sql;
create table both as
select distinct(Sex) as Sex, sum(both_)/count(Sex) as both_
from two_situation
group by Sex;

proc sql;
create table likelihood as 
select a.Sex,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.Sex=b.Sex and a.Sex=c.Sex;
run;

proc print data=likelihood;
run;

data plot_table;
input sex $ kind $ likelihood;
cards;
female only_state 0.201
female only_civil 0.227
female both 0.0889
male only_state 0.249
male only_civil 0.2
male both 0.226
;
run;

proc gchart data=plot_table;                                                                                                       
   vbar kind / subgroup=kind group=sex sumvar=likelihood                                                                           
                  space=0 gspace=4 ;                                                                                       
                                                                                                    
run;                                                                                                                                    
quit;    

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*Sex only_civil*Sex both_*Sex / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class Sex;
model only_state=Sex;
run;
proc anova data=two_situation;
class Sex;
model only_civil=Sex;
run;
proc anova data=two_situation;
class Sex;
model both_=Sex;
run;
proc npar1way data=state wilcoxon;
class Sex;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class Sex;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class Sex;
var both_;
run;


****relationship change over time**********************************************************;
proc sort data=state;
by Sex Exonerated;
run;

proc sort data=two_situation;
by Sex Exonerated;
run;


proc glm data=state;
class Exonerated Sex;
model only_state=Exonerated|Sex;
run;

proc glm data=two_situation;
class Exonerated Sex;
model only_civil=Exonerated|Sex;
run;

proc glm data=two_situation;
class Exonerated Sex;
model both_=Exonerated|Sex;
run;


******the impact of time lost************************************************************;
proc corr data=state pearson spearman;
var Years_Lost only_state;
run;

proc corr data=two_situation pearson spearman;
var Years_Lost only_civil;
run;

proc corr data=two_situation pearson spearman;
var Years_Lost both_;
run;

proc glm data=state;
class Sex;
model only_state=Years_Lost;
run;


proc glm data=state;
class Sex;
model only_state=Sex | Years_Lost;
run;

proc logistic data=state PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Sex /param=ref;
   model only_state(event='1')=Years_Lost;
   effectplot /noobs ;
run;

ods graphics on;
proc logistic data=state PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Sex /param=ref;
   model only_state(event='1')= Sex Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Sex) / noobs ;
run;

ods graphics on;
proc gampl data=state plots seed=12345;
class Sex;
model only_state(event='1') = spline(Years_Lost)/dist=binary;
run;

*;

proc glm data=two_situation;
class Sex;
model only_civil=Years_Lost;
run;


proc glm data=two_situation;
class Sex;
model only_civil=Sex | Years_Lost;
run;

proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Sex /param=ref;
   model only_civil(event='1')=Years_Lost;
   effectplot /noobs ;
run;

ods graphics on;
proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Sex /param=ref;
   model only_civil(event='1')= Sex Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Sex) / noobs ;
run;

ods graphics on;
proc gampl data=two_situation plots seed=12345;
class Sex;
model only_civil(event='1') = spline(Years_Lost)/dist=binary;
run;

*;

proc glm data=two_situation;
class Sex;
model both_=Years_Lost;
run;


proc glm data=two_situation;
class Sex;
model both_=Sex | Years_Lost;
run;

proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Sex /param=ref;
   model both_(event='1')=Years_Lost;
   effectplot /noobs ;
run;

ods graphics on;
proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Sex /param=ref;
   model both_(event='1')= Sex Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Sex) / noobs ;
run;

ods graphics on;
proc gampl data=two_situation plots seed=12345;
class Sex;
model both_(event='1') = spline(Years_Lost)/dist=binary;
run;


***********question 5***************************************************************************;
***/////////////preprocessing;
proc sort data=final out=q1;
by Sex Exonerated;
run;
data q1;
set q1;
keep Sex No_Time State_Award Award Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between Sex****;

proc sql;
create table only_state as
select distinct(Sex) as Sex, sum(only_state)/count(Sex) as only_state
from state
group by Sex;

proc sql;
create table only_civil as
select distinct(Sex) as Sex, sum(only_civil)/count(Sex) as only_civil
from two_situation
group by Sex;

proc sql;
create table both as
select distinct(Sex) as Sex, sum(both_)/count(Sex) as both_
from two_situation
group by Sex;

proc sql;
create table likelihood as 
select a.Sex,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.Sex=b.Sex and a.Sex=c.Sex;
run;

proc print data=likelihood;
run;

data plot_table;
input sex $ kind $ likelihood;
cards;
Female	only_state	0.15789
Female	only_civil	0.09444
Female	both_	0.05
Male	only_state	0.24749
Male	only_civil	0.10756
Male	both_	0.11395

;
run;

proc gchart data=plot_table;                                                                                                       
   vbar kind / subgroup=kind group=sex sumvar=likelihood                                                                           
                  space=0 gspace=4 ;                                                                                       
                                                                                                    
run;                                                                                                                                    
quit; 

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*Sex only_civil*Sex both_*Sex / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class Sex;
model only_state=Sex;
run;
proc anova data=two_situation;
class Sex;
model only_civil=Sex;
run;
proc anova data=two_situation;
class Sex;
model both_=Sex;
run;
proc npar1way data=state wilcoxon;
class Sex;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class Sex;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class Sex;
var both_;
run;


****relationship change over time**********************************************************;
proc sort data=state;
by Sex Exonerated;
run;

proc sort data=two_situation;
by Sex Exonerated;
run;


proc glm data=state;
class Exonerated Sex;
model only_state=Exonerated|Sex;
run;

proc glm data=two_situation;
class Exonerated Sex;
model only_civil=Exonerated|Sex;
run;

proc glm data=two_situation;
class Exonerated Sex;
model both_=Exonerated|Sex;
run;


******the impact of time lost************************************************************;
proc corr data=state pearson spearman;
var Years_Lost only_state;
run;

proc corr data=two_situation pearson spearman;
var Years_Lost only_civil;
run;

proc corr data=two_situation pearson spearman;
var Years_Lost both_;
run;

proc glm data=state;
class Sex;
model only_state=Years_Lost;
run;


proc glm data=state;
class Sex;
model only_state=Sex | Years_Lost;
run;

proc logistic data=state PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Sex /param=ref;
   model only_state(event='1')=Years_Lost;
   effectplot /noobs ;
run;

ods graphics on;
proc logistic data=state PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Sex /param=ref;
   model only_state(event='1')= Sex Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Sex) / noobs ;
run;

ods graphics on;
proc gampl data=state plots seed=12345;
class Sex;
model only_state(event='1') = spline(Years_Lost)/dist=binary;
run;

*;

proc glm data=two_situation;
class Sex;
model only_civil=Years_Lost;
run;


proc glm data=two_situation;
class Sex;
model only_civil=Sex | Years_Lost;
run;

proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Sex /param=ref;
   model only_civil(event='1')=Years_Lost;
   effectplot /noobs ;
run;

ods graphics on;
proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Sex /param=ref;
   model only_civil(event='1')= Sex Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Sex) / noobs ;
run;

ods graphics on;
proc gampl data=two_situation plots seed=12345;
class Sex;
model only_civil(event='1') = spline(Years_Lost)/dist=binary;
run;

*;

proc glm data=two_situation;
class Sex;
model both_=Years_Lost;
run;


proc glm data=two_situation;
class Sex;
model both_=Sex | Years_Lost;
run;

proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Sex /param=ref;
   model both_(event='1')=Years_Lost;
   effectplot /noobs ;
run;

ods graphics on;
proc logistic data=two_situation PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Sex /param=ref;
   model both_(event='1')= Sex Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Sex) / noobs ;
run;

ods graphics on;
proc gampl data=two_situation plots seed=12345;
class Sex;
model both_(event='1') = spline(Years_Lost)/dist=binary;
run;


****question 6**********************************************************;
proc sort data=final out=q1;
by Sex Exonerated;
run;

data q1;
set q1;
keep Sex Amount_c Exonerated Years_Lost;
run;

data q1;
set q1;
if Amount_c=0 then delete;
run;

data q1;
set q1;
if Amount_c=. then delete;
run;

data q1;
set q1;
if Years_Lost=0 then delete;
run;

data civil;
set q1;
amount_per=Amount_c/Years_Lost;
run;

*********;
proc univariate data=civil;
class Sex;
var amount_per;
histogram amount_per; 
qqplot amount_per;
run;

proc anova data=civil;
class Sex;
model amount_per=Sex;
run;

proc npar1way data=civil wilcoxon;
class Sex;
var amount_per;
run;

*********************************************************;
proc corr data=civil pearson spearman;
var Exonerated amount_c;
run;

proc glm data=civil;
class Exonerated Sex;
model amount_per=Exonerated|Sex;
run;



***question 7 *******************************************************************;

proc sort data=area_1 out=q1;
by State;
run;
data q1;
set q1;
keep State No_Time State_Claim_Made Non_Statutory_Case_Filed;
run;
data q2;
set q1;
if State_Claim_Made=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data state;
set q2;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Claim_Made=. then State_Claim_Made=0;
run;

data two_situation;
set q1;
if State_Claim_Made=0 and Non_Statutory_Case_Filed=1 then only_civil=1;
else only_civil=0;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=1 then both_=1;
else both_=0;
run;

**** To prove whether there are different between different State;
****assumption: Cause we are not interest in the people who do not filling compensation, so in this situation, in order to avoid 
the possible error of missing value, let set empty to be zero****;

***the likelihood of filling compensation between State****;

proc sql;
create table only_state as
select distinct(State) as State, sum(only_state)/count(State) as only_state
from state
group by State;

proc sql;
create table only_civil as
select distinct(State) as State, sum(only_civil)/count(State) as only_civil
from two_situation
group by State;

proc sql;
create table both as
select distinct(State) as State, sum(both_)/count(State) as both_
from two_situation
group by State;

proc sql;
create table likelihood as 
select a.State,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.State=b.State and a.State=c.State;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*State only_civil*State both_*State / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class State;
model only_state=State;
run;
proc anova data=two_situation;
class State;
model only_civil=State;
run;
proc anova data=two_situation;
class State;
model both=State;
run;
proc npar1way data=state wilcoxon;
class State;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class State;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class State;
var both_;
run;


*******question 8 *******************************************************************;
***/////////////preprocessing;
proc sort data=area_1 out=q1;
by State;
run;
data q1;
set q1;
keep State No_Time State_Award Award Exonerated;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between State****;

proc sql;
create table only_state as
select distinct(State) as State, sum(only_state)/count(State) as only_state
from state
group by State;

proc sql;
create table only_civil as
select distinct(State) as State, sum(only_civil)/count(State) as only_civil
from two_situation
group by State;

proc sql;
create table both as
select distinct(State) as State, sum(both_)/count(State) as both_
from two_situation
group by State;

proc sql;
create table likelihood as 
select a.State,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.State=b.State and a.State=c.State;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*State only_civil*State both_*State / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class State;
model only_state=State;
run;
proc anova data=two_situation;
class State;
model only_civil=State;
run;
proc anova data=two_situation;
class State;
model both_=State;
run;
proc npar1way data=state wilcoxon;
class State;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class State;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class State;
var both_;
run;


********question 9************;
***/////////////preprocessing;
proc sort data=area_1 out=q1;
by State;
run;
data q1;
set q1;
keep State No_Time State_Award Award Exonerated;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between State****;

proc sql;
create table only_state as
select distinct(State) as State, sum(only_state)/count(State) as only_state
from state
group by State;

proc sql;
create table only_civil as
select distinct(State) as State, sum(only_civil)/count(State) as only_civil
from two_situation
group by State;

proc sql;
create table both as
select distinct(State) as State, sum(both_)/count(State) as both_
from two_situation
group by State;

proc sql;
create table likelihood as 
select a.State,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.State=b.State and a.State=c.State;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*State only_civil*State both_*State / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class State;
model only_state=State;
run;
proc anova data=two_situation;
class State;
model only_civil=State;
run;
proc anova data=two_situation;
class State;
model both_=State;
run;
proc npar1way data=state wilcoxon;
class State;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class State;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class State;
var both_;
run;


****question 10 ********;
***/////////////preprocessing;
proc sort data=color_area_1 out=q1;
by State Exonerated;
run;
data q1;
set q1;
keep State No_Time State_Award Award Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between State****;

proc sql;
create table only_state as
select distinct(State) as State, sum(only_state)/count(State) as only_state
from state
group by State;

proc sql;
create table only_civil as
select distinct(State) as State, sum(only_civil)/count(State) as only_civil
from two_situation
group by State;

proc sql;
create table both as
select distinct(State) as State, sum(both_)/count(State) as both_
from two_situation
group by State;

proc sql;
create table likelihood as 
select a.State,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.State=b.State and a.State=c.State;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*State only_civil*State both_*State / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class State;
model only_state=State;
run;
proc anova data=two_situation;
class State;
model only_civil=State;
run;
proc anova data=two_situation;
class State;
model both_=State;
run;
proc npar1way data=state wilcoxon;
class State;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class State;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class State;
var both_;
run;



******question 11*******************************************************;
******filling********************************************
proc sort data=final out=q1;
by CIU Exonerated;
run;
data q1;
set q1;
keep CIU No_Time State_Claim_Made Non_Statutory_Case_Filed Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Claim_Made=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data state;
set q2;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Claim_Made=. then State_Claim_Made=0;
run;

data two_situation;
set q1;
if State_Claim_Made=0 and Non_Statutory_Case_Filed=1 then only_civil=1;
else only_civil=0;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=1 then both_=1;
else both_=0;
run;

**** To prove whether there are different between different CIU;
****assumption: Cause we are not interest in the people who do not filling compensation, so in this situation, in order to avoid 
the possible error of missing value, let set empty to be zero****;

***the likelihood of filling compensation between CIU****;

proc sql;
create table only_state as
select distinct(CIU) as CIU, sum(only_state)/count(CIU) as only_state
from state
group by CIU;

proc sql;
create table only_civil as
select distinct(CIU) as CIU, sum(only_civil)/count(CIU) as only_civil
from two_situation
group by CIU;

proc sql;
create table both as
select distinct(CIU) as CIU, sum(both_)/count(CIU) as both_
from two_situation
group by CIU;

proc sql;
create table likelihood as 
select a.CIU,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.CIU=b.CIU and a.CIU=c.CIU;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*CIU only_civil*CIU both_*CIU / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class CIU;
model only_state=CIU;
run;
proc anova data=two_situation;
class CIU;
model only_civil=CIU;
run;
proc anova data=two_situation;
class CIU;
model both=CIU;
run;
proc npar1way data=state wilcoxon;
class CIU;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class CIU;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class CIU;
var both_;
run;
**********PREVAILING*************************************;
***/////////////preprocessing;
proc sort data=final out=q1;
by CIU Exonerated;
run;
data q1;
set q1;
keep CIU No_Time State_Award Award Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between CIU****;

proc sql;
create table only_state as
select distinct(CIU) as CIU, sum(only_state)/count(CIU) as only_state
from state
group by CIU;

proc sql;
create table only_civil as
select distinct(CIU) as CIU, sum(only_civil)/count(CIU) as only_civil
from two_situation
group by CIU;

proc sql;
create table both as
select distinct(CIU) as CIU, sum(both_)/count(CIU) as both_
from two_situation
group by CIU;

proc sql;
create table likelihood as 
select a.CIU,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.CIU=b.CIU and a.CIU=c.CIU;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*CIU only_civil*CIU both_*CIU / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class CIU;
model only_state=CIU;
run;
proc anova data=two_situation;
class CIU;
model only_civil=CIU;
run;
proc anova data=two_situation;
class CIU;
model both_=CIU;
run;
proc npar1way data=state wilcoxon;
class CIU;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class CIU;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class CIU;
var both_;
run;


**********************QUESTION 12**************************************;
******filling********************************************
proc sort data=final out=q1;
by Guilty_Plea Exonerated;
run;
data q1;
set q1;
keep Guilty_Plea No_Time State_Claim_Made Non_Statutory_Case_Filed Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Claim_Made=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data state;
set q2;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Claim_Made=. then State_Claim_Made=0;
run;

data two_situation;
set q1;
if State_Claim_Made=0 and Non_Statutory_Case_Filed=1 then only_civil=1;
else only_civil=0;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=1 then both_=1;
else both_=0;
run;

**** To prove whether there are different between different Guilty_Plea;
****assumption: Cause we are not interest in the people who do not filling compensation, so in this situation, in order to avoid 
the possible error of missing value, let set empty to be zero****;

***the likelihood of filling compensation between Guilty_Plea****;

proc sql;
create table only_state as
select distinct(Guilty_Plea) as Guilty_Plea, sum(only_state)/count(Guilty_Plea) as only_state
from state
group by Guilty_Plea;

proc sql;
create table only_civil as
select distinct(Guilty_Plea) as Guilty_Plea, sum(only_civil)/count(Guilty_Plea) as only_civil
from two_situation
group by Guilty_Plea;

proc sql;
create table both as
select distinct(Guilty_Plea) as Guilty_Plea, sum(both_)/count(Guilty_Plea) as both_
from two_situation
group by Guilty_Plea;

proc sql;
create table likelihood as 
select a.Guilty_Plea,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.Guilty_Plea=b.Guilty_Plea and a.Guilty_Plea=c.Guilty_Plea;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*Guilty_Plea only_civil*Guilty_Plea both_*Guilty_Plea / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class Guilty_Plea;
model only_state=Guilty_Plea;
run;
proc anova data=two_situation;
class Guilty_Plea;
model only_civil=Guilty_Plea;
run;
proc anova data=two_situation;
class Guilty_Plea;
model both=Guilty_Plea;
run;
proc npar1way data=state wilcoxon;
class Guilty_Plea;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class Guilty_Plea;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class Guilty_Plea;
var both_;
run;
**********PREVAILING*************************************;
***/////////////preprocessing;
proc sort data=final out=q1;
by Guilty_Plea Exonerated;
run;
data q1;
set q1;
keep Guilty_Plea No_Time State_Award Award Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between Guilty_Plea****;

proc sql;
create table only_state as
select distinct(Guilty_Plea) as Guilty_Plea, sum(only_state)/count(Guilty_Plea) as only_state
from state
group by Guilty_Plea;

proc sql;
create table only_civil as
select distinct(Guilty_Plea) as Guilty_Plea, sum(only_civil)/count(Guilty_Plea) as only_civil
from two_situation
group by Guilty_Plea;

proc sql;
create table both as
select distinct(Guilty_Plea) as Guilty_Plea, sum(both_)/count(Guilty_Plea) as both_
from two_situation
group by Guilty_Plea;

proc sql;
create table likelihood as 
select a.Guilty_Plea,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.Guilty_Plea=b.Guilty_Plea and a.Guilty_Plea=c.Guilty_Plea;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*Guilty_Plea only_civil*Guilty_Plea both_*Guilty_Plea / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class Guilty_Plea;
model only_state=Guilty_Plea;
run;
proc anova data=two_situation;
class Guilty_Plea;
model only_civil=Guilty_Plea;
run;
proc anova data=two_situation;
class Guilty_Plea;
model both_=Guilty_Plea;
run;
proc npar1way data=state wilcoxon;
class Guilty_Plea;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class Guilty_Plea;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class Guilty_Plea;
var both_;
run;


*****************QUESTION 13*******************************'
******filling********************************************
proc sort data=final out=q1;
by IO Exonerated;
run;
data q1;
set q1;
keep IO No_Time State_Claim_Made Non_Statutory_Case_Filed Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Claim_Made=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data state;
set q2;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Claim_Made=. then State_Claim_Made=0;
run;

data two_situation;
set q1;
if State_Claim_Made=0 and Non_Statutory_Case_Filed=1 then only_civil=1;
else only_civil=0;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=1 then both_=1;
else both_=0;
run;

**** To prove whether there are different between different IO;
****assumption: Cause we are not interest in the people who do not filling compensation, so in this situation, in order to avoid 
the possible error of missing value, let set empty to be zero****;

***the likelihood of filling compensation between IO****;

proc sql;
create table only_state as
select distinct(IO) as IO, sum(only_state)/count(IO) as only_state
from state
group by IO;

proc sql;
create table only_civil as
select distinct(IO) as IO, sum(only_civil)/count(IO) as only_civil
from two_situation
group by IO;

proc sql;
create table both as
select distinct(IO) as IO, sum(both_)/count(IO) as both_
from two_situation
group by IO;

proc sql;
create table likelihood as 
select a.IO,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.IO=b.IO and a.IO=c.IO;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*IO only_civil*IO both_*IO / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class IO;
model only_state=IO;
run;
proc anova data=two_situation;
class IO;
model only_civil=IO;
run;
proc anova data=two_situation;
class IO;
model both=IO;
run;
proc npar1way data=state wilcoxon;
class IO;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class IO;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class IO;
var both_;
run;
**********PREVAILING*************************************;
***/////////////preprocessing;
proc sort data=final out=q1;
by IO Exonerated;
run;
data q1;
set q1;
keep IO No_Time State_Award Award Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between IO****;

proc sql;
create table only_state as
select distinct(IO) as IO, sum(only_state)/count(IO) as only_state
from state
group by IO;

proc sql;
create table only_civil as
select distinct(IO) as IO, sum(only_civil)/count(IO) as only_civil
from two_situation
group by IO;

proc sql;
create table both as
select distinct(IO) as IO, sum(both_)/count(IO) as both_
from two_situation
group by IO;

proc sql;
create table likelihood as 
select a.IO,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.IO=b.IO and a.IO=c.IO;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*IO only_civil*IO both_*IO / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class IO;
model only_state=IO;
run;
proc anova data=two_situation;
class IO;
model only_civil=IO;
run;
proc anova data=two_situation;
class IO;
model both_=IO;
run;
proc npar1way data=state wilcoxon;
class IO;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class IO;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class IO;
var both_;
run;


*******************question 14*******************************;

******filling********************************************
proc sort data=final out=q1;
by Worst_Crime Exonerated;
run;
data q1;
set q1;
keep Worst_Crime No_Time State_Claim_Made Non_Statutory_Case_Filed Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Claim_Made=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data state;
set q2;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Claim_Made=. then State_Claim_Made=0;
run;

data two_situation;
set q1;
if State_Claim_Made=0 and Non_Statutory_Case_Filed=1 then only_civil=1;
else only_civil=0;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=1 then both_=1;
else both_=0;
run;

**** To prove whether there are different between different Worst_Crime;
****assumption: Cause we are not interest in the people who do not filling compensation, so in this situation, in order to avoid 
the possible error of missing value, let set empty to be zero****;

***the likelihood of filling compensation between Worst_Crime****;

proc sql;
create table only_state as
select distinct(Worst_Crime) as Worst_Crime, sum(only_state)/count(Worst_Crime) as only_state
from state
group by Worst_Crime;

proc sql;
create table only_civil as
select distinct(Worst_Crime) as Worst_Crime, sum(only_civil)/count(Worst_Crime) as only_civil
from two_situation
group by Worst_Crime;

proc sql;
create table both as
select distinct(Worst_Crime) as Worst_Crime, sum(both_)/count(Worst_Crime) as both_
from two_situation
group by Worst_Crime;

proc sql;
create table likelihood as 
select a.Worst_Crime,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.Worst_Crime=b.Worst_Crime and a.Worst_Crime=c.Worst_Crime;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*Worst_Crime only_civil*Worst_Crime both_*Worst_Crime / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class Worst_Crime;
model only_state=Worst_Crime;
run;
proc anova data=two_situation;
class Worst_Crime;
model only_civil=Worst_Crime;
run;
proc anova data=two_situation;
class Worst_Crime;
model both=Worst_Crime;
run;
proc npar1way data=state wilcoxon;
class Worst_Crime;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class Worst_Crime;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class Worst_Crime;
var both_;
run;
**********PREVAILING*************************************;
***/////////////preprocessing;
proc sort data=final out=q1;
by Worst_Crime Exonerated;
run;
data q1;
set q1;
keep Worst_Crime No_Time State_Award Award Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between Worst_Crime****;

proc sql;
create table only_state as
select distinct(Worst_Crime) as Worst_Crime, sum(only_state)/count(Worst_Crime) as only_state
from state
group by Worst_Crime;

proc sql;
create table only_civil as
select distinct(Worst_Crime) as Worst_Crime, sum(only_civil)/count(Worst_Crime) as only_civil
from two_situation
group by Worst_Crime;

proc sql;
create table both as
select distinct(Worst_Crime) as Worst_Crime, sum(both_)/count(Worst_Crime) as both_
from two_situation
group by Worst_Crime;

proc sql;
create table likelihood as 
select a.Worst_Crime,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.Worst_Crime=b.Worst_Crime and a.Worst_Crime=c.Worst_Crime;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*Worst_Crime only_civil*Worst_Crime both_*Worst_Crime / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class Worst_Crime;
model only_state=Worst_Crime;
run;
proc anova data=two_situation;
class Worst_Crime;
model only_civil=Worst_Crime;
run;
proc anova data=two_situation;
class Worst_Crime;
model both_=Worst_Crime;
run;
proc npar1way data=state wilcoxon;
class Worst_Crime;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class Worst_Crime;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class Worst_Crime;
var both_;
run;


***************question 15********************************************;
proc sort data=final out=q1;
by Worst_Crime Exonerated;
run;

data q1;
set q1;
keep Worst_Crime Amount_c Exonerated Years_Lost;
run;

data q1;
set q1;
if Amount_c=0 then delete;
run;

data q1;
set q1;
if Amount_c=. then delete;
run;

data q1;
set q1;
if Years_Lost=0 then delete;
run;

data civil;
set q1;
amount_per=Amount_c/Years_Lost;
run;

*********;
proc univariate data=civil;
class Worst_Crime;
var amount_per;
histogram amount_per; 
qqplot amount_per;
run;

proc anova data=civil;
class Worst_Crime;
model amount_per=Worst_Crime;
run;

proc npar1way data=civil wilcoxon;
class Worst_Crime;
var amount_per;
run;

*********************************************************;
proc corr data=civil pearson spearman;
var Exonerated amount_c;
run;

proc glm data=civil;
class Exonerated Worst_Crime;
model amount_per=Exonerated|Worst_Crime;
run;
 

**************question 16*****************************************************;
******filling********************************************;
******filling********************************************
proc sort data=final out=q1;
by Exonerated;
run;
data q1;
set q1;
keep Exonerated No_Time State_Claim_Made Non_Statutory_Case_Filed Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Claim_Made=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data state;
set q2;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Claim_Made=. then State_Claim_Made=0;
run;

data two_situation;
set q1;
if State_Claim_Made=0 and Non_Statutory_Case_Filed=1 then only_civil=1;
else only_civil=0;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=1 then both_=1;
else both_=0;
run;

**** To prove whether there are different between different Exonerated;
****assumption: Cause we are not interest in the people who do not filling compensation, so in this situation, in order to avoid 
the possible error of missing value, let set empty to be zero****;

***the likelihood of filling compensation between Exonerated****;

proc sql;
create table only_state as
select distinct(Exonerated) as Exonerated, sum(only_state)/count(Exonerated) as only_state
from state
group by Exonerated;

proc sql;
create table only_civil as
select distinct(Exonerated) as Exonerated, sum(only_civil)/count(Exonerated) as only_civil
from two_situation
group by Exonerated;

proc sql;
create table both as
select distinct(Exonerated) as Exonerated, sum(both_)/count(Exonerated) as both_
from two_situation
group by Exonerated;

proc sql;
create table likelihood as 
select a.Exonerated,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.Exonerated=b.Exonerated and a.Exonerated=c.Exonerated;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*Exonerated only_civil*Exonerated both_*Exonerated / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class Exonerated;
model only_state=Exonerated;
run;
proc anova data=two_situation;
class Exonerated;
model only_civil=Exonerated;
run;
proc anova data=two_situation;
class Exonerated;
model both=Exonerated;
run;
proc npar1way data=state wilcoxon;
class Exonerated;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class Exonerated;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class Exonerated;
var both_;
run;
**********PREVAILING*************************************;
***/////////////preprocessing;
proc sort data=final out=q1;
by Exonerated Exonerated;
run;
data q1;
set q1;
keep Exonerated No_Time State_Award Award Exonerated Years_Lost;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between Exonerated****;

proc sql;
create table only_state as
select distinct(Exonerated) as Exonerated, sum(only_state)/count(Exonerated) as only_state
from state
group by Exonerated;

proc sql;
create table only_civil as
select distinct(Exonerated) as Exonerated, sum(only_civil)/count(Exonerated) as only_civil
from two_situation
group by Exonerated;

proc sql;
create table both as
select distinct(Exonerated) as Exonerated, sum(both_)/count(Exonerated) as both_
from two_situation
group by Exonerated;

proc sql;
create table likelihood as 
select a.Exonerated,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.Exonerated=b.Exonerated and a.Exonerated=c.Exonerated;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*Exonerated only_civil*Exonerated both_*Exonerated / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class Exonerated;
model only_state=Exonerated;
run;
proc anova data=two_situation;
class Exonerated;
model only_civil=Exonerated;
run;
proc anova data=two_situation;
class Exonerated;
model both_=Exonerated;
run;
proc npar1way data=state wilcoxon;
class Exonerated;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class Exonerated;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class Exonerated;
var both_;
run;


**********************question 17*******************************;
******filling********************************************
proc sort data=final out=q1;
by DNA_only;
run;
data q1;
set q1;
keep DNA_only No_Time State_Claim_Made Non_Statutory_Case_Filed DNA_only Years_Lost;
run;

data q2;
set q1;
if State_Claim_Made=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data state;
set q2;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Claim_Made=. then State_Claim_Made=0;
run;

data two_situation;
set q1;
if State_Claim_Made=0 and Non_Statutory_Case_Filed=1 then only_civil=1;
else only_civil=0;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=1 then both_=1;
else both_=0;
run;

**** To prove whether there are different between different DNA_only;
****assumption: Cause we are not interest in the people who do not filling compensation, so in this situation, in order to avoid 
the possible error of missing value, let set empty to be zero****;

***the likelihood of filling compensation between DNA_only****;

proc sql;
create table only_state as
select distinct(DNA_only) as DNA_only, sum(only_state)/count(DNA_only) as only_state
from state
group by DNA_only;

proc sql;
create table only_civil as
select distinct(DNA_only) as DNA_only, sum(only_civil)/count(DNA_only) as only_civil
from two_situation
group by DNA_only;

proc sql;
create table both as
select distinct(DNA_only) as DNA_only, sum(both_)/count(DNA_only) as both_
from two_situation
group by DNA_only;

proc sql;
create table likelihood as 
select a.DNA_only,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.DNA_only=b.DNA_only and a.DNA_only=c.DNA_only;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*DNA_only only_civil*DNA_only both_*DNA_only / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class DNA_only;
model only_state=DNA_only;
run;
proc anova data=two_situation;
class DNA_only;
model only_civil=DNA_only;
run;
proc anova data=two_situation;
class DNA_only;
model both=DNA_only;
run;
proc npar1way data=state wilcoxon;
class DNA_only;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class DNA_only;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class DNA_only;
var both_;
run;
**********PREVAILING*************************************;
***/////////////preprocessing;
proc sort data=final out=q1;
by DNA_only DNA_only;
run;
data q1;
set q1;
keep DNA_only No_Time State_Award Award DNA_only Years_Lost;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between DNA_only****;

proc sql;
create table only_state as
select distinct(DNA_only) as DNA_only, sum(only_state)/count(DNA_only) as only_state
from state
group by DNA_only;

proc sql;
create table only_civil as
select distinct(DNA_only) as DNA_only, sum(only_civil)/count(DNA_only) as only_civil
from two_situation
group by DNA_only;

proc sql;
create table both as
select distinct(DNA_only) as DNA_only, sum(both_)/count(DNA_only) as both_
from two_situation
group by DNA_only;

proc sql;
create table likelihood as 
select a.DNA_only,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.DNA_only=b.DNA_only and a.DNA_only=c.DNA_only;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*DNA_only only_civil*DNA_only both_*DNA_only / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class DNA_only;
model only_state=DNA_only;
run;
proc anova data=two_situation;
class DNA_only;
model only_civil=DNA_only;
run;
proc anova data=two_situation;
class DNA_only;
model both_=DNA_only;
run;
proc npar1way data=state wilcoxon;
class DNA_only;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class DNA_only;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class DNA_only;
var both_;
run;



***********question 18**********************************;
******filling********************************************
proc sort data=final out=q1;
by Death_Penalty;
run;
data q1;
set q1;
keep Death_Penalty No_Time State_Claim_Made Non_Statutory_Case_Filed Death_Penalty Years_Lost;
run;

data q2;
set q1;
if State_Claim_Made=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data state;
set q2;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Claim_Made=. then State_Claim_Made=0;
run;

data two_situation;
set q1;
if State_Claim_Made=0 and Non_Statutory_Case_Filed=1 then only_civil=1;
else only_civil=0;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=1 then both_=1;
else both_=0;
run;

**** To prove whether there are different between different Death_Penalty;
****assumption: Cause we are not interest in the people who do not filling compensation, so in this situation, in order to avoid 
the possible error of missing value, let set empty to be zero****;

***the likelihood of filling compensation between Death_Penalty****;

proc sql;
create table only_state as
select distinct(Death_Penalty) as Death_Penalty, sum(only_state)/count(Death_Penalty) as only_state
from state
group by Death_Penalty;

proc sql;
create table only_civil as
select distinct(Death_Penalty) as Death_Penalty, sum(only_civil)/count(Death_Penalty) as only_civil
from two_situation
group by Death_Penalty;

proc sql;
create table both as
select distinct(Death_Penalty) as Death_Penalty, sum(both_)/count(Death_Penalty) as both_
from two_situation
group by Death_Penalty;

proc sql;
create table likelihood as 
select a.Death_Penalty,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.Death_Penalty=b.Death_Penalty and a.Death_Penalty=c.Death_Penalty;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*Death_Penalty only_civil*Death_Penalty both_*Death_Penalty / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class Death_Penalty;
model only_state=Death_Penalty;
run;
proc anova data=two_situation;
class Death_Penalty;
model only_civil=Death_Penalty;
run;
proc anova data=two_situation;
class Death_Penalty;
model both=Death_Penalty;
run;
proc npar1way data=state wilcoxon;
class Death_Penalty;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class Death_Penalty;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class Death_Penalty;
var both_;
run;
**********PREVAILING*************************************;
***/////////////preprocessing;
proc sort data=final out=q1;
by Death_Penalty Death_Penalty;
run;
data q1;
set q1;
keep Death_Penalty No_Time State_Award Award Death_Penalty Years_Lost;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between Death_Penalty****;

proc sql;
create table only_state as
select distinct(Death_Penalty) as Death_Penalty, sum(only_state)/count(Death_Penalty) as only_state
from state
group by Death_Penalty;

proc sql;
create table only_civil as
select distinct(Death_Penalty) as Death_Penalty, sum(only_civil)/count(Death_Penalty) as only_civil
from two_situation
group by Death_Penalty;

proc sql;
create table both as
select distinct(Death_Penalty) as Death_Penalty, sum(both_)/count(Death_Penalty) as both_
from two_situation
group by Death_Penalty;

proc sql;
create table likelihood as 
select a.Death_Penalty,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.Death_Penalty=b.Death_Penalty and a.Death_Penalty=c.Death_Penalty;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*Death_Penalty only_civil*Death_Penalty both_*Death_Penalty / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class Death_Penalty;
model only_state=Death_Penalty;
run;
proc anova data=two_situation;
class Death_Penalty;
model only_civil=Death_Penalty;
run;
proc anova data=two_situation;
class Death_Penalty;
model both_=Death_Penalty;
run;
proc npar1way data=state wilcoxon;
class Death_Penalty;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class Death_Penalty;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class Death_Penalty;
var both_;
run;



*****************question 19*******************************;
proc print data=tag;**tag(1).xlsx;
run;
proc sql;
title'tag';
select distinct(Tags)
from tag;
run;

data compress;
set tag;
text=compress(Tags,';','k');
run;

data t;
set compress;
if text=' ' then  max=length(text);
else max=length(text)+1;
run;

data b;
set t;
do idd=1 to max;
text1=scan(Tags,idd,';');
output;
end;
run;
******filling********************************************;
proc sort data=b out=q1;
by text1;
run;
data q1;
set q1;
keep text1 No_Time State_Claim_Made Non_Statutory_Case_Filed text1 Years_Lost;
run;

data q2;
set q1;
if State_Claim_Made=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data state;
set q2;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Claim_Made=. then State_Claim_Made=0;
run;

data two_situation;
set q1;
if State_Claim_Made=0 and Non_Statutory_Case_Filed=1 then only_civil=1;
else only_civil=0;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=1 then both_=1;
else both_=0;
run;

**** To prove whether there are different between different text1;
****assumption: Cause we are not interest in the people who do not filling compensation, so in this situation, in order to avoid 
the possible error of missing value, let set empty to be zero****;

***the likelihood of filling compensation between text1****;

proc sql;
create table only_state as
select distinct(text1) as text1, sum(only_state)/count(text1) as only_state
from state
group by text1;

proc sql;
create table only_civil as
select distinct(text1) as text1, sum(only_civil)/count(text1) as only_civil
from two_situation
group by text1;

proc sql;
create table both as
select distinct(text1) as text1, sum(both_)/count(text1) as both_
from two_situation
group by text1;

proc sql;
create table likelihood as 
select a.text1,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.text1=b.text1 and a.text1=c.text1;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*text1 only_civil*text1 both_*text1 / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class text1;
model only_state=text1;
run;
proc anova data=two_situation;
class text1;
model only_civil=text1;
run;
proc anova data=two_situation;
class text1;
model both=text1;
run;
proc npar1way data=state wilcoxon;
class text1;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class text1;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class text1;
var both_;
run;
**********PREVAILING*************************************;
***/////////////preprocessing;
proc sort data=final out=q1;
by text1 text1;
run;
data q1;
set q1;
keep text1 No_Time State_Award Award text1 Years_Lost;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between text1****;

proc sql;
create table only_state as
select distinct(text1) as text1, sum(only_state)/count(text1) as only_state
from state
group by text1;

proc sql;
create table only_civil as
select distinct(text1) as text1, sum(only_civil)/count(text1) as only_civil
from two_situation
group by text1;

proc sql;
create table both as
select distinct(text1) as text1, sum(both_)/count(text1) as both_
from two_situation
group by text1;

proc sql;
create table likelihood as 
select a.text1,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.text1=b.text1 and a.text1=c.text1;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*text1 only_civil*text1 both_*text1 / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class text1;
model only_state=text1;
run;
proc anova data=two_situation;
class text1;
model only_civil=text1;
run;
proc anova data=two_situation;
class text1;
model both_=text1;
run;
proc npar1way data=state wilcoxon;
class text1;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class text1;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class text1;
var both_;
run;

********************question 20**********************************************;
data modiyear;
set final;
if Years_Lost <=1 then generl_yearslost=1;
else if Years_Lost <=5 and Years_Lost > 1 then generl_yearslost=2;
else if Years_Lost <=10 and Years_Lost > 5 then generl_yearslost=3;
else if Years_Lost <=15 and Years_Lost > 10 then generl_yearslost=4;
else if Years_Lost <=20 and Years_Lost > 15 then generl_yearslost=5;
else if Years_Lost <=25 and Years_Lost > 20 then generl_yearslost=6;
else if Years_Lost <=30 and Years_Lost > 25 then generl_yearslost=7;
else if Years_Lost <=35 and Years_Lost > 30 then generl_yearslost=8;
else if Years_Lost <=40 and Years_Lost > 35 then generl_yearslost=9;
run;

******filling********************************************;
proc sort data=modiyear out=q1;
by generl_yearslost;
run;
data q1;
set q1;
keep generl_yearslost No_Time State_Claim_Made Non_Statutory_Case_Filed generl_yearslost Years_Lost;
run;

data q2;
set q1;
if State_Claim_Made=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data state;
set q2;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Claim_Made=. then State_Claim_Made=0;
run;

data two_situation;
set q1;
if State_Claim_Made=0 and Non_Statutory_Case_Filed=1 then only_civil=1;
else only_civil=0;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=1 then both_=1;
else both_=0;
run;

**** To prove whether there are different between different generl_yearslost;
****assumption: Cause we are not interest in the people who do not filling compensation, so in this situation, in order to avoid 
the possible error of missing value, let set empty to be zero****;

***the likelihood of filling compensation between generl_yearslost****;

proc sql;
create table only_state as
select distinct(generl_yearslost) as generl_yearslost, sum(only_state)/count(generl_yearslost) as only_state
from state
group by generl_yearslost;

proc sql;
create table only_civil as
select distinct(generl_yearslost) as generl_yearslost, sum(only_civil)/count(generl_yearslost) as only_civil
from two_situation
group by generl_yearslost;

proc sql;
create table both as
select distinct(generl_yearslost) as generl_yearslost, sum(both_)/count(generl_yearslost) as both_
from two_situation
group by generl_yearslost;

proc sql;
create table likelihood as 
select a.generl_yearslost,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.generl_yearslost=b.generl_yearslost and a.generl_yearslost=c.generl_yearslost;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*generl_yearslost only_civil*generl_yearslost both_*generl_yearslost / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class generl_yearslost;
model only_state=generl_yearslost;
run;
proc anova data=two_situation;
class generl_yearslost;
model only_civil=generl_yearslost;
run;
proc anova data=two_situation;
class generl_yearslost;
model both=generl_yearslost;
run;
proc npar1way data=state wilcoxon;
class generl_yearslost;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class generl_yearslost;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class generl_yearslost;
var both_;
run;
**********PREVAILING*************************************;
***/////////////preprocessing;
proc sort data=final out=q1;
by generl_yearslost generl_yearslost;
run;
data q1;
set q1;
keep generl_yearslost No_Time State_Award Award generl_yearslost Years_Lost;
run;

data q2;
set q1;
if State_Award=. then delete;
run;
data q2;
set q2;
if No_Time =1 then delete;
run;

data q2;
set q2;
if State_Award=2 then State_Award=0;
run;

data state;
set q2;
if State_Award=1 and Award=0 then only_state=1;
else only_state=0; 
run;

data q1;
set q1;
if State_Award=. then State_Claim_Made=0;
run;

data q1;
set q1;
if State_Award=2 then State_Award=0;
run;


data two_situation;
set q1;
if State_Award=0 and Award=1 then only_civil=1;
else only_civil=0;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;

***the likelihood of filling compensation between generl_yearslost****;

proc sql;
create table only_state as
select distinct(generl_yearslost) as generl_yearslost, sum(only_state)/count(generl_yearslost) as only_state
from state
group by generl_yearslost;

proc sql;
create table only_civil as
select distinct(generl_yearslost) as generl_yearslost, sum(only_civil)/count(generl_yearslost) as only_civil
from two_situation
group by generl_yearslost;

proc sql;
create table both as
select distinct(generl_yearslost) as generl_yearslost, sum(both_)/count(generl_yearslost) as both_
from two_situation
group by generl_yearslost;

proc sql;
create table likelihood as 
select a.generl_yearslost,a.only_state,b.only_civil,c.both_
from only_state a, only_civil b,both c
where a.generl_yearslost=b.generl_yearslost and a.generl_yearslost=c.generl_yearslost;
run;

proc print data=likelihood;
run;

symbol1 interpol=join value=dot ;
proc gplot data=likelihood;
 plot only_state*generl_yearslost only_civil*generl_yearslost both_*generl_yearslost / overlay; 
run;
quit;

*****analysis the group mean**********************************************************;
proc anova data=state;
class generl_yearslost;
model only_state=generl_yearslost;
run;
proc anova data=two_situation;
class generl_yearslost;
model only_civil=generl_yearslost;
run;
proc anova data=two_situation;
class generl_yearslost;
model both_=generl_yearslost;
run;
proc npar1way data=state wilcoxon;
class generl_yearslost;
var only_state;
run;
proc npar1way data=two_situation wilcoxon;
class generl_yearslost;
var only_civil;
run;
proc npar1way data=two_situation wilcoxon;
class generl_yearslost;
var both_;
run;












































