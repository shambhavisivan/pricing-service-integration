#!/bin/bash
set -e
echo "Starting PSI CI build on SFDX"

orgAlias=PSI-CI$BUILD_NUMBER

function finish() {
	# make sure scratch org is removed before exit
	echo "Deleting scratch org..."
	sfdx force:org:delete --targetusername $orgAlias --noprompt
}

trap finish EXIT

echo "Creating scratch org..."
sfdx force:org:create --setdefaultusername -f config/project-scratch-def.json --setalias $orgAlias

echo "Installing CS Utilities package"
sfdx force:package:install --package cs-util@1.63 --wait 15 --targetusername $orgAlias

echo "Deploying source code"
sfdx force:source:push --targetusername $orgAlias --wait 10

echo "Running tests"
sfdx force:apex:test:run --testlevel RunLocalTests --targetusername $orgAlias --resultformat tap