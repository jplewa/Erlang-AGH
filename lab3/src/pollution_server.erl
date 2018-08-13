%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. kwi 2018 15:51
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("julia").

%% API
-import('pollution', [getStation/1, createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3, getDeviation/4]).
-export([start/0, start_link/0, stop/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getDeviation/3, getMonitor/0, crash/0]).


% client API

start() -> register(pollution_server, spawn(fun() -> init() end)).

start_link() -> register(pollution_server, Pid = spawn_link(fun() -> init() end)), Pid.

stop() -> sendRequest({stop, self()}).

addStation(Name, Coordinates) -> sendRequest({addStation, self(), Name, Coordinates}).

addValue(Station, Date, Type, Value) -> sendRequest({addValue, self(), Station, Date, Type, Value}).

removeValue(Station, Date, Type) -> sendRequest({removeValue, self(), Station, Date, Type}).

getOneValue(Station, Date, Type) -> sendRequest({getOneValue, self(), Station, Date, Type}).

getStationMean(Station, Type) -> sendRequest({getStationMean, self(), Station, Type}).

getDailyMean(Date, Type) -> sendRequest({getDailyMean, self(), Date, Type}).

getDeviation(Date, Hour, Type) -> sendRequest({getDeviation, self(), Date, Hour, Type}).

getMonitor() -> sendRequest({getMonitor, self()}).

crash() -> pollution_server ! crashServer.


% server and helper functions

init() -> loop(pollution:createMonitor()).

sendRequest(Request) ->
  pollution_server ! Request,
  receive
    Reply -> Reply
  end.

handleRequest(addStation, Monitor, {Name, Coordinates}) ->
  NewMonitor = pollution:addStation(Name, Coordinates, Monitor),
  case (NewMonitor =:= already_exists) of
    true -> {NewMonitor, Monitor};
    false -> {ok, NewMonitor}
  end;

handleRequest(addValue, Monitor, {Station, Date, Type, Value}) ->
  NewMonitor = pollution:addValue(Station, Date, Type, Value, Monitor),
  case ((NewMonitor =:= already_exists) or (NewMonitor =:= no_such_station)) of
    true -> {NewMonitor, Monitor};
    false -> {ok, NewMonitor}
  end;

handleRequest(removeValue, Monitor, {Station, Date, Type}) ->
  NewMonitor = pollution:removeValue(Station, Date, Type, Monitor),
  case ((NewMonitor =:= no_such_measurement) or (NewMonitor =:= no_such_station)) of
    true -> {NewMonitor, Monitor};
    false -> {ok, NewMonitor}
  end.

loop(Monitor) ->
  receive
    {addStation, Pid, Name, Coordinates} ->
      {Msg, State} = handleRequest(addStation, Monitor, {Name, Coordinates}),
      Pid ! Msg,
      loop(State);
    {addValue, Pid, Station, Date, Type, Value} ->
      {Msg, State} = handleRequest(addValue, Monitor, {Station, Date, Type, Value}),
      Pid ! Msg,
      loop(State);
    {removeValue, Pid, Station, Date, Type} ->
      {Msg, State} = handleRequest(removeValue, Monitor, {Station, Date, Type}),
      Pid ! Msg,
      loop(State);
    {getOneValue, Pid, Station, Date, Type} ->
      Pid ! pollution:getOneValue(Station, Date, Type, Monitor),
      loop(Monitor);
    {getStationMean, Pid, Station, Type} ->
      Pid ! pollution:getStationMean(Station, Type, Monitor),
      loop(Monitor);
    {getDailyMean, Pid, Date, Type} ->
      Pid ! pollution:getDailyMean(Date, Type, Monitor),
      loop(Monitor);
    {getDeviation, Pid, Date, Hour, Type} ->
      Pid ! pollution:getDeviation(Date, Hour, Type, Monitor),
      loop(Monitor);
    {stop, Pid} -> Pid ! ok;
    {getMonitor, Pid} ->
      Pid ! Monitor,
      loop(Monitor);
    crashServer -> 1 = 0;
    _ -> loop(Monitor)
  end.