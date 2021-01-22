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
CONSTANT C_NOIMG = "fa-circle-thin"
DEFINE m_doc om.domDocument
DEFINE m_arr DYNAMIC ARRAY OF t_action
	
MAIN
-- Initial version only works on the default.4ad
	DEFINE l_fileName STRING = C_DEF_FILE
	DEFINE x SMALLINT

	IF NOT os.path.exists( l_fileName ) THEN
		ERROR( SFMT("File '%1' doesn't exist!", l_fileName ) )
		EXIT PROGRAM 1
	END IF	

-- Open the file - should validate that the file exists before trying to open it.
	TRY
		LET m_doc = om.DomDocument.createFromXmlFile(l_fileName)
	CATCH
		ERROR( SFMT("Serious error opening '%1' %2:%3", l_fileName, STATUS, ERR_GET(STATUS) ) )
		EXIT PROGRAM 1
	END TRY
	IF m_doc IS NULL THEN
		ERROR( SFMT("Failed to open '%1' or not a valid XML file!", l_fileName) )
		EXIT PROGRAM 1
	END IF
	IF NOT loadArray(m_doc.getDocumentElement()) THEN
		EXIT PROGRAM 1
	END IF

	DISPLAY SFMT("File '%1' contains %2 actions:", l_fileName, m_arr.getLength() )

-- Step 1 - just display to stdout a list of the actions
	{FOR x = 1 TO m_arr.getLength()
		DISPLAY SFMT("%1) %2  Text = %3  Image = %4", (x USING "&&"), m_arr[x].nam, NVL(m_arr[x].txt, "* no text *"), NVL(m_arr[x].img, "* no image *") )
	END FOR}

-- Step 2 - Open & Display Form
	OPEN FORM f FROM "f_actionMaint2"
	DISPLAY FORM f

-- Step 3 - Allow maintenance
	CALL actMaint()
	
END MAIN
--------------------------------------------------------------------------------
-- Populate the array with the actions from the XML
FUNCTION loadArray( l_node om.domNode )
	DEFINE x SMALLINT
	DEFINE l_nl om.nodeList
	IF l_node.getTagName() != "ActionDefaultList" THEN 
		DISPLAY "File doesn't start with 'ActionDefaultList' !" 
	END IF
	LET l_nl = l_node.selectByTagName("ActionDefault")
	IF l_nl.getLength() < 1 THEN
		ERROR( "File doesn't contain any 'ActionDefault' nodes!" )
		RETURN FALSE
	END IF
	FOR x = 1 TO l_nl.getLength()
		LET l_node = l_nl.item(x)
		LET m_arr[x].nam = l_node.getAttribute("name")
		LET m_arr[x].txt = l_node.getAttribute("text")
		LET m_arr[x].img = l_node.getAttribute("image")
		LET m_arr[x].cmt = l_node.getAttribute("comment")
		LET m_arr[x].ky1 = l_node.getAttribute("acceleratorName")
		LET m_arr[x].ky2 = l_node.getAttribute("acceleratorName2")
		LET m_arr[x].ky3 = l_node.getAttribute("acceleratorName3")
		LET m_arr[x].ky4 = l_node.getAttribute("acceleratorName4")
		LET m_arr[x].dfv = l_node.getAttribute("defaultView")
		LET m_arr[x].cxt = l_node.getAttribute("contextMenu")
		LET m_arr[x].val = l_node.getAttribute("validate")
		IF m_arr[x].img IS NULL THEN LET m_arr[x].img = C_NOIMG END IF
	END FOR
-- Sort the array by name
	CALL m_arr.sort("nam",FALSE)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
-- UI Code
FUNCTION actMaint()
	DEFINE x SMALLINT
-- Write UI code here
	DISPLAY ARRAY m_arr TO arr.*
		BEFORE ROW
			LET x = arr_curr()
			IF m_arr[x].img = C_NOIMG THEN LET m_arr[x].img = NULL END IF
			DISPLAY BY NAME m_arr[x].*
			IF m_arr[x].img IS NULL THEN LET m_arr[x].img = C_NOIMG END IF
	END DISPLAY
END FUNCTION
--------------------------------------------------------------------------------
-- Turn the array back into a XML and save it.
FUNCTION save()
-- if file name already exists confirm to over write it.
-- create a new XML document
-- loop through using createChild and setAttribute to create the nodes
-- save the XML as a file.
END FUNCTION