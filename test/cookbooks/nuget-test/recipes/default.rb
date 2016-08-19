nuget_sources 'name2' do
  action :remove
  source node['nuget']['repositories']['name2']
end
