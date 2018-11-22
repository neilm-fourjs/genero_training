FUNCTION about()
	DEFINE w ui.Window
	DEFINE f ui.Form
	DEFINE f_n, g_n, d_n	om.DomNode

	OPEN WINDOW a AT 1,1 WITH 1 ROWS, 1 COLUMNS ATTRIBUTES(STYLE="naked")

	LET w = ui.window.getCurrent()
	CALL w.setText("About Window")
	LET f = w.createForm("about")
	LET f_n = f.getNode()

	LET g_n = f_n.createChild("Group")
	CALL g_n.setAttribute("text", "About")
	CALL g_n.setAttribute("name", "form_extension")
	CALL g_n.setAttribute("style","copyright")
	CALL g_n.setAttribute("width", 40)
	CALL g_n.setAttribute("height",10)

	LET d_n = g_n.createChild("Image")
	CALL d_n.setAttribute("posX", 1)
	CALL d_n.setAttribute("posY", 1)
	CALL d_n.setAttribute("image", "getGDCcfg")
	CALL d_n.setAttribute("style","logo")
	CALL d_n.setAttribute("gridWidth", 40)

	LET d_n = g_n.createChild("Label")
	CALL d_n.setAttribute("posX", 1)
	CALL d_n.setAttribute("posY", 2)
	CALL d_n.setAttribute("width", 10)
	CALL d_n.setAttribute("gridWidth", 40)
	CALL d_n.setAttribute("justify", "center")
	CALL d_n.setAttribute("style","copyright")
	CALL d_n.setAttribute("text", "getGDCcfg - Training Exercise V2.00")
	CALL d_n.setAttribute("name", "copyright")

	LET d_n = g_n.createChild("HLine")
	CALL d_n.setAttribute("posY",3)
	CALL d_n.setAttribute("posX",1)
	CALL d_n.setAttribute("gridWidth",40)

	LET d_n = g_n.createChild("Label")
	CALL d_n.setAttribute("posX", 1)
	CALL d_n.setAttribute("posY", 4)
	CALL d_n.setAttribute("width", 10)
	CALL d_n.setAttribute("gridWidth", 40)
	CALL d_n.setAttribute("justify", "center")
	CALL d_n.setAttribute("style","copyright")
	CALL d_n.setAttribute("text", "(c) Copyright Four Js Development Tools")
	CALL d_n.setAttribute("name", "copyright")

	MENU
		ON ACTION CLOSE EXIT MENU
		ON ACTION EXIT EXIT MENU
	END MENU

	CLOSE WINDOW a

END FUNCTION