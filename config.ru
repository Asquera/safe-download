ENV['RACK_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require

require './app'
run SafeDownloads
