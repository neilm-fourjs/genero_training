-- custmain.4gl

MAIN
	DEFINE query_ok SMALLINT

	DISPLAY "Hello world, FGLSERVER is ", fgl_getEnv("FGLSERVER") -- debug message

	TRY
		CONNECT TO "custdemo"
	CATCH
		CALL fgl_winMessage("Error","Failed to connect to database!\n"||SQLERRMESSAGE,"exclamation")
		EXIT PROGRAM
	END TRY

	SET LOCK MODE TO WAIT 6
	LET query_ok = FALSE

	CALL ui_init()
	CLOSE WINDOW SCREEN
	OPEN WINDOW w1 WITH FORM "custform"

	MENU
		ON ACTION close
			EXIT MENU
		ON ACTION find 
			LET query_ok = query_cust()
		ON ACTION next
			IF query_ok THEN
				CALL fetch_rel_cust(1)
			ELSE
				MESSAGE "You must query first."
			END IF
		ON ACTION previous
			IF query_ok THEN
				CALL fetch_rel_cust(-1)
			ELSE
				MESSAGE "You must query first."
			END IF
		ON ACTION add
			IF inpupd_cust("A") THEN
				CALL insert_cust()
			END IF
		ON ACTION delete
			IF delete_check() THEN
				CALL delete_cust()
			END IF
		ON ACTION update
			IF inpupd_cust("U") THEN
				CALL update_cust()
			END IF
		ON ACTION quit 
			EXIT MENU
	END MENU
	
	CLOSE WINDOW w1
 
END MAIN
--------------------------------------------------------------------------------
FUNCTION ui_init()

	CALL ui.interface.loadToolBar("mytoolbar")
	CALL ui.interface.loadTopMenu("mytopmenu")
	CALL ui.interface.loadStartMenu("mystartmenu")

END FUNCTION
