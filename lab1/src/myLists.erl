%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. mar 2018 15:11
%%%-------------------------------------------------------------------
-module(myLists).
-author("julia").
%proplista
%% API
-export([contains/2, duplicateElements/1, sumFloats/1, sumFloatsTail/2, myFun/1, factorial/1, factorial2/1, factorial3/1, funkcja/1]).

contains([], _) -> false;
contains([Head | _], Head) -> true;
contains([_ | Tail], X) -> contains(Tail, X).

duplicateElements([]) -> [];
duplicateElements([Head | Tail]) -> [Head, Head] ++ duplicateElements(Tail).

sumFloats([]) -> 0.0;
sumFloats([Head | Tail]) -> Head + sumFloats(Tail).

sumFloatsTail([], Sum) -> Sum;
sumFloatsTail([Head | Tail], Sum) -> sumFloatsTail(Tail, Sum+Head).

myFun(N) when N == 13 -> ala;
myFun(N) when is_integer(N) and (N rem 2 == 0) ->
  case N of
    6 when (7 == 3) -> toszesc;
    _ -> 0
  end;

myFun(_) -> ups.

factorial(N) when is_integer(N) and (N =< 0)
  -> 1;
factorial(N)
  -> N * factorial(N-1).

factorial2(N) ->
  case N of
    0 -> 1;
    _ -> N * factorial(N-1)
  end.

factorial3(N) ->
  if
    N =< 0 -> 1;
    true -> N * factorial3(N-1)
  end.

funkcja([]) -> io:format("dwf\n");
funkcja([Head | Tail]) -> io:format("bu\n").

% Kalkulator ONP
%  http://pl.wikipedia.org/wiki/Odwrotna_notacja_polska
%  zapisz w onp następujące wyrażenia :
%  1 + 2 * 3 - 4 / 5 + 6
%  1 + 2 + 3 + 4 + 5 + 6 * 7
%  ( (4 + 7) / 3 ) * (2 - 19)
%  17 * (31 + 4) / ( (26 - 15) * 2 - 22 ) - 1
%  utwórz moduł onp z funkcją onp/1, która dla poprawnego wyrażenia ONP zwróci wynik
%  funkcja powinna obsługiwać operacje +, -, *, / oraz liczby całkowite
%  do parsowania wyrażenia wykorzystaj funkcję string:tokens/2
%  do konwertowania ciągów znaków na liczby wykorzystaj funkcję list_to_integer/1
%  sprawdź działanie dla zapisanych wyrażeń (http://lidia-js.kis.p.lodz.pl/LM_lab/cwiczenia.php?id=oblicz_onp)

% Zadanie domowe
%  Dokończ zadania z zajęć.
%  Dodaj do kalkulatora operacje sqrt, pow i funkcje trygonometryczne
%  Dodaj do kalkulatora obsługę liczb zmiennoprzecinkowych w wyrażeniach