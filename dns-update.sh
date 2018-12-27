#!/bin/bash
#
# Dynamic DNS record updater script
# for Hurricane Electric Free DNS service (https://dns.he.net/).
#
# (c) Peter Budai, 2018
# https://peterbudai.eu/
#

# Global variables
# Full path to the executing script file
script_file=""
# Whether to display log messages to stderr as well
verbose=0

# Log message to syslog and, optionally, to stderr
log() {
	local severity="$1"
	shift
	if [[ $verbose ]]; then
		echo "$@" >&2
	fi
	logger -t "$(basename "$script_file" .sh)" -p "user.$severity" "$@"
}

# Read configuration file
read_config() {
	# Determine config file location
	# It should be next to this script, using the same name with .conf extension
	local config_file="$(dirname "$script_file")/$(basename "$script_file" .sh).conf"

	# Read config file
	if [[ ! -r "$config_file" ]]; then
		log err "Can't read config file: $config_file"
		exit 2
	fi
	# Skip empty, whitespace-only, and commented lines,
	# process only valid-looking lines and return the three relevant fields
	awk '/^\s*(4|6)\s+(\w|\.|-)+\s+[^#[:space:]]\S*\s*(#.*)?$/{print $1,$2,$3}' "$config_file"
}

# Update a dynamic DNS entry of a single host
update_host() {
	# Call DNS entry update endpoint and store result
	local result
	result=$(curl -$1 -s -m 5 "https://dyn.dns.he.net/nic/update" -d "hostname=$2" -d "password=$3")
	local code=$?

	# Log result of the operation
	local severity
	case $code in
	0)
		severity=info
		;;
	7)
		result="can't connect"
		severity=notice
		;;
	28)
		result="timed out"
		severity=notice
		;;
	*)
		if [[ -z $result ]]; then
			result="error"
		fi
		severity=err
		;;
	esac
	log $severity "Updating IPv$1 address of host $2: $result ($code)"
}

# Parse arguments and run DNS update
main() {
	# Obtain script name
	# Using readlink as per https://gist.github.com/tvlooy/cbfbdb111a4ebad8b93e
	script_file="$(readlink -f "$0" 2>/dev/null)"

	# Parse arguments
	while [[ $# -gt 0 ]]; do
		case $1 in
		-v|--verbose)
			verbose=1
			;;
		*)
			echo "Usage: $(basename "$script_file") [-v|--verbose|-h|--help]" >&2
			echo "For more information, visit https://github.com/peterbudai/he-dns-update" >&2
			exit 1
			;;
		esac
		shift
	done

	# Update dynamic DNS records for all config file entries
	read_config | while read -r cfg_proto cfg_host cfg_pass; do
		update_host "$cfg_proto" "$cfg_host" "$cfg_pass"
	done
}

# Script entry point
main "$@"
