#
# Author:: Blair Hamilton (bhamilton@draftkings.com)
# Cookbook Name:: nuget
# Provider:: sources
#
# Copyright:: Copyright (c) 2015, DraftKings Inc.
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
require 'rexml/document'

include Chef::Mixin::ShellOut
include REXML

def whyrun_supported?
  true
end

use_inline_resources

action :add do
  unless @current_resource.exists
    cmd = "nuget sources add -name \"#{new_resource.name}\" -source #{new_resource.source}"
    Chef::Log.debug(cmd)
    shell_out!(cmd)
    new_resource.updated_by_last_action(true)
    Chef::Log.info("#{new_resource} added")
  else
    Chef::Log.debug("#{new_resource} source already exists - nothing to do")
  end
end

action :remove do
  if @current_resource.exists
    cmd = "nuget sources remove -name \"#{new_resource.name}\" -source #{new_resource.source}"
    Chef::Log.debug(cmd)
    shell_out!(cmd)
    new_resource.updated_by_last_action(true)
    Chef::Log.info("#{new_resource} deleted")
  else
    Chef::Log.debug("#{new_resource} source does not exist - nothing to do")
  end
end

def load_current_resource
  @current_resource = Chef::Resource::NugetSources.new(new_resource.name)
  @current_resource.name(new_resource.name)
  @current_resource.source(new_resource.source)
  cmd = shell_out("nuget.exe sources list")
  Chef::Log.debug("#{new_resource} sources list command output: #{cmd.stdout}")
  regex = /(\d?[0-9]+\.\s+)(#{new_resource.name} \[Enabled\])\s+(#{new_resource.source})/
  Chef::Log.debug('Running regex')
  if cmd.stderr.empty?
    result = cmd.stdout.match(regex) 
    Chef::Log.debug("#{new_resource} current_resource match output:#{result}")
    if result
      @current_resource.exists = true
    else
      @current_resource.exists = false
    end
  else
    log "Failed to run nuget_sources action :load_current_resource, #{cmd_current_values.stderr}" do
      level :warn
    end
  end
end