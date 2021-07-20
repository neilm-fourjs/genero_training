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
IMPORT FGL fgldialog
IMPORT FGL error
IMPORT FGL lib

-- Error display
&define ERROR( l_err ) CALL error.error( __LINE__, __FILE__, l_err )

TYPE t_action RECORD
	nam STRING, -- Name of the actions
	txt STRING, -- text
	img STRING, -- image ( file name or TTF icon name )
	cmt STRING, -- comment ( Tooltip )
	ky1 STRING, -- acceleratorName
	ky2 STRING, -- acceleratorName2
	ky3 STRING, -- acceleratorName3
	ky4 STRING, -- acceleratorName4
	dfv STRING, -- defaultView ( "yes"|"no"|"auto" )
	cxt STRING, -- contextMenu ( "yes"|"no"|"auto" )
	val STRING  -- validate ( Not set or "no" )
END RECORD
CONSTANT C_DEF_FILE = "../etc/default.4ad"
CONSTANT C_NOIMG    = "fa-circle-thin"
DEFINE m_doc      om.domDocument
DEFINE m_arr      DYNAMIC ARRAY OF t_action
DEFINE m_fileName STRING = C_DEF_FILE
MAIN
-- Initial version only works on the default.4ad

	IF NOT os.path.exists(m_fileName) THEN
		ERROR(SFMT("File '%1' doesn't exist!", m_fileName))
		EXIT PROGRAM 1
	END IF

-- Open the file - should validate that the file exists before trying to open it.
	TRY
		LET m_doc = om.DomDocument.createFromXmlFile(m_fileName)
	CATCH
		ERROR(SFMT("Serious error opening '%1' %2:%3", m_fileName, STATUS, ERR_GET(STATUS)))
		EXIT PROGRAM 1
	END TRY
	IF m_doc IS NULL THEN
		ERROR(SFMT("Failed to open '%1' or not a valid XML file!", m_fileName))
		EXIT PROGRAM 1
	END IF
	IF NOT loadArray(m_doc.getDocumentElement()) THEN
		EXIT PROGRAM 1
	END IF

	DISPLAY SFMT("File '%1' contains %2 actions:", m_fileName, m_arr.getLength())

-- Step 1 - just display to stdout a list of the actions
{	FOR x = 1 TO m_arr.getLength()
		DISPLAY SFMT("%1) %2  Text = %3  Image = %4", (x USING "&&"), m_arr[x].nam, NVL(m_arr[x].txt, "* no text *"), NVL(m_arr[x].img, "* no image *") )
	END FOR}

-- Step 2 - Open & Display Form
	CALL ui.Interface.setText("Action Default Maintenance")
	CALL ui.interface.setImage("fa-tag")
	OPEN FORM f FROM "f_actionMaint3"
	DISPLAY FORM f
	DISPLAY m_fileName TO filename

-- Step 3 - Allow maintenance
	CALL actMaint()

END MAIN
--------------------------------------------------------------------------------
-- Populate the array with the actions from the XML
FUNCTION loadArray(l_node om.domNode)
	DEFINE x                SMALLINT
	DEFINE l_nl             om.nodeList
	IF l_node.getTagName() != "ActionDefaultList" THEN
		DISPLAY "File doesn't start with 'ActionDefaultList' !"
	END IF
	LET l_nl = l_node.selectByTagName("ActionDefault")
	IF l_nl.getLength() < 1 THEN
		ERROR("File doesn't contain any 'ActionDefault' nodes!")
		RETURN FALSE
	END IF
	FOR x = 1 TO l_nl.getLength()
		LET l_node       = l_nl.item(x)
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
		IF m_arr[x].img IS NULL THEN
			LET m_arr[x].img = C_NOIMG
		END IF
	END FOR
-- Sort the array by name
	CALL m_arr.sort("nam", FALSE)
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
-- UI Code
FUNCTION actMaint()
	DEFINE l_rec     t_action
	DEFINE l_touched BOOLEAN
	DEFINE l_img     STRING
	DEFINE l_row     SMALLINT
	DIALOG ATTRIBUTE(UNBUFFERED)
		DISPLAY ARRAY m_arr TO arr.*
			BEFORE ROW
				LET l_row = arr_curr()
				LET l_rec.* = m_arr[l_row].*
				IF l_rec.img = C_NOIMG THEN
					LET l_rec.img = NULL
				END IF
				DISPLAY l_rec.img TO img2

			ON INSERT
				CALL ins(l_row)
				IF NOT int_flag THEN
					CALL DIALOG.setActionActive("save", TRUE)
				END IF

			ON DELETE
				IF fgldialog.fgl_winQuestion(
								"Confirm", SFMT("Delete the '%1' action?", l_rec.nam), "No", "Yes|No", "question", 0)
						= "No" THEN
					LET int_flag = TRUE
				ELSE
					CALL DIALOG.setActionActive("save", TRUE)
				END IF

		END DISPLAY

		INPUT BY NAME l_rec.*
			BEFORE INPUT
				LET l_touched = FALSE
				CALL DIALOG.setActionActive("dialogtouched", TRUE)
				CALL DIALOG.setActionActive("accept", FALSE)

			ON ACTION imgs INFIELD img
				LET l_img = lib.imgLookUp()
				IF l_img IS NOT NULL THEN
					LET l_rec.img = l_img
					LET l_touched = TRUE
					CALL DIALOG.setActionActive("accept", TRUE)
				END IF
				DISPLAY l_rec.img TO img2

			ON ACTION dialogtouched
				LET l_touched = TRUE
				CALL DIALOG.setActionActive("accept", TRUE)
				CALL DIALOG.setActionActive("dialogtouched", FALSE)

			ON ACTION accept
				LET m_arr[l_row].* = l_rec.* -- save record to the array
				CALL DIALOG.setActionActive("save", TRUE)
				LET l_touched = FALSE
				NEXT FIELD col1

			ON ACTION cancel
				LET l_rec.* = m_arr[l_row].* -- restore the record
				LET l_touched = FALSE
				NEXT FIELD col1

			AFTER INPUT
				IF l_touched THEN
					IF fgl_winQuestion(
									"Confirm", SFMT("Action changed.\nUpdate the '%1' action?", l_rec.nam), "No", "Yes|No", "question", 0)
							= "Yes" THEN
						LET m_arr[l_row].* = l_rec.*
						CALL DIALOG.setActionActive("save", TRUE)
					END IF
				END IF
		END INPUT
		BEFORE DIALOG
			CALL DIALOG.setActionActive("save", FALSE)
		ON ACTION save
			CALL save()
			CALL DIALOG.setActionActive("save", FALSE)
		ON ACTION quit
			EXIT DIALOG
		ON ACTION close
			EXIT DIALOG
	END DIALOG
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION ins(x SMALLINT)
	DEFINE l_img STRING
	INPUT BY NAME m_arr[x].* ATTRIBUTES(UNBUFFERED)
		ON ACTION imgs INFIELD img
			LET l_img = lib.imgLookUp()
			IF l_img IS NOT NULL THEN
				LET m_arr[x].img = l_img
			END IF
			DISPLAY m_arr[x].img TO img2
	END INPUT

	IF NOT int_flag THEN
		IF m_arr[x].img IS NULL THEN
			LET m_arr[x].img = C_NOIMG
		END IF
	END IF
END FUNCTION
--------------------------------------------------------------------------------
-- Turn the array back into a XML and save it.
FUNCTION save()
	DEFINE x           SMALLINT
	DEFINE l_doc       om.domDocument
	DEFINE l_root, l_n om.DomNode
-- if file name already exists confirm to over write it.
-- create a new XML document
-- loop through using createChild and setAttribute to create the nodes
-- save the XML as a file.
	LET l_doc  = om.domDocument.create("ActionDefaultList")
	LET l_root = l_doc.getDocumentElement()
	FOR x = 1 TO m_arr.getLength()
		LET l_n = l_root.createChild("ActionDefault")
		IF m_arr[x].nam IS NOT NULL THEN
			CALL setAttr(l_n, "name", m_arr[x].nam)
			CALL setAttr(l_n, "text", m_arr[x].txt)
			CALL setAttr(l_n, "image", m_arr[x].img)
			CALL setAttr(l_n, "comment", m_arr[x].cmt)
			CALL setAttr(l_n, "acceleratorName", m_arr[x].ky1)
			CALL setAttr(l_n, "acceleratorName2", m_arr[x].ky2)
			CALL setAttr(l_n, "acceleratorName3", m_arr[x].ky3)
			CALL setAttr(l_n, "acceleratorName4", m_arr[x].ky4)
			CALL setAttr(l_n, "defaultView", m_arr[x].dfv)
			CALL setAttr(l_n, "contextMenu", m_arr[x].cxt)
			CALL setAttr(l_n, "validate", m_arr[x].val)
		END IF
	END FOR
	DISPLAY l_root.toString()
	CALL l_root.writeXml(m_fileName || ".new")
	MESSAGE "File saved."
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION setAttr(l_n om.domNode, l_key STRING, l_val STRING)
	IF l_val IS NOT NULL THEN
		CALL l_n.setAttribute(l_key, l_val.trim())
	END IF
END FUNCTION
