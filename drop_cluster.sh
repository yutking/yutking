#!/bin/sh

/usr/bin/pg_dropcluster --stop 9.4 c01
/usr/bin/pg_dropcluster --stop 9.4 c02
