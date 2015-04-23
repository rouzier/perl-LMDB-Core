use 5.010001;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'LMDB::Core',
    VERSION_FROM => 'lib/LMDB/Core.pm',    # finds $VERSION
    PREREQ_PM    => {},                    # e.g., Module::Name => 1.1
    (   $] >= 5.005
        ?                                  ## Add these new keywords supported since 5.005
          ( ABSTRACT_FROM => 'lib/LMDB/Core.pm',         # retrieve abstract from module
            AUTHOR        => 'root <root@localdomain>'
          )
        : ()
    ),
    LIBS   => [''],      # e.g., '-lm'
    DEFINE => '',        # e.g., '-DHAVE_SOMETHING'
    MYEXTLIB => 'liblmdb/liblmdb$(LIB_EXT)',
    INC    => '-I. ',    # e.g., '-I. -I/usr/include/other'
                         # Un-comment this if you add C files to link with later:
                         # OBJECT            => '$(O_FILES)', # link all the C files too
);
if (eval {require ExtUtils::Constant; 1}) {

    # If you edit these definitions to change the constants used by this module,
    # you will need to use the generated const-c.inc and const-xs.inc
    # files to replace their "fallback" counterparts before distributing your
    # changes.
    my @names = (
        qw(
          MDB_APPEND
          MDB_APPENDDUP
          MDB_BAD_DBI
          MDB_BAD_RSLOT
          MDB_BAD_TXN
          MDB_BAD_VALSIZE
          MDB_CORRUPTED
          MDB_CP_COMPACT
          MDB_CREATE
          MDB_CURRENT
          MDB_CURSOR_FULL
          MDB_DBS_FULL
          MDB_DUPFIXED
          MDB_DUPSORT
          MDB_FIRST
          MDB_FIRST_DUP
          MDB_FIXEDMAP
          MDB_GET_BOTH
          MDB_GET_BOTH_RANGE
          MDB_GET_CURRENT
          MDB_GET_MULTIPLE
          MDB_INCOMPATIBLE
          MDB_INTEGERDUP
          MDB_INTEGERKEY
          MDB_INVALID
          MDB_KEYEXIST
          MDB_LAST
          MDB_LAST_DUP
          MDB_LAST_ERRCODE
          MDB_MAPASYNC
          MDB_MAP_FULL
          MDB_MAP_RESIZED
          MDB_MAXKEYSIZE
          MDB_MULTIPLE
          MDB_NEXT
          MDB_NEXT_DUP
          MDB_NEXT_MULTIPLE
          MDB_NEXT_NODUP
          MDB_NODUPDATA
          MDB_NOLOCK
          MDB_NOMEMINIT
          MDB_NOMETASYNC
          MDB_NOOVERWRITE
          MDB_NORDAHEAD
          MDB_NOSUBDIR
          MDB_NOSYNC
          MDB_NOTFOUND
          MDB_NOTLS
          MDB_PAGE_FULL
          MDB_PAGE_NOTFOUND
          MDB_PANIC
          MDB_PREV
          MDB_PREV_DUP
          MDB_PREV_NODUP
          MDB_RDONLY
          MDB_READERS_FULL
          MDB_RESERVE
          MDB_REVERSEDUP
          MDB_REVERSEKEY
          MDB_SET
          MDB_SET_KEY
          MDB_SET_RANGE
          MDB_SUCCESS
          MDB_TLS_FULL
          MDB_TXN_FULL
          MDB_VERSION_FULL
          MDB_VERSION_MAJOR
          MDB_VERSION_MINOR
          MDB_VERSION_MISMATCH
          MDB_VERSION_PATCH
          MDB_WRITEMAP
          )
    );
    ExtUtils::Constant::WriteConstants(
        NAME         => 'LMDB::Core',
        NAMES        => \@names,
        DEFAULT_TYPE => 'IV',
        C_FILE       => 'const-c.inc',
        XS_FILE      => 'const-xs.inc',
    );

}
else {
    use File::Copy;
    use File::Spec;
    foreach my $file ('const-c.inc', 'const-xs.inc') {
        my $fallback = File::Spec->catfile('fallback', $file);
        copy($fallback, $file) or die "Can't copy $fallback to $file: $!";
    }
}

sub MY::postamble {
    if ($^O =~ /MSWin32/ && !defined($ENV{SYSTEMROOT})) {
        if ($Config{'make'} =~ /dmake/i) {
            return <<'EOT';
$(MYEXTLIB): liblmdb/Makefile
@[
	cd liblmdb
	$(MAKE) XCFLAGS=-fPIC liblmdb$(LIB_EXT)
	cd ..
]
EOT
        }
        elsif ($Config{'make'} =~ /nmake/i) {
            return <<'EOT';
$(MYEXTLIB): liblmdb/Makefile
	cd liblmdb
	$(MAKE) XCFLAGS=-fPIC liblmdb$(LIB_EXT)
	cd ..
EOT
        }
    }
    else {
        return <<'EOT';
$(MYEXTLIB): liblmdb/Makefile
	cd liblmdb && $(MAKE) XCFLAGS=-fPIC liblmdb$(LIB_EXT)
EOT
    }
}
