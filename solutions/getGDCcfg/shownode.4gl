IMPORT FGL pretty_lab

FUNCTION shownode( n om.domNode )
	DEFINE w ui.Window
	DEFINE f ui.Form
	DEFINE g,l,fn,dn om.domNode
	DEFINE x SMALLINT
	DEFINE lab, val STRING
	
	OPEN WINDOW show_node AT 1,1 WITH 10 ROWS, 20 COLUMNS ATTRIBUTE(STYLE="dialog")
	LET w = ui.window.getCurrent()
	CALL w.setText("Dynamically Show An XML Node.")
	LET f = w.createForm("shownode")
	LET g = f.getNode()
	LET g = g.createChild("Grid")
	
	FOR x = 1 TO n.getAttributesCount()
		LET l = g.createChild("Label")
		LET lab = pretty_lab.pretty_lab( n.getAttributeName(x) )
		CALL l.setAttribute("text", lab )
		CALL l.setAttribute("posX", 1 )
		CALL l.setAttribute("posY", x )
		CALL l.setAttribute("style", "bold" )

		LET val = n.getAttributeValue(x)
		LET fn = g.createChild("FormField")
		CALL fn.setAttribute("colName", "fld"||x )
		CALL fn.setAttribute("value", val )
		LET dn = fn.createChild("Edit")
		CALL dn.setAttribute("posX", 20 )
		CALL dn.setAttribute("posY", x )
		CALL dn.setAttribute("width", val.getLength() )
		CALL dn.setAttribute("gridWidth", val.getLength() )
		CALL dn.setAttribute("style", "special" )
	END FOR	

	MENU 
		COMMAND "Finish"	EXIT MENU
		ON ACTION CLOSE EXIT MENU
	END MENU
	CLOSE WINDOW show_node
END FUNCTION