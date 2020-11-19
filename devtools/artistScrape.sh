#!/bin/bash

cd ./artistScrape
rm *.txt
python3 ./artistScrape.py $1
./artistScrape.sh > final.txt
cat final.txt | sed 's/\s\+/;/g' > ../"$2".txt
