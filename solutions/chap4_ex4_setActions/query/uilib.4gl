SCHEMA custdemo
--------------------------------------------------------------------------------
FUNCTION ui_init()
	CALL ui.Interface.loadStartMenu("mystartmenu")
	CALL ui.interface.loadToolBar("mytoolbar")
	CALL ui.interface.loadTopMenu("mytopmenu")
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION set_combo_list( l_cb ui.ComboBox )
	DEFINE l_state RECORD LIKE state.*
	DECLARE state_cur CURSOR FOR SELECT * FROM state
	FOREACH state_cur INTO l_state.*
		CALL l_cb.addItem(l_state.state_code, l_state.state_name CLIPPED)
	END FOREACH
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION hide_field( l_nam STRING, l_lab STRING, l_tf BOOLEAN)
	CALL ui.Window.getCurrent().getForm().setElementHidden(l_nam, l_tf)
	CALL ui.Window.getCurrent().getForm().setElementHidden(l_lab, l_tf)
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION set_actions( d ui.Dialog, l_tf BOOLEAN )
	CALL d.setActionActive("next",l_tf)
	CALL d.setActionActive("previous",l_tf)
	CALL d.setActionActive("update",l_tf)
	CALL d.setActionActive("delete",l_tf)
END FUNCTION
--------------------------------------------------------------------------------
