%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. kwi 2018 14:48
%%%-------------------------------------------------------------------
-module(pingpong).
-author("julia").

%% API
-export([start/0, stop/0, play/1]).

% Po otrzymaniu wiadomości, proces ping ma rozpocząć wymianę N wiadomości z procesem pong.
% Przy odebraniu każdej wiadomości procesy mają wypisać na standardowe wyjście informację o przebiegu odbijania.
% Dla zwiększenia czytelności działania warto użyć funkcji timer:sleep(Milisec).
% Procesy ping i pong powinny samoczynnie kończyć działanie po 20 sekundach bezczynności.

ping_fun() ->
  receive
    0 -> io:format("Done!~n"), ping_fun();
    N when is_integer(N)->
      io:format("Ping (~B)~n", [N]),
      timer:sleep(1000),
      pong ! (N-1),
      ping_fun();
    stop -> ok;
    _ -> ping_fun()
  after
    20000 -> ok
  end.

pong_fun() ->
  receive
    0 -> io:format("Done!~n"), pong_fun();
    N when is_integer(N) ->
      io:format("Pong (~B)~n", [N]),
      timer:sleep(1000),
      ping ! (N-1),
      pong_fun();
    stop -> ok;
    _ -> pong_fun()
  after
    20000 -> ok
  end.

%start/0, która utworzy 2 procesy i zarejestruje je pod nazwami ping i pong,
%aby dzialal spawn(MFA), nalezy dodac do eksportu
start() ->
  register(ping, spawn(fun() -> ping_fun() end)),
  register(pong, spawn(fun() -> pong_fun() end)).

%stop/0, która zakończy oba procesy,
stop() -> ping ! stop, pong ! stop.

%play/1, która wyśle wiadomość z liczbą całkowitą N do procesu ping.
play(N) when ((is_integer(N)) and (N >= 0))  -> ping ! N.