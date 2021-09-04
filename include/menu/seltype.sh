    # Menu "Type"
    output=$(dialog --stdout --backtitle "Compare"\
 		--title "Select type"\
 		--menu ""\
 			20 20\
 			2\
 			1 "Compare"\
 			2 "Search"\
		)
	menupath=$(echo "$menupath" | head -c 1)"$output"
