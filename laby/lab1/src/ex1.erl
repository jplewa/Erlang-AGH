%%%-------------------------------------------------------------------
%%% @author julia
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. mar 2018 14:52
%%%-------------------------------------------------------------------
-module(ex1).
-author("julia").

%% API
-export([power/2]).

power(_, 0) -> 1;
power(0, _) -> 0;
power(A, 1) -> A;
power(A, B) -> A * power(A, B-1).
