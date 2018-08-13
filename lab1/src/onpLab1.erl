%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. mar 2018 13:08
%%%-------------------------------------------------------------------
-module('onpLab1').
-author("julia").

%% API
-compile(export_all).

onp_parse(Expr) ->
  string:tokens(Expr, " ").

onp_get_float({N, _}) -> N.

onp_reduce([], [Head | _]) -> Head;
onp_reduce(["+" | Tail], [First | [Second | StackTail]]) -> onp_reduce(Tail, [(Second + First) | StackTail]);
onp_reduce(["*" | Tail], [First | [Second | StackTail]]) -> onp_reduce(Tail, [(Second * First) | StackTail]);
onp_reduce(["/" | _], [0.0 |  _]) -> io:format("Infinity!\n");
onp_reduce(["/" | Tail], [First | [Second | StackTail]]) -> onp_reduce(Tail, [(Second / First) | StackTail]);
onp_reduce(["-" | Tail], [First | [Second | StackTail]]) -> onp_reduce(Tail, [(Second - First) | StackTail]);
onp_reduce(["pow" | Tail], [First | [Second | StackTail]]) -> onp_reduce(Tail, [(math:pow(Second,  First)) | StackTail]);
onp_reduce(["sqrt" | _], [First | _]) when First < 0.0 -> io:format("Let's not imagine things!\n");
onp_reduce(["sqrt" | Tail], [First | StackTail]) -> onp_reduce(Tail, [math:sqrt(First) | StackTail]);
onp_reduce(["cos" | Tail], [First | StackTail]) -> onp_reduce(Tail, [math:cos(First) | StackTail]);
onp_reduce(["tan" | Tail], [First | StackTail]) -> onp_reduce(Tail, [math:tan(First) | StackTail]);
onp_reduce(["sin" | Tail], [First | StackTail]) -> onp_reduce(Tail, [math:sin(First) | StackTail]);
onp_reduce([Head | Tail], Stack) -> onp_reduce(Tail, [onpLab1:onp_get_float(string:to_float(Head ++ ".0")) | Stack]).

onp_calculator(Expr) -> onpLab1:onp_reduce(onp_parse(Expr), []).

% 1 + 2 * 3 - 4 / 5 + 6                               1 2 3 * + 4 5 / - 6 +                 12.2
% 1 + 2 + 3 + 4 + 5 + 6 * 7                           1 2 3 4 5 + + + + 6 7 * +             57
% ( (4 + 7) / 3 ) * (2 - 19)                          2 19 - 4 7 +  3 / *                   -62.(3)
% 17 * (31 + 4) / ( (26 - 15) * 2 - 22 ) - 1          17 31 4 + * 26 15 - 2 * 22 - / 1 -
