module F2k
  module Renderer
    def config_hash(flow_nodes)
      config = { sensors_networks: {} }

      flow_nodes.each do |flow_node|
        node_info = Chef::Node.load(flow_node.at(0))

        next unless node_info && node_info[:ipaddress]

        config[:sensors_networks][node_info[:ipaddress]] ||= {}
        observation = {}
        observation['enrichment'] = {}

        index_partitions = node_info.dig('redborder', 'index_partitions').nil? ? 5 : node_info['redborder']['index_partitions']
        observation['enrichment']['index_partitions'] = index_partitions

        index_replicas = node_info.dig('redborder', 'index_replicas').nil? ? 1 : node_info['redborder']['index_replicas']
        observation['enrichment']['index_replicas'] = index_replicas

        sensor_name = node_info['rbname'].nil? ? node_info.name : node_info['rbname']
        observation['enrichment']['sensor_name'] = sensor_name

        observation['enrichment']['sensor_ip'] = node_info[:ipaddress].to_s

        %w(sensor_uuid deployment deployment_uuid namespace namespace_uuid market market_uuid
          organization organization_uuid service_provider service_provider_uuid campus
          campus_uuid building building_uuid floor floor_uuid).each do |ss|
          if node_info['redborder'][ss] && !node_info['redborder'][ss].empty?
            observation['enrichment'][ss] = node_info['redborder'][ss]
          end
        end # end do |ss|

        span_port = (node_info['redborder']['spanport'] && node_info['redborder']['spanport'].to_i == 1) ? true : false
        observation['span_port'] = span_port

        observation['exporter_in_wan_side'] = true

        dns_ptr_target = (node_info['redborder']['dns_ptr_target'] && node_info['redborder']['dns_ptr_target'].to_i == 1) ? true : false
        observation['dns_ptr_target'] = dns_ptr_target

        dns_ptr_client = (node_info['redborder']['dns_ptr_target'] && node_info['redborder']['dns_ptr_client'].to_i == 1) ? true : false
        observation['dns_ptr_client'] = dns_ptr_client

        observation['home_nets'] = []
        if node_info['redborder']['homenets']
          node_info['redborder']['homenets'].each do |homenet|
            observation['home_nets'] << { 'network' => homenet['value'], 'network_name' => homenet['name'] }
          end
        end

        observation['routers_macs'] = []
        if node_info['redborder']['routers_macs']
          node_info['redborder']['routers_macs'].each do |router_mac|
            observation['routers_macs'] << router_mac['value']
          end
        end

        config[:sensors_networks][node_info[:ipaddress]]['observations_id'] ||= {}

        observation_id = node_info['redborder']['observation_id'] || 'default'
        observation_id = 'default' if observation_id.empty?

        config[:sensors_networks][node_info[:ipaddress]]['observations_id'][observation_id] = observation
      end

      config
    end
  end
end
