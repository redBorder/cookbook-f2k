# Cookbook:: f2k
# Recipe:: default
# Copyright:: 2024, redborder
# License:: Affero General Public License, Version 3

f2k_config 'config' do
  sensors node['redborder']['sensors_info']['flow-sensor']
  action :add
end
