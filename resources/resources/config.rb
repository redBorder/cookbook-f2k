# Cookbook Name:: f2k
#
# Resource:: config
#

actions :add, :remove, :register, :deregister
default_action :add

attribute :cores, :kind_of => Integer, :default => 1
attribute :memory_kb, :kind_of => Integer, :default => 102400
attribute :enrichment_enabled, :kind_of => [TrueClass, FalseClass], :default => true
attribute :cache_dir, :kind_of => String, :default => "/var/cache/f2k"
attribute :templates_dir, :kind_of => String, :default => "/var/cache/f2k/templates"
attribute :config_dir, :kind_of => String, :default => "/etc/f2k"
attribute :user, :kind_of => String, :default => "f2k"
attribute :sensors, :kind_of => Hash, :default => {}
