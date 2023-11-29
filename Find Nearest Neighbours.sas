/* templated code goes here*/;
/*-----------------------------------------------------------------------------------------*
   START MACRO DEFINITIONS.
*------------------------------------------------------------------------------------------*/

/* -----------------------------------------------------------------------------------------* 
   Error flag for capture during code execution.
*------------------------------------------------------------------------------------------ */

%global _fnn_error_flag;
%let _fnn_error_flag=0;

/* -----------------------------------------------------------------------------------------* 
   Global macro variable for the trigger to run this custom step. A value of 1 
   (the default) enables this custom step to run.  A value of 0 (provided by upstream code)
   sets this to disabled.
*------------------------------------------------------------------------------------------ */

%global _fnn_run_trigger;

%if %sysevalf(%superq(_fnn_run_trigger)=, boolean)  %then %do;

	%put NOTE: Trigger macro variable _fnn_run_trigger does not exist. Creating it now.;
    %let _fnn_run_trigger=1;

%end;

/*-----------------------------------------------------------------------------------------*
   Macro variable to capture indicator of a currently active CAS session
*------------------------------------------------------------------------------------------*/

%global casSessionExists;
%global _current_uuid_;

/*-----------------------------------------------------------------------------------------*
   Macro to capture indicator and UUID of any currently active CAS session.
   UUID is not expensive and can be used in future to consider graceful reconnect.
*------------------------------------------------------------------------------------------*/

%macro _fnn_checkSession;
   %if %sysfunc(symexist(_SESSREF_)) %then %do;
      %let casSessionExists= %sysfunc(sessfound(&_SESSREF_.));
      %if &casSessionExists.=1 %then %do;
         proc cas;
            session.sessionId result = sessresults;
            call symputx("_current_uuid_", sessresults[1]);
            %put NOTE: A CAS session &_SESSREF_. is currently active with UUID &_current_uuid_. ;
         quit;
      %end;
   %end;
%mend _fnn_checkSession;

/*-----------------------------------------------------------------------------------------*
   This macro creates a global macro variable called _usr_nameCaslib
   that contains the caslib name (aka. caslib-reference-name) associated with the libname 
   and assumes that the libname is using the CAS engine.

   As sysvalue has a length of 1024 chars, we use the trimmed option in proc sql
   to remove leading and trailing blanks in the caslib name.
*------------------------------------------------------------------------------------------*/

%macro _usr_getNameCaslib(_usr_LibrefUsingCasEngine); 

   %global _usr_nameCaslib;
   %let _usr_nameCaslib=;

   proc sql noprint;
      select sysvalue into :_usr_nameCaslib trimmed from dictionary.libnames
      where libname = upcase("&_usr_LibrefUsingCasEngine.") and upcase(sysname)="CASLIB";
   quit;

%mend _usr_getNameCaslib;

/*-----------------------------------------------------------------------------------------*
   EXECUTION CODE MACRO 
*------------------------------------------------------------------------------------------*/

%macro _fnn_main_execution_code;

/*-----------------------------------------------------------------------------------------*
   Check for an active CAS session
*------------------------------------------------------------------------------------------*/

   %_fnn_checkSession;

   %if &casSessionExists. = 0 %then %do;
      %put ERROR: A CAS session does not exist. Connect to a CAS session upstream. ;
      %let _fnn_error_flag = 1;
   %end;
   %else %do;
/*-----------------------------------------------------------------------------------------*
   Check Input (base) table libref to ensure it points to a valid caslib.
*------------------------------------------------------------------------------------------*/

      %if &_fnn_error_flag. = 0 %then %do;

         %global baseCaslib;
   
         %_usr_getNameCaslib(&baseTable_lib.);
         %let baseCaslib=&_usr_nameCaslib.;
         %put NOTE: &baseCaslib. is the caslib for the base table.;
         %let _usr_nameCaslib=;

         %if "&baseCaslib." = "" %then %do;
            %put ERROR: Base table caslib is blank. Check if Base table is a valid CAS table. ;
            %let _fnn_error_flag=1;
         %end;

      %end;

/*-----------------------------------------------------------------------------------------*
   Check Input (query) table libref to ensure it points to a valid caslib.
*------------------------------------------------------------------------------------------*/

      %if &_fnn_error_flag. = 0 %then %do;

         %global queryCaslib;
   
         %_usr_getNameCaslib(&queryTable_lib.);
         %let queryCaslib=&_usr_nameCaslib.;
         %put NOTE: &queryCaslib. is the caslib for the query table.;
         %let _usr_nameCaslib=;

         %if "&queryCaslib." = "" %then %do;
            %put ERROR: Query table caslib is blank. Check if Query table is a valid CAS table. ;
            %let _fnn_error_flag=1;
         %end;

      %end;

/*-----------------------------------------------------------------------------------------*
   Check Output table libref to ensure it points to a valid caslib.
*------------------------------------------------------------------------------------------*/

      %if &_fnn_error_flag. = 0 %then %do;

         %global outputCaslib;
   
         %_usr_getNameCaslib(&outputTable_lib.);
         %let outputCaslib=&_usr_nameCaslib.;
         %put NOTE: &outputCaslib. is the output caslib.;
         %let _usr_nameCaslib=;

         %if "&outputCaslib." = "" %then %do;
            %put ERROR: Output table caslib is blank. Check if Output table is a valid CAS table. ;
            %let _fnn_error_flag=1;
         %end;

      %end;

/*-----------------------------------------------------------------------------------------*
   Check Output (distance) table libref to ensure it points to a valid caslib.
*------------------------------------------------------------------------------------------*/

      %if &_fnn_error_flag. = 0 %then %do;

         %global outputDistCaslib;
   
         %_usr_getNameCaslib(&outputDistTable_lib.);
         %let outputDistCaslib=&_usr_nameCaslib.;
         %put NOTE: &outputDistCaslib. is the output distance table caslib.;
         %let _usr_nameCaslib=;

         %if "&outputDistCaslib." = "" %then %do;
            %put ERROR: Output distance table caslib is blank. Check if Output distance table is a valid CAS table. ;
            %let _fnn_error_flag=1;
         %end;

      %end;

/*-----------------------------------------------------------------------------------------*
   Run CAS statements
*------------------------------------------------------------------------------------------*/

      %if &_fnn_error_flag. = 0 %then %do;
 
         proc cas;         

/*-----------------------------------------------------------------------------------------*
   Obtain inputs from UI.
*------------------------------------------------------------------------------------------*/

            inputTableName      = symget("inputTable_name_base");
            inputTableLib       = symget("inputCaslib");
            queryTableName      = symget("queryTable_name_base");
            queryTableLib       = symget("queryCaslib");
            outputTableName     = symget("outputTable_name_base");
            outputTableLib      = symget("outputCaslib");
            outputDistTableName = symget("outputDistTable_name_base");
            outputDistTableLib  = symget("outputDistCaslib");

            idCol               = symget("idCol");
            numMatches          = symget("numMatches");
            thresholdDistance   = symget("thresholdDistance");
            searchMethod        = symget("searchMethod");
            parallelization     = symget("parallelization");

            mTrees              = symget("mTrees");
            maxPoints           = symget("maxPoints");

/*-----------------------------------------------------------------------------------------*
   
*------------------------------------------------------------------------------------------*/
   


/*-----------------------------------------------------------------------------------------*
   Compile model.
*------------------------------------------------------------------------------------------*/
 
 

/*-----------------------------------------------------------------------------------------*
   Score text to obtain sentences.
*------------------------------------------------------------------------------------------*/

 

           
/*-----------------------------------------------------------------------------------------*
   Model validation is unlikely to error for a statically defined model, but good practice.
*------------------------------------------------------------------------------------------*/


         quit;

/*-----------------------------------------------------------------------------------------*
   FUTURE PLACEHOLDER: The below step has potential for some refactoring with CASL 
   in future. 
   Fact result IDs, through a perhaps lovable quirk of the applyConcept action, are ordered
   in descending order, giving a _result_id_ of 1 to the last occurrence of a sentence, 
   rather than the first.  This data step corrects the same and also generates an overall
   Observation ID which combines the original DocID and Sentence ID.
*------------------------------------------------------------------------------------------*/
         %if %sysfunc(upcase("&docId_1_type."))="NUMERIC" %then %do;
            data &outputtable.;
               length Obs_ID $40. total_sentences 8. ;
               retain total_sentences;
               set &outputtable.(rename=(_result_Id_=_sentence_id_) drop=_fact_argument_ _fact_ _path_);
               by &docId. _start_ ;
               if first.&docId. then do;
                  total_sentences = _sentence_id_;
               end;
               Obs_ID = compress(put(&docId.,z10.)||"_"||put((sum(total_sentences,1)-_sentence_id_),z15.));               _sentence_id_ = sum(total_sentences,1)-_sentence_id_;
            run;
         %end;
         %else %do;
            data &outputtable.;
               length Obs_ID $40. total_sentences 8. ;
               retain total_sentences;
               set &outputtable.(rename=(_result_Id_=_sentence_id_) drop=_fact_argument_ _fact_ _path_);
               by &docId. _start_ ;        
               if first.&docId. then do;
                  total_sentences = _sentence_id_;
               end;
               Obs_ID = compress(substr(compress(&docId.),1,24)||"_"||put((sum(total_sentences,1)-_sentence_id_),z15.));
            run;
         %end;
      %end;
   %end;

%mend _fnn_main_execution_code;


/*-----------------------------------------------------------------------------------------*
   END MACRO DEFINITIONS.
*------------------------------------------------------------------------------------------*/




/*-----------------------------------------------------------------------------------------*
   Clean up existing macro variables and macro definitions.
*------------------------------------------------------------------------------------------*/
%symdel _fnn_error_flag;
%symdel _fnn_run_trigger;
%symdel casSessionExists;
%symdel _current_uuid_;
%symdel _usr_nameCaslib;
%symdel inputCaslib;
%symdel outputCaslib;

%sysmacdelete _fnn_checkSession;
%sysmacdelete _usr_getNameCaslib;
%sysmacdelete _fnn_main_execution_code;