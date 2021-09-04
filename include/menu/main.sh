    # Main menu
    output=$(dialog --stdout --backtitle "Compare"\
 		--title "Main"$(echo "$output" | head -c 1 | tail -c 1)\
 		--menu ""\
 			20 20\
 			3\
 			1 "Type"\
 			2 "Data1"\
 			3 "Data2" 
		)
	if [ "$output" = "" ]; then
	 menuloop=0
	fi
	menupath="$output"
	
