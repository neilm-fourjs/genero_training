
IMPORT FGL lib_rpt
IMPORT FGL lib

&include "schema.inc"

MAIN
	DEFINE l_stk RECORD LIKE stock.*
	DEFINE l_stkcat RECORD LIKE stock_cat.*

	CALL db_connect()
	CALL lib_rpt.init_report(80)

	DECLARE cur CURSOR FOR SELECT * FROM stock,stock_cat WHERE stock.stock_cat = stock_cat.stock_cat
		ORDER BY stock.stock_cat, stock.description
	FOREACH cur INTO l_stk.*, l_stkcat.*
		IF lib_rpt.m_rows = 0 THEN
			LET lib_rpt.m_rptStarted = TRUE
			CALL lib_rpt.set_dest()
			CASE lib_rpt.m_dest
				WHEN "S"
					START REPORT report1 TO SCREEN
				WHEN "F"
					START REPORT report1 TO FILE lib_rpt.m_fileName
				OTHERWISE
					START REPORT report1 TO PRINTER
			END CASE
		END IF
		LET lib_rpt.m_rows = lib_rpt.m_rows + 1
		OUTPUT TO REPORT report1( l_stk.*, l_stkcat.* )
	END FOREACH
	IF lib_rpt.m_rptStarted THEN
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
		RIGHT MARGIN lib_rpt.m_pageWidth

	ORDER EXTERNAL BY l_stk.stock_cat, l_stk.description

	FORMAT
		PAGE HEADER
			PRINT lib_rpt.pageHeader("Stock Item Listing by Category", PAGENO)
			PRINT lib_rpt.hyphens()

		BEFORE GROUP OF l_stk.stock_cat
			SKIP TO TOP OF PAGE
			PRINT "Category:",l_stkcat.description
			PRINT
			PRINT "Stk Code", COLUMN 20, "Description"
			PRINT lib_rpt.hyphens()

		AFTER GROUP OF l_stk.stock_cat
			PRINT
			PRINT GROUP COUNT(*), " Items in '"||(l_stkcat.description CLIPPED)||"' category."

		ON EVERY ROW
			PRINT l_stk.stock_num, COLUMN 20,l_stk.description

		ON LAST ROW
			PRINT
			PRINT lib_rpt.hyphens()
			PRINT lib_rpt.lastPage("Stock Items")
END REPORT