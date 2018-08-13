%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. maj 2018 18:34
%%%-------------------------------------------------------------------
-module(pollutionMnesia).
-author("julia").

%% API
-export([startDB/0, addStation/2, addValue/4, getStations/0, getMeasurements/0, matchMeasurement/3,
  getStation/1, getNodes/0, startNodes/0, removeStation/1, getDatesWhenValueAbove/2]).

-record(measurement, {station, date, type, value}).
-record(station, {name, coordinates}).

startDB() ->
  Nodes = pollutionMnesia:getNodes(),
  mnesia:create_schema(Nodes),
  rpc:multicall(Nodes, application, start, [mnesia]),
  mnesia:create_table(station,
    [{attributes, record_info(fields, station)},
      {disc_copies, Nodes},
      {index, [#station.coordinates]},
      {type, bag}]),
  mnesia:create_table(measurement,
    [{attributes, record_info(fields, measurement)},
      {disc_copies, Nodes},
      {type, bag}]).

addStation(Name, Coordinates) ->
  mnesia:activity(transaction,
    fun() -> case ((mnesia:read(station, Name) /= [])
      orelse (mnesia:match_object(station, {station, '_', Coordinates}, read) /= [])) of
               true -> already_exists;
               false -> mnesia:activity(transaction,
                 fun() -> mnesia:write(#station{name=Name,
                   coordinates=Coordinates})
                 end)
             end
    end).


getStation(Station = {_,_}) ->
  mnesia:activity(transaction,
    fun() -> mnesia:match_object(#station{name = '_', coordinates = Station}) end);

getStation(Station) ->
  mnesia:activity(transaction,
    fun() -> mnesia:read(station, Station) end).

%getOneValue(Station, Date, Type) ->
%  mnesia:activity(transaction, fun() ->
%    mnesia:select(measurement, [{#measurement{station=Station, date=Date, type=Type, value='$1'}, [], ['$1']}]) end).

getDatesWhenValueAbove(Type, Value) ->
  mnesia:activity(transaction, fun() ->
    MatchHead = #measurement{station='_', date='$2', type=Type, value='$4'},
    Guard = [{'>', '$4', Value}], %{'==', '$3', Type}],
    Result = ['$$'],
    mnesia:select(measurement, [{MatchHead, Guard, Result}]) end).


addValue(Station, Date, Type, Value) ->
    mnesia:activity(transaction,
    fun() ->
      StationList = pollutionMnesia:getStation(Station),
      case (StationList =:= []) of
        true -> no_such_station;
        false ->
          StationName = (hd(StationList))#station.name,
          case (mnesia:activity(transaction,
            fun() -> mnesia:match_object(#measurement{station = StationName,
              date = Date, type = Type, value = Value}) end) =:= []) of
            true -> mnesia:activity(transaction,
              fun() -> mnesia:write(#measurement{station = StationName, date = Date, type = Type, value = Value}) end);
            false -> already_exists
          end
      end
    end).

matchMeasurement(Station, Date, Type) ->
  mnesia:activity(transaction,
    fun() -> mnesia:match_object(#measurement{station = Station, date = Date, type = Type, value = '_'}) end).

removeStation(StationName) ->
  mnesia:activity(sync_transaction,
      fun() -> mnesia:delete({measurement, StationName}),
               mnesia:delete({station, StationName})
      end).

getMeasurements() ->
  mnesia:activity(sync_dirty,
    fun() ->
      mnesia:foldl(
        fun(M, Acc) ->
          [M | Acc]
        end,
        [],
        measurement)
    end).

getStations() ->
  mnesia:activity(sync_dirty,
    fun() ->
      mnesia:foldl(
        fun(M, Acc) ->
          [M | Acc]
        end,
        [],
        station)
    end).

loop(Nodes) ->
  receive
    {getList, Pid} -> Pid ! Nodes, loop(Nodes);
    NewNode -> case (net_adm:ping(NewNode) == pong) of
                 true -> loop([NewNode | Nodes]);
                 false -> loop(Nodes)
               end
  end.

startNodes() ->
  global:register_name(nodes, spawn(fun () -> loop([node()]) end)).

getNodes() ->
  global:send(nodes, {getList, self()}),
  receive
    List -> List
  after
    20000 -> ok
  end.




