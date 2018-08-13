%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. maj 2018 18:37
%%%-------------------------------------------------------------------
-module(pollution_gen_server_backup).
-behavior(gen_server).

-author("julia").

%% API
-export([start/0, getBackupMonitor/0, setBackupMonitor/1]).
-export([start_link/1, init/1, handle_call/3, handle_cast/2]).

start() -> start_link(pollution:createMonitor()).
start_link(InitValue) -> gen_server:start_link({local, pollution_gen_server_backup},?MODULE,InitValue,[]).
init(InitialValue) -> {ok, InitialValue}.

getBackupMonitor() -> gen_server:call(pollution_gen_server_backup, getBackupMonitor).
setBackupMonitor(NewMonitor) -> gen_server:cast(pollution_gen_server_backup, {setBackupMonitor, NewMonitor}).

handle_call(getBackupMonitor, _From, Monitor) -> {reply, Monitor, Monitor}.

handle_cast({setBackupMonitor, NewMonitor}, _OldMonitor) ->  {noreply, NewMonitor}.