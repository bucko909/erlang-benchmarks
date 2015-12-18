#include "erl_nif.h"

ErlNifResourceType* BLOB_TYPE;
ERL_NIF_TERM atom_ok;

void
free_blob(ErlNifEnv* env, void* obj)
{
	//Tracker* tracker = (Tracker*) enif_priv_data(env);
	//tracker->count -= 1;
}

// There are four functions that may be called during the lifetime
// of a NIF. load, reload, upgrade, and unload. Any of these functions
// can be left unspecified by passing NULL to the ERL_NIF_INIT macro.
//
// NIFs are awesome.

// Return value of 0 indicates success.
// Docs: http://erlang.org/doc/man/erl_nif.html#load

static int
load(ErlNifEnv* env, void** priv, ERL_NIF_TERM load_info)
{
	const char *mod = "bench_test1";
	const char *resource_name = "Blob";
	int flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;

	BLOB_TYPE = enif_open_resource_type(env, mod, resource_name, free_blob, flags, NULL);
	atom_ok = enif_make_atom(env, "ok");
	return 0;
}

// Called when changing versions of the C code for a module's NIF
// implementation if I read the docs correctly.
//
// Return value of 0 indicates success.
// Docs: http://erlang.org/doc/man/erl_nif.html#upgrade

static int
upgrade(ErlNifEnv* env, void** priv, void** old_priv, ERL_NIF_TERM load_info)
{
    return 0;
}

// Called when the library is unloaded. Not called after a reload
// executes.
//
// No return value
// Docs: http://erlang.org/doc/man/erl_nif.html#load

static void
unload(ErlNifEnv* env, void* priv)
{
    return;
}

// The actual C implementation of an Erlang function.
//
// Docs: http://erlang.org/doc/man/erl_nif.html#ErlNifFunc

static ERL_NIF_TERM
return_ok_nif_0(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    return atom_ok;
}

static ERL_NIF_TERM
return_ok_nif_1(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    return atom_ok;
}

static ERL_NIF_TERM
return_ok_nif_2(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    return atom_ok;
}

static ERL_NIF_TERM
nine_tuple_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	return enif_make_tuple9(env, argv[0], argv[0], argv[0], argv[0], argv[0], argv[0], argv[0], argv[0], argv[0]);
}

static ERL_NIF_TERM
return_resource_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int *res;
	ERL_NIF_TERM ret;

	res = enif_alloc_resource(BLOB_TYPE, sizeof(int));
	if(res == NULL) return enif_make_badarg(env);

	ret = enif_make_resource(env, res);
	enif_release_resource(res);

	return ret;
}

static ERL_NIF_TERM
return_keep_resource_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int *res;
	ERL_NIF_TERM ret;

	res = enif_alloc_resource(BLOB_TYPE, sizeof(int));
	if(res == NULL) return enif_make_badarg(env);

	ret = enif_make_resource(env, res);

	return ret;
}

static ERL_NIF_TERM
inspect_resource_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int* res;

	if(argc != 1)
	{
		return enif_make_badarg(env);
	}

	if(!enif_get_resource(env, argv[0], BLOB_TYPE, (void**) &res))
	{
		return enif_make_badarg(env);
	}

	return enif_make_int(env, *res);
}

static ERL_NIF_TERM
only_inspect_resource_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int* res;

	if(argc != 1)
	{
		return enif_make_badarg(env);
	}

	if(!enif_get_resource(env, argv[0], BLOB_TYPE, (void**) &res))
	{
		return enif_make_badarg(env);
	}

	return atom_ok;
}

static ERL_NIF_TERM
increment_resource_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int* res;

	if(argc != 1)
	{
		return enif_make_badarg(env);
	}

	if(!enif_get_resource(env, argv[0], BLOB_TYPE, (void**) &res))
	{
		return enif_make_badarg(env);
	}

	(*res)++;

	return enif_make_int(env, *res);
}

static ERL_NIF_TERM
double_inspect_resource_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int* res;

	if(argc != 1)
	{
		return enif_make_badarg(env);
	}

	if(!enif_get_resource(env, argv[0], BLOB_TYPE, (void**) &res))
	{
		return enif_make_badarg(env);
	}

	if(!enif_get_resource(env, argv[0], BLOB_TYPE, (void**) &res))
	{
		return enif_make_badarg(env);
	}

	return enif_make_int(env, *res);
}

static ERL_NIF_TERM
free_resource_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	int* res;

	if(argc != 1)
	{
		return enif_make_badarg(env);
	}

	if(!enif_get_resource(env, argv[0], BLOB_TYPE, (void**) &res))
	{
		return enif_make_badarg(env);
	}

	enif_release_resource(res);

	return atom_ok;
}


static ErlNifFunc nif_funcs[] = {
    {"return_ok_nif", 0, return_ok_nif_0},
    {"return_ok_nif", 1, return_ok_nif_1},
    {"return_ok_nif", 2, return_ok_nif_2},
	{"nine_tuple_nif", 1, nine_tuple_nif},
	{"return_resource_nif", 0, return_resource_nif},
	{"return_keep_resource_nif", 0, return_keep_resource_nif},
	{"inspect_resource_nif", 1, inspect_resource_nif},
	{"increment_resource_nif", 1, increment_resource_nif},
	{"only_inspect_resource_nif", 1, only_inspect_resource_nif},
	{"double_inspect_resource_nif", 1, double_inspect_resource_nif},
	{"free_resource_nif", 1, free_resource_nif}
};

// Initialize this NIF library.
//
// Args: (MODULE, ErlNifFunc funcs[], load, reload, upgrade, unload)
// Docs: http://erlang.org/doc/man/erl_nif.html#ERL_NIF_INIT

ERL_NIF_INIT(bench_test1, nif_funcs, &load, NULL, &upgrade, &unload);
