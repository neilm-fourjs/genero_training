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
