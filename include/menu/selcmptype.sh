# Selected $menupath = 11
    output=$(dialog --stdout --backtitle "Compare"\
 		--title "Compare type"\
		--radiolist "t"\
 			20 27\
 			6\
 			11 "Data1 >  Data2" $(if [ "$cmptype" = "11" ]; then echo ON; else echo OFF; fi)\
 			12 "Data1 => Data2" $(if [ "$cmptype" = "12" ]; then echo ON; else echo OFF; fi)\
 			13 "Data1 =  Data2" $(if [ "$cmptype" = "13" ]; then echo ON; else echo OFF; fi)\
 			14 "Data1 <= Data2" $(if [ "$cmptype" = "14" ]; then echo ON; else echo OFF; fi)\
 			15 "Data1 <  Data2" $(if [ "$cmptype" = "15" ]; then echo ON; else echo OFF; fi)\
 			16 "Data1 != Data2" $(if [ "$cmptype" = "16" ]; then echo ON; else echo OFF; fi)\
		)
    menupath=$(echo "$menupath" | head -c ${#output}-1)
    type=$output

