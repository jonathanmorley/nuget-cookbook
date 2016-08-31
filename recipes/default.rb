#
# Author:: Blair Hamilton (blairham@me.com)
# Cookbook Name:: nuget
# Recipe:: default
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

include_recipe 'chocolatey::default'

chocolatey_package 'nuget.commandline' do
  action :install
  notifies :run, 'ruby_block[add nuget to PATH]', :immediately
end

ruby_block 'add nuget to PATH' do
  action :nothing
  block { ENV['PATH'] += ";#{ENV['PROGRAMDATA']}\\chocolatey\\bin" }
end

node['nuget']['repositories'].each do |name, source|
  nuget_sources name do
    action :add
    source source
  end
end
