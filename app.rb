require 'sinatra/base'
require 'hmac/strategies/query'
require 'hmac/strategies/header'
require 'yaml'
require 'erb'

class SafeDownloads < Sinatra::Base
  set :sessions, true # warden requires sessions, even if store => false is set

  use Warden::Manager do |manager|
    manager.failure_app = -> env { [401, {"Content-Length" => "0"}, [""]] }

    config_file = "#{File.dirname(__FILE__)}/config/authentication.yml"

    if File.exists? config_file
      config = YAML.load(ERB.new(File.read(config_file)).result)[ENV['RACK_ENV']]
      config[:ttl] ||= 300 # 5 minutes
    else
      raise "\nAuthentication config not found. Create a config file at: #{config_file}"
    end

    manager.scope_defaults :default, :strategies => config[:strategies], 
      :store => false, 
      :hmac => { 
        :secret => config[:secret],
        :ttl => config[:ttl]
      }
  end

  get '/downloads/*' do |path|
    env['warden'].authenticate!
    file_location = "/files/#{path}"
    headers 'X-Accel-Redirect' => file_location
  end
end

