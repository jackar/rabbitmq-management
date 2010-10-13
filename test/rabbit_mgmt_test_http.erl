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
%%   The Original Code is RabbitMQ Management Console.
%%
%%   The Initial Developers of the Original Code are Rabbit Technologies Ltd.
%%
%%   Copyright (C) 2010 Rabbit Technologies Ltd.
%%
%%   All Rights Reserved.
%%
%%   Contributor(s): ______________________________________.
%%
-module(rabbit_mgmt_test_http).

-include_lib("eunit/include/eunit.hrl").
-include_lib("amqp_client/include/amqp_client.hrl").

-define(OK, 200).
-define(CREATED, 201).
-define(NO_CONTENT, 204).
-define(BAD_REQUEST, 400).
-define(NOT_AUTHORISED, 401).
%%-define(NOT_FOUND, 404). Defined for AMQP by amqp_client.hrl (as 404)
-define(PREFIX, "http://localhost:55672/api").

overview_test() ->
    %% Rather crude, but this req doesn't say much and at least this means it
    %% didn't blow up.
    [<<"0.0.0.0:5672">>] = pget(bound_to, http_get("/overview")),
    %% TODO uncomment when priv works in test
    %%http_get(""),
    %% Just for coverage
    http_get("/applications"),
    ok.

auth_test() ->
    test_auth(?NOT_AUTHORISED, []),
    test_auth(?NOT_AUTHORISED, [auth_header("guest", "gust")]),
    test_auth(?OK, [auth_header("guest", "guest")]).

%% This test is rather over-verbose as we're trying to test understanding of
%% Webmachine
vhosts_test() ->
    [[{name, <<"/">>}]] = http_get("/vhosts"),
    %% Create a new one
    http_put("/vhosts/myvhost", [], ?NO_CONTENT),
    %% PUT should be idempotent
    http_put("/vhosts/myvhost", [], ?NO_CONTENT),
    %% Check it's there
    [[{name, <<"/">>}], [{name, <<"myvhost">>}]] = http_get("/vhosts"),
    %% Check individually
    [{name, <<"/">>}] = http_get("/vhosts/%2f", ?OK),
    [{name, <<"myvhost">>}] = http_get("/vhosts/myvhost"),
    %% Delete it
    http_delete("/vhosts/myvhost", ?NO_CONTENT),
    %% It's not there
    http_get("/vhosts/myvhost", ?NOT_FOUND),
    http_delete("/vhosts/myvhost", ?NOT_FOUND).

users_test() ->
    assert_item([{name, <<"guest">>},
                 {password, <<"guest">>},
                 {administrator, true}], http_get("/whoami", ?OK)),
    http_get("/users/myuser", ?NOT_FOUND),
    http_put_raw("/users/myuser", "Something not JSON", ?BAD_REQUEST),
    http_put("/users/myuser", [{flim, <<"flam">>}], ?BAD_REQUEST),
    http_put("/users/myuser", [{password, <<"myuser">>},
                               {administrator, false}], ?NO_CONTENT),
    http_put("/users/myuser", [{password, <<"password">>},
                               {administrator, true}], ?NO_CONTENT),
    [{name,          <<"myuser">>},
     {password,      <<"password">>},
     {administrator, true}] =
        http_get("/users/myuser"),
    [[{name,<<"guest">>},
      {password,<<"guest">>},
      {administrator, true}],
     [{name,          <<"myuser">>},
      {password,      <<"password">>},
      {administrator, true}]] =
        http_get("/users"),
    test_auth(?OK, [auth_header("myuser", "password")]),
    http_delete("/users/myuser", ?NO_CONTENT),
    test_auth(?NOT_AUTHORISED, [auth_header("myuser", "password")]),
    http_get("/users/myuser", ?NOT_FOUND),
    ok.

permissions_validation_test() ->
    Good = [{configure, <<".*">>}, {write, <<".*">>}, {read, <<".*">>}],
    http_put("/permissions/wrong/guest", Good, ?BAD_REQUEST),
    http_put("/permissions/%2f/wrong", Good, ?BAD_REQUEST),
    http_put("/permissions/%2f/guest",
             [{configure, <<"[">>}, {write, <<".*">>}, {read, <<".*">>}],
             ?BAD_REQUEST),
    http_put("/permissions/%2f/guest", Good, ?NO_CONTENT),
    ok.

permissions_list_test() ->
    [[{user,<<"guest">>},
      {vhost,<<"/">>},
      {configure,<<".*">>},
      {write,<<".*">>},
      {read,<<".*">>}]] =
        http_get("/permissions"),

    http_put("/users/myuser1", [{password, <<"">>}, {administrator, true}],
             ?NO_CONTENT),
    http_put("/users/myuser2", [{password, <<"">>}, {administrator, true}],
             ?NO_CONTENT),
    http_put("/vhosts/myvhost1", [], ?NO_CONTENT),
    http_put("/vhosts/myvhost2", [], ?NO_CONTENT),

    Perms = [{configure, <<"foo">>}, {write, <<"foo">>}, {read, <<"foo">>}],
    http_put("/permissions/myvhost1/myuser1", Perms, ?NO_CONTENT),
    http_put("/permissions/myvhost2/myuser1", Perms, ?NO_CONTENT),
    http_put("/permissions/myvhost1/myuser2", Perms, ?NO_CONTENT),

    4 = length(http_get("/permissions")),
    2 = length(http_get("/users/myuser1/permissions")),
    1 = length(http_get("/users/myuser2/permissions")),

    http_delete("/users/myuser1", ?NO_CONTENT),
    http_delete("/users/myuser2", ?NO_CONTENT),
    http_delete("/vhosts/myvhost1", ?NO_CONTENT),
    http_delete("/vhosts/myvhost2", ?NO_CONTENT),
    ok.

permissions_test() ->
    http_put("/users/myuser", [{password, <<"myuser">>}, {administrator, true}],
             ?NO_CONTENT),
    http_put("/vhosts/myvhost", [], ?NO_CONTENT),

    http_put("/permissions/myvhost/myuser",
             [{configure, <<"foo">>}, {write, <<"foo">>}, {read, <<"foo">>}],
             ?NO_CONTENT),

    Permission = [{user,<<"myuser">>},
                  {vhost,<<"myvhost">>},
                  {configure,<<"foo">>},
                  {write,<<"foo">>},
                  {read,<<"foo">>}],
    Default = [{user,<<"guest">>},
               {vhost,<<"/">>},
               {configure,<<".*">>},
               {write,<<".*">>},
               {read,<<".*">>}],
    Permission = http_get("/permissions/myvhost/myuser"),
    assert_list([Permission, Default], http_get("/permissions")),
    assert_list([Permission], http_get("/users/myuser/permissions")),
    http_delete("/permissions/myvhost/myuser", ?NO_CONTENT),
    http_get("/permissions/myvhost/myuser", ?NOT_FOUND),

    http_delete("/users/myuser", ?NO_CONTENT),
    http_delete("/vhosts/myvhost", ?NO_CONTENT),
    ok.

connections_test() ->
    {ok, Conn} = amqp_connection:start(network),
    LocalPort = rabbit_mgmt_test_db:local_port(Conn),
    Path = binary_to_list(
             rabbit_mgmt_format:print(
               "/connections/127.0.0.1%3A~w", [LocalPort])),
    http_get(Path, ?OK),
    http_delete(Path, ?NO_CONTENT),
    http_get(Path, ?NOT_FOUND).

test_auth(Code, Headers) ->
    {ok, {{_, Code, _}, _, _}} = req(get, "/overview", Headers).

exchanges_test() ->
    %% Can pass booleans or strings
    Good = [{type, <<"direct">>}, {durable, <<"true">>},
            {auto_delete, <<"false">>}, {arguments, []}],
    http_put("/vhosts/myvhost", [], ?NO_CONTENT),
    http_get("/exchanges/myvhost/foo", ?NOT_AUTHORISED),
    http_put("/exchanges/myvhost/foo", Good, ?NOT_AUTHORISED),
    http_put("/permissions/myvhost/guest",
             [{configure, <<".*">>}, {write, <<".*">>}, {read, <<".*">>}],
             ?NO_CONTENT),
    http_get("/exchanges/myvhost/foo", ?NOT_FOUND),
    http_put("/exchanges/myvhost/foo", Good, ?NO_CONTENT),
    http_put("/exchanges/myvhost/foo", Good, ?NO_CONTENT),
    http_get("/exchanges/%2f/foo", ?NOT_FOUND),
    [{name,<<"foo">>},
     {vhost,<<"myvhost">>},
     {type,<<"direct">>},
     {durable,true},
     {auto_delete,false},
     {arguments,[]}] =
        http_get("/exchanges/myvhost/foo"),

    http_put("/exchanges/badvhost/bar", Good, ?NOT_FOUND),
    http_put("/exchanges/myvhost/bar",
             [{type, <<"bad_exchange_type">>},
              {durable, true}, {auto_delete, false}, {arguments, []}],
             ?BAD_REQUEST),
    http_put("/exchanges/myvhost/bar",
             [{type, <<"direct">>},
              {durable, <<"troo">>}, {auto_delete, false}, {arguments, []}],
             ?BAD_REQUEST),
    http_put("/exchanges/myvhost/foo",
             [{type, <<"direct">>},
              {durable, false}, {auto_delete, false}, {arguments, []}],
             ?BAD_REQUEST),

    http_delete("/exchanges/myvhost/foo", ?NO_CONTENT),
    http_delete("/exchanges/myvhost/foo", ?NOT_FOUND),

    http_delete("/vhosts/myvhost", ?NO_CONTENT),
    http_get("/exchanges/badvhost", ?NOT_FOUND),
    ok.

queues_test() ->
    Good = [{durable, true}, {auto_delete, false}, {arguments, []}],
    http_get("/queues/%2f/foo", ?NOT_FOUND),
    http_put("/queues/%2f/foo", Good, ?NO_CONTENT),
    http_put("/queues/%2f/foo", Good, ?NO_CONTENT),
    http_get("/queues/%2f/foo", ?OK),

    http_put("/queues/badvhost/bar", Good, ?NOT_FOUND),
    http_put("/queues/%2f/bar",
             [{durable, <<"troo">>}, {auto_delete, false}, {arguments, []}],
             ?BAD_REQUEST),
    http_put("/queues/%2f/foo",
             [{durable, false}, {auto_delete, false}, {arguments, []}],
             ?BAD_REQUEST),

    http_put("/queues/%2f/baz", Good, ?NO_CONTENT),

    Queues = http_get("/queues/%2f"),
    Queue = http_get("/queues/%2f/foo"),
    assert_list([[{name,        <<"foo">>},
                  {vhost,       <<"/">>},
                  {durable,     true},
                  {auto_delete, false},
                  {arguments,   []}],
                 [{name,        <<"baz">>},
                  {vhost,       <<"/">>},
                  {durable,     true},
                  {auto_delete, false},
                  {arguments,   []}]], Queues),
    assert_item([{name,        <<"foo">>},
                 {vhost,       <<"/">>},
                 {durable,     true},
                 {auto_delete, false},
                 {arguments,   []}], Queue),

    http_delete("/queues/%2f/foo", ?NO_CONTENT),
    http_delete("/queues/%2f/baz", ?NO_CONTENT),
    http_delete("/queues/%2f/foo", ?NOT_FOUND),
    http_get("/queues/badvhost", ?NOT_FOUND),
    ok.

bindings_test() ->
    XArgs = [{type, <<"direct">>}, {durable, false}, {auto_delete, false},
             {arguments, []}],
    QArgs = [{durable, false}, {auto_delete, false}, {arguments, []}],
    http_put("/exchanges/%2f/myexchange", XArgs, ?NO_CONTENT),
    http_put("/queues/%2f/myqueue", QArgs, ?NO_CONTENT),
    http_put("/bindings/%2f/badqueue/myexchange/routing", [], ?NOT_FOUND),
    http_put("/bindings/%2f/myqueue/badexchange/routing", [], ?NOT_FOUND),
    http_put("/bindings/%2f/myqueue/myexchange/bad_routing", [], ?BAD_REQUEST),
    http_put("/bindings/%2f/myqueue/myexchange/routing", [], ?NO_CONTENT),
    http_get("/bindings/%2f/myqueue/myexchange/routing", ?OK),
    http_get("/bindings/%2f/myqueue/myexchange/rooting", ?NOT_FOUND),
    Binding =
        [{exchange,<<"myexchange">>},
         {vhost,<<"/">>},
         {queue,<<"myqueue">>},
         {routing_key,<<"routing">>},
         {arguments,[]},
         {properties_key,<<"routing">>}],
    DBinding =
        [{exchange,<<"">>},
         {vhost,<<"/">>},
         {queue,<<"myqueue">>},
         {routing_key,<<"myqueue">>},
         {arguments,[]},
         {properties_key,<<"myqueue">>}],
    Binding = http_get("/bindings/%2f/myqueue/myexchange/routing"),
    assert_list([Binding],
                http_get("/bindings/%2f/myqueue/myexchange")),
    assert_list([Binding, DBinding],
                http_get("/queues/%2f/myqueue/bindings")),
    assert_list([Binding],
                http_get("/exchanges/%2f/myexchange/bindings")),
    http_delete("/bindings/%2f/myqueue/myexchange/routing", ?NO_CONTENT),
    http_delete("/bindings/%2f/myqueue/myexchange/routing", ?NOT_FOUND),
    http_delete("/exchanges/%2f/myexchange", ?NO_CONTENT),
    http_delete("/queues/%2f/myqueue", ?NO_CONTENT),
    http_get("/bindings/badvhost", ?NOT_FOUND),
    http_get("/bindings/badvhost/myqueue/myexchange/routing", ?NOT_FOUND),
    http_get("/bindings/%2f/myqueue/myexchange/routing", ?NOT_FOUND),
    ok.

bindings_post_test() ->
    XArgs = [{type, <<"direct">>}, {durable, false}, {auto_delete, false},
             {arguments, []}],
    QArgs = [{durable, false}, {auto_delete, false}, {arguments, []}],
    BArgs = [{routing_key, <<"routing">>}, {arguments, []}],
    http_put("/exchanges/%2f/myexchange", XArgs, ?NO_CONTENT),
    http_put("/queues/%2f/myqueue", QArgs, ?NO_CONTENT),
    http_post("/bindings/%2f/badqueue/myexchange", BArgs, ?NOT_FOUND),
    http_post("/bindings/%2f/myqueue/badexchange", BArgs, ?NOT_FOUND),
    http_post("/bindings/%2f/myqueue/myexchange", [{a, "b"}], ?BAD_REQUEST),
    Headers = http_post("/bindings/%2f/myqueue/myexchange", BArgs, ?CREATED),
    "/api/bindings/%2F/myqueue/myexchange/routing" =
        pget("location", Headers),
    [{exchange,<<"myexchange">>},
     {vhost,<<"/">>},
     {queue,<<"myqueue">>},
     {routing_key,<<"routing">>},
     {arguments,[]},
     {properties_key,<<"routing">>}] =
        http_get("/bindings/%2f/myqueue/myexchange/routing", ?OK),
    http_delete("/bindings/%2f/myqueue/myexchange/routing", ?NO_CONTENT),
    http_delete("/exchanges/%2f/myexchange", ?NO_CONTENT),
    http_delete("/queues/%2f/myqueue", ?NO_CONTENT),
    ok.

permissions_administrator_test() ->
    http_put("/users/isadmin", [{password, <<"isadmin">>},
                                {administrator, true}], ?NO_CONTENT),
    http_put("/users/notadmin", [{password, <<"notadmin">>},
                                 {administrator, true}], ?NO_CONTENT),
    http_put("/users/notadmin", [{password, <<"notadmin">>},
                                 {administrator, false}], ?NO_CONTENT),
    Test =
        fun(Path) ->
                http_get(Path, "notadmin", "notadmin", ?NOT_AUTHORISED),
                http_get(Path, "isadmin", "isadmin", ?OK),
                http_get(Path, "guest", "guest", ?OK)
        end,
    %% All users can get a list of vhosts. It may be filtered.
    %%Test("/vhosts"),
    Test("/vhosts/%2f"),
    Test("/vhosts/%2f/permissions"),
    Test("/users"),
    Test("/users/guest"),
    Test("/users/guest/permissions"),
    Test("/permissions"),
    Test("/permissions/%2f/guest"),
    http_delete("/users/notadmin", ?NO_CONTENT),
    http_delete("/users/isadmin", ?NO_CONTENT),
    ok.

permissions_vhost_test() ->
    QArgs = [{durable, false}, {auto_delete, false}, {arguments, []}],
    PermArgs = [{configure, <<".*">>}, {write, <<".*">>}, {read, <<".*">>}],
    http_put("/users/myuser", [{password, <<"myuser">>},
                               {administrator, false}], ?NO_CONTENT),
    http_put("/vhosts/myvhost1", [], ?NO_CONTENT),
    http_put("/vhosts/myvhost2", [], ?NO_CONTENT),
    http_put("/permissions/myvhost1/myuser", PermArgs, ?NO_CONTENT),
    http_put("/permissions/myvhost1/guest", PermArgs, ?NO_CONTENT),
    http_put("/permissions/myvhost2/guest", PermArgs, ?NO_CONTENT),
    assert_list([[{name, <<"/">>}],
                 [{name, <<"myvhost1">>}],
                 [{name, <<"myvhost2">>}]], http_get("/vhosts", ?OK)),
    assert_list([[{name, <<"myvhost1">>}]],
                http_get("/vhosts", "myuser", "myuser", ?OK)),
    http_put("/queues/myvhost1/myqueue", QArgs, ?NO_CONTENT),
    http_put("/queues/myvhost2/myqueue", QArgs, ?NO_CONTENT),
    Test1 =
        fun(Path) ->
                Results = http_get(Path, "myuser", "myuser", ?OK),
                [case pget(vhost, Result) of
                     <<"myvhost2">> ->
                         throw({got_result_from_vhost2_in, Path, Result});
                     _ ->
                         ok
                 end || Result <- Results]
        end,
    Test2 =
        fun(Path1, Path2) ->
                http_get(Path1 ++ "/myvhost1/" ++ Path2, "myuser", "myuser",
                         ?OK),
                http_get(Path1 ++ "/myvhost2/" ++ Path2, "myuser", "myuser",
                         ?NOT_AUTHORISED)
        end,
    Test1("/exchanges"),
    Test2("/exchanges", ""),
    Test2("/exchanges", "amq.direct"),
    Test1("/queues"),
    Test2("/queues", ""),
    Test2("/queues", "myqueue"),
    Test1("/bindings"),
    Test2("/bindings", ""),
    Test2("/queues", "myqueue/bindings"),
    Test2("/exchanges", "amq.default/bindings"),
    Test2("/bindings", "myqueue/amq.default"),
    Test2("/bindings", "myqueue/amq.default/myqueue"),
    http_delete("/vhosts/myvhost1", ?NO_CONTENT),
    http_delete("/vhosts/myvhost2", ?NO_CONTENT),
    http_delete("/users/myuser", ?NO_CONTENT),
    ok.

permissions_amqp_test() ->
    %% Just test that it works at all, not that it works in all possible cases.
    QArgs = [{durable, false}, {auto_delete, false}, {arguments, []}],
    PermArgs = [{configure, <<"foo.*">>}, {write, <<"foo.*">>},
                {read,      <<"foo.*">>}],
    http_put("/users/myuser", [{password, <<"myuser">>},
                               {administrator, false}], ?NO_CONTENT),
    http_put("/permissions/%2f/myuser", PermArgs, ?NO_CONTENT),
    http_put("/queues/%2f/bar-queue", QArgs, "myuser", "myuser", ?NOT_AUTHORISED),
    http_put("/queues/%2f/bar-queue", QArgs, "nonexistent", "nonexistent", ?NOT_AUTHORISED),
    http_delete("/users/myuser", ?NO_CONTENT),
    ok.

get_conn(Username, Password) ->
    {ok, Conn} = amqp_connection:start(network, #amqp_params{
                                        username = Username,
                                        password = Password}),
    LocalPort = rabbit_mgmt_test_db:local_port(Conn),
    ConnPath = binary_to_list(
                 rabbit_mgmt_format:print(
                   "/connections/127.0.0.1%3A~w", [LocalPort])),
    ChPath = binary_to_list(
               rabbit_mgmt_format:print(
                 "/channels/127.0.0.1%3A~w%3A1", [LocalPort])),
    {Conn, ConnPath, ChPath}.

permissions_connection_channel_test() ->
    PermArgs = [{configure, <<".*">>}, {write, <<".*">>}, {read, <<".*">>}],
    http_put("/users/user", [{password, <<"user">>},
                             {administrator, false}], ?NO_CONTENT),
    http_put("/permissions/%2f/user", PermArgs, ?NO_CONTENT),
    {Conn1, ConnPath1, ChPath1} = get_conn("user", "user"),
    {Conn2, ConnPath2, ChPath2} = get_conn("guest", "guest"),
    {ok, _Ch1} = amqp_connection:open_channel(Conn1),
    {ok, _Ch2} = amqp_connection:open_channel(Conn2),

    2 = length(http_get("/connections", ?OK)),
    1 = length(http_get("/connections", "user", "user", ?OK)),
    http_get(ConnPath1, ?OK),
    http_get(ConnPath2, ?OK),
    http_get(ConnPath1, "user", "user", ?OK),
    http_get(ConnPath2, "user", "user", ?NOT_AUTHORISED),
    2 = length(http_get("/channels", ?OK)),
    1 = length(http_get("/channels", "user", "user", ?OK)),
    http_get(ChPath1, ?OK),
    http_get(ChPath2, ?OK),
    http_get(ChPath1, "user", "user", ?OK),
    http_get(ChPath2, "user", "user", ?NOT_AUTHORISED),
    amqp_connection:close(Conn1),
    amqp_connection:close(Conn2),
    http_delete("/users/user", ?NO_CONTENT),
    http_get("/connections/foo", ?NOT_FOUND),
    http_get("/channels/foo", ?NOT_FOUND),
    ok.

unicode_test() ->
    QArgs = [{durable, false}, {auto_delete, false}, {arguments, []}],
    http_put("/queues/%2f/♫♪♫♪", QArgs, ?NO_CONTENT),
    http_get("/queues/%2f/♫♪♫♪", ?OK),
    http_delete("/queues/%2f/♫♪♫♪", ?NO_CONTENT),
    ok.

all_configuration_test() ->
    XArgs = [{type, <<"direct">>}, {durable, false}, {auto_delete, false},
             {arguments, []}],
    QArgs = [{durable, false}, {auto_delete, false}, {arguments, []}],
    http_put("/queues/%2f/my-queue", QArgs, ?NO_CONTENT),
    http_put("/exchanges/%2f/my-exchange", XArgs, ?NO_CONTENT),
    http_put("/bindings/%2f/my-queue/my-exchange/routing", [], ?NO_CONTENT),
    AllConfig = http_get("/all-configuration", ?OK),
    http_delete("/bindings/%2f/my-queue/my-exchange/routing", ?NO_CONTENT),
    http_delete("/queues/%2f/my-queue", ?NO_CONTENT),
    http_delete("/exchanges/%2f/my-exchange", ?NO_CONTENT),
    http_post("/all-configuration", AllConfig, ?NO_CONTENT),
    http_delete("/bindings/%2f/my-queue/my-exchange/routing", ?NO_CONTENT),
    http_delete("/queues/%2f/my-queue", ?NO_CONTENT),
    http_delete("/exchanges/%2f/my-exchange", ?NO_CONTENT),
    ExtraConfig =
        [{users,       []},
         {vhosts,      []},
         {permissions, []},
         {queues,       [[{name,        <<"another-queue">>},
                          {vhost,       <<"/">>},
                          {durable,     true},
                          {auto_delete, false},
                          {arguments,   []}
                         ]]},
         {exchanges,   []},
         {bindings,    []}],
    BrokenConfig =
        [{users,       []},
         {vhosts,      []},
         {permissions, []},
         {queues,      []},
         {exchanges,   [[{name,        <<"amq.direct">>},
                         {vhost,       <<"/">>},
                         {type,        <<"definitely not direct">>},
                         {durable,     true},
                         {auto_delete, false},
                         {arguments,   []}
                        ]]},
         {bindings,    []}],
    http_post("/all-configuration", ExtraConfig, ?NO_CONTENT),
    http_post("/all-configuration", BrokenConfig, ?BAD_REQUEST),
    http_delete("/queues/%2f/another-queue", ?NO_CONTENT),
    ok.

all_configuration_remove_things_test() ->
    {ok, Conn} = amqp_connection:start(network, #amqp_params{}),
    {ok, Ch} = amqp_connection:open_channel(Conn),
    amqp_channel:call(Ch, #'queue.declare'{ queue = <<"my-exclusive">>,
                                            exclusive = true }),
    http_get("/queues/%2f/my-exclusive", ?OK),
    AllConfig = http_get("/all-configuration", ?OK),
    [] = pget(queues, AllConfig),
    [] = pget(exchanges, AllConfig),
    [] = pget(bindings, AllConfig),
    amqp_channel:close(Ch),
    amqp_connection:close(Conn),
    ok.

all_configuration_server_named_queue_test() ->
    {ok, Conn} = amqp_connection:start(network, #amqp_params{}),
    {ok, Ch} = amqp_connection:open_channel(Conn),
    #'queue.declare_ok'{ queue = QName } =
        amqp_channel:call(Ch, #'queue.declare'{}),
    amqp_channel:close(Ch),
    amqp_connection:close(Conn),
    Path = "/queues/%2f/" ++ mochiweb_util:quote_plus(QName),
    http_get(Path, ?OK),
    AllConfig = http_get("/all-configuration", ?OK),
    http_delete(Path, ?NO_CONTENT),
    http_get(Path, ?NOT_FOUND),
    http_post("/all-configuration", AllConfig, ?NO_CONTENT),
    http_get(Path, ?OK),
    http_delete(Path, ?NO_CONTENT),
    ok.

aliveness_test() ->
    [{status, <<"ok">>}] = http_get("/aliveness-test/%2f", ?OK),
    http_get("/aliveness-test/foo", ?NOT_FOUND),
    http_delete("/queues/%2f/aliveness-test", ?NO_CONTENT),
    ok.

arguments_test() ->
    XArgs = [{type, <<"headers">>}, {durable, false}, {auto_delete, false},
             {arguments, [{'alternate-exchange', <<"amq.direct">>}]}],
    QArgs = [{durable, false}, {auto_delete, false},
             {arguments, [{'x-expires', 1800000}]}],
    BArgs = [{routing_key, <<"">>},
             {arguments, [{'x-match', <<"all">>},
                          {foo, <<"bar">>}]}],
    http_put("/exchanges/%2f/myexchange", XArgs, ?NO_CONTENT),
    http_put("/queues/%2f/myqueue", QArgs, ?NO_CONTENT),
    http_post("/bindings/%2f/myqueue/myexchange", BArgs, ?CREATED),
    AllConfig = http_get("/all-configuration", ?OK),
    http_delete("/exchanges/%2f/myexchange", ?NO_CONTENT),
    http_delete("/queues/%2f/myqueue", ?NO_CONTENT),
    http_post("/all-configuration", AllConfig, ?NO_CONTENT),
    [{'alternate-exchange', <<"amq.direct">>}] =
        pget(arguments, http_get("/exchanges/%2f/myexchange", ?OK)),
    [{'x-expires', 1800000}] =
        pget(arguments, http_get("/queues/%2f/myqueue", ?OK)),
    [{foo, <<"bar">>}, {'x-match', <<"all">>}] =
        pget(arguments,
             http_get("/bindings/%2f/myqueue/myexchange/" ++
                          "_foo_bar_x-match_all", ?OK)),
    http_delete("/exchanges/%2f/myexchange", ?NO_CONTENT),
    http_delete("/queues/%2f/myqueue", ?NO_CONTENT),
    ok.

queue_purge_test() ->
    QArgs = [{durable, false}, {auto_delete, false}, {arguments, []}],
    http_put("/queues/%2f/myqueue", QArgs, ?NO_CONTENT),
    {ok, Conn} = amqp_connection:start(network, #amqp_params{}),
    {ok, Ch} = amqp_connection:open_channel(Conn),
    Publish = fun() ->
                      amqp_channel:call(
                        Ch, #'basic.publish'{exchange = <<"">>,
                                             routing_key = <<"myqueue">>},
                        #amqp_msg{payload = <<"message">>})
              end,
    Publish(),
    Publish(),
    amqp_channel:call(
      Ch, #'queue.declare'{queue = <<"exclusive">>, exclusive = true}),
    {#'basic.get_ok'{}, _} =
        amqp_channel:call(Ch, #'basic.get'{queue = <<"myqueue">>}),
    http_delete("/queues/%2f/myqueue/contents", ?NO_CONTENT),
    http_delete("/queues/%2f/badqueue/contents", ?NOT_FOUND),
    http_delete("/queues/%2f/exclusive/contents", ?BAD_REQUEST),
    http_delete("/queues/%2f/exclusive", ?BAD_REQUEST),
    #'basic.get_empty'{} =
        amqp_channel:call(Ch, #'basic.get'{queue = <<"myqueue">>}),
    amqp_channel:close(Ch),
    amqp_connection:close(Conn),
    http_delete("/queues/%2f/myqueue", ?NO_CONTENT),
    ok.

sorting_test() ->
    QArgs = [{durable, false}, {auto_delete, false}, {arguments, []}],
    PermArgs = [{configure, <<".*">>}, {write, <<".*">>}, {read, <<".*">>}],
    http_put("/vhosts/vh1", [], ?NO_CONTENT),
    http_put("/permissions/vh1/guest", PermArgs, ?NO_CONTENT),
    http_put("/queues/%2f/test0", QArgs, ?NO_CONTENT),
    http_put("/queues/vh1/test1", QArgs, ?NO_CONTENT),
    http_put("/queues/%2f/test2", QArgs, ?NO_CONTENT),
    http_put("/queues/vh1/test3", QArgs, ?NO_CONTENT),
    assert_list([[{name, <<"test0">>}],
                 [{name, <<"test2">>}],
                 [{name, <<"test1">>}],
                 [{name, <<"test3">>}]], http_get("/queues", ?OK)),
    assert_list([[{name, <<"test0">>}],
                 [{name, <<"test1">>}],
                 [{name, <<"test2">>}],
                 [{name, <<"test3">>}]], http_get("/queues?sort=name", ?OK)),
    assert_list([[{name, <<"test0">>}],
                 [{name, <<"test2">>}],
                 [{name, <<"test1">>}],
                 [{name, <<"test3">>}]], http_get("/queues?sort=vhost", ?OK)),
    assert_list([[{name, <<"test3">>}],
                 [{name, <<"test1">>}],
                 [{name, <<"test2">>}],
                 [{name, <<"test0">>}]], http_get("/queues?sort_reverse=true", ?OK)),
    assert_list([[{name, <<"test3">>}],
                 [{name, <<"test2">>}],
                 [{name, <<"test1">>}],
                 [{name, <<"test0">>}]], http_get("/queues?sort=name&sort_reverse=true", ?OK)),
    assert_list([[{name, <<"test3">>}],
                 [{name, <<"test1">>}],
                 [{name, <<"test2">>}],
                 [{name, <<"test0">>}]], http_get("/queues?sort=vhost&sort_reverse=true", ?OK)),
    %% Rather poor but at least test it doesn't blow up with dots
    http_get("/queues?sort=owner_pid_details.name", ?OK),
    http_delete("/queues/%2f/test0", ?NO_CONTENT),
    http_delete("/queues/vh1/test1", ?NO_CONTENT),
    http_delete("/queues/%2f/test2", ?NO_CONTENT),
    http_delete("/queues/vh1/test3", ?NO_CONTENT),
    http_delete("/vhosts/vh1", ?NO_CONTENT),
    ok.

%%---------------------------------------------------------------------------
http_get(Path) ->
    http_get(Path, ?OK).

http_get(Path, CodeExp) ->
    http_get(Path, "guest", "guest", CodeExp).

http_get(Path, User, Pass, CodeExp) ->
    {ok, {{_HTTP, CodeExp, _}, Headers, ResBody}} =
        req(get, Path, [auth_header(User, Pass)]),
    decode(CodeExp, Headers, ResBody).

http_put(Path, List, CodeExp) ->
    http_put_raw(Path, format_for_upload(List), CodeExp).

http_put(Path, List, User, Pass, CodeExp) ->
    http_put_raw(Path, format_for_upload(List), User, Pass, CodeExp).

http_post(Path, List, CodeExp) ->
    http_post_raw(Path, format_for_upload(List), CodeExp).

format_for_upload(List) ->
    iolist_to_binary(mochijson2:encode({struct, List})).

http_put_raw(Path, Body, CodeExp) ->
    http_upload_raw(put, Path, Body, "guest", "guest", CodeExp).

http_put_raw(Path, Body, User, Pass, CodeExp) ->
    http_upload_raw(put, Path, Body, User, Pass, CodeExp).

http_post_raw(Path, Body, CodeExp) ->
    http_upload_raw(post, Path, Body, "guest", "guest", CodeExp).

%% TODO Lose the sleep below. What is happening async?
http_upload_raw(Type, Path, Body, User, Pass, CodeExp) ->
    {ok, {{_HTTP, CodeExp, _}, Headers, ResBody}} =
        req(Type, Path, [auth_header(User, Pass)], Body),
    timer:sleep(100),
    decode(CodeExp, Headers, ResBody).

http_delete(Path, CodeExp) ->
    {ok, {{_HTTP, CodeExp, _}, Headers, ResBody}} =
        req(delete, Path, [auth_header()]),
    decode(CodeExp, Headers, ResBody).

req(Type, Path, Headers) ->
    httpc:request(Type, {?PREFIX ++ Path, Headers}, [], []).

req(Type, Path, Headers, Body) ->
    httpc:request(Type, {?PREFIX ++ Path, Headers, "application/json", Body},
                  [], []).

decode(?OK, _Headers,  ResBody) -> cleanup(mochijson2:decode(ResBody));
decode(_,    Headers, _ResBody) -> Headers.

cleanup(L) when is_list(L) ->
    [cleanup(I) || I <- L];
cleanup({struct, I}) ->
    cleanup(I);
cleanup({K, V}) when is_binary(K) ->
    {list_to_atom(binary_to_list(K)), cleanup(V)};
cleanup(I) ->
    I.

auth_header() ->
    auth_header("guest", "guest").

auth_header(Username, Password) ->
    {"Authorization",
     "Basic " ++ binary_to_list(base64:encode(Username ++ ":" ++ Password))}.

%%---------------------------------------------------------------------------

assert_list(Exp, Act) ->
    case length(Exp) == length(Act) of
        true  -> ok;
        false -> throw({expected, Exp, actual, Act})
    end,
    [case length(lists:filter(fun(ActI) -> test_item(ExpI, ActI) end, Act)) of
         1 -> ok;
         N -> throw({found, N, ExpI, in, Act})
     end || ExpI <- Exp].

assert_item(Exp, Act) ->
    case test_item0(Exp, Act) of
        [] -> ok;
        Or -> throw(Or)
    end.

test_item(Exp, Act) ->
    case test_item0(Exp, Act) of
        [] -> true;
        _  -> false
    end.

test_item0(Exp, Act) ->
    [{did_not_find, ExpI, in, Act} || ExpI <- Exp,
                                      not lists:member(ExpI, Act)].

%%---------------------------------------------------------------------------

pget(K, L) ->
     proplists:get_value(K, L).
