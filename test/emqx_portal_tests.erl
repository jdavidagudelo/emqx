%% Copyright (c) 2019 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(emqx_portal_tests).
-behaviour(emqx_portal_connect).

-include_lib("eunit/include/eunit.hrl").

-define(PORTAL_NAME, test_portal).
-define(WAIT(PATTERN, TIMEOUT),
        receive
            PATTERN ->
                ok
        after
            TIMEOUT ->
                error(timeout)
        end).

%% stub callbacks
-export([start/1, send/2, stop/2]).

start(#{connect_result := Result, test_pid := Pid, test_ref := Ref}) ->
    Pid ! {connection_start_attempt, Ref},
    Result.

send(_Connection, _Batch) -> ok.

stop(dummy_ref, _Pid) -> ok.

%% portal worker should retry connecting remote node indefinitely
reconnect_test() ->
    Ref = make_ref(),
    Config = #{test_pid => self(),
               test_ref => Ref,
               connect_module => ?MODULE,
               reconnect_delay_ms => 50,
               connect_result => {error, test}
              },
    {ok, Pid} = emqx_portal:start_link(?PORTAL_NAME, Config),
    %% assert name registered
    ?assertEqual(Pid, whereis(?PORTAL_NAME)),
    ?WAIT({connection_start_attempt, Ref}, 1000),
    %% expect same message again
    ?WAIT({connection_start_attempt, Ref}, 1000),
    ok = emqx_portal:stop(?PORTAL_NAME),
    ok.

