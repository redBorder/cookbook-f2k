module F2k
  module Helper
    def get_known_ips
      known_ips = {}
      node_keys = Chef::Node.list.keys.sort
      node_keys.each do |n_key|
        n = Chef::Node.load n_key
        known_ips[n["rbname"].nil? ? n.name : n["rbname"]] = n["ipaddress"] if !n["ipaddress"].nil? and (!n.name.nil? or !n["rbname"].nil?)
      end
      known_ips
    end

    def get_objects(object_type)
      known_ips = get_known_ips
      objects = {}
      if (!node["redborder"].nil? and !node["redborder"]["objects"].nil? and !node["redborder"]["objects"][object_type].nil? and node["redborder"]["objects"][object_type].class != Chef::Node::ImmutableArray)
        if object_type == "hosts"
          objects = known_ips.merge(node["redborder"]["objects"][object_type])
        else
          objects = node["redborder"]["objects"][object_type]
        end
      elsif object_type == "hosts"
        objects = known_ips
      end
      objects
    end
  end
end