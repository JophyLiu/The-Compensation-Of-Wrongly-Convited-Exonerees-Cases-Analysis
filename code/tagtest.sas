*/april/;
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
if State_Claim_Made =1 and civil=1 then both_claim=1;
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
if civil=1;
run;






data compress;
set fs;
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





data compress;
set fc;
text=compress(Tags,';','k');
run;

data t;
set compress;
if text=' ' then  max=length(text);
else max=length(text)+1;
run;

data c;
set t;
do idd=1 to max;
text1=scan(Tags,idd,';');
output;
end;
run;


goptions reset=all;
proc sql;
create table state_claim as
select distinct(text1) as text1, avg(State_Claim_Made) as state
from b
group by text1;

proc sql;
create table civil_claim as
select distinct(text1) as text1, avg(civil) as civil
from c
group by text1;

proc sql;
create table both_claim as
select distinct(text1) as text1, avg(both_claim) as both_claim
from b
group by text1;

proc sql;
create table likelihood_claim as 
select a.text1,a.state,b.civil,c.both_claim
from state_claim a, civil_claim b,both_claim c
where a.text1=b.text1 and a.text1=c.text1;
run;

proc print data=likelihood_claim;
run;

*method: contingence table;


proc freq data=b;
   tables text1*State_Claim_Made / chisq;
run;

proc freq data=c;
tables text1*Non_Statutory_Case_Filed/ chisq;
run;

proc freq data=b;
tables text1*both_claim/ chisq;
run;

data compress;
set ps;
text=compress(Tags,';','k');
run;

data t;
set compress;
if text=' ' then  max=length(text);
else max=length(text)+1;
run;

data e;
set t;
do idd=1 to max;
text1=scan(Tags,idd,';');
output;
end;
run;

data compress;
set pc;
text=compress(Tags,';','k');
run;

data t;
set compress;
if text=' ' then  max=length(text);
else max=length(text)+1;
run;

data f;
set t;
do idd=1 to max;
text1=scan(Tags,idd,';');
output;
end;
run;

***the likelihood_award of previvling compensation between text1****;
goptions reset=all;
proc sql;
create table state_award as
select distinct(text1) as text1, avg(State_Award) as state_award
from e
group by text1;
proc sql;
create table civil_award as
select distinct(text1) as text1, avg(Award) as civil_award
from f
group by text1;

proc sql;
create table likelihood_award as 
select a.text1,a.state_award,b.civil_award
from state_award a, civil_award b
where a.text1=b.text1;
run;
proc print data=likelihood_award;
run;

*method: contingence table;

proc freq data=e;
   tables text1*State_Award / chisq;
run;
proc freq data=f;
tables text1*Award/ chisq;
run;
