%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. kwi 2018 19:27
%%%-------------------------------------------------------------------
-module(pollution).
-author("julia").

%% API
-export([createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3, getDeviation/4]).

-record(measurement, {date, type, value}).
-record(station, {name, coordinates}).

% createMonitor/0 - tworzy i zwraca nowy monitor zanieczyszczeń;

createMonitor() -> dict:new().

getStation(Station = {_,_}, Monitor) ->
  hd(lists:filter(fun(X) -> X#station.coordinates=:= Station end, dict:fetch_keys(Monitor)));
getStation(Station, Monitor) ->
  hd(lists:filter(fun(X) -> X#station.name =:= Station end, dict:fetch_keys(Monitor))).

stationExists(Station = {_,_}, Monitor) ->
  lists:any(fun(X) -> X#station.coordinates =:= Station end, dict:fetch_keys(Monitor));
stationExists(Station, Monitor) ->
  lists:any(fun(X) -> X#station.name =:= Station end, dict:fetch_keys(Monitor)).

measurementExists(Station, Date, Type, Monitor) ->
  lists: any(fun(X) -> ((X#measurement.date =:= Date) and (X#measurement.type =:= Type)) end,
    dict:fetch(getStation(Station, Monitor), Monitor)).

% addStation/3 - dodaje do monitora wpis o nowej stacji pomiarowej (nazwa i współrzędne geograficzne), zwraca zaktualizowany monitor;

addStation(Name, Coordinates, Monitor) ->
  case ((stationExists(Name, Monitor)) or (stationExists(Coordinates, Monitor))) of
    false -> dict:store(#station{name = Name, coordinates = Coordinates}, [], Monitor);
    _ -> already_exists
  end.

% addValue/5 - dodaje odczyt ze s)tacji (współrzędne geograficzne lub nazwa stacji, data, typ pomiaru, wartość), zwraca zaktualizowany monitor;
addValue(Station, Date, Type, Value, Monitor) ->
  case (stationExists(Station, Monitor)) of
    true ->
      case (measurementExists(Station, Date, Type, Monitor)) of
        true -> already_exists;
        false -> dict:append(getStation(Station, Monitor), #measurement{date = Date, type = Type, value = Value}, Monitor)
        end;
    false -> no_such_station
  end.

% removeValue/4 - usuwa odczyt ze stacji (współrzędne geograficzne lub nazwa stacji, data, typ pomiaru),
% zwraca zaktualizowany monitor;
removeValue (Station, Date, Type, Monitor) ->
  case(stationExists(Station, Monitor)) of
    true ->
      case (measurementExists(Station, Date, Type, Monitor)) of
        true ->
          NewList = lists:filter(fun(X) -> ((X#measurement.date /= Date) or (X#measurement.type /= Type)) end,
            dict:fetch(getStation(Station, Monitor), Monitor)),
          dict:update(getStation(Station, Monitor), fun(_) -> NewList end, dict:fetch(getStation(Station, Monitor), Monitor), Monitor);
        false -> no_such_measurement
        end;
    false -> no_such_station
  end.

% getOneValue/4 - zwraca wartość pomiaru o zadanym typie, z zadanej daty i stacji;
getOneValue(Station, Date, Type, Monitor) ->
  case ((stationExists(Station, Monitor)) andalso (measurementExists(Station, Date, Type, Monitor))) of
    true -> (hd(lists:filter(fun(X) -> ((X#measurement.date =:= Date) and (X#measurement.type =:= Type)) end,
      dict:fetch(getStation(Station, Monitor), Monitor))))#measurement.value;
    false -> no_such_measurement
  end.

getMean(List) ->
  case (length(List) < 1) of
    false -> lists:sum(List)/length(List);
    true -> not_enough_data
  end.

% getStationMean/3 - zwraca średnią wartość parametru danego typu z zadanej stacji;
getStationMean(Station, Type, Monitor) ->
  case (stationExists(Station, Monitor)) of
    true ->  getMean([X#measurement.value || X <- dict:fetch(getStation(Station, Monitor), Monitor), X#measurement.type =:= Type ]);
    false -> no_such_station
  end.

% getDailyMean/3 - zwraca średnią wartość parametru danego typu, danego dnia na wszystkich stacjach;
getDailyMean(Date, Type, Monitor) ->
  getMean(lists:foldl(fun(X,Y) -> X ++ Y end, [],
    lists:map(fun(Y) -> [ X#measurement.value || X <- dict:fetch(Y, Monitor), X#measurement.type =:= Type,
      element(1, X#measurement.date) =:= Date ] end, dict:fetch_keys(Monitor)))).

getDeviationHelper(List) ->
  case (length(List) < 2) of
    false -> math:sqrt(lists:sum(lists:map(fun(X) -> math:pow((X-getMean(List)),2) end, List))/(length(List) - 1));
    true -> not_enough_data
  end.

getDeviation(Date, Hour, Type, Monitor) ->
  getDeviationHelper(lists:foldl(fun(X,Y) -> X ++ Y end, [], lists:map(fun(Y) ->
  [ X#measurement.value || X <- dict:fetch(Y, Monitor),  X#measurement.type =:= Type, element(1, X#measurement.date) =:= Date,
  element(1, element(2, X#measurement.date)) =:= Hour ] end, dict:fetch_keys(Monitor)))).
