--------------------------------------------------------------------------------
-- Program to create user and training tables with data.
--------------------------------------------------------------------------------
IMPORT os

CONSTANT c_quot   = "'"
CONSTANT c_db     = "custdemo"
CONSTANT c_dtefmt = "YYYY-MM-DD"

TYPE t_cust RECORD
	store_num    INTEGER,
	store_name   CHAR(22),
	addr         CHAR(20),
	addr2        CHAR(20),
	city         CHAR(15),
	state        CHAR(2),
	zipcode      CHAR(5),
	contact_name CHAR(30),
	phone        CHAR(18),
	created_on   DATE
END RECORD

MAIN

	DISPLAY "FGLPROFILE=", fgl_getEnv("FGLPROFILE")
	DISPLAY "db driver:", fgl_getResource("dbi.database." || c_db || ".driver")

	CALL mk_db(os.path.join(fgl_getEnv("DBPATH"), c_db || ".db"))

	CALL connect(c_db)

	CALL drop()

	CALL create()

	CALL load()

	CALL chk()

END MAIN
--------------------------------------------------------------------------------
FUNCTION mk_db(l_db STRING)

	IF os.path.exists(l_db) THEN
		RETURN
	END IF

	TRY
		CREATE DATABASE l_db
		DISPLAY "Created ", l_db
	CATCH
		DISPLAY __LINE__, ":", STATUS, ":", SQLERRMESSAGE
		EXIT PROGRAM
	END TRY

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION connect(l_db STRING)

	DISPLAY "Connecting to ", l_db CLIPPED
	TRY
		DATABASE l_db
		DISPLAY "Connected."
	CATCH
		DISPLAY __LINE__, ":", STATUS, ":", SQLERRMESSAGE
		EXIT PROGRAM
	END TRY

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION chk()
	DEFINE cnt SMALLINT

	LET cnt = NULL
	SELECT COUNT(*) INTO cnt FROM customer
	DISPLAY 'Customers:', cnt

	LET cnt = NULL
	SELECT COUNT(*) INTO cnt FROM orders
	DISPLAY 'Orders   :', cnt

	LET cnt = NULL
	SELECT COUNT(*) INTO cnt FROM factory
	DISPLAY 'Factorys :', cnt

	LET cnt = NULL
	SELECT COUNT(*) INTO cnt FROM stock
	DISPLAY 'Stock    :', cnt

	LET cnt = NULL
	SELECT COUNT(*) INTO cnt FROM stock_cat
	DISPLAY 'Stock Cat:', cnt

	LET cnt = NULL
	SELECT COUNT(*) INTO cnt FROM items
	DISPLAY 'Items    :', cnt

	LET cnt = NULL
	SELECT COUNT(*) INTO cnt FROM state
	DISPLAY 'States   :', cnt

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION drop()

	DISPLAY 'Dropping tables...'
	CALL do_it('DROP TABLE customer');
	CALL do_it('DROP TABLE orders');
	CALL do_it('DROP TABLE factory');
	CALL do_it('DROP TABLE stock');
	CALL do_it('DROP TABLE stock_cat');
	CALL do_it('DROP TABLE items');
	CALL do_it('DROP TABLE state');

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION create()

	DISPLAY 'Creating tables...'
	CALL do_it('
	CREATE TABLE customer(
	    store_num     INTEGER NOT NULL,
	    store_name    CHAR(22) NOT NULL,
	    addr          CHAR(20),
	    addr2         CHAR(20),
	    city          CHAR(15),
	    state         CHAR(2),
	    zipcode       CHAR(5),
	    contact_name  CHAR(30),
	    phone         CHAR(18), 
	    created_on    DATE,
	    PRIMARY KEY (store_num)
	);')

	CALL do_it('CREATE TABLE orders(
	    order_num     INTEGER NOT NULL,
	    order_date    DATE NOT NULL,
	    store_num     INTEGER NOT NULL,
	    fac_code      CHAR(3),
	    ship_instr    CHAR(10),
	    promo         CHAR(1) NOT NULL,    
	    PRIMARY KEY (order_num)
	);')

	CALL do_it('CREATE TABLE factory(
	    fac_code      CHAR(3) NOT NULL,
	    fac_name      CHAR(15) NOT NULL,
	    PRIMARY KEY (fac_code)
	);')

	CALL do_it('CREATE TABLE stock(
	    stock_num     INTEGER NOT NULL,
			stock_cat			CHAR(2) NOT NULL,
	    fac_code      CHAR(3) NOT NULL,
	    description   CHAR(15) NOT NULL,
	    reg_price     DECIMAL(8,2) NOT NULL,
	    promo_price   DECIMAL(8,2),
	    price_updated DATE,
	    unit          CHAR(4) NOT NULL,
	    PRIMARY KEY (stock_num, fac_code)
	);')

	CALL do_it('CREATE TABLE stock_cat(
	    stock_cat     CHAR(2) NOT NULL,
	    description		CHAR(40) NOT NULL,
	    PRIMARY KEY (stock_cat)
	);')

	CALL do_it('CREATE TABLE items(
	    order_num     INTEGER NOT NULL,
	    stock_num     INTEGER NOT NULL,
	    quantity      SMALLINT NOT NULL,
	    price         DECIMAL(8,2) NOT NULL,
	    PRIMARY KEY (order_num, stock_num)
	);')

	CALL do_it('CREATE TABLE state(
	    state_code CHAR(2) NOT NULL,
	    state_name CHAR(15) NOT NULL,
	    PRIMARY KEY (state_code)
	);')

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION load()
	DEFINE l_cust t_cust
	DEFINE l_dte  DATE

	DISPLAY 'Loading data...'

	CALL do_it('DELETE FROM items;')
	CALL do_it('DELETE FROM orders;')
	CALL do_it('DELETE FROM stock;')
	CALL do_it('DELETE FROM stock_cat;')
	CALL do_it('DELETE FROM factory;')
	CALL do_it('DELETE FROM customer;')
	CALL do_it('DELETE FROM state;')

	CALL do_it(
			"INSERT INTO customer VALUES(101," || c_quot || "Bandys Hardware" || c_quot || "," || c_quot || "110 Main"
					|| c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Chicago" || c_quot || "," || c_quot || "IL"
					|| c_quot || "," || c_quot || "60068" || c_quot || "," || c_quot || "Bob Bandy" || c_quot || "," || c_quot
					|| "630-221-9055" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(102," || c_quot || "The FIX-IT Shop" || c_quot || "," || c_quot
					|| "65W Elm Street Sqr." || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Madison" || c_quot
					|| "," || c_quot || "WI" || c_quot || "," || c_quot || "65454" || c_quot || "," || c_quot || " " || c_quot
					|| "," || c_quot || "630-34343434" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(103," || c_quot || "Hills Hobby Shop" || c_quot || "," || c_quot
					|| "553 Central Parkway" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Eau Claire"
					|| c_quot || "," || c_quot || "WI" || c_quot || "," || c_quot || "54354" || c_quot || "," || c_quot
					|| "Janice Hilstrom" || c_quot || "," || c_quot || "666-4564564" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(104," || c_quot || "Illinois Hardware" || c_quot || "," || c_quot
					|| "123 Main Street" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Peoria" || c_quot || ","
					|| c_quot || "IL" || c_quot || "," || c_quot || "63434" || c_quot || "," || c_quot || "Ramon Aguirra"
					|| c_quot || "," || c_quot || "630-3434334" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(105," || c_quot || "Tools and Stuff" || c_quot || "," || c_quot
					|| "645W Center Street" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Dubuque" || c_quot
					|| "," || c_quot || "IA" || c_quot || "," || c_quot || "54654" || c_quot || "," || c_quot
					|| "Lavonne Robinson" || c_quot || "," || c_quot || "630-4533456" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(106," || c_quot || "TrueTest Hardware" || c_quot || "," || c_quot
					|| "6123 N. Michigan Ave" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Chicago" || c_quot
					|| "," || c_quot || "IL" || c_quot || "," || c_quot || "60104" || c_quot || "," || c_quot
					|| "Michael Mazukelli" || c_quot || "," || c_quot || "640-3453456" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(209," || c_quot || "2nd FIX-IT Shop" || c_quot || "," || c_quot
					|| "65W Elm Street Sqr." || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Madison" || c_quot
					|| "," || c_quot || "WI" || c_quot || "," || c_quot || "65454" || c_quot || "," || c_quot || " " || c_quot
					|| "," || c_quot || "630-34343434" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(203," || c_quot || "2nd Hobby Shop" || c_quot || "," || c_quot
					|| "553 Central Parkway" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Eau Claire"
					|| c_quot || "," || c_quot || "WI" || c_quot || "," || c_quot || "54354" || c_quot || "," || c_quot
					|| "Janice Hilstrom" || c_quot || "," || c_quot || "666-4564564" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(204," || c_quot || "2nd Hardware" || c_quot || "," || c_quot || "123 Main Street"
					|| c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Peoria" || c_quot || "," || c_quot || "IL"
					|| c_quot || "," || c_quot || "63434" || c_quot || "," || c_quot || "Ramon Aguirra" || c_quot || "," || c_quot
					|| "630-3434334" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(205," || c_quot || "2nd Stuff" || c_quot || "," || c_quot || "645W Center Street"
					|| c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Dubuque" || c_quot || "," || c_quot || "IA"
					|| c_quot || "," || c_quot || "54654" || c_quot || "," || c_quot || "Lavonne Robinson" || c_quot || ","
					|| c_quot || "630-4533456" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(206," || c_quot || "2ndTest Hardware" || c_quot || "," || c_quot
					|| "6123 N. Michigan Ave" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Chicago" || c_quot
					|| "," || c_quot || "IL" || c_quot || "," || c_quot || "60104" || c_quot || "," || c_quot
					|| "Michael Mazukelli" || c_quot || "," || c_quot || "640-3453456" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(309," || c_quot || "Thirds Hardware" || c_quot || "," || c_quot || "110 Main"
					|| c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Chicago" || c_quot || "," || c_quot || "IL"
					|| c_quot || "," || c_quot || "60068" || c_quot || "," || c_quot || "Bob Bandy" || c_quot || "," || c_quot
					|| "630-221-9055" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(302," || c_quot || "Third FIX-IT Shop" || c_quot || "," || c_quot
					|| "65W Elm Street Sqr." || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Madison" || c_quot
					|| "," || c_quot || "WI" || c_quot || "," || c_quot || "65454" || c_quot || "," || c_quot || " " || c_quot
					|| "," || c_quot || "630-34343434" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(303," || c_quot || "Third Hobby Shop" || c_quot || "," || c_quot
					|| "553 Central Parkway" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Eau Claire"
					|| c_quot || "," || c_quot || "WI" || c_quot || "," || c_quot || "54354" || c_quot || "," || c_quot
					|| "Janice Hilstrom" || c_quot || "," || c_quot || "666-4564564" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(304," || c_quot || "Third Ill Hardware" || c_quot || "," || c_quot
					|| "123 Main Street" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Peoria" || c_quot || ","
					|| c_quot || "IL" || c_quot || "," || c_quot || "63434" || c_quot || "," || c_quot || "Ramon Aguirra"
					|| c_quot || "," || c_quot || "630-3434334" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(305," || c_quot || "Third and Stuff" || c_quot || "," || c_quot
					|| "645W Center Street" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Dubuque" || c_quot
					|| "," || c_quot || "IA" || c_quot || "," || c_quot || "54654" || c_quot || "," || c_quot
					|| "Lavonne Robinson" || c_quot || "," || c_quot || "630-4533456" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(306," || c_quot || "Third Hardware" || c_quot || "," || c_quot
					|| "6123 N. Michigan Ave" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Chicago" || c_quot
					|| "," || c_quot || "IL" || c_quot || "," || c_quot || "60104" || c_quot || "," || c_quot
					|| "Michael Mazukelli" || c_quot || "," || c_quot || "640-3453456" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(409," || c_quot || "Fourth  Hardware" || c_quot || "," || c_quot || "110 Main"
					|| c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Chicago" || c_quot || "," || c_quot || "IL"
					|| c_quot || "," || c_quot || "60068" || c_quot || "," || c_quot || "Bob Bandy" || c_quot || "," || c_quot
					|| "630-221-9055" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(402," || c_quot || "Fourth FIX-IT Shop" || c_quot || "," || c_quot
					|| "65W Elm Street Sqr." || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Madison" || c_quot
					|| "," || c_quot || "WI" || c_quot || "," || c_quot || "65454" || c_quot || "," || c_quot || " " || c_quot
					|| "," || c_quot || "630-34343434" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(403," || c_quot || "Fourth Hobby Shop" || c_quot || "," || c_quot
					|| "553 Central Parkway" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Eau Claire"
					|| c_quot || "," || c_quot || "WI" || c_quot || "," || c_quot || "54354" || c_quot || "," || c_quot
					|| "Janice Hilstrom" || c_quot || "," || c_quot || "666-4564564" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(404," || c_quot || "Fourth Tools" || c_quot || "," || c_quot || "123 Main Street"
					|| c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Peoria" || c_quot || "," || c_quot || "IL"
					|| c_quot || "," || c_quot || "63434" || c_quot || "," || c_quot || "Ramon Aguirra" || c_quot || "," || c_quot
					|| "630-3434334" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(405," || c_quot || "Fourth and Stuff" || c_quot || "," || c_quot
					|| "645W Center Street" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Dubuque" || c_quot
					|| "," || c_quot || "IA" || c_quot || "," || c_quot || "54654" || c_quot || "," || c_quot
					|| "Lavonne Robinson" || c_quot || "," || c_quot || "630-4533456" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(406," || c_quot || "Fourth Ill Hardware" || c_quot || "," || c_quot
					|| "6123 N. Michigan Ave" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Chicago" || c_quot
					|| "," || c_quot || "IL" || c_quot || "," || c_quot || "60104" || c_quot || "," || c_quot
					|| "Michael Mazukelli" || c_quot || "," || c_quot || "640-3453456" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(509," || c_quot || "Fifth  Hardware" || c_quot || "," || c_quot || "110 Main"
					|| c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Chicago" || c_quot || "," || c_quot || "IL"
					|| c_quot || "," || c_quot || "60068" || c_quot || "," || c_quot || "Bob Bandy" || c_quot || "," || c_quot
					|| "630-221-9055" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(502," || c_quot || "Fifth FIX-IT Shop" || c_quot || "," || c_quot
					|| "65W Elm Street Sqr." || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Madison" || c_quot
					|| "," || c_quot || "WI" || c_quot || "," || c_quot || "65454" || c_quot || "," || c_quot || " " || c_quot
					|| "," || c_quot || "630-34343434" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(503," || c_quot || "Fifth Hobby Shop" || c_quot || "," || c_quot
					|| "553 Central Parkway" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Eau Claire"
					|| c_quot || "," || c_quot || "WI" || c_quot || "," || c_quot || "54354" || c_quot || "," || c_quot
					|| "Janice Hilstrom" || c_quot || "," || c_quot || "666-4564564" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(504," || c_quot || "Fifth Ill Hardware" || c_quot || "," || c_quot
					|| "123 Main Street" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Peoria" || c_quot || ","
					|| c_quot || "IL" || c_quot || "," || c_quot || "63434" || c_quot || "," || c_quot || "Ramon Aguirra"
					|| c_quot || "," || c_quot || "630-3434334" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(505," || c_quot || "Ill Tools and Stuff" || c_quot || "," || c_quot
					|| "645W Center Street" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Dubuque" || c_quot
					|| "," || c_quot || "IA" || c_quot || "," || c_quot || "54654" || c_quot || "," || c_quot
					|| "Lavonne Robinson" || c_quot || "," || c_quot || "630-4533456" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(506," || c_quot || "Ill TrueTest Hardware" || c_quot || "," || c_quot
					|| "6123 N. Michigan Ave" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Chicago" || c_quot
					|| "," || c_quot || "IL" || c_quot || "," || c_quot || "60104" || c_quot || "," || c_quot
					|| "Michael Mazukelli" || c_quot || "," || c_quot || "640-3453456" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(609," || c_quot || "Sixth Hardware" || c_quot || "," || c_quot || "110 Main"
					|| c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Chicago" || c_quot || "," || c_quot || "IL"
					|| c_quot || "," || c_quot || "60068" || c_quot || "," || c_quot || "Bob Bandy" || c_quot || "," || c_quot
					|| "630-221-9055" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(602," || c_quot || "Sixth FIX-IT Shop" || c_quot || "," || c_quot
					|| "65W Elm Street Sqr." || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Madison" || c_quot
					|| "," || c_quot || "WI" || c_quot || "," || c_quot || "65454" || c_quot || "," || c_quot || " " || c_quot
					|| "," || c_quot || "630-34343434" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(603," || c_quot || "Sixth Hobby Shop" || c_quot || "," || c_quot
					|| "553 Central Parkway" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Eau Claire"
					|| c_quot || "," || c_quot || "WI" || c_quot || "," || c_quot || "54354" || c_quot || "," || c_quot
					|| "Janice Hilstrom" || c_quot || "," || c_quot || "666-4564564" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(604," || c_quot || "Sixth Ill Hardware" || c_quot || "," || c_quot
					|| "123 Main Street" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Peoria" || c_quot || ","
					|| c_quot || "IL" || c_quot || "," || c_quot || "63434" || c_quot || "," || c_quot || "Ramon Aguirra"
					|| c_quot || "," || c_quot || "630-3434334" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(605," || c_quot || "6th Tools" || c_quot || "," || c_quot || "645W Center Street"
					|| c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Dubuque" || c_quot || "," || c_quot || "IA"
					|| c_quot || "," || c_quot || "54654" || c_quot || "," || c_quot || "Lavonne Robinson" || c_quot || ","
					|| c_quot || "630-4533456" || c_quot || ",NULL);")
	CALL do_it(
			"INSERT INTO customer VALUES(606," || c_quot || "TrueTest Hardware" || c_quot || "," || c_quot
					|| "6123 N. Michigan Ave" || c_quot || "," || c_quot || " " || c_quot || "," || c_quot || "Chicago" || c_quot
					|| "," || c_quot || "IL" || c_quot || "," || c_quot || "60104" || c_quot || "," || c_quot
					|| "Michael Mazukelli" || c_quot || "," || c_quot || "640-3453456" || c_quot || ",NULL);")

	BEGIN WORK
	DECLARE c_cur CURSOR FOR SELECT * FROM customer
	FOREACH c_cur INTO l_cust.*
		LET l_dte = TODAY - l_cust.store_num
		UPDATE customer SET created_on = l_dte WHERE store_num = l_cust.store_num
	END FOREACH
	COMMIT WORK

	LET l_dte = TODAY
	CALL do_it(
			"INSERT INTO orders VALUES(1," || c_quot || (l_dte USING c_dtefmt) || c_quot || ",103," || c_quot || "ASC"
					|| c_quot || "," || c_quot || "FEDEX" || c_quot || "," || c_quot || "N" || c_quot || ");")
	CALL do_it(
			"INSERT INTO orders VALUES(2," || c_quot || (l_dte USING c_dtefmt) || c_quot || ",103," || c_quot || "ASC"
					|| c_quot || "," || c_quot || "FEDEX" || c_quot || "," || c_quot || "Y" || c_quot || ");")

	CALL do_it("INSERT INTO items VALUES(1,456,10,5.55);")
	CALL do_it("INSERT INTO items VALUES(1,310,5,12.85);")
	CALL do_it("INSERT INTO items VALUES(1,744,60,250.95);")
	CALL do_it("INSERT INTO items VALUES(2,456,15,5.55);")
	CALL do_it("INSERT INTO items VALUES(2,310,2,12.85);")

	LET l_dte = TODAY
	CALL do_it(
			"INSERT INTO stock VALUES(456," || c_quot || "AA" || c_quot || "," || c_quot || "ASC" || c_quot || "," || c_quot
					|| "lightbulbs" || c_quot || ",5.55,5.0," || c_quot || (l_dte USING c_dtefmt) || c_quot || "," || c_quot
					|| "ctn" || c_quot || ");")
	CALL do_it(
			"INSERT INTO stock VALUES(310," || c_quot || "BB" || c_quot || "," || c_quot || "ASC" || c_quot || "," || c_quot
					|| "sink stoppers" || c_quot || ",12.85,11.57," || c_quot || (l_dte USING c_dtefmt) || c_quot || "," || c_quot
					|| "grss" || c_quot || ");")
	CALL do_it(
			"INSERT INTO stock VALUES(744," || c_quot || "BB" || c_quot || "," || c_quot || "ASC" || c_quot || "," || c_quot
					|| "faucets" || c_quot || ",250.95,225.86," || c_quot || (l_dte USING c_dtefmt) || c_quot || "," || c_quot
					|| "6/bx" || c_quot || ");")

	CALL do_it(
			"INSERT INTO stock_cat VALUES(" || c_quot || "AA" || c_quot || "," || c_quot || "Household" || c_quot || ");")
	CALL do_it(
			"INSERT INTO stock_cat VALUES(" || c_quot || "BB" || c_quot || "," || c_quot || "Plumming" || c_quot || ");")

	CALL do_it(
			"INSERT INTO factory VALUES(" || c_quot || "ASC" || c_quot || "," || c_quot || "Assoc. Std. Co." || c_quot
					|| ");")
	CALL do_it(
			"INSERT INTO factory VALUES(" || c_quot || "PHL" || c_quot || "," || c_quot || "Phelps Lighting" || c_quot
					|| ");")

	LOAD FROM "states.unl" INSERT INTO state

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION do_it(l_stmt STRING)

	DISPLAY "Stmt:", l_stmt CLIPPED
	TRY
		PREPARE pre1 FROM l_stmt
		EXECUTE pre1
	CATCH
		DISPLAY "Failed! ", STATUS, ":", SQLERRMESSAGE
	END TRY

END FUNCTION
