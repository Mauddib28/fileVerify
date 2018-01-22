#!/bin/bash

echo "Starting file verification test"

echo "Setting up script variable defaults"
searchDir="."
dbg=0			# Debug bit
declare -a textfile_extensions=('txt' 'md' 'text');
declare -a pdf_extensions=('pdf');
declare -a image_extensions=('png' 'jpeg');
declare -a audio_extensions=('wav' 'mp3');
declare -a video_extensions=('mp4');
declare -a script_extensions=('exe' 'sh' 'py');
# Create array of arrays in bash? May not be possible at all
declare -a extensionArray=(testfile_extensions pdf_extensions)

echo "Searching for all files in the current directory"
if [ $# -eq 0 ]; then		# No arguemnts suppled
	echo "No arguments supplied"
else
	searchDir="$1"
fi

echo "Directory to search is $searchDir"

fullfile=""
extension=""
filename=""
testResponse="./testFile.output"
for entry in "$searchDir"/*; do
	echo "Examining... $entry"
	# Pull out the file extension and filename information | Note: TURN INTO A FUNCTION
	fullfile=$(basename "$entry")
	extension="${fullfile##*.}"	# Grabs the final writing after the last '.' character | Note: Need to test on file with no extension
	filename="${fullfile%.*}"	# Grabs the writing right before the last '.' character
	if [ "$dbg" -eq "1" ]; then
		echo "Fullfile: $fullfile"
		echo "Extension: $extension"
		echo "Filename: $filename"
	fi
	file $fullfile > $testResponse
	foundMatch=0
	for extension in  "${textfile_extensions[@]}"		# Iterate through all the extensions in the array
	do
		grepTest=$(grep $extension $testResponse)	# Test if grep sees the respective word in the grep return
		echo "GrepTest return: $grepTest"
		if [ "$grepTest" == "" ]; then
			if [ "$dgb" -eq "1" ]; then
				echo "No Match!"
			else
				let foundMatch+=1
			fi
		fi
	done
	# Check to see if any of the extensions had a match
	echo "Matches found: $foundMatch"
	# NOTE: Code should alert the user if a file extension does NOT match any of the expected file types
	# Order:
	#	-> 1) Check to see what the file extension is
	#	-> 2) Based on the extension, look (e.g. use grep) to check for a specific text string in the 'file' response for that item
	#	-> 3) If NONE of the strings return a positive 'found match' response, then alert the user for the potential IMPOSTER file
	# Update the code to extend the difference file extensiosn and 'file' responses that allow for legitimate files
done

# Clean-up
rm $testResponse
