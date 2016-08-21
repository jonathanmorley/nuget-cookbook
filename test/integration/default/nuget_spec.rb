# encoding: utf-8
# author: Jonathan Morley (morley.jonathan@gmail.com)

describe command('nuget sources list') do
  its('stdout') { should match %r{name1 \[Enabled\]\s+http://example.com/name1} }
  its('stdout') { should_not match %r{name2 \[Enabled\]\s+http://example.com/name2} }
  its('exit_status') { should eq 0 }
end
