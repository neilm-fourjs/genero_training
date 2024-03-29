IMPORT FGL lib_rptGre
IMPORT FGL lib

&include "schema.inc"

MAIN
	DEFINE l_stk    RECORD LIKE stock.*
	DEFINE l_stkcat RECORD LIKE stock_cat.*

	CALL db_connect()
	CALL lib_rptGre.init_report(130)

	DECLARE cur CURSOR FOR
			SELECT * FROM stock, stock_cat WHERE stock.stock_cat = stock_cat.stock_cat
					ORDER BY stock.stock_cat, stock.description
	FOREACH cur INTO l_stk.*, l_stkcat.*
		IF lib_rptGre.m_rows = 0 THEN
			LET lib_rptGre.m_rptStarted = TRUE

			CALL lib_rptGre.set_dest(ARG_VAL(1))
			START REPORT report_gre TO XML HANDLER lib_rptGre.m_gre
		END IF
		LET lib_rptGre.m_rows = lib_rptGre.m_rows + 1
		OUTPUT TO REPORT report_gre(l_stk.*, l_stkcat.*)
	END FOREACH
	IF lib_rptGre.m_rptStarted THEN
		FINISH REPORT report_gre
		CALL lib_rptGre.finishReport()
	END IF
	DISPLAY "Program Finished."

END MAIN
--------------------------------------------------------------------------------
REPORT report_gre(l_stk, l_stkcat)
	DEFINE l_stk               RECORD LIKE stock.*
	DEFINE l_stkcat            RECORD LIKE stock_cat.*
	DEFINE l_head, l_desc      STRING
	DEFINE l_row, l_groupCount INTEGER
	DEFINE l_date              DATE

	ORDER EXTERNAL BY l_stk.stock_cat

	FORMAT
		FIRST PAGE HEADER
			LET l_date = TODAY
			LET l_head = "Stock Item Listing by Category"
			PRINT l_date, l_head
			LET l_row = 0

		AFTER GROUP OF l_stk.stock_cat
			LET l_groupCount = GROUP COUNT(*)
			PRINT l_groupCount

		ON EVERY ROW
			LET l_row = l_row + 1
			--IF l_stk.stock_num = 744 THEN LET l_stk.description = NULL END IF
			LET l_desc = l_stk.description CLIPPED
			PRINT l_row, l_stk.*, l_desc, l_stkcat.*

END REPORT
