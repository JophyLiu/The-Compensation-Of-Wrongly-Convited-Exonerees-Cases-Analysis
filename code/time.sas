data ps;
set ps;
drop time;
run;
data fs;
set fs;
drop time;
run;
data pc;
set pc;
drop time;
run;
data fc;
set fc;
drop time;
run;

data ps;
set ps;
length time $ 10;
if Exonerated_Year<=1990 then time= '1990before';
run;

data ps;
set ps;
if 1990<Exonerated_Year<=1995 then time= '1991-1995';
run;

data ps;
set ps;
if 1995<Exonerated_Year<=2000 then time= '1996-2000';
run;

data ps;
set ps;
if 2000<Exonerated_Year<=2005 then time= '2001-2005';
run;

data ps;
set ps;
if 2005<Exonerated_Year<=2010 then time= '2006-2010';
run;
data ps;
set ps;
if 2010<Exonerated_Year<=2015 then time= '2011-2015';
run;
data ps;
set ps;
if Exonerated_Year>2015 then time= '2016after';
run;

data pc;
set pc;
length time $ 10;
if Exonerated_Year<=1990 then time= '1990before';
run;

data pc;
set pc;
if 1990<Exonerated_Year<=1995 then time= '1991-1995';
run;

data pc;
set pc;
if 1995<Exonerated_Year<=2000 then time= '1996-2000';
run;

data pc;
set pc;
if 2000<Exonerated_Year<=2005 then time= '2001-2005';
run;

data pc;
set pc;
if 2005<Exonerated_Year<=2010 then time= '2006-2010';
run;
data pc;
set pc;
if 2010<Exonerated_Year<=2015 then time= '2011-2015';
run;
data pc;
set pc;
if Exonerated_Year>2015 then time= '2016after';
run;

data fs;
set fs;
length time $ 10;
if Exonerated_Year<=1990 then time= '1990before';
run;

data fs;
set fs;
if 1990<Exonerated_Year<=1995 then time= '1991-1995';
run;

data fs;
set fs;
if 1995<Exonerated_Year<=2000 then time= '1996-2000';
run;

data fs;
set fs;
if 2000<Exonerated_Year<=2005 then time= '2001-2005';
run;

data fs;
set fs;
if 2005<Exonerated_Year<=2010 then time= '2006-2010';
run;
data fs;
set fs;
if 2010<Exonerated_Year<=2015 then time= '2011-2015';
run;
data fs;
set fs;
if Exonerated_Year>2015 then time= '2016after';
run;

data fc;
set fc;
length time $ 10;
if Exonerated_Year<=1990 then time= '1990before';
run;

data fc;
set fc;
if 1990<Exonerated_Year<=1995 then time= '1991-1995';
run;

data fc;
set fc;
if 1995<Exonerated_Year<=2000 then time= '1996-2000';
run;

data fc;
set fc;
if 2000<Exonerated_Year<=2005 then time= '2001-2005';
run;

data fc;
set fc;
if 2005<Exonerated_Year<=2010 then time= '2006-2010';
run;
data fc;
set fc;
if 2010<Exonerated_Year<=2015 then time= '2011-2015';
run;
data fc;
set fc;
if Exonerated_Year>2015 then time= '2016after';
run;

