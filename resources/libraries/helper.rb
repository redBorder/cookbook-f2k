module F2k
  module Helper
    def get_known_ips
      known_ips = {}
      Chef::Node.list.keys.sort.each do |node_key|
        node = nil
        begin
          node = Chef::Node.load node_key
        rescue
          Chef::Log.error("[get_known_ips] Failed to load node: #{node_key}")
        end
        next unless node && node['ipaddress'] && (node.name || node['rbname'])

        node_name = node['rbname'] || node.name
        known_ips[node_name] = node['ipaddress']
      end
      known_ips
    end

    def get_objects(object_type)
      known_ips = get_known_ips
      objects = {}
      if node['redborder'] &&
         node['redborder']['objects'] &&
         node['redborder']['objects'][object_type] &&
         node['redborder']['objects'][object_type].class != Chef::Node::ImmutableArray
        objects = (object_type == 'hosts') ? known_ips.merge(node['redborder']['objects'][object_type]) : node['redborder']['objects'][object_type]
      elsif object_type == 'hosts'
        objects = known_ips
      end
      objects
    end
  end
end
