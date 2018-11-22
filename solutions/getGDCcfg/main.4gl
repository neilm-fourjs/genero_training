
-- Changes:
--	Multidialog
--	Handle both 2.20 and 2.11 format config.xml files.

IMPORT os
IMPORT FGL about
IMPORT FGL shownode

DEFINE m_file_remote, m_file_local STRING
DEFINE m_nl om.NodeList

-- Array to populate from the config.xml
DEFINE m_apps DYNAMIC ARRAY OF RECORD
		img STRING,
		name STRING,
		host STRING,
		type STRING,
		user STRING,
		command STRING
	END RECORD

-- Should contain the main controlling logic for the program.
MAIN

	CALL initProg()

	OPEN FORM frm FROM "form"
	DISPLAY FORM frm

	DIALOG ATTRIBUTES(UNBUFFERED)

		INPUT BY NAME m_file_remote, m_file_local ATTRIBUTE(WITHOUT DEFAULTS)
			ON ACTION fileopen 
				IF browseFile() THEN
					IF getRemoteFile() THEN
						CALL ui.interface.refresh()
					END IF
				END IF
		END INPUT

		DISPLAY ARRAY m_apps TO arr.*
			ON ACTION details -- Trigged on a Double click of a row item or clicking on accept button.
				CALL shownode.showNode(  m_nl.item( arr_curr() ) )

			BEFORE ROW
				MESSAGE "Row = "||arr_Curr()
		END DISPLAY

		ON ACTION about CALL about.about()
		ON ACTION exit EXIT DIALOG
		ON ACTION close EXIT PROGRAM
	END DIALOG

END MAIN
--------------------------------------------------------------------------------
-- Initialization
FUNCTION initProg()
	CALL ui.interface.setText("getGDCcfg") -- StartBar Text
	CALL ui.interface.setImage("getGDCcfg") -- Custom Icon
END FUNCTION
--------------------------------------------------------------------------------
-- Browse for file - returns true/false
FUNCTION browseFile() RETURNS BOOLEAN
	CALL ui.interface.frontCall("standard","openfile",["","Config","*.xml",%"GDC Config File"],m_file_remote)
	IF m_file_remote IS NULL THEN
		ERROR %"Cancelled"
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
#+ Get the Remote File / read file / call loadArr
#+
#+ @returns boolean success
FUNCTION getRemoteFile() RETURNS BOOLEAN
	DEFINE l_err STRING
	DEFINE l_dd om.DomDocument
	DEFINE l_dn om.DomNode

	IF m_file_local IS NULL THEN
		LET m_file_local = os.path.basename( m_file_remote )
	END IF
	IF NOT validateFile(m_file_local) THEN RETURN FALSE END IF

	TRY
		CALL fgl_getfile( m_file_remote, m_file_local )
	CATCH
		CASE STATUS
			WHEN -8064 LET l_err = ERR_GET( STATUS )
			WHEN -8065 LET l_err = %"Network error during file transfer."
			WHEN -8066 LET l_err = %"Could not write destination file for file transfer."
			WHEN -8067 LET l_err = %"Could not read source for file transfer."
			OTHERWISE  LET l_err = %"Unknown Error:"||STATUS
		END CASE
		CALL fgl_winMessage(%"Error",SFMT(%"Error reading '%1'\n"||l_err,m_file_local),"exclamation")
		RETURN FALSE
	END TRY	

	LET l_dd = om.DomDocument.createFromXmlFile( m_file_local )
	IF l_dd IS NULL THEN
		CALL fgl_winMessage(%"Error",SFMT(%"Error reading '%1'",m_file_local),"exclamation")
		RETURN FALSE
	END IF

	LET l_dn = l_dd.getDocumentElement()
	IF l_dn IS NULL THEN
		CALL fgl_winmessage(%"Error",SFMT(%"Error '%1' is empty!",m_file_local),"exclamation")
		RETURN FALSE
	END IF

	RETURN loadArray(l_dn)
END FUNCTION
--------------------------------------------------------------------------------
#+ validate that local file doesn't already exist
#+
#+ @param l_file File to check
#+ @returns boolean success
FUNCTION validateFile(l_file STRING) RETURNS BOOLEAN
	DEFINE l_info STRING
	IF os.path.exists( l_file ) THEN
		LET l_info = "\n"||l_file||" - "||os.path.mtime( l_file )
		MENU %"File Exists" 
			ATTRIBUTES(COMMENT=SFMT(%"Replace Existing Local File ? %1",l_info), IMAGE="exclamation", STYLE="dialog")
			ON ACTION replace EXIT MENU
			ON ACTION cancel RETURN FALSE
		END MENU
	END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
#+ populate the array with the data from xml file.
#+
#+ @param l_dn DomNode for the xml config file
#+ @returns boolean success
FUNCTION loadArray(l_dn om.DomNode) RETURNS BOOLEAN
	DEFINE l_n om.domNode
	DEFINE x SMALLINT
	DEFINE l_tag STRING

	LET l_tag = "Shortcuts"
	LET m_nl = l_dn.selectByTagName( l_tag )
	IF m_nl.getLength() < 1 THEN
		CALL fgl_winmessage("Error","No "||l_tag||" in '"||m_file_local||"'!","exclamation")
		RETURN FALSE
	END IF

	LET l_tag = l_tag.subString(1,l_tag.getLength()-1)
	LET m_nl = l_dn.selectByTagName( l_tag )
	MESSAGE l_tag||":"|| m_nl.getLength()
	CALL m_apps.clear()
	FOR x = 1 TO m_nl.getLength()
		LET l_n = m_nl.item( x )
		LET m_apps[ m_apps.getLength() + 1 ].name = l_n.getAttribute("name")
		LET m_apps[ m_apps.getLength() ].type = l_n.getAttribute("type")
		LET m_apps[ m_apps.getLength() ].img  = l_n.getAttribute("iconFilePath")
		LET m_apps[ m_apps.getLength() ].host = l_n.getAttribute("hostName")
		LET m_apps[ m_apps.getLength() ].user = l_n.getAttribute("userName")
		LET m_apps[ m_apps.getLength() ].command = l_n.getAttribute("hostCommand")
	END FOR
	RETURN TRUE

END FUNCTION
