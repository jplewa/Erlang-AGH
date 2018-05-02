%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. kwi 2018 19:01
%%%-------------------------------------------------------------------
-module(funEx2).
-author("julia").

%-import(qsort, randomElems/3).
%% API
-export([map/2, filter/2, digSum/1, q3/0]).

% Zaimplementuj samodzielnie funkcje wyższego rzędu map/2 oraz filter/2.
map(F, List) -> [F(X) || X <- List].
filter(F, List) -> [X || X <- List, F(X)].

% Stwórz funkcję, która policzy sumę cyfr w liczbie. Użyj do tego lists:foldl/3.
digSum(N) -> lists:foldl(fun(X, Acc) -> Acc + list_to_integer([X]) end, 0, integer_to_list(N,10)).

% Przy pomocy funkcji lists:filter/2 wybierz z listy miliona losowych liczb takie, w których suma cyfr jest podzielna przez 3.
q3() -> lists:filter(fun(X) -> X rem 3 == 0 end, qsort:randomElems(1000000,1, 100)).