# Flags
default['f2k']['registered'] = false

# x2kafka netflow listener
default['f2k']['port'] = 2055
default['f2k']['kafka_brokers'] = ['kafka.service:9092']
default['f2k']['kafka_topic'] = 'rb_flow'
# keepalived checks /health on this port: keep it in sync with the health_port of f2k
# in cookbook-rb-manager and with the ports opened by cookbook-rb-firewall
default['f2k']['stats_port'] = 7983
# x2kafka only refreshes a template when the exporter resends it, so keep them longer
# than the exporters' template refresh (cisco resends every 30 minutes)
default['f2k']['template_ttl'] = 3600
