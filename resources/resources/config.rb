# Cookbook:: f2k
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :config_dir, kind_of: String, default: '/etc/f2k'
attribute :sensors, kind_of: Hash, default: {}
attribute :port, kind_of: Integer, default: 2055
attribute :bind, kind_of: String, default: '0.0.0.0'
attribute :kafka_brokers, kind_of: Array, default: ['kafka.service:9092']
attribute :kafka_topic, kind_of: String, default: 'rb_flow'
# keepalived checks /health on this port (the health_port of f2k in cookbook-rb-manager)
attribute :stats_port, kind_of: Integer, default: 7983
# longer than the exporters' template refresh (cisco resends every 30 minutes)
attribute :template_ttl, kind_of: Integer, default: 3600
