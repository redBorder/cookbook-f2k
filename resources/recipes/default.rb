#
# Cookbook Name:: f2k
# Recipe:: default
#
# Copyright 2017, redborder
#
# AFFERO GENERAL PUBLIC LICENSE, Version 3
#

f2k_config "config" do
	sensors node["redborder"]["sensors_info"]["flow-sensor"]
  action :add
end
