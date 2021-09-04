###################################################################
#
# Filename: getID.sh
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
#                                                               Getting Data ID                                                                 #
#################################################################################################################################################

sqliteGetDataTypeID () {
 # Return ID of specified DataType:
 # Usage:
 #  sqliteGetFileID "SQLite/database.dbfile" returnVariableName "Datatype"

 local sqlFILE="$1"
 local -n result="$2"
 local datatype="$3"
 result=$(sqlite3 "$sqlFILE" "SELECT id FROM DataTypes WHERE Type=\"$datatype\"")
}

#################################################################################################################################################

sqliteGetFileID () {
 # Return ID of specified path:
 # Usage:
 #  sqliteGetFileID "SQLite/database.dbfile" returnVariableName "File/Path" "File.name"

 local sqlFILE="$1"
 local -n result="$2"
 local sqlPATH="$3"
 local sqlNAME="$4"
 result=$(sqlite3 "$sqlFILE" "SELECT filenames.id FROM filenames INNER JOIN datapath ON filenames.path=datapath.id WHERE datapath.path=\"$sqlPATH\" AND filenames.name=\"$sqlNAME\"")
}

#################################################################################################################################################

sqliteGetPathID () {
 # Return ID of specified path 
 # Usage:
 #  sqliteGetPathID "SQLite/database.dbfile" returnVariableName "Path"

 local sqlFILE="$1"
 local -n result="$2"
 local sqlPATH="$3"
 result=$(sqlite3 "$sqlFILE" "SELECT id FROM datapath WHERE path=\"$sqlPATH\"")
}

#################################################################################################################################################

sqliteGetDatasetID () {
# Return ID of dataset if present
# Usage:
#  sqliteGetDatasetID "SQLite/database.dbfile" returnVariableName binaryData

 local sqlFILE="$1"
 local -n result="$2"
 local blobtext="$3"

 # Encode 'blobtext'-number to binary format
 #local blob= bash do not support binary data normaly. so converting it right into sql command
# 'blobtext' mast be "HHJJKK..." format, where HH=hex byte
# ToDo: make 'blobtext' more flexible with numbers

 result=$(sqlite3 "$sqlFILE" "SELECT id FROM Datasets WHERE dataset=x'$blobtext';")
}

#################################################################################################################################################

sqliteGetDataMaskID () {
# Return ID of dataset if present
# Usage:
#  sqliteGetDataMaskID "SQLite/database.dbfile" returnVariableName binaryData

 local sqlFILE="$1"
 local -n result="$2"
 local blobtext="$3"

 # Encode 'blobtext'-number to binary format
 #local blob= bash do not support binary data normaly. so converting it right into sql command
# 'blobtext' mast be "HHJJKK..." format, where HH=hex byte
# ToDo: make 'blobtext' more flexible with numbers

 result=$(sqlite3 "$sqlFILE" "SELECT id FROM DataMask WHERE Mask=x'$blobtext';")
}

#################################################################################################################################################

sqliteGetTextID () {
# Return ID of text if present
# Usage:
#  sqliteGetTextID "SQLite/database.dbfile" returnVariableName "Text"

 local sqlFILE="$1"
 local -n result="$2"
 local text="$3"
 result=$(sqlite3 "$sqlFILE" "SELECT id FROM Texts WHERE Text=\"$text\";")
}

#################################################################################################################################################

sqliteGetMaskLinkID () {
# Return ID of MaskLink if present
# Usage:
#  sqliteGetMaskLinkID "SQLite/database.dbfile" returnVariableName "DataID" "MaskID"

 local sqlFILE="$1"
 local -n result="$2"
 local DataID="$3"
 local MaskID="$4"
 result=$(sqlite3 "$sqlFILE" "SELECT id FROM MaskLink WHERE Data=\"$DataID\" AND DataMask=\"$MaskID\";")
}
