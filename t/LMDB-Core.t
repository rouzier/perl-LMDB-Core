# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl LMDB-Core.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 16;
BEGIN { use_ok('LMDB::Core') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

is(LMDB::Core::mdb_version(my $major, my $minor, my $patch),"LMDB 0.9.14: (September 20, 2014)","mdb_version");

is($major,0,"Major version");
is($minor,9,"Minor version");
is($patch,14,"Patch version");

is(LMDB::Core::mdb_strerror(0),"Successful return: 0","mdb_strerror Success");

my $rc = LMDB::Core::mdb_env_create(my $env);

is($rc,0,"mdb_env_create");

isa_ok($env,"LMDB::Core::Env","Isa LMDB::Core::Env");

mkdir ("tempdb");

$rc = LMDB::Core::mdb_env_open($env,"tempdb");

is($rc,0,"mdb_env_open");

$rc = LMDB::Core::mdb_txn_begin($env, undef, 0, my $txn);

is($rc,0,"mdb_txn_begin");

isa_ok($txn,"LMDB::Core::Txn","Isa LMDB::Core::Txn");

my $rc = LMDB::Core::mdb_dbi_open($txn,undef,0,$dbi);

is($rc,0,"mdb_dbi_open");

my $rc = LMDB::Core::mdb_put($txn,$dbi,"bob", "jones",0);

is($rc,0,"mdb_put");

$rc = LMDB::Core::mdb_txn_commit($txn);

is($rc,0,"mdb_txn_commit");

$rc = LMDB::Core::mdb_txn_begin($env, undef, 0, $txn);

my $key = "bob";
my $data;

my $rc = LMDB::Core::mdb_get($txn,$dbi,$key,$data);

is($rc,0,"mdb_get");

is($data,"jones","mdb_get back");




LMDB::Core::mdb_env_close($env);
