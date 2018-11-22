-- custmain.4gl

MAIN
	DEFINE query_ok SMALLINT
	DEFINE l_hide, l_labs BOOLEAN

	DISPLAY "Hello world, FGLSERVER is ", fgl_getEnv("FGLSERVER") -- debug message

	TRY
		CONNECT TO "custdemo"
	CATCH
		CALL fgl_winMessage("Error","Failed to connect to database!\n"||SQLERRMESSAGE,"exclamation")
		EXIT PROGRAM
	END TRY

	SET LOCK MODE TO WAIT 6
	LET query_ok = FALSE

	CLOSE WINDOW SCREEN
	OPEN WINDOW w1 WITH FORM "custform"

	CALL ui_init(ui.Window.getCurrent().getForm())
{	OPEN FORM f FROM "custform"
	DISPLAY FORM f}

	MENU
		BEFORE MENU
			CALL set_actions( DIALOG, FALSE )

		ON ACTION find
			LET query_ok = query_cust()
			CALL set_actions( DIALOG, query_ok )

		ON ACTION previous
			IF query_ok THEN
				CALL fetch_rel_cust(-1)
			ELSE
				MESSAGE "You must query first."
			END IF
		ON ACTION next
			IF query_ok THEN
				CALL fetch_rel_cust(1)
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
			LET l_hide = NOT l_hide
			CALL hide_field( "customer.contact_name", "lcon", l_hide)

		ON ACTION labs
			LET l_labs = NOT l_labs
			CALL change_labels( IIF(l_labs,"darkred","darkblue") )

		ON ACTION close
			EXIT MENU

		ON ACTION quit 
			EXIT MENU
	END MENU
	
	CLOSE WINDOW w1

END MAIN
--------------------------------------------------------------------------------
