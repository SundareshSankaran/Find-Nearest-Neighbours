* Enter the folder in which the SAS Studio Custom Steps are available;
%let sourceFolderServer = /mnt/viya-share/data/;

* If set to one the repository will be cloned into sourceFolderServer path;
* Set the value to 0 if you already have the repository cloned;
%let wantCloning = 0;

* If you have the repository already cloned set this to 1 to pull new changes;
%let wantPull = 1;

* Enter the folder where the SAS Studio Custom Steps should be stored in SAS Content;
%let targetFolderContent = /Public/;

* Replace previously already existing steps - set to true if you want to replace steps;
* Setting this to true is recommend if you pull the repository to get updated steps;
%let replaceSteps = true;

%global targetFolderURI;

/*-----------------------------------------------------------------------------------------*
   Macro to check if a SAS Content folder already exists.
*------------------------------------------------------------------------------------------*/
%macro check_sas_content_folder(targetFolderContent);
/*-----------------------------------------------------------------------------------------*
   This macro will check a given path in SAS Content and set a macro variable to folder URI 
   if it exists, or a direction to the error code if not.
      - targetFolderContent: the full path of the folder to check for
	  - targetFolderURI: set inside macro
*------------------------------------------------------------------------------------------*/
   %local targetPathList;
   %global targetFolderURI;
   
   data _null_;
      call symput("targetPathList",'{"items": ['||'"'||transtrn(strip(transtrn("&targetFolderContent.","/","   ")),"   ",'","')||'"'||'], "contentType": "folder"}');
   run;

   filename pathData temp;
   filename outResp temp;
   data _null_;
      length inputData $32767.;
      inputData = symget("targetPathList");
      file pathData;
	  put inputData;
   run;
%put &targetPathList.;
   proc http
	  method='POST'
	  url="&viyaHost./folders/paths"
	  in=pathData 
	oauth_bearer=sas_services
	out=outResp;
	headers 'Content-Type'='application/vnd.sas.content.folder.path+json';
   quit;
   
   %if "&SYS_PROCHTTP_STATUS_CODE."="200" %then %do;

      * Create a JSON library from response;
      libname outResp json;

      * Get the URI of the folder;
      data _null_;
	     set outResp.links(obs=1);
	     call symput("targetFolderURI", trim(uri));
      run;

   %end;
   %else %do;
      data _null_;
         call symput("targetFolderURI", "Refer SYS_PROCHTTP_STATUS_CODE macro variable.");
      run;
   %end;

%mend check_sas_content_folder;

* Get SAS Viya Host URL;
%let viyaHost = %sysfunc(getoption(SERVICESBASEURL));

%check_sas_content_folder(&targetFolderContent.);

%put &SYS_PROCHTTP_STATUS_CODE. is the code;

%put &targetFolderURI.;


/*-----------------------------------------------------------------------------------------*
   Macro to create a SAS Content folder.
*------------------------------------------------------------------------------------------*/
%macro create_sas_content_folder(targetFolderContent);
/*-----------------------------------------------------------------------------------------*
   This macro will create a desired SAS Content folder based on given parameter.
      - targetFolderContent: the full path of the folder to create
*------------------------------------------------------------------------------------------*/
   %local targetFolderParent;
   data _null_;
      length targetFolderContent $32767.;
      if substr(strip("&targetFolderContent"),length(strip("&targetFolderContent."))-1,1)="/" then targetFolderContent=substr(trim("&targetFolderContent"),1,length(trim("&targetFolderContent."))-1);
      else targetFolderContent=strip("&targetFolderContent.");
      put targetFolderContent;
      substr=substr("&targetFolderContent",length("&targetFolderContent.")-1,1);
      put substr;
      call symput("targetFolderParent",scan(targetFolderContent,-1,"/","MO"));
   run;
   %put &targetFolderContent.;
   %put &targetFolderParent.;

%mend create_sas_content_folder;

%if "&SYS_PROCHTTP_STATUS_CODE."="404" %then %do;



%end;


%if &wantCloning. %then %do;
	data _null_;
		rc = gitfn_clone('https://github.com/sassoftware/sas-studio-custom-steps', "&sourceFolderServer.");
		put rc=;
	run;
%end;

%if &wantPull. %then %do;
	data _null_;
		rc = git_pull("&sourceFolderServer.","git","","/mnt/viya-share/data/keysncerts/id_ecdsa.pub","/mnt/viya-share/data/keysncerts/id_ecdsa");
		put rc=;
	run;
%end;

* Get macros to find all step files in a folder;
filename getmacro url 'https://raw.githubusercontent.com/SASJedi/sas-macros/master/exist.sas';
%include getmacro;
filename getmacro url 'https://raw.githubusercontent.com/SASJedi/sas-macros/master/fileattribs.sas';
%include getmacro;
filename getmacro url 'https://raw.githubusercontent.com/SASJedi/sas-macros/master/translate.sas';
%include getmacro;
filename getmacro url 'https://raw.githubusercontent.com/SASJedi/sas-macros/master/findfiles.sas';
%include getmacro;

* Find all step files and store in a table;
%FindFiles(&sourceFolderServer., step, work._CustomSteps);

filename getmacro clear;



* Get targetFolderContent URI;
* JSON Request Data;
filename pathData temp;

* Create the Input JSON for the POST Call;
data _null_;
	length dataIn $32000. numberOfSlashes 8.;
	numberOfSlashes = count("&targetFolderContent.", '/');

	* Build the JSON Request Data;
	file pathData;
	dataIn = '{"items": [';

	* Separate the elements of the Path;
	_counter = 1;
	do while(_counter <= numberOfSlashes);
		if _counter = 1 then dataIn = strip(dataIn) || '"' || strip(scan("&targetFolderContent.", _counter, '/')) || '"';
		else dataIn = strip(dataIn) || ',"' || strip(scan("&targetFolderContent.", _counter, '/')) || '"';

		if _counter = numberOfSlashes then call symputx('_fileName', strip(scan("&targetFolderContent.", numberOfSlashes, '/')));

		_counter + 1;
	end;

	dataIn = strip(dataIn) || '], "contentType": "folder"}';

	* Write to the file;
	put dataIn;
run;

%put &viyaHost.;


* Create a temporary file;
filename outResp temp;

%put _all_;


 
* Find the Folder URI;
proc http
	method='POST'
	url="https://viya.ext-post-aks.unx.sas.com/folders/paths"
	in=pathData
    verbose 
	oauth_bearer=sas_services
	out=outResp;
	headers 'Content-Type'='application/vnd.sas.content.folder.path+json';
quit;

* Create a JSON library from response;
libname outResp json;

* Get the URI of the folder;
data _null_;
	set outResp.links(obs=1);
	call symput('targetFolderContentURI', trim(uri));
run;

%put &targetFolderContentURI.;

* Clear file & lib to reuse;
filename pathData clear;
filename outResp clear;
libname outResp clear;

%put &pathToStep.;


* Macro to upload and register each Custom Step;
%macro registerStep(pathToStep);
	filename step "&pathToStep.";
	
	* Please note this is an undocumented SAS Viya API-endpoint so might be subject to change!;
	proc http
		url = "&viyahost./dataFlows/steps?parentFolderUri=&targetFolderContentURI.%nrstr(&overwrite)=&replaceSteps."
		in = step
		oauth_bearer = sas_services;
		headers 'Accept'= 'application/vnd.sas.data.flow.step+json';
		headers 'content-type' = 'application/json';
	quit;
	
	%if &SYS_PROCHTTP_STATUS_CODE. EQ 201 %then %put NOTE: &pathToStep. registered successfully;
	%else %if &SYS_PROCHTTP_STATUS_CODE. EQ 409 %then %put WARNING: &pathToStep. already exists;

	filename step clear;
%mend registerStep;

data _null_;
	length arg $32000.;
	set work._CustomSteps;

	arg = cats('%nrstr(%registerStep(%str(', trim(path), '/', trim(filename),".step", ')))');
	call execute(arg);
run;

title 'List of available Custom Steps from the GitHub Repository';
proc print data=work._CustomSteps;
quit;
title;

* Clean up;
proc datasets library=work nolist;
	delete _CustomSteps;
run;
%symdel sourceFolderServer wantCloning wantPull targetFolderContent replaceSteps viyaHost targetFolderContentURI;
%sysmacdelete exist;
%sysmacdelete fileattribs;
%sysmacdelete translate;
%sysmacdelete findfiles;
%sysmacdelete registerStep;