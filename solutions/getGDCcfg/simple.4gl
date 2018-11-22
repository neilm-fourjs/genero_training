MAIN
	DEFINE l_file STRING
	DEFINE dd om.domDocument
	DEFINE dn om.domNode
	DEFINE nl om.nodeList
	DEFINE x SMALLINT
	CALL winopenfile("../etc","Config","*.xml",%"GDC Config File") RETURNING l_file
	CALL fgl_getFile(l_file, "simple.xml")
	LET dd = om.DomDocument.createFromXmlFile( l_file )	
	LET dn = dd.getDocumentElement()
	LET nl = dn.selectByTagName("Shortcut")
	FOR x = 1 TO nl.getLength()
		LET dn = nl.item(x)
		DISPLAY "Name:",dn.getAttribute("name")
	END FOR
END MAIN
