# Cookbook:: rb-druid-indexer
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :config_dir, kind_of: String, default: '/etc/rb-druid-indexer'
attribute :log_dir, kind_of: String, default: '/var/log/rb-druid-indexer'
attribute :user, kind_of: String, default: 'rb-druid-indexer'
attribute :zk_hosts, kind_of: Array
attribute :kafka_brokers, kind_of: Array
attribute :namespaces, kind_of: Array, default: []
attribute :tasks, kind_of: Array, default: []
