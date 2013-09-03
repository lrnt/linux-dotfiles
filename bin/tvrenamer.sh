#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # #
#												#
# Script written by Wes G						#
# http://www.wesg.ca							#
#												#
# # # # # # # # # # # # # # # # # # # # # # # # #

# read show name
SHOW=$1

if [ ! -n "$SHOW" ]; then
	echo "No show was entered."
	exit
fi

# google result
SHOW=$(echo $SHOW | sed -e 's/ /\+/g')
echo "Downloading show data for '$1'..."
url=$(echo "http://services.tvrage.com/feeds/search.php?show=$SHOW")
google=$(wget -U firefox -qO - "$url" )
number=$(echo $google | awk -F '</showid>' ' { print $1 } ' | awk -F '>' ' { print $NF } ')

# tv.com url
echo "Downloading episode guide..."
tv=$(echo "http://services.tvrage.com/feeds/episode_list.php?sid=$number")

# tv.com page data
guide=$(wget -U firefox -qO - "$tv")

# read files in folder
files=$(find . -maxdepth 1 | sort)

find . -print0 | sort | while read -d $'\0' file
do
	# check the file has been renamed yet
  	complete=$( expr length "$file")
  	if [[ $complete == 12 ]]; then
  		
		# find season and episode
		season=$(echo "$file" | awk -F '' '{print $4$5}' | sed 's/^0//')
		episode=$(echo "$file" | awk -F '' '{print $7$8}')
		search=$(echo ""$season", Episode "$episode)
		# Nest the season searches
		snum=$(echo "<Season no=\"$season\">")
		title=$(echo "$guide" | xmlstarlet sel -t -v "/Show/Episodelist/Season[@no='$season']/episode[$episode]/title")
		
		# find the episode title
  		 		
  		if [ -n "$title" ]; then
  			ext=$(echo $file | awk -F '.' '{ print $NF }')
  			rename=$(echo $file | egrep -o -e "/([^.]+)")
			rename=$(echo "./""$1"" - "$rename" - "$title".$ext")  
			original=$(echo $file | awk -F '.' '{print $2"."$3}' | awk -F '/' '{print $2}')
			rename=$(echo $rename | awk -F '/' '{print $2$3}')
			echo "Renaming $original to $rename"
 			mv "$file" "`echo "./"$rename`"
  		else
  			echo "No title info found"
  		fi
  	fi
done