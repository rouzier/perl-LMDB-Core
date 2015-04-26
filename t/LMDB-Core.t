# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl LMDB-Core.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use constant BULK_INSERT => 10;

use Test::More tests => (18 + BULK_INSERT * 6);
use Test::NoWarnings;
use File::Temp qw(tempdir);
BEGIN {use_ok('LMDB::Core')}
use strict;
use warnings;
use Errno qw(EACCES);

sub rcmp {$b cmp $a}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

is(LMDB::Core::mdb_version(my $major, my $minor, my $patch), "LMDB 0.9.14: (September 20, 2014)", "mdb_version");

is($major, 0,  "Major version");
is($minor, 9,  "Minor version");
is($patch, 14, "Patch version");

is(LMDB::Core::mdb_strerror(0), "Successful return: 0", "mdb_strerror Success");

my $rc = LMDB::Core::mdb_env_create(my $env);

is($rc, 0, "mdb_env_create");

BAILOUT("Cannot create mdb environment " . LMDB::Core::mdb_env_create($rc)) if $rc;

isa_ok($env, "LMDB::Core::Env", "Isa LMDB::Core::Env");

my $tempdb = tempdir(CLEANUP => 1);

$rc = LMDB::Core::mdb_env_open($env, $tempdb);

is($rc, 0, "mdb_env_open");

BAILOUT("Cannot open mdb db $tempdb " . LMDB::Core::mdb_env_create($rc)) if $rc;

$rc = LMDB::Core::mdb_txn_begin($env, undef, 0, my $txn);

is($rc, 0, "mdb_txn_begin");

isa_ok($txn, "LMDB::Core::Txn", "Isa LMDB::Core::Txn");

$rc = LMDB::Core::mdb_dbi_open($txn, undef, 0, my $dbi);
LMDB::Core::mdb_set_compare($txn, $dbi, sub {$b cmp $a});

is($rc, 0, "mdb_dbi_open");

for (my $i = 0; $i < BULK_INSERT; $i++) {
    my $key = "key_$i";
    my $val = "val_$i";
    $rc = LMDB::Core::mdb_put($txn, $dbi, $key, $val);
    is($rc, 0, "mdb_put $key = $val");
}

$rc = LMDB::Core::mdb_txn_commit($txn);

is($rc, 0, "mdb_txn_commit");

$rc = LMDB::Core::mdb_txn_begin($env, undef, LMDB::Core::MDB_RDONLY(), $txn);

for (my $i = 0; $i < BULK_INSERT; $i++) {
    my $key  = "key_$i";
    my $val  = "val_$i";
    my $data = '';
    $rc = LMDB::Core::mdb_get($txn, $dbi, $key, $data);
    is($rc,   0,    "mdb_get $key is success");
    is($data, $val, "mdb_get $key = $val");
}

$rc = LMDB::Core::mdb_put($txn, $dbi, "garbage_in", "garbage_out", 0);

is($rc, EACCES, "mdb_put failed readonly");

$rc = LMDB::Core::mdb_cursor_open($txn, $dbi, my $cursor);
is($rc, 0, "mdb_cursor_open");

my $key  = '';
my $data = '';
$rc = LMDB::Core::mdb_cursor_get($cursor, $key, $data, LMDB::Core::MDB_FIRST());

#Testing insert order in reverse

for (my $i = BULK_INSERT - 1; $i >= 0; $i--) {
    is($rc, 0, "mdb_cursor_get");
    my $test_key = "key_$i";
    my $test_val = "val_$i";
    is($test_key, $key,  "Insert order key");
    is($test_val, $data, "Insert order val");
    $rc = LMDB::Core::mdb_cursor_get($cursor, $key, $data, LMDB::Core::MDB_NEXT());
}

is($rc, LMDB::Core::MDB_NOTFOUND(), "mdb_cursor_get");

isa_ok($cursor, "LMDB::Core::Cursor", "Isa LMDB::Core::Cursor");

LMDB::Core::mdb_cursor_close($cursor);

LMDB::Core::mdb_txn_abort($txn);

LMDB::Core::mdb_env_close($env);
