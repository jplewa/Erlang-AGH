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

-import('pollution_server', [start/0, stop/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getDeviation/3, getMonitor/0, crash/0]).
-export([startSupervisor/0, stopSupervisor/0]).

initSupervisor() ->
  process_flag(trap_exit, true),
  pollution_server:start(),
  io:format("pollution_server ~p is up~n", [whereis(pollution_server)]),
  link(whereis(pollution_server)),
  monitor(whereis(pollution_server)).

monitor(Pid) ->
  receive
    {'EXIT', Pid, normal} -> io:format("pollution_server ~p is down~n", [Pid]), ok;
    {'EXIT', Pid, _} -> io:format("pollution_server ~p is down~n", [Pid]), initSupervisor();
    _-> monitor(Pid)
  end.

startSupervisor() -> spawn(fun() -> initSupervisor() end).
stopSupervisor() -> pollution_server:stop().