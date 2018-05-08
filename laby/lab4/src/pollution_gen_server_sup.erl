%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. maj 2018 21:34
%%%-------------------------------------------------------------------
-module(pollution_gen_server_sup).
-behavior(supervisor).
-author("julia").

%% API
-import('pollution', [getStation/1, createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3, getDeviation/4]).
-export([start/0, stop/0]).
-export([start_link/1, init/1]).

start() -> start_link(pollution:createMonitor()).

start_link(InitValue) -> supervisor:start_link({local, pollution_gen_server_sup}, ?MODULE, InitValue).

init(InitValue) ->
  {ok, {
    {rest_for_one, 1, 5},
    [ {pollution_gen_server_backup,
      {pollution_gen_server_backup, start_link, [InitValue]},
      transient, infinity, worker, [pollution_gen_server_backup]},
      {pollution_gen_server,
        {pollution_gen_server, start_link, [InitValue]},
        transient, infinity, worker, [pollution_gen_server]}
    ]}
  }.

stop() -> exit(whereis(pollution_gen_server_sup), normal).