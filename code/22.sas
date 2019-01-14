data fs;
set final;
if State_Statute ='N' then delete;
run;

data fs;
set fs;
if No_Time=1 then delete;
run;


data fs;
set fs;
if State_Claim_Made =1 and Non_Statutory_Case_Filed=1 then both_claim=1;
else both_claim=0;
run;

data ps;
set fs;
if State_Claim_Made=1;
run;

data ps;
set ps;
if State_Award=2 then delete;
run;

data ps;
set ps;
if State_Award=. then delete;
run;

data ps;
set ps;
if State_Award=1 and Award=1 then both_award=1;
else both_award=0;
run;

data ast;
set ps;
if State_Award=1;
run;

data fc;
set final;
run;

data pc;
set fc;
if Non_Statutory_Case_Filed=1;
run;

data total_award;
length CIU $ 10;
length Method $ 15;
input CIU$ likelihood Method$;
datalines;
0	0.79905	state_award
1	0.92958	state_award
0	0.56522	civil_award
1	0.46667	civil_award
0	0.56522	both_award
1	0.46667	both_award
0	0.51885	state_claim
1	0.52903	state_claim
0	0.44231	civil_claim
1	0.25532	civil_claim
0	0.26681	both_claim
1	0.32258	both_claim
;
run;
/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                                                                                                                                                                  
/* Define the title */                                                                                                                  
title 'The likelihood_award of prevaling state_award or civil_award right claim';                                                                                                                                                                                                                                
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "likelihood");                                                                                                                                                                                                                                       
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                                                                                                                                                              
/* Generate the graph */                                                                                                                
proc gchart data=total_award;                                                                                                       
   vbar CIU / subgroup=CIU group=method sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2  outside=sum;                                                                                   
run;                                                                                                                                    
quit;
proc gchart data=total_award;                                                                                                       
   vbar method / subgroup=method group=CIU sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2  outside=sum;                                                                                   
run;                                                                                                                                    
quit;



*/////Guilty plea;
***the likelihood_award of previvling compensation between Guilty_Plea****;
goptions reset=all;
proc sql;
create table state_award as
select distinct(Guilty_Plea) as Guilty_Plea, avg(State_Award) as state_award
from ps
group by Guilty_Plea;
proc sql;
create table civil_award as
select distinct(Guilty_Plea) as Guilty_Plea, avg(Award) as civil_award
from pc
group by Guilty_Plea;
proc sql;
create table both as
select distinct(Guilty_Plea) as Guilty_Plea, avg(both_award) as both_award
from ps
group by Guilty_Plea;
proc sql;
create table likelihood_award as 
select a.Guilty_Plea,a.state_award,b.civil_award,c.both_award
from state_award a, civil_award b,both c
where a.Guilty_Plea=b.Guilty_Plea and a.Guilty_Plea=c.Guilty_Plea;
run;

proc print data=likelihood_award;
run;

*method: contingence table;

proc freq data=ps;
   tables Guilty_Plea*State_Award / chisq;
run;
proc freq data=pc;
tables Guilty_Plea*Award/ chisq;
run;
proc freq data=ps;
   tables Guilty_Plea*both_award / chisq;
run;

goptions reset=all;
proc sql;
create table state_claim as
select distinct(Guilty_Plea) as Guilty_Plea, avg(State_Claim_Made) as state
from fs
group by Guilty_Plea;

proc sql;
create table civil_claim as
select distinct(Guilty_Plea) as Guilty_Plea, avg(Non_Statutory_Case_Filed) as civil
from fc
group by Guilty_Plea;

proc sql;
create table both_claim as
select distinct(Guilty_Plea) as Guilty_Plea, avg(both_claim) as both_claim
from fs
group by Guilty_Plea;

proc sql;
create table likelihood_claim as 
select a.Guilty_Plea,a.state as state_claim,b.civil as civil_claim,c.both_claim
from state_claim a, civil_claim b,both_claim c
where a.Guilty_Plea=b.Guilty_Plea and a.Guilty_Plea=c.Guilty_Plea;
run;

proc print data=likelihood_claim;
run;

*method: contingence table;
proc freq data=fs;
   tables Guilty_Plea*State_Claim_Made / chisq;
run;

proc freq data=fc;
tables Guilty_Plea*Non_Statutory_Case_Filed/ chisq;
run;

proc freq data=fs;
   tables Guilty_Plea*both_claim / chisq;
run;



data total_award;
length Guilty_Plea $ 10;
length Method $ 15;
input Guilty_Plea$ likelihood Method$;
datalines;
0	0.81068	state_award
1	0.82353	state_award
0	0.53669	civil_award
1	0.70297	civil_award
0	0.29612	both_award
1	0.25882	both_award
0	0.55754	state_claim
1	0.34909	state_claim
0	0.46364	civil_claim
1	0.25187	civil_claim
0	0.30146	both_claim
1	0.14182	both_claim

;
run;

/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                                                                                                                                                                  
/* Define the title */                                                                                                                  
title 'The likelihood of filling/prevaling state or civil right claim';                                                                                                                                                                                                                                
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "likelihood_award");                                                                                                                                                                                                                                       
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                                                                                                                                                              
/* Generate the graph */                                                                                                                
proc gchart data=total_award;                                                                                                       
   vbar Guilty_Plea / subgroup=Guilty_Plea group=method sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;
proc gchart data=total_award;                                                                                                       
   vbar method / subgroup=method group=Guilty_Plea sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;



*////////////crime;

***the likelihood_award of previvling compensation between Crime****;
goptions reset=all;
proc sql;
create table state_award as
select distinct(Crime) as Crime, avg(State_Award) as state_award
from ps
group by Crime;
proc sql;
create table civil_award as
select distinct(Crime) as Crime, avg(Award) as civil_award
from pc
group by Crime;
proc sql;
create table both as
select distinct(Crime) as Crime, avg(both_award) as both_award
from ps
group by Crime;
proc sql;

create table likelihood_award as 
select a.Crime,a.state_award,b.civil_award,c.both_award
from state_award a, civil_award b,both c
where a.Crime=b.Crime and a.Crime=c.Crime;
run;

proc print data=likelihood_award;
run;

*method: contingence table;

proc freq data=ps;
   tables Crime*State_Award / chisq;
run;
proc freq data=pc;
tables Crime*Award/ chisq;
run;
proc freq data=ps;
   tables Crime*both_award / chisq;
run;

goptions reset=all;
proc sql;
create table state_claim as
select distinct(Crime) as Crime, avg(State_Claim_Made) as state
from fs
group by Crime;

proc sql;
create table civil_claim as
select distinct(Crime) as Crime, avg(Non_Statutory_Case_Filed) as civil
from fc
group by Crime;

proc sql;
create table both_claim as
select distinct(Crime) as Crime, avg(both_claim) as both_claim
from fs
group by Crime;

proc sql;
create table likelihood_claim as 
select a.Crime,a.state as state_claim,b.civil as civil_claim,c.both_claim
from state_claim a, civil_claim b,both_claim c
where a.Crime=b.Crime and a.Crime=c.Crime;
run;

proc print data=likelihood_claim;
run;

*method: contingence table;
proc freq data=fs;
   tables Crime*State_Claim_Made / chisq;
run;

proc freq data=fc;
tables Crime*Non_Statutory_Case_Filed/ chisq;
run;

proc freq data=fs;
   tables Crime*both_claim / chisq;
run;



data total_award;
length Crime $ 20;
length Method $ 15;
input Crime$ likelihood Method$;
datalines;
murder	0.83333	state_award
sexual_assault	0.91411	state_award
drugs	0.65	state_award
child_sexual_abuse	0.76923	state_award
robbery	0.72093	state_award
other	0.65432	state_award
murder	0.54902	civil_award
sexual_assault	0.57391	civil_award
drugs	0.51852	civil_award
child_sexual_abuse	0.57746	civil_award
robbery	0.44444	civil_award
other	0.60825	civil_award
murder	0.40566	both_award
sexual_assault	0.23313	both_award
drugs	0.05	both_award
child_sexual_abuse	0.14103	both_award
robbery	0.2093	both_award
other	0.20988	both_award
murder	0.54985	state_claim
sexual_assault	0.68254	state_claim
drugs	0.18333	state_claim
child_sexual_abuse	0.46354	state_claim
robbery	0.52941	state_claim
other	0.46465	state_claim
murder	0.58621	civil_claim
sexual_assault	0.38851	civil_claim
drugs	0.12676	civil_claim
child_sexual_abuse	0.31696	civil_claim
robbery	0.28125	civil_claim
other	0.33681	civil_claim
murder	0.37764	both_claim
sexual_assault	0.28175	both_claim
drugs	0.05833	both_claim
child_sexual_abuse	0.15104	both_claim
robbery	0.21176	both_claim
other	0.18182	both_claim

;run;




/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                                                                                                                                                                  
/* Define the title */                                                                                                                  
title 'The likelihood of filling/ prevaling state or civil right claim';                                                                                                                                                                                                                                
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "likelihood_award");                                                                                                                                                                                                                                       
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                                                                                                                                                              
/* Generate the graph */                                                                                                                
proc gchart data=total_award;                                                                                                       
   vbar Crime / subgroup=Crime group=method sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;
proc gchart data=total_award;                                                                                                       
   vbar method / subgroup=method group=Crime sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;


data ac;
set pc;
if Award =1;
run;

data ac;
set ac;
if Amount_c=. then delete;
run;
data ac;
set ac;
amount_per_civil=Amount_c/Years_Lost;
run;
data ac;
set ac;
if Years_lost=0 then amount_per_civil=Amount_c;
run;


proc sql;
create table amount as 
select avg(amount_per_civil) as amount_per_civil,Crime
from ac
group by Crime; 

proc sort nodupkey data =amount out=amount;
by Crime;
run;

proc print data=amount;
run;

/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border ;                                                                                                                                                                                                                  
/* Define the title */                                                                                                                  
title 'The amount of prevaling state or civil right claim';                                                                                                                                                                                                                                
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "civil right average amount per year");                                                                                                                                                                                                                                       
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                                                                                                                                                              
/* Generate the graph */                                                                                                                
proc gchart data=amount;                                                                                                       
   vbar Crime / subgroup=Crime sumvar=amount_per_civil midpoints= 1 to 6 by 1                                                                          
                  legend=legend1 space=1                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 outside=sum;                                                                                   
run;                                                                                                                                    
quit;

proc anova data=ac;
class Crime;
model amount_per_civil=Crime;
run;


*//////////////dna;
***the likelihood_award of previvling compensation between DNA****;
goptions reset=all;
proc sql;
create table state_award as
select distinct(DNA) as DNA, avg(State_Award) as state_award
from ps
group by DNA;
proc sql;
create table civil_award as
select distinct(DNA) as DNA, avg(Award) as civil_award
from pc
group by DNA;
proc sql;
create table both as
select distinct(DNA) as DNA, avg(both_award) as both_award
from ps
group by DNA;
proc sql;

create table likelihood_award as 
select a.DNA,a.state_award,b.civil_award,c.both_award
from state_award a, civil_award b,both c
where a.DNA=b.DNA and a.DNA=c.DNA;
run;

proc print data=likelihood_award;
run;

*method: contingence table;

proc freq data=ps;
   tables DNA*State_Award / chisq;
run;
proc freq data=pc;
tables DNA*Award/ chisq;
run;
proc freq data=ps;
   tables DNA*both_award / chisq;
run;

goptions reset=all;
proc sql;
create table state_claim as
select distinct(DNA) as DNA, avg(State_Claim_Made) as state
from fs
group by DNA;

proc sql;
create table civil_claim as
select distinct(DNA) as DNA, avg(Non_Statutory_Case_Filed) as civil
from fc
group by DNA;

proc sql;
create table both_claim as
select distinct(DNA) as DNA, avg(both_claim) as both_claim
from fs
group by DNA;

proc sql;
create table likelihood_claim as 
select a.DNA,a.state as state_claim,b.civil as civil_claim,c.both_claim
from state_claim a, civil_claim b,both_claim c
where a.DNA=b.DNA and a.DNA=c.DNA;
run;

proc print data=likelihood_claim;
run;

*method: contingence table;
proc freq data=fs;
   tables DNA*State_Claim_Made / chisq;
run;

proc freq data=fc;
tables DNA*Non_Statutory_Case_Filed/ chisq;
run;

proc freq data=fs;
   tables DNA*both_claim / chisq;
run;



data total_award;
length DNA $ 10;
length Method $ 15;
input DNA$ likelihood Method$;
datalines;
0	0.73434	state_award
1	0.9625	state_award
0	0.51078	civil_award
1	0.70466	civil_award
0	0.2419	both_award
1	0.3875	both_award
0	0.44362	state_claim
1	0.82178	state_claim
0	0.38753	civil_claim
1	0.56105	civil_claim
0	0.2272	both_claim
1	0.45215	both_claim
;
run;

/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                                                                                                                                                                  
/* Define the title */                                                                                                                  
title 'The likelihood of filling/ prevaling state or civil right claim';                                                                                                                                                                                                                                
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "likelihood_award");                                                                                                                                                                                                                                       
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                                                                                                                                                              
/* Generate the graph */                                                                                                                
proc gchart data=total_award;                                                                                                       
   vbar DNA / subgroup=DNA group=method sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;
proc gchart data=total_award;                                                                                                       
   vbar method / subgroup=method group=DNA sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;






*////////DEATH PEANTLY ;
***the likelihood_award of previvling compensation between Death_Penalty****;
goptions reset=all;
proc sql;
create table state_award as
select distinct(Death_Penalty) as Death_Penalty, avg(State_Award) as state_award
from ps
group by Death_Penalty;
proc sql;
create table civil_award as
select distinct(Death_Penalty) as Death_Penalty, avg(Award) as civil_award
from pc
group by Death_Penalty;
proc sql;
create table both as
select distinct(Death_Penalty) as Death_Penalty, avg(both_award) as both_award
from ps
group by Death_Penalty;
proc sql;

create table likelihood_award as 
select a.Death_Penalty,a.state_award,b.civil_award,c.both_award
from state_award a, civil_award b,both c
where a.Death_Penalty=b.Death_Penalty and a.Death_Penalty=c.Death_Penalty;
run;

proc print data=likelihood_award;
run;

*method: contingence table;

proc freq data=ps;
   tables Death_Penalty*State_Award / chisq;
run;
proc freq data=pc;
tables Death_Penalty*Award/ chisq;
run;
proc freq data=ps;
   tables Death_Penalty*both_award / chisq;
run;

goptions reset=all;
proc sql;
create table state_claim as
select distinct(Death_Penalty) as Death_Penalty, avg(State_Claim_Made) as state
from fs
group by Death_Penalty;

proc sql;
create table civil_claim as
select distinct(Death_Penalty) as Death_Penalty, avg(Non_Statutory_Case_Filed) as civil
from fc
group by Death_Penalty;

proc sql;
create table both_claim as
select distinct(Death_Penalty) as Death_Penalty, avg(both_claim) as both_claim
from fs
group by Death_Penalty;

proc sql;
create table likelihood_claim as 
select a.Death_Penalty,a.state as state_claim,b.civil as civil_claim,c.both_claim
from state_claim a, civil_claim b,both_claim c
where a.Death_Penalty=b.Death_Penalty and a.Death_Penalty=c.Death_Penalty;
run;

proc print data=likelihood_claim;
run;

*method: contingence table;
proc freq data=fs;
   tables Death_Penalty*State_Claim_Made / chisq;
run;

proc freq data=fc;
tables Death_Penalty*Non_Statutory_Case_Filed/ chisq;
run;

proc freq data=fs;
   tables Death_Penalty*both_claim / chisq;
run;



data total_award;
length Death_Penalty $ 10;
length Method $ 15;
input Death_Penalty$ likelihood Method$;
datalines;
0	0.81487	state_award
1	0.77273	state_award
0	0.56088	civil_award
1	0.52308	civil_award
0	0.28983	both_award
1	0.31818	both_award
0	0.5198	state_claim
1	0.51579	state_claim
0	0.40975	civil_claim
1	0.56034	civil_claim
0	0.38753	both_claim
1	0.40975	both_claim
;
run;



/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                                                                                                                                                                  
/* Define the title */                                                                                                                  
title 'The likelihood of filling/ prevaling state or civil right claim';                                                                                                                                                                                                                                
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "likelihood_award");                                                                                                                                                                                                                                       
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                                                                                                                                                              
/* Generate the graph */                                                                                                                
proc gchart data=total_award;                                                                                                       
   vbar Death_Penalty / subgroup=Death_Penalty group=method sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;
proc gchart data=total_award;                                                                                                       
   vbar method / subgroup=method group=Death_Penalty sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;


*////////state_color;
***the likelihood_award of previvling compensation between State_color****;
goptions reset=all;
proc sql;
create table state_award as
select distinct(State_color) as State_color, avg(State_Award) as state_award
from ps
group by State_color;
proc sql;
create table civil_award as
select distinct(State_color) as State_color, avg(Award) as civil_award
from pc
group by State_color;
proc sql;
create table both as
select distinct(State_color) as State_color, avg(both_award) as both_award
from ps
group by State_color;
proc sql;

create table likelihood_award as 
select a.State_color,a.state_award,b.civil_award,c.both_award
from state_award a, civil_award b,both c
where a.State_color=b.State_color and a.State_color=c.State_color;
run;

proc print data=likelihood_award;
run;

*method: contingence table;

proc freq data=ps;
   tables State_color*State_Award / chisq;
run;
proc freq data=pc;
tables State_color*Award/ chisq;
run;
proc freq data=ps;
   tables State_color*both_award / chisq;
run;

goptions reset=all;
proc sql;
create table state_claim as
select distinct(State_color) as State_color, avg(State_Claim_Made) as state
from fs
group by State_color;

proc sql;
create table civil_claim as
select distinct(State_color) as State_color, avg(Non_Statutory_Case_Filed) as civil
from fc
group by State_color;

proc sql;
create table both_claim as
select distinct(State_color) as State_color, avg(both_claim) as both_claim
from fs
group by State_color;

proc sql;
create table likelihood_claim as 
select a.State_color,a.state as state_claim,b.civil as civil_claim,c.both_claim
from state_claim a, civil_claim b,both_claim c
where a.State_color=b.State_color and a.State_color=c.State_color;
run;

proc print data=likelihood_claim;
run;

*method: contingence table;
proc freq data=fs;
   tables State_color*State_Claim_Made / chisq;
run;

proc freq data=fc;
tables State_color*Non_Statutory_Case_Filed/ chisq;
run;

proc freq data=fs;
   tables State_color*both_claim / chisq;
run;



data total_award;
length State_color $ 10;
length Method $ 15;
input State_color$ likelihood Method$;
datalines;
0	0.78846	state_award
1	0.84669	state_award
0	0.61983	civil_award
1	0.46154	civil_award
0	0.28983	both_award
1	0.31818	both_award
0	0.5198	state_claim
1	0.51579	state_claim
0	0.40975	civil_claim
1	0.56034	civil_claim
0	0.38753	both_claim
1	0.40975	both_claim
;run;



/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                                                                                                                                                                  
/* Define the title */                                                                                                                  
title 'The likelihood of filling/ prevaling state or civil right claim';                                                                                                                                                                                                                                
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "likelihood_award");                                                                                                                                                                                                                                       
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                                                                                                                                                              
/* Generate the graph */                                                                                                                
proc gchart data=total_award;                                                                                                       
   vbar State_color / subgroup=State_color group=method sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;
proc gchart data=total_award;                                                                                                       
   vbar method / subgroup=method group=State_color sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;



*/////////area;

***the likelihood_award of previvling compensation between State_area****;
goptions reset=all;
proc sql;
create table state_award as
select distinct(State_area) as State_area, avg(State_Award) as state_award
from ps
group by State_area;
proc sql;
create table civil_award as
select distinct(State_area) as State_area, avg(Award) as civil_award
from pc
group by State_area;
proc sql;
create table both as
select distinct(State_area) as State_area, avg(both_award) as both_award
from ps
group by State_area;
proc sql;

create table likelihood_award as 
select a.State_area,a.state_award,b.civil_award,c.both_award
from state_award a, civil_award b,both c
where a.State_area=b.State_area and a.State_area=c.State_area;
run;

proc print data=likelihood_award;
run;

*method: contingence table;

proc freq data=ps;
   tables State_area*State_Award / chisq;
run;
proc freq data=pc;
tables State_area*Award/ chisq;
run;
proc freq data=ps;
   tables State_area*both_award / chisq;
run;

goptions reset=all;
proc sql;
create table state_claim as
select distinct(State_area) as State_area, avg(State_Claim_Made) as state
from fs
group by State_area;

proc sql;
create table civil_claim as
select distinct(State_area) as State_area, avg(Non_Statutory_Case_Filed) as civil
from fc
group by State_area;

proc sql;
create table both_claim as
select distinct(State_area) as State_area, avg(both_claim) as both_claim
from fs
group by State_area;

proc sql;
create table likelihood_claim as 
select a.State_area,a.state as state_claim,b.civil as civil_claim,c.both_claim
from state_claim a, civil_claim b,both_claim c
where a.State_area=b.State_area and a.State_area=c.State_area;
run;

proc print data=likelihood_claim;
run;

*method: contingence table;
proc freq data=fs;
   tables State_area*State_Claim_Made / chisq;
run;

proc freq data=fc;
tables State_area*Non_Statutory_Case_Filed/ chisq;
run;

proc freq data=fs;
   tables State_area*both_claim / chisq;
run;



data total_award;
length State_area $ 10;
length Method $ 15;
input State_area$ likelihood Method$;
datalines;
east	0.76617	state_award
midwest	0.86979	state_award
south	0.86134	state_award
west	0.625	state_award
east	0.65566	civil_award
midwest	0.55556	civil_award
south	0.46328	civil_award
west	0.53425	civil_award
east	0.45274	both_award
midwest	0.38542	both_award
south	0.11765	both_award
west	0.16667	both_award
east	0.75	state_claim
midwest	0.56378	state_claim
south	0.43493	state_claim
west	0.35371	state_claim
east	0.5422	civil_claim
midwest	0.57363	civil_claim
south	0.23854	civil_claim
west	0.46795	civil_claim
east	0.47039	both_claim
midwest	0.36735	both_claim
south	0.13527	both_claim
west	0.19651	both_claim
;
run;



/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                                                                                                                                                                  
/* Define the title */                                                                                                                  
title 'The likelihood of filling/ prevaling state or civil right claim';                                                                                                                                                                                                                                
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "likelihood_award");                                                                                                                                                                                                                                       
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                                                                                                                                                              
/* Generate the graph */                                                                                                                
proc gchart data=total_award;                                                                                                       
   vbar State_area / subgroup=State_area group=method sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;
proc gchart data=total_award;                                                                                                       
   vbar method / subgroup=method group=State_area sumvar=likelihood                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;

