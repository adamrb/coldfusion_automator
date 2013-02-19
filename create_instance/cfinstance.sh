#!/bin/bash

# Creates ColdFusion9 server instances automatically
# You must have rhino (https://developer.mozilla.org/en-US/docs/Rhino) installed on the originating computer to use it.  It should be in your repos. 
#
# Run by manually editing the variables below or using "-i instancename" & "-s servername" (can be repeated as many times as necessary, eg: "-i instance1 -i instance2")
#
# Name of the instances you want to create (space delimited)
#instances="instance1 instance2"

# Hostnames of the servers to create instances on (space delimited)
#servers="server1 server2"

while getopts "i:s:" Option
do
  case $Option in
    i|I ) # Instance Name
        instances="$OPTARG $instances"
        ;;
    s|S ) # Instance Name
        servers="$OPTARG $servers"
        ;;
    * )
        echo "I don't have anything implemented for \"-$Option\".\n"
        ;;
  esac
done
shift $(($OPTIND - 1))

echo "Instances: $instances"
echo "Servers: $servers"

# Verify we have rhino installed
if [ "$(which rhino)" == "" ]; then
	echo "Rhino must be installed to run this script. Exiting."
	exit 1
fi

# Check for missing instances
if [ "$instances" == "" ]; then
        echo "No instances defined. Exiting"
        exit 1
fi

# Check for missing servers
if [ "$servers" == "" ]; then
        echo "No servers defined. Exiting"
        exit 1
fi

# Loop through the servers
for server in $servers; do
	cookiefile="/tmp/curl-cookies-${server}.txt"
	curl_cmd="/usr/bin/curl -b $cookiefile -c $cookiefile -H \"HOST: $server\" -s"
	cfadmin="http://${server}:8300/CFIDE/administrator"

	# We don't want cookie crumbs
	rm -f $cookiefile
	touch $cookiefile

	# Get Salt from Login Page
	salt=$(${curl_cmd} "${cfadmin}/" | sed -n 's/.*<input name="salt" type="hidden" value="\(.*\)">.*/\1/p')
	[ "$salt" == "" ] && echo "Unable to get a password salt from the login page $cfadmin.  Exiting" && exit 2

	# Hash the Password
	pass_hash=$(rhino cfpassgen.js $salt $password)
	[ "$pass_hash" == "" ] && echo "Unable to generate a sha1 hash.  Exiting" && exit 2

	# Log into the admin page
	echo -n "Logging in..."
	$curl_cmd --referer "$cfadmin/" -d "cfadminPassword=${pass_hash}&requestedURL=%2FCFIDE%2Fadministrator%2Fenter.cfm%3F&salt=${salt}&submit=Login" "${cfadmin}/enter.cfm" > /dev/null
	echo "done."

	# Loop through the instances we want to create
	for instance in $instances; do
		echo "[step 1 of 4] creating new instance $instance on $server."
		$curl_cmd -d "serverName=$instance&directory=/opt/jrun4/servers/$instance&archive_location=&addsubmit=Submit" "${cfadmin}/entman/processaddserver.cfm" | egrep --line-buffered --color=never -o -e "\[step.*\." -e "New CF Instance started\!"
		sleep 1
		echo
	done

	# Cleanup after ourselves
	rm -f $cookiefile
done
