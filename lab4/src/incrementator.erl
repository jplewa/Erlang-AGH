% 1. Który z wzorców OTP został użyty do implementacji modułu incrementator?
%     Wzorzec gen_server
% 2. Jaki rodzaj komunikacji został wykorzystany do przesyłania atomu get, a jaki do inc?
%     get jest realizowane przy pomocy funkcji gen_server:call/2, czyli jest to zapytanie synchroniczne
%     inc jest realizowane przy pomocy funkcji gen_server_cast/2, czyli jest to zapytanie asynchroniczne
% 3. Jakie kluczowe atomy dla danego wzorca OTP zostały tutaj wykorzystane? Do czego służą?
%     init/1: inicjalizuje serwer z zadaną wartością (wywołana po gen_server:start_link/3)
%     handle_call/3: odpowiedź na zapytania synchroniczne (wywołana po gen_server:call/2) - wersja dla get i terminate
%     handle_cast/2: odpowiedź na zapytania asynchroniczne (wywołana po gen_server:cast/2) - wersja dla inc
%     terminate/2: zakończenie działania serwera (wywołana, gdy któraś z funkcji handle_Something
%       zwraca krotkę {stop, Reason, NewState} or {stop, Reason, Reply, NewState})

-module(incrementator).
-behaviour(gen_server).
%% API
-export([start_link/0, increment/1, decrement/1, get/1,close/1]).
-export([init/1,handle_call/3,handle_cast/2,terminate/2, handle_info/2]).

%% START %%
start_link()   -> gen_server:start_link(?MODULE,0,[]).

%% INTERFEJS KLIENT -> SERWER %%
increment(Pid) -> gen_server:cast(Pid,inc).
decrement(Pid) -> gen_server:cast(Pid,dec).
get(Pid)       -> gen_server:call(Pid, get).
close(Pid)     -> gen_server:call(Pid,terminate).
init(N)        -> {ok,N}.

%% OBSŁUGA WIADOMOŚCI %%
handle_cast(inc, N) -> {noreply, N+1};
handle_cast(dec, N) -> {noreply, N-1}.

handle_call(get,_From, N)      -> {reply, N, N};
handle_call(terminate,_From,N) -> {stop, normal, ok, N}.

terminate(normal, N) -> io:format("The number is: ~B~nBye.~n",[N]), ok.

%  =WARNING REPORT==== 5-May-2018::18:45:11 ===
% ** Undefined handle_info in incrementator
% ** Unhandled message: "czesc"

% handle_info(dec, N) -> io:format("Received message: ~s~nCurrent number is: ~B~n",[dec,N-1]), {noreply, N-1};
% handle_info(inc, N) -> io:format("Received message: ~s~nCurrent number is: ~B~n",[inc,N+1]), {noreply, N+1};
handle_info(Info, N) -> io:format("Received message: ~s~nCurrent number is: ~B~n",[Info,N]), {noreply, N}.
