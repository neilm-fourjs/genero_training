SCHEMA custdemo

FUNCTION display_custarr()
	DEFINE
		cust_arr DYNAMIC ARRAY OF RECORD
			store_num    LIKE customer.store_num,
			store_name   LIKE customer.store_name,
			city         LIKE customer.city,
			state        LIKE customer.state,
			zipcode      LIKE customer.zipcode,
			contact_name LIKE customer.contact_name,
			phone        LIKE customer.phone
		END RECORD,
		cust_rec RECORD
			store_num    LIKE customer.store_num,
			store_name   LIKE customer.store_name,
			city         LIKE customer.city,
			state        LIKE customer.state,
			zipcode      LIKE customer.zipcode,
			contact_name LIKE customer.contact_name,
			phone        LIKE customer.phone
		END RECORD,
		ret_num      LIKE customer.store_num,
		ret_name     LIKE customer.store_name,
		curr_pa, idx SMALLINT

	OPEN WINDOW wcust WITH FORM "manycust"

	DECLARE custlist_curs CURSOR FOR
			SELECT store_num, store_name, city, state, zipcode, contact_name, phone FROM customer ORDER BY store_num

	LET idx = 0
	CALL cust_arr.clear()
	FOREACH custlist_curs INTO cust_rec.*
		LET idx = idx + 1
		LET cust_arr[idx].* = cust_rec.*
	END FOREACH

	LET ret_num  = 0
	LET ret_name = NULL

	IF idx > 0 THEN
		LET int_flag = FALSE
		DISPLAY ARRAY cust_arr TO sa_cust.*
		IF (NOT int_flag) THEN
			LET curr_pa  = arr_curr()
			LET ret_num  = cust_arr[curr_pa].store_num
			LET ret_name = cust_arr[curr_pa].store_name
		END IF
	END IF

	CLOSE WINDOW wcust
	RETURN ret_num, ret_name

END FUNCTION
