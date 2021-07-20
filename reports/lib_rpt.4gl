
PUBLIC DEFINE m_rptStarted BOOLEAN
PUBLIC DEFINE m_rows INTEGER
PUBLIC DEFINE m_dest CHAR(1)
PUBLIC DEFINE m_fileName STRING
PUBLIC DEFINE m_pageWidth SMALLINT

FUNCTION init_report(l_width)
	DEFINE l_width SMALLINT
	LET m_pageWidth = l_width
	LET m_rptStarted = FALSE
	LET m_rows = 0
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION set_dest()

	MENU "Report Destination"
		ATTRIBUTES(STYLE="dialog",COMMENT="Output report to ...",IMAGE="question")
		COMMAND "File" LET m_dest = "F"
		COMMAND "Screen" LET m_dest = "S"
		COMMAND "Printer" LET m_dest = "P"
	END MENU
	IF int_flag THEN
		CALL fgl_winMessage("Cancelled","Report cancelled","information")
		EXIT PROGRAM
	END IF

	IF m_dest = "F" THEN
		PROMPT "Enter filename:" FOR m_fileName
		IF m_fileName IS NULL THEN LET m_fileName = base.Application.getProgramName() END IF
		IF m_fileName.getIndexOf(".",1) < 1 THEN
			LET m_fileName = m_fileName.append(".rpt")
		END IF
	END IF
	IF int_flag THEN
		CALL fgl_winMessage("Cancelled","Report cancelled","information")
		EXIT PROGRAM
	END IF
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
