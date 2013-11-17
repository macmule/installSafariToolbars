#!/bin/bash
####################################################################################################
#
# More information: http://macmule.com/2012/08/01/deploying-installing-safari-toolbars
#
# GitRepo: https://github.com/macmule/installSafariToolbars/
#
# License: http://macmule.com/license/
#
###################################################################################################
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

# HARDCODED VALUES ARE SET HERE
archiveFileName=""
bundleDirectoryName=""

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN
if [ "$4" != "" ] && [ "$archiveFileName" == "" ];then
	archiveFileName=$4
fi

if [ "$5" != "" ] && [ "$bundleDirectoryName" == "" ];then
	bundleDirectoryName=$5
fi

# ONLY ERRORS IF NO VALUE HAS BEEN PASSED FOR $4 OR $5
if [ "$archiveFileName" == "" ]; then
	echo "Error: The parameter 'archiveFileName' is blank."
	exit 1
fi

if [ "$bundleDirectoryName" == "" ]; then
	echo "Error: The parameter 'bundleDirectoryName' is blank."
	exit 1
fi

####################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

#Get logged in users shortname
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

#If ~/Library/Safari/Extensions/Extensions.plist does not exist, then create it.
if [[ ! -f /Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist ]]; then

	sudo /usr/libexec/PlistBuddy -c "Add :Available\ Updates dict" /Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist
	sudo /usr/libexec/PlistBuddy -c "Add :Available\ Updates:Updates\ List array" /Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist
	sudo /usr/libexec/PlistBuddy -c "Add :Installed\ Extensions array" /Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist
	sudo /usr/libexec/PlistBuddy -c "Add :Version integer 1" /Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist

	echo "/Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist did not exist, created..."

fi

# Check to see if the toolbar exists
toolbarCheck=`sudo /usr/libexec/PlistBuddy -c "Print :Installed\ Extensions:" /Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist | grep -n "Archive File Name = $archiveFileName" | awk '{print $1}' | cut -d ":" -f1`

# Check to see if the toolbar is not installed...
if [[ -z $toolbarCheck ]]; then
	
	echo "Toolbar called $archiveFileName not installed for user $loggedInUser..."
	
	dictionariesWithinArray=`sudo /usr/libexec/PlistBuddy -c "Print :Installed\ Extensions:" /Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist | grep -c "Dict {"`
	
	echo "The Installed Extensions array contains $dictionariesWithinArray dictionaries..."
	
		sudo /usr/libexec/PlistBuddy -c "Add :Installed\ Extensions:"$dictionariesWithinArray":Added\ Non-Default\ Toolbar\ Items array" /Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist
		sudo /usr/libexec/PlistBuddy -c "Add :Installed\ Extensions:"$dictionariesWithinArray":Archive\ File\ Name string $archiveFileName" /Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist
		sudo /usr/libexec/PlistBuddy -c "Add :Installed\ Extensions:"$dictionariesWithinArray":Bundle\ Directory\ Name string $bundleDirectoryName" /Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist
		sudo /usr/libexec/PlistBuddy -c "Add :Installed\ Extensions:"$dictionariesWithinArray":Enabled bool true" /Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist
		sudo /usr/libexec/PlistBuddy -c "Add :Installed\ Extensions:"$dictionariesWithinArray":Hidden\ Bars array" /Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist
		sudo /usr/libexec/PlistBuddy -c "Add :Installed\ Extensions:"$dictionariesWithinArray":Removed\ Default\ Toolbar\ Items array" /Users/"$loggedInUser"/Library/Safari/Extensions/Extensions.plist
	
	echo "Written settings for $archiveFileName..."

else

	# If the toolbar is installed..
	echo "Toolbar called $archiveFileName is installed for user $loggedInUser..."

fi
