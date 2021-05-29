#!/usr/bin/perl

use DBI;
use DBD::Pg;

$dbh1 = DBI->connect("DBI:Pg:dbname=postgres;host=127.0.0.1;port=5433","postgres","", { RaiseError => 1, AutoCommit => 1 }) or die "Can't connect PostgreSQL server\n";

$sql1="delete from y";
$sth1 = $dbh1->prepare($sql1);
$sth1->execute();

for($i = 1; $i <= 10; $i++) {
 
 $h1{$i} = 1;
 $sql1 = "insert into y (i) values ($i)";
 $sth1=$dbh1->do($sql1) or $h1{$i} = 2;

}

$dbh2 = DBI->connect("DBI:Pg:dbname=postgres;host=127.0.0.1;port=5434","postgres","", { RaiseError => 1, AutoCommit => 1 }) or die "Can't connect PostgreSQL server\n";

$sql2 = "select i from y";
$sth2 = $dbh2->prepare($sql2);
$sth2->execute();
 
while(@row2 = $sth2->fetchrow_array) {
 
 $h2{$row2[0]} = 1;

}
 
while (@res = each %h1) {
 if(! exists($h2{$res[0]})) {
  print "line not found! $res[0] = $res[1]\n"
 }
}
