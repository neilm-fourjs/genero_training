-- custmain.4gl

MAIN
	DEFINE query_ok SMALLINT
	DEFINE l_tf BOOLEAN

	DISPLAY "Hello world, FGLSERVER is ", fgl_getEnv("FGLSERVER") -- debug message

	TRY
		CONNECT TO "custdemo"
	CATCH
		CALL fgl_winMessage("Error","Failed to connect to database!\n"||SQLERRMESSAGE,"exclamation")
		EXIT PROGRAM
	END TRY

	LET query_ok = FALSE

	CLOSE WINDOW SCREEN
	OPEN WINDOW w1 WITH FORM "custform"
	CALL ui_init(ui.Window.getCurrent().getForm())

	CALL ui.Window.getCurrent().setText("Hello World")

	MENU
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

		ON ACTION hide 
			LET l_tf = NOT l_tf
			CALL hide_field( "customer.contact_name", "lcon", l_tf )

		ON ACTION quit EXIT MENU
		ON ACTION close EXIT MENU
	END MENU

	CLOSE WINDOW w1

END MAIN
