%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. maj 2018 21:16
%%%-------------------------------------------------------------------
-module(pollution_gen_server_tests).
-include_lib("eunit/include/eunit.hrl").
-author("julia").
-compile(export_all).


createMonitor_test() ->
  code:add_path("/media/sem4/Erlang/laby/lab2/src"),
  undefined = whereis(pollution_gen_server),
  {ok, Pid} = (pollution_gen_server:start()),
  Pid = whereis(pollution_gen_server).
createMonitor2_test() -> [] =
  dict:fetch_keys(pollution_gen_server:getMonitor()).
addStation1_test() ->
  ok = pollution_gen_server:addStation("Qwerty", {12, 34}),
  [{station, "Qwerty", {12, 34}}] = dict:fetch_keys(pollution_gen_server:getMonitor()).
addStation2_test() ->
  already_exists = pollution_gen_server:addStation("Qwerty", {12, 12}),
  [{station, "Qwerty", {12, 34}}] = dict:fetch_keys(pollution_gen_server:getMonitor()).
addStation3_test() ->
  already_exists = pollution_gen_server:addStation("Qwert", {12, 34}),
  [{station, "Qwerty", {12, 34}}] = dict:fetch_keys(pollution_gen_server:getMonitor()).
addStation4_test() ->
  ok = pollution_gen_server:addStation("Asdf", {56,78}),
  [{station, "Qwerty", {12, 34}}, {station, "Asdf", {56,78}}] = dict:fetch_keys(pollution_gen_server:getMonitor()).
addValue1_test() ->
  ok = pollution_gen_server:addValue("Qwerty", {{2018,4,1}, {0,0,0}}, temp, 10),
  [{measurement, {{2018,4,1},{0,0,0}}, temp, 10}] = dict:fetch({station, "Qwerty", {12, 34}}, pollution_gen_server:getMonitor()).
addValue2_test() ->
  already_exists = pollution_gen_server:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10),
  [{measurement, {{2018,4,1},{0,0,0}}, temp, 10}] = dict:fetch({station, "Qwerty", {12, 34}}, pollution_gen_server:getMonitor()).
addValue3_test() ->
  no_such_station = pollution_gen_server:addValue("Qwertysdfgh", {{2018,4,1}, {0,0,0}}, temp, 20),
  1 = length(dict:fetch({station, "Qwerty", {12, 34}}, pollution_gen_server:getMonitor())).
addValue4_test() ->
  ok = pollution_gen_server:addValue("Qwerty", {{2018,4,2}, {0,0,0}}, temp, 20),
  2 = length(dict:fetch({station, "Qwerty", {12, 34}}, pollution_gen_server:getMonitor())).
addValue5_test() ->
  ok = pollution_gen_server:addValue("Qwerty", {{2018,4,1}, {12,0,0}}, temp, 20),
  3 = length(dict:fetch({station, "Qwerty", {12, 34}}, pollution_gen_server:getMonitor())).
addValue6_test() ->
  ok = pollution_gen_server:addValue("Qwerty", {{2018,4,1}, {0,0,0}}, "PM10", 59),
  4 = length(dict:fetch({station, "Qwerty", {12, 34}}, pollution_gen_server:getMonitor())).
addValue7_test() ->
  already_exists = pollution_gen_server:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, "PM10", 59),
  4 = length(dict:fetch({station, "Qwerty", {12, 34}}, pollution_gen_server:getMonitor())).
removeValue1_test() ->
  ok = pollution_gen_server:removeValue("Qwerty", {{2018,4,1}, {12,0,0}}, temp),
  3 = length(dict:fetch({station, "Qwerty", {12, 34}}, pollution_gen_server:getMonitor())).
removeValue2_test() ->
  no_such_measurement = pollution_gen_server:removeValue("Qwerty", {{2018,4,1}, {12,0,0}}, temp),
  3 = length(dict:fetch({station, "Qwerty", {12, 34}}, pollution_gen_server:getMonitor())).
removeValue3_test() ->
  no_such_station = pollution_gen_server:removeValue("Asdfgh", {{2018,4,1}, {0,0,0}}, "PM10"),
  3 = length(dict:fetch({station, "Qwerty", {12, 34}}, pollution_gen_server:getMonitor())).
getOneValue1_test() ->
  59 = pollution_gen_server:getOneValue("Qwerty", {{2018,4,1}, {0,0,0}}, "PM10").
getOneValue2_test() ->
  59 = pollution_gen_server:getOneValue({12,34}, {{2018,4,1}, {0,0,0}}, "PM10").
getOneValue3_test() ->
  no_such_measurement = pollution_gen_server:getOneValue("Asdf", {{2018,4,1}, {0,0,0}}, "PM10").
getStationMean1_test() ->
  59.0 = pollution_gen_server:getStationMean("Qwerty", "PM10").
getStationMean2_test() ->
  59.0 = pollution_gen_server:getStationMean({12,34}, "PM10").
getStationMean3_test() ->
  pollution_gen_server:addValue({12, 34}, {{2018,4,2}, {0,0,0}}, "PM10", 39),
  49.0 = pollution_gen_server:getStationMean({12, 34}, "PM10").
getStationMean4_test() ->
  not_enough_data = pollution_gen_server:getStationMean({12, 34}, "PM2,5").
getStationMean5_test() ->
  no_such_station = pollution_gen_server:getStationMean({34, 12}, "PM2,5").
getDailyMean1_test() ->
  ok = pollution_gen_server:addValue({12, 34}, {{2018,4,2}, {12,12,12}}, "PM10", 59),
  49.0 = pollution_gen_server:getDailyMean({2018,4,2}, "PM10").
getDailyMean2_test() ->
  not_enough_data = pollution_gen_server:getDailyMean({2018,4,1}, "PM2,5"),
  not_enough_data = pollution_gen_server:getDailyMean({2017,4,1}, "PM10").
getDeviation1_test() ->
  not_enough_data = pollution_gen_server:getDeviation({2018,4,1}, 0, temp).
getDeviation2_test() ->
  ok =pollution_gen_server:addValue("Asdf", {{2018,4,2}, {0,0,0}}, "PM11", 59),
  ok =pollution_gen_server:addValue({56,78}, {{2018,4,1}, {1,0,0}}, "PM11", 39),
  ok =pollution_gen_server:addValue({12,34}, {{2018,4,1}, {1,0,0}}, "PM11", 39),
  ok =pollution_gen_server:addValue("Qwerty", {{2018,4,2}, {0,0,0}}, "PM11", 59),
  0.0 = pollution_gen_server:getDeviation({2018,4,2}, 0, "PM11").
stop_test() ->
  ok = pollution_gen_server:stop().
stop2_test() ->
  undefined = whereis(pollution_gen_server).