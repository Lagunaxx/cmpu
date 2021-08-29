#!/bin/bash

###################################################################
#
# Filename: compare.sh
# Version: 1.0
# Author: Novoselov Vitaliy A. (Russia, Krasnodar)
#
# Description:
#  Script makes comparison of two objects. Was made to search changes/not chenged in datasets
#  (mostly for memory dumps (gamehack)). Bat may be used in other datasets.
#  To use it first of all you need to create database with 'compare.sh new' command. Next you
#  need to add some data with 'compare.sh add' command. After this you can compare datasets with
#  'compare.sh cmp' command.
#
###################################################################


source sqlite.sh
source textbin.sh

DIFF_CMD="diff"
DIFF_PARAM="--changed-group-format='%>' --unchanged-group-format=''"
DBASEPATH="."
DBASENAME="default.db"
DBASE="$DBASEPATH/$DBASENAME"
LOG="yes" # yes = make log, no = do not make log !ToDo!

COMMAND=$1

if [ "$COMMAND" = "new" ]; then
 # Create new database
 if [ -f "$DBASEPATH/$DBASE" ]; then
  #ToDo: make backup
  rm $DBASE
 fi
 sqliteCreate $DBASE

elif [ "$COMMAND" = "ttt" ]; then
 echo "TESTING option..."
# encode dataset sqlite3 "$DBASE"  "SELECT quote(dataset) FROM Datasets WHERE id=22"
# echo ${$(sqlite3 "$DBASE"  "SELECT quote(dataset) FROM Datasets WHERE id=22")#*/'}
# ddd=$(sqlite3 "$DBASE"  "SELECT quote(dataset) FROM Datasets WHERE id=22")
# echo "$ddd"
# ddd=${ddd#*\'}
# ddd=${ddd%\'*}

 sqliteGetDataset "$DBASE" ddd "22"
 echo "$ddd"
 #encode dataset cat ./ttt.ttt #&&
#  decode "$var" | cmp - ./ttt.ttt && echo OK
 echo "Hex:$dataset"
# sqliteAddDataset "$DBASE" "$dataset"

 echo "Exiting"
 exit 0
elif [ "$COMMAND" = "add" ]; then 
 # Add file/folder to check
 if [[ "$2" = "-f" ]]; then
  sqliteAddFile "$DBASE" "$3" returnVal
# ToDo: add logging into functions;  sqliteAddData "$DBASE" ...
# ToDo: make able to switch logging off
  #ToDo add record to log with data logging
sqliteGetDataTypeID "$DBASE" DataTypeID "File"
sqliteAddData "$DBASE" "$DataTypeID" "$returnVal" returnDataID
  #ToDo add Data  adding to sqlite.sh

 elif [[ "$2" = "-d" ]]; then
  sqliteAddFolder "$DBASE" "$3" returnVal
#sqliteGetDataTypeID "$DBASE" DataTypeID "Folder"
#sqliteAddData "$DBASE" "$DataTypeID" "$returnVal" returnDataID

 elif [[ "$2" = "-t" ]]; then
  sqliteAddText "$DBASE" "$3" returnVal
sqliteGetDataTypeID "$DBASE" DataTypeID "Text"
sqliteAddData "$DBASE" "$DataTypeID" "$returnVal" returnDataID

 elif [[ "$2" = "-b" ]]; then
  sqliteAddDataset "$DBASE" "$3" returnVal
sqliteGetDataTypeID "$DBASE" DataTypeID "Dataset"
sqliteAddData "$DBASE" "$DataTypeID" "$returnVal" returnDataID

 elif [[ "$2" = "-" ]]; then
  echo "'-' used. ToDo: add any other options if need"
  exit 0
 else
  echo "Type of data mast be specified:"
  echo " -f - file"
  echo " -d - folder"
  echo " -t - text"
  echo " -b - integer"
  echo ""
  echo "Exiting with error 1"
  exit 1
 fi

 sqliteLog "$DBASE" "add" "$returnDataID"
 echo "ID of added data = $returnVal"
 echo "Exiting"
 exit 0

elif [ "$COMMAND" = "cmp" ]; then
 # Begin comparing

 # $2 mast be Filter
 # Filters:
 #
 #  Next for two dumps:
 #   same - fix what parts of memory are eq (parts of same files at this moment) (id=1)
 #   diff - fix what parts are difference (parts of files at this moment) (id=2)
 #
 #  Next for one dump:
 #   eq - fix if value of memory eq to Value (look $3) (id=3)
 #   ne - not eq (id=4)
 #   gt - greater then Value (id=5)
 #   lt - lighter then Value (id=6)
 #   ge - greater or eq Value (id=7)
 #   le - lighter or eq Value (id=8)
 #

 # Parameters:
 #  Usage: -parameter data
 # -DT1 - Data1 type (check 'DataTypes.Type'). Example -DT1 "File"
 # -DT2 - Data2 type (check 'Datatypes.Type'). Example -DT2 "Masked"
 # -D1 - Link for Data1
 # -D2 - Link for Data2

 FILTER=$2
 checkfilter=0

 # Checking if specified filter exists in database
 sqliteGetFilters $DBASE filters
 for filter in ${filters[@]}; do
  filterid=$(awk -F\| '{print $1}' <<< "$filter" )
  filtername=$(awk -F\| '{print $2}' <<< "$filter" )

  if [[ "$filtername" = "$FILTER" ]]; then
   checkfilter=1
   break
  fi
 done

 if [[ "$checkfilter" = "0" ]]; then
  echo "No \"$FILTER\" filter specified!"
  echo "Use next filters:"
  for filter in ${filters[@]}; do
   filtername=$(awk -F\| '{print $2}' <<< "$filter" )
   echo " $filtername"
  done
  echo ""
  echo "Exiting with error 1"
  exit 1
  # Exited due no filter in database
 fi

 # Continue comparing ===========================================================

 # ToDo: Make selection from database
 # ToDo: Data may be any 'DataType'
 # ToDo: Any Data may be some saved result

 # Get Parameters for 'cmd' comand from args
 NumParam=3
 NumParams=$#
 echo "$NumParams"
 while [ $NumParam -le $NumParams ]; do
  Param="$3"  #(eval echo "\$$NumParam");

  if [[ "$Param" = "" ]]; then
   break
  fi

  if [[ "$Param" = "-DT1" ]]; then
   DataType1="$4"
   NumParams=$((NumParam + 1))
   shift 1

  elif [[ "$Param" = "-DT2" ]]; then
   DataType2="$4"
   NumParams=$((NumParam + 1))
   shift 1

  elif [[ "$Param" = "-D1" ]]; then
   Data1="$4"
   NumParams=$((NumParam + 1))
   shift 1

  elif [[ "$Param" = "-D2" ]]; then
   Data2="$4"
   NumParams=$((NumParam + 1))
   shift 1

  fi
  NumParam=$((NumParam + 1))
  shift 1

 done

 # Check if all Parameters are valid:
 checkdatatype1=0
 checkdatatype2=0
 sqliteGetDataTypes $DBASE datatypes
 for datatype in ${datatypes[@]}; do
  datatypeid=$(awk -F\| '{print $1}' <<< "$datatype" )
  datatypename=$(awk -F\| '{print $2}' <<< "$datatype" )

  if [[ "$datatypename" = "$DataType1" ]]; then
   checkdatatype1=1
  fi
  if [[ "$datatypename" = "$DataType2" ]]; then
   checkdatatype2=1
  fi

  if [[ "$checkdatatype1" = "1" ]]; then
   if [[ "$checkdatatype2" = "1" ]]; then
    break
   fi
  fi

 done

 if [[ "$checkdatatype1" = "0" ]]; then
  echo "No \"$DataType1\" type of data specified!"
  echo "Use next DataType after -DT1 parameter:"
  for datatype in ${datatypes[@]}; do
   datatypename=$(awk -F\| '{print $2}' <<< "$datatype" )
   echo " $datatypename"
  done
  echo ""
  echo "Exiting with error 1"
  exit 1
  # Exited due no DataTypes in database
 fi

 if [[ "$checkdatatype2" = "0" ]]; then
  echo "No \"$DataType2\" type of data specified!"
  echo "Use next DataType after -DT2 parameter:"
  for datatype in ${datatypes[@]}; do
   datatypename=$(awk -F\| '{print $2}' <<< "$datatype" )
   echo " $datatypename"
  done
  echo ""
  echo "Exiting with error 1"
  exit 1
  # Exited due no DataTypes in database
 fi

# ToDo: make data specification, so cmp command will consist id of data or data itself
# ForNow: Command cmp consists of data itself
 sqliteDataID "$DBASE" dataID1 "$DataType1" "$Data1"
 sqliteDataID "$DBASE" dataID2 "$DataType1" "$Data1"

echo "DataType1=$DataType1; DataType2=$DataType2; Data1=$Data1; Data2=$Data2"

 if [[ "$dataID1" = ""  ]]; then
  echo "No data $Data1 present"
  echo "Exiting with error 1"
  exit 1
 fi
 if [[ "$dataID2" = ""  ]]; then
  echo "No data $Data2 present"
  echo "Exiting with error 1"
  exit 1
 fi


                      

exit 0

Data1="$3"
 if [[ -n $4 ]]; then
  Data2="$4"
 else
  echo "Parameter 4 not specified"
  echo "Exiting with error 1"
  exit 1
 fi

 if [[ "$filtername" = "same" ]] || [[ "$filtername" = "diff" ]]; then
  echo "$Data2"
  sqliteGetData $DBASE Data2 $Data2
  echo "$Data2"
 fi

    echo "Processing $Data1 and $Data2"

    DataSize1=$(stat -c%s "$Data1")
    DataSize2=$(stat -c%s "$Data2")
    if [ "$DataSize1" = "$DataSize2" ]; then

     # ToDo: Make this for every file in folder
     $DIFF_CMD $Data1 $Data2 > /dev/null 2>&1
     error=$?
     if [ $error -eq 2 ]
     then
      echo "There was something wrong with the diff command"
      echo "Exiting with error 1"
      exit 1
     elif [ $error -eq 1 ]
     then

      LowestSize = $DataSize1

     else
      echo "$DIR1/$FNAME1 and $DIR2/$FNAME2 have no differencies"
     fi

     echo "Total size: $DataSize1 bytes"
     echo ""
    else
     echo "Different sizes: $DataSize | $DataSize2."
     if ( $DataSize1 gt $DataSize2 ); then
      LowestSize = $DataSize2
     else
      LowestSize = $DataSize1
     fi
    fi

    # Comparing datasets

 FILES1=$Data1"/*"
 FILES2=$Data2"/*"

 echo "Comparing..."

 #counters for files
 c_files1=0
 c_files2=0
 c_count2=1
 c_feq=0

 for f1 in $FILES1
 do
  FNAME1="${f1##*/}"
  c_files1=$((c_files1+1))
  for f2 in $FILES2
  do
   FNAME2="${f2##*/}"
   if [ "$FNAME1" = "$FNAME2" ]; then
    echo "Processing $FNAME1"
    fsize1=$(stat -c%s "$Data1/$FNAME1")
    fsize2=$(stat -c%s "$Data2/$FNAME2")
    if [ "$fsize1" = "$fsize2" ]; then

     $DIFF_CMD $Data1/$FNAME1 $Data2/$FNAME2 > /dev/null 2>&1
     error=$?
     if [ $error -eq 2 ]
     then
      echo "There was something wrong with the diff command"
     elif [ $error -eq 1 ]
     then

    echo "$Data1/$FNAME1 and $Data2/$FNAME2 differ"
    echo "Total size: $LowestSize bytes"
    i=0
    while [ $i -lt $LowestSize ]; do
     if ! r="`cmp -n 1024 -i $i -b $Data1 $Data2`"; then
      printf "%8x: %s\n" $i "$r"
     fi
     i=$(expr $i + 1024)
    done

     else
      echo "$Data1/$FNAME1 and $Data2/$FNAME2 have no differencies"
     fi

     echo "Total size: $fsize1 bytes"
     echo ""
    else
     echo "different sizes: $fsize | $fsize2"
    fi
    c_feq=$((c_feq+1))
 #   $DIFF_CMD $DIFF_PARAM $DIR1/$FNAME1 $DIR2/$FNAME2
   fi
   if [ "$c_count2" = "1" ]; then
    c_files2=$((c_files2+1))
   fi
  done
  c_count2=0
 done

 echo "files 1 = $c_files1 files 2 = $c_files2"
 echo "eq names = $c_feq"


    # End of comparing

   fi


exit 0;

elif [ "$COMMAND" = "test" ]; then
 DIR1=$2
 DIR2=$3

 FILES1=$DIR1"/*"
 FILES2=$DIR2"/*"

 echo "Comparing..."

 #counters for files
 c_files1=0
 c_files2=0
 c_count2=1
 c_feq=0

 for f1 in $FILES1
 do
  FNAME1="${f1##*/}"
  c_files1=$((c_files1+1))
  for f2 in $FILES2
  do
   FNAME2="${f2##*/}"
   if [ "$FNAME1" = "$FNAME2" ]; then
    echo "Processing $FNAME1"
    fsize1=$(stat -c%s "$DIR1/$FNAME1")
    fsize2=$(stat -c%s "$DIR2/$FNAME2")
    if [ "$fsize1" = "$fsize2" ]; then

     $DIFF_CMD $DIR1/$FNAME1 $DIR2/$FNAME2 > /dev/null 2>&1
     error=$?
     if [ $error -eq 2 ]
     then
      echo "There was something wrong with the diff command"
     elif [ $error -eq 1 ]
     then

      echo "$DIR1/$FNAME1 and $DIR2/$FNAME2 differ"
      echo "Total size: $fsize1 bytes"
      i=0
      while [ $i -lt $fsize1 ]; do
       if ! r="`cmp -n 1024 -i $i -b $DIR1/$FNAME1 $DIR2/$FNAME2`"; then
        printf "%8x: %s\n" $i "$r"
       fi
       i=$(expr $i + 1024)
      done

     else
      echo "$DIR1/$FNAME1 and $DIR2/$FNAME2 have no differencies"
     fi

     echo "Total size: $fsize1 bytes"
     echo ""
    else
     echo "different sizes: $fsize | $fsize2"
    fi
    c_feq=$((c_feq+1))
 #   $DIFF_CMD $DIFF_PARAM $DIR1/$FNAME1 $DIR2/$FNAME2
   fi
   if [ "$c_count2" = "1" ]; then
    c_files2=$((c_files2+1))
   fi
  done
  c_count2=0
 done

 echo "files 1 = $c_files1 files 2 = $c_files2"
 echo "eq names = $c_feq"

elif [ "$COMMAND" = "-" ]; then
 echo "help"
fi
