SCHEMA custdemo

MAIN
DEFINE store_num  LIKE customer.store_num,
       store_name LIKE customer.store_name 

  DEFER INTERRUPT
  CONNECT TO "custdemo"

--  CLOSE WINDOW SCREEN
  CALL display_custarr()
     RETURNING store_num, store_name
  DISPLAY store_num, store_name

  DISCONNECT CURRENT

END MAIN

