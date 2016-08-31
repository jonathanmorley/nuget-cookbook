# encoding: utf-8
# author: Blair Hamilton (blairham@me.com)

require 'spec_helper'

describe 'nuget::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'includes chocolatey::default recipe' do
      expect(chef_run).to include_recipe('chocolatey::default')
    end

    it 'installs package nuget.commandline' do
      expect(chef_run).to install_chocolatey('nuget.commandline')
      expect(chef_run.chocolatey('nuget.commandline')).to notify('ruby_block[add nuget to PATH]').to(:run)
    end

    it 'does not add chocolatey bins to the PATH environment' do
      expect(chef_run.ruby_block('add nuget to PATH')).to do_nothing
    end
  end
end
