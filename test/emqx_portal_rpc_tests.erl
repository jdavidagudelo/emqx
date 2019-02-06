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

-module(emqx_portal_rpc_tests).
-include_lib("eunit/include/eunit.hrl").

start_stop_test() ->
    {ok, Pid, Node} = emqx_portal_rpc:start(#{address => node()}),
    ok = emqx_portal_rpc:stop(Pid, Node).

send_and_ack_test() ->
    meck:new(emqx_portal, [passthrough]),
    meck:expect(emqx_portal, import_batch, 2,
                fun(batch, AckFun) -> AckFun() end),
    try
        {ok, Pid, Node} = emqx_portal_rpc:start(#{address => node()}),
        {ok, Ref} = emqx_portal_rpc:send(Node, batch),
        receive
            {batch_ack, Ref} ->
                ok
        end,
        ok = emqx_portal_rpc:stop(Pid, Node)
    after
        meck:unload(emqx_portal)
    end.
