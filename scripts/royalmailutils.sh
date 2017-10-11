#!/bin/bash

# We need the ROYALMAIL_PROJECT_FOLDER environment variable set before
# we continue (must be set within ~/.bashrc) ...

# Check ROYALMAIL_PROJECT_FOLDER set ...


if [ "a${ROYALMAIL_PROJECT_FOLDER}" = "a" ]
then
	echo "[ERR] ROYALMAIL_PROJECT_FOLDER environment variable not set. This needs to be set to the absolute folder name containing the test POM"
	exit 1
fi

# Check that folder exists ...

if [ ! -d "${ROYALMAIL_PROJECT_FOLDER}" ]
then
	echo "[ERR] Royal Mail Project Folder ${ROYALMAIL_PROJECT_FOLDER} does not exist."
	exit 1
fi

# Check that folder contains POM ...
if [ ! -f "${ROYALMAIL_PROJECT_FOLDER}/pom.xml" ]
then
	echo "[ERR] Royal Mail Project POM does not exist in ${ROYALMAIL_PROJECT_FOLDER}"
	exit 1
fi

function getRoyalMailProjectFolderWindows(){
	echo ${1} | sed s/"^\/\([^\/]*\)"/"\1:"/g | sed s/"\/"/"\\\\"/g | tr "[a-z]" "[A-Z]"
}

export ROYALMAIL_PROJECT_FOLDER_WINDOWS="`getRoyalMailProjectFolderWindows ${ROYALMAIL_PROJECT_FOLDER}`"
export ROYALMAIL_PROPERTIES="${ROYALMAIL_PROJECT_FOLDER}/src/test/resources/royalmail.properties"

function createTempFolder(){

	if [ ! -d "${ROYALMAIL_PROJECT_FOLDER}/target/tmp" ]
	then
		mkdir "${ROYALMAIL_PROJECT_FOLDER}"/target/tmp 2>/dev/null
	
		if [ ! "${?}" = "0" ]
		then
			echo "[WARN] Failed to create ${ROYALMAIL_PROJECT_FOLDER}/target/tmp"
		fi
	fi

	export TEMP_FOLDER="${ROYALMAIL_PROJECT_FOLDER}/target/tmp"
}

function GetProperty(){

	file="${1}"
	property="${2}"

	if [ "a${file}" = "a" ]
	then
		echo "[ERR] Property file not given"
		exit 1
	fi

	if [ "a${property}" = "a" ]
	then
		echo "[ERR] Property not given"
		exit 1
	fi

	cat "${file}" | sed -n s/"^[ ]*$property=[ ]*[\"]*\(.*\)\"*$"/"\1"/p
}

function GetApkLocation(){

	ENV="${1}"

	GetProperty "${ROYALMAIL_PROJECT_FOLDER}/src/test/resources/environments/${ENV}/environment.properties" "app.src"
}


function GetAppId(){
	ENV="${1}"

	GetProperty "${ROYALMAIL_PROJECT_FOLDER}/src/test/resources/environments/${ENV}/environment.properties" "app.id"
}

function GetDeviceEmulator(){
	GetProperty "${ROYALMAIL_PROPERTIES}" "device.emulator"
}

if [ "a${UTIL_INIT}" = "a" ]
then
	echo "[INFO] Project Folder		:${ROYALMAIL_PROJECT_FOLDER} (${ROYALMAIL_PROJECT_FOLDER_WINDOWS})"

	createTempFolder

	export UTIL_INIT="done"
fi
