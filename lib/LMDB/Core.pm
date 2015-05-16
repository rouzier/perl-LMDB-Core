package LMDB::Core;

use 5.010001;
use strict;
use warnings;
use Carp;

require Exporter;
use AutoLoader;
use version;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use LMDB::Core ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (
    'all' => [
        qw(
          MDB_APPEND MDB_APPENDDUP
          MDB_BAD_DBI MDB_BAD_RSLOT
          MDB_BAD_TXN MDB_BAD_VALSIZE
          MDB_CORRUPTED MDB_CP_COMPACT
          MDB_CREATE MDB_CURRENT
          MDB_CURSOR_FULL MDB_DBS_FULL
          MDB_DUPFIXED MDB_DUPSORT
          MDB_FIRST MDB_FIRST_DUP
          MDB_FIXEDMAP MDB_GET_BOTH
          MDB_GET_BOTH_RANGE MDB_GET_CURRENT
          MDB_GET_MULTIPLE MDB_INCOMPATIBLE
          MDB_INTEGERDUP MDB_INTEGERKEY
          MDB_INVALID MDB_KEYEXIST
          MDB_LAST MDB_LAST_DUP
          MDB_LAST_ERRCODE MDB_MAPASYNC
          MDB_MAP_FULL MDB_MAP_RESIZED
          MDB_MAXKEYSIZE MDB_MULTIPLE
          MDB_NEXT MDB_NEXT_DUP
          MDB_NEXT_MULTIPLE MDB_NEXT_NODUP
          MDB_NODUPDATA MDB_NOLOCK
          MDB_NOMEMINIT MDB_NOMETASYNC
          MDB_NOOVERWRITE MDB_NORDAHEAD
          MDB_NOSUBDIR MDB_NOSYNC
          MDB_NOTFOUND MDB_NOTLS
          MDB_PAGE_FULL MDB_PAGE_NOTFOUND
          MDB_PANIC MDB_PREV
          MDB_PREV_DUP MDB_PREV_NODUP
          MDB_RDONLY MDB_READERS_FULL
          MDB_RESERVE MDB_REVERSEDUP
          MDB_REVERSEKEY MDB_SET
          MDB_SET_KEY MDB_SET_RANGE
          MDB_SUCCESS MDB_TLS_FULL
          MDB_TXN_FULL MDB_VERSION_DATE
          MDB_VERSION_FULL MDB_VERSION_MAJOR
          MDB_VERSION_MINOR MDB_VERSION_MISMATCH
          MDB_VERSION_PATCH MDB_VERSION_STRING
          MDB_WRITEMAP
        ),
        qw(
          mdb_version mdb_strerror
          mdb_env_create mdb_env_open
          mdb_env_copy mdb_env_copyfd
          mdb_env_stat mdb_env_info
          mdb_env_sync mdb_env_close
          mdb_env_set_flags mdb_env_get_flags
          mdb_env_get_path mdb_env_get_fd
          mdb_env_set_mapsize mdb_env_set_maxreaders
          mdb_env_get_maxreaders mdb_env_set_maxdbs
          mdb_env_get_maxkeysize mdb_env_set_userctx
          mdb_env_get_userctx mdb_txn_begin
          mdb_txn_env mdb_txn_id
          mdb_txn_commit mdb_txn_renew
          mdb_txn_abort mdb_txn_reset
          mdb_dbi_open mdb_stat
          mdb_dbi_flags mdb_dbi_close
          mdb_drop mdb_set_compare
          mdb_set_dupsort mdb_get
          mdb_put mdb_del
          mdb_cursor_open mdb_cursor_close
          mdb_cursor_renew mdb_cursor_txn
          mdb_cursor_dbi mdb_cursor_get
          mdb_cursor_put mdb_cursor_del
          mdb_cursor_count mdb_cmp
          mdb_dcmp mdb_reader_check
          mdb_clear_compare mdb_clear_dupsort
          mdb_reader_list
        )
    ],
    cursor => [
        qw(
          mdb_cursor_open mdb_cursor_close
          mdb_cursor_renew mdb_cursor_txn
          mdb_cursor_dbi mdb_cursor_get
          mdb_cursor_put mdb_cursor_del
          mdb_cursor_count
          MDB_FIRST
          MDB_FIRST_DUP
          MDB_GET_BOTH
          MDB_GET_BOTH_RANGE
          MDB_GET_CURRENT
          MDB_GET_MULTIPLE
          MDB_LAST
          MDB_LAST_DUP
          MDB_NEXT
          MDB_NEXT_DUP
          MDB_NEXT_MULTIPLE
          MDB_NEXT_NODUP
          MDB_PREV
          MDB_PREV_DUP
          MDB_PREV_NODUP
          MDB_SET
          MDB_SET_KEY
          MDB_SET_RANGE
        )
    ],
    quick => [
        qw(
          mdb_env_create mdb_env_open
          mdb_txn_begin mdb_env_close
          mdb_dbi_open
          mdb_get mdb_put mdb_del
          mdb_txn_commit mdb_txn_abort
          MDB_KEYEXIST MDB_SUCCESS MDB_NOTFOUND MDB_NOTLS MDB_NOLOCK MDB_NOOVERWRITE MDB_NOSUBDIR MDB_NOTFOUND MDB_CREATE
          MDB_RDONLY
        )
    ],
    errors => [
        qw(
          mdb_strerror
          MDB_SUCCESS
          MDB_KEYEXIST
          MDB_NOTFOUND
          MDB_PAGE_NOTFOUND
          MDB_CORRUPTED
          MDB_PANIC
          MDB_VERSION_MISMATCH
          MDB_INVALID
          MDB_MAP_FULL
          MDB_DBS_FULL
          MDB_READERS_FULL
          MDB_TLS_FULL
          MDB_TXN_FULL
          MDB_CURSOR_FULL
          MDB_PAGE_FULL
          MDB_MAP_RESIZED
          MDB_INCOMPATIBLE
          MDB_BAD_RSLOT
          MDB_BAD_TXN
          MDB_BAD_VALSIZE
          MDB_BAD_DBI
        )
    ],
);

sub import {
    my $pkg = caller;

    #  Touch the caller's $a and $b, to avoid the warning of
    #   Name "main::a" used only once: possible typo" warning
    no strict 'refs';
    ${"${pkg}::a"} = ${"${pkg}::a"};
    ${"${pkg}::b"} = ${"${pkg}::b"};

    goto &Exporter::import;
}

*EXPORT_OK = $EXPORT_TAGS{'all'};

our $VERSION = v0.9.14.0;

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "&LMDB::Core::constant not defined" if $constname eq 'constant';
    my ($error, $val) = constant($constname);
    if ($error) { croak $error; }
    {
	no strict 'refs';
	# Fixed between 5.005_53 and 5.005_61
#XXX	if ($] >= 5.00561) {
#XXX	    *$AUTOLOAD = sub () { $val };
#XXX	}
#XXX	else {
	    *$AUTOLOAD = sub { $val };
#XXX	}
    }
    goto &$AUTOLOAD;
}

require XSLoader;
XSLoader::load('LMDB::Core', $VERSION);

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

LMDB::Core - A thin wrapper for the LMDB api

=head1 SYNOPSIS

  use LMDB::Core qw(:quick);

  my $dbdir = 'dbdir';

  mkdir $dbdir unless -d $dbdir;

  #Create the LMDB environment
  my $rc = mdb_env_create(my $env);

  #Open the environment
  $rc = mdb_env_open($env, $dbdir);

  #New write transaction
  $rc = mdb_txn_begin($env, undef, 0, my $txn);

  #Open the default database
  $rc = mdb_dbi_open($txn, undef, MDB_CREATE, my $dbi);

  #Add to the database
  $rc = mdb_put($txn,$dbi,"larry","wall");

  #Commit your transaction which closes your txn
  $rc = mdb_txn_commit($txn);

  #New read transaction
  $rc = mdb_txn_begin($env, undef, MDB_RDONLY, $txn);

  #Get the value from the database
  $rc = mdb_get($txn,$dbi,"larry",my $data);

  print "larry = $data\n"

  #Close the transaction
  mdb_txn_abort($txn);

  #Close the environment
  mdb_env_close($env);

=head1 DESCRIPTION

LMDB::Core is a thin wrapper of the LMDB library.
Which mean it is very fast this also means that you must manage all resources manually.

=head1 FUNCTIONS

=head2 mdb_version

Return the LMDB library version information.

  my $version_str = mdb_version(my $major, my $minor, my $patch);

Where $major, $minor, $patch will be set with the LMDB version

=head2 mdb_strerror

Return a string describing a given error code.

  my $errstr = mdb_strerror($rc);

=head2 mdb_env_create

Create an LMDB environment handle.
To release the handle, call L</mdb_env_close>

  my $rc =  mdb_env_create($env);

The new lmdb environment will be set in $env or be set to undef on failure

=head2 mdb_env_open

Open an environment handle.
If this function fails, L</mdb_env_close> must be called to discard the env handle.

=head3 EXAMPLE

  my $rc = mdb_env_open($env, $path, $flags = 0, $mode = 0660);

=head3 PARAMETERS

=over

=item $env   - environment handle returned by L</mdb_env_create>

=item $path  - path to the directory of the database

=item $flags - options for this environment must zero or the follow flags OR'ed together

=over

=item L</MDB_FIXEDMAP>

The feature is highly experimental.
Use a fixed address for the mmap region. This flag must be specified
when creating the environment, and is stored persistently in the environment.
If successful, the memory map will always reside at the same virtual address
and pointers used to reference data items in the database will be constant
across multiple invocations. This option may not always work, depending on
how the operating system has allocated memory to shared libraries and other uses.

=item L</MDB_NOSUBDIR>

By default, LMDB creates its environment in a directory.
When this is set this  path is used as-is for the database main data file.
The database lock file is the path with "-lock" appended.

=item L</MDB_RDONLY>

Open the environment in read-only mode. No write operations will be
allowed. LMDB will still modify the lock file - except on read-only
filesystems, where LMDB does not use locks.

=item L</MDB_WRITEMAP>

Use a writeable memory map unless MDB_RDONLY is set. This is faster
and uses fewer mallocs, but loses protection from application bugs
like wild pointer writes and other bad updates into the database.
Incompatible with nested transactions.
Do not mix processes with and without MDB_WRITEMAP on the same
environment.  This can defeat durability (L</mdb_env_sync> etc).

=item L</MDB_NOMETASYNC>

Flush system buffers to disk only once per transaction, omit the
metadata flush. Defer that until the system flushes files to disk,
or next non-MDB_RDONLY commit or L</mdb_env_sync>. This optimization
maintains database integrity, but a system crash may undo the last
committed transaction. I.e. it preserves the ACI (atomicity,
consistency, isolation) but not D (durability) database property.
This flag may be changed at any time using L</mdb_env_set_flags>

=item L</MDB_NOSYNC>

Don't flush system buffers to disk when committing a transaction.
This optimization means a system crash can corrupt the database or
lose the last transactions if buffers are not yet flushed to disk.
The risk is governed by how often the system flushes dirty buffers
to disk and how often L</mdb_env_sync> is called.  However, if the
filesystem preserves write order and the L</MDB_WRITEMAP> flag is not
used, transactions exhibit ACI (atomicity, consistency, isolation)
properties and only lose D (durability).  I.e. database integrity
is maintained, but a system crash may undo the final transactions.
Note that (L</MDB_NOSYNC> | L</MDB_WRITEMAP>) leaves the system with no
hint for when to write transactions to disk, unless L</mdb_env_sync>
is called. (L</MDB_MAPASYNC> | L</MDB_WRITEMAP>) may be preferable.
This flag may be changed at any time using L</mdb_env_set_flags>.

=item L</MDB_MAPASYNC>

When using L</MDB_WRITEMAP>, use asynchronous flushes to disk.
As with L</MDB_NOSYNC>, a system crash can then corrupt the
database or lose the last transactions. Calling L</mdb_env_sync>
ensures on-disk database integrity until next commit.
This flag may be changed at any time using L</mdb_env_set_flags>.

=item L</MDB_NOTLS>

Don't use Thread-Local Storage. Tie reader locktable slots to
txn objects instead of to threads. I.e. L</mdb_txn_reset> keeps
the slot reseved for the txn object. A thread may use parallel
read-only transactions. A read-only transaction may span threads if
the user synchronizes its use. Applications that multiplex many
user threads over individual OS threads need this option. Such an
application must also serialize the write transactions in an OS
thread, since LMDB's write locking is unaware of the user threads.

=item L</MDB_NOLOCK>

Don't do any locking. If concurrent access is anticipated, the
caller must manage all concurrency itself. For proper operation
the caller must enforce single-writer semantics, and must ensure
that no readers are using old transactions while a writer is
active. The simplest approach is to use an exclusive lock so that
no readers may be active at all when a writer begins.

=item L</MDB_NORDAHEAD>

Turn off readahead. Most operating systems perform readahead on
read requests by default. This option turns it off if the OS
supports it. Turning it off may help random read performance
when the DB is larger than RAM and system RAM is full.
The option is not implemented on Windows.

=item L</MDB_NOMEMINIT>

Don't initialize malloc'd memory before writing to unused spaces
in the data file. By default, memory for pages written to the data
file is obtained using malloc. While these pages may be reused in
subsequent transactions, freshly malloc'd pages will be initialized
to zeroes before use. This avoids persisting leftover data from other
code (that used the heap and subsequently freed the memory) into the
data file. Note that many other system libraries may allocate
and free memory from the heap for arbitrary uses. E.g., stdio may
use the heap for file I/O buffers. This initialization step has a
modest performance cost so some applications may want to disable
it using this flag. This option can be a problem for applications
which handle sensitive data like passwords, and it makes memory
checkers like Valgrind noisy. This flag is not needed with L</MDB_WRITEMAP>,
which writes directly to the mmap instead of using malloc for pages. The
initialization is also skipped if L</MDB_RESERVE> is used; the
caller is expected to overwrite all of the memory that was
reserved in that case.
This flag may be changed at any time using L</mdb_env_set_flags>.

=back

=item  $mode - The UNIX permissions to set on created files ignored on Windows.

=back

=head3 RETURN

A non-zero error value on failure and 0 on success.
Some possible errors are

=over

=item L</MDB_VERSION_MISMATCH> - the version of the LMDB library doesn't match the

=item L</MDB_INVALID> - the environment file headers are corrupted.

=item ENOENT - the directory specified by the path parameter doesn't exist.

=item EACCES - the user didn't have permission to access the environment files.

=item EAGAIN - the environment was locked by another process.

=back

=head2 mdb_env_copy

Copy an LMDB environment to the specified path.
This function may be used to make a backup of an existing environment.
No lockfile is created, since it gets recreated at need.
This can trigger significant file size growth if run in parallel with write transactions.
See L</CAVEATS> for long-lived transactions.

=head3 EXAMPLE

    my $rc = mdb_env_copy($env, $path, $flags = 0);

=head3 PARAMETERS

=over

=item $env    - environment handle to copy returned by L</mdb_env_create>

=item $path   - path to an empty directory of the database

=item $flags  - flags zero or L</MDB_CP_COMPACT>

=back

=head3 RETURN

A non-zero error value on failure and 0 on success.

=head2 mdb_env_copyfd

Copy an LMDB environment to the specified file descriptor
This function may be used to make a backup of an existing environment.
No lockfile is created, since it gets recreated at need.
This can trigger significant file size growth if run in parallel with write transactions.
See long-lived transactions under L</CAVEATS>

=head3 EXAMPLE

    my $rc = mdb_env_copyfd($env, $fd, $flags = 0);

=head3 PARAMETERS

=over

=item $env    - environment handle to copy returned by L</mdb_env_create>

=item $path   - the file descriptor to write to

=item $flags  - flags zero or L</MDB_CP_COMPACT>

=back

=head3 RETURN

A non-zero error value on failure and 0 on success.

=head2 mdb_env_stat

=head3 EXAMPLE

    my $rc = mdb_env_stat($env,$stat);

=head3 PARAMETERS

=over

=item $env    - environment handle to copy returned by L</mdb_env_create>

=item $stat   - the variable to store the LMDB::Core::Stat object

=back

=head3 RETURN

A non-zero error value on failure and 0 on success.

=head2 mdb_env_info

=head3 EXAMPLE

    my $rc = mdb_env_info($env,$info);

=head3 PARAMETERS

=over

=item $env  - environment handle to copy returned by L</mdb_env_create>

=item $info - the variable to store the LMDB::Core::EnvInfo object

=back

=head3 RETURN

A non-zero error value on failure and 0 on success.

=head2 mdb_env_sync

Data is always written to disk when L</mdb_txn_commit> is called,
but the operating system may keep it buffered. LMDB always flushes
the OS buffers upon commit as well, unless the environment was
opened with #MDB_NOSYNC or in part #MDB_NOMETASYNC. This call is
not valid if the environment was opened with #MDB_RDONLY.

=head3 EXAMPLE

    my $rc = mdb_env_sync($env, $force);

=head3 PARAMETERS

=over

=item $env  - environment handle to copy returned by L</mdb_env_create>

=item $force

If true, force synchronous flush.
Otherwise if the environment has the #MDB_NOSYNC flag set the flushes
will be omitted, and with #MDB_MAPASYNC they will be asynchronous.

=back

=head3 RETURN

A non-zero error value on failure and 0 on success. Some possible

=over

=item EACCES

the environment is read-only.

=item EINVAL

an invalid parameter was specified.

=item EIO

an error occurred during synchronization.

=back

=head2 mdb_env_close

Close the environment and release the memory map.

Only a single thread may call this function. All transactions, databases,
and cursors must already be closed before calling this function. Attempts to
use any such handles after calling this function will cause a SIGSEGV.
The environment handle will be freed and must not be used again after this call.

=head3 EXAMPLE

    mdb_env_close($env);

=head3 PARAMETERS

=over

=item $env

environment handle to copy returned by L</mdb_env_create>

=back

=head3 RETURN

Nothing

=head2 mdb_env_set_flags

This may be used to set some flags in addition to those from
L</mdb_env_open>, or to unset these flags.  If several threads
change the flags at the same time, the result is undefined.

=head3 EXAMPLE

    my $rc = mdb_env_set_flags($env, $flags, $onoff);

=head3 PARAMETERS

=over

=item $env

environment handle returned by L</mdb_env_create>

=item $flags

The flags to set bitwise OR'ed together

=item $onoff

A true value sets the flags, zero clears them.

=back

=head3 RETURN

A non-zero error value on failure and 0 on success. Some possible

=over

=item

EINVAL - an invalid parameter was specified.

=back

=head2 mdb_env_get_flags

This may be used to set some flags in addition to those from
L</mdb_env_open>, or to unset these flags.  If several threads
change the flags at the same time, the result is undefined.

=head3 EXAMPLE

    my $rc = mdb_env_get_flags($env, $flags);

=head3 PARAMETERS

=over

=item $env

environment handle returned by L</mdb_env_create>

=item $flags

The scalar to store the flags

=back

=head3 RETURN

A non-zero error value on failure and 0 on success. Some possible

=over

=item

EINVAL - an invalid parameter was specified.

=back

=head1 CURSOR OPERATIONS

=head2 MDB_FIRST

Position at first key/data item

=head2 MDB_FIRST_DUP

Position at first data item of current key.
Only for #MDB_DUPSORT

=head2 MDB_GET_BOTH

Position at key/data pair. Only for #MDB_DUPSORT

=head2 MDB_GET_BOTH_RANGE

position at key, nearest data. Only for #MDB_DUPSORT

=head2 MDB_GET_CURRENT

Return key/data at current cursor position

=head2 MDB_GET_MULTIPLE

Return key and up to a page of duplicate data items
from current cursor position. Move cursor to prepare
for #MDB_NEXT_MULTIPLE. Only for #MDB_DUPFIXED

=head2 MDB_LAST

Position at last key/data item

=head2 MDB_LAST_DUP

Position at last data item of current key.
Only for #MDB_DUPSORT

=head2 MDB_NEXT

Position at next data item

=head2 MDB_NEXT_DUP

Position at next data item of current key.
Only for #MDB_DUPSORT

=head2 MDB_NEXT_MULTIPLE

Return key and up to a page of duplicate data items
from next cursor position. Move cursor to prepare
for #MDB_NEXT_MULTIPLE. Only for #MDB_DUPFIXED

=head2 MDB_NEXT_NODUP

Position at first data item of next key

=head2 MDB_PREV

Position at previous data item

=head2 MDB_PREV_DUP

Position at previous data item of current key.
Only for #MDB_DUPSORT

=head2 MDB_PREV_NODUP

Position at last data item of previous key

=head2 MDB_SET

Position at specified key

=head2 MDB_SET_KEY

Position at specified key, return key + data

=head2 MDB_SET_RANGE

Position at first key greater than or equal to specified key.

=head1 CAVEATS

=head2 Broken Lock

A broken lockfile can cause sync issues.
Stale reader transactions left behind by an aborted program
cause further writes to grow the database quickly, and
stale locks can block further operation.

Fix: Check for stale readers periodically, using the
L</mdb_reader_check> function or the L<mdb_stat> "mdb_stat" tool.
Stale writers will be cleared automatically on most systems:
- Windows - automatic
- BSD, systems using SysV semaphores - automatic
- Linux, systems using POSIX mutexes with Robust option - automatic
Otherwise just make all programs using the database close it;
the lockfile is always reset on first open of the environment.

=head1 SEE ALSO

L<LMDB_File> another perl module for LMDB

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

James Jude Rouzier, E<lt>rouzier@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by James Jude Rouzier

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
