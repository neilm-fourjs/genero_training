
--------------------------------------------------------------------------------
#+ Upshift 1st letter : replace _ with space : split capitalised names
#+
#+ @param l_lab Label to make pretty
#+ @returns string of pretty label
FUNCTION pretty_lab( l_lab CHAR(60) ) RETURNS STRING
	DEFINE l_ret STRING
	DEFINE x,l_len SMALLINT

	LET l_len = LENGTH( l_lab )

	FOR x = 2 TO l_len

-- Look for camel case and add a space
		IF l_lab[x] >= "A" AND l_lab[x] <= "Z" THEN 
			LET l_lab = l_lab[1,x-1]||" "||l_lab[x,60]
			LET l_len = l_len + 1
			LET x = x + 1
		END IF

		IF l_lab[x] = "_" THEN LET l_lab[x] = " " END IF
	END FOR
	LET l_lab[1] = UPSHIFT(l_lab[1])

	LET l_ret = l_lab CLIPPED,":"
	RETURN l_ret
END FUNCTION
