# Selected $menupath = 12
    output=$(dialog --stdout --backtitle "Compare"\
 		--title "Search type"\
		--radiolist "t"\
 			20 27\
 			5\
 			21 "Value" $(if [ "$cmptype" = "21" ]; then echo ON; else echo OFF; fi)\
 			22 "Not changed" $(if [ "$cmptype" = "22" ]; then echo ON; else echo OFF; fi)\
 			23 "Changed uncknown" $(if [ "$cmptype" = "23" ]; then echo ON; else echo OFF; fi)\
 			24 "Changed up" $(if [ "$cmptype" = "24" ]; then echo ON; else echo OFF; fi)\
 			25 "Changed down" $(if [ "$cmptype" = "25" ]; then echo ON; else echo OFF; fi)\
		)
    menupath=$(echo "$menupath" | head -c ${#output}-1)
    type=$output
