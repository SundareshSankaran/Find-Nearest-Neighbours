proc python;

submit;

import json

filelocation="/mnt/viya-share/data/"
name="Find Nearest Neighbors"

step1=CustomStep(filelocation=filelocation, name=name, about=True)


endsubmit;

quit;