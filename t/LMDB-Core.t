# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl LMDB-Core.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 9;
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

