**/////PART 1 RACE////////////////////////////////;
data final;
set final;
if Race='caucasian' then Race='Caucasian';
run;

proc sort data=final out=q1;
by Race Exonerated;
run;

data q1;
set q1;
keep Race State_Claim_Made Non_Statutory_Case_Filed Exonerated Years_Lost;
run;

data q1;
set q1;
if State_Claim_Made=. then State_Claim=0;
run;

data q1;
set q1;
if State_Claim_Made=1 and Non_Statutory_Case_Filed=1 then both_=1;
else both_=0;
run;

**** To prove whether there are different between different Race;
****assumption: Cause we are not interest in the people who do not filling compensation, so in this situation, in order to avoid 
the possible error of missing value, let set empty to be zero****;

***the likelihood of filling compensation between race****;
goptions reset=all;
proc sql;
create table state as
select distinct(Race) as Race, sum(State_Claim_Made)/count(Race) as state
from q1
group by Race;

proc sql;
create table civil as
select distinct(Race) as Race, sum(Non_Statutory_Case_Filed)/count(Race) as civil
from q1
group by Race;

proc sql;
create table both as
select distinct(Race) as Race, sum(both_)/count(Race) as both_
from q1
group by Race;

proc sql;
create table likelihood as 
select a.Race,a.state,b.civil,c.both_
from state a, civil b,both c
where a.Race=b.Race and a.Race=c.Race;
run;

proc print data=likelihood;
run;

data totals;
length Race $ 10;
length Method $ 5;
input Race$ Likelihood Method$;
datalines;
Asian	0.30769	state
Black	0.50271	state
Caucasian	0.31397	state
Hispanic	0.38288	state
Native_American	0.33333	state
Other	0.22222	state
Asian	0.30769	civil
Black	0.46254	civil
Caucasian	0.37068	civil
Hispanic	0.41441	civil
Native_American	0.41667	civil
Other	0.11111	civil
Asian	0.07692	both_
Black	0.29099	both_
Caucasian	0.12725	both_
Hispanic	0.22072	both_
Native_American	0	both_
Other	0.11111	both_
;
run;

/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                           
                                                                                                                                        
/* Define the title */                                                                                                                  
title 'The likelihood of filling state or civil right claim';                                                                                         
                                                                                                                                        
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "Likelihood");                                                                                                
                                                                                                                   
                                                                                                                                        
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                        
                                                                                                                                        
/* Generate the graph */                                                                                                                
proc gchart data=totals;                                                                                                       
   vbar Race / subgroup=Race group=method sumvar=Likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;

*method: contingence table;

data q2;
set q1;
if Race='Asian' then delete;
run;
data q2;
set q2;
if Race='Other' then delete;
run;
data q2;
set q2;
if Race='Native American' then delete;
run;

proc freq data=q2;
   tables Race*State_Claim_Made / chisq;
run;

proc freq data=q2;
tables Race*Non_Statutory_Case_Filed/ chisq;
run;

proc freq data=q2;
tables Race*both_/ chisq;
run;

*method: anova table;
proc anova data=q2;
class Race;
model State_Claim_Made=Race;
run;
proc anova data=q2;
class Race;
model Non_Statutory_Case_Filed=Race;
run;
proc anova data=q2;
class Race;
model both_=Race;
run;

* time ;
*/ preprocess the time first;
proc sort data=q2;
by Exonerated;
run;

data q3;
set q2;
length time $ 10;
if Exonerated<=1990 then time= '<1990';
run;

data q3;
set q3;
if 1990<Exonerated<=1995 then time= '1990-1905';
run;

data q3;
set q3;
if 1995<Exonerated<=2000 then time= '1995-2000';
run;

data q3;
set q3;
if 2000<Exonerated<=2005 then time= '2000-2005';
run;

data q3;
set q3;
if 2005<Exonerated<=2010 then time= '2005-2010';
run;
data q3;
set q3;
if 2010<Exonerated<=2015 then time= '2010-2015';
run;
data q3;
set q3;
if Exonerated>2015 then time= '>2015';
run;

goptions reset=all;
proc sql;
create table state as
select distinct(Race) as Race,time, sum(State_Claim_Made)/count(Race) as state
from q3
group by Race,time;

proc sql;
create table civil as
select distinct(Race) as Race, time, sum(Non_Statutory_Case_Filed)/count(Race) as civil
from q3
group by Race,time;

proc sql;
create table both as
select distinct(Race) as Race,time, sum(both_)/count(Race) as both_
from q3
group by Race,time;

proc sql;
create table likelihood as 
select a.Race,a.time, a.state,b.civil,c.both_
from state a, civil b,both c
where a.Race=b.Race and a.Race=c.Race and a.time=b.time and a.time=c.time;
run;

proc gplot data= likelihood;
symbol1 interpol=join width=2 value=triangle c=steelblue;
symbol2 interpol=join width=2 value=circle c=indigo;
symbol3 interpol=join width=2 value=square c=orchid;
axis1 label=none;
axis2 label=("Likelihood of filling state claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot state*time=Race/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;

proc gplot data= likelihood;
symbol1 interpol=join width=2 value=triangle c=steelblue;
symbol2 interpol=join width=2 value=circle c=indigo;
symbol3 interpol=join width=2 value=square c=orchid;
axis1 label=none;
axis2 label=("Likelihood of filling civil right claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot civil*time=Race/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;

proc gplot data= likelihood;
symbol1 interpol=join width=2 value=triangle c=steelblue;
symbol2 interpol=join width=2 value=circle c=indigo;
symbol3 interpol=join width=2 value=square c=orchid;
axis1 label=none;
axis2 label=("Likelihood of filling both state and civil right claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot both_*time=Race/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;


proc sort data=q3;
by Race time;
run;

proc glm data=q3;
class time Race;
model State_Claim_Made=time|Race;
run;

proc glm data=q3;
class time Race;
model Non_Statutory_Case_Filed=time|Race;
run;

proc glm data=q3;
class time Race;
model both_=time|Race;
run;

*/trend;
proc freq data=q3;
 tables Race*time*State_Claim_Made / trend measures cl;
   test smdrc;
   exact trend /maxtime=120;
run;

*/;
proc corr data=q2 pearson spearman;
var Years_Lost State_Claim_Made;
run;

proc corr data=q2 pearson spearman;
var Years_Lost Non_Statutory_Case_Filed;
run;

proc corr data=q2 pearson spearman;
var Years_Lost both_;
run;
*;
proc logistic data=q2 PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model State_Claim_Made(event='1')= Race Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Race) / noobs ;
run;

proc logistic data=q2 descending;
   model State_Claim_Made=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
proc gplot data=lout;
plot (State_Claim_Made pred lowerCL upperCL)*Years_Lost / overlay;
run;
*;
proc logistic data=q2 PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model Non_Statutory_Case_Filed(event='1')= Race Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Race) / noobs ;
run;

proc logistic data=q2 descending;
   model Non_Statutory_Case_Filed=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
proc gplot data=lout;
plot (Non_Statutory_Case_Filed pred lowerCL upperCL)*Years_Lost / overlay;
run;
*;
proc logistic data=q2 PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model both_(event='1')= Race Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Race) / noobs ;
run;

proc logistic data=q2 descending;
   model both_=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
proc gplot data=lout;
plot (both_ pred lowerCL upperCL)*Years_Lost / overlay;
run;


***********************QUESTION 2************************************************************;
**preprocessing;
data q1;
set q1;
keep Race State_Award Award Exonerated Years_Lost;
run;
data q1;
set q1;
if State_Award=. then State_Claim=0;
run;
data q1;
set q1;
if State_Award=2 then State_Award=0;
run;
data q1;
set q1;
if State_Award=1 and Award=1 then both_=1;
else both_=0;
run;
***the likelihood of filling compensation between race****;
goptions reset=all;
proc sql;
create table state as
select distinct(Race) as Race, sum(State_Award)/count(Race) as state
from q1
group by Race;
proc sql;
create table civil as
select distinct(Race) as Race, sum(Award)/count(Race) as civil
from q1
group by Race;
proc sql;
create table both as
select distinct(Race) as Race, sum(both_)/count(Race) as both_
from q1
group by Race;
proc sql;
create table likelihood as 
select a.Race,a.state,b.civil,c.both_
from state a, civil b,both c
where a.Race=b.Race and a.Race=c.Race;
run;
proc print data=likelihood;
run;

data totals;
length Race $ 10;
length Method $ 5;
input Race$ Likelihood Method$;
datalines;
Asian	0.53846	state
Black	0.66232	state
Caucasian	0.39419	state
Hispanic	0.44144	state
Native_American	0.33333	state
Other	0.55556	state
Asian	0.30769	civil
Black	0.2595	civil
Caucasian	0.20194	civil
Hispanic	0.24324	civil
Native_American	0.08333	civil
Other	0.11111	civil
Asian	0	both_
Black	0.14875	both_
Caucasian	0.05394	both_
Hispanic	0.13964	both_
Native_American	0	both_
Other	0	both_
;
run;
/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                                                                                                                                                                  
/* Define the title */                                                                                                                  
title 'The likelihood of prevaling state or civil right claim';                                                                                                                                                                                                                                
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "Likelihood");                                                                                                                                                                                                                                       
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                                                                                                                                                              
/* Generate the graph */                                                                                                                
proc gchart data=totals;                                                                                                       
   vbar Race / subgroup=Race group=method sumvar=Likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;
*method: contingence table;
data q2;
set q1;
if Race='Asian' then delete;
run;
data q2;
set q2;
if Race='Other' then delete;
run;
data q2;
set q2;
if Race='Native American' then delete;
run;
proc freq data=q2;
   tables Race*State_Award / chisq;
run;
proc freq data=q2;
tables Race*Award/ chisq;
run;
proc freq data=q2;
tables Race*both_/ chisq;
run;
*method: anova table;
proc anova data=q2;
class Race;
model State_Award=Race;
run;
proc anova data=q2;
class Race;
model Award=Race;
run;
proc anova data=q2;
class Race;
model both_=Race;
run;
* time ;
*/ preprocess the time first;
proc sort data=q2;
by Exonerated;
run;
data q3;
set q2;
length time $ 10;
if Exonerated<=1990 then time= '<1990';
run;
data q3;
set q3;
if 1990<Exonerated<=1995 then time= '1990-1905';
run;
data q3;
set q3;
if 1995<Exonerated<=2000 then time= '1995-2000';
run;
data q3;
set q3;
if 2000<Exonerated<=2005 then time= '2000-2005';
run;
data q3;
set q3;
if 2005<Exonerated<=2010 then time= '2005-2010';
run;
data q3;
set q3;
if 2010<Exonerated<=2015 then time= '2010-2015';
run;
data q3;
set q3;
if Exonerated>2015 then time= '>2015';
run;
goptions reset=all;
proc sql;
create table state as
select distinct(Race) as Race,time, sum(State_Award)/count(Race) as state
from q3
group by Race,time;
proc sql;
create table civil as
select distinct(Race) as Race, time, sum(Award)/count(Race) as civil
from q3
group by Race,time;
proc sql;
create table both as
select distinct(Race) as Race,time, sum(both_)/count(Race) as both_
from q3
group by Race,time;
proc sql;
create table likelihood as 
select a.Race,a.time, a.state,b.civil,c.both_
from state a, civil b,both c
where a.Race=b.Race and a.Race=c.Race and a.time=b.time and a.time=c.time;
run;
proc print data=likelihood;
run;
proc gplot data= likelihood;
symbol1 interpol=join width=2 value=triangle c=steelblue;
symbol2 interpol=join width=2 value=circle c=indigo;
symbol3 interpol=join width=2 value=square c=orchid;
axis1 label=none;
axis2 label=("Likelihood of filling state claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot state*time=Race/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;
goptions reset=all;
proc gplot data= likelihood;
symbol1 interpol=join width=2 value=triangle c=steelblue;
symbol2 interpol=join width=2 value=circle c=indigo;
symbol3 interpol=join width=2 value=square c=orchid;
axis1 label=none;
axis2 label=("Likelihood of filling civil right claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot civil*time=Race/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;
goptions reset=all;
proc gplot data= likelihood;
symbol1 interpol=join width=2 value=triangle c=steelblue;
symbol2 interpol=join width=2 value=circle c=indigo;
symbol3 interpol=join width=2 value=square c=orchid;
axis1 label=none;
axis2 label=("Likelihood of filling both state and civil right claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot both_*time=Race/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;
proc sort data=q3;
by Race time;
run;
proc glm data=q3;
class time Race;
model State_Award=time|Race;
run;
proc glm data=q3;
class time Race;
model Award=time|Race;
run;
proc glm data=q3;
class time Race;
model both_=time|Race;
run;
*/trend;
proc freq data=q3;
 tables Race*time*State_Award / trend measures cl;
   test smdrc;
   exact trend /maxtime=120;
run;
*/;
proc corr data=q2 pearson spearman;
var Years_Lost State_Award;
run;
proc corr data=q2 pearson spearman;
var Years_Lost Award;
run;
proc corr data=q2 pearson spearman;
var Years_Lost both_;
run;
proc logistic data=q2 PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model State_Award(event='1')= Race Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Race) / noobs ;
run;

proc logistic data=q2 descending;
   model State_Award=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
goptions reset=all;
proc gplot data=lout;
plot (State_Award pred lowerCL upperCL)*Years_Lost / overlay;
run;
*;
proc logistic data=q2 PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model Award(event='1')= Race Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Race) / noobs ;
run;
proc logistic data=q2 descending;
   model Award=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
goptions reset=all;
proc gplot data=lout;
plot (Award pred lowerCL upperCL)*Years_Lost / overlay;
run;
*;
proc logistic data=q2 PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class Race /param=ref;
   model both_(event='1')= Race Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=Race) / noobs ;
run;

proc logistic data=q2 descending;
   model both_=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
goptions reset=all;
proc gplot data=lout;
plot (both_ pred lowerCL upperCL)*Years_Lost / overlay;
run;



**********question 3***********;
data q1;
set final;
keep Race Amount Amount_c Exonerated Years_Lost;
run;
data q1;
set q1;
if Amount_c=. then Amount_c=0;
run;
data q1;
set q1;
if Amount=. then Amount=0;
run;
data recovery;
set q1;
amount_per_c=Amount_c/Years_Lost;
run;
data recovery;
set recovery;
amount_per=Amount/Years_Lost;
run;
data recovery;
set recovery;
if amount_per_c=. then amount_per_c=0;
run;
data recovery;
set recovery;
if amount_per=. then amount_per=0;
run;
data recovery;
set recovery;
if Race='Asian' then delete;
run;
data recovery;
set recovery;
if Race='Other' then delete;
run;
data recovery;
set recovery;
if Race='Native American' then delete;
run;
proc anova data=recovery;
class Race;
model amount_per_c=Race;
run;
proc anova data=recovery;
class Race;
model amount_per=Race;
run;
proc sort data=recovery;
by Exonerated;
run;
data recovery;
set recovery;
length time $ 10;
if Exonerated<=1990 then time= '<1990';
run;
data recovery;
set recovery;
if 1990<Exonerated<=1995 then time= '1990-1905';
run;
data recovery;
set recovery;
if 1995<Exonerated<=2000 then time= '1995-2000';
run;
data recovery;
set recovery;
if 2000<Exonerated<=2005 then time= '2000-2005';
run;
data recovery;
set recovery;
if 2005<Exonerated<=2010 then time= '2005-2010';
run;
data recovery;
set recovery;
if 2010<Exonerated<=2015 then time= '2010-2015';
run;
data recovery;
set recovery;
if Exonerated>2015 then time= '>2015';
run;

goptions reset=all;
proc sql;
create table amount_state as
select distinct(Race) as Race,time, avg(amount_per) as amount_state
from recovery
group by Race,time;
proc sql;
create table amount_civil as
select distinct(Race) as Race,time, avg(amount_per_c) as amount_civil
from recovery
group by Race,time;
proc glm data=recovery;
class time Race;
model amount_per=time|Race;
run;
proc glm data=recovery;
class time Race;
model amount_per_c=time|Race;
run;
proc gplot data= amount_state;
symbol1 interpol=join width=2 value=triangle c=steelblue;
symbol2 interpol=join width=2 value=circle c=indigo;
symbol3 interpol=join width=2 value=square c=orchid;
axis1 label=none;
axis2 label=("The Amount of recovering state claim per year")
order=(0 to 300000 by 20000);
legend1 label=none value=(tick=1 "Black");
plot amount_state*time=Race/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;
proc gplot data= amount_civil;
symbol1 interpol=join width=2 value=triangle c=steelblue;
symbol2 interpol=join width=2 value=circle c=indigo;
symbol3 interpol=join width=2 value=square c=orchid;
axis1 label=none;
axis2 label=("The Amount of recovering civil right per year")
order=(0 to 300000 by 100000);
legend1 label=none value=(tick=1 "Black");
plot amount_civil*time=Race/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;


