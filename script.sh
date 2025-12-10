# ======
# MACROS
# ======

# macro to print a line of equals
printSeparationLine() {
    local str="${1:=}"
    local num="${2:-80}"
    printf "%${num}s" "" | tr ' ' "$str"
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
    local title="${1:-}"
    local available_now
    available_now=$(getAvailableSpace)
    local saved=$((available_now - AVAILABLE_INITIAL))

    local sep
    sep=$(printSeparationLine '*' 80)

    local out=""
    out+="\n"
    out+="$sep\n"
    if [ -n "$title" ]; then
        out+="=> ${title}: Saved $(formatByteCount "$saved")\n"
    else
        out+="=> Saved $(formatByteCount "$saved")\n"
    fi
    out+="$sep\n"
    out+="\n"

    # print output atomically
    printf '%b' "$out"
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


# ======
# SCRIPT
# ======

# Display initial disk space stats

printDH "BEFORE CLEAN-UP:"
echo ""

# Clean-up

if [[ "$REMOVE_ANDROID" == 'true' ]]; then
	remove "Android library" /usr/local/lib/android &
fi

if [[ "$REMOVE_AZ" == 'true' ]]; then
	remove "Az" /opt/az /usr/share/az* &
fi

if [[ "$REMOVE_AWS_CLI" == 'true' ]]; then
	remove "AWS CLI" /usr/local/aws* &
fi

if [[ "$REMOVE_BROWSERS" == 'true' ]]; then
	remove "Browsers" \
		/opt/chrome \
		/opt/google/chrome \
		/usr/local/share/chromedriver* \
		/usr/local/share/chromium \
		/opt/microsoft/{edge,msedge} \
		/opt/msedge \
		/usr/local/share/edge_driver* \
		/usr/lib/firefox &
fi

if [[ "$REMOVE_GCC" == 'true' ]]; then
	remove "GCC" /usr/lib/gcc /usr/libexec/gcc &
fi

if [[ "$REMOVE_GOOGLE_CLOUD_SDK" == 'true' ]]; then
	remove "Google Cloud SDK" /usr/lib/google-cloud-sdk &
fi

if [[ "$REMOVE_DOCKER_IMAGES" == 'true' ]]; then {
	sudo docker image prune --all --force &>/dev/null || true
	printSavedSpace "Docker images"
}& fi


if [[ "$REMOVE_DOTNET" == 'true' ]]; then
	remove ".NET runtime" \
		/usr/share/dotnet \
		/usr/lib/dotnet \
		/home/{runner,runneradmin}/.dotnet \
		/etc/skel/.dotnet &
fi

if [[ "$REMOVE_JVM" == 'true' ]]; then
	remove "JVM runtime" \
		/usr/lib/jvm \
		/usr/share/gradle* \
		/usr/share/java* \
		/usr/share/kotlin* \
		/usr/share/sbt* \
		/root/.sbt \
		/usr/local/lib/lein &
fi

if [[ "$REMOVE_JULIA" == 'true' ]]; then
	remove "Julia runtime" /usr/local/julia* &
fi

if [[ "$REMOVE_HASKELL" == 'true' ]]; then
	remove "Haskell runtime" /opt/ghc /usr/local/.ghcup &
fi

if [[ "$REMOVE_HEROKU" == 'true' ]]; then
	remove "Heroku" /usr/lib/heroku &
fi

if [[ "$REMOVE_LLVM" == 'true' ]]; then
	remove "LLVM" \
		/usr/lib/llvm* \
		/usr/include/llvm* \
		/usr/lib/*-linux-gnu/libLLVM* \
		/usr/lib/*-linux-gnu/libclang* \
		/usr/lib/*-linux-gnu/liblldb* &
fi

if [[ "$REMOVE_MONO" == 'true' ]]; then
	remove "Mono runtime" /usr/lib/mono &
fi

if [[ "$REMOVE_MYSQL" == 'true' ]]; then {
	sudo systemctl stop mysql -q || true
	remove "MySQL" /var/lib/mysql/
}& fi

if [[ "$REMOVE_NODE" == 'true' ]]; then
	remove "Node runtime" \
		/usr/local/n \
		/usr/local/lib/node_modules \
		/usr/local/include/node &
fi

if [[ "$REMOVE_PYTHON" == 'true' ]]; then
	remove "Python runtime" /opt/pipx /usr/share/miniconda &
fi

if [[ "$REMOVE_POSTGRESQL" == 'true' ]]; then {
	sudo systemctl stop postgresql -q || true
	remove "PostgreSQL" /usr/lib/postgresql /var/lib/postgresql
}& fi

if [[ "$REMOVE_POWERSHELL" == 'true' ]]; then
	remove "Powershell runtime" /usr/local/share/powershell /opt/microsoft/powershell &
fi

if [[ "$REMOVE_RUBY" == 'true' ]]; then
	remove "Ruby runtime" \
		/usr/lib/ruby \
		/var/lib/gems \
		/home/linuxbrew/.linuxbrew \
		/usr/share/ri &
fi

if [[ "$REMOVE_RUST" == 'true' ]]; then
	remove "Rust runtime" \
		/home/{runner,runneradmin}/{.cargo,.rustup} \
		/etc/skel/{.cargo,.rustup} &
fi

if [[ "$REMOVE_SNAP" == 'true' ]]; then {
	sudo systemctl stop snapd.service -q || true
	sudo umount --recursive /snap/*/* -q || true
	remove "Snap" ~/snap /snap /var/snap /var/lib/snapd /usr/lib/snapd
}& fi

if [[ "$REMOVE_SWIFT" == 'true' ]]; then
	remove "Swift runtime" /usr/share/swift &
fi


if [[ "$REMOVE_TOOL_CACHE" == 'true' ]]; then
	remove "Tool cache" "$AGENT_TOOLSDIRECTORY"
fi

if [[ "$REMOVE_USRMISC" == 'true' ]]; then
	remove "/usr/src and /usr/{,local}/share/{man,doc,icons}" \
		/usr/src \
		/usr/share/{man,doc,icons} \
		/usr/local/{man,doc,icons} \
		/usr/local/share/{man,doc,icons} &
fi

if [[ "$REMOVE_USRLOCAL" == 'true' ]]; then
	remove "/usr/local" /usr/local &
fi

if [[ "$REMOVE_OPT" == 'true' ]]; then
	remove "/opt" /opt &
fi

if [[ "$REMOVE_VARCACHE" == 'true' ]]; then
	remove "/var/cache" /var/cache &
fi

# Wait until all background jobs finishes
# shellcheck disable=SC2046
wait $(jobs -rp)

# Output saved space statistic
echo ""
printDH "AFTER CLEAN-UP:"
echo ""

printSavedSpace
