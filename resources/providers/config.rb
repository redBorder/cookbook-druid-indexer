# Cookbook:: druid-indexer
# Provider:: config

include RbDruidIndexer::Helper

action :add do
  begin
    config_dir = new_resource.config_dir
    user = new_resource.user
    tasks = new_resource.tasks
    zookeeper_servers = new_resource.zookeeper_servers
    log_dir = new_resource.log_dir
    namespaces = new_resource.namespaces

    # RPM Installation
    dnf_package 'rb-druid-indexer' do
      action :upgrade
      flush_cache [:before]
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

    dimensions = {}
    Dir.glob('/var/rb-extensions/*/dimensions.yml') do |item|
      begin
        dimensions.merge!(YAML.load_file(item))
      rescue
        dimensions
      end
    end

    base_tasks = [
      { task_name: 'rb_monitor', feed: 'rb_monitor' },
      { task_name: 'rb_state', feed: 'rb_state_post' },
      { task_name: 'rb_flow', feed: 'rb_flow_post' },
      { task_name: 'rb_event', feed: 'rb_event_post' },
      { task_name: 'rb_vault', feed: 'rb_vault_post'},
      { task_name: 'rb_scanner', feed: 'rb_scanner_post' },
      { task_name: 'rb_location', feed: 'rb_loc_post' },
      { task_name: 'rb_wireless', feed: 'rb_wireless' },
    ]
    
    tasks = base_tasks.flat_map do |task|
      default_task = { spec: task[:task_name], task_name: task[:task_name], namespace: '', feed: task[:feed], kafka_host: 'kafka.service:9092' }
      default_task[:custom_dimensions] = dimensions.keys if task[:task_name] == "rb_vault"
      
      namespace_tasks = namespaces.map do |namespace|
        taskHash = { spec: task[:task_name], task_name: task[:task_name] + '_' + namespace, namespace: namespace, kafka_host: 'kafka.service:9092' }
        taskHash[:feed] = task[:feed] + '_' + namespace
        taskHash[:feed] = 'rb_monitor_post_' + namespace if task[:task_name] == 'rb_monitor'
        taskHash[:custom_dimensions] = dimensions.keys if task[:task_name] == 'rb_vault'
        taskHash
      end
    
      [default_task] + namespace_tasks
    end

    node.default['redborder']['druid-indexer-tasks'] = tasks.length

    template "#{config_dir}/config.yml" do
      source 'druid_indexer_config.erb'
      cookbook 'rb-druid-indexer'
      owner 'root'
      group 'root'
      mode '0644'
      variables(tasks: tasks, zookeeper_servers: zookeeper_servers)
      retries 2
      notifies :restart, 'service[rb-druid-indexer]', :delayed
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
