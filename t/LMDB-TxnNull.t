# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl LMDB-Core.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use Test::More tests => 9;
use Test::NoWarnings;
use File::Temp qw(tempdir);
BEGIN {use_ok('LMDB::Core')}
use strict;
use warnings;
use Errno qw(EACCES);
use LMDB::Core qw(:all);

sub rcmp {$b cmp $a}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $rc = mdb_env_create(my $env);

is($rc, 0, "mdb_env_create");

BAIL_OUT("Cannot create mdb environment " . mdb_env_create($rc)) if $rc;

isa_ok($env, "LMDB::Core::Env", "Isa LMDB::Core::Env");

my $tempdb = tempdir(CLEANUP => 1);

$rc = mdb_env_open($env, $tempdb);

is($rc, 0, "mdb_env_open");

BAIL_OUT("Cannot open mdb db $tempdb " . mdb_strerror($rc)) if $rc;

mdb_env_close($env);

$rc = mdb_env_create($env);

is($rc, 0, "mdb_env_create");

$rc = mdb_env_open($env, $tempdb, MDB_RDONLY);

is($rc, 0, "mdb_env_open MDB_RDONLY");

BAIL_OUT("Cannot open mdb db $tempdb " . mdb_strerror($rc)) if $rc;

$rc = mdb_txn_begin($env, undef, 0, my $txn);

is($rc, EACCES, "mdb_txn_begin failed");

is(undef,$txn,"Undef on failure");
