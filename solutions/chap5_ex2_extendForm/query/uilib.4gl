SCHEMA custdemo
--------------------------------------------------------------------------------
FUNCTION ui_init()
	CALL ui.form.setDefaultInitializer("form_init")
	CALL ui.Interface.loadStartMenu("mystartmenu")
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION form_init( l_f ui.Form )
	CALL l_f.loadToolBar("mytoolbar")
	CALL l_f.loadTopMenu("mytopmenu")
	CALL extend_form(l_f.getNode())
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
FUNCTION change_labels(l_col STRING)
	DEFINE l_nl om.nodeList
	DEFINE x SMALLINT
	DEFINE l_str STRING
	LET l_nl = ui.window.getCurrent().getNode().selectByTagName("Label")
	FOR x = 1 TO l_nl.getLength()
		CALL l_nl.item(x).setAttribute("color",l_col)
		LET l_str = l_nl.item(x).getAttribute("text")
		CALL l_nl.item(x).setAttribute("text",IIF(l_col="darkred",l_str.toUpperCase(),l_str.toLowerCase()))
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
-- Add a new group to the VBOX of the current passed form.
--
-- @param l_form Dom Node of the form object.
FUNCTION extend_form(l_form om.DomNode)
	DEFINE l_box	om.DomNode
  LET l_box = l_form.getFirstChild()
  WHILE l_box IS NOT NULL -- Find the VBOX
    IF l_box.getTagName() MATCHES "[VH]Box" THEN
      EXIT WHILE
    END IF
    LET l_box = l_box.getNext()
  END WHILE
	IF l_box IS NULL THEN RETURN END IF -- can't extend, so bail!
	LET l_box = l_box.createChild("Group") -- New Group
	CALL l_box.setAttribute("text","Extension:")
	CALL l_box.setAttribute("style","ext")
	LET l_box = l_box.createChild("Label") -- New Label
	CALL l_box.setAttribute("text","Copyright Neil.J.Martin 2018")
	CALL l_box.setAttribute("width","80")
	CALL l_box.setAttribute("justify","center")
END FUNCTION