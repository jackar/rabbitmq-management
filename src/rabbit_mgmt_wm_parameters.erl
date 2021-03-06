%%   The contents of this file are subject to the Mozilla Public License
%%   Version 1.1 (the "License"); you may not use this file except in
%%   compliance with the License. You may obtain a copy of the License at
%%   http://www.mozilla.org/MPL/
%%
%%   Software distributed under the License is distributed on an "AS IS"
%%   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
%%   License for the specific language governing rights and limitations
%%   under the License.
%%
%%   The Original Code is RabbitMQ Management Plugin.
%%
%%   The Initial Developer of the Original Code is GoPivotal, Inc.
%%   Copyright (c) 2007-2016 Pivotal Software, Inc.  All rights reserved.
%%

-module(rabbit_mgmt_wm_parameters).

-export([init/3, rest_init/2, to_json/2, content_types_provided/2, is_authorized/2,
         resource_exists/2, basic/1]).

-include("rabbit_mgmt.hrl").
-include_lib("rabbit_common/include/rabbit.hrl").

%%--------------------------------------------------------------------

init(_, _, _) -> {upgrade, protocol, cowboy_rest}.

rest_init(Req, _Config) -> {ok, Req, #context{}}.

content_types_provided(ReqData, Context) ->
   {[{<<"application/json">>, to_json}], ReqData, Context}.

resource_exists(ReqData, Context) ->
    {case basic(ReqData) of
         not_found -> false;
         _         -> true
     end, ReqData, Context}.

to_json(ReqData, Context) ->
    rabbit_mgmt_util:reply_list(
      rabbit_mgmt_util:filter_vhost(basic(ReqData), ReqData, Context),
      ReqData, Context).

is_authorized(ReqData, Context) ->
    rabbit_mgmt_util:is_authorized_policies(ReqData, Context).

%%--------------------------------------------------------------------

basic(ReqData) ->
    Raw = case rabbit_mgmt_util:id(component, ReqData) of
              none -> rabbit_runtime_parameters:list();
              Name -> case rabbit_mgmt_util:vhost(ReqData) of
                          none      -> rabbit_runtime_parameters:list_component(
                                         Name);
                          not_found -> not_found;
                          VHost     -> rabbit_runtime_parameters:list(
                                         VHost, Name)
                      end
          end,
    case Raw of
        not_found -> not_found;
        _         -> [rabbit_mgmt_format:parameter(P) || P <- Raw]
    end.
