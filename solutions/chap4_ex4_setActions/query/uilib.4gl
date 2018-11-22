SCHEMA custdemo
FUNCTION ui_init(l_f ui.Form)
	CALL l_f.loadToolBar("mytoolbar")
	CALL l_f.loadTopMenu("mytopmenu")
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION set_combo_list( l_cb ui.combobox )
	DEFINE l_rec RECORD LIKE state.*
	DECLARE cur CURSOR FOR SELECT * FROM state
	FOREACH cur INTO l_rec.*
		CALL l_cb.addItem(l_rec.state_code, l_rec.state_name)
	END FOREACH
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION hide_field( l_fld STRING, l_lab STRING, l_hide BOOLEAN )
	DEFINE l_f ui.Form
	LET l_f = ui.Window.getCurrent().getForm()
	CALL l_f.setElementHidden(l_lab,l_hide)
	CALL l_f.setFieldHidden(l_fld,l_hide)
	IF l_hide THEN
		CALL l_f.setElementText("hide","Show")
		CALL l_f.setElementImage("hide","fa-user")
	ELSE
		CALL l_f.setElementText("hide","Hide")
		CALL l_f.setElementImage("hide","fa-user-o")
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION set_actions( d ui.Dialog, l_tf BOOLEAN )
	CALL d.setActionActive("next",l_tf)
	CALL d.setActionActive("previous",l_tf)
	CALL d.setActionActive("update",l_tf)
	CALL d.setActionActive("delete",l_tf)
END FUNCTION
--------------------------------------------------------------------------------
