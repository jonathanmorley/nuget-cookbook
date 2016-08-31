# Make sure that adding the sources a second time works
node['nuget']['repositories'].each do |name, source|
  nuget_sources name do
    action :add
    source source
  end
end

# Remove the name2 source
nuget_sources 'name2' do
  action :remove
  source node['nuget']['repositories']['name2']
end
