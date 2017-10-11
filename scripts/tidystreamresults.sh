#!/bin/bash

# AUTHOR	: Des McCarter @ BJSS
# DATE		: 06/10/2017
# DESCRIPTION	: Creates a CSV form of royalmailresults/all-streams-results.txt


SEDFILE="${ROYALMAIL_PROJECT_FOLDER}/scripts/tidystreamresults.sed"
INFILE="${ROYALMAIL_PROJECT_FOLDER}/royalmailresults/all-streams-results.txt"

sed -n -f "${SEDFILE}" "${INFILE}"
