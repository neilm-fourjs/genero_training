
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
			CALL lib_rptGre.set_dest(NULL)
			CASE lib_rptGre.m_dest
				WHEN "S"
					START REPORT report1 TO SCREEN
				WHEN "F"
					START REPORT report1 TO FILE lib_rptGre.m_fileName
				OTHERWISE
					START REPORT report1 TO PRINTER
			END CASE
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

	OUTPUT
		PAGE LENGTH 40
		TOP MARGIN 0
		BOTTOM MARGIN 0
		LEFT MARGIN 0
		RIGHT MARGIN lib_rptGre.m_pageWidth

	ORDER EXTERNAL BY l_cst.state, l_st.state_name

	FORMAT
		PAGE HEADER
			PRINT lib_rptGre.pageHeader("Customer Item Listing by State", PAGENO)
			PRINT lib_rptGre.hyphens()

		BEFORE GROUP OF l_cst.state
			SKIP TO TOP OF PAGE
			PRINT "State:",l_st.state_name
			PRINT
			PRINT "Num Name                   City            Created"
			PRINT lib_rptGre.hyphens()

		AFTER GROUP OF l_cst.state
			PRINT
			PRINT GROUP COUNT(*), " Items in '"||(l_st.state_name CLIPPED)||"' category."

		ON EVERY ROW
			PRINT (l_cst.store_num USING "&&&")," ",l_cst.store_name," ",l_cst.city," ",l_cst.created_on

		ON LAST ROW
			PRINT
			PRINT lib_rptGre.hyphens()
			PRINT lib_rptGre.lastPage("customer Items")
END REPORT