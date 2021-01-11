
BASE=$( pwd )
export FGLRESOURCEPATH=$BASE/etc
export FGLPROFILE=$BASE/etc/fglprofile
if [ -e $FGLDIR/etc/lic.dev ]; then
	export FGLPROFILE=$FGLPROFILE:$FGLDIR/etc/lic.dev
fi
if [ -e $FGLDIR/etc/fglprofile.dev ]; then
	export FGLPROFILE=$FGLPROFILE:$FGLDIR/etc/fglprofile.dev
fi
export DBDATE=DMY4/
export DBPATH=$BASE/db
export FGLDBPATH=$BASE/etc
export FGLLDPATH=$BASE/bin
export FGLSQLDEBUG=0
