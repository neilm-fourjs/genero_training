-- custmain.4gl

MAIN
	DEFINE query_ok SMALLINT
	DEFINE l_tf, l_labs BOOLEAN

	DISPLAY "Hello world, FGLSERVER is ", fgl_getEnv("FGLSERVER") -- debug message

	TRY
		CONNECT TO "custdemo"
	CATCH
		CALL fgl_winMessage("Error","Failed to connect to database!\n"||SQLERRMESSAGE,"exclamation")
		EXIT PROGRAM
	END TRY

	LET query_ok = FALSE

	CALL ui_init()
	CLOSE WINDOW SCREEN
	OPEN WINDOW w1 WITH FORM "custform"

	CALL ui.Window.getCurrent().setText("Hello World")
--	OPEN FORM f FROM "custform"
--	DISPLAY FORM f

	MENU
		BEFORE MENU
			CALL set_actions( DIALOG, FALSE  )

		ON ACTION find 
			LET query_ok = query_cust()
			CALL set_actions( DIALOG, query_ok )

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
			CALL hide_field( "customer.contact_name", "lab4", l_tf )
			CALL DIALOG.getForm().setElementText( "hide", IIF(l_tf,"Show","Hide"))
			CALL DIALOG.getForm().setElementImage("hide", IIF(l_tf,"fa-toggle-on","fa-toggle-off"))

		ON ACTION labs
			LET l_labs = NOT l_labs
			CALL change_labels( IIF(l_labs,"darkred","darkblue") )

		ON ACTION ext CALL extend_form( DIALOG.getForm().getNode() )

		ON ACTION quit EXIT MENU
		ON ACTION close EXIT MENU
	END MENU

	CLOSE WINDOW w1

END MAIN
