#!/bin/sh

/bin/mkdir /home/testdb/archivedir
/bin/chown postgres.postgres /home/testdb/archivedir

/usr/bin/pg_createcluster 9.4 c01 -d /home/testdb/db01 -p 5433
/usr/bin/pg_createcluster 9.4 c02 -d /home/testdb/db02 -p 5434

/bin/sed -i "s/#hot_standby = off/hot_standby = on/g" /etc/postgresql/9.4/c01/postgresql.conf
/bin/sed -i "s/#wal_level = minimal/wal_level = hot_standby/g" /etc/postgresql/9.4/c01/postgresql.conf
/bin/sed -i "s/#archive_mode = off/archive_mode = on/g" /etc/postgresql/9.4/c01/postgresql.conf
/bin/sed -i "s/#archive_command = ''/archive_command = 'cp %p \/home\/testdb\/archivedir\/%f'/g" /etc/postgresql/9.4/c01/postgresql.conf
/bin/sed -i "s/#max_wal_senders = 0/max_wal_senders = 2/g" /etc/postgresql/9.4/c01/postgresql.conf
/bin/sed -i  "s/local   all             all                                     peer/local   all             all                                     trust/g" /etc/postgresql/9.4/c01/pg_hba.conf
/bin/sed -i  "s/host    all             all             127.0.0.1\/32            md5/host    all             all             127.0.0.1\/32            trust/g" /etc/postgresql/9.4/c01/pg_hba.conf
/bin/sed -i  "s/#host    replication     postgres        127.0.0.1\/32            md5/host    replication     postgres        127.0.0.1\/32            trust/g" /etc/postgresql/9.4/c01/pg_hba.conf

/bin/sed -i "s/#hot_standby = off/hot_standby = on/g" /etc/postgresql/9.4/c02/postgresql.conf
/bin/sed -i  "s/local   all             all                                     peer/local   all             all                                     trust/g" /etc/postgresql/9.4/c02/pg_hba.conf
/bin/sed -i  "s/host    all             all             127.0.0.1\/32            md5/host    all             all             127.0.0.1\/32            trust/g" /etc/postgresql/9.4/c02/pg_hba.conf

/usr/bin/pg_ctlcluster 9.4 c01 start
/bin/rm -rf /home/testdb/db02/*
/bin/su - postgres -c '/usr/bin/pg_basebackup -h 127.0.0.1 -U postgres -p 5433 -D /home/testdb/db02/ --write-recovery-conf'

/usr/bin/pg_ctlcluster 9.4 c02 start
/bin/sleep 10

/usr/bin/psql -U postgres -h 127.0.0.1 -p 5433 -c 'create table x as select random() from generate_series (1,1000000);'
/bin/echo claster created. sleeping 10s and check replecation..
/bin/sleep 10
/usr/bin/psql -U postgres -h 127.0.0.1 -p 5434 -c 'select count(*) from x;'
