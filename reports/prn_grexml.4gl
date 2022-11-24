-- Arg #1: .xml data file
-- Arg #2: .4rp report design
MAIN
	DEFINE l_myHandler om.SaxDocumentHandler
	IF NOT fgl_report_loadCurrentSettings(ARG_VAL(2)) THEN
	END IF
	CALL fgl_report_selectDevice("SVG")
	CALL fgl_report_selectPreview(TRUE)
	LET l_myHandler = fgl_report_commitCurrentSettings()
	IF NOT fgl_report_runReportFromProcessLevelDataFile(l_myHandler, ARG_VAL(1)) THEN
	END IF
END MAIN
