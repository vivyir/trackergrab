#!/bin/bash

echo "Running tests..."
echo ""
nominatedRes=$(MODULE=158263 TESTS=1 ./main.sh random | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
invalidModule=$(MODULE=30638 TESTS=1 ./main.sh random | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
normalModule=$(MODULE=99356 TESTS=1 ./main.sh random | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")

nomResSpotlight=$(echo -n "$nominatedRes" | grep "Spotlit" --color=no | cut -d' ' -f3)
nomResFilename=$(echo -n "$nominatedRes" | grep "filename" --color=no | cut -d' ' -f4)

if [ "$nomResSpotlight" == "Yes" ] && [ "$nomResFilename" == "blz_-_october.xm" ]; then
	echo "Spotlight test passed : "
	echo "	Spotlit? = "$nomResSpotlight""
	echo "	blz_-_october.xm? = "$nomResFilename""
else
	echo "Spotlight test failed!"
fi

echo ""

if [ "$invalidModule" == "No module by the ID '30638' found, regenerating..." ]; then
	echo "Invalid module test passed : "
	echo "	No module by the ID '30638' found, regenerating... == "$invalidModule""
else
	echo "Invalid module test failed!"
	echo "	No module by the ID '30638' found, regenerating... != "$invalidModule""
fi

echo ""

norModSpotlight=$(echo -n "$normalModule" | grep "Spotlit" --color=no | cut -d' ' -f3)
norModFilename=$(echo -n "$normalModule" | grep "filename" --color=no | cut -d' ' -f4)

if [ "$norModSpotlight" == "No" ] && [ "$norModFilename" == "emerszuzia.mod" ]; then
	echo "Normal module test passed : "
	echo "	Spotlit? = "$norModSpotlight""
	echo "	emerszuzia.mod? = "$norModFilename""
else
	echo "Normal module test failed!"
fi
