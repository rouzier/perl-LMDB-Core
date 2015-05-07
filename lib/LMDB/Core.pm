package LMDB::Core;

use 5.010001;
use strict;
use warnings;
use Carp;

require Exporter;
use AutoLoader;

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

our $VERSION = '0.01';

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
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

LMDB::Core - Perl extension for blah blah blah

=head1 SYNOPSIS

  use LMDB::Core;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for LMDB::Core, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

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
