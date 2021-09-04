###################################################################
#
# Filename: sqlite.sh
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

# ToDo:
#  - make reindexing of database
#  - make deletion of records in tables (with links to it)
#
###################################################################
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

source $DIR/textbin.sh
source $DIR/sqlite/getID.sh
source $DIR/sqlite/add.sh
source $DIR/sqlite/get.sh

sqliteCreate () {
# Create database
# Usage:
#  sqliteCreate

 local sqlFILE="$1"
 sqlite3 "$sqlFILE" "CREATE TABLE IF NOT EXISTS datapath ( id INTEGER PRIMARY KEY AUTOINCREMENT, path TEXT NOT NULL UNIQUE );" # <- place for adding Folders
 sqlite3 "$sqlFILE" "CREATE TABLE IF NOT EXISTS filenames ( id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, path INTEGER );" # <- place for adding Files, Path is 'id' of 'datapath'-table

 # Filteres:
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
 # Result of comparing writting to sqllite database. 
 # Table SearchType consists of id of filter 
 # Table SearchData consists of columns Data1 and Data2 and FilterID (link to id of SearchType). 
 #       Data1 = file for comparing/searching. 
 #       Data2 = file (for FilterID = 1 and 2) or Value (for FilterID = [3 ... 8])

 sqlite3 "$sqlFILE" "CREATE TABLE IF NOT EXISTS Commands ( id INTEGER PRIMARY KEY, Command TEXT NOT NULL );" # <- consists of all commands of compare.sh
 sqlite3 "$sqlFILE" "INSERT INTO Commands (id, Command) VALUES (1,\"new\"), (2,\"add\"), (3,\"cmp\");" # <- add here commands of compare.sh

 sqlite3 "$sqlFILE" "CREATE TABLE IF NOT EXISTS SearchType ( id INTEGER PRIMARY KEY, Filter TEXT NOT NULL );" # <- consists of search types used for 'cmp'-command
 sqlite3 "$sqlFILE" "INSERT INTO SearchType VALUES (1,\"same\"), (2,\"diff\"), (3,\"eq\"), (4,\"ne\"), (5,\"gt\"), (6,\"lt\"), (7,\"ge\"), (8,\"le\");" # <- add here if any search types will be added

 sqlite3 "$sqlFILE" "CREATE TABLE IF NOT EXISTS SearchData ( id INTEGER PRIMARY KEY AUTOINCREMENT, SearchType INTEGER NOT NULL, Data1 INTEGER, Data2 INTEGER );" # <- for 'cmp' logging (log here every 'cmp' command). DataX is id of 'Data'-table

 sqlite3 "$sqlFILE" "CREATE TABLE IF NOT EXISTS DataTypes ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT NOT NULL, DTTable TEXT);" # <- Table for data-types
 sqlite3 "$sqlFILE" "INSERT INTO DataTypes (Type, DTTable) VALUES (\"Folder\",\"datapath\"), (\"File\",\"filenames\"), (\"DataMask\",\"DataMask\"), (\"Masked\",\"MaskLink\"), (\"Integer\",\"Data\"), (\"Text\",\"Texts\"), (\"Dataset\",\"DataSets\"), (\"Saved\",\"Saves\");" # <- add here if any other data-types will be added. 'Masked' used to determine what part of data are analized (not analized data may be any value in middle part). Using table 'MaskLink' as Data in 'SearchData'. 'Saved' mast be used to point on step (log) whos result mast be using (reserved)
#ToDo: DataType Integer need to be depricated. Any numeric data mast store in BLOB (Dataset) as number of bytes.

 sqlite3 "$sqlFILE" "CREATE TABLE IF NOT EXISTS CompareLog ( id INTEGER PRIMARY KEY AUTOINCREMENT, command INTEGER NOT NULL, data INTEGER);" # <- add here every command by adding insertion to table in top of command block. 'data' will be id of 'SearchData'.
 sqlite3 "$sqlFILE" "CREATE TABLE IF NOT EXISTS Data (id INTEGER PRIMARY KEY AUTOINCREMENT, DataType INTEGER NOT NULL, Data INTEGER);" # <- stores: if DataType=id of 'Integer', then Data is integer-data, else Data is 'id' of data tables (for Folder - table 'datapath', for File - table 'filenames', for 'Dataset' - table 'Datasets', for Text - table 'Texts', 'MaskLink' - for 'Masked'

 sqlite3 "$sqlFILE" "CREATE TABLE IF NOT EXISTS DataMask (id INTEGER PRIMARY KEY AUTOINCREMENT, Mask BLOB);" # <- here places mask for analized 'Data'
 sqlite3 "$sqlFILE" "CREATE TABLE IF NOT EXISTS MaskLink (id INTEGER PRIMARY KEY AUTOINCREMENT, Data INTEGER, DataMask INTEGER);" # <- consists of 'id' from 'Data'-table and 'id' of 'DataMask'-table, linked in usage.
 sqlite3 "$sqlFILE" "CREATE TABLE IF NOT EXISTS Datasets ( id INTEGER PRIMARY KEY AUTOINCREMENT, dataset BLOB );" # <- here places some binary data
 sqlite3 "$sqlFILE" "CREATE TABLE IF NOT EXISTS Texts ( id INTEGER PRIMARY KEY AUTOINCREMENT, Text TEXT);" # <- here places text data

# Storing data in tables:
#  Masked data: data stores to table (if not exists), specified in Data-table comment. mask stores in DataMask. Next, Link to this Data stores in MaskLink table with link to Mask in DataMask. Link to MaskLink stores to Data table.
#  Most other data: stores in table (if not exists), specified in Datatable comment.

 # ToDo: create table with links betwin DataType and table to use for this DataType (read comment for 'Data'-table above)

 #sqlite3 "$sqlFILE" "INSERT INTO CompareLog (command, data) VALUES (1,0)" # <-store to log first command that executes (compare.sh new).
 sqliteLog "$sqlFILE" "new" "0" # <- same as line above
}

#################################################################################################################################################

sqliteLog () {
 # Add log event
 # Usage:
 #  sqliteLog "SQLite/database.dbfile" "command" "data"
 #
 # Before calling log you need to add data to 'SearchData' table and get 'id' of record

 local sqlFILE="$1"
 local command="$2" # <- "command"  mast be one from table 'Commands.command'
 local data="$3" # <- "data" mast be one from 'id' of 'SearchData' for cmp, or "Data" for add-command

 # command mast be 'id' of 'Commands'
 commandId=$(sqlite3 "$sqlFILE" "SELECT id FROM Commands WHERE Command=\"$command\"")
 if [[ "$commandId" != "" ]]; then
  sqlite3 "$sqlFILE" "INSERT INTO CompareLog (command, data) VALUES($commandId,$data);"
 fi
}

#################################################################################################################################################

sqliteLogAddSearch () {
 # Add SearchData for sqliteLog ()
 # Usage:
 #  sqliteLogAddSearch "SQLite/database.dbfile" "SearchType" "data1" "data2"  [returnVariableName]

 # Add (if not exists) command line (SearchType Data1 Data2) to 'SearchData'-table return 'id'

 local sqlFILE="$1"
 local SearchType="$2" # <- "SearchType"  mast be one from table 'SearchType.Filter'
 local data1="$3" # <- "data1" and "data2" mast be one from 'Data.id'
 local data2="4"

 SearchTypeID=$(sqlite3 "$sqlFILE" "SELECT id FROM SearchType WHERE Type=\"$SearchType\"")
 if [[ "$SearchTypeID" != "" ]]; then
  # ToDo: check if data1 and data2 are present in Data table
  sqlite3 "$sqlFILE" "INSERT INTO SearchData (SearchType, Data1, Data2) VALUES($SearchTypeID,$data1,$data2);"
 else
  echo "SearchType $SearchType not present on database!"
 fi
}

#################################################################################################################################################

sqliteGetFilters () {
 # Returns all registered in database filters
 # Usage:
 #  sqliteGetFilters "SQLite/database.dbfile" returnVariableName

 local sqlFILE="$1"
 local -n result="$2"
 result=$(sqlite3 "$sqlFILE" "SELECT * FROM SearchType")
}

#################################################################################################################################################

sqliteGetDataTypes () {
 # Returns all registered in database DataTypes
 # Usage:
 #  sqliteGetDataTypes "SQLite/database.dbfile" returnVariableName

 local sqlFILE="$1"
 local -n result="$2"
 result=$(sqlite3 "$sqlFILE" "SELECT * FROM DataTypes")
}


#################################################################################################################################################
#################################################################################################################################################

sqliteDataID () {
 # Check if specified Data exists in 'Data'-table
 # Usage:
 #  sqliteIsDataExists "SQLite/database.dbfile" returnVariableName "DataType" "Data"

 local sqlFILE="$1"
 local -n result="$2"
 local DataType="$3"
 local data="$4"


 #ToDo: Next block mast be modifyed to check if specified data exists in database
 local filename="test" # <- Get from data for DataType 'File'
 local filepath="./test" # <- same as above

 result=$(sqlite3 "$sqlFILE" "SELECT Data.id \
				FROM Data \
				 INNER JOIN DataTypes ON Data.DataType=DataTypes.id \
				 INNER JOIN filenames ON Data.Data=filenames.id\
				 INNER JOIN datapath  ON filename.path=datapath.id\
				WHERE DataTypes.Type=\"$DataType\" \
				 AND filenames.name=\"$filename\" \
				 AND datapath.path=\"$filepath\" \
 ")
}
