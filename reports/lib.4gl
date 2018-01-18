
FUNCTION db_connect()
	DEFINE l_db VARCHAR(30)

	LET l_db = "custdemo"
	TRY
		CONNECT TO l_db
	CATCH
		CALL fgl_winMessage("Error","Failed to connect to database '"||l_db||"'\n"||SQLERRMESSAGE,"exclamation")
		EXIT PROGRAM
	END TRY

END FUNCTION