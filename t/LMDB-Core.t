# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl LMDB-Core.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use constant BULK_INSERT => 10;

use Test::More tests => (20 + BULK_INSERT * 6);
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

is(mdb_version(my $major, my $minor, my $patch), "LMDB 0.9.14: (September 20, 2014)", "mdb_version");

is($major, 0,  "Major version");
is($minor, 9,  "Minor version");
is($patch, 14, "Patch version");

is(mdb_strerror(0), "Successful return: 0", "mdb_strerror Success");

my $rc = mdb_env_create(my $env);

is($rc, 0, "mdb_env_create");

BAILOUT("Cannot create mdb environment " . mdb_env_create($rc)) if $rc;

isa_ok($env, "LMDB::Core::Env", "Isa LMDB::Core::Env");

my $tempdb = tempdir(CLEANUP => 1);

$rc = mdb_env_open($env, $tempdb);

is($rc, 0, "mdb_env_open");

BAILOUT("Cannot open mdb db $tempdb " . mdb_env_create($rc)) if $rc;

$rc = mdb_txn_begin($env, undef, 0, my $txn);

is($rc, 0, "mdb_txn_begin");

isa_ok($txn, "LMDB::Core::Txn", "Isa LMDB::Core::Txn");

$rc = mdb_dbi_open($txn, undef, 0, my $dbi);
mdb_set_compare($txn, $dbi, sub {$b cmp $a});

is($rc, 0, "mdb_dbi_open");

for (my $i = 0; $i < BULK_INSERT; $i++) {
    my $key = "key_$i";
    my $val = "val_$i";
    $rc = mdb_put($txn, $dbi, $key, $val);
    is($rc, 0, "mdb_put $key = $val");
}

$rc = mdb_txn_commit($txn);

is($rc, 0, "mdb_txn_commit");


$rc = mdb_txn_begin($env, undef, MDB_RDONLY(), $txn);

is($rc, 0, "mdb_txn_begin MDB_RDONLY");

$rc = mdb_get($txn, $dbi, "key_1", undef);

for (my $i = 0; $i < BULK_INSERT; $i++) {
    my $key  = "key_$i";
    my $val  = "val_$i";
    my $data = '';
    $rc = mdb_get($txn, $dbi, $key, $data);
    is($rc,   0,    "mdb_get $key is success");
    is($data, $val, "mdb_get $key = $val");
}

$rc = mdb_put($txn, $dbi, "garbage_in", "garbage_out", 0);

is($rc, EACCES, "mdb_put failed readonly");

$rc = mdb_cursor_open($txn, $dbi, my $cursor);
is($rc, 0, "mdb_cursor_open");

my $key  = '';
my $data = '';
$rc = mdb_cursor_get($cursor, $key, $data, MDB_FIRST());

#Testing insert order in reverse

for (my $i = BULK_INSERT - 1; $i >= 0; $i--) {
    is($rc, 0, "mdb_cursor_get");
    my $test_key = "key_$i";
    my $test_val = "val_$i";
    is($test_key, $key,  "Insert order key");
    is($test_val, $data, "Insert order val");
    $rc = mdb_cursor_get($cursor, $key, $data, MDB_NEXT());
}

is($rc, MDB_NOTFOUND(), "mdb_cursor_get");

isa_ok($cursor, "LMDB::Core::Cursor", "Isa LMDB::Core::Cursor");
my $count = 0;

mdb_reader_list($env,sub { $count++ ; return -1 });

is($count,1,"The reader list callback is working");

mdb_cursor_close($cursor);

mdb_txn_abort($txn);

mdb_env_close($env);
