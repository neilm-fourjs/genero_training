-- custquery.4gl

SCHEMA custdemo

DEFINE mr_custrec, work_custrec RECORD LIKE customer.*
--------------------------------------------------------------------------------
FUNCTION query_cust()
	DEFINE cont_ok SMALLINT,
				cust_cnt SMALLINT,
				where_clause STRING

	MESSAGE "Enter search criteria"
	LET cont_ok = FALSE
	LET int_flag = FALSE
	
	CONSTRUCT BY NAME where_clause ON customer.*
	IF int_flag THEN
		LET int_flag=FALSE
		CLEAR FORM
		LET cont_ok = FALSE
		MESSAGE "Cancelled by user."
	ELSE
		CALL get_cust_cnt(where_clause) RETURNING cust_cnt
		IF cust_cnt > 0 THEN
			MESSAGE cust_cnt using "<<<<", " rows found."
			CALL cust_select(where_clause) RETURNING cont_ok
		ELSE
			MESSAGE "No rows found."
			LET cont_ok = FALSE		
		END IF
	END IF
 
	IF cont_ok THEN
		CALL display_cust()
	END IF
		
	RETURN cont_ok
 
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION get_cust_cnt(p_where_clause)
	DEFINE p_where_clause STRING,
				sql_text				STRING,
				cust_cnt				SMALLINT
	
	LET sql_text = "SELECT COUNT(*) FROM customer " ||
			" WHERE " || p_where_clause
	
	TRY
		PREPARE cust_cnt_stmt FROM sql_text
		EXECUTE cust_cnt_stmt INTO cust_cnt
		FREE cust_cnt_stmt
	CATCH
		LET cust_cnt = 0
		ERROR SQLERRMESSAGE
	END TRY
	
	RETURN cust_cnt
	
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION cust_select(p_where_clause) 
	DEFINE p_where_clause STRING,
				sql_text				STRING,
				fetch_ok				SMALLINT
 
	LET sql_text = "SELECT * FROM customer " ||
				" WHERE " || p_where_clause

	DECLARE cust_curs SCROLL CURSOR WITH HOLD FROM sql_text
	
	OPEN cust_curs
	CALL fetch_cust(1)				--fetch the first row
		RETURNING fetch_ok
	IF NOT (fetch_ok) THEN
		MESSAGE "no rows in table."	-- someone deleted the rows after we checked the count
	END IF
			
	RETURN fetch_ok
 
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION fetch_cust(p_fetch_flag)
	DEFINE p_fetch_flag SMALLINT,
				fetch_ok		SMALLINT
				
	LET fetch_ok = TRUE

	IF p_fetch_flag = 1 THEN
		FETCH NEXT cust_curs INTO mr_custrec.*
	ELSE
		FETCH PREVIOUS cust_curs INTO mr_custrec.*
	END IF
	
	CASE
		WHEN (SQLCA.SQLCODE = 0)
			LET fetch_ok = TRUE
		WHEN (SQLCA.SQLCODE = NOTFOUND)
			LET fetch_ok = FALSE
		WHEN (SQLCA.SQLCODE < 0)
			LET fetch_ok = FALSE
			MESSAGE " Error ", SQLCA.SQLCODE USING "<<<<"
	END CASE
	
	RETURN fetch_ok
	
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION fetch_rel_cust(p_fetch_flag)
	DEFINE p_fetch_flag SMALLINT,
				fetch_ok		SMALLINT
	
	MESSAGE " "
	CALL fetch_cust(p_fetch_flag) RETURNING fetch_ok
		
	IF fetch_ok THEN
		CALL display_cust()
	ELSE
		IF p_fetch_flag = 1 THEN
			MESSAGE "End of list"
		ELSE
			MESSAGE "Beginning of list"
		END IF
	END IF
		
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION display_cust()
	DISPLAY BY NAME mr_custrec.*
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION inpupd_cust(au_flag)
	DEFINE au_flag CHAR(1),
				cont_ok SMALLINT
				
	INITIALIZE work_custrec.* TO NULL
	LET cont_ok = TRUE 
	
	IF au_flag = "A" THEN
		MESSAGE "Add a new customer "
		LET work_custrec.created_on = TODAY
		LET mr_custrec.* = work_custrec.*
	ELSE
		MESSAGE "Update customer"
		LET work_custrec.* = mr_custrec.*
	END IF
	
	LET int_flag = FALSE
	
	INPUT BY NAME mr_custrec.*
			WITHOUT DEFAULTS ATTRIBUTE(UNBUFFERED) 
	
		BEFORE FIELD store_num
			IF au_flag = "U" THEN
					NEXT FIELD store_name
			END IF
	
		ON CHANGE store_num
			IF au_flag = "A" THEN
				SELECT *
						INTO mr_custrec.*
						FROM customer 
						WHERE store_num = mr_custrec.store_num
					IF SQLCA.SQLCODE = 0 THEN
						ERROR "Store number already in database."
						LET cont_ok = FALSE
						CALL display_cust()
						EXIT INPUT
					END IF
			END IF

		AFTER FIELD store_name
			IF mr_custrec.store_name IS NULL THEN
				ERROR "You must enter a company name."
				NEXT FIELD store_name
			END IF 
		
	END INPUT
 
	IF int_flag THEN
		LET int_flag = FALSE
		LET cont_ok = FALSE
		MESSAGE "Operation cancelled by user." 
		LET mr_custrec.* = work_custrec.* 
	END IF
			
	RETURN cont_ok
	
END FUNCTION
-------------------------------------------------------------------------------- 
FUNCTION insert_cust()
	TRY
		INSERT INTO customer VALUES (mr_custrec.*)
		MESSAGE "Row added"
	CATCH
		ERROR SQLERRMESSAGE
	END TRY
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION update_cust()
	DEFINE l_custrec RECORD LIKE customer.*,
		matches INTEGER,
		cont_ok INTEGER
		
	LET matches = FALSE
	LET cont_ok = FALSE
			
	BEGIN WORK

	SELECT * INTO l_custrec.* FROM customer 
		WHERE store_num = mr_custrec.store_num

	IF SQLCA.SQLCODE = NOTFOUND THEN
			ERROR "Store has been deleted"
			LET cont_ok = FALSE
	ELSE
		IF l_custrec.* = work_custrec.* THEN
			LET matches = TRUE
		ELSE
			LET matches = FALSE
		END IF

		IF matches = TRUE THEN		
			TRY
				UPDATE customer SET
					store_name = mr_custrec.store_name,
					addr = mr_custrec.addr,
					addr2 = mr_custrec.addr2,
					city = mr_custrec.city,
					state = mr_custrec.state,
					zipcode = mr_custrec.zipcode,
					contact_name = mr_custrec.contact_name,
					phone = mr_custrec.phone,
					created_on = mr_custrec.created_on
				WHERE store_num = mr_custrec.store_num
				LET cont_ok = TRUE
				MESSAGE "Row updated"
			CATCH
				LET cont_ok = FALSE
				ERROR SQLERRMESSAGE
			END TRY
		ELSE
			LET cont_ok = FALSE
			LET mr_custrec.* = l_custrec.*		-- replace with latest values retrieved
			DISPLAY BY NAME mr_custrec.*				-- remove this for UNBUFFERED
			MESSAGE "Row updated by another user."
		END IF
	END IF
		
	IF cont_ok THEN
		COMMIT WORK
	ELSE
		ROLLBACK WORK
	END IF

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION delete_cust()
	
	TRY
		DELETE FROM customer WHERE store_num = mr_custrec.store_num
		MESSAGE "Row deleted"
		INITIALIZE mr_custrec.* TO NULL
		DISPLAY BY NAME mr_custrec.* 
	CATCH
		ERROR SQLERRMESSAGE
	END TRY
 
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION delete_check()
	DEFINE del_ok SMALLINT,
				del_count SMALLINT
	
	LET del_ok = FALSE
		
	SELECT COUNT(*) INTO del_count FROM orders
		WHERE orders.store_num = mr_custrec.store_num
	
	IF del_count > 0 THEN
		MESSAGE "Store has orders and cannot be deleted"
		LET del_ok = FALSE
	ELSE
		MENU "Delete" ATTRIBUTE ( STYLE="dialog", COMMENT="Delete the row?", IMAGE="question" )
			COMMAND "Yes"
				LET del_ok = TRUE
			COMMAND "No"
				MESSAGE "Delete canceled"
				EXIT MENU
		END MENU
	END IF

	RETURN del_ok

END FUNCTION
--------------------------------------------------------------------------------
