%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. kwi 2018 20:23
%%%-------------------------------------------------------------------
-module(pollutionTests).
-include_lib("eunit/include/eunit.hrl").
-author("julia").
-compile(export_all).

%% API
createMonitor_test() -> [] = dict:fetch_keys(pollution:createMonitor()).
addStation1_test() -> [{station, "Qwerty", {12, 34}}] =
  dict:fetch_keys(pollution:addStation("Qwerty", {12, 34}, pollution:createMonitor())).
addStation2_test() -> [{station, "Qwerty", {12, 34}}] =
  dict:fetch_keys(pollution:addStation("Qwerty", {34,12}, pollution:addStation("Qwerty", {12, 34}, pollution:createMonitor()))).
addStation3_test() -> [{station, "Qwerty", {12, 34}}] =
  dict:fetch_keys(pollution:addStation("Qwert", {12,34}, pollution:addStation("Qwerty", {12, 34}, pollution:createMonitor()))).
addStation4_test() -> [{station, "Qwerty", {12, 34}}, {station, "Asdf", {56,78}}] =
  dict:fetch_keys(pollution:addStation("Asdf", {56,78}, pollution:addStation("Qwerty", {12, 34}, pollution:createMonitor()))).
addValue1_test() -> [{measurement, {{2018,4,1},{0,0,0}}, temp, 10}] = dict:fetch({station, "Qwerty", {12, 34}}, pollution:addValue(
"Qwerty", {{2018,4,1}, {0,0,0}}, temp, 10, pollution:addStation("Qwerty", {12, 34}, pollution:createMonitor()))).
addValue2_test() -> [{measurement, {{2018,4,1},{0,0,0}}, temp, 10}] = dict:fetch({station, "Qwerty", {12, 34}}, pollution:addValue(
  {12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10, pollution:addStation("Qwerty", {12, 34}, pollution:createMonitor()))).
addValue3_test() -> 1 = length(dict:fetch({station, "Qwerty", {12, 34}},
  (pollution:addValue("Qwerty", {{2018,4,1}, {0,0,0}}, temp, 20,
      (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10, pollution:addStation("Qwerty", {12, 34},
        pollution:createMonitor()))))))).
addValue4_test() -> 2 = length(dict:fetch({station, "Qwerty", {12, 34}},
  (pollution:addValue("Qwerty", {{2018,4,2}, {0,0,0}}, temp, 20,
    (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10, pollution:addStation("Qwerty", {12, 34},
      pollution:createMonitor()))))))).
addValue5_test() -> 2 = length(dict:fetch({station, "Qwerty", {12, 34}},
  (pollution:addValue("Qwerty", {{2018,4,1}, {12,0,0}}, temp, 20,
    (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10, pollution:addStation("Qwerty", {12, 34},
      pollution:createMonitor()))))))).
addValue6_test() -> 2 = length(dict:fetch({station, "Qwerty", {12, 34}},
  (pollution:addValue("Qwerty", {{2018,4,1}, {0,0,0}}, "PM10", 59,
    (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10, pollution:addStation("Qwerty", {12, 34},
      pollution:createMonitor()))))))).
addValue7_test() -> 1 = length(dict:fetch({station, "Qwerty", {12, 34}},
  (pollution:addValue("Qwerty", {{2018,4,1}, {0,0,0}}, temp, 20,
    (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10, pollution:addStation("Qwerty", {12, 34},
      pollution:createMonitor()))))))).
removeValue1_test() -> 1 = length(dict:fetch({station, "Qwerty", {12, 34}},
  pollution:removeValue("Qwerty", {{2018,4,1}, {0,0,0}}, "PM10",
    (pollution:addValue("Qwerty", {{2018,4,1}, {0,0,0}}, "PM10", 59,
      (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10, pollution:addStation("Qwerty", {12, 34},
        pollution:createMonitor())))))))).
removeValue2_test() -> 2 = length(dict:fetch({station, "Qwerty", {12, 34}},
  pollution:removeValue("Qwerty", {{2018,4,2}, {0,0,0}}, "PM10",
    (pollution:addValue("Qwerty", {{2018,4,1}, {0,0,0}}, "PM10", 59,
      (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10, pollution:addStation("Qwerty", {12, 34},
        pollution:createMonitor())))))))).
removeValue3_test() -> 2 = length(dict:fetch({station, "Qwerty", {12, 34}},
  pollution:removeValue("Asdf", {{2018,4,1}, {0,0,0}}, "PM10",
    (pollution:addValue("Qwerty", {{2018,4,1}, {0,0,0}}, "PM10", 59,
      (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10, pollution:addStation("Qwerty", {12, 34},
        pollution:createMonitor())))))))).
getOneValue1_test() -> 59 =
  pollution:getOneValue("Qwerty", {{2018,4,1}, {0,0,0}}, "PM10",
      (pollution:addValue("Qwerty", {{2018,4,1}, {0,0,0}}, "PM10", 59,
        (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10,
          pollution:addStation("Qwerty", {12, 34},
            pollution:createMonitor())))))).
getOneValue2_test() -> 59 =
  pollution:getOneValue({12, 34}, {{2018,4,1}, {0,0,0}}, "PM10",
    (pollution:addValue("Qwerty", {{2018,4,1}, {0,0,0}}, "PM10", 59,
      (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10,
        pollution:addStation("Qwerty", {12, 34},
          pollution:createMonitor())))))).
getOneValue3_test() -> no_such_measurement =
  pollution:getOneValue("Asdf", {{2018,4,1}, {0,0,0}}, "PM10",
    (pollution:addValue("Qwerty", {{2018,4,1}, {0,0,0}}, "PM10", 59,
      (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10,
        pollution:addStation("Qwerty", {12, 34},
          pollution:createMonitor())))))).
getStationMean1_test() -> 59.0 =
  pollution:getStationMean("Qwerty", "PM10",
    (pollution:addValue("Qwerty", {{2018,4,1}, {0,0,0}}, "PM10", 59,
      (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10,
        pollution:addStation("Qwerty", {12, 34},
          pollution:createMonitor())))))).
getStationMean2_test() -> 59.0 =
  pollution:getStationMean({12, 34}, "PM10",
    (pollution:addValue("Qwerty", {{2018,4,1}, {0,0,0}}, "PM10", 59,
      (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10,
        pollution:addStation("Qwerty", {12, 34},
          pollution:createMonitor())))))).
getStationMean3_test() -> 49.0 =
  pollution:getStationMean({12, 34}, "PM10",
    (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
      (pollution:addValue("Qwerty", {{2018,4,2}, {0,0,0}}, "PM10", 59,
        (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10, pollution:addStation("Qwerty", {12, 34},
          pollution:createMonitor())))))))).
getStationMean4_test() -> not_enough_data =
  pollution:getStationMean({12, 34}, "PM2,5",
    (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
      (pollution:addValue("Qwerty", {{2018,4,2}, {0,0,0}}, "PM10", 59,
        (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10, pollution:addStation("Qwerty", {12, 34},
          pollution:createMonitor())))))))).
getStationMean5_test() -> no_such_station =
  pollution:getStationMean({34, 12}, "PM2,5",
    (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
      (pollution:addValue("Qwerty", {{2018,4,2}, {0,0,0}}, "PM10", 59,
        (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10, pollution:addStation("Qwerty", {12, 34},
          pollution:createMonitor())))))))).
getDailyMean1_test() -> 39.0 =
  pollution:getDailyMean({2018,4,1}, "PM10",
    (pollution:addValue("Asdf", {{2018,4,12}, {0,0,0}}, "PM10", 59,
      (pollution:addValue({56, 78}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
        (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
          (pollution:addValue("Qwerty", {{2018,4,2}, {0,0,0}}, "PM10", 59,
            (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10,
              (pollution:addStation("Asdf", {56, 78},
                (pollution:addStation("Qwerty", {12, 34},
                  pollution:createMonitor()))))))))))))))).
getDailyMean2_test() -> not_enough_data =
  pollution:getDailyMean({2018,4,1}, "PM2,5",
    (pollution:addValue("Asdf", {{2018,4,12}, {0,0,0}}, "PM10", 59,
      (pollution:addValue({56, 78}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
        (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
          (pollution:addValue("Qwerty", {{2018,4,2}, {0,0,0}}, "PM10", 59,
            (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10,
              (pollution:addStation("Asdf", {56, 78},
                (pollution:addStation("Qwerty", {12, 34},
                  pollution:createMonitor()))))))))))))))).
getDailyMean3_test() -> not_enough_data =
  pollution:getDailyMean({2017,4,1}, "PM10",
    (pollution:addValue("Asdf", {{2018,4,12}, {0,0,0}}, "PM10", 59,
      (pollution:addValue({56, 78}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
        (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
          (pollution:addValue("Qwerty", {{2018,4,2}, {0,0,0}}, "PM10", 59,
            (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10,
              (pollution:addStation("Asdf", {56, 78},
                (pollution:addStation("Qwerty", {12, 34},
                  pollution:createMonitor()))))))))))))))).
getDeviation1_test() -> not_enough_data =
  pollution:getDeviation( {2018,4,1}, 0,temp,
    (pollution:addValue("Asdf", {{2018,4,12}, {0,0,0}}, "PM10", 59,
      (pollution:addValue({56, 78}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
        (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
          (pollution:addValue("Qwerty", {{2018,4,2}, {0,0,0}}, "PM10", 59,
            (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10,
              (pollution:addStation("Asdf", {56, 78},
                (pollution:addStation("Qwerty", {12, 34},
                  pollution:createMonitor()))))))))))))))).
getDeviation2_test() -> not_enough_data =
  pollution:getDeviation({2018,4,2}, 0, "PM10",
    (pollution:addValue("Asdf", {{2018,4,2}, {12,0,0}}, "PM10", 59,
      (pollution:addValue({56, 78}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
        (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
          (pollution:addValue("Qwerty", {{2018,4,2}, {0,0,0}}, "PM10", 59,
            (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10,
              (pollution:addStation("Asdf", {56, 78},
                (pollution:addStation("Qwerty", {12, 34},
                  pollution:createMonitor()))))))))))))))).
getDeviation3_test() -> not_enough_data =
  pollution:getDeviation({2018,4,2}, 0, "PM2,5",
    (pollution:addValue("Asdf", {{2018,4,2}, {12,0,0}}, "PM10", 59,
      (pollution:addValue({56, 78}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
        (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
          (pollution:addValue("Qwerty", {{2018,4,2}, {0,0,0}}, "PM10", 59,
            (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10,
              (pollution:addStation("Asdf", {56, 78},
                (pollution:addStation("Qwerty", {12, 34},
                  pollution:createMonitor()))))))))))))))).
getDeviation4_test() -> 0.0 =
  pollution:getDeviation({2018,4,1}, 0, "PM10",
    (pollution:addValue("Asdf", {{2018,4,2}, {12,0,0}}, "PM10", 59,
      (pollution:addValue({56, 78}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
        (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, "PM10", 39,
          (pollution:addValue("Qwerty", {{2018,4,2}, {0,0,0}}, "PM10", 59,
            (pollution:addValue({12, 34}, {{2018,4,1}, {0,0,0}}, temp, 10,
              (pollution:addStation("Asdf", {56, 78},
                (pollution:addStation("Qwerty", {12, 34},
                  pollution:createMonitor()))))))))))))))).