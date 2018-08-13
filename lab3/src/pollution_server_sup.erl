%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. maj 2018 19:34
%%%-------------------------------------------------------------------
-module(pollution_server_sup).
-author("julia").

-import('pollution_server', [start_link/0]).
-export([start/0, stop/0]).

init() ->
  process_flag(trap_exit, true),
  Pid = pollution_server:start_link(),
  %io:format("pollution_server ~p is up~n", [Pid]),
  monitor(Pid).

monitor(Pid) ->
  receive
    {'EXIT', Pid, normal} ->
      %io:format("pollution_server ~p is down~n", [Pid]),
      ok;
    {'EXIT', Pid, _} ->
      %io:format("pollution_server ~p is down~n", [Pid]),
      init();
    _-> monitor(Pid)
  end.

start() -> spawn(fun() -> init() end).
stop() -> pollution_server:stop().