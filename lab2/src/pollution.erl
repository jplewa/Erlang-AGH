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
  case lists:dropwhile(fun(X) -> X#station.coordinates /= Station end, dict:fetch_keys(Monitor)) of
    [] -> no_such_station;
    [X | _] -> X
  end;

getStation(Station, Monitor) ->
  case lists:dropwhile(fun(X) -> X#station.name /= Station end, dict:fetch_keys(Monitor)) of
    [] -> no_such_station;
    [X | _] -> X
  end.

measurementExists(Station, Date, Type, Monitor) ->
  case lists:dropwhile(fun(X) -> ((X#measurement.date /= Date) orelse (X#measurement.type /= Type)) end,
    dict:fetch(Station, Monitor)) of
    [] -> false;
    _ -> true
  end.

% addStation/3 - dodaje do monitora wpis o nowej stacji pomiarowej (nazwa i współrzędne geograficzne), zwraca zaktualizowany monitor;

addStation(Name, Coordinates, Monitor) ->
  case ((getStation(Name, Monitor) /= no_such_station) orelse (getStation(Coordinates, Monitor) /= no_such_station)) of
    false -> dict:store(#station{name = Name, coordinates = Coordinates}, [], Monitor);
    _ -> already_exists
  end.

% addValue/5 - dodaje odczyt ze s)tacji (współrzędne geograficzne lub nazwa stacji, data, typ pomiaru, wartość), zwraca zaktualizowany monitor;
addValue(Station, Date, Type, Value, Monitor) ->
  S = getStation(Station, Monitor),
  case (S /= no_such_station) of
    true ->
      case (measurementExists(S, Date, Type, Monitor)) of
        true -> already_exists;
        false -> dict:append(S, #measurement{date = Date, type = Type, value = Value}, Monitor)
        end;
    false -> S
  end.

% removeValue/4 - usuwa odczyt ze stacji (współrzędne geograficzne lub nazwa stacji, data, typ pomiaru),
% zwraca zaktualizowany monitor;
removeValue (Station, Date, Type, Monitor) ->
  S = getStation(Station, Monitor),
  case(S /= no_such_station) of
    true ->
      case (measurementExists(S, Date, Type, Monitor)) of
        true ->
          NewList = lists:filter(fun(X) -> ((X#measurement.date /= Date) orelse (X#measurement.type /= Type)) end,
            dict:fetch(S, Monitor)),
          dict:update(S, fun(_) -> NewList end, dict:fetch(S, Monitor), Monitor);
        false -> no_such_measurement
        end;
    false -> S
  end.

% getOneValue/4 - zwraca wartość pomiaru o zadanym typie, z zadanej daty i stacji;
getOneValue(Station, Date, Type, Monitor) ->
  S = getStation(Station, Monitor),
  case ((S /= no_such_station) andalso (measurementExists(S, Date, Type, Monitor))) of
    true -> (hd(lists:filter(fun(X) -> ((X#measurement.date =:= Date) andalso (X#measurement.type =:= Type)) end,
      dict:fetch(S, Monitor))))#measurement.value;
    false -> no_such_measurement
  end.

getMean(List) ->
  case (length(List) < 1) of
    false -> lists:sum(List)/length(List);
    true -> not_enough_data
  end.

% getStationMean/3 - zwraca średnią wartość parametru danego typu z zadanej stacji;
getStationMean(Station, Type, Monitor) ->
  S = getStation(Station, Monitor),
  case (S /= no_such_station) of
    true ->  getMean([X#measurement.value || X <- dict:fetch(S, Monitor), X#measurement.type =:= Type ]);
    false -> S
  end.

% getDailyMean/3 - zwraca średnią wartość parametru danego typu, danego dnia na wszystkich stacjach;
getDailyMean(Date, Type, Monitor) ->
  getMean(lists:append(lists:map(fun (K) ->
    [ V#measurement.value || V <- dict:fetch(K, Monitor), ((V#measurement.type =:= Type) andalso
      (element(1, V#measurement.date) =:= Date))] end, dict:fetch_keys(Monitor)))).

getDeviationHelper(List) ->
  case (length(List) < 2) of
    false -> math:sqrt(lists:sum(lists:map(fun(X) -> math:pow((X-getMean(List)),2) end, List))/(length(List) - 1));
    true -> not_enough_data
  end.

getDeviation(Date, Hour, Type, Monitor) ->
  getDeviationHelper(lists:foldl(fun(X,Y) -> X ++ Y end, [], lists:map(fun(Y) ->
  [ X#measurement.value || X <- dict:fetch(Y, Monitor),  X#measurement.type =:= Type, element(1, X#measurement.date) =:= Date,
  element(1, element(2, X#measurement.date)) =:= Hour ] end, dict:fetch_keys(Monitor)))).
