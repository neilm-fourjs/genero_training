
IMPORT FGL lib_rptGre
IMPORT FGL lib

SCHEMA fjs_demos

MAIN
	DEFINE l_stk RECORD LIKE stock.*
	DEFINE l_stkcat RECORD LIKE stock_cat.*

	CALL db_connect()
	CALL lib_rptGre.init_report(80)

	DECLARE cur CURSOR FOR SELECT * FROM stock,stock_cat WHERE stock.stock_cat = stock_cat.catid
		ORDER BY stock.stock_cat, stock.description
	FOREACH cur INTO l_stk.*, l_stkcat.*
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
		OUTPUT TO REPORT report1( l_stk.*, l_stkcat.* )
	END FOREACH
	IF lib_rptGre.m_rptStarted THEN
		FINISH REPORT report1
	END IF
	DISPLAY "Program Finished."

END MAIN
--------------------------------------------------------------------------------
REPORT report1( l_stk, l_stkcat )
	DEFINE l_stk RECORD LIKE stock.*
	DEFINE l_stkcat RECORD LIKE stock_cat.*

	OUTPUT
		PAGE LENGTH 40
		TOP MARGIN 0
		BOTTOM MARGIN 0
		LEFT MARGIN 0
		RIGHT MARGIN lib_rptGre.m_pageWidth

	ORDER EXTERNAL BY l_stk.stock_cat, l_stk.description

	FORMAT
		PAGE HEADER
			PRINT lib_rptGre.pageHeader("Stock Item Listing by Category", PAGENO)
			PRINT lib_rptGre.hyphens()

		BEFORE GROUP OF l_stk.stock_cat
			SKIP TO TOP OF PAGE
			PRINT "Category:",l_stkcat.cat_name
			PRINT
			PRINT "Stk Code Description"
			PRINT lib_rptGre.hyphens()

		AFTER GROUP OF l_stk.stock_cat
			PRINT
			PRINT GROUP COUNT(*), " Items in '"||(l_stkcat.cat_name CLIPPED)||"' category."

		ON EVERY ROW
			PRINT l_stk.stock_code," ",l_stk.description

		ON LAST ROW
			PRINT
			PRINT lib_rptGre.hyphens()
			PRINT lib_rptGre.lastPage("Stock Items")
END REPORT