*-------------------------------------------MACROS--------------------------------------;
*Macros are a great thing to learn to make your life easier when you get into advanced coding.
Macros allow you to run one model on a bunch of different variables w/o having to retype
the model a million types.  This will be esp. useful in single marker analyses.  I present
a simple example, using our PROC MIXED code from above to execute for the agronomic traits.;

*To write a macro, put together a model and make sure it'll work on it's own first.  Here,
I copied and pasted one of the models from above.  Then, you write %macro xxxx(yyyy), where
xxxx will be the name of your macro, and yyyy is the name of the macro variable.  In the macro
code itself, change whatever variables should change between the analyses to &yyyy.  Lastly,
put %mend to end the macro.

*To execute the macro, use %xxxx(yyyy), using your macro name and macro variables from above.
Make sure you highlight both the actual macro code and the execute lines when you hit "run".;

%macro traits(trait);
proc mixed data=dataset;
	title "&trait analysis";
	class year rep geno;
	model &trait =;
	random geno year rep(year) geno*year;
run;
%mend;

%traits(PHT);
%traits(EHT);
%traits(EP);
