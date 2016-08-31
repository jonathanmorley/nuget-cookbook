#
# Author:: Blair Hamilton (bhamilton@draftkings.com>)
# Author:: Jonathan Morley (morley.jonathan@gmail.com>)
# Cookbook Name:: nuget
# Resource:: source
#
# Copyright 2015, Blair Hamilton
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

property :name, kind_of: String, name_attribute: true
property :config_file, kind_of: String, default: "#{ENV['PROGRAMDATA']}\\NuGet\\Config\\NuGet.config"
property :source, kind_of: [String, nil]

default_action :add

load_current_value do
  cmd = shell_out('nuget sources list')
  Chef::Log.debug("nuget sources list command output:\n#{cmd.stdout}")
  regex = /\s*\d+\.\s+(?<name>#{name}) (?<enabled>\[Enabled\])?\s+(?<source>.+)/

  if cmd.stderr.empty?
    result = cmd.stdout.match(regex)
    Chef::Log.debug("current_resource match output: #{result.inspect}")
    source result[:source].strip if result
  else
    Chef::Log.warn("Failed to run nuget sources list. Error:\n#{cmd.stderr}")
  end
end

action :add do
  converge_if_changed :source do
    if config_file
      directory ::File.dirname(config_file) do
        action :create
        recursive true
      end

      file config_file do
        action :create_if_missing
        content '<?xml version="1.0" encoding="utf-8"?><configuration />'
      end
    end

    nuget_cmd = 'nuget sources Add'
    nuget_cmd << " -Name \"#{new_resource.name}\"" if new_resource.name
    nuget_cmd << " -Source \"#{new_resource.source}\"" if new_resource.source
    nuget_cmd << " -ConfigFile \"#{new_resource.config_file}\"" if new_resource.config_file

    execute 'add nuget source' do
      action :run
      command nuget_cmd
    end
  end
end

action :remove do
  nuget_cmd = 'nuget sources Remove'
  nuget_cmd << " -Name \"#{new_resource.name}\"" if new_resource.name
  nuget_cmd << " -Source \"#{new_resource.source}\"" if new_resource.source
  nuget_cmd << " -ConfigFile \"#{new_resource.config_file}\"" if new_resource.config_file

  execute 'remove nuget source' do
    action :run
    command nuget_cmd
  end
end
