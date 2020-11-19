#/bin/bash

main=$(grep -o "?moduleid=.*" ./artistScrape.txt | sed "s/\#/\;/g" | grep -o "[^?moduleid=].*")

mainID=$(echo $main | sed 's/\s\+/\n/g' | grep -o "^[0-9]*")
mainName=$(echo $main | sed 's/\s\+/\n/g' | grep -o "\;.*" | grep -o "[^\;]*")

echo $mainID | sed 's/\s\+/\n/g' > ./cache1.txt
echo $mainName | sed 's/\s\+/\n/g' > ./cache2.txt

#paste -d ';' ./cache2.txt ./cache1.txt

while IFS=$';' read -r f1 f2
do
	printf '%s' "$f1"
	printf '%s\n' "$f2"
done < <(paste ./cache2.txt ./cache1.txt)
