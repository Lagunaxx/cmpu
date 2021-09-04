###################################################################
#
# Filename: get.sh
# Version: 1.0
# Author: Novoselov Vitaliy A. (Russia, Krasnodar)
#
# Description:
#  Library fo compare.sh to work with sqlite database
#
# Usage:
#  Mostly descriptions are in functions' heads.
#  [] - in description (section 'Usage') show unnessesary parameter
#
###################################################################
#################################################################################################################################################
#                                                                Getting Data                                                                   #
#################################################################################################################################################
#################################################################################################################################################

sqliteGetPath () {
 # Retutns Value of specified path
 # Usage:
 #  sqliteGetPath "SQLite/database.dbfile" returnVariableName "PathID"

 local sqlFILE="$1"
 local -n result="$2"
 result=$(sqlite3 "$sqlFILE" "SELECT path FROM datapath WHERE id=\"$3\"")
}

#################################################################################################################################################

sqliteGetFile () {
 # Retutns Value of specified path
 # Usage:
 #  sqliteGetFile "SQLite/database.dbfile" returnVariableName "fileID"

 local sqlFILE="$1"
 local -n result="$2"
 fNAME=$(sqlite3 "$sqlFILE" "SELECT name FROM filenames WHERE filenames.id=\"$3\"")
 fPATH=$(sqlite3 "$sqlFILE" "SELECT datapath.path FROM datapath INNER JOIN filenames ON filenames.path=database.id WHERE filename.id=\"$3\"")
 result="$fPATH/$fNAME"
}

#################################################################################################################################################

sqliteGetDataset () {
# Return dataset with ID specified if present
# Usage:
#  sqliteGetDataset "SQLite/database.dbfile" returnVariableName "datasetID"

 local sqlFILE="$1"
 local -n result="$2"
 local blobID="$3"

 result=$(sqlite3 "$sqlFILE"  "SELECT quote(dataset) FROM Datasets WHERE id='$blobID'")
 result=${result#*\'} 
 result=${result%\'*}
}

#################################################################################################################################################

sqliteGetData () {
# Return data with ID specified if present
# Usage:
#  sqliteGetData "SQLite/database.dbfile" returnVariableName "dataID"

 local sqlFILE="$1"
 local -n result="$2"
 local dataID="$3"

 result=$(sqlite3 "$sqlFILE"  "SELECT Data FROM Data WHERE id=$dataID")
}

sqliteGetDataIDDataType () {
# Return data with ID specified if present
# Usage:
#  sqliteGetDataIDDataType "SQLite/database.dbfile" returnVariableName "dataID"

 local sqlFILE="$1"
 local -n result="$2"
 local dataID="$3"

 result=$(sqlite3 "$sqlFILE"  "SELECT DataType FROM Data WHERE id=$dataID")
}

sqliteGetDataID () {
# Return data ID
# Usage:
#  sqliteGetDataIDDataType "SQLite/database.dbfile" returnVariableName "DataType" "Data"

 local sqlFILE="$1"
 local -n result="$2"
 local datatype="$3"
 local data="$4"

 result=$(sqlite3 "$sqlFILE"  "SELECT id FROM Data WHERE DataType=\"$datatype\" AND Data=\"$data\"")
}
