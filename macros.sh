# ======
# MACROS
# ======

# macro to print a line of equals
# (silly but works)
printSeparationLine() {
	str=${1:=}
	num=${2:-80}
	counter=1
	output=""
	while [ $counter -le "$num" ]
	do
		output="${output}${str}"
		counter=$((counter+1))
	done
	echo "${output}"
}

# macro to compute available space
# REF: https://unix.stackexchange.com/a/42049/60849
# REF: https://stackoverflow.com/a/450821/408734
getAvailableSpace() { df -a | awk 'NR > 1 {avail+=$4} END {print avail}'; }
AVAILABLE_INITIAL=$(getAvailableSpace)
readonly AVAILABLE_INITIAL

# macro to make Kb human readable (assume the input is Kb)
# REF: https://unix.stackexchange.com/a/44087/60849
formatByteCount() { numfmt --to=iec-i --suffix=B --padding=7 "$1"'000'; }

# macro to output saved space
printSavedSpace() {
	title=${1:-}

	AVAILABLE_NOW=$(getAvailableSpace)
	SAVED=$((AVAILABLE_NOW-AVAILABLE_INITIAL))

	echo ""
	printSeparationLine '*' 80
	if [ -n "${title}" ]; then
		echo "=> ${title}: Saved $(formatByteCount "$SAVED")"
	else
		echo "=> Saved $(formatByteCount "$SAVED")"
	fi
	printSeparationLine '*' 80
	echo ""
}

# macro to print output of dh with caption
printDH() {
	caption=${1:-}

	printSeparationLine '=' 80
	echo "${caption}"
	echo ''

	echo '$ dh -ha'
	df -ha
	echo ''

	echo '$ free -h'
	free -h
	echo ''

	# this is slow, this is why it is not enabled by default
	if [[ "$DEBUG" == 'true' ]]; then
		echo '$ du -h /* 2>/dev/null | sort -hr | head -n 100'
		# https://unix.stackexchange.com/a/355164
		sudo perl -e \
			'$SIG{PIPE}="DEFAULT"; exec "@ARGV"' \
			'du -h /* 2>/dev/null | sort -hr | head -n 100' || true

		echo ''
	fi
	printSeparationLine '=' 80
}

remove() {
	# shellcheck disable=SC2068
	sudo rm -rf ${@:2} || true
	printSavedSpace "$1"
}
