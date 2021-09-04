###################################################################
#
# Filename: add.sh
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
#                                                                Adding Data                                                                    #
#################################################################################################################################################

sqliteAddFile () {
 # Add file to database with specified datapath
 # Usage:
 #  sqliteAddFile "SQLite/database.dbfile" "Full/Path/to/file/or/folder" [returnID]

 sqlFILE="$1"
 sqlDATA="$2"

 if [[ -d "$sqlDATA" ]]; then
  # Folder specified

  # First check if folder exists in Database
  checkID=$(sqlite3 "$sqlFILE" "SELECT id FROM datapath WHERE path=\"$sqlDATA\"")

  if [[ "$checkID" = "" ]]; then
   echo "$sqlDATA not in database. Adding..."
   # If folder do not exists then add it in databse
   #sqliteAddFolder "$sqlFILE" "$sqlDATA"
   sqliteAddFolder "$sqlFILE" "$sqlDATA" checkID

  else
   # If specified to add all files then add all files from folder [if they do not exists in database - checking in adding file routin] (recursively)
   echo "$sqlDATA exists in database wih ID = $checkID"
  fi

 elif [[ -f "$sqlDATA" ]]; then
  # File specified

  # Check if folder to file exists, if donot exists then add it
  sqlNAME="${sqlDATA##*/}" # Strip longest match of */ from start
  sqlPATH="${sqlDATA%/*}"

  sqliteGetPathID "$sqlFILE" pathID "$sqlPATH"

  if [[ "$pathID" == "" ]]; then
   sqliteAddFolder "$sqlFILE" "$sqlPATH" pathID
  fi

  # Check if file exists, if do not exists then add it
  sqliteGetFileID "$sqlFILE" fileID "$sqlPATH" "$sqlNAME"
  if [[ "$fileID" == "" ]]; then
   sqlite3 "$sqlFILE" "INSERT INTO filenames (name,path) VALUES (\"$sqlNAME\",\"$pathID\");"
   sqliteGetFileID "$sqlFILE" fileID "$sqlPATH" "$sqlNAME"
   sqliteGetDataTypeID "$sqlFILE" DataTypeID "File"
   sqliteAddData "$sqlFILE" "$DataTypeID" "$fileID" returnDataID

  fi

  checkID="$fileID"

 else
  echo "some error (may be <<$sqlDATA>> do not exists)"
  checkID="Error"
 fi

 if [[ "$3" != "" ]]; then
  local -n sqlReturnID="$3"
  sqlReturnID="$checkID"
 fi


}

#################################################################################################################################################

sqliteAddFolder () {
# Add path to analization
# Usage:
#  sqliteAddFolder "SQLite/database.dbfile" "Path" [returnVariableNameForFolderID]

 local sqlFILE="$1"
 local sqlPATH="$2"

 if [[ -d "$sqlPATH" ]]; then
  sqliteGetPathID "$DBASE" pathid "$sqlPATH"
  if [[ "$pathid" = "" ]]; then
   sqlite3 "$sqlFILE" "INSERT INTO datapath (path) VALUES (\"$sqlPATH\");"
   sqliteGetPathID "$sqlFILE" pathid "$sqlPATH"
   sqliteGetDataTypeID "$sqlFILE" DataTypeID "Folder"
   sqliteAddData "$sqlFILE" "$DataTypeID" "$pathid" returnDataID
  fi

  if [[ "$3" != "" ]]; then
   local -n sqlReturnID="$3"
   sqliteGetPathID "$sqlFILE" sqlReturnID "$sqlPATH"
  fi
  return 0
 else
  echo "No folder <<$sqlPATH>> found"
  return 1
 fi
}

#################################################################################################################################################

sqliteAddText () {
# Add Text to analization
# Usage:
#  sqliteAddText "SQLite/database.dbfile" "Text" [returnVariableName]

 local sqlFILE="$1"
 local text="$2"
 sqliteGetTextID "$sqlFILE" textID "$text"
 if [[ "$textID" = "" ]]; then
  sqlite3 "$sqlFILE" "INSERT INTO Texts (Text) VALUES (\"$text\");"
  sqliteGetTextID "$sqlFILE" idData "$text"
  sqliteGetDataTypeID "$sqlFILE" DataTypeID "Text"
  sqliteAddData "$sqlFILE" "$DataTypeID" "$idData" returnDataID
 fi
 if [[ "$3" != "" ]]; then
  local -n sqlReturnID="$3"
  sqliteGetTextID "$sqlFILE" sqlReturnID "$text"
 fi
}

#################################################################################################################################################
# ToDo make it and sqliteGetDatasetID
sqliteAddDataset () {
# Add path to analization
# Usage:
#  sqliteAddDataset "SQLite/database.dbfile" binaryData [returnVariableName]
#
# binaryData mast be like "0AFF55" or "0a44bf" or similar.

 local sqlFILE="$1"
 local dataset="$2" # mast be "HHJJKK...", where HH JJ and KK are byte-value (from 00 to FF)

 sqliteGetDatasetID "$sqlFILE" datasetID "$dataset"
 if [[ "$datasetID" = "" ]]; then
  sqlite3 "$sqlFILE" "INSERT INTO Datasets (dataset) VALUES (x'$dataset');"
  sqliteGetDatasetID "$sqlFILE" idData "$dataset"
  sqliteGetDataTypeID "$sqlFILE" DataTypeID "Dataset"
  sqliteAddData "$sqlFILE" "$DataTypeID" "$idData" returnDataID
#  sqliteLog "$DBASE" "add" "$returnDataID"
 fi
 if [[ "$3" != "" ]]; then
  local -n sqlReturnID="$3"
  sqliteGetDatasetID "$sqlFILE" sqlReturnID "$dataset"
 fi
}

#################################################################################################################################################

sqliteAddMaskLink () {
# Add path to analization
# Usage:
#  sqliteAddMaskLink "SQLite/database.dbfile" "DataID" "MaskID" [returnVariableName]

 local sqlFILE="$1"
 local DataID="$2"
 local MaskID="$3"

 sqliteGetMaskLinkID "$sqlFILE" sqlReturnID "$DataID" "$MaskID"

 if [[ "$sqlReturnID" = "" ]]; then
  sqlite3 "$sqlFILE" "INSERT INTO MaskLink (Data,DataMask) VALUES (\"$DataID\", \"$MaskID\");"
  sqliteGetMaskLinkID "$sqlFILE" idData "$DataMask" "$MaskID"
  sqliteGetDataTypeID "$sqlFILE" DataTypeID "Masked"
  sqliteAddData "$sqlFILE" "$DataTypeID" "$idData" returnDataID
 fi

 if [[ "$4" != "" ]]; then
  local -n sqlReturnID="$4"
  sqliteGetMaskLinkID "$sqlFILE" sqlReturnID "$DataID" "$MaskID"
 fi
}

#################################################################################################################################################

sqliteAddDataMask () {
#ToDo: make DataMask as Dataset everywhere
# Add path to analization
# Usage:
#  sqliteAddDataMask "SQLite/database.dbfile" "xData" [returnVariableName]

 local sqlFILE="$1"
 local Data="$2" # mast be "HHJJKK...", where HH JJ and KK are byte-value (from 00 to FF)

 sqliteGetDataMaskID "$sqlFILE" datasetID "$Data"
 if [[ "$datasetID" = "" ]]; then
  sqlite3 "$sqlFILE" "INSERT INTO DataMask (Mask) VALUES (x'$Data');"
  sqliteGetDataMaskID "$sqlFILE" idData "$Data"
  sqliteGetDataTypeID "$sqlFILE" DataTypeID "DataMask"
  sqliteAddData "$sqlFILE" "$DataTypeID" "$idData" returnDataID
 fi
 if [[ "$3" != "" ]]; then
  local -n sqlReturnID="$3"
  sqliteGetDataMaskID "$sqlFILE" sqlReturnID "$Data"
 fi
}

#################################################################################################################################################

sqliteAddData () {
# Add Data link
# Usage:
#  sqliteAddData "SQLite/database.dbfile" "DataType" "dataID" [returnVariableName]

 local sqlFILE="$1"
 local datatype="$2" # id of 'DataTypes'
 local dataid="$3"

 sqliteGetDataID "$sqlFILE" id "$datatype" "$dataid"

 if [[ "$id" = "" ]]; then
  sqlite3 "$sqlFILE" "INSERT INTO Data (DataType, Data) VALUES ($datatype,$dataid);"
  sqliteGetDataID "$sqlFILE" returnDataID "$datatype" "$dataid"
  sqliteLog "$DBASE" "add" "$returnDataID"
 fi

 if [[ "$4" != "" ]]; then
  local -n sqlReturnID="$4"
  sqlReturnID="$id"
 fi
}