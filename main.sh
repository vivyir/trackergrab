#!/bin/bash

source "./trackergrab.conf"
curatedlist="./resource/curated.txt"
mkdir $modpath 2>/dev/null

if [ "$1" = "conf" ]; then

	if [ "$2" = "set" ]; then

		if [ "$3" = "gitname" ]; then

			sed -i "s/gitname=".*"/gitname=\"$4\"/g" "./trackergrab.conf"
			echo "gitname set to : "$4""

		elif [ "$3" = "targetrepo" ]; then

			sed -i "s/targetrepo=".*"/targetrepo=\"$4\"/g" "./trackergrab.conf"
			echo "target repo set to : "$4""

		elif [ "$3" = "branch" ]; then

			sed -i "s/branch=".*"/branch=\"$4\"/g" "./trackergrab.conf"
			echo "branch set to : "$4""

		elif [ "$3" = "modpath" ]; then

			sed -i "s/modpath=".*"/modpath=\"$4\"/g" "./trackergrab.conf"
			echo "modpath set to : "$4""

		else
			echo "Options :"
			echo "git name : varname = gitname, now $gitname"
			echo "target repository : varname = targetrepo, now = $targetrepo"
			echo "branch : varname = branch, now = $branch"
			echo "downloaded modules path : varname = modpath, now = $modpath"
		fi

	elif [ "$2" = "show" ]; then
		
		echo "gitname : $gitname"
		echo "target repository : $targetrepo"
		echo "branch : $branch"
		echo "downloaded modules path : $modpath"

	else

		source "./trackergrab.conf"
		echo "Config refreshed"

	fi

elif [ "$1" = "grab" ]; then

	chosen=$(grep "$2" "$curatedlist" | cut -d';' -f2)

	chosen_filename=$(grep "$2" "$curatedlist" | cut -d';' -f1)

	if [ "$chosen" = "" ]; then

		echo "The chosen module($2) either doesn't exist or is not currently in your curated list."
		exit 1;

	fi

	modurl="https://api.modarchive.org/downloads.php?moduleid="$chosen""

	# printf '%q\n' "$chosen_filename"

	wget "$modurl" --quiet --show-progress --restrict-file-names=unix -O ""$modpath"/"$chosen_filename""

elif [ "$1" = "id-grab" ]; then

	modurl="https://api.modarchive.org/downloads.php?moduleid="$1""
	wget "$modurl" --quiet --show-progress --restrict-file-names=unix -O ""$modpath"/"$2""

elif [ "$1" = "random" ]; then

	if [ "$2" == "clean" ]; then

		rm -r /tmp/randmods
		echo "Cleaned random modules."
		exit 0

	fi

	mkdir /tmp/randmods 2>/dev/null

	module=$(shuf -i 1-"$newestmod" -n1)
	modname=$(curl -s "https://modarchive.org/index.php?request=view_by_moduleid&query="$module"" | head -n141 | tail -n1 | awk -F '">' '{print $2}' | awk -F '</span></h1>' '{print $1}' | sed s/\(// | sed s/\)//)

	if [ "$modname" == "" ]; then
		echo "Something went wrong, rerun."
		exit 1
	fi

	echo "Module filename : "$modname""
	echo "Module ID : "$module""
	echo "Saved in : /tmp/randmods/"$modname""

	modurl="https://api.modarchive.org/downloads.php?moduleid="$module""
	wget "$modurl" --quiet --show-progress --restrict-file-names=unix -O "/tmp/randmods/"$modname""
	openmpt123 $openmptOpts /tmp/randmods/"$modname"

elif [ "$1" = "re-source" ]; then

	source "./trackergrab.conf"
	echo "Sources were re-sourced"

elif [ "$1" = "search" ]; then

	grep "$2" "$curatedlist"

elif [ "$1" = "add" ];  then

	if [ "$2" = "local" ]; then

		pathToNewList="$3"

		echo "cat \"$pathToNewList\" >> \$curated" >> "./curator.sh"
		echo "\"cat \"$pathToNewList\" >> \$curated\" was added as a new script line to your curator.sh!"
		echo "Please enter \"$0 curate\" next to curate your personal list again"

	elif [ "$2" = "remote" ]; then
		
		remoteListName="$3"

		gitUrl="https://raw.githubusercontent.com/"$gitname"/"$targetrepo"/"$branch"/resource/"$remoteListName""
		echo "Downloading list "$remoteListName" from "$gitUrl" to ./resource/$remoteListName"
		wget "$gitUrl" --quiet --show-progress --restrict-file-names=unix -P "./resource/"
		echo "Updating your curator.sh..."

		echo "cat \"./resource/"$remoteListName"\" >> \$curated" >> "./curator.sh"

		echo "\"cat \"./resource/"$remoteListName"\" >> \$curated\" was added as a new script line to your curator.sh!"

		echo "Please enter \"$0 curate \" next to curate your personal list again."

	else

		echo "There are only 2 modes available :"

		echo ""$0" add local /full/path/to/list"
		echo ""$0" add remote listname.txt"

	fi

elif [ "$1" = "curate" ]; then

	rm "./resource/curated.txt" 2>/dev/null
	"./curator.sh"
	echo "Your list was curated!"

else
	echo "cringe"

fi
