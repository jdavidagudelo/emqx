%%--------------------------------------------------------------------
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
%%--------------------------------------------------------------------

-module(emqx_config_SUITE).

-compile(export_all).
-compile(nowarn_export_all).

-include_lib("eunit/include/eunit.hrl").

all() -> emqx_ct:all(?MODULE).

init_per_suite(Config) ->
    emqx_ct_helpers:start_apps([]),
    Config.

end_per_suite(_Config) ->
    emqx_ct_helpers:stop_apps([]).

t_get_env(_) ->
    ?assertEqual(undefined, emqx_config:get_env(undefined_key)),
    ?assertEqual(default_value, emqx_config:get_env(undefined_key, default_value)),
    application:set_env(emqx, undefined_key, hello),
    ?assertEqual(hello, emqx_config:get_env(undefined_key)),
    ?assertEqual(hello, emqx_config:get_env(undefined_key, default_value)),
    application:unset_env(emqx, undefined_key).