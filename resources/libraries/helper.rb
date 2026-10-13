module F2k
  module Helper
    def get_known_ips
      known_ips = {}
      # Only the needed attributes of each node are requested to the chef server
      query_filter = { 'name' => ['name'], 'rbname' => ['rbname'], 'ipaddress' => ['ipaddress'] }
      search(:node, '*:*', filter_result: query_filter).sort_by { |n| n['name'].to_s }.each do |n|
        next unless n['ipaddress'] && (n['name'] || n['rbname'])

        node_name = n['rbname'] || n['name']
        known_ips[node_name] = n['ipaddress']
      end
      known_ips
    end

    def get_objects(object_type)
      objects = {}
      if node['redborder'] &&
         node['redborder']['objects'] &&
         node['redborder']['objects'][object_type] &&
         node['redborder']['objects'][object_type].class != Chef::Node::ImmutableArray
        objects = (object_type == 'hosts') ? get_known_ips.merge(node['redborder']['objects'][object_type]) : node['redborder']['objects'][object_type]
      elsif object_type == 'hosts'
        objects = get_known_ips
      end
      objects
    end
  end
end
