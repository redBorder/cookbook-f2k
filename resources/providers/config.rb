# Cookbook:: f2k
# Provider:: config

include F2k::Helper

action :add do
  begin
    config_dir = new_resource.config_dir
    sensors = new_resource.sensors

    # redborder-f2k ships the f2k unit running x2kafka and obsoletes the legacy f2k package
    dnf_package 'redborder-f2k' do
      action :upgrade
    end

    # restart f2k when a new x2kafka is installed
    dnf_package 'x2kafka' do
      action :upgrade
      notifies :restart, 'service[f2k]', :delayed unless node['redborder']['leader_configuring']
    end

    # leftovers of the legacy f2k daemon
    file '/etc/sysconfig/f2k' do
      action :delete
    end

    directory '/var/cache/f2k' do
      recursive true
      action :delete
    end

    # Directory creation
    directory config_dir do
      owner 'root'
      group 'root'
      mode '0755'
    end

    directory '/etc/objects' do
      owner 'root'
      group 'root'
      mode '0777'
      action :create
    end

    service 'f2k' do
      supports status: true, start: true, restart: true, reload: true, stop: true
      if node['redborder']['leader_configuring']
        action [:enable, :stop]
      else
        action [:enable, :start]
      end
    end

    # Templates
    template "#{config_dir}/config.json" do
      source 'f2k_config.erb'
      cookbook 'f2k'
      owner 'root'
      group 'root'
      mode '0644'
      retries 2
      variables(config: x2kafka_config(sensors))
      notifies :reload, 'service[f2k]', :delayed unless node['redborder']['leader_configuring']
    end

    # Objects templates
    %w(icmps interfaces hosts).each do |ob|
      objects = get_objects(ob)

      template "/etc/objects/#{ob}" do
        source 'objects_hosts.erb'
        owner 'root'
        group 'root'
        mode '0644'
        retries 2
        cookbook 'f2k'
        variables(objects: objects)
        notifies :reload, 'service[f2k]', :delayed unless node['redborder']['leader_configuring']
      end
    end

    %w(macs protocols services networks vlans).each do |ob|
      begin
        ob_db = data_bag_item('rBglobal', ob)
      rescue
        ob_db = nil
      end

      objects = {}

      if ob_db && ob_db['list'] && !ob_db['list'].empty?
        objects = ob_db['list']
      end

      template "/etc/objects/#{ob}" do
        source 'objects.erb'
        owner 'root'
        group 'root'
        mode '0644'
        retries 2
        cookbook 'f2k'
        variables(objects: objects)
        notifies :reload, 'service[f2k]', :delayed unless node['redborder']['leader_configuring']
      end
    end

    %w(http_domains http_host_l1_alias os engines).each do |ob|
      template "/etc/objects/#{ob}" do
        source "objects_#{ob}.erb"
        owner 'root'
        group 'root'
        mode '0644'
        retries 2
        cookbook 'f2k'
        notifies :reload, 'service[f2k]', :delayed unless node['redborder']['leader_configuring']
      end
    end

    begin
      app_db = data_bag_item('rBglobal', 'applications')
    rescue
      app_db = nil
    end

    if app_db.nil? || app_db['list'].nil? || app_db['list'].empty?
      template '/etc/objects/applications' do
        source 'objects_default_applications.erb'
        owner 'root'
        group 'root'
        mode '0644'
        retries 2
        cookbook 'f2k'
        notifies :reload, 'service[f2k]', :delayed unless node['redborder']['leader_configuring']
      end
    else
      template '/etc/objects/applications' do
        source 'objects_applications.erb'
        owner 'root'
        group 'root'
        mode '0644'
        retries 2
        cookbook 'f2k'
        variables(applications: app_db['list'])
        notifies :reload, 'service[f2k]', :delayed unless node['redborder']['leader_configuring']
      end
    end
    # End objects templates

    Chef::Log.info('f2k cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service 'f2k' do
      supports stop: true, disable: true
      action [:stop, :disable]
    end

    Chef::Log.info('f2k cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    unless node['f2k']['registered']
      query = {}
      query['ID'] = "f2k-#{node['hostname']}"
      query['Name'] = 'f2k'
      query['Address'] = "#{node['ipaddress']}"
      query['Port'] = node['f2k']['port']
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['f2k']['registered'] = true
    end
    Chef::Log.info('f2k service has been registered in consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['f2k']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/f2k-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['f2k']['registered'] = false
    end
    Chef::Log.info('f2k service has been deregistered from consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end
