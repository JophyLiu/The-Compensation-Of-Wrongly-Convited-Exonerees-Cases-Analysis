area;
goptions reset=all;
proc sql;
create table state_claim as
select distinct(area) as area, avg(State_Claim_Made) as state
from fs
group by area;

proc sql;
create table civil_claim as
select distinct(area) as area, avg(Non_Statutory_Case_Filed) as civil
from fc
group by area;

proc sql;
create table both_claim as
select distinct(area) as area, avg(both_claim) as both_claim
from fs
group by area;

proc sql;
create table likelihood_claim as 
select a.area,a.state,b.civil,c.both_claim
from state_claim a, civil_claim b,both_claim c
where a.area=b.area and a.area=c.area;
run;

proc print data=likelihood_claim;
run;

data total_claim;
length area $ 10;
length Method $ 5;
input area$ Likelihood Method$;
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
Asian	0.07692	both_claim
Black	0.29099	both_claim
Caucasian	0.12725	both_claim
Hispanic	0.22072	both_claim
Native_American	0	both_claim
Other	0.11111	both_claim
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
proc gchart data=total_claim;                                                                                                       
   vbar area / subgroup=area group=method sumvar=Likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;

*method: contingence table;


proc freq data=fs;
   tables area*State_Claim_Made / chisq;
run;

proc freq data=fc;
tables area*Non_Statutory_Case_Filed/ chisq;
run;

proc freq data=fs;
tables area*both_claim/ chisq;
run;

*method: anova table;
proc anova data=fs;
class area;
model State_Claim_Made=area;
run;
proc anova data=fc;
class area;
model Non_Statutory_Case_Filed=area;
run;
proc anova data=fs;
class area;
model both_claim=area;
run;

* time ;
*/ preprocess the time first;

goptions reset=all;
proc sql;
create table state_claim as
select distinct(area) as area,time, avg(State_Claim_Made) as state
from fs
group by area,time;

proc sql;
create table civil_claim as
select distinct(area) as area, time, avg(Non_Statutory_Case_Filed) as civil
from fc
group by area,time;

proc sql;
create table both_claim as
select distinct(area) as area,time, avg(both_claim)/count(area) as both_claim
from fs
group by area,time;

proc sql;
create table likelihood_claim as 
select a.area,a.time, a.state,b.civil,c.both_claim
from state_claim a, civil_claim b,both_claim c
where a.area=b.area and a.area=c.area and a.time=b.time and a.time=c.time;
run;

proc print data=likelihood_claim;
run;


proc gplot data= likelihood_claim;
symbol1 interpol=join width=1 value=triangle c=steelblue;
symbol2 interpol=join width=1 value=circle c=indigo;
symbol3 interpol=join width=1 value=square c=orchid;
symbol4 interpol=join width=1 value=dot c=red;
axis1 label=none;
axis2 label=("Likelihood of filling state claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot state*time=area/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;

proc gplot data= likelihood_claim;
symbol1 interpol=join width=1 value=triangle c=steelblue;
symbol2 interpol=join width=1 value=circle c=indigo;
symbol3 interpol=join width=1 value=square c=orchid;
symbol4 interpol=join width=1 value=dot c=red;
axis1 label=none;
axis2 label=("Likelihood of filling civil right claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot civil*time=area/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;

proc gplot data= likelihood_claim;
symbol1 interpol=join width=1 value=triangle c=steelblue;
symbol2 interpol=join width=1 value=circle c=indigo;
symbol3 interpol=join width=1 value=square c=orchid;
symbol4 interpol=join width=1 value=dot c=red;
axis1 label=none;
axis2 label=("Likelihood of filling both state and civil right claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot both_claim*time=area/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;


proc sort data=fs;
by area time;
run;

proc glm data=fs;
class time area;
model State_Claim_Made=time|area;
run;

proc glm data=fc;
class time area;
model Non_Statutory_Case_Filed=time|area;
run;

proc glm data=fs;
class time area;
model both_claim=time|area;
run;

*/trend;
proc freq data=fs;
 tables area*time*State_Claim_Made / trend measures cl;
   test smdrc;
   exact trend /maxtime=120;
run;
*/trend;
proc freq data=fc;
 tables area*time*Non_Statutory_Case_Filed / trend measures cl;
   test smdrc;
   exact trend /maxtime=120;
run;
*/trend;
proc freq data=fs;
 tables area*time*both_claim / trend measures cl;
   test smdrc;
   exact trend /maxtime=120;
run;

*/;
proc corr data=fs pearson spearman;
var Years_Lost State_Claim_Made;
run;

proc corr data=fc pearson spearman;
var Years_Lost Non_Statutory_Case_Filed;
run;

proc corr data=fs pearson spearman;
var Years_Lost both_claim;
run;
*;
goptions reset=all;
proc logistic data=fs PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class area /param=ref;
   model State_Claim_Made(event='1')= area Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=area) / noobs ;
run;
goptions reset=all;
proc logistic data=fs descending;
   model State_Claim_Made=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
proc gplot data=lout;
plot (State_Claim_Made pred lowerCL upperCL)*Years_Lost / overlay;
run;
*;
proc logistic data=fc PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class area /param=ref;
   model Non_Statutory_Case_Filed(event='1')= area Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=area) / noobs ;
run;
goptions reset=all;
proc logistic data=fc descending;
   model Non_Statutory_Case_Filed=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
proc gplot data=lout;
plot (Non_Statutory_Case_Filed pred lowerCL upperCL)*Years_Lost / overlay;
run;
*;
goptions reset=all;
proc logistic data=fs PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class area /param=ref;
   model both_claim(event='1')= area Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=area) / noobs ;
run;
goptions reset=all;
proc logistic data=fs descending;
   model both_claim=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
proc gplot data=lout;
plot (both_claim pred lowerCL upperCL)*Years_Lost / overlay;
run;



*/////////////////////////////////;
***the likelihood_award of previvling compensation between area****;
goptions reset=all;
proc sql;
create table state_award as
select distinct(area) as area, avg(State_Award) as state_award
from ps
group by area;
proc sql;
create table civil_award as
select distinct(area) as area, avg(Award) as civil_award
from pc
group by area;
proc sql;
create table likelihood_award as 
select a.area,a.state_award,b.civil_award
from state_award a, civil_award b
where a.area=b.area;
run;
proc print data=likelihood_award;
run;

data total_award;
length area $ 10;
length Method $ 5;
input area$ likelihood_award Method$;
datalines;
Asian	0.53846	state_award
Black	0.66232	state_award
Caucasian	0.39419	state_award
Hispanic	0.44144	state_award
Native_American	0.33333	state_award
Other	0.55556	state_award
Asian	0.30769	civil_award
Black	0.2595	civil_award
Caucasian	0.20194	civil_award
Hispanic	0.24324	civil_award
Native_American	0.08333	civil_award
Other	0.11111	civil_award
Asian	0	both_award
Black	0.14875	both_award
Caucasian	0.05394	both_award
Hispanic	0.13964	both_award
Native_American	0	both_award
Other	0	both_award
;
run;
/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                                                                                                                                                                  
/* Define the title */                                                                                                                  
title 'The likelihood_award of prevaling state_award or civil_award right claim';                                                                                                                                                                                                                                
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "likelihood_award");                                                                                                                                                                                                                                       
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                                                                                                                                                              
/* Generate the graph */                                                                                                                
proc gchart data=total_award;                                                                                                       
   vbar area / subgroup=area group=method avgvar=likelihood_award                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=avg;                                                                                   
run;                                                                                                                                    
quit;
*method: contingence table;

proc freq data=ps;
   tables area*State_Award / chisq;
run;
proc freq data=pc;
tables area*Award/ chisq;
run;

*method: anova table;
proc anova data=ps;
class area;
model State_Award=area;
run;
proc anova data=pc;
class area;
model Award=area;
run;
proc anova data=ps;
class area;
model both_award=area;
run;
* time ;
*/ preprocess the time first;



goptions reset=all;
proc sql;
create table state_award as
select distinct(area) as area,time, avg(State_Award) as state_award
from ps
group by area,time;
proc sql;
create table civil_award as
select distinct(area) as area, time, avg(Award) as civil_award
from pc
group by area,time;

proc sql;
create table likelihood_award as 
select a.area,a.time, a.state_award,b.civil_award
from state_award a, civil_award b
where a.area=b.area and a.time=b.time;
run;
proc print data=likelihood_award;
run;
proc gplot data= likelihood_award;
symbol1 interpol=join width=1 value=triangle c=steelblue;
symbol2 interpol=join width=1 value=circle c=indigo;
symbol3 interpol=join width=1 value=square c=orchid;
symbol4 interpol=join width=1 value=dot c=red;
axis1 label=none;
axis2 label=("likelihood_award of filling state_award claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot state_award*time=area/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;
goptions reset=all;
proc gplot data= likelihood_award;
symbol1 interpol=join width=1 value=triangle c=steelblue;
symbol2 interpol=join width=1 value=circle c=indigo;
symbol3 interpol=join width=1 value=square c=orchid;
symbol4 interpol=join width=1 value=dot c=red;
axis1 label=none;
axis2 label=("likelihood_award of filling civil_award right claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot civil_award*time=area/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;

proc sort data=ps;
by area time;
run;
proc glm data=ps;
class time area;
model State_Award=time|area;
run;
proc glm data=pc;
class time area;
model Award=time|area;
run;

*/trend;
proc freq data=ps;
 tables area*time*State_Award / trend measures cl;
   test smdrc;
   exact trend /maxtime=120;
run;
proc freq data=pc;
 tables area*time*Award / trend measures cl;
   test smdrc;
   exact trend /maxtime=120;
run;
*/;
proc corr data=ps pearson spearman;
var Years_Lost State_Award;
run;
proc corr data=pc pearson spearman;
var Years_Lost Award;
run;
proc corr data=ps pearson spearman;
var Years_Lost both_award;
run;
proc logistic data=ps PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class area /param=ref;
   model State_Award(event='1')= area Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=area) / noobs ;
run;
goptions reset=all;

proc logistic data=ps descending;
   model State_Award=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
goptions reset=all;
proc gplot data=lout;
plot (State_Award pred lowerCL upperCL)*Years_Lost / overlay;
run;
*;
proc logistic data=pc PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class area /param=ref;
   model Award(event='1')= area Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=area) / noobs ;
run;
proc logistic data=pc descending;
   model Award=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
goptions reset=all;
proc gplot data=lout;
plot (Award pred lowerCL upperCL)*Years_Lost / overlay;
run;


*//////////////////////////////////////////////////////
state_support;
goptions reset=all;
proc sql;
create table state_claim as
select distinct(state_support) as state_support, avg(State_Claim_Made) as state
from fs
group by state_support;

proc sql;
create table civil_claim as
select distinct(state_support) as state_support, avg(Non_Statutory_Case_Filed) as civil
from fc
group by state_support;

proc sql;
create table both_claim as
select distinct(state_support) as state_support, avg(both_claim) as both_claim
from fs
group by state_support;

proc sql;
create table likelihood_claim as 
select a.state_support,a.state,b.civil,c.both_claim
from state_claim a, civil_claim b,both_claim c
where a.state_support=b.state_support and a.state_support=c.state_support;
run;

proc print data=likelihood_claim;
run;

data total_claim;
length state_support $ 10;
length Method $ 5;
input state_support$ Likelihood Method$;
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
Asian	0.07692	both_claim
Black	0.29099	both_claim
Caucasian	0.12725	both_claim
Hispanic	0.22072	both_claim
Native_American	0	both_claim
Other	0.11111	both_claim
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
proc gchart data=total_claim;                                                                                                       
   vbar state_support / subgroup=state_support group=method sumvar=Likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;

*method: contingence table;


proc freq data=fs;
   tables state_support*State_Claim_Made / chisq;
run;

proc freq data=fc;
tables state_support*Non_Statutory_Case_Filed/ chisq;
run;

proc freq data=fs;
tables state_support*both_claim/ chisq;
run;

*method: anova table;
proc anova data=fs;
class state_support;
model State_Claim_Made=state_support;
run;
proc anova data=fc;
class state_support;
model Non_Statutory_Case_Filed=state_support;
run;
proc anova data=fs;
class state_support;
model both_claim=state_support;
run;

* time ;
*/ preprocess the time first;

goptions reset=all;
proc sql;
create table state_claim as
select distinct(state_support) as state_support,time, avg(State_Claim_Made) as state
from fs
group by state_support,time;

proc sql;
create table civil_claim as
select distinct(state_support) as state_support, time, avg(Non_Statutory_Case_Filed) as civil
from fc
group by state_support,time;

proc sql;
create table both_claim as
select distinct(state_support) as state_support,time, avg(both_claim)/count(state_support) as both_claim
from fs
group by state_support,time;

proc sql;
create table likelihood_claim as 
select a.state_support,a.time, a.state,b.civil,c.both_claim
from state_claim a, civil_claim b,both_claim c
where a.state_support=b.state_support and a.state_support=c.state_support and a.time=b.time and a.time=c.time;
run;

proc print data=likelihood_claim;
run;

proc gplot data= likelihood_claim;
symbol1 interpol=join width=1 value=triangle c=steelblue;
symbol2 interpol=join width=1 value=circle c=indigo;
symbol3 interpol=join width=1 value=square c=orchid;
symbol4 interpol=join width=1 value=dot c=red;
axis1 label=none;
axis2 label=("Likelihood of filling state claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot state*time=state_support/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;

proc gplot data= likelihood_claim;
symbol1 interpol=join width=1 value=triangle c=steelblue;
symbol2 interpol=join width=1 value=circle c=indigo;
symbol3 interpol=join width=1 value=square c=orchid;
symbol4 interpol=join width=1 value=dot c=red;
axis1 label=none;
axis2 label=("Likelihood of filling civil right claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot civil*time=state_support/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;

proc gplot data= likelihood_claim;
symbol1 interpol=join width=1 value=triangle c=steelblue;
symbol2 interpol=join width=1 value=circle c=indigo;
symbol3 interpol=join width=1 value=square c=orchid;
symbol4 interpol=join width=1 value=dot c=red;
axis1 label=none;
axis2 label=("Likelihood of filling both state and civil right claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot both_claim*time=state_support/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;


proc sort data=fs;
by state_support time;
run;

proc glm data=fs;
class time state_support;
model State_Claim_Made=time|state_support;
run;

proc glm data=fc;
class time state_support;
model Non_Statutory_Case_Filed=time|state_support;
run;

proc glm data=fs;
class time state_support;
model both_claim=time|state_support;
run;

*/trend;
proc freq data=fs;
 tables state_support*time*State_Claim_Made / trend measures cl;
   test smdrc;
   exact trend /maxtime=120;
run;
*/trend;
proc freq data=fc;
 tables state_support*time*Non_Statutory_Case_Filed / trend measures cl;
   test smdrc;
   exact trend /maxtime=120;
run;
*/trend;
proc freq data=fs;
 tables state_support*time*both_claim / trend measures cl;
   test smdrc;
   exact trend /maxtime=120;
run;

*/;
proc corr data=fs pearson spearman;
var Years_Lost State_Claim_Made;
run;

proc corr data=fc pearson spearman;
var Years_Lost Non_Statutory_Case_Filed;
run;

proc corr data=fs pearson spearman;
var Years_Lost both_claim;
run;
*;
goptions reset=all;
proc logistic data=fs PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class state_support /param=ref;
   model State_Claim_Made(event='1')= state_support Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=state_support) / noobs ;
run;

proc logistic data=fs descending;
   model State_Claim_Made=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
proc gplot data=lout;
plot (State_Claim_Made pred lowerCL upperCL)*Years_Lost / overlay;
run;
*;
proc logistic data=fc PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class state_support /param=ref;
   model Non_Statutory_Case_Filed(event='1')= state_support Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=state_support) / noobs ;
run;

proc logistic data=fc descending;
   model Non_Statutory_Case_Filed=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
proc gplot data=lout;
plot (Non_Statutory_Case_Filed pred lowerCL upperCL)*Years_Lost / overlay;
run;
*;
proc logistic data=fs PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class state_support /param=ref;
   model both_claim(event='1')= state_support Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=state_support) / noobs ;
run;

proc logistic data=fs descending;
   model both_claim=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
proc gplot data=lout;
plot (both_claim pred lowerCL upperCL)*Years_Lost / overlay;
run;

*///////////////////////////////////;



*/////////////////////////////////////////;
***the likelihood_award of previvling compensation between state_support****;
goptions reset=all;
proc sql;
create table state_award as
select distinct(state_support) as state_support, avg(State_Award) as state_award
from ps
group by state_support;
proc sql;
create table civil_award as
select distinct(state_support) as state_support, avg(Award) as civil_award
from pc
group by state_support;

proc sql;
create table likelihood_award as 
select a.state_support,a.state_award,b.civil_award
from state_award a, civil_award b
where a.state_support=b.state_support;
run;
proc print data=likelihood_award;
run;

data total_award;
length state_support $ 10;
length Method $ 5;
input state_support$ likelihood_award Method$;
datalines;
Asian	0.53846	state_award
Black	0.66232	state_award
Caucasian	0.39419	state_award
Hispanic	0.44144	state_award
Native_American	0.33333	state_award
Other	0.55556	state_award
Asian	0.30769	civil_award
Black	0.2595	civil_award
Caucasian	0.20194	civil_award
Hispanic	0.24324	civil_award
Native_American	0.08333	civil_award
Other	0.11111	civil_award
Asian	0	both_award
Black	0.14875	both_award
Caucasian	0.05394	both_award
Hispanic	0.13964	both_award
Native_American	0	both_award
Other	0	both_award
;
run;
/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                                                                                                                                                                  
/* Define the title */                                                                                                                  
title 'The likelihood_award of prevaling state_award or civil_award right claim';                                                                                                                                                                                                                                
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "likelihood_award");                                                                                                                                                                                                                                       
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                                                                                                                                                              
/* Generate the graph */                                                                                                                
proc gchart data=total_award;                                                                                                       
   vbar state_support / subgroup=state_support group=method avgvar=likelihood_award                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=avg;                                                                                   
run;                                                                                                                                    
quit;
*method: contingence table;

proc freq data=ps;
   tables state_support*State_Award / chisq;
run;
proc freq data=pc;
tables state_support*Award/ chisq;
run;

*method: anova table;
proc anova data=ps;
class state_support;
model State_Award=state_support;
run;
proc anova data=pc;
class state_support;
model Award=state_support;
run;
* time ;
*/ preprocess the time first;
goptions reset=all;
proc sql;
create table state_award as
select distinct(state_support) as state_support,time, avg(State_Award) as state_award
from ps
group by state_support,time;
proc sql;
create table civil_award as
select distinct(state_support) as state_support, time, avg(Award) as civil_award
from pc
group by state_support,time;
proc sql;
create table likelihood_award as 
select a.state_support,a.time, a.state_award,b.civil_award
from state_award a, civil_award b
where a.state_support=b.state_support  and a.time=b.time;
run;
proc print data=likelihood_award;
run;
proc gplot data= likelihood_award;
symbol1 interpol=join width=2 value=triangle c=steelblue;
symbol2 interpol=join width=2 value=circle c=indigo;
symbol3 interpol=join width=2 value=square c=orchid;
axis1 label=none;
axis2 label=("likelihood_award of filling state_award claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot state_award*time=state_support/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;
goptions reset=all;
proc gplot data= likelihood_award;
symbol1 interpol=join width=2 value=triangle c=steelblue;
symbol2 interpol=join width=2 value=circle c=indigo;
symbol3 interpol=join width=2 value=square c=orchid;
axis1 label=none;
axis2 label=("likelihood_award of filling civil_award right claim")
order=(0.14 to 0.64 by 0.02);;
legend1 label=none value=(tick=1 "Black");
plot civil_award*time=state_support/ 
        haxis=axis1 hminor=0
        vaxis=axis2 vminor=1
        legend=legend1;
run;
quit;

proc sort data=ps;
by state_support time;
run;
proc glm data=ps;
class time state_support;
model State_Award=time|state_support;
run;
proc glm data=pc;
class time state_support;
model Award=time|state_support;
run;

*/trend;
proc freq data=ps;
 tables state_support*time*State_Award / trend measures cl;
   test smdrc;
   exact trend /maxtime=120;
run;
*/;
proc corr data=ps pearson spearman;
var Years_Lost State_Award;
run;
proc corr data=pc pearson spearman;
var Years_Lost Award;
run;

goptions reset=all;
proc logistic data=ps PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class state_support /param=ref;
   model State_Award(event='1')= state_support Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=state_support) / noobs ;
run;

proc logistic data=ps descending;
   model State_Award=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
goptions reset=all;
proc gplot data=lout;
plot (State_Award pred lowerCL upperCL)*Years_Lost / overlay;
run;
*;
proc logistic data=pc PLOTS(ONLY) = EFFECT(CLBAR SHOWOBS);
   class state_support /param=ref;
   model Award(event='1')= state_support Years_Lost;
   effectplot slicefit(x=Years_Lost sliceby=state_support) / noobs ;
run;
proc logistic data=pc descending;
   model Award=Years_Lost;
   output out=lout p=pred l=lowerCL u=upperCL;
run;
goptions reset=all;
proc gplot data=lout;
plot (Award pred lowerCL upperCL)*Years_Lost / overlay;
run;



*//////////////////////////////////;















