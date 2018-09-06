
SCHEMA custdemo

--------------------------------------------------------------------------------
FUNCTION ui_init()

	CALL ui.interface.loadToolBar("mytoolbar")
	CALL ui.interface.loadTopMenu("mytopmenu")
--	CALL ui.interface.loadStartMenu("mystartmenu")

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION cb_init( l_cb ui.Combobox )
	DEFINE l_state RECORD LIKE state.*
	DECLARE state_cur CURSOR FOR SELECT * FROM state
	FOREACH state_cur INTO l_state.*
		CALL l_cb.addItem( l_state.state_code CLIPPED, l_state.state_name CLIPPED )
	END FOREACH
END FUNCTION
