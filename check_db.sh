#!/bin/sh

/usr/bin/pg_isready -q -p 5433

if [ $? = "0" ]
then
 /bin/echo "database is ok"
else
 /bin/echo "database error. prmote.."
 /usr/bin/pg_ctlcluster 9.4 c02 promote
fi
