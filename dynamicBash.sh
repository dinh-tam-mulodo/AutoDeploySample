
#!/bin/bash
# Counting the number of lines in a list of files
# function version

join_by(){ local IFS="$1"; shift; echo "$*"; }

# cd /Users/macos/Documents/Deployment/UAT
# #pull code first
# git checkout stagin
# git pull origin stagin

# CHANGED=(`git diff-tree --no-commit-id --name-only -r HEAD~ HEAD | xargs`)

CHANGED=()
CHANGED+=(src/objects/demoDeploy__c.object)
CHANGED+=(src/workflows/demoDeploy__c.workflow)
CHANGED+=("src/layouts/demoDeploy__c-demoDeploy Layout.layout")
CHANGED+=("src/layouts/demoDeploy__c-uat layout.layout")
CHANGED+=("src/globalValueSets/Demo_Deploy.globalValueSet")
CHANGED+=("src/globalValueSets/Demo_Deploy2.globalValueSet")


#Array of pages
pageArr=()
#Array of class
clsArr=()
#Array of trigger
triggerArr=()
#Array of resource
resourceArr=()
#Array of component
componentArr=()
#Array of object
objectArr=()
#Array of workflow
workflowArr=()
#layout
layoutArr=""
#Array of globalValueSet
globalValueSetArr=()

if [ -n "${CHANGED}" ]; then
	#create folder if not exist
	mkdir -p "codeDeployPkg"
	#remove all old files
	rm -rf ./codeDeployPkg/*
	for i in ${!CHANGED[@]}
	do
		metaName=${CHANGED[i]};
		echo $metaName
		if [[ $metaName = *".cls" ]]; then
			className=${metaName#src/classes/}
			clsArr+=("<members>${className%.cls}</members>")
		elif [[ $metaName = *".page" ]]; then
			pageName=${metaName#src/pages/}
	        pageArr+=("<members>${pageName%.page}</members>")
	    elif [[ $metaName = *".trigger" ]]; then
			triggerName=${metaName#src/triggers/}
	        triggerArr+=("<members>${triggerName%.trigger}</members>")
	    elif [[ $metaName = *".resource" ]]; then
			resourceName=${metaName#src/staticresources/}
	        resourceArr+=("<members>${resourceName%.resource}</members>")
	    elif [[ $metaName = *".labels" ]]; then
	        labels="<types>
						<members>CustomLabels</members>
						<name>CustomLabels</name>
					</types>"   
	    elif [[ $metaName = *".component" ]]; then
	    	componentName=${metaName#src/components/}
	        componentArr+=("<members>${componentName%.component}</members>")
	    elif [[ $metaName = *".object" ]]; then
	    	objectName=${metaName#src/objects/}
	        objectArr+=("<members>${objectName%.object}</members>")
	   	elif [[ $metaName = *".workflow" ]]; then
	    	workflowName=${metaName#src/workflows/}
	        workflowArr+=("<members>${workflowName%.workflow}</members>")
	    elif [[ $metaName = *".layout" ]]; then
	    	layoutName=${metaName#src/layouts/}
	    	echo $layoutName
	        layoutArr="$layoutArr <members>${layoutName%.layout}</members>"
	    elif [[ $metaName = *".globalValueSet" ]]; then
	    	globalValueSetName=${metaName#src/globalValueSets/}
	        globalValueSetArr+=("<members>${globalValueSetName%.globalValueSet}</members>")
		fi
	done
	# check pageArr is not Empty
	pages=""
	if [ -n "$pageArr" ]; then
		#join page with comma
		pages=$( join_by "" ${pageArr[@]} )
		pages="<types>$pages<name>ApexPage</name></types>"
	fi
	# check classArr is not Empty
	class=""
	if [ -n "$clsArr" ]; then
		#join class with comma
		class=$( join_by "" ${clsArr[@]} )
		class="<types>$class<name>ApexClass</name></types>"
	fi
	# check trigger is not Empty
	trigger=""
	if [ -n "$triggerArr" ]; then
		#join class with comma
		trigger=$( join_by "" ${triggerArr[@]} )
		trigger="<types>$trigger<name>ApexTrigger</name></types>"
	fi
	# check static resource is not Empty
	resource=""
	if [ -n "$resourceArr" ]; then
		#join class with comma
		resource=$( join_by "" ${resourceArr[@]} )
		resource="<types>$resource<name>StaticResource</name></types>"
	fi
	#check component is not Empty
	component=""
	if [ -n "$componentArr" ]; then
		#join class with comma
		component=$( join_by "" ${componentArr[@]} )
		component="<types>$component<name>ApexComponent</name></types>"
	fi
	#check object Arr is not Empty
	object=""
	if [ -n "$objectArr" ]; then
		#join class with comma
		object=$( join_by "" ${objectArr[@]} )
		object="<types>$object<name>CustomObject</name></types>"
	fi
	#check workflow Arr is not Empty
	workflow=""
	if [ -n "$workflowArr" ]; then
		#join class with comma
		workflow=$( join_by "" ${workflowArr[@]} )
		workflow="<types>$workflow<name>Workflow</name></types>"
	fi
	#check layout Arr is not Empty
	layoutArr="<types>$layoutArr<name>Layout</name></types>"
	#check workflow Arr is not Empty
	globalValueSet=""
	if [ -n "$globalValueSetArr" ]; then
		#join class with comma
		globalValueSet=$( join_by "" ${globalValueSetArr[@]} )
		globalValueSet="<types>$globalValueSet<name>GlobalValueSet</name></types>"
	fi

	packageString="<?xml version=\"1.0\" encoding=\"UTF-8\"?><Package xmlns=\"http://soap.sforce.com/2006/04/metadata\">$pages $class $trigger $resource $labels $object $component $workflow $layoutArr $globalValueSet<version>39.0</version></Package>"

	echo $packageString > codeDeployPkg/package.xml

	# Call ant for retrieve data from dev org
	ant retrieveDataOrgDev

	# Call ant for deploy data to uat org
	ant deployUAT	
fi