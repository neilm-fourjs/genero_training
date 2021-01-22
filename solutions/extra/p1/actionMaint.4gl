-- Genero Features used:
-- IMPORT an extra package
-- IMPORT FGL 4gl library
-- preprocessor macro
-- TYPEs
-- Dynamic Arrays, including sorting an array
-- CONSTANTS
-- Initialize a variable in the DEFINE
-- os.path class
-- TRY / CATCH
-- om. XML file access
-- SFMT
-- ERR_GET( )
-- NVL
-- STRING handling
-- getStackTrace ( see error.4gl )

IMPORT os
IMPORT FGL error

-- Error display
&define ERROR( l_err ) CALL error.error( __LINE__, __FILE__, l_err )

TYPE t_action RECORD
	nam STRING,  -- Name of the actions
	txt STRING,  -- text 
	img STRING,  -- image ( file name or TTF icon name )
	cmt STRING,  -- comment ( Tooltip )
	ky1 STRING,  -- acceleratorName
	ky2 STRING,  -- acceleratorName2
	ky3 STRING,  -- acceleratorName3
	ky4 STRING,  -- acceleratorName4
	dfv STRING,  -- defaultView ( "yes"|"no"|"auto" )
	cxt STRING,  -- contextMenu ( "yes"|"no"|"auto" )
	val STRING   -- validate ( Not set or "no" )
END RECORD
CONSTANT C_DEF_FILE = "../etc/default.4ad"
DEFINE m_doc om.domDocument
DEFINE m_arr DYNAMIC ARRAY OF t_action
	
MAIN
-- Initial version only works on the default.4ad
	DEFINE l_fileName STRING = C_DEF_FILE

	WHENEVER ERROR CALL error.crashed

-- An example of how to raise an error using a macro
	ERROR( "This is how you raise an error!" )

--TODO: check the file exists using the os.path method, if not raise an error and exit program


--TODO: Open the file - validate we can open it and it's not null, if not raise an error and exit program


-- Load the Array from the XML 
	IF NOT loadArray(m_doc.getDocumentElement()) THEN
		EXIT PROGRAM 1
	END IF

	DISPLAY SFMT("File '%1' contains %2 actions:", l_fileName, m_arr.getLength() )

--TODO: Step 1 - just display to stdout a list of the actions


-- Step 2 - Open & Display Form
--	OPEN FORM f FROM "f_actionMaint"
--	DISPLAY FORM f

-- Step 3 - Allow maintenance
	CALL actMaint()
	
END MAIN
--------------------------------------------------------------------------------
-- Populate the array with the actions from the XML
FUNCTION loadArray( l_node om.domNode )
	DEFINE l_nl om.nodeList -- will hold a list of ActionDefault nodes
--TODO: check the xml node is the one we expect

--TODO: get a list of ActionDefault nodes

--TODO: if the list is empty raise an error and return false

--TODO: load our m_arr with the details of the nodes

--TODO: Sort the array by name

	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
-- UI Code goes here
FUNCTION actMaint()
-- Write UI code here
END FUNCTION
--------------------------------------------------------------------------------
-- Turn the array back into a XML and save it.
FUNCTION save()
-- if file name already exists confirm to over write it.
-- create a new XML document
-- loop through using createChild and setAttribute to create the nodes
-- save the XML as a file.
END FUNCTION