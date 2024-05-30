# Cookbook:: f2k
# Provider:: config

include F2k::Helper

action :add do
  begin
    cores = new_resource.cores
    memory_kb = new_resource.memory_kb
    enrichment_enabled = new_resource.enrichment_enabled
    cache_dir = new_resource.cache_dir
    config_dir = new_resource.config_dir
    templates_dir = new_resource.templates_dir
    user = new_resource.user
    sensors = new_resource.sensors

    # RPM Installation
    dnf_package 'f2k' do
      action :upgrade
      flush_cache [ :before ]
    end

    # User creation
    execute 'create_user' do
      command "/usr/sbin/useradd #{user}"
      ignore_failure true
      not_if "getent passwd #{user}"
    end

    # Directory creation
    directory config_dir do
      owner 'root'
      group 'root'
      mode '0755'
    end

    directory cache_dir do
      owner user
      group user
      mode '0755'
    end

    directory templates_dir do
      owner user
      group user
      mode '0755'
    end

    directory '/etc/objects' do
      owner 'root'
      group 'root'
      mode '0777'
      action :create
    end

    # Memory calculation
    dns_cache_size_mb = [memory_kb / (4 * 1024), 10].max.to_i
    buffering_max_messages = [memory_kb / 4, 1000].max.to_i

    # Templates
    template '/etc/sysconfig/f2k' do
      source 'f2k_sysconfig.erb'
      cookbook 'f2k'
      owner 'root'
      group 'root'
      mode '0644'
      retries 2
      variables(cores: cores,
                enrichment_enabled: enrichment_enabled,
                cache_dir: cache_dir,
                config_file: "#{config_dir}/config.json",
                dns_cache_size_mb: dns_cache_size_mb,
                user: user,
                buffering_max_messages: buffering_max_messages)
      notifies :reload, 'service[f2k]', :delayed
    end

    template "#{config_dir}/config.json" do
      source 'f2k_config.erb'
      cookbook 'f2k'
      owner 'root'
      group 'root'
      mode '0644'
      retries 2
      variables(sensors: sensors)
      helpers F2k::Renderer
      notifies :reload, 'service[f2k]', :delayed
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
        notifies :reload, 'service[f2k]', :delayed
      end
    end

    %w(macs protocols services networks vlans).each do |ob|
      ob_db = Chef::DataBagItem.load('rBglobal', ob) rescue ob_db = nil
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
        notifies :reload, 'service[f2k]', :delayed
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
        notifies :reload, 'service[f2k]', :delayed
      end
    end

    app_db = Chef::DataBagItem.load('rBglobal', 'applications') rescue app_db = nil

    if app_db || app_db['list'].nil? || app_db['list'].empty?
      template '/etc/objects/applications' do
        source 'objects_default_applications.erb'
        owner 'root'
        group 'root'
        mode '0644'
        retries 2
        cookbook 'f2k'
        notifies :reload, 'service[f2k]', :delayed
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
        notifies :reload, 'service[f2k]', :delayed
      end
    end
    # End objects templates

    service 'f2k' do
      supports status: true, start: true, restart: true, reload: true, stop: true
      action [:enable, :start]
    end

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
      query['Port'] = 2055
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
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/f2k-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['f2k']['registered'] = false
    end
    Chef::Log.info('f2k service has been deregistered from consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end
