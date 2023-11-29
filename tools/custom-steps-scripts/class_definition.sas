proc python;
submit;


class CustomStep:
    """This class helps you create a SAS Studio Custom Step programmatically"""
    def __init__(self, filelocation, name,createdBy="anonymous",pages=1,about=True) -> None:
        from datetime import datetime, timezone
        import json

        self.creationTimeStamp = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.%fZ')
        self.modifiedTimeStamp = self.creationTimeStamp
        self.name=name
        self.displayName=self.name+".step"
        self.localDisplayName=self.displayName
        self.createdBy=createdBy
        self.modifiedBy=self.createdBy
        self.metadataVersion=0.0
        self.version=2
        self.type="code"
        self.flowMetadata={}
        self.ui = json.dumps(PromptUI(pages=pages,about=about).__dict__)
        self.templates={"SAS":"/* templated code goes here*/;"}
        self.create_file(filelocation,name)
    
    def create_file(self,filelocation,name):
        import os
        import json

        with open(os.path.join(filelocation,"{}.step".format(name)),"w") as f:
            json.dump(self.__dict__,f)

class PromptUI:
    """This class helps you create a prompt UI programmatically 
       for use within SAS Studio Custom Steps and job definition 
       prompts.
    """
    def __init__(self, pages=1, about=True) -> None:
        self.showPageContentOnly=True
        self.pages=[]
        for idx in range(0,pages):
            page={}
            page["id"]="page{}".format(idx+1)
            page["type"]="page"
            page["label"]="Page {}".format(idx+1)
            page["children"]=[]
            page["syntaxversion"]="1.3.0"
            self.pages.append(page)
        if about == True:
            page={}
            page["id"]="about"
            page["type"]="page"
            page["label"]="About"
            page["syntaxversion"]="1.3.0"
            page["children"] = [
				{
					"id": "about_description",
					"type": "text",
					"text": "In this section, explain what the custom step does and provide some examples of business use-cases it can support.",
					"visible": ""
				},
				{
					"id": "about_parameters",
					"type": "section",
					"label": "Parameters",
					"open": 0,
					"visible": "",
					"children": [
						{
							"id": "parameters_text",
							"type": "text",
							"text": "Provide some broad parameter descriptions and overall prerequisites or dependencies.  For example, if your custom step runs in CAS: This custom step runs on data loaded to a SAS Cloud Analytics Services (CAS) library (known as a caslib). Ensure you are connected to CAS before running this step. \n\n Or, if your custom steps requires a specific product:  This custom step also requires a SAS ____ license.",
							"visible": ""
						},
						{
							"id": "parameters_input",
							"type": "section",
							"label": "Input Parameters",
							"open": 1,
							"visible": "",
							"children": [
								{
									"id": "input_parameters_text",
									"type": "text",
									"text": "Explain your input parameters here.  Specify the type of control for ease Example:\n\n1. Input table containing a text column (input port, required): attach a CAS table to this port.",
									"visible": ""
								}
							]
						},
						{
							"id": "parameters_output_specs",
							"type": "section",
							"label": "Output Specifications",
							"open": 1,
							"visible": "",
							"children": [
								{
									"id": "output_parameters_text",
									"type": "text",
									"text": "Specify any output details here.  Usually, inform users on any output tables they have to specify.",
									"visible": ""
								}
							]
						}
					]
				},
				{
					"id": "about_runtimecontrol",
					"type": "section",
					"label": "Run-time Control",
					"open": 0,
					"visible": "",
					"children": [
						{
							"id": "runtimecontrol_text",
							"type": "text",
							"text": "Edit / keep this section only if you want to have a run-time control\n\nNote: Run-time control is optional.  You may choose whether to execute the main code of this step or not, based on upstream conditions set by earlier SAS programs.  This includes nodes run prior to this custom step earlier in a SAS Studio Flow, or a previous program in the same session.\n\nRefer this blog (https://communities.sas.com/t5/SAS-Communities-Library/Switch-on-switch-off-run-time-control-of-SAS-Studio-Custom-Steps/ta-p/885526) for more details on the concept.\n\nThe following macro variable,\n\n_<your control>_run_trigger\n\nwill initialize with a value of 1 by default, indicating an \"enabled\" status and allowing the custom step to run.\n\nIf you wish to control execution of this custom step, include code in an upstream SAS program to set this variable to 0.  This \"disables\" execution of the custom step.\n\nTo \"disable\" this step, run the following code upstream:\n\n%global _<your control>_run_trigger;\n%let _<your control>_run_trigger =0;\n\nTo \"enable\" this step again, run the following (it's assumed that this has already been set as a global variable):\n\n%let _<your control>_run_trigger =1;\n\nIMPORTANT: Be aware that disabling this step means that none of its main execution code will run, and any  downstream code which was dependent on this code may fail.  Change this setting only if it aligns with the objective of your SAS Studio program.",
							"visible": ""
						}
					]
				},
				{
					"id": "about_documentation",
					"type": "section",
					"label": "Documentation",
					"open": 0,
					"visible": "",
					"children": [
						{
							"id": "documentation_text",
							"type": "text",
							"text": "Provide a list of references / documentation here with the full web address of any online links.",
							"visible": ""
						}
					]
				},
				{
					"id": "version_text",
					"type": "text",
					"text": "Version: X.X  (DDMONYYYY)",
					"visible": ""
				},
				{
					"id": "contact_text",
					"type": "text",
					"text": "Created/contact: \n\n- Your Name (your.email@address.com)\n",
					"visible": ""
				}
			]
            self.pages.append(page)

        
        
endsubmit;

quit;