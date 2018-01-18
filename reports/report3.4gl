
IMPORT FGL lib_rptGre
IMPORT FGL lib

SCHEMA custdemo

MAIN
	DEFINE l_cst RECORD LIKE customer.*
	DEFINE l_st RECORD LIKE state.*

	CALL db_connect()
	CALL lib_rptGre.init_report(80)

	DECLARE cur CURSOR FOR SELECT * FROM customer,state WHERE customer.state = state.state_code
		ORDER BY customer.state, state.state_name
	FOREACH cur INTO l_cst.*, l_st.*
		IF lib_rptGre.m_rows = 0 THEN
			LET lib_rptGre.m_rptStarted = TRUE
			CALL lib_rptGre.set_dest("custrpt1")
			START REPORT report1 TO XML HANDLER lib_rptGre.m_gre
		END IF
		LET lib_rptGre.m_rows = lib_rptGre.m_rows + 1
		OUTPUT TO REPORT report1( l_cst.*, l_st.* )
	END FOREACH
	IF lib_rptGre.m_rptStarted THEN
		FINISH REPORT report1
	END IF
	DISPLAY "Program Finished."

END MAIN
--------------------------------------------------------------------------------
REPORT report1( l_cst, l_st )
	DEFINE l_cst RECORD LIKE customer.*
	DEFINE l_st RECORD LIKE state.*
    DEFINE l_date DATE
    DEFINE l_head STRING
    DEFINE l_row, l_groupCount SMALLINT
    
	OUTPUT
		PAGE LENGTH 40
		TOP MARGIN 0
		BOTTOM MARGIN 0
		LEFT MARGIN 0
		RIGHT MARGIN lib_rptGre.m_pageWidth

	ORDER EXTERNAL BY l_cst.state, l_st.state_name

	FORMAT
		FIRST PAGE HEADER
			LET l_date = TODAY
			LET l_head = "Customer Item Listing by Category"
			PRINT l_date, l_head
			LET l_row = 0

		AFTER GROUP OF l_cst.state
			LET l_groupCount = GROUP COUNT(*)
			PRINT l_groupCount

		ON EVERY ROW
			LET l_row = l_row + 1
			PRINT l_row, l_cst.*, l_st.*

END REPORT