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
