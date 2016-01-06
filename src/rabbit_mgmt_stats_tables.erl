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
%%   The Original Code is RabbitMQ.
%%
%%   The Initial Developer of the Original Code is Pivotal Software, Inc.
%%   Copyright (c) 2010-2015 Pivotal Software, Inc.  All rights reserved.
%%

-module(rabbit_mgmt_stats_tables).

-include("rabbit_mgmt_metrics.hrl").

-export([aggr_table/2, aggr_tables/1, type_from_table/1]).

-spec aggr_table(event_type(), type()) -> table_name().
aggr_table(queue_stats, deliver_get) ->
    aggr_queue_stats_deliver_get;
aggr_table(queue_stats, fine_stats) ->
    aggr_queue_stats_fine_stats;
aggr_table(queue_stats, queue_msg_rates) ->
    aggr_queue_stats_queue_msg_rates;
aggr_table(queue_stats, queue_msg_counts) ->
    aggr_queue_stats_queue_msg_counts;
aggr_table(queue_stats, coarse_node_stats) ->
    aggr_queue_stats_coarse_node_stats;
aggr_table(queue_stats, coarse_node_node_stats) ->
    aggr_queue_stats_coarse_node_node_stats;
aggr_table(queue_stats, coarse_conn_stats) ->
    aggr_queue_stats_coarse_conn_stats;
aggr_table(queue_exchange_stats, deliver_get) ->
    aggr_queue_exchange_stats_deliver_get;
aggr_table(queue_exchange_stats, fine_stats) ->
    aggr_queue_exchange_stats_fine_stats;
aggr_table(queue_exchange_stats, queue_msg_rates) ->
    aggr_queue_exchange_stats_queue_msg_rates;
aggr_table(queue_exchange_stats, queue_msg_counts) ->
    aggr_queue_exchange_stats_queue_msg_counts;
aggr_table(queue_exchange_stats, coarse_node_stats) ->
    aggr_queue_exchange_stats_coarse_node_stats;
aggr_table(queue_exchange_stats, coarse_node_node_stats) ->
    aggr_queue_exchange_stats_coarse_node_node_stats;
aggr_table(queue_exchange_stats, coarse_conn_stats) ->
    aggr_queue_exchange_stats_coarse_conn_stats;
aggr_table(vhost_stats, deliver_get) ->
    aggr_vhost_stats_deliver_get;
aggr_table(vhost_stats, fine_stats) ->
    aggr_vhost_stats_fine_stats;
aggr_table(vhost_stats, queue_msg_rates) ->
    aggr_vhost_stats_queue_msg_rates;
aggr_table(vhost_stats, queue_msg_counts) ->
    aggr_vhost_stats_queue_msg_counts;
aggr_table(vhost_stats, coarse_node_stats) ->
    aggr_vhost_stats_coarse_node_stats;
aggr_table(vhost_stats, coarse_node_node_stats) ->
    aggr_vhost_stats_coarse_node_node_stats;
aggr_table(vhost_stats, coarse_conn_stats) ->
    aggr_vhost_stats_coarse_conn_stats;
aggr_table(channel_queue_stats, deliver_get) ->
    aggr_channel_queue_stats_deliver_get;
aggr_table(channel_queue_stats, fine_stats) ->
    aggr_channel_queue_stats_fine_stats;
aggr_table(channel_queue_stats, queue_msg_rates) ->
    aggr_channel_queue_stats_queue_msg_rates;
aggr_table(channel_queue_stats, queue_msg_counts) ->
    aggr_channel_queue_stats_queue_msg_counts;
aggr_table(channel_queue_stats, coarse_node_stats) ->
    aggr_channel_queue_stats_coarse_node_stats;
aggr_table(channel_queue_stats, coarse_node_node_stats) ->
    aggr_channel_queue_stats_coarse_node_node_stats;
aggr_table(channel_queue_stats, coarse_conn_stats) ->
    aggr_channel_queue_stats_coarse_conn_stats;
aggr_table(channel_stats, deliver_get) ->
    aggr_channel_stats_deliver_get;
aggr_table(channel_stats, fine_stats) ->
    aggr_channel_stats_fine_stats;
aggr_table(channel_stats, queue_msg_rates) ->
    aggr_channel_stats_queue_msg_rates;
aggr_table(channel_stats, queue_msg_counts) ->
    aggr_channel_stats_queue_msg_counts;
aggr_table(channel_stats, coarse_node_stats) ->
    aggr_channel_stats_coarse_node_stats;
aggr_table(channel_stats, coarse_node_node_stats) ->
    aggr_channel_stats_coarse_node_node_stats;
aggr_table(channel_stats, coarse_conn_stats) ->
    aggr_channel_stats_coarse_conn_stats;
aggr_table(channel_exchange_stats, deliver_get) ->
    aggr_channel_exchange_stats_deliver_get;
aggr_table(channel_exchange_stats, fine_stats) ->
    aggr_channel_exchange_stats_fine_stats;
aggr_table(channel_exchange_stats, queue_msg_rates) ->
    aggr_channel_exchange_stats_queue_msg_rates;
aggr_table(channel_exchange_stats, queue_msg_counts) ->
    aggr_channel_exchange_stats_queue_msg_counts;
aggr_table(channel_exchange_stats, coarse_node_stats) ->
    aggr_channel_exchange_stats_coarse_node_stats;
aggr_table(channel_exchange_stats, coarse_node_node_stats) ->
    aggr_channel_exchange_stats_coarse_node_node_stats;
aggr_table(channel_exchange_stats, coarse_conn_stats) ->
    aggr_channel_exchange_stats_coarse_conn_stats;
aggr_table(exchange_stats, deliver_get) ->
    aggr_exchange_stats_deliver_get;
aggr_table(exchange_stats, fine_stats) ->
    aggr_exchange_stats_fine_stats;
aggr_table(exchange_stats, queue_msg_rates) ->
    aggr_exchange_stats_queue_msg_rates;
aggr_table(exchange_stats, queue_msg_counts) ->
    aggr_exchange_stats_queue_msg_counts;
aggr_table(exchange_stats, coarse_node_stats) ->
    aggr_exchange_stats_coarse_node_stats;
aggr_table(exchange_stats, coarse_node_node_stats) ->
    aggr_exchange_stats_coarse_node_node_stats;
aggr_table(exchange_stats, coarse_conn_stats) ->
    aggr_exchange_stats_coarse_conn_stats;
aggr_table(node_stats, deliver_get) ->
    aggr_node_stats_deliver_get;
aggr_table(node_stats, fine_stats) ->
    aggr_node_stats_fine_stats;
aggr_table(node_stats, queue_msg_rates) ->
    aggr_node_stats_queue_msg_rates;
aggr_table(node_stats, queue_msg_counts) ->
    aggr_node_stats_queue_msg_counts;
aggr_table(node_stats, coarse_node_stats) ->
    aggr_node_stats_coarse_node_stats;
aggr_table(node_stats, coarse_node_node_stats) ->
    aggr_node_stats_coarse_node_node_stats;
aggr_table(node_stats, coarse_conn_stats) ->
    aggr_node_stats_coarse_conn_stats;
aggr_table(node_node_stats, deliver_get) ->
    aggr_node_node_stats_deliver_get;
aggr_table(node_node_stats, fine_stats) ->
    aggr_node_node_stats_fine_stats;
aggr_table(node_node_stats, queue_msg_rates) ->
    aggr_node_node_stats_queue_msg_rates;
aggr_table(node_node_stats, queue_msg_counts) ->
    aggr_node_node_stats_queue_msg_counts;
aggr_table(node_node_stats, coarse_node_stats) ->
    aggr_node_node_stats_coarse_node_stats;
aggr_table(node_node_stats, coarse_node_node_stats) ->
    aggr_node_node_stats_coarse_node_node_stats;
aggr_table(node_node_stats, coarse_conn_stats) ->
    aggr_node_node_stats_coarse_conn_stats;
aggr_table(connection_stats, deliver_get) ->
    aggr_connection_stats_deliver_get;
aggr_table(connection_stats, fine_stats) ->
    aggr_connection_stats_fine_stats;
aggr_table(connection_stats, queue_msg_rates) ->
    aggr_connection_stats_queue_msg_rates;
aggr_table(connection_stats, queue_msg_counts) ->
    aggr_connection_stats_queue_msg_counts;
aggr_table(connection_stats, coarse_node_stats) ->
    aggr_connection_stats_coarse_node_stats;
aggr_table(connection_stats, coarse_node_node_stats) ->
    aggr_connection_stats_coarse_node_node_stats;
aggr_table(connection_stats, coarse_conn_stats) ->
    aggr_connection_stats_coarse_conn_stats.

-spec aggr_tables(event_type()) -> [table_name()].
aggr_tables(queue_stats) ->
    [aggr_queue_stats_deliver_get,
     aggr_queue_stats_fine_stats,
     aggr_queue_stats_queue_msg_rates,
     aggr_queue_stats_queue_msg_counts,
     aggr_queue_stats_coarse_node_stats,
     aggr_queue_stats_coarse_node_node_stats,
     aggr_queue_stats_coarse_conn_stats];
aggr_tables(queue_exchange_stats) ->
    [aggr_queue_exchange_stats_deliver_get,
     aggr_queue_exchange_stats_fine_stats,
     aggr_queue_exchange_stats_queue_msg_rates,
     aggr_queue_exchange_stats_queue_msg_counts,
     aggr_queue_exchange_stats_coarse_node_stats,
     aggr_queue_exchange_stats_coarse_node_node_stats,
     aggr_queue_exchange_stats_coarse_conn_stats];
aggr_tables(vhost_stats) ->
    [aggr_vhost_stats_deliver_get,
     aggr_vhost_stats_fine_stats,
     aggr_vhost_stats_queue_msg_rates,
     aggr_vhost_stats_queue_msg_counts,
     aggr_vhost_stats_coarse_node_stats,
     aggr_vhost_stats_coarse_node_node_stats,
     aggr_vhost_stats_coarse_conn_stats];
aggr_tables(channel_queue_stats) ->
    [aggr_channel_queue_stats_deliver_get,
     aggr_channel_queue_stats_fine_stats,
     aggr_channel_queue_stats_queue_msg_rates,
     aggr_channel_queue_stats_queue_msg_counts,
     aggr_channel_queue_stats_coarse_node_stats,
     aggr_channel_queue_stats_coarse_node_node_stats,
     aggr_channel_queue_stats_coarse_conn_stats];
aggr_tables(channel_stats) ->
    [aggr_channel_stats_deliver_get,
     aggr_channel_stats_fine_stats,
     aggr_channel_stats_queue_msg_rates,
     aggr_channel_stats_queue_msg_counts,
     aggr_channel_stats_coarse_node_stats,
     aggr_channel_stats_coarse_node_node_stats,
     aggr_channel_stats_coarse_conn_stats];
aggr_tables(channel_exchange_stats) ->
    [aggr_channel_exchange_stats_deliver_get,
     aggr_channel_exchange_stats_fine_stats,
     aggr_channel_exchange_stats_queue_msg_rates,
     aggr_channel_exchange_stats_queue_msg_counts,
     aggr_channel_exchange_stats_coarse_node_stats,
     aggr_channel_exchange_stats_coarse_node_node_stats,
     aggr_channel_exchange_stats_coarse_conn_stats];
aggr_tables(exchange_stats) ->
    [aggr_exchange_stats_deliver_get,
     aggr_exchange_stats_fine_stats,
     aggr_exchange_stats_queue_msg_rates,
     aggr_exchange_stats_queue_msg_counts,
     aggr_exchange_stats_coarse_node_stats,
     aggr_exchange_stats_coarse_node_node_stats,
     aggr_exchange_stats_coarse_conn_stats];
aggr_tables(node_stats) ->
    [aggr_node_stats_deliver_get,
     aggr_node_stats_fine_stats,
     aggr_node_stats_queue_msg_rates,
     aggr_node_stats_queue_msg_counts,
     aggr_node_stats_coarse_node_stats,
     aggr_node_stats_coarse_node_node_stats,
     aggr_node_stats_coarse_conn_stats];
aggr_tables(node_node_stats) ->
    [aggr_node_node_stats_deliver_get,
     aggr_node_node_stats_fine_stats,
     aggr_node_node_stats_queue_msg_rates,
     aggr_node_node_stats_queue_msg_counts,
     aggr_node_node_stats_coarse_node_stats,
     aggr_node_node_stats_coarse_node_node_stats,
     aggr_node_node_stats_coarse_conn_stats];
aggr_tables(connection_stats) ->
    [aggr_connection_stats_deliver_get,
     aggr_connection_stats_fine_stats,
     aggr_connection_stats_queue_msg_rates,
     aggr_connection_stats_queue_msg_counts,
     aggr_connection_stats_coarse_node_stats,
     aggr_connection_stats_coarse_node_node_stats,
     aggr_connection_stats_coarse_conn_stats].

-spec type_from_table(table_name()) -> type().
type_from_table(aggr_queue_stats_deliver_get) ->
    deliver_get;
type_from_table(aggr_queue_stats_fine_stats) ->
    fine_stats;
type_from_table(aggr_queue_stats_queue_msg_rates) ->
    queue_msg_rates;
type_from_table(aggr_queue_stats_queue_msg_counts) ->
    queue_msg_counts;
type_from_table(aggr_queue_stats_coarse_node_stats) ->
    coarse_node_stats;
type_from_table(aggr_queue_stats_coarse_node_node_stats) ->
    coarse_node_node_stats;
type_from_table(aggr_queue_stats_coarse_conn_stats) ->
    coarse_conn_stats;
type_from_table(aggr_queue_exchange_stats_deliver_get) ->
    deliver_get;
type_from_table(aggr_queue_exchange_stats_fine_stats) ->
    fine_stats;
type_from_table(aggr_queue_exchange_stats_queue_msg_rates) ->
    queue_msg_rates;
type_from_table(aggr_queue_exchange_stats_queue_msg_counts) ->
    queue_msg_counts;
type_from_table(aggr_queue_exchange_stats_coarse_node_stats) ->
    coarse_node_stats;
type_from_table(aggr_queue_exchange_stats_coarse_node_node_stats) ->
    coarse_node_node_stats;
type_from_table(aggr_queue_exchange_stats_coarse_conn_stats) ->
    coarse_conn_stats;
type_from_table(aggr_vhost_stats_deliver_get) ->
    deliver_get;
type_from_table(aggr_vhost_stats_fine_stats) ->
    fine_stats;
type_from_table(aggr_vhost_stats_queue_msg_rates) ->
    queue_msg_rates;
type_from_table(aggr_vhost_stats_queue_msg_counts) ->
    queue_msg_counts;
type_from_table(aggr_vhost_stats_coarse_node_stats) ->
    coarse_node_stats;
type_from_table(aggr_vhost_stats_coarse_node_node_stats) ->
    coarse_node_node_stats;
type_from_table(aggr_vhost_stats_coarse_conn_stats) ->
    coarse_conn_stats;
type_from_table(aggr_channel_queue_stats_deliver_get) ->
    deliver_get;
type_from_table(aggr_channel_queue_stats_fine_stats) ->
    fine_stats;
type_from_table(aggr_channel_queue_stats_queue_msg_rates) ->
    queue_msg_rates;
type_from_table(aggr_channel_queue_stats_queue_msg_counts) ->
    queue_msg_counts;
type_from_table(aggr_channel_queue_stats_coarse_node_stats) ->
    coarse_node_stats;
type_from_table(aggr_channel_queue_stats_coarse_node_node_stats) ->
    coarse_node_node_stats;
type_from_table(aggr_channel_queue_stats_coarse_conn_stats) ->
    coarse_conn_stats;
type_from_table(aggr_channel_stats_deliver_get) ->
    deliver_get;
type_from_table(aggr_channel_stats_fine_stats) ->
    fine_stats;
type_from_table(aggr_channel_stats_queue_msg_rates) ->
    queue_msg_rates;
type_from_table(aggr_channel_stats_queue_msg_counts) ->
    queue_msg_counts;
type_from_table(aggr_channel_stats_coarse_node_stats) ->
    coarse_node_stats;
type_from_table(aggr_channel_stats_coarse_node_node_stats) ->
    coarse_node_node_stats;
type_from_table(aggr_channel_stats_coarse_conn_stats) ->
    coarse_conn_stats;
type_from_table(aggr_channel_exchange_stats_deliver_get) ->
    deliver_get;
type_from_table(aggr_channel_exchange_stats_fine_stats) ->
    fine_stats;
type_from_table(aggr_channel_exchange_stats_queue_msg_rates) ->
    queue_msg_rates;
type_from_table(aggr_channel_exchange_stats_queue_msg_counts) ->
    queue_msg_counts;
type_from_table(aggr_channel_exchange_stats_coarse_node_stats) ->
    coarse_node_stats;
type_from_table(aggr_channel_exchange_stats_coarse_node_node_stats) ->
    coarse_node_node_stats;
type_from_table(aggr_channel_exchange_stats_coarse_conn_stats) ->
    coarse_conn_stats;
type_from_table(aggr_exchange_stats_deliver_get) ->
    deliver_get;
type_from_table(aggr_exchange_stats_fine_stats) ->
    fine_stats;
type_from_table(aggr_exchange_stats_queue_msg_rates) ->
    queue_msg_rates;
type_from_table(aggr_exchange_stats_queue_msg_counts) ->
    queue_msg_counts;
type_from_table(aggr_exchange_stats_coarse_node_stats) ->
    coarse_node_stats;
type_from_table(aggr_exchange_stats_coarse_node_node_stats) ->
    coarse_node_node_stats;
type_from_table(aggr_exchange_stats_coarse_conn_stats) ->
    coarse_conn_stats;
type_from_table(aggr_node_stats_deliver_get) ->
    deliver_get;
type_from_table(aggr_node_stats_fine_stats) ->
    fine_stats;
type_from_table(aggr_node_stats_queue_msg_rates) ->
    queue_msg_rates;
type_from_table(aggr_node_stats_queue_msg_counts) ->
    queue_msg_counts;
type_from_table(aggr_node_stats_coarse_node_stats) ->
    coarse_node_stats;
type_from_table(aggr_node_stats_coarse_node_node_stats) ->
    coarse_node_node_stats;
type_from_table(aggr_node_stats_coarse_conn_stats) ->
    coarse_conn_stats;
type_from_table(aggr_node_node_stats_deliver_get) ->
    deliver_get;
type_from_table(aggr_node_node_stats_fine_stats) ->
    fine_stats;
type_from_table(aggr_node_node_stats_queue_msg_rates) ->
    queue_msg_rates;
type_from_table(aggr_node_node_stats_queue_msg_counts) ->
    queue_msg_counts;
type_from_table(aggr_node_node_stats_coarse_node_stats) ->
    coarse_node_stats;
type_from_table(aggr_node_node_stats_coarse_node_node_stats) ->
    coarse_node_node_stats;
type_from_table(aggr_node_node_stats_coarse_conn_stats) ->
    coarse_conn_stats;
type_from_table(aggr_connection_stats_deliver_get) ->
    deliver_get;
type_from_table(aggr_connection_stats_fine_stats) ->
    fine_stats;
type_from_table(aggr_connection_stats_queue_msg_rates) ->
    queue_msg_rates;
type_from_table(aggr_connection_stats_queue_msg_counts) ->
    queue_msg_counts;
type_from_table(aggr_connection_stats_coarse_node_stats) ->
    coarse_node_stats;
type_from_table(aggr_connection_stats_coarse_node_node_stats) ->
    coarse_node_node_stats;
type_from_table(aggr_connection_stats_coarse_conn_stats) ->
    coarse_conn_stats;
type_from_table(A) when is_atom(A) ->
    A.