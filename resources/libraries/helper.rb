# frozen_string_literal: true

require 'yaml'

module RbDruidIndexer
  module Helper
    def fetch_rb_monitor_feed(config_path, task_name = 'rb_monitor')
      default_value = 'rb_monitor'
      return default_value unless ::File.exist?(config_path)

      begin
        config = YAML.load_file(config_path)
        # tasks
        # |> task_name
        # |> feed
        task = config['tasks']&.find { |t| t['task_name'] == task_name }

        # Return its feed, or nil if not found
        task ? task['feed'] : default_value

      rescue => e
        Chef::Log.warn("Failed to read rb_monitor feed from #{config_path}: #{e}")
        default_value
      end
    end
  end
end
