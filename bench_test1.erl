-module(bench_test1).

-on_load(init/0).

-compile([{parse_transform, repeat}]).

-compile(export_all).

init() ->
	io:format("load_nif: ~p~n", [erlang:load_nif("./bench_test1", erlang:unique_integer() rem 10000)]),
	ok.

% 0.01ns
bench_unrolled_ok() ->
	repeat(1000, ok).

% 2.33ns+-0.2
bench_unrolled_fun() ->
	repeat(1000, return_ok_pure()).

% 2.7ns+-0.1
bench_unrolled_fun_1() ->
	repeat(1000, return_ok_pure(0)).

% 3.03ns+-0.1
bench_unrolled_fun_2() ->
	repeat(1000, return_ok_pure(0, 0)).

% CONCLUSIONS:
%  pure fun call costs ~2.3ns
%  pure fun param costs ~0.4ns

% 9.4ns+-0.2
bench_unrolled_nif() ->
	repeat(1000, return_ok_nif()).

% 9.5ns+-0.2
bench_unrolled_nif_1() ->
	repeat(1000, return_ok_nif(0)).

% 10.5ns+-0.1
bench_unrolled_nif_2() ->
	repeat(1000, return_ok_nif(0, 0)).

% CONCLUSION:
%  nif call costs ~9.4ns
%  nif param costs ~1ns (without unpacking in nif)

% 7.7ns+-0.1
bench_repeated_ok() ->
	bench_repeated_ok(1000).
bench_repeated_ok(X) when X > 0 ->
	ok,
	bench_repeated_ok(X-1);
bench_repeated_ok(0) ->
	ok.

% 5.9ns+-0.1
bench_repeated_ok_match() ->
	bench_repeated_ok_match(1000).
bench_repeated_ok_match(0) ->
	ok;
bench_repeated_ok_match(X) ->
	ok,
	bench_repeated_ok_match(X-1).

% 7.9ns+-0.2
bench_repeated_add() ->
	bench_repeated_add(1000).
bench_repeated_add(X) when X > 0 ->
	1+1,
	bench_repeated_add(X-1);
bench_repeated_add(0) ->
	ok.

% CONCLUSION:
%  the guard version is slower; the guard costs ~2ns per check more than skipping a clause.

% 11.3ns+-0.2
bench_repeated_fun() ->
	bench_repeated_fun(1000).
bench_repeated_fun(X) when X > 0 ->
	return_ok_pure(),
	bench_repeated_fun(X-1);
bench_repeated_fun(0) ->
	ok.

% 11.3ns+-0.1
bench_repeated_fun_1() ->
	bench_repeated_fun_1(1000).
bench_repeated_fun_1(X) when X > 0 ->
	return_ok_pure(0),
	bench_repeated_fun_1(X-1);
bench_repeated_fun_1(0) ->
	ok.

% 12ns+-0.4
bench_repeated_fun_2() ->
	bench_repeated_fun_2(1000).
bench_repeated_fun_2(X) when X > 0 ->
	return_ok_pure(0, 0),
	bench_repeated_fun_2(X-1);
bench_repeated_fun_2(0) ->
	ok.

% CONCLUSION:
%  consistent with bench_unrolled_fun: ~2.3ns to make a call, and ~0.3ns per param.

% 11.2ns+-0.2
bench_repeated_fun_1_X() ->
	bench_repeated_fun_1_X(1000).
bench_repeated_fun_1_X(X) when X > 0 ->
	return_ok_pure(X),
	bench_repeated_fun_1_X(X-1);
bench_repeated_fun_1_X(0) ->
	ok.

% 12ns+-0.2
bench_repeated_fun_2_X() ->
	bench_repeated_fun_2_X(1000).
bench_repeated_fun_2_X(X) when X > 0 ->
	return_ok_pure(X, X),
	bench_repeated_fun_2_X(X-1);
bench_repeated_fun_2_X(0) ->
	ok.

% CONCLUSION:
%  Passing a variable costs the same as passing a constant. Phew.

% 15.0ns+-0.1
bench_repeated_subtract_fun_param() ->
	bench_repeated_subtract_fun_param(1000).
bench_repeated_subtract_fun_param(X) when X > 0 ->
	return_ok_pure(X-1),
	bench_repeated_subtract_fun_param(X-1);
bench_repeated_subtract_fun_param(0) ->
	ok.

% 14.3ns+-0.2
bench_repeated_subtract_1_fun() ->
	bench_repeated_subtract_1_fun(1000).
bench_repeated_subtract_1_fun(X) when X > 0 ->
	subtract_1_pure(X),
	bench_repeated_subtract_1_fun(X-1);
bench_repeated_subtract_1_fun(0) ->
	ok.

% 15.5ns+-0.5
bench_repeated_subtract_fun() ->
	bench_repeated_subtract_fun(1000).
bench_repeated_subtract_fun(X) when X > 0 ->
	subtract_pure(X, 1),
	bench_repeated_subtract_fun(X-1);
bench_repeated_subtract_fun(0) ->
	ok.

% CONCLUSION:
%  subtraction X-1 into a param costs 3ns. Probably due to temp var?
%  subtraction X-1 in a fun costs 2.3ns
%
%  so cost of loop is 3ns + 2.3ns + 2ns = 7.3ns.

% 13.2ns+-0.2
bench_repeated_subtract_fun_match() ->
	bench_repeated_subtract_fun_match(1000).
bench_repeated_subtract_fun_match(0) ->
	ok;
bench_repeated_subtract_fun_match(X) ->
	subtract_pure(X, 1),
	bench_repeated_subtract_fun_match(X-1).

% CONCLUSION:
%  Confirms above conclusions. Guard costs ~2ns more than match.

% 18.3 +- 0.5 ns
bench_repeated_nif() ->
	bench_repeated_nif(1000).
bench_repeated_nif(X) when X > 0 ->
	return_ok_nif(),
	bench_repeated_nif(X-1);
bench_repeated_nif(0) ->
	ok.

% 19ns+-0.3
bench_repeated_nif_2() ->
	bench_repeated_nif_2(1000).
bench_repeated_nif_2(X) when X > 0 ->
	return_ok_nif(X, X),
	bench_repeated_nif_2(X-1);
bench_repeated_nif_2(0) ->
	ok.

% CONCLUSION:
%  consistent with bench_unrolled_nif? ~9.3ns to make a nif call. First param is cheap, second more costly.

-record(record_0, {}).
-record(record_1, {a}).
-record(record_5, {a, b, c, d, e}).
-record(record_10, {a, b, c, d, e, f, g, h, i, j}).

% FIX -- these are nif!
% ~16.5ns+-0.2
bench_repeated_fun_0_nif() ->
	bench_repeated_fun_0_nif(1000).
bench_repeated_fun_0_nif(0) ->
	ok;
bench_repeated_fun_0_nif(X) ->
	return_ok_nif(0),
	bench_repeated_fun_0_nif(X-1).

% ~16.5ns+-0.2
bench_repeated_fun_tuple_0_nif() ->
	bench_repeated_fun_tuple_0_nif(1000).
bench_repeated_fun_tuple_0_nif(0) ->
	ok;
bench_repeated_fun_tuple_0_nif(X) ->
	return_ok_nif({}),
	bench_repeated_fun_tuple_0_nif(X-1).

% ~16.5ns+-0.2
bench_repeated_fun_record_0_nif() ->
	bench_repeated_fun_record_0_nif(1000).
bench_repeated_fun_record_0_nif(0) ->
	ok;
bench_repeated_fun_record_0_nif(X) ->
	return_ok_nif(#record_0{}),
	bench_repeated_fun_record_0_nif(X-1).

% 16.9ns+-0.2
bench_repeated_fun_record_10_nif() ->
	bench_repeated_fun_record_10_nif(1000).
bench_repeated_fun_record_10_nif(0) ->
	ok;
bench_repeated_fun_record_10_nif(X) ->
	return_ok_nif(#record_10{}),
	bench_repeated_fun_record_10_nif(X-1).

% 9.5ns+-0.03
bench_repeated_fun_record_10() ->
	bench_repeated_fun_record_10(1000).
bench_repeated_fun_record_10(0) ->
	ok;
bench_repeated_fun_record_10(X) ->
	return_ok_pure(#record_10{}),
	bench_repeated_fun_record_10(X-1).

% CONCLUSION:
%   Creating longer default-initialised records is basically free. (0.04ns per entry?)
%   Sending said records to NIFs is free also.

% 12.3ns+-0.1
bench_repeated_fun_set_record_1() ->
	bench_repeated_fun_set_record_1(1000).
bench_repeated_fun_set_record_1(0) ->
	ok;
bench_repeated_fun_set_record_1(X) ->
	record_1_set(#record_1{}),
	bench_repeated_fun_set_record_1(X-1).

% 30.3ns+-0.2ns
bench_repeated_fun_set_record_5() ->
	bench_repeated_fun_set_record_5(1000).
bench_repeated_fun_set_record_5(0) ->
	ok;
bench_repeated_fun_set_record_5(X) ->
	record_5_set(#record_5{}),
	bench_repeated_fun_set_record_5(X-1).

% 33.5ns+-0.3ns
bench_repeated_fun_set_record_10() ->
	bench_repeated_fun_set_record_10(1000).
bench_repeated_fun_set_record_10(0) ->
	ok;
bench_repeated_fun_set_record_10(X) ->
	record_10_set(#record_10{}),
	bench_repeated_fun_set_record_10(X-1).

% 30ns
bench_repeated_fun_setelement_record_10() ->
	bench_repeated_fun_setelement_record_10(1000).
bench_repeated_fun_setelement_record_10(0) ->
	ok;
bench_repeated_fun_setelement_record_10(X) ->
	record_10_setelement(#record_10{}),
	bench_repeated_fun_setelement_record_10(X-1).
% COMPILES IDENTICAL TO ABOVE.

% 36.0ns+-0.1ns
bench_repeated_fun_set_record_10_2() ->
	bench_repeated_fun_set_record_10_2(1000).
bench_repeated_fun_set_record_10_2(0) ->
	ok;
bench_repeated_fun_set_record_10_2(X) ->
	record_10_set_2(#record_10{}),
	bench_repeated_fun_set_record_10_2(X-1).
% USES SETELEMENT HACK ONCE.

% 47ns
bench_repeated_fun_set_record_10_9() ->
	bench_repeated_fun_set_record_10_9(1000).
bench_repeated_fun_set_record_10_9(0) ->
	ok;
bench_repeated_fun_set_record_10_9(X) ->
	record_10_set_9(#record_10{}),
	bench_repeated_fun_set_record_10_9(X-1).

% 48ns
bench_repeated_fun_set_record_10_9_plus() ->
	bench_repeated_fun_set_record_10_9_plus(1000).
bench_repeated_fun_set_record_10_9_plus(0) ->
	ok;
bench_repeated_fun_set_record_10_9_plus(X) ->
	record_10_set_9_plus(#record_10{}),
	bench_repeated_fun_set_record_10_9_plus(X-1).
% THESE TWO BUILD AN 11-TUPLE (compile identical, too).

% 12.3ns
bench_repeated_fun_set_record_10_10() ->
	bench_repeated_fun_set_record_10_10(1000).
bench_repeated_fun_set_record_10_10(0) ->
	ok;
bench_repeated_fun_set_record_10_10(X) ->
	record_10_set_10(#record_10{}),
	bench_repeated_fun_set_record_10_10(X-1).
% RETURNS A LITERAL.

% CONCLUSION:
%  updating a huge record is pretty costly!
%  updating the /entire/ record to a static value is free.

% 12.3ns
bench_repeated_fun_record_10_match() ->
	bench_repeated_fun_record_10_match(1000).
bench_repeated_fun_record_10_match(0) ->
	ok;
bench_repeated_fun_record_10_match(X) ->
	record_10_match(#record_10{}),
	bench_repeated_fun_record_10_match(X-1).

% 13.6ns+-0.2
bench_repeated_fun_record_10_match_1() ->
	bench_repeated_fun_record_10_match_1(1000).
bench_repeated_fun_record_10_match_1(0) ->
	ok;
bench_repeated_fun_record_10_match_1(X) ->
	record_10_match_1(#record_10{}),
	bench_repeated_fun_record_10_match_1(X-1).

% 13.6ns+-0.1
bench_repeated_fun_record_10_extract() ->
	bench_repeated_fun_record_10_extract(1000).
bench_repeated_fun_record_10_extract(0) ->
	ok;
bench_repeated_fun_record_10_extract(X) ->
	record_10_extract(#record_10{}),
	bench_repeated_fun_record_10_extract(X-1).

% CONCLUSION:
%  extracting a field takes the same time as matching -- 1.3ns
%  matching a record in a clause or update takes about 2.8ns.

% 40ns
bench_repeated_fun_record_10_nonstatic() ->
	bench_repeated_fun_record_10_nonstatic(1000).
bench_repeated_fun_record_10_nonstatic(0) ->
	ok;
bench_repeated_fun_record_10_nonstatic(X) ->
	return_ok_pure(#record_10{a=X}),
	bench_repeated_fun_record_10_nonstatic(X-1).

make_record_10() -> #record_10{}.

% 30ns. Ugly!
bench_repeated_fun_record_10_nonstatic_2() ->
	bench_repeated_fun_record_10_nonstatic_2(1000).
bench_repeated_fun_record_10_nonstatic_2(0) ->
	ok;
bench_repeated_fun_record_10_nonstatic_2(X) ->
	A=make_record_10(),
	return_ok_pure(A#record_10{a=X}),
	bench_repeated_fun_record_10_nonstatic_2(X-1).

% 43ns.
bench_nine_tuple_nif() ->
	bench_nine_tuple_nif(1000).
bench_nine_tuple_nif(0) ->
	ok;
bench_nine_tuple_nif(X) ->
	nine_tuple_nif(X),
	bench_nine_tuple_nif(X-1).

% 47ns
atom() -> an_atom.
bench_atom_to_list() ->
	bench_atom_to_list(1000).
bench_atom_to_list(0) ->
	ok;
bench_atom_to_list(X) ->
	atom_to_list(atom()),
	bench_atom_to_list(X-1).

% 164ns
list() -> "a_list_".
bench_list_to_atom() ->
	bench_list_to_atom(1000).
bench_list_to_atom(0) ->
	ok;
bench_list_to_atom(X) ->
	list_to_atom(list()),
	bench_list_to_atom(X-1).

% 76ns
bench_list_to_binary() ->
	bench_list_to_binary(1000).
bench_list_to_binary(0) ->
	ok;
bench_list_to_binary(X) ->
	list_to_binary(list()),
	bench_list_to_binary(X-1).

% 20.3ns
bench_ccy_convert_1() ->
	bench_ccy_convert_1(1000).
bench_ccy_convert_1(0) ->
	ok;
bench_ccy_convert_1(X) ->
	ccy_convert("111"),
	bench_ccy_convert_1(X-1).

% 20.7ns
bench_ccy_convert_10() ->
	bench_ccy_convert_10(1000).
bench_ccy_convert_10(0) ->
	ok;
bench_ccy_convert_10(X) ->
	ccy_convert("000"),
	bench_ccy_convert_10(X-1).

% 158ns
bench_unrolled_return_resource_nif() ->
	repeat(1000, return_resource_nif()).

% 176ns
bench_unrolled_return_free_resource_nif() ->
	repeat(1000, free_resource_nif(return_keep_resource_nif())).

% 14.9ns+-0.2
bench_unrolled_only_inspect_resource_nif() ->
	R = return_resource_nif(),
	repeat(1000, only_inspect_resource_nif(R)).

% 16.0ns (cache hot, of course)
bench_unrolled_inspect_resource_nif() ->
	R = return_resource_nif(),
	repeat(1000, inspect_resource_nif(R)).

% 20.0ns+-0.1
bench_unrolled_double_inspect_resource_nif() ->
	R = return_resource_nif(),
	repeat(1000, double_inspect_resource_nif(R)).

% 17.7ns+-0.4
bench_unrolled_increment_resource_nif() ->
	R = return_resource_nif(),
	repeat(1000, increment_resource_nif(R)).

% CONCLUSION:
%  resource creation is slow! Takes ~150ns.
%  inspecting is ~4ns
%  free takes ~3ns

repeat(F, N) ->
	{T, ok} = timer:tc(?MODULE, repeat_, [F, N]),
	T / N.

repeat_(_, 0) ->
	ok;
repeat_(F, N) ->
	F(),
	repeat_(F, N-1).

return_ok_pure() -> ok.
return_ok_pure(_) -> ok.
return_ok_pure(_, _) -> ok.
return_ok_nif() -> erlang:error(nif_not_loaded).
return_ok_nif(_) -> erlang:error(nif_not_loaded).
return_ok_nif(_, _) -> erlang:error(nif_not_loaded).
nine_tuple_nif(_) -> erlang:error(nif_not_loaded).
return_resource_nif() -> erlang:error(nif_not_loaded).
return_keep_resource_nif() -> erlang:error(nif_not_loaded).
inspect_resource_nif(_) -> erlang:error(nif_not_loaded).
increment_resource_nif(_) -> erlang:error(nif_not_loaded).
only_inspect_resource_nif(_) -> erlang:error(nif_not_loaded).
double_inspect_resource_nif(_) -> erlang:error(nif_not_loaded).
free_resource_nif(_) -> erlang:error(nif_not_loaded).
subtract_1_pure(X) -> X - 1.
subtract_pure(X, Y) -> X - Y.

record_1_set(A) -> A#record_1{a=1}.
record_5_set(A) -> A#record_5{a=1}.
record_10_set(A) -> A#record_10{a=1}.
record_10_setelement(A) -> setelement(2, A, 1).
record_10_set_2(A) -> A#record_10{a=1, b=2}.
record_10_set_9(A) -> A#record_10{a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8, i=9}.
record_10_set_9_plus(A) -> A#record_10{a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8, i=9, j=A#record_10.j}.
record_10_set_10(A) -> A#record_10{a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8, i=9, j=10}.
record_10_match(#record_10{}) -> ok.
record_10_match_1(#record_10{j=X}) -> X.
record_10_match_extract(A=#record_10{j=X}) -> {X, A#record_10.i}.
record_10_extract(A) -> A#record_10.j.

ccy_convert("111") -> 1;
ccy_convert("222") -> 2;
ccy_convert("333") -> 3;
ccy_convert("444") -> 4;
ccy_convert("555") -> 5;
ccy_convert("666") -> 6;
ccy_convert("777") -> 7;
ccy_convert("888") -> 8;
ccy_convert("999") -> 9;
ccy_convert([a|"00"]) -> a;
ccy_convert("000") -> 0;
ccy_convert(aaaa1) -> aaaa1;
ccy_convert(aaaa2) -> aaaa2.
