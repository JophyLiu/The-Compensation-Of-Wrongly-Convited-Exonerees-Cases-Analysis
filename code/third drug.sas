proc print data=final;**final project/April;
run;

data final;
set final;
if Race='caucasian' then Race='Caucasian';
run;

***simple inquiries***;

*1.	Number of incarcerated (not 0 time) exonerees.*;
data notime;
set final;
if missing(No_Time) then No_Time =.;
run;

proc sql ;
title 'number of incarceted (not 0 time) exonerees N';
select count(No_Time) as answer_of_n
from notime
where No_Time = 0;
proc sql;
title 'number of incarceted (not 0 time) exonerees Y';
select count(No_Time) as answer_of_y
from notime
where No_Time = 1;

goptions reset=all border cback=white htext=10pt htitle=12pt;                                                                                                                                                                                                                                                                                                                    
/* Add a title to the graph */                                                                                                          
title 'Number of incarcerated (not 0 time) exonerees';                                                                                        
                                                                                                                                        
/* Produc the bar chart */   
goptions reset=all border cback=white htext=10pt htitle=12pt; 
axis1 label=("Total");
proc gchart data=final;                                                                                                                                                                                          
  hbar No_Time1 / subgroup= No_Time1 midpoints= 0 to 1 by 1 maxis=axis1;                                                                                           
run;                                                                                                                                    
quit;                                          

*proc sql ;
*title 'number of incarceted (not 0 time) exonerees NA';
*select count(No_Time) as answer_of_na
from notime
where No_Time = .; 

data Incarcerated;
set final;
if Years_Lost =0 then yeargroup='Never Incarcerated';
else yeargroup='Incarcerated';
run;

goptions reset=all border cback=white htext=10pt htitle=12pt;                                                                                                                                                                                                                                                                                                                    
title 'Number of Incarcerated'; 
axis2 label=( "Total"); 
proc gchart data=Incarcerated;                                                                                                                                                                                          
hbar yeargroup / subgroup=yeargroup midpoints= 0 to 1 by 1 maxis=axis2 ; 
run;                                                                                                                                    
quit;

*2.	Number of incarcerated exonerees serving one year or less*;

proc sql;
title 'Number of incarcerated exonerees serving one year or less';
select count(No_time) as serving_less_than_one_year
from final
where No_Time1=0 and Years_Lost<=1;

data inperson;
set final;
where No_Time1=0;
run;
data yeargroup;
set inperson;
if Years_Lost <= 1 then yeargroup='less than one year';
else yeargroup='greater than one year';
run;

goptions reset=all border cback=white htext=10pt htitle=12pt;                                                                                                                                                                                                                                                                                                                    
title 'Number of Year lost'; 
axis2 label=( "Total"); 
proc gchart data=yeargroup;                                                                                                                                                                                          
hbar yeargroup / subgroup=yeargroup midpoints= 0 to 1 by 1 maxis=axis2; 
run;                                                                                                                                    
quit;

*3.	Number of incarcerated exonerees serving more than one year*;
proc sql;
title 'Number of incarcerated exonerees serving more than one year';
select count(No_time) as serving_more_than_one_year
from notime
where No_time=0 and Years_Lost > 1;

*4.	Number of total exonerees by race/gender*;
proc sql;
title 'Number of total exonerees by sex';
select Sex as Sex,count(Sex) as Number_of_exonerees
from final
group by Sex;

goptions reset=all border cback=white htext=10pt htitle=12pt;                                                                                                                                                                                                                                                                                                                    
title 'Number of total exonerees by gender'; 
proc gchart data=final;                                                                                                                                                                                          
hbar Sex / subgroup=Sex ;   
run;                                                                                                                                    
quit;

data final;
set final;
if Race='caucasian' then Race='Caucasian';
run;

proc sql;
title 'Number of total exonerees by race';
select Race as Race,count(Race) as Number_of_Exonerees
from final
group by Race; 

goptions reset=all border cback=white htext=10pt htitle=12pt;                                                                                                                                                                                                                                                                                                                    
title 'Number of total exonerees by race'; 
proc gchart data=final;                                                                                                                                                                                          
hbar Race / subgroup=Race ;   
run;                                                                                                                                    
quit;

*5.	Number of total incarcerated (not 0 time) by race/gender*;
data incarcerated;
set final;
where No_Time=0;
run;

proc sql;
title 'Number of total incarcerated exonerees by sex';
select distinct(Sex) as Sex,count(*) as Number_of_incarcerated_exonerees
from incarcerated
group by Sex;

goptions reset=all border cback=white htext=10pt htitle=12pt;                                                                                                                                                                                                                                                                                                                    
title 'Number of total incarcerated exonerees by sex'; 
proc gchart data=incarcerated;                                                                                                                                                                                          
hbar Sex / subgroup=Sex;  
run;                                                                                                                                    
quit;

proc sql;
title 'Number of total incarcerated exonerees by race';
select Race as Race,count(Race) as Number_of_incarcerated_Exonerees
from incarcerated
group by Race; 

goptions reset=all border cback=white htext=10pt htitle=12pt;                                                                                                                                                                                                                                                                                                                    
title 'Number of total incarcerated exonerees by race'; 
proc gchart data=final;                                                                                                                                                                                          
hbar Race / subgroup=Race;  
Where No_Time=0;
run;                                                                                                                                    
quit;

*6.	Average number of years lost by race/gender*;
proc sql;
title 'Average number of years lost by sex';
create table average_years_lost as
select distinct(Sex) as Sex,avg(Years_Lost) as Average_year_of_lost
from final
group by Sex;

proc gchart data=average_years_lost;                                                                                                                                                                                          
hbar Sex/ sumvar=Average_year_of_lost subgroup=Sex;  
run;                                                                                                                                    
quit;

proc sql;
title 'Number of total incarcerated exonerees by race';
create table average_years_lost_of_Race as
select distinct(Race) as Race,avg(Years_Lost) as  Average_year_of_lost
from final
group by Race; 

proc gchart data=average_years_lost_of_Race;                                                                                                                                                                                          
hbar Race/ sumvar=Average_year_of_lost subgroup=Race; 
run;                                                                                                                                    
quit;

**7.	Number exonerated through CIUs./not through CIUs
a.	% seeking/receiving state compensation
b.	% seeking/receiving civil rights compensation**;
data table1;
set final;
keep CIU State_Claim_Made State_Award civil Award No_Time;
run;
data table1;
set table1;
if No_Time=1 then State_Claim=0;
run;
data table1;
set table1;
if No_Time=1 then State_Claim_Made=0;
run;
data table1;
set table1;
if State_Award=2 then State_Award=0;
run;
data table1;
set table1;
if CIU=. then CIU=0;
run;
proc sort data=table1;
by CIU;
run;


title 'number exonerated through CIUs seeking/recieving';
proc sql;
create table CIU as
select sum(State_Claim_Made) as seeking_state, sum(State_Claim_Made)/count(CIU) as state_p, 
sum(State_Award) as receiving_state,sum(State_Award)/ sum(State_Claim_Made) as state_a_p,
sum(civil) as seeking_civil,sum(civil)/count(CIU) as civil_p,
sum(Award) as receiving_civil,sum(Award)/sum(civil) as civil_a_p
from table1
group by CIU;
proc print DATA=CIU;
RUN;


data totals;
length method $ 20;
input method$ CIU total;
datalines;
seeking_state 0 702
seeking_state 1 82
seeking_civil 0 736
seeking_civil 1 60
receiving_state 0 515
receiving_state 1 66
receiving_civil 0 417
receiving_civil 1 28
;
run;

/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                           
                                                                                                                                        
/* Define the title */                                                                                                                  
title 'number exonerated through or no CIU seeking/recieving compensation';                                                                                         
                                                                                                                                        
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "Total number");                                                                                                
                                                                                                                   
                                                                                                                                        
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                        
                                                                                                                                        
/* Generate the graph */                                                                                                                
proc gchart data=totals;                                                                                                       
   vbar method / subgroup=method group=CIU sumvar=total                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;






**8.	Number with guilty pleas exonerated/without guilty pleas
a.	% seeking/receiving state compensation
b.	% seeking/receiving civil rights compensation**;
data table1;
set final;
keep Guilty_Plea State_Claim_Made State_Award civil Award No_Time;
run;
data table1;
set table1;
if No_Time=1 then State_Claim=0;
run;
data table1;
set table1;
if No_Time=1 then State_Claim_Made=0;
run;
data table1;
set table1;
if State_Award=2 then State_Award=0;
run;
data table1;
set table1;
if Guilty_Plea=. then Guilty_Plea=0;
run;
proc sort data=table1;
by Guilty_Plea;
run;
title 'number exonerated through or no Guilty_Pleas seeking/recieving';
proc sql;
create table Guilty_Plea as
select sum(State_Claim_Made) as seeking_state, sum(State_Claim_Made)/count(Guilty_Plea) as state_p, 
sum(State_Award) as receiving_state,sum(State_Award)/ sum(State_Claim_Made) as state_a_p,
sum(civil) as seeking_civil,sum(civil)/count(Guilty_Plea) as civil_p,
sum(Award) as receiving_civil,sum(Award)/sum(civil) as civil_a_p
from table1
group by Guilty_Plea;
proc print DATA=Guilty_Plea;
RUN;

data totals;
length method $ 20;
input method$ Guilty_Plea total;
datalines;
seeking_state 0 688
seeking_state 1 96
seeking_civil 0 695
seeking_civil 1 101
receiving_state 0 510
receiving_state 1 71
receiving_civil 0 374
receiving_civil 1 71
;
run;

/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                           
                                                                                                                                        
/* Define the title */                                                                                                                  
title 'number exonerated through or no Guilty_Plea seeking/recieving compensation';                                                                                         
                                                                                                                                        
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "Total number");                                                                                                
                                                                                                                   
                                                                                                                                        
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                        
                                                                                                                                        
/* Generate the graph */                                                                                                                
proc gchart data=totals;                                                                                                       
   vbar method / subgroup=method group=Guilty_Plea sumvar=total                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;






**9.	Number assisted by IO/not assisted by IO
a.	% seeking/receiving state compensation
b.	% seeking/receiving civil rights compensation**;
data table1;
set final;
keep IO State_Claim_Made State_Award civil Award No_Time;
run;
data table1;
set table1;
if No_Time=1 then State_Claim=0;
run;
data table1;
set table1;
if No_Time=1 then State_Claim_Made=0;
run;
data table1;
set table1;
if State_Award=2 then State_Award=0;
run;
data table1;
set table1;
if IO=. then IO=0;
run;
proc sort data=table1;
by IO;
run;
title 'number exonerated through IOs seeking/recieving';
proc sql;
create table IO as
select sum(State_Claim_Made) as seeking_state, sum(State_Claim_Made)/count(IO) as state_p, 
sum(State_Award) as receiving_state,sum(State_Award)/ sum(State_Claim_Made) as state_a_p,
sum(civil) as seeking_civil,sum(civil)/count(IO) as civil_p,
sum(Award) as receiving_civil,sum(Award)/sum(civil) as civil_a_p
from table1
group by IO;
proc print DATA=IO;
RUN;

data totals;
length method $ 20;
input method$ IO total;
datalines;
seeking_state 0 784
seeking_civil 0 396
receiving_state 0 581
receiving_civil 0 445
;
run;

/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                           
                                                                                                                                        
/* Define the title */                                                                                                                  
title 'number exonerated through Death_Penalty seeking/recieving compensation';                                                                                         
                                                                                                                                        
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "Total number");                                                                                                
                                                                                                                   
                                                                                                                                        
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                        
                                                                                                                                        
/* Generate the graph */                                                                                                                
proc gchart data=totals;                                                                                                       
   vbar method / subgroup=method group=IO sumvar=total                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;

**10.	Number of DNA exonerees/not DNA exonerees
a.	% seeking/receiving state compensation
b.	% seeking/receiving civil rights compensation**;
data table1;
set final;
keep DNA_only State_Claim_Made State_Award civil Award No_Time;
run;
data table1;
set table1;
if No_Time=1 then State_Claim=0;
run;
data table1;
set table1;
if No_Time=1 then State_Claim_Made=0;
run;
data table1;
set table1;
if State_Award=2 then State_Award=0;
run;
data table1;
set table1;
if DNA_only=. then DNA_only=0;
run;
proc sort data=table1;
by DNA_only;
run;
title 'number exonerated through DNA_onlys seeking/recieving';
proc sql;
create table DNA_only as
select sum(State_Claim_Made) as seeking_state, sum(State_Claim_Made)/count(DNA_only) as state_p, 
sum(State_Award) as receiving_state,sum(State_Award)/ sum(State_Claim_Made) as state_a_p,
sum(civil) as seeking_civil,sum(civil)/count(DNA_only) as civil_p,
sum(Award) as receiving_civil,sum(Award)/sum(civil) as civil_a_p
from table1
group by DNA_only;
proc print DATA=DNA_only;
RUN;

data totals;
length method $ 20;
input method$ DNA_only total;
datalines;
seeking_state 0 535
seeking_state 1 249
seeking_civil 0 603
seeking_civil 1 193
receiving_state 0 344
receiving_state 1 237
receiving_civil 0 309
receiving_civil 1 136
;
run;

/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                           
                                                                                                                                        
/* Define the title */                                                                                                                  
title 'number exonerated through or no DNA seeking/recieving compensation';                                                                                         
                                                                                                                                        
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "Total number");                                                                                                
                                                                                                                   
                                                                                                                                        
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                        
                                                                                                                                        
/* Generate the graph */                                                                                                                
proc gchart data=totals;                                                                                                       
   vbar method / subgroup=method group=DNA_only sumvar=total                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;   

**11.	Number of death penalty cases/not death penalty cases
a.	% seeking/receiving state compensation
b.	% seeking/receiving civil rights compensation**;

data table1;
set final;
keep Death_Penalty State_Claim_Made State_Award civil Award No_Time;
run;
data table1;
set table1;
if No_Time=1 then State_Claim=0;
run;
data table1;
set table1;
if No_Time=1 then State_Claim_Made=0;
run;
data table1;
set table1;
if State_Award=2 then State_Award=0;
run;
data table1;
set table1;
if Death_Penalty=. then Death_Penalty=0;
run;
proc sort data=table1;
by Death_Penalty;
run;
title 'number exonerated through Death_Penaltys seeking/recieving';
proc sql;
create table Death_Penalty as
select sum(State_Claim_Made) as seeking_state, sum(State_Claim_Made)/count(Death_Penalty) as state_p, 
sum(State_Award) as receiving_state,sum(State_Award)/ sum(State_Claim_Made) as state_a_p,
sum(civil) as seeking_civil,sum(civil)/count(Death_Penalty) as civil_p,
sum(Award) as receiving_civil,sum(Award)/sum(civil) as civil_a_p
from table1
group by Death_Penalty;
proc print DATA=Death_Penalty;
RUN;

data totals;
length method $ 20;
input method$ Death_Penalty total;
datalines;
seeking_state 0 735
seeking_state 1 49
seeking_civil 0 731
seeking_civil 1 65
receiving_state 0 547
receiving_state 1 34
receiving_civil 0 411
receiving_civil 1 34
;
run;

/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                           
                                                                                                                                        
/* Define the title */                                                                                                                  
title 'number exonerated through Death_Penalty seeking/recieving compensation';                                                                                         
                                                                                                                                        
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "Total number");                                                                                                
                                                                                                                   
                                                                                                                                        
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                        
                                                                                                                                        
/* Generate the graph */                                                                                                                
proc gchart data=totals;                                                                                                       
   vbar method / subgroup=method group=Death_Penalty sumvar=total                                                                           
                  legend=legend1 space=0 gspace=4                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;   


*12.	Number of each crime
a.	% seeking/receiving state compensation
b.	% seeking/receiving civil rights compensation*;



data table1;
set final;
keep Worst_Crime_ State_Claim_Made State_Award civil Award No_Time;
run;
data table1;
set table1;
if No_Time=1 then State_Claim=0;
run;
data table1;
set table1;
if No_Time=1 then State_Claim_Made=0;
run;
data table1;
set table1;
if State_Award=2 then State_Award=0;
run;

proc sort data=table1;
by Worst_Crime_;
run;
title 'number exonerated through Worst_Crime_s seeking/recieving';
proc sql;
create table Worst_Crime_ as
select sum(State_Claim_Made) as seeking_state, sum(State_Claim_Made)/count(Worst_Crime_) as state_p, 
sum(State_Award) as receiving_state,sum(State_Award)/ sum(State_Claim_Made) as state_a_p,
sum(civil) as seeking_civil,sum(civil)/count(Worst_Crime_) as civil_p,
sum(Award) as receiving_civil,sum(Award)/sum(civil) as civil_a_p
from table1
group by Worst_Crime_;
proc print DATA=Worst_Crime_;
RUN;

proc print data=Worst_Crime_;
run;


data totals;
length method $ 20;
length Worst_Crime_ $ 20;
input method$ Worst_Crime_$ total;
datalines;
seeking_state	murder	364
seeking_state	sexual_assault	172
seeking_state	drugs	22
seeking_state	child_sexual_abuse	89
seeking_state	robbery	45
seeking_state	other	92
receiving_state	murder	266
receiving_state	sexual_assault	155
receiving_state	drugs	14
receiving_state	child_sexual_abuse	61
receiving_state	robbery	32
receiving_state	other	53
seeking_civil	murder	459
seeking_civil	sexual_assault	115
seeking_civil	drugs	27
seeking_civil	child_sexual_abuse	71
seeking_civil	robbery	27
seeking_civil	other	97
receiving_civil	murder	253
receiving_civil	sexual_assault	66
receiving_civil	drugs	14
receiving_civil	child_sexual_abuse	41
receiving_civil	robbery	12
receiving_civil	other	59
;
run;

/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                           
                                                                                                                                        
/* Define the title */                                                                                                                  
title 'number exonerated through or no Crime seeking/recieving compensation';                                                                                         
                                                                                                                                        
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "Total number");                                                                                                
axis3 label=none;                                                                                                                     
                                                                                                                                        
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                        
                                                                                                                                        
/* Generate the graph */                                                                                                                
proc gchart data=totals;                                                                                                       
   vbar method / subgroup=method group=Worst_Crime_ sumvar=total                                                                           
                  legend=legend1 space=0 gspace=2                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3 inside=sum;                                                                                   
run;                                                                                                                                    
quit;   





*********seperate the tag with different row************************;
proc print data=tag;**tag_april.xlsx;
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

data b;
set b;
if missing(State_Award) then State_Award =0;
run;
**13.	Number of each tag
a.	% seeking/receiving state compensation
b.	% seeking/receiving civil rights compensation**;
proc sql;
title'tag';
select distinct(text1)
from b;
run;


data tag_table;
set b;
keep text1 State_Claim_Made State_Award civil Award No_Time;
run;
data tag_table;
set table1;
if No_Time=1 then State_Claim=0;
run;
data tag_table;
set tag_table;
if No_Time=1 then State_Claim_Made=0;
run;
data tag_table;
set tag_table;
if State_Award=2 then State_Award=0;
run;

proc sort data=tag_table;
by text1;
run;
title 'number exonerated through text1s seeking/recieving';
proc sql;
create table text1 as
select sum(State_Claim_Made) as seeking_state, sum(State_Claim_Made)/count(text1) as state_p, 
sum(State_Award) as receiving_state,sum(State_Award)/ sum(State_Claim_Made) as state_a_p,
sum(civil) as seeking_civil,sum(civil)/count(text1) as civil_p,
sum(Award) as receiving_civil,sum(Award)/sum(civil) as civil_a_p
from tag_table
group by text1;
proc print DATA=text1;
RUN;

proc print data=text1;
run;

data totals;
length method $ 20;
length Worst_Crime_ $ 5;
input method$ tag$ total;
datalines;
seeking_state	A	30
seeking_state	CDC	102
seeking_state	CIU	81
seeking_state	CV	204
seeking_state	F	36
seeking_state	H	366
seeking_state	JI	45
seeking_state	NC	131
seeking_state	P	74
receiving_state	A	44
receiving_state	CDC	133
receiving_state	CIU	180
receiving_state	CV	225
receiving_state	F	53
receiving_state	H	422
receiving_state	JI	52
receiving_state	NC	250
receiving_state	P	179
seeking_civil	A	22
seeking_civil	CDC	143
seeking_civil	CIU	56
seeking_civil	CV	183
seeking_civil	F	56
seeking_civil	H	462
seeking_civil	JI	83
seeking_civil	NC	138
seeking_civil	P	80
receiving_civil	A	15
receiving_civil	CDC	98
receiving_civil	CIU	28
receiving_civil	CV	100
receiving_civil	F	28
receiving_civil	H	262
receiving_civil	JI	51
receiving_civil	NC	70
receiving_civil	P	59
;
run;
/* Set the graphics environment */                                                                                                      
goptions reset=all cback=white border htitle=12pt htext=10pt;                                                                           
                                                                                                                                        
/* Define the title */                                                                                                                  
title 'number exonerated through Death_Penalty seeking/recieving compensation';                                                                                         
                                                                                                                                        
/* Define the axis characteristics */                                                                                                   
axis1 value=none label=none;                                                                                                          
axis2 label=(angle=90 "Total number");                                                                                                
axis3 label=none;                                                                                                                     
                                                                                                                                        
/* Define the legend options */                                                                                                         
legend1 frame;                                                                                                                        
                                                                                                                                        
/* Generate the graph */                                                                                                                
proc gchart data=totals;                                                                                                       
   vbar method / subgroup=method group=tag sumvar=total                                                                           
                  legend=legend1 space=0 gspace=2                                                                                        
                  maxis=axis1 raxis=axis2 gaxis=axis3;                                                                                   
run;                                                                                                                                    
quit; 












