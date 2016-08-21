# encoding: utf-8
# author: Blair Hamilton (blairham@me.com)

require 'chefspec'
require 'chefspec/berkshelf'

at_exit { ChefSpec::Coverage.report! }
