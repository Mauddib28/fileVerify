#!/bin/bash

echo "Starting file verification test"

function checkExtension() {
	# Grabbing the name and contents of the passed extension array
	# This part works for performing array content grabbing through the use of indirect substitution
	arrayGrab=$2[@]
	if [ "$dbg" -eq "1" ]; then
		echo "Passed file: $1"
		echo "Passed extension array: $2"
		echo ${!arrayGrab}
	fi
	#filePass=0
	# Looping through the passed extension array for search for mismatches
	# TODO: Update this function to propertly look for two points - (1) Check that the file extension of the file matches a known file extension (NOTE: If NOT then kick back to file saying new file extension seen)
	#	(2) If the 'foundMatch' variable increase, THEN ensure that the 'file' return contains specific terms (e.g. text, pdf, executable)
	# NOTE: This may require the creation of secondary arrays, for a very detailed for loop
	for knownExtension in  "${!arrayGrab}"		# Iterate through all the extensions in the array
	do
		if [ "$dbg" -eq "1" ]; then
			echo "File extension being compared: $extension"
			echo "Extension being checked: $knownExtension"
			echo -e "\tFull Filename: $fullfile"
		fi
		# Does the actual file extension the same as any expected extensions
		extensionCheck=$(echo $extension | grep $knownExtension)		# Grep that checks that if the known extension is the same as a presented file extension
		# Note: The above check does NOT use the full filename because the file name could contain "extension strings"
		if [ "$dbg" -eq "1" ]; then
			echo "Testing extension grep:"
			echo -e "\t$extensionCheck"
			echo -e "\tExtension check: $extensionCheck"
		fi
		if [ "$extensionCheck" != "" ]; then		# This comparison works and returns correctly
			let foundMatch+=1
			if [ "$dbg" -eq "1" ]; then
				echo -e "\tPossible Extensions: ${testFileResponses[@]}"
			fi
			for keyword in "${testFileResponses[@]}"; do
				fileCheck=$(grep $keyword $testResponse)
				if [ "$dbg" -eq "1" ]; then
					echo -e "\tOutput from fileCheck:\t$fileCheck"
				fi
				if [ "$fileCheck" != "" ]; then
					let filePass+=1		# Works to add to this counter if conditions are met
				else
					# Do NOTHING
					if [ "$dbg" -eq "1" ]; then
						echo "No match of keyword in 'file' return"
					fi
				fi
			done
		else
			if [ "$dbg" -eq "1" ]; then
				# Maybe this works in Ubuntu and not in Arch?
				echo "Fuck I don't understand string comparison"
			fi
		fi
	done
}

echo "Setting up script variable defaults"
searchDir="."
dbg=0			# Debug bit
declare -a textfile_extensions=('txt' 'md' 'text');	# Note: Currently works because 'text' is in the 'file' response.  Should be (1) what group is extension in, (2) what keyword(s) does that belong to, (3) does the 'file' return contain that pair
declare -a pdf_extensions=('pdf');
declare -a image_extensions=('png' 'jpeg');
declare -a audio_extensions=('wav' 'mp3');
declare -a video_extensions=('mp4');
declare -a script_extensions=('exe' 'sh' 'py');
# Create array of arrays in bash? May not be possible at all | Can not do via names of arrays, but can build from array contents
declare -a extensionArray=(textfile_extensions pdf_extensions)
#declare -a extensionArray=("${textfile_extensions[@]}" "${pdf_extensions[@]}")
# Creating an array of keywords for 'file' command matching
declare -a testFileResponses=('text' 'executable');

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
	file $fullfile > $testResponse	# This is the 'file' command response for the given file
	foundMatch=0
	filePass=0
	# TODO: This check should rotate depending on the file extension of the original file
	#	Steps:
	#		1) Check to see if the file extension exists inside of any of the extension arrays
	#		2) Return the extension(s) arrays that contain the extension
	#		3) Call function to perform check for extension match
	#		4) Aggregate the match counts
	#		5) Examine the total count to see if a mismatching file was found
	# Checking for textfile extension to match
	# For loop for passing each declared array
	# NOTE: Currently ONLY does LARGE SCALE check of knowledge
	#	TODO: Add in single file level examination of data
	for arraySet in "${extensionArray[@]}"
	do
		if [ "$dbg" -eq "1" ]; then
			echo "Array to examine: $arraySet"
		fi
		checkExtension $fullfile $arraySet
	done
	# Check to see if any of the extensions had a match
	echo -e "\tMatches found: $foundMatch"
	# Final check to see if a mismatch was found
	echo -e "\tValue of filePass: $filePass"
	if [ "$filePass" -eq "0" ]; then
		echo -e "Warning!! Mismatch found:\t$fullfile"
	fi
done

# Clean-up
rm $testResponse
