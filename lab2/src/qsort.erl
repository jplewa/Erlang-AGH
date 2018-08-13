%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. kwi 2018 16:19
%%%-------------------------------------------------------------------
-module(qsort).
-author("julia").

%% API
-export([lessThan/2, grtEqThan/2, qs/1, randomElems/3, compareSpeeds/3]).


% Funkcja lessThan/2, która dla listy i zadanego argumentu wybierze te elementy
% które są mniejsze od argumentu. Wykorzystaj list comprehensions.

lessThan(List, Arg) -> [X || X <- List, X < Arg].

% Funkcja grtEqThan/2, która dla listy i zadanego argumentu wybierze te elementy
% które są większe bądź równe od argumentu. Tutaj też wykorzystaj list comprehensions.

grtEqThan(List, Arg) -> [X || X <- List, X >= Arg].

% Funkcja qs/1 implementująca algorytm quicksort:
qs([]) -> [];
qs([Pivot|Tail]) -> qs(lessThan(Tail,Pivot)) ++ [Pivot] ++ qs(grtEqThan(Tail,Pivot)).


% Funkcja randomElems/3, która zwróci listę losowych elementów z zakresu [Min,Max] o rozmiarze N.
% Wykorzystaj list comprehensions oraz rand:uniform/1 i lists:seq/2.

% randomElems(N,Min,Max)-> [Y || Y <- (lists:map(fun(_) -> lists:nth((Min-1+rand:uniform(Max - Min + 1)), lists:seq(Min,Max)) end, lists:seq(1,N)))].
randomElems(N, Min, Max) -> [Min-1+rand:uniform(Max - Min + 1) || _ <- lists:seq(1,N)].


%Funkcja compareSpeeds/3 która porówna prędkości działania podanych algorytmów sortujących dla zadanej listy.
% Wykorzystaj do tego funkcję timer:tc

compareSpeeds(List, Fun1, Fun2) ->
  {element(1, timer:tc(Fun1, [List])), element(1, timer:tc(Fun2, [List]))}.
