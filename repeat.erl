-module(repeat).

-compile([export_all]).


parse_transform(AST, _Opts) ->
	uberpt:ast_apply(
		AST,
		fun
			({call, _, {atom, _, repeat}, [{integer, _, Count} | Calls]}) ->
				lists:append(lists:duplicate(Count, Calls));
			(Other) ->
				[Other]
		end
	).
