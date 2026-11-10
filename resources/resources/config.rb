# Cookbook:: f2k
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :config_dir, kind_of: String, default: '/etc/f2k'
attribute :sensors, kind_of: Hash, default: {}
