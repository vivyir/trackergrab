#!/bin/bash

source ""$HOME"/trackergrab/trackergrab.conf"
curatedlist=""$HOME"/trackergrab/resource/curated.txt"
mkdir $modpath 2>/dev/null

if [ "$1" = "conf" ]; then

	if [ "$2" = "set" ]; then

		if [ "$3" = "gitname" ]; then

			sed -i "s/gitname=".*"/gitname=\"$4\"/g" ""$HOME"/trackergrab/trackergrab.conf"
			echo "gitname set to : "$4""

		elif [ "$3" = "targetrepo" ]; then

			sed -i "s/targetrepo=".*"/targetrepo=\"$4\"/g" ""$HOME"/trackergrab/trackergrab.conf"
			echo "target repo set to : "$4""

		elif [ "$3" = "branch" ]; then

			sed -i "s/branch=".*"/branch=\"$4\"/g" ""$HOME"/trackergrab/trackergrab.conf"
			echo "branch set to : "$4""

		elif [ "$3" = "modpath" ]; then

			sed -i "s/modpath=".*"/modpath=\"$4\"/g" ""$HOME"/trackergrab/trackergrab.conf"
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

		source ""$HOME"/trackergrab/trackergrab.conf"
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

elif [ "$1" = "re-source" ]; then

	source ""$HOME"/trackergrab/trackergrab.conf"
	echo "Sources were re-sourced"

elif [ "$1" = "search" ]; then

	grep "$2" "$curatedlist"

elif [ "$1" = "add" ];  then

	if [ "$2" = "local" ]; then

		pathToNewList="$3"

		echo "cat \"$pathToNewList\" >> \$curated" >> ""$HOME"/trackergrab/curator.sh"
		echo "\"cat \"$pathToNewList\" >> \$curated\" was added as a new script line to your curator.sh!"
		echo "Please enter \"$0 curate\" next to curate your personal list again"

	elif [ "$2" = "remote" ]; then
		
		remoteListName="$3"

		gitUrl="https://raw.githubusercontent.com/"$gitname"/"$targetrepo"/"$branch"/resource/"$remoteListName""
		echo "Downloading list "$remoteListName" from "$gitUrl" to "$HOME"/trackergrab/resource/$remoteListName"
		wget "$gitUrl" --quiet --show-progress --restrict-file-names=unix -P ""$HOME"/trackergrab/resource/"
		echo "Updating your curator.sh..."

		echo "cat \""$HOME"/trackergrab/resource/"$remoteListName"\" >> \$curated" >> ""$HOME"/trackergrab/curator.sh"

		echo "\"cat \""$HOME"/trackergrab/resource/"$remoteListName"\" >> \$curated\" was added as a new script line to your curator.sh!"

		echo "Please enter \"$0 curate \" next to curate your personal list again."

	else

		echo "There are only 2 modes available :"

		echo ""$0" add local /full/path/to/list"
		echo ""$0" add remote listname.txt"

	fi

elif [ "$1" = "curate" ]; then

	rm ""$HOME"/trackergrab/resource/curated.txt"
	""$HOME"/trackergrab/curator.sh"
	echo "Your list was curated!"

else
	echo "cringe"

fi
