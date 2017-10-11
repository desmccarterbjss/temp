. "${ROYALMAIL_PROJECT_FOLDER}/scripts/royalmailutils.sh"

SITE="${ROYALMAIL_PROJECT_FOLDER}/target/site"

# Tests are run against emulator by default ...
RUN_AGAINST_PHYSICAL_DEVICE="false"
CHECKOUT_APK="false"

unset RUN_SELENDROID

function setEnvironmentInMainProperties(){

	ENV="${1}"

	TEMP_PROPERTIES="${TEMP_FOLDER}/`basename ${ROYALMAIL_PROPERTIES}`"

	cat "${ROYALMAIL_PROPERTIES}" | sed s/"^\([|	]*test\.environment\)=.*$"/"\1=$ENV"/g >  "${TEMP_PROPERTIES}"

	mv "${TEMP_PROPERTIES}" "${ROYALMAIL_PROPERTIES}"
}

function refreshApk(){
	echo "[INFO] attempting to get fresh copy of APK (${*}) ..."

	if [[ -z "${*}" ]]
	then
		echo "[ERR] No APK given"
		exit 1
	fi

	TARGET_APK="${*}"
	ROOT_FOLDER_OF_APK="`dirname ${TARGET_APK}`"
	UNTOUCHED_APK="${ROOT_FOLDER_OF_APK}/untouched/`basename ${TARGET_APK}`"

	if [[ ! -f "${UNTOUCHED_APK}" ]]
	then
		echo "[ERR] Original APK ${UNTOUCHED_APK} does not exist"
		exit 1
	fi

	# Selendroid 'modifies' an APK when launched, so 
	# copying fresh copy of APK to target (which will be touched by selendroid) ...

	echo "[INFO] Getting fresh copy of APK ${TARGET_APK} (from ${UNTOUCHED_APK}) ..."

	cp "${UNTOUCHED_APK}" "${TARGET_APK}" 2>/dev/null

	if [ ! "a${?}" = "a0" ]
	then
		echo "[ERR] Failed to create fresh APK ${TARGET_APK}"

		exit 1
	fi

	echo "[INFO] Done"
}

function prepareTestRun(){
	if [ -d "${SITE}" ]
	then
		echo "[INFO] Cleaning site ..."
	fi

	refreshApk "${APK}"
}

function processArgs(){
	while [ ! "a${1}" = "a" ]
	do
		if [ "${1}" = "-test-criteria" ]
		then
			shift
	
			if [ "a${1}" = "a" ]
			then
				echo "[ERR] -test-critera flag requires criteria of tests to run, e.g. -test-criteria 'sprint1' ... "
				exit 1
			fi
	
			CRITERIA="${1}"
		elif [ "${1}" = "--usage" ]
		then
			usage
			exit 0
		elif [ "${1}" = "--run-selendroid" ]
		then
			RUN_SELENDROID=" ${1} "
		elif [ "${1}" = "--run-against-physical-device" ]
		then
			RUN_AGAINST_PHYSICAL_DEVICE=true
		elif [ "${1}" = "-environment" ]
		then
			shift
	
			if [ "a${1}" = "a" ]
			then
				echo "[ERR] -environment flag requires an environment, e.g. -apk 'qa' or -apk 'sit' or -apk 'pre-prod' ... "
				exit 1
			fi
	
			export TEST_ENVIRONMENT="${1}"
		else
			echo "Unknown argument ${1}"
			exit 1
		fi
	
		shift
	done
}

function usage(){
	echo "[INFO] Usage: `basename ${0}` -test-criteria '<criteria>' [--run-against-physical-device] [--git-checkout-apk]"
	echo "[INFO]        Arguments in square brackets [...] are optional"
}

function checkArgs(){
	if [ "a${CRITERIA}" = "a" ]
	then
		echo "[ERR] Criteria not set."
	
		usage
	
		exit 1
	fi
	
	echo "[INFO] Test Criteria is ${CRITERIA}"
}

function tidyReports(){
	if [ -d "${SITE}" ]
	then
		OUTPUT_FOLDER=~/testresults/`date +%F`
	
		cd "${SITE}"
	
		tar -cvpf ~/"${CRITERIA}.tar" * &>/dev/null
	
		if [ ! -d ${OUTPUT_FOLDER}/${CRITERIA} ]
		then
			mkdir -p ${OUTPUT_FOLDER}/${CRITERIA}
		fi
	
		cd ${OUTPUT_FOLDER}/${CRITERIA}
	
		tar -xvpf ~/"${CRITERIA}.tar" &>/dev/null

		echo "[INFO] Test results held in ${OUTPUT_FOLDER}/${CRITERIA}"
	fi
}

function removePackagesFromDevice(){

	APP_ID="`GetAppId ${TEST_ENVIRONMENT}`"

	echo -n "[INFO] Removing existing app ${APP_ID} from PDA device..."

	adb uninstall "${APP_ID}" >/dev/null 2>/dev/null
	adb uninstall "io.selendroid.${APP_ID}" >/dev/null 2>/dev/null

	echo

	echo "[INFO] ${APP_ID} removed from PDA device."
}

function pointToEnvironment(){

	ENV="${1}"
	APK="${ROYALMAIL_PROJECT_FOLDER}/`GetApkLocation ${ENV}`"

	echo "[INFO] Apk location is ${APK}"

	# set environment within main royalmail.properties file so that
	# Java process can use it ...

	setEnvironmentInMainProperties "${ENV}"
}


function runTests(){

	if [ "${RUN_AGAINST_PHYSICAL_DEVICE}" = "true" ]
	then
		removePackagesFromDevice

		runtests.sh -apk "${APK}" --run-against-physical-device ${RUN_SELENDROID} -cucumber-options "--tags @${CRITERIA}"
	else
		runtests.sh -apk "${APK}" -run-emulator "`GetDeviceEmulator`" ${RUN_SELENDROID} -cucumber-options "--tags @${CRITERIA}"
	fi

	tidyReports
}

# Check arguments sent into this script
# and make sure they are valid ...

processArgs $*
checkArgs
pointToEnvironment "${TEST_ENVIRONMENT}"
prepareTestRun

# ... and finally run tests and produce a report ...
runTests
