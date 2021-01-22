IMPORT FGL fgldialog
IMPORT os
FUNCTION error(l_line SMALLINT, l_mod STRING, l_err STRING)
	DEFINE l_func STRING
	DEFINE x,y SMALLINT
	LET l_func = base.Application.getStackTrace()
	LET x = l_func.getIndexOf("#1",1)
	LET y = l_func.getIndexOf(" ",x+3)
	LET l_func = l_func.subString(x+3,y-1)	
	DISPLAY os.path.baseName(l_mod),":",l_func,":",l_line,":",l_err
	CALL fgldialog.fgl_winMessage("Error",l_err,"exclamation")
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION crashed()
	DEFINE l_func STRING
	DEFINE l_stat, x SMALLINT
	LET l_stat = STATUS
	LET l_func = base.Application.getStackTrace()
	LET x = l_func.getIndexOf("#1",1)
	LET l_func = l_func.subString(x+3, l_func.getLength())
	DISPLAY l_func," Status:", l_stat, ":", ERR_GET(l_stat)
	EXIT PROGRAM 1
END FUNCTION
