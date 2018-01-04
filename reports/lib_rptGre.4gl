
PUBLIC DEFINE m_rptStarted BOOLEAN
PUBLIC DEFINE m_rows INTEGER
PUBLIC DEFINE m_dest CHAR(1)
PUBLIC DEFINE m_fileName STRING
PUBLIC DEFINE m_pageWidth SMALLINT
PUBLIC DEFINE m_gre om.SaxDocumentHandler

FUNCTION init_report(l_width)
	DEFINE l_width SMALLINT
	LET m_pageWidth = l_width
	LET m_rptStarted = FALSE
	LET m_rows = 0
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION set_dest(l_rptName)
	DEFINE l_rptName, l_device STRING
	DEFINE l_preview BOOLEAN

	LET l_preview = FALSE
	MENU "Report Destination"
		ATTRIBUTES(STYLE="dialog",COMMENT="Output report to ...",IMAGE="question")
		COMMAND "File" LET m_dest = "F" LET l_device = "XML" 
		COMMAND "File PDF" LET m_dest = "F"  LET l_device = "PDF"
		COMMAND "Screen" LET m_dest = "S" LET l_device = "SVG" 	LET l_preview = TRUE
		COMMAND "Printer" LET m_dest = "P" LET l_device = "Printer"
		COMMAND "PDF" LET m_dest = "D"  LET l_device = "PDF" 	LET l_preview = TRUE
		COMMAND "XLS" LET m_dest = "D"  LET l_device = "XLS" 	LET l_preview = TRUE
		COMMAND "HTML" LET m_dest = "D"  LET l_device = "HTML" 	LET l_preview = TRUE
		COMMAND "XLSX" LET m_dest = "F"  LET l_device = "XLSX" 	LET l_preview = TRUE
		COMMAND "XML" LET m_dest = "F"  LET l_device = "XML"
	END MENU
	IF int_flag THEN
		CALL fgl_winMessage("Cancelled","Report cancelled","information")
		EXIT PROGRAM
	END IF

	IF l_rptName IS NOT NULL THEN LET l_rptName = l_rptName.append(".4rp") END IF
	IF NOT fgl_report_loadCurrentSettings(l_rptName) THEN
		CALL fgl_winMessage("Error","Report initialize failed!","exclamation")
		EXIT PROGRAM
	END IF

	IF m_dest = "F" THEN
		PROMPT "Enter filename:" FOR m_fileName
		IF m_fileName IS NULL THEN LET m_fileName = base.Application.getProgramName() END IF
		IF m_fileName.getIndexOf(".",1) < 1 THEN
			LET m_fileName = m_fileName.append("."||l_device.toLowerCase())
		END IF
	END IF
	IF int_flag THEN
		CALL fgl_winMessage("Cancelled","Report cancelled","information")
		EXIT PROGRAM
	END IF

	IF m_pageWidth > 80 THEN
		CALL fgl_report_configurePageSize("a4length","a4width") -- Landscape
	ELSE
		CALL fgl_report_configurePageSize("a4width","a4length") -- Portrait
	END IF

	IF l_device = "PDF" AND l_rptName IS NULL THEN
		CALL fgl_report_configureCompatibilityOutput (m_pageWidth,"Courier",TRUE,base.Application.getProgramName(),"","") 
	END IF

	IF l_device != "XML" THEN
		CALL fgl_report_selectDevice(l_device)
		CALL fgl_report_selectPreview(l_preview)
	END IF

	IF l_device = "Printer" THEN
		CALL fgl_report_setPrinterName( m_fileName )
	ELSE
		IF m_fileName IS NOT NULL THEN
			CALL fgl_report_setOutputFileName( m_fileName )
		END IF
	END IF
	-- Return the SAX handler
	IF l_device = "XML" THEN -- Just produce XML output
		LET m_gre = fgl_report_createProcessLevelDataFile(m_fileName)
	ELSE -- Produce a report using GRE
		LET m_gre = fgl_report_commitCurrentSettings()
	END IF

	MESSAGE "Printing, please wait ..."
	CALL ui.Interface.refresh()

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION lastPage(l_what)
	DEFINE l_what STRING
	DEFINE l_out VARCHAR(132)
	LET l_out = "Report Finished: ",m_rows," ",l_what," Printed."
	RETURN l_out
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION hyphens()
	DEFINE l_out VARCHAR(132)
	LET l_out = "------------------------------------------------------------------------------------------------------------------------------------"
	RETURN l_out[1,m_pageWidth]
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION pageHeader(l_titl, l_pno)
	DEFINE l_titl STRING
	DEFINE l_rptTitle VARCHAR(132)
	DEFINE x,l_pno SMALLINT

	LET x = ( m_pageWidth / 2 ) - ( l_titl.getLength() / 2 )
	LET l_rptTitle = TODAY
	LET l_rptTitle[x, x+l_titl.getLength() ] = l_titl
	LET l_rptTitle[ m_pageWidth-2, m_pageWidth ] = (l_pno USING "&&&")
	RETURN l_rptTitle

END FUNCTION