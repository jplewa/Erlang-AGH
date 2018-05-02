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
-export([start/0, stop/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getDeviation/3, getMonitor/0]).

start() -> register(pollution_server, spawn(fun() -> init() end)).

init() -> loop(pollution:createMonitor()).

loop(Monitor) ->
  receive
    {Pid, addStation, Name, Coordinates} ->
      NewMonitor = pollution:addStation(Name, Coordinates, Monitor),
      case (NewMonitor =:= already_exists) of
        true ->
          Pid ! NewMonitor,
          loop(Monitor);
        false ->
          Pid ! ok,
          loop(NewMonitor)
      end;
    {Pid, addValue, Station, Date, Type, Value} ->
      NewMonitor = pollution:addValue(Station, Date, Type, Value, Monitor),
      case (NewMonitor =:= already_exists) of
        true ->
          Pid ! NewMonitor,
          loop(Monitor);
        false ->
          Pid ! ok,
          loop(NewMonitor)
      end;
    {Pid, removeValue, Station, Date, Type} ->
      NewMonitor = pollution:removeValue(Station, Date, Type, Monitor),
      case (NewMonitor =:= no_such_measurement) of
        true ->
          Pid ! NewMonitor,
          loop(Monitor);
        false ->
          Pid ! ok,
          loop(NewMonitor)
      end;
    {Pid, getOneValue, Station, Date, Type} ->
      Pid ! pollution:getOneValue(Station, Date, Type, Monitor),
      loop(Monitor);
    {Pid, getStationMean, Station, Type} ->
      Pid ! pollution:getStationMean(Station, Type, Monitor),
      loop(Monitor);
    {Pid, getDailyMean, Date, Type} ->
      Pid ! pollution:getDailyMean(Date, Type, Monitor),
      loop(Monitor);
    {Pid, getDeviation, Date, Hour, Type} ->
      Pid ! pollution:getDeviation(Date, Hour, Type, Monitor),
      loop(Monitor);
    {Pid, stop} -> Pid ! ok;
    {Pid, getMonitor} ->
      Pid ! Monitor,
      loop(Monitor);
    _ -> loop(Monitor)
  end.

stop() ->
  pollution_server ! {self(), stop},
  receive
    Reply -> Reply
  end.

addStation(Name, Coordinates) ->
  pollution_server ! {self(), addStation, Name, Coordinates},
  receive
    Reply -> Reply
  end.

addValue(Station, Date, Type, Value) ->
  pollution_server ! {self(), addValue, Station, Date, Type, Value},
  receive
    Reply -> Reply
  end.

removeValue(Station, Date, Type) ->
  pollution_server ! {self(), removeValue, Station, Date, Type},
  receive
    Reply -> Reply
  end.

getOneValue(Station, Date, Type) ->
  pollution_server ! {self(), getOneValue, Station, Date, Type},
  receive
    Reply -> Reply
  end.

getStationMean(Station, Type) ->
  pollution_server ! {self(), getStationMean, Station, Type},
  receive
    Reply -> Reply
  end.

getDailyMean(Date, Type) ->
  pollution_server ! {self(), getDailyMean, Date, Type},
  receive
    Reply -> Reply
  end.

getDeviation(Date, Hour, Type) ->
  pollution_server ! {self(), getDeviation, Date, Hour, Type},
  receive
    Reply -> Reply
  end.

getMonitor() ->
  pollution_server ! {self(), getMonitor},
  receive
    Reply -> Reply
  end.