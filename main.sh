#!/bin/bash
trackergrabPath="."

source ""$trackergrabPath"/trackergrab.conf"
curatedlist=""$trackergrabPath"/resource/curated.txt"
mkdir $modpath 2>/dev/null

_black="\e[0;30m"
_red="\e[0;31m"
_green="\e[0;32m"
_brown="\e[0;33m"
_blue="\e[0;34m"
_purple="\e[0;35m"
_yellow="\e[1;33m"
_cyan="\e[0;36m"
_white="\e[0;37m"
_lightblue="\e[1;34m"
_reset="\e[0m"

if [ "$1" = "conf" ]; then

	if [ "$2" = "set" ]; then

		if [ "$3" = "gitname" ]; then

			sed -i "s/gitname=".*"/gitname=\"$4\"/g" ""$trackergrabPath"/trackergrab.conf"
			echo -e ""$_blue"gitname"$_green" set to "$_reset": "$_red""$4""

		elif [ "$3" = "targetrepo" ]; then

			sed -i "s/targetrepo=".*"/targetrepo=\"$4\"/g" ""$trackergrabPath"/trackergrab.conf"
			echo -e ""$_blue"target repo"$_green" set to "$_reset": "$_red""$4""

		elif [ "$3" = "branch" ]; then

			sed -i "s/branch=".*"/branch=\"$4\"/g" ""$trackergrabPath"/trackergrab.conf"
			echo -e ""$_blue"branch"$_green" set to "$_reset": "$_red""$4""

		elif [ "$3" = "modpath" ]; then

			sed -i "s/modpath=".*"/modpath=\"$4\"/g" ""$trackergrabPath"/trackergrab.conf"
			echo -e ""$_blue"modpath"$_green" set to "$_reset": "$_red""$4""

		else
			echo -e ""$_green"Options "$_reset":"
			echo -e "git name : varname = "$_blue"gitname"$_reset", now "$_red"$gitname"$_reset""
			echo -e "target repository : varname = "$_blue"targetrepo"$_reset", now = "$_red"$targetrepo"$_reset""
			echo -e "branch : varname = "$_blue"branch"$_reset", now = "$_red"$branch"$_reset""
			echo -e "downloaded modules path : varname = "$_blue"modpath"$_reset", now = "$_red"$modpath"$_reset""
		fi

	elif [ "$2" = "show" ]; then
		
		echo -e ""$_blue"gitname"$_reset" : "$_red"$gitname"$_reset""
		echo -e ""$_blue"target repository"$_reset" : "$_red"$targetrepo"$_reset""
		echo -e ""$_blue"branch"$_reset" : "$_red"$branch"$_reset""
		echo -e ""$_blue"downloaded modules path"$_reset" : "$_red"$modpath"$_reset""

	else

		source ""$trackergrabPath"/trackergrab.conf"
		echo -e ""$_green"Config refreshed!"

	fi

elif [ "$1" = "grab" ]; then

	chosen=$(grep "$2" "$curatedlist" | cut -d';' -f2)

	chosen_filename=$(grep "$2" "$curatedlist" | cut -d';' -f1)

	if [ "$chosen" = "" ]; then

		echo -e ""$_red"The chosen module ($2) either doesn't exist or is not currently in your curated list."
		exit 1;

	fi

	modurl="https://api.modarchive.org/downloads.php?moduleid="$chosen""

	# printf '%q\n' "$chosen_filename"

	echo -ne "$_yellow"
	wget "$modurl" --quiet --show-progress --restrict-file-names=unix -O ""$modpath"/"$chosen_filename""
	echo -ne "$_reset"

elif [ "$1" = "id-grab" ]; then

	modurl="https://api.modarchive.org/downloads.php?moduleid="$2""
	modname=$(curl -s "https://modarchive.org/index.php?request=view_by_moduleid&query="$2"" | head -n140 | tail -n1 | awk -F '">' '{print $2}' | awk -F '</span></h1>' '{print $1}' | sed s/\(// | sed s/\)//)

	if [ "$modname" == "" ]; then
		echo -e ""$_red"No module by the ID '$2' found."
		exit 1
	fi

	echo -ne "$_yellow"
	wget "$modurl" --quiet --show-progress --restrict-file-names=unix -O ""$modpath"/"$modname""
	echo -ne "$_reset"

elif [ "$1" = "random" ]; then

	if [ "$2" == "clean" ]; then

		rm -r /tmp/randmods 2>/dev/null
		echo -e ""$_green"Cleaned random modules."
		exit 0

	fi

	mkdir /tmp/randmods 2>/dev/null

	if [ "$MODULE" == "" ]; then
		module=$(shuf -i 1-"$newestmod" -n1)
	else
		module="$MODULE"
	fi

	wpage=$(curl -s "https://modarchive.org/index.php?request=view_by_moduleid&query="$module"")
	modstat=$(echo -n "$wpage" | head -n184 | tail -n1)

	if [ "$modstat" == "" ]; then
		echo -e ""$_yellow"No module by the ID '$module' found, regenerating..."

		if [ "$TESTS" == "1" ]; then
			exit 0
		fi

		exec "$0" "$1" 
	fi

	modspot=$(echo -n "$wpage" | head -n170 | tail -n1)

	nameline=178
	spotlit="No"
	if [ "$modspot" != "" ]; then
		let "nameline = nameline + 6"
		spotlit="Yes"
	fi

	modname=$(echo -n "$wpage" | head -n"$nameline" | tail -n1 | cut -d'#' -f2 | awk -F '">' '{print $1}')


	echo -e ""$_green"Module filename "$_reset": "$_lightblue""$modname""
	echo -e ""$_green"Module ID "$_reset": "$_lightblue""$module""
	echo -e ""$_green"Spotlit "$_reset": "$_lightblue""$spotlit""
	echo -e ""$_green"Saved in "$_reset": "$_lightblue"/tmp/randmods/"$modname""$_reset""

	if [ "$TESTS" == "1" ]; then
		exit 0
	fi

	echo -ne "$_yellow"
	modurl="https://api.modarchive.org/downloads.php?moduleid="$module""
	wget "$modurl" --quiet --show-progress --restrict-file-names=unix -O "/tmp/randmods/"$modname""
	echo -ne "$_reset"

	openmpt123 $openmptOpts /tmp/randmods/"$modname"

elif [ "$1" = "near-fname-grab" ]; then

	wpage=$(curl -s "https://modarchive.org/index.php?request=search&query="$2"&submit=Find&search_type=filename")

	statline=151
	stat=$(echo -n "$wpage" | head -n"$statline" | tail -n1)

	if [ "$stat" == "" ]; then
		let "modline = statline + 18"
	elif [ "$stat" == "<h1>Module Search</h1>" ]; then
		echo -e ""$_red"No module by the name '$2' found, exiting..."
		exit 1
	else
		let "modline = statline + 7"
	fi

	modid=$(echo -n "$wpage" | head -n"$modline" | tail -n1 | awk -F '&amp;query=' '{print $2}' | awk -F '" title' '{print $1}')

	exec "$0" "id-grab" "$modid"

elif [ "$1" = "re-source" ]; then

	source ""$trackergrabPath"/trackergrab.conf"
	echo -e ""$_green"Sources were re-sourced"

elif [ "$1" = "search" ]; then

	grep "$2" "$curatedlist"

elif [ "$1" = "add" ];  then

	if [ "$2" = "local" ]; then

		pathToNewList="$3"

		echo "cat \"$pathToNewList\" >> \$curated" >> ""$trackergrabPath"/curator.sh"
		echo -e ""$_lightblue"\"cat \"$pathToNewList\" >> \$curated\""$_reset""$_green" was added as a new script line to your curator.sh!"
		echo -e ""$_yellow"Please enter \"$0 curate\" next to curate your personal list again"

	elif [ "$2" = "remote" ]; then
		
		remoteListName="$3"

		gitUrl="https://raw.githubusercontent.com/"$gitname"/"$targetrepo"/"$branch"/resource/"$remoteListName""
		echo -e ""$_green"Downloading list "$_yellow""$remoteListName""$_green" from "$_yellow""$gitUrl""$_green" to "$_yellow""$trackergrabPath"/resource/$remoteListName"$_reset""

		echo -ne "$_yellow"
		wget "$gitUrl" --quiet --show-progress --restrict-file-names=unix -P ""$trackergrabPath"/resource/"
		echo -ne "$_reset"

		echo -e ""$_green"Updating your curator.sh..."$_reset""

		echo "cat \""$trackergrabPath"/resource/"$remoteListName"\" >> \$curated" >> ""$trackergrabPath"/curator.sh"

		echo -e ""$_lightblue"\"cat \""$trackergrabPath"/resource/"$remoteListName"\" >> \$curated\""$_reset""$_green" was added as a new script line to your curator.sh!"
		echo -e ""$_yellow"Please enter \"$0 curate \" next to curate your personal list again."

	else

		echo -e ""$_green"There are only 2 modes available "$_reset":"

		echo -e ""$_yellow""$0" "$_red"add local "$_lightblue"/full/path/to/list"
		echo -e ""$_yellow""$0" "$_red"add remote "$_lightblue"listname.txt"

	fi

elif [ "$1" = "curate" ]; then

	rm ""$trackergrabPath"/resource/curated.txt" 2>/dev/null
	""$trackergrabPath"/curator.sh"
	echo -e ""$_green"Your list was curated!"

else
	echo "cringe"
fi
