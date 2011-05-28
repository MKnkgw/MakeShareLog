require 'rubygems'
require File.join(File.dirname(__FILE__), '..', 'makeuplog.rb')

require 'rspec'
require 'rack/test'
#require 'rspec'

set :environment, :test
#set :run, false
set :raise_errors, true
set :logging, false

