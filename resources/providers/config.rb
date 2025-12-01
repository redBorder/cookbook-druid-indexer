# Cookbook:: druid-indexer
# Provider:: config

include RbDruidIndexer::Helper

action :add do
  begin
    config_dir = new_resource.config_dir
    user = new_resource.user
    tasks = new_resource.tasks
    zk_hosts = new_resource.zk_hosts
    log_dir = new_resource.log_dir

    zk_hosts = zk_hosts.map { |zk_server| "#{zk_server}.node:2181" }

    # RPM Installation
    dnf_package 'rb-druid-indexer' do
      action :upgrade
    end

    service 'rb-druid-indexer' do
      supports status: true, start: true, restart: true, reload: true, stop: true
      action [:enable, :start]
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

    directory log_dir do
      owner 'root'
      group 'root'
      mode '0755'
    end

    task_config = { 'rb_monitor': {
        dimensions: [],
        dimensions_exclusions: %w(unit type value),
        metrics: [
          { type: 'count', name: 'events' },
          { type: 'doubleSum', name: 'sum_value', fieldName: 'value' },
          { type: 'doubleMax', name: 'max_value', fieldName: 'value' },
          { type: 'doubleMin', name: 'min_value', fieldName: 'value' },
        ],
      },
      'rb_state': {
        dimensions: %w(
          wireless_station type wireless_channel wireless_tx_power wireless_admin_state wireless_op_state
          wireless_mode wireless_slot sensor_name sensor_uuid deployment deployment_uuid namespace namespace_uuid
          organizaton organization_uuid market market_uuid floor floor_uuid zone zone_uuid building building_uuid
          campus campus_uuid service_provider service_provider_uuid wireless_station_ip status wireless_station_name
          client_count
        ),
        dimensions_exclusions: [],
        metrics: [
          { type: 'count', name: 'events' },
          { type: 'doubleSum', name: 'sum_value', fieldName: 'value' },
          { type: 'hyperUnique', name: 'wireless_stations', fieldName: 'wireless_station' },
          { type: 'hyperUnique', name: 'wireless_channels', fieldName: 'wireless_channel' },
          { type: 'longSum', name: 'sum_wireless_tx_power', fieldName: 'wireless_tx_power' },
        ],
      },
      'rb_flow': {
        dimensions: %w(
          application_id_name building building_uuid campus campus_uuid client_accounting_type
          client_auth_type client_fullname client_gender client_id client_latlong client_loyality client_mac
          client_mac_vendor client_rssi client_vip conversation coordinates_map deployment deployment_uuid
          direction dot11_protocol dot11_status dst_map duration engine_id_name floor floor_uuid host
          host_l2_domain http_social_media http_user_agent https_common_name interface_name ip_as_name ip_country_code
          ip_protocol_version l4_proto lan_interface_description lan_interface_name lan_ip lan_ip_as_name lan_ip_country_code
          lan_ip_name lan_ip_net_name lan_l4_port lan_name lan_vlan market market_uuid namespace namespace_uuid organization
          organization_uuid product_name public_ip public_ip_mac referer referer_l2 scatterplot selector_name sensor_ip
          sensor_name sensor_uuid service_provider service_provider_uuid src_map tcp_flags tos type url
          wan_interface_description wan_interface_name wan_ip wan_ip_as_name wan_ip_country_code wan_ip_map wan_ip_net_name
          wan_l4_port wan_name wan_vlan wireless_id ti_category ti_average_score ti_policy_name ti_policy_id
          ti_indicators wireless_operator wireless_station zone zone_uuid client_asset_type
        ),
        dimensions_exclusions: %w(bytes pkts flow_end_reason first_switched wan_ip_name),
        metrics: [
          { type: 'count', name: 'events' },
          { type: 'longSum', name: 'sum_bytes', fieldName: 'bytes' },
          { type: 'longSum', name: 'sum_pkts', fieldName: 'pkts' },
          { type: 'longSum', name: 'sum_rssi', fieldName: 'client_rssi_num' },
          { type: 'hyperUnique', name: 'clients', fieldName: 'client_mac' },
          { type: 'hyperUnique', name: 'wireless_stations', fieldName: 'wireless_station' },
        ],
      },
      'rb_event': {
        dimensions: %w(
          src src_is_malicious dst dst_is_malicious sensor_uuid src_port dst_port src_as_name src_country_code
          dst_map src_map service_provider sha256 sha256_is_malicious file_uri file_uri_is_malicious file_size file_hostname
          file_hostname_is_malicious action ethlength_range icmptype ethsrc ethsrc_vendor ethdst ethdst_vendor ttl vlan
          classification domain_name group_name sig_generator rev priority msg sig_id dst_country_code dst_as_name
          namespace deployment market organization campus building floor floor_uuid conversation iplen_range l4_proto
          sensor_name scatterplot src_net_name dst_net_name tos service_provider_uuid namespace_uuid market_uuid
          organization_uuid campus_uuid building_uuid deployment_uuid incident_uuid event_uuid
        ),
        dimensions_exclusions: %w(payload),
        metrics: [
          { type: 'count', name: 'events' },
          { type: 'hyperUnique', name: 'signatures', fieldName: 'msg' },
        ],
      },
      'rb_vault': {
        dimensions: %w(
          pri pri_text syslogfacility syslogfacility_text syslogseverity syslogseverity_text hostname fromhost_ip
          app_name sensor_name proxy_uuid message status ti_category ti_average_score ti_policy_name ti_policy_id
          ti_indicators category source target sensor_uuid service_provider service_provider_uuid namespace namespace_uuid
          deployment deployment_uuid market market_uuid organization organization_uuid campus campus_uuid building
          building_uuid floor floor_uuid action incident_uuid alarm_id alarm_name alarm_product_type alarm_condition
          alarm_user alarm_severity lan_ip wan_ip wireless_station asset_ip_address asset_mac_address
          client_mac ethdst ethsrc
        ),
        dimensions_exclusions: %w(unit type valur),
        metrics: [
          { type: 'count', name: 'events' },
        ],
      },
      'rb_scanner': {
        dimensions: %w(
          pri pri_text syslogfacility syslogfacility_text syslogseverity syslogseverity_text hostname fromhost_ip
          app_name sensor_name proxy_uuid message status category source target sensor_uuid service_provider
          service_provider_uuid namespace namespace_uuid deployment deployment_uuid market market_uuid organization
          organization_uuid campus campus_uuid building building_uuid floor floor_uuid ipaddress scan_id scan_subtype
          scan_type result_data result cve_info vendor product version servicename protocol cpe cve port metric
          severity score mac subnet path layer ipv4 port_state
        ),
        dimensions_exclusions: [],
        metrics: [
          { type: 'count', name: 'events' },
        ],
      },
      'rb_host_discovery' => {
        dimensions: %w(
          ip mac vendor hostname os os_vendor os_family os_gen services cpe open_ports_count scan_id timestamp
          sensor_name sensor_uuid service_provider service_provider_uuid namespace namespace_uuid organization
          organization_uuid zone zone_uuid building building_uuid campus campus_uuid deployment deployment_uuid
          market market_uuid floor floor_uuid scan_type
        ),
        dimensions_exclusions: [],
        metrics: [
          { type: 'count', name: 'events' },
        ],
      },
      'rb_location': {
        dimensions: %w(
          location_id latitude longitude address city region country postal_code sensor_name sensor_uuid
          deployment deployment_uuid namespace namespace_uuid organization organization_uuid market market_uuid floor
          floor_uuid zone zone_uuid building building_uuid campus campus_uuid service_provider service_provider_uuid
        ),
        dimensions_exclusions: [],
        metrics: [
          { type: 'count', name: 'events' },
          { type: 'doubleSum', name: 'sum_latitude', fieldName: 'latitude' },
          { type: 'doubleSum', name: 'sum_longitude', fieldName: 'longitude' },
          { type: 'hyperUnique', name: 'unique_locations', fieldName: 'location_id' },
        ],
      },
      'rb_wireless': {
        dimensions: %w(
          wireless_station type wireless_channel wireless_tx_power wireless_admin_state wireless_op_state wireless_mode
          wireless_slot sensor_name sensor_uuid deployment deployment_uuid namespace namespace_uuid organization
          organization_uuid market market_uuid floor floor_uuid zone zone_uuid building building_uuid campus campus_uuid
          service_provider service_provider_uuid wireless_station_ip status wireless_station_name client_count
        ),
        dimensions_exclusions: [],
        metrics: [
          { type: 'count', name: 'events' },
          { type: 'hyperUnique', name: 'wireless_stations', fieldName: 'wireless_station' },
          { type: 'hyperUnique', name: 'wireless_channels', fieldName: 'wireless_channel' },
          { type: 'longSum', name: 'sum_wireless_tx_power', fieldName: 'wireless_tx_power' },
        ],
      },
      'rb_malware': {
        dimensions: %w(
          application_id_name building building_uuid campus campus_uuid client_id client_mac deployment deployment_uuid
          domain_name dst email_destination email_destinations email_id email_sender file_name file_size filename floor
          floor_uuid hash hash_probe_score hash_score ip_probe_score ip_score lan_ip malware_name market market_uuid
          namespace namespace_uuid organization organization_uuid probe_hash_score probe_ip_score probe_url_score
          proxy_ip score sensor_name sensor_uuid service_provider service_provider_uuid sha256 src status type url
          url_probe_score url_score wan_ip
        ),
        dimensions_exclusions: [],
        metrics: [
          { type: 'count', name: 'events' },
          { type: 'hyperUnique', name: 'files', fieldName: 'hash' },
        ],
      },
    }

    tasks.map! do |task|
      config = task_config[task['spec'].to_sym] || {
        dimensions: [],
        dimensions_exclusions: [],
        metrics: [],
      }
      task.merge(config)
    end

    execute 'restart_rb_monitor_supervisor' do
      command '/usr/lib/rvm/rubies/ruby-2.7.5/bin/ruby /usr/lib/redborder/bin/rb_restart_druid_supervisor -s rb_monitor'
      action :nothing
    end

    old_feed_rb_monitor = RbDruidIndexer::Helper.fetch_rb_monitor_feed("#{config_dir}/config.yml")

    template "#{config_dir}/config.yml" do
      source 'druid_indexer_config.erb'
      cookbook 'rb-druid-indexer'
      owner 'root'
      group 'root'
      mode '0644'
      variables(tasks: tasks, zookeeper_servers: zk_hosts)
      retries 2
      notifies :restart, 'service[rb-druid-indexer]', :delayed
      notifies :run, 'ruby_block[restart_rb_monitor_if_feed_changed]', :immediately
      # notifies :restart, 'service[druid-indexer]', :delayed # Restart needed wether all namespaces added/removed for rb_monitor
    end

    # Restart would be called on every node when template is updated
    # TODO: Run only once instead of 1 to n (number of nodes) times
    ruby_block 'restart_rb_monitor_if_feed_changed' do
      block do
        new_feed_rb_monitor = RbDruidIndexer::Helper.fetch_rb_monitor_feed("#{config_dir}/config.yml")
        if old_feed_rb_monitor != new_feed_rb_monitor
          Chef::Log.info("rb_monitor feed changed: #{old_feed_rb_monitor} -> #{new_feed_rb_monitor}; restarting supervisor.")
          run_context.resource_collection.find('execute[restart_rb_monitor_supervisor]').run_action(:run)
        end
      end
      action :nothing
    end

    Chef::Log.info('rb-druid-indexer cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service 'rb-druid-indexer' do
      supports stop: true, disable: true
      action [:stop, :disable]
    end

    Chef::Log.info('rb-druid-indexer cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    unless node['rb-druid-indexer']['registered']
      query = {}
      query['ID'] = "rb-druid-indexer-#{node['hostname']}"
      query['Name'] = 'rb-druid-indexer'
      query['Address'] = "#{node['ipaddress']}"
      query['Port'] = 2055
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['rb-druid-indexer']['registered'] = true
    end
    Chef::Log.info('rb-druid-indexer service has been registered in consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['rb-druid-indexer']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/rb-druid-indexer-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['rb-druid-indexer']['registered'] = false
    end
    Chef::Log.info('rb-druid-indexer service has been deregistered from consul')
  rescue => e
    Chef::Log.error(e.message)
  end
end
