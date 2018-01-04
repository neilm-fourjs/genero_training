
-- Basic steps:
-- 1.Get the remote file name
-- 2.Copy file from client to server
-- 3.Load the xml file into memory.
-- 4.Get the root node of the xml file
-- 5.Find the nodes you want
-- 6.Loop foreach node in the list
-- 7.Get node in loop to process
-- 8.Populate the array in the loop
-- 9.Display the Array

	DEFINE file_rmt, file_lcl STRING
	DEFINE dd om.DomDocument
	DEFINE dn om.DomNode
	DEFINE gotFile SMALLINT

-- Array to populate from the config.xml 
	DEFINE apps DYNAMIC ARRAY OF RECORD
			img STRING,
			name STRING,
			host STRING,
			type STRING,
			user STRING,
			command STRING
		END RECORD
	
-- Should contain the main controlling logic for the program.
MAIN
	
	CALL init_prog()

-- ...

END MAIN
--------------------------------------------------------------------------------
-- Initialization
FUNCTION init_prog()

-- ...

END FUNCTION
--------------------------------------------------------------------------------
-- Get the file - returns true/false
FUNCTION get_file()

-- ...

	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
-- populate the array with the data from xml file
FUNCTION load_arr()

-- ...

END FUNCTION
--------------------------------------------------------------------------------
-- display the array - show is true=stay in array, false=just display and exit
FUNCTION show_arr( show )
	DEFINE show SMALLINT

-- ...

END FUNCTION
