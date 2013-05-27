require 'sinatra/base'
require 'hmac/strategies/query'
require 'hmac/strategies/header'

class SafeDownloads < Sinatra::Base
  set :sessions, true # warden requires sessions, even if store => false is set

  use Warden::Manager do |manager|
    manager.failure_app = -> env { [401, {"Content-Length" => "0"}, [""]] }
  # other scopes
    manager.scope_defaults :default, :strategies => [:hmac_query, :hmac_header], 
      :store => false, 
      :hmac => { 
        :secret => "testsecret" 
      }
  end

  get '/downloads/*' do |path|
    env['warden'].authenticate!
    file_location = "/files/#{path}"
    headers 'X-Accel-Redirect' => file_location
  end
end

