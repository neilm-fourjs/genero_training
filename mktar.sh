make clean
touch *.4pw
rm -f training.tgz training.zip
tar cvzf training.tgz *.4pw db env.sh etc getGDCcfg makefile mk_db arrays orders query reports/*.4gl reports/*.inc 
zip -ro training.zip *.4pw db env.sh etc getGDCcfg makefile mk_db arrays orders query reports/*.4gl reports/*.inc 
