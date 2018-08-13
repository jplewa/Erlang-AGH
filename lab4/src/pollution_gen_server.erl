%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. maj 2018 20:34
%%%-------------------------------------------------------------------
-module(pollution_gen_server).
-behavior(gen_server).
-author("julia").

%% API
-import('pollution', [getStation/1, createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3, getDeviation/4]).
-import('pollution_gen_server_backup', [setBackupMonitor/1, getBackupMonitor/0]).
-export([start/0, stop/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getDeviation/3, getMonitor/0, crash/0]).
-export([init/1, start_link/1, handle_call/3, handle_cast/2, terminate/2]).
-export([backup/1]).

start() -> start_link(pollution:createMonitor()).
start_link(InitValue) -> gen_server:start_link({local, pollution_gen_server},?MODULE,InitValue,[]).
stop() -> gen_server:cast(pollution_gen_server, stop).
addStation(Name, Coordinates) -> gen_server:call(pollution_gen_server,{addStation, Name, Coordinates}).
addValue(Station, Date, Type, Value) -> gen_server:call(pollution_gen_server,{addValue, Station, Date, Type, Value}).
removeValue(Station, Date, Type) -> gen_server:call(pollution_gen_server, {removeValue, Station, Date, Type}).
getOneValue(Station, Date, Type) -> gen_server:call(pollution_gen_server, {getOneValue, Station, Date, Type}).
getStationMean(Station, Type) -> gen_server:call(pollution_gen_server, {getStationMean, Station, Type}).
getDailyMean(Date, Type) -> gen_server:call(pollution_gen_server, {getDailyMean, Date, Type}).
getDeviation(Date, Hour, Type) -> gen_server:call(pollution_gen_server, {getDeviation, Date, Hour, Type}).
getMonitor() -> gen_server:call(pollution_gen_server, getMonitor).
crash() -> gen_server:cast(pollution_gen_server, crashServer).

init(InitialValue) ->
  case (whereis(pollution_gen_server_backup) =:= undefined) of
    true -> {ok, InitialValue};
    false -> {ok, pollution_gen_server_backup:getBackupMonitor()}
end.

handle_cast(crashServer, Monitor) ->
  _Value = 1/0,
  {noreply, Monitor};

handle_cast(stop, Monitor) -> {stop, normal, Monitor}.

terminate(Reason, Monitor) -> backup(Monitor), Reason.

handle_call({addStation, Name, Coordinates}, _From, Monitor) ->
  NewMonitor = pollution:addStation(Name, Coordinates, Monitor),
  case (NewMonitor =:= already_exists) of
    true -> {reply, NewMonitor, Monitor};
    false -> {reply, ok, NewMonitor}
  end;

handle_call({addValue, Station, Date, Type, Value}, _From, Monitor) ->
  NewMonitor = pollution:addValue(Station, Date, Type, Value, Monitor),
  case ((NewMonitor =:= already_exists) orelse (NewMonitor =:= no_such_station)) of
    true -> {reply, NewMonitor, Monitor};
    false -> {reply, ok, NewMonitor}
  end;

handle_call({removeValue, Station, Date, Type}, _From, Monitor) ->
  NewMonitor = pollution:removeValue(Station, Date, Type, Monitor),
  case ((NewMonitor =:= no_such_measurement) orelse (NewMonitor =:= no_such_station)) of
  true -> {reply, NewMonitor, Monitor};
  false -> {reply, ok, NewMonitor}
  end;

handle_call({getOneValue, Station, Date, Type}, _From, Monitor) ->
  {reply, pollution:getOneValue(Station, Date, Type, Monitor), Monitor};

handle_call({getStationMean, Station, Type}, _From, Monitor) ->
  {reply, pollution:getStationMean(Station, Type, Monitor), Monitor};

handle_call({getDailyMean, Date, Type}, _From, Monitor) ->
  {reply, pollution:getDailyMean(Date, Type, Monitor), Monitor};

handle_call({getDeviation, Date, Hour, Type}, _From, Monitor) ->
  {reply, pollution:getDeviation(Date, Hour, Type, Monitor), Monitor};

handle_call(getMonitor, _From, Monitor) ->
  {reply, Monitor, Monitor}.

backup(Monitor) ->
  case ((whereis(pollution_gen_server_backup) /= undefined)) of
    true -> gen_server:cast(pollution_gen_server_backup, {setBackupMonitor, Monitor}), ok;
    false -> ok
  end.