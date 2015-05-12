#define PERL_NO_GET_CONTEXT /* we want efficiency */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <liblmdb/lmdb.h>

#include "const-c.inc"

#if PERL_VERSION >= 18
# define SvTRULYREADONLY(sv) SvREADONLY(sv)
#else
# define SvTRULYREADONLY(sv) (SvREADONLY(sv) && !SvIsCOW(sv))
#endif

typedef	MDB_env*    LMDB__Core__Env;
typedef	MDB_envinfo*    LMDB__Core__EnvInfo;
typedef	MDB_txn*    LMDB__Core__Txn;
typedef MDB_txn*    LMDB__Core__TxnNullable;
typedef MDB_cursor* LMDB__Core__Cursor;
typedef MDB_stat*   LMDB__Core__Stat;
typedef MDB_val     MDB_valIn;
typedef MDB_val*    MDB_valInOut;

static int LMDB_Core_msg_func(const char *msg, void *ctx) {
    int count;
    SV* method = (SV*) ctx;
    dTHX;
    dSP;
    int ret;
    ENTER; SAVETMPS;
    PUSHMARK(SP);
    PUSHs(sv_2mortal(newSVpv(msg,0)));
    PUTBACK;
    count = call_sv(method, G_SCALAR);
    SPAGAIN;
    if(count != 1) {
        croak("LMDB_Core_msg_func did not return a single value");
    }
    ret = POPi;
    PUTBACK;
    FREETMPS; LEAVE;
    return ret;
}

static int  LMDB_Core_cmp(const MDB_val *a, const MDB_val *b, void * ctx) {
    int count;
    SV* method = (SV*) ctx;
    dTHX;
    dSP;
    int ret;
    ENTER; SAVETMPS;
    PUSHMARK(SP);
    sv_setpvn_mg(get_sv("::a",GV_ADDMULTI), a->mv_data, a->mv_size);
    sv_setpvn_mg(get_sv("::b",GV_ADDMULTI), b->mv_data, b->mv_size);
    count = call_sv(method, G_SCALAR|G_NOARGS);
    SPAGAIN;
    if(count != 1) {
        croak("LMDB_Core_cmp did not return a single value");
    }
    ret = POPi;
    PUTBACK;
    FREETMPS; LEAVE;
    return ret;
}

MODULE = LMDB::Core		PACKAGE = LMDB::Core::EnvInfo

void* mapaddr(envinfo)
    LMDB::Core::EnvInfo envinfo
    CODE:
    RETVAL = envinfo->me_mapaddr;
    OUTPUT:
    RETVAL

size_t mapsize(envinfo)
	LMDB::Core::EnvInfo envinfo
	CODE:
	RETVAL = envinfo->me_mapsize;
	OUTPUT:
	RETVAL

size_t last_pgno(envinfo)
	LMDB::Core::EnvInfo envinfo
	CODE:
	RETVAL = envinfo->me_last_pgno;
	OUTPUT:
	RETVAL

size_t last_txnid(envinfo)
	LMDB::Core::EnvInfo envinfo
	CODE:
	RETVAL = envinfo->me_last_txnid;
	OUTPUT:
	RETVAL

unsigned int maxreaders(envinfo)
	LMDB::Core::EnvInfo envinfo
	CODE:
	RETVAL = envinfo->me_maxreaders;
	OUTPUT:
	RETVAL

unsigned int numreaders(envinfo)
	LMDB::Core::EnvInfo envinfo
	CODE:
	RETVAL = envinfo->me_numreaders;
	OUTPUT:
	RETVAL

void DESTROY(envinfo)
	LMDB::Core::EnvInfo envinfo
    CODE:
    Safefree(envinfo);

MODULE = LMDB::Core		PACKAGE = LMDB::Core::Stat

unsigned int psize(stat)
    LMDB::Core::Stat stat
    CODE:
    RETVAL = stat->ms_psize;
    OUTPUT:
    RETVAL

unsigned int depth(stat)
    LMDB::Core::Stat stat
    CODE:
    RETVAL = stat->ms_branch_pages;
    OUTPUT:
    RETVAL

size_t branch_pages(stat)
    LMDB::Core::Stat stat
    CODE:
    RETVAL = stat->ms_branch_pages;
    OUTPUT:
    RETVAL

size_t leaf_pages(stat)
    LMDB::Core::Stat stat
    CODE:
    RETVAL = stat->ms_leaf_pages;
    OUTPUT:
    RETVAL

size_t overflow_pages(stat)
    LMDB::Core::Stat stat
    CODE:
    RETVAL = stat->ms_overflow_pages;
    OUTPUT:
    RETVAL

size_t entries(stat)
    LMDB::Core::Stat stat
    CODE:
    RETVAL = stat->ms_entries;
    OUTPUT:
    RETVAL

void DESTROY(stat)
    LMDB::Core::Stat stat
    CODE:
    Safefree(stat);


MODULE = LMDB::Core		PACKAGE = LMDB::Core		
PROTOTYPES: DISABLE

INCLUDE: const-xs.inc


char *
mdb_version(major, minor, patch)
    int &major = NO_INIT
    int &minor = NO_INIT
    int &patch = NO_INIT
    OUTPUT:
    major
    minor
    patch
    
char *
mdb_strerror(err)
    int err

int
mdb_env_create(env)
	LMDB::Core::Env   &env = NULL;
    OUTPUT:
	env

int
mdb_env_open(env, path, flags = 0, mode = 0660)
	LMDB::Core::Env   env
	const char *	path
	unsigned flags
	int	mode

int
mdb_env_copy(env, path, flags = 0)
	LMDB::Core::Env   env
	const char *	path
	unsigned int flags
    CODE:
	RETVAL = mdb_env_copy2(env, path, flags);
    OUTPUT:
	RETVAL

int
mdb_env_copyfd(env, fd, flags = 0)
	LMDB::Core::Env   env
	int  fd
	unsigned flags
    CODE:
	RETVAL = mdb_env_copyfd2(env, fd, flags);
    OUTPUT:
	RETVAL


int
mdb_env_stat(env, stat)
    LMDB::Core::Env env
    LMDB::Core::Stat stat = NO_INIT
    INIT:
    Newx(stat, 1, MDB_stat);
    CODE:
    RETVAL = mdb_env_stat(env,stat);
    OUTPUT:
    stat
    RETVAL

int
mdb_env_info(env,envinfo)
    LMDB::Core::Env env
    LMDB::Core::EnvInfo envinfo = NO_INIT
    INIT:
    Newx(envinfo, 1, MDB_envinfo);
    CODE:
    RETVAL = mdb_env_info(env,envinfo);
    OUTPUT:
    envinfo
    RETVAL

int
mdb_env_sync(env, force=0)
	LMDB::Core::Env   env
	int	force

void
mdb_env_close(env)
	LMDB::Core::Env   env

int
mdb_env_set_flags(env, flags, onoff)
	LMDB::Core::Env   env
	unsigned int	flags
	int	onoff

int
mdb_env_get_flags(env, flags)
	LMDB::Core::Env   env
	unsigned int &flags = NO_INIT
    OUTPUT:
	flags

int
mdb_env_get_path(env, path)
	LMDB::Core::Env   env
	const char * &path = NO_INIT
    OUTPUT:
	path

int
mdb_env_get_fd(env, fd)
    LMDB::Core::Env   env
    int &fd = NO_INIT
    OUTPUT:
    fd

int
mdb_env_set_mapsize(env, size)
	LMDB::Core::Env   env
	size_t	size

int
mdb_env_set_maxreaders(env, readers)
	LMDB::Core::Env   env
	unsigned int	readers

int
mdb_env_get_maxreaders(env, readers)
	LMDB::Core::Env   env
	unsigned int &readers = NO_INIT
    OUTPUT:
	readers

int
mdb_env_set_maxdbs(env, dbs)
	LMDB::Core::Env   env
	int	dbs

int
mdb_env_get_maxkeysize(env)
	LMDB::Core::Env   env

int
mdb_env_set_userctx(env, ctx)
    LMDB::Core::Env   env
    SV* ctx
    CODE:
    RETVAL = mdb_env_set_userctx(env,(void*)ctx);
    OUTPUT:
    RETVAL

SV *
mdb_env_get_userctx(env);
    LMDB::Core::Env   env
    CODE:
    RETVAL = (SV*) mdb_env_get_userctx(env);
    OUTPUT:
    RETVAL

=begin

# I will not add this mdb_env_set_assert as it will may be dropped later

int  mdb_env_set_assert(MDB_env *env, MDB_assert_func *func);

=cut

int
mdb_txn_begin(env, parent, flags, txn)
	LMDB::Core::Env   env
	LMDB::Core::TxnNullable parent
	unsigned    flags
	LMDB::Core::Txn   &txn = NULL;
    OUTPUT:
	txn

LMDB::Core::Env
mdb_txn_env(txn)
	LMDB::Core::Txn   txn
    POSTCALL:
    if (RETVAL == NULL)
        XSRETURN_UNDEF;

size_t
mdb_txn_id(txn)
	LMDB::Core::Txn   txn

int
interface_int_txn(txn)
	LMDB::Core::Txn   txn
INTERFACE:
mdb_txn_commit
mdb_txn_renew

void
interface_void_txn(txn)
	LMDB::Core::Txn   txn
INTERFACE:
mdb_txn_abort
mdb_txn_reset


int
mdb_dbi_open(txn, name, flags, dbi)
	LMDB::Core::Txn   txn
	const char * name = SvOK($arg) ? (const char *)SvPV_nolen($arg) : NULL;
	unsigned	flags
	unsigned int &dbi = NO_INIT
    OUTPUT:
	dbi

int
mdb_stat(txn, dbi, stat);
	LMDB::Core::Txn   txn
    int dbi
    LMDB::Core::Stat stat = NO_INIT
    INIT:
    Newx(stat, 1, MDB_stat);
    CODE:
    RETVAL = mdb_stat(txn,dbi,stat);
    OUTPUT:
    stat
    RETVAL

int
mdb_dbi_flags(txn, dbi, flags);
	LMDB::Core::Txn   txn
    int dbi
    unsigned int &flags = NO_INIT
    OUTPUT:
    flags

void
mdb_dbi_close (env, dbi)
	LMDB::Core::Env   env
	unsigned int	dbi

int
mdb_drop(txn, dbi, del = 0)
	LMDB::Core::Txn txn
	unsigned int	dbi
    int del

int
mdb_set_compare(txn, dbi, cmp) 
    LMDB::Core::Txn txn
    unsigned int dbi
    SV *cmp 
    CODE:
    SV *callback;
    int rc;
    if(!SvOK(cmp)) {
        rc = EINVAL;
        goto done;
    }
    if((rc = mdb_get_cmpctx(txn, dbi,(void**) &callback)) != MDB_SUCCESS) {
        goto done;
    }
    if (callback == (SV*)NULL)  {
        callback = newSVsv(cmp);
    }
    else {
        SvSetSV(callback, cmp);
    }
    if((rc = mdb_set_cmpctx(txn, dbi, (void *)callback)) != MDB_SUCCESS) {
        goto done;
    }
    if((rc = mdb_set_compare(txn, dbi, LMDB_Core_cmp)) != MDB_SUCCESS) {
        mdb_set_cmpctx(txn, dbi, NULL);
        goto done;
    }
done:
    RETVAL = rc;
    OUTPUT:
    RETVAL

int
mdb_clear_compare(txn, dbi) 
    LMDB::Core::Txn txn
    unsigned int dbi
    CODE:
    SV *callback;
    int rc;
    if((rc = mdb_get_cmpctx(txn, dbi,(void**) &callback)) != MDB_SUCCESS) {
        goto done;
    }
    if (callback == (SV*)NULL)  {
        goto done;
    }
    SvREFCNT_dec(callback);
    if((rc = mdb_set_cmpctx(txn, dbi, NULL)) != MDB_SUCCESS) {
        goto done;
    }
    if((rc = mdb_set_compare(txn, dbi, NULL)) != MDB_SUCCESS) {
        goto done;
    }
done:
    RETVAL = rc;
    OUTPUT:
    RETVAL

int
mdb_set_dupsort(txn, dbi, cmp) 
    LMDB::Core::Txn txn
    unsigned int dbi
    SV *cmp 
    CODE:
    SV *callback;
    int rc;
    if(!SvOK(cmp)) {
        rc = EINVAL;
        goto done;
    }
    if((rc = mdb_get_dcmpctx(txn, dbi,(void**) &callback)) != MDB_SUCCESS) {
        goto done;
    }
    if (callback == (SV*)NULL)  {
        callback = newSVsv(cmp);
    }
    else {
        SvSetSV(callback, cmp);
    }
    if((rc = mdb_set_dcmpctx(txn, dbi, (void *)callback)) != MDB_SUCCESS) {
        goto done;
    }
    if((rc = mdb_set_dupsort(txn, dbi, LMDB_Core_cmp)) != MDB_SUCCESS) {
        mdb_set_dcmpctx(txn, dbi, NULL);
        goto done;
    }
    SvREFCNT_inc(cmp);
done:
    RETVAL = rc;
    OUTPUT:
    RETVAL

int
mdb_clear_dupsort(txn, dbi) 
    LMDB::Core::Txn txn
    unsigned int dbi
    CODE:
    SV *callback;
    int rc;
    if((rc = mdb_get_dcmpctx(txn, dbi,(void**) &callback)) != MDB_SUCCESS) {
        goto done;
    }
    if (callback == (SV*)NULL)  {
        goto done;
    }
    SvREFCNT_dec(callback);
    if((rc = mdb_set_dcmpctx(txn, dbi, NULL)) != MDB_SUCCESS) {
        goto done;
    }
    if((rc = mdb_set_dupsort(txn, dbi, NULL)) != MDB_SUCCESS) {
        goto done;
    }
done:
    RETVAL = rc;
    OUTPUT:
    RETVAL

=begin

int  mdb_set_relfunc(MDB_txn *txn, MDB_dbi dbi, MDB_rel_func *rel);
int  mdb_set_relctx(MDB_txn *txn, MDB_dbi dbi, void *ctx);

=cut

int
mdb_get(txn, dbi, key, data)
    LMDB::Core::Txn txn
    unsigned int dbi
    MDB_valIn &key
    MDB_valInOut data;
    OUTPUT:
    data

int
mdb_put(txn, dbi, key, data, flags = 0)
    LMDB::Core::Txn txn
    unsigned int dbi
    MDB_valIn &key
    MDB_valIn &data
    unsigned int flags

int
mdb_del(txn, dbi, key, data)
    LMDB::Core::Txn txn
    unsigned int dbi
    MDB_valIn &key
    MDB_valIn &data

int
mdb_cursor_open(txn, dbi, cursor)
	LMDB::Core::Txn   txn
	unsigned int	dbi
	LMDB::Core::Cursor	&cursor = NULL;
    OUTPUT:
	cursor

void
mdb_cursor_close(cursor)
	LMDB::Core::Cursor	cursor

int
mdb_cursor_renew(txn, cursor)
	LMDB::Core::Txn   txn
	LMDB::Core::Cursor	cursor

LMDB::Core::Txn
mdb_cursor_txn(cursor)
	LMDB::Core::Cursor	cursor


unsigned int
mdb_cursor_dbi(cursor)
	LMDB::Core::Cursor	cursor

int
mdb_cursor_get(cursor, key, data, MDB_cursor_op op)
    LMDB::Core::Cursor cursor
    MDB_valInOut key
    MDB_valInOut data
    OUTPUT:
    key
    data


int
mdb_cursor_put(cursor, key, data, flags)
	LMDB::Core::Cursor	cursor
    MDB_valIn &key
    MDB_valIn &data
    unsigned int flags

int
mdb_cursor_del(cursor, flags = 0)
	LMDB::Core::Cursor	cursor
	unsigned		flags

int
mdb_cursor_count(cursor, count)
	LMDB::Core::Cursor	cursor
	size_t  &count = NO_INIT
    OUTPUT:
	count

int
mdb_cmp(txn, dbi, a, b)
	LMDB::Core::Txn   txn
    unsigned int dbi
    MDB_valIn   &a
    MDB_valIn   &b

int
mdb_dcmp(txn, dbi, a, b)
	LMDB::Core::Txn   txn
    unsigned int dbi
    MDB_valIn   &a
    MDB_valIn   &b

int
mdb_reader_list(env, func);
    LMDB::Core::Env env
    SV * func
    CODE:
    RETVAL = mdb_reader_list(env,LMDB_Core_msg_func,func);
    OUTPUT:
    RETVAL

int
mdb_reader_check(env, dead)
    LMDB::Core::Env env
    int &dead = NO_INIT

