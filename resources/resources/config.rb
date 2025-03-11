# Cookbook:: rb-druid-indexer
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :config_dir, kind_of: String, default: '/etc/rb-druid-indexer'
attribute :log_dir, kind_of: String, default: '/var/log/rb-druid-indexer'
attribute :user, kind_of: String, default: 'rb-druid-indexer'
attribute :zookeeper_servers, kind_of: Array, default: ['zookeeper.service:2181']
attribute :namespaces, kind_of: Array, default: []
attribute :tasks, kind_of: Array, default: []
